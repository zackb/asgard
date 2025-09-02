variable "email_address" {
  description = "Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account."
}

variable "lets_encrypt_prod" {
  description = "Let's Encrypt server. False for staging, true for prod"
  type        = bool
  default     = false
}

variable "certificates" {
  type = list(object({
    domain    = string
    namespace = string
  }))
  default = []
}
