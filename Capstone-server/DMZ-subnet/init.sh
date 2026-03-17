
# 알파인 리눅스(Bastion)

# 커뮤니티 저장소  #제거
vi /etc/apk/repositories

# gemu-agent 설치
apk add qemu-guest-agent

rc-service qemu-guest-agent start


#Haproxy

apt update

apt install haproxy -y
