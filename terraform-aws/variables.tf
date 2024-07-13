variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância"
  type        = string
  default     = "c5.xlarge"
}

variable "ami_id" {
  description = "ID da AMI"
  type        = string
  default     = "ami-0b320e43c9f810fcb"
}

variable "tag_environment" {
  description = "Tag de ambiente"
  type        = string
  default     = "Dev"
}