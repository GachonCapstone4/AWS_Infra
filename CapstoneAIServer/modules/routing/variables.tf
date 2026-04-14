variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = object({
    public = string
    ai     = string
  })
}

variable "natvpn_eni_id" {
  type = string
}
