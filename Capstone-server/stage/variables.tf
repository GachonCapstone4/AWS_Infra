variable "pm_api_token_secret" {
  description = "Proxmox API 토큰 시크릿 키"
  type        = string
  sensitive   = true
}

variable "lxcpw" {

  description = "Proxmox lxc 비밀번호"
  type = string
  sensitive   = true
}


