# ===========================================================
# VM 301, 302 - Kubernetes Worker Nodes (for_each)
# Rocky Linux 10 (cloud-init clone from template 9001)
# App/Cluster 서브넷: 192.168.2.0/24 | 게이트웨이: 192.168.2.1 (pfSense vmbr2)
#
# [사전 요구사항]
# - Proxmox에 VM 9001 (Rocky10-Template) 이 템플릿 상태로 존재해야 함
# - qemu-guest-agent가 템플릿에 설치되어 있어야 cloud-init이 동작함
# ===========================================================

locals {
  worker_nodes = {
    "1" = {
      vm_id = 301
      ip    = "192.168.2.20"
    }
    "2" = {
      vm_id = 302
      ip    = "192.168.2.30"
    }
  }
}

resource "proxmox_virtual_environment_vm" "worker_node" {
  for_each = local.worker_nodes

  name        = "k8s-worker-${each.key}"
  description = "Managed by Terraform - Kubernetes Worker Node ${each.key}"
  node_name   = "suhansrv"
  vm_id       = each.value.vm_id

  tags = ["rocky10", "k8s", "worker"]

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
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 8192
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
    size         = 40
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
        address = "${each.value.ip}/24"
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
    order      = "3"  # control-plane(order=2) 다음에 시작
    up_delay   = "60" # control-plane 준비 대기
    down_delay = "0"
  }
}
