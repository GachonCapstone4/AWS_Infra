# Proxmox 호스트 Shell에서 실행 (LXC ID: 201 기준)
cat <<EOF >> /etc/pve/lxc/201.conf
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
EOF
# 컨테이너 재시작
pct reboot 201

# LXC 컨테이너 내부에서 실행
# 1. Tailscale 설치
curl -fsSL https://tailscale.com/install.sh | sh

# 2. IP 포워딩 활성화 (중요: 서브넷 라우팅 필수 작업)
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Tailscale 실행 및 사무실 대역 광고
tailscale up --advertise-routes=192.168.0.0/24

