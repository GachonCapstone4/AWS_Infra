resource "proxmox_virtual_environment_container" "tailscale_lxc" {
  node_name = "suhansrv"
  vm_id     = 201
  tags      = ["network", "tailscale"]

  # Tailscale 서브넷 라우터로 쓰려면 비특권(unprivileged)을 false로 하거나,
  # nesting을 켜주는 것이 좋습니다.
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "office-tailscale-router"

    user_account {
      password = var.lxcpw
    }


    ip_config {
      ipv4 {
        address = "192.168.100.211/24"
        gateway = "192.168.100.254"
      }
    }
  }

  network_interface {
    name   = "eth0"     # 컨테이너 OS 내부 이름
    bridge = "vmbr0"    # Proxmox 브릿지 이름
  }

  # LXC는 디스크 설정이 필수입니다.
  disk {
    datastore_id = "local-lvm" # 또는 "local-zfs" 등 안동훈 님의 스토리지 ID
    size         = 8            # GB 단위
  }

  operating_system {
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }
}