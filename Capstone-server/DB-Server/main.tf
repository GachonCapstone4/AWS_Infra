
resource "proxmox_virtual_environment_vm" "mariadb_nodes" {
  for_each = {
    "master" = { "id" = 400, "ip" = "192.168.3.10" },
    "slave"  = { "id" = 401, "ip" = "192.168.3.20" }
  }

  name      = "mariadb-${each.key}"
  node_name = "suhansrv"
  vm_id     = each.value.id

  # 템플릿 클론 설정
  clone {
    vm_id = 9001
    full  = true
  }


  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  # 디스크 설정
  disk {
    datastore_id = "local-lvm" # 실제 스토리지 이름 확인 필요
    interface    = "scsi0"
    size         = 20
    iothread     = true
  }

  # 네트워크 설정
  network_device {
    bridge = "vmbr3"
    model  = "virtio"
  }

  # Cloud-Init 설정 (bpg 프로바이더의 핵심 변화)
  initialization {
    datastore_id = "local-lvm" # cloud-init 드라이브가 생성될 스토리지

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
        gateway = "192.168.3.1"
      }
    }
  }
}