# ===========================================================
# VM 204 - DMZ Test VM
# Rocky Linux 10 (cloud-init clone from template 9001)
# DMZ 서브넷: 192.168.1.0/24 | 게이트웨이: 192.168.1.1 (pfSense vmbr1)
#
# [사전 요구사항]
# - Proxmox에 VM 9001 (Rocky10-Template) 이 템플릿 상태로 존재해야 함
# - qemu-guest-agent가 템플릿에 설치되어 있어야 cloud-init이 동작함
# ===========================================================

resource "proxmox_virtual_environment_vm" "dmz_test_vm" {
  name        = "dmz-test-vm"
  description = "Managed by Terraform - DMZ Test VM"
  node_name   = "suhansrv"
  vm_id       = 210

  tags = ["dmz", "rocky10", "test"]

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
    dedicated = 2048
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
  # Disk
  # ---------------------------
  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 8
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
        address = "192.168.1.50/24"
        gateway = "192.168.1.1"
      }
    }
  }

  # ---------------------------
  # Network - DMZ 브릿지 (vmbr1)
  # ---------------------------
  network_device {
    bridge   = "vmbr1"
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
    order      = "3"
    up_delay   = "30"
    down_delay = "0"
  }
}
