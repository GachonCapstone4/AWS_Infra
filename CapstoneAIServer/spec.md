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
-- capstone-public-subnet --
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
** variables.tf **
선언된 모든 서브넷 id 받아옴

# ec2 모듈 생성


# 보안 그룹 모듈 생성

# stage 
-- 호출 대상--
vpc 모듈
subnet 모듈
igw 모듈