terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

variable "vmpassword" {
  description = "VM cloud-init 사용자 비밀번호"
  type        = string
  sensitive   = true
}
