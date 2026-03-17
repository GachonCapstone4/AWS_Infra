# # ===========================================================
# # VM 9000 - Rocky Linux 9 K8s Node Template Base VM
# # App/Cluster 서브넷: 192.168.2.0/24 | 게이트웨이: 192.168.2.1 (pfSense vmbr2)
# #
# # [템플릿화 전체 절차]
# # Step 1. terraform apply → VM 9000 생성 (started = false)
# # Step 2. Proxmox 콘솔에서 ISO 부팅 → Rocky Linux 9 minimal 설치
# # Step 3. VM 내부에서 App-subnet/init.sh 내용을 참고해 cloud-init sysprep 수행
# # Step 4. VM 종료 후 Proxmox 호스트에서: qm template 9000
# # Step 5. 이후 K8s 노드는 VM 9000을 clone하여 생성
# # ===========================================================
# resource "proxmox_virtual_environment_vm" "rocky10_template" {
#   name        = "Rocky9-K8s-Template"
#   description = "Managed by Terraform - Rocky Linux 9 base VM for cloud-init template"
#   node_name   = "suhansrv"
#   vm_id       = 9000
#
#   tags = ["rocky9", "k8s", "template"]
#
#   # ---------------------------
#   # CPU / Memory
#   # ---------------------------
#   cpu {
#     cores   = 1
#     sockets = 1
#     type    = "host"
#   }
#
#   memory {
#     dedicated = 2048
#     floating  = 0
#   }
#
#   # ---------------------------
#   # BIOS / OS
#   # ---------------------------
#   bios = "seabios"
#
#   operating_system {
#     type = "l26"
#   }
#
#   # agent {
#   #   enabled = true  # Rocky 설치 후 qemu-guest-agent 설치 시 활성화됨
#   # }
#
#
#   cdrom {
#     file_id   = "local:iso/Rocky-10.1-x86_64-minimal.iso"
#     interface = "ide2"
#   }
#
#   # ---------------------------
#   # Disk
#   # ---------------------------
#   scsi_hardware = "virtio-scsi-single"
#
#   disk {
#     datastore_id = "local-lvm"
#     interface    = "scsi0"
#     size         = 8
#     discard      = "on"
#     iothread     = true
#     file_format  = "raw"
#   }
#
#   # ---------------------------
#   # cloud-init 드라이브 (템플릿화 후 clone 시 사용)
#   # qm template 변환 전에 아래 블록 주석 해제 → terraform apply
#   # ---------------------------
#   # initialization {
#   #   datastore_id = "local-lvm"
#   #   dns {
#   #     servers = ["192.168.2.1"]
#   #   }
#   # }
#
#   # ---------------------------
#   # Network - App/Cluster 브릿지 (vmbr2)
#   # ---------------------------
#   network_device {
#     bridge   = "vmbr2"
#     model    = "virtio"
#     firewall = false
#   }
#
#   # ---------------------------
#   # Boot order
#   # ISO 설치 중: boot_order = ["ide2", "scsi0"]  으로 변경
#   # 설치 완료 후: boot_order = ["scsi0"]  (기본값)
#   # ---------------------------
#   boot_order = ["scsi0"]
#
#   # ---------------------------
#   # Power state
#   # ISO 부팅 및 설치는 Proxmox 콘솔에서 수동 기동
#   # ---------------------------
#   on_boot = false
#   started = false
# }
