## ssh 설정 완료
## 3개 노드 전부
sudo swapoff -a
#swap 영구 비활성화
sudo sed -i '/swap/s/^/#/' /etc/fstab

## 방화벽 설정
sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

#Control Plane

# k8s API 서버
sudo firewall-cmd --permanent --add-port=6443/tcp
# k8s 상태 정보가 저장되는 etcd server client API
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
# Kubelet API (10250) - 마스터가 각 노드의 상태를 확인하고 명령을 내릴 때 쓰는 채널
# kube-schdduler(10251) 어떤 노드에 pod를 띄울지 결정하는 스케줄러 확인용
# kube-controller-manager(10252) 클러스터의 상태를 감시하고 조절하는 컨트롤러용
sudo firewall-cmd --permanent --add-port=10250-10252/tcp
# Flannel(8285) / VXLAN(8472) - 네트워크 플러그인 용. 서로 다른 노드에 있는 Pod 끼리 통신할때의 사용하는 가상 터널.
sudo firewall-cmd --permanent --add-port=8285/udp
sudo firewall-cmd --permanent --add-port=8472/udp




#Data Plane

# Kubelet API (10250) - 마스터가 각 노드의 상태를 확인하고 명령을 내릴 때 쓰는 채널
sudo firewall-cmd --permanent --add-port=10250/tcp

# NodePort Services - 외부에서 브라우저 등을 통해 서비스에 접속할 때 쓰는 포트 범위입니다.
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --permanent --add-port=8285/udp
sudo firewall-cmd --permanent --add-port=8472/udp
sudo firewall-cmd --permanent --add-port=26443/tcp


#추가 Calico 허용 포트 (공용)

# 1. BGP 라우팅용
sudo firewall-cmd --permanent --add-port=179/tcp

# 2. VXLAN 캡슐화용 (사용할 경우)
sudo firewall-cmd --permanent --add-port=4789/udp

# 3. IP-in-IP 프로토콜 허용 (포트가 아니라 프로토콜 자체를 허용)
sudo firewall-cmd --permanent --add-protocol=ipip

# 4. Calico Typha (나중을 위해 미리 열어둬도 무방)
sudo firewall-cmd --permanent --add-port=5473/tcp

# 설정 적용
sudo firewall-cmd --reload


# 브릿지 네트워크 통신을 위해 overlay와 br_netfilter 모듈 호출
# 1. 재부팅 시에도 자동으로 로드되도록 설정 파일 생성
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# 2. 현재 세션에 즉시 모듈 로드
sudo modprobe overlay
sudo modprobe br_netfilter



# 네트워크 파라미터 설정 - 노드 간 통신 및 Pod 간의 통신을 위해 IP 포워딩과 브릿지 트래픽 처리를 활성화 한다.
# 1. 쿠버네티스용 커널 파라미터 설정 파일 생성
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf

net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1

EOF

# 2. 설정 변경 사항 즉시 적용
sudo sysctl --system

# 커널 모듈 확인:
lsmod | grep -e overlay -e br_netfilter
# 네트워크 파라미터 확인
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

sudo vi /etc/selinux/config

SELINUX= permissive

sudo reboot

# host 설정

sudo vi /etc/cloud/templates/hosts.redhat.tmpl
# Kubernetes Cluster Nodes
192.168.2.10  k8s-control-plane
192.168.2.20  k8s-worker-1
192.168.2.30  k8s-worker-2

# Containerd 설정

# 1. dnf-utils 설치 (저장소 관리를 편하게 해줍니다)
sudo dnf install -y dnf-utils

# 2. Docker 공식 저장소 추가 (여기서 containerd.io를 가져옵니다)
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 3. containerd 설치
sudo dnf install -y containerd.io

# 1. 기본 설정 파일 생성
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 2. SystemdCgroup 옵션을 true로 변경 (K8s와 OS의 자원 관리 방식을 통일)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# 3. 서비스 시작 및 부팅 시 자동 실행 등록
sudo systemctl restart containerd
sudo systemctl enable containerd

# 쿠버네티스 패키지 설치

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

# 1. 캐시 갱신
sudo dnf makecache

# 2. 패키지 설치 (exclude 설정을 무시하고 설치하는 옵션 포함)
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# 3. Kubelet 서비스 활성화 (부팅 시 자동 실행)
sudo systemctl enable --now kubelet

# conntrack 설치
sudo dnf install -y conntrack-tools

# Control Plane

# Calico 기본 대역대 명시
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# kubectl root 아니어도 이용할 수 있게
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Calico 설치
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

# Join 명령어 확인하기
kubeadm token create --print-join-command

# 워커노드에서 해당 명령어 입력

# 컨트롤 플레인에서 확인
kubectl get nodes