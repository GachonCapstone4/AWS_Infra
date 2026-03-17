# ===========================================================
# LXC 202 - DMZ HAProxy (Ubuntu 24.04)
# DMZ 서브넷: 192.168.1.0/24 | 게이트웨이: 192.168.1.1 (pfSense vmbr1)
# ===========================================================
resource "proxmox_virtual_environment_container" "dmz_haproxy" {
  node_name = "suhansrv"
  vm_id     = 202
  tags      = ["dmz", "haproxy"]

  unprivileged = true

  # ---------------------------
  # CPU / Memory
  # ---------------------------
  cpu {
    cores = 1
    units = 1024
  }

  memory {
    dedicated = 512
    swap = 512
  }

  features {
    nesting = true
  }

  # ---------------------------
  # Init / Network
  # ---------------------------
  initialization {
    hostname = "dmz-haproxy"

    user_account {
      password = var.lxcpw
    }

    ip_config {
      ipv4 {
        address = "192.168.1.10/24"
        gateway = "192.168.1.1"
      }
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1"
    firewall = false
  }

  # ---------------------------
  # Disk
  # ---------------------------
  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  # ---------------------------
  # OS Template
  # ---------------------------
  operating_system {
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }

  # ---------------------------
  # Power state / Auto-start
  # ---------------------------
  start_on_boot = true
  started       = true

  startup {
    order      = "2"  # pfSense(1) 이후 기동
    up_delay   = "30" # pfSense 준비 대기
    down_delay = "0"
  }
}

# ===========================================================
# VM 203 - DMZ Jump Host (Alpine Linux)
# DMZ 서브넷: 192.168.1.0/24 | 게이트웨이: 192.168.1.1 (pfSense vmbr1)
# ===========================================================
resource "proxmox_virtual_environment_vm" "dmz_jumphost" {
  name        = "DMZ-JumpHost"
  description = "Managed by Terraform - DMZ Jump Host"
  node_name   = "suhansrv"
  vm_id       = 203

  # ---------------------------
  # CPU / Memory
  # ---------------------------
  cpu {
    cores = 1
    type  = "host"
  }

  memory {
    dedicated = 512
    floating  = 0
  }

  # ---------------------------
  # BIOS / OS
  # ---------------------------
  bios = "seabios"

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }

  # ---------------------------
  # Boot ISO (Alpine Linux installer)
  # 설치 완료 후 아래 cdrom 블록을 제거하세요
  # ---------------------------
  cdrom {
    file_id   = "none"
    interface = "ide3"
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
  }

  # ---------------------------
  # Network - DMZ 브릿지 (vmbr1)
  # ---------------------------
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # ---------------------------
  # Boot order
  # ---------------------------
  boot_order = ["scsi0", "ide3"]

  # ---------------------------
  # Power state / Auto-start
  # ---------------------------
  on_boot = true
  started = true

  startup {
    order      = "3"  # pfSense(1) 이후 기동
    up_delay   = "30" # pfSense 준비 대기
    down_delay = "0"
  }
}
