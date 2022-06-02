variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.96.0.0/21"
}

variable "tags" {
  type = map(string)
}