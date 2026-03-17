# ===========================================================
# VM 300 - Kubernetes Control Plane Node
# Rocky Linux 10 (cloud-init clone from template 9001)
# App/Cluster 서브넷: 192.168.2.0/24 | 게이트웨이: 192.168.2.1 (pfSense vmbr2)
#
# [사전 요구사항]
# - Proxmox에 VM 9001 (Rocky10-Template) 이 템플릿 상태로 존재해야 함
# - qemu-guest-agent가 템플릿에 설치되어 있어야 cloud-init이 동작함
# ===========================================================

resource "proxmox_virtual_environment_vm" "control_plane" {
  name        = "k8s-control-plane"
  description = "Managed by Terraform - Kubernetes Control Plane Node"
  node_name   = "suhansrv"
  vm_id       = 300

  tags = ["rocky10", "k8s", "control-plane"]

  # ---------------------------
  # 템플릿 클론 (VM 9001: Rocky10-Template)
  # ---------------------------
  clone {
    vm_id = 9001
    full  = true
  }

  # ---------------------------
  # QEMU Guest Agent
  # ---------------------------
  agent {
    enabled = true
  }

  # ---------------------------
  # CPU / Memory
  # ---------------------------
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 4096
    floating  = 0
  }

  # ---------------------------
  # BIOS / OS
  # ---------------------------
  bios = "seabios"

  operating_system {
    type = "l26"
  }

  # ---------------------------
  # Disk (템플릿 디스크 리사이즈)
  # ---------------------------
  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
    discard      = "on"
    iothread     = true
    file_format  = "raw"
  }

  # ---------------------------
  # Cloud-init 초기화
  # ---------------------------
  initialization {
    datastore_id = "local-lvm"

    user_account {
      username = "suhan"
      password = var.vmpassword
    }

    dns {
      servers = ["8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "192.168.2.10/24"
        gateway = "192.168.2.1"
      }
    }
  }

  # ---------------------------
  # Network - App/Cluster 브릿지 (vmbr2)
  # ---------------------------
  network_device {
    bridge   = "vmbr2"
    model    = "virtio"
    firewall = false
  }

  # ---------------------------
  # VGA / Display
  # ---------------------------
  vga {
    type   = "virtio"
    memory = 16
  }

  # ---------------------------
  # Boot order / Power state
  # ---------------------------
  boot_order = ["scsi0"]

  on_boot = true
  started = true

  startup {
    order      = "2"  # pfSense(order=1) 다음에 시작
    up_delay   = "30" # pfSense 네트워크 준비 대기
    down_delay = "0"  # 종료는 바로 (pfSense down_delay=120이 커버)
  }
}
