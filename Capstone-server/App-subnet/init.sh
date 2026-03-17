#!/bin/bash

#템플릿 제작 순서

# selinux disalbe
vim /etc/selinux/config
...
SELINUX=disabled
systemctl disable firewalld

#일시적 ip 주소 게이트웨이 부여
ip addr add 192.168.2.10/24 dev ens18
ip link set ens18 up
ip route add default via 192.168.2.1
# DNS 네임서버 입력
vi /etc/resolv.conf
nameserver 8.8.8.8
# 기본 패키지 설치
yum install tcpdump vim psmisc net-tools bind-utils epel-release wget
# qemu-guest-agent 설치
yum install qemu-guest-agent
systemctl enable qemu-guest-agent
# hostname 초기화
hostnamectl set-hostname localhost.localdomain
# machine-id 삭제

cat /dev/null > /etc/machine-id

# ssh root key 삭제
rm -f /etc/ssh/ssh_host_*
rm -rf /root/.ssh/
rm -f /root/anaconda-ks.cfg
rm -f /root/.bash_history

# network interface script 수정
UUID 삭제

#Log 삭제
rm -f /var/log/boot.log
rm -f /var/log/cron
rm -f /var/log/dmesg
rm -f /var/log/grubby
rm -f /var/log/lastlog
rm -f /var/log/maillog
rm -f /var/log/messages
rm -f /var/log/secure
rm -f /var/log/spooler
rm -f /var/log/tallylog
rm -f /var/log/wpa_supplicant.log
rm -f /var/log/wtmp
rm -f /var/log/yum.log
rm -f /var/log/audit/audit.log
rm -f /var/log/tuned/tuned.log


#Cloud init 설치
yum install cloud-init

#Cloudinit Drive 설정
qm set [vm번호] --ide2 local-lvm:cloudinit
qm set [vm번호] --boot order=scsi0
 qm set [vm번호] --serial0 socket --vga serial0
# Proxmox Host CLI
# 초기화
apt install libguestfs-tools
virt-sysprep -a [vm디스크명]