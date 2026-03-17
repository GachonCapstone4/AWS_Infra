resource "proxmox_virtual_environment_vm" "pfsense_gateway" {
  name        = "pfSense-Gateway"
  description = "Managed by Terraform - pfSense VPN Gateway"
  node_name   = "suhansrv"
  vm_id       = 200
  machine     = "q35"

  # ---------------------------
  # CPU / Memory
  # ---------------------------
  cpu {
    cores = 2
    type  = "host" # AES-NI passthrough for VPN acceleration
  }

  memory {
    dedicated = 2048
    floating  = 0 # ballooning 비활성화 → 안정적 메모리 확보
  }

  # ---------------------------
  # BIOS / OS
  # ---------------------------
  bios = "ovmf"

  operating_system {
    type = "other" # pfSense = FreeBSD base
  }

  agent {
    enabled = false
  }
  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
    pre_enrolled_keys = false
  }

  # ---------------------------
  # Boot ISO (pfSense installer)
  # 설치 완료 후 아래 cdrom 블록을 제거하세요
  # ---------------------------
  cdrom {
    file_id   = "local:iso/netgate-installer-v1.1.1-RELEASE-amd64.iso"
    interface = "sata0"
  }

  # ---------------------------
  # Disk
  # ---------------------------
  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
    discard      = "on"
    iothread     = true
  }

  # ---------------------------
  # Network Interfaces
  # ---------------------------

  # 1. WAN (stable driver priority)
  network_device {
    bridge      = "vmbr0"
    model       = "e1000"
    mac_address = "02:00:00:00:00:10"
  }

  # 2.DMZ
  network_device {
    bridge      = "vmbr1"
    model       = "virtio"
    mac_address = "02:00:00:00:00:11"
  }

  # 3. Cluster subnet
  network_device {
    bridge      = "vmbr2"
    model       = "virtio"
    mac_address = "02:00:00:00:00:12"
  }

  # 4. DB subnet
  network_device {
    bridge      = "vmbr3"
    model       = "virtio"
    mac_address = "02:00:00:00:00:13"
  }

  # ---------------------------
  # Boot order
  # ---------------------------
  boot_order = ["scsi0"] # 설치 완료 후 디스크 우선 부팅

  # ---------------------------
  # Power state / Auto-start
  # ---------------------------
  on_boot = true
  started = true

  startup {
    order      = "1"   # Proxmox 호스트 부팅 시 가장 먼저 시작
    up_delay   = "0"
    down_delay = "120" # 종료 시 다른 VM이 먼저 내려갈 시간 확보
  }
}
