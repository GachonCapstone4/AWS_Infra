terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox" # 네트워크 브릿지 등 리소스 지원
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.100.210:8006/"
  api_token = "admin@pve!terraform-token=${var.pm_api_token_secret}"

  # 자체 서명 인증서(Self-signed)를 사용하는 온프레미스 특성상 아래 옵션이 필요합니다.
  insecure = true

}

module "pfsense" {
  source = "../vm-pfsense"
}

module "lxc-Tailscale" {
  source = "../lxc-Tailscale"
  lxcpw = var.lxcpw
}

module "dmz-subnet" {
  source = "../DMZ-subnet"
  lxcpw  = var.lxcpw
}

module "app-subnet" {
  source     = "../App-subnet"
  vmpassword = var.lxcpw
}

module "DB" {
  source     = "../DB-Server"
  vmpassword = var.lxcpw
}

module "dmz-vm" {
  source     = "../DMZ-VM"
  vmpassword = var.lxcpw
}


# resource "proxmox_virtual_environment_vm" "rocky10_template" {
#   node_name = "suhansrv"
#   vm_id     = 9001
#   template  = true # 템플릿인 경우 추가
# }


