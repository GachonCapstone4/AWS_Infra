# 모든 메인 모듈의 경로는 CapstoneAIServer/

# vpc 모듈
vpc 모듈 디렉터리 생성
## main.tf
vpc 명 capstone-vpc
ip 대역 172.16.0.0/16 설정

## outputs.tf
vpc_id 내보냄
# subnet 생성
subnet 모듈 디렉터리 생성
## main.tf
capstone-public-subnet 생성
-- capstone-public-subnet --
vpc : capstone-vpc
ip : 172.16.1.0/24
az : ap-northeat-2a
public_ip 자동 할당: false

captstone-ai-subnet 생성
-- capstone-ai-subnet --
vpc : capstone-vpc
ip : 172.16.2.0/24
az : ap-northeast-2a
public_ip 자동 할당: false

## variables.tf 
vpc_id 받음
## outputs.tf
subnet_id 내보냄
# Routing 모듈 생성 
** igw.tf **
name : capstone-igw
** routingtable.tf **
0.0.0.0 public subnet - igw 연결
0.0.0.0 ai subnet - NatVPN 게이트웨이 ec2 연결
** variables.tf **
선언된 모든 서브넷 id 받아옴

# 보안 그룹 모듈 생성
## main.tf
** NatVPN 게이트웨이 보안그룹 **
name : capstone-natvpn-sg
인바운드
UDP 51820 0.0.0.0 
TCP IP 22 0.0.0.0
All All 17.16.0.0/16
아웃바운드
All 0.0.0.0

** AI 서버 보안그룹 **
NatVPN 게이트웨이로 부터오는 모든 트래픽 허용
All All 172.16.0.0/16
아웃바운드
All 0.0.0.0

## outputs.tf
sg id 내보냄

# ec2 모듈 생성
## main.tf
**NatVPN 게이트웨이 ec2 **
name : NatVPN Gateway
고정 ip 생성 및 할당.
subnet : capstone-public-subnet
sg : capstone-natvpn-sg
스펙 : t3.micro
os : 우분투 22.04
키 선택 : nat.pem
사설 ip : 172.16.1.10




**AI EC2 **
name : AIserver
lan ip : 172.16.2.10 할당
subnet : capstone-ai-subnet
스펙 : t3.미디움
volume : 10gb
os : 우분투 22.04
키 선택 : nat.pem

## variables.tf
 서브넷 id 받음 /보안 그룹 id 받음
## outputs.tf
ec2 id 내보냄 

# stage 
-- 호출 대상--
modules 내 전부
