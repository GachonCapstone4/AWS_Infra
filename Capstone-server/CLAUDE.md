# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Proxmox VE 홈서버 인프라를 Terraform으로 관리하는 IaC 프로젝트. **bpg/proxmox** 프로바이더(`registry.terraform.io/bpg/proxmox`, version ~0.66) 사용. Proxmox 호스트: `192.168.0.16:8006` (노드명: `suhansrv`), 자체 서명 인증서(`insecure = true`). 사용자는 한국어로 소통합니다.

## Architecture

```
stage/              -- 루트 모듈: 프로바이더 설정 + 모듈 오케스트레이션
  main.tf           -- bpg/proxmox 프로바이더 + 하위 모듈 호출
  variables.tf      -- 루트 레벨 입력 변수 (pm_api_token_secret, lxcpw)
  terraform.tfvars  -- 실제 값 (gitignored)

vm-pfsense/         -- VM 모듈: pfSense 방화벽/게이트웨이 (VM ID: 200)
  main.tf           -- q35 머신, OVMF BIOS, 4개 NIC (WAN/DMZ/App/DB), 부팅 순서 1

lxc-Tailscale/      -- LXC 모듈: Tailscale 서브넷 라우터 (VM ID: 201)
  main.tf           -- Ubuntu 24.04 LXC, IP: 192.168.0.22/24
  variables.tf      -- proxmox 프로바이더 선언 + lxcpw 변수

App-subnet/         -- 플레이스홀더 (현재 AWS provider 스텁)
DB-Server/          -- 플레이스홀더 (현재 AWS provider 스텁)
DMZ-subnet/         -- 플레이스홀더 (현재 AWS provider 스텁)

script/
  init.sh           -- Tailscale LXC 수동 설정 스크립트 (Proxmox 호스트 + LXC 내부 실행용)
```

**네트워크 구조**: pfSense(VM 200)가 게이트웨이/방화벽 역할. 4개 브릿지:
- `vmbr0`: WAN (물리 네트워크, e1000 드라이버)
- `vmbr1`: DMZ
- `vmbr2`: App/Cluster 서브넷
- `vmbr3`: DB 서브넷

**모듈 흐름**: `stage/`가 루트 모듈. `terraform.tfvars`의 변수를 하위 모듈로 전달. `lxc-Tailscale` 모듈은 자체 `variables.tf`에 proxmox 프로바이더를 재선언함 (provider inheritance 패턴).

## Common Commands

모든 Terraform 명령은 `stage/` 디렉토리에서 실행:

```bash
cd stage
/c/terraform/terraform.exe init       # 프로바이더 및 모듈 초기화
/c/terraform/terraform.exe validate   # 설정 유효성 검사
/c/terraform/terraform.exe plan       # 변경사항 미리보기
/c/terraform/terraform.exe apply      # 변경사항 적용
/c/terraform/terraform.exe destroy    # 리소스 삭제
```

Terraform 바이너리 경로: `C:\terraform\terraform.exe` (bash에서는 `/c/terraform/terraform.exe`).

## Key Patterns

- **API 토큰 형식**: `"admin@pve!terraform-token=${var.pm_api_token_secret}"` — `user@realm!token-name=secret`
- **terraform.tfvars gitignore**: `.gitignore`에 `nul`만 있고 `*.tfvars`는 없으나, `terraform.tfvars`에 시크릿이 있으므로 절대 커밋 금지
- **LXC tun 디바이스**: `script/init.sh`는 Terraform 적용 후 Proxmox 호스트 쉘에서 수동 실행 필요 (LXC 201의 `/dev/net/tun` 마운트 + Tailscale 설치)
- **pfSense 설치 후 처리**: `vm-pfsense/main.tf`의 `cdrom` 블록은 설치 완료 후 제거 필요 (주석으로 명시됨)
- **App-subnet/DB-Server/DMZ-subnet**: 현재 AWS 프로바이더 스텁 상태 — 실제 Proxmox 리소스로 교체 예정
