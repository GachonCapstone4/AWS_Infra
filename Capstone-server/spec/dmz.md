## VM

가상 머신 2개를 생성할 예정. DMZ 서브넷에서 구동할 가상머신으로 각각 Nginx Server 와 jump host임.
Nginx - 로키리눅스 iso 선택. CPU 1개 RAM 1기가 할당 
jump host - 알파인리눅스 iso 선택 cpu 1개 RAm 512 MB 할당

이둘은 vmbr1 브릿지와 연결되어야함. 

pFsense를 통한 트레픽 제어를 받음 (vm-pfsense)
