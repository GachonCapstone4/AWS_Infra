## ECR.md

modules/에 ecr 모듈 생성

main.tf
프라이빗 레포지토리를 생성 이름은 capstone-ecr(/capstone/ecr)
life-cycle 
최근 4개의 컨테이너 이미지만을 저장, 4개 이상넘어갈시 가장오래된 이미지의 자동삭제설정
variables.tf

outputs.tf
ecr 내보냄

타 모듈들과 똑같이 stage/에서 호출