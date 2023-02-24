variable "prefix" {
  type        = string
  description = "Prefix of the env"

  validation {
    condition     = can(regex("^[a-z]{2,}$", var.prefix))
    error_message = "Can only be lower-case letters and be at least 2 characters long."
  }
  default = "acaappgtwcd"
}

variable "location" {
  type        = string
  description = "Location of the env"

  default = "West Europe"
}

variable "cidr" {
  type = string

  validation {
    condition     = can(cidrhost(var.cidr, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
  default = "10.0.0.0/16"
}

variable "email_address" {
  type        = string
  description = "Email address for the acme registration"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the acme registration"
}

variable "cert_password" {
  type        = string
  description = "Password for the certificate"
}
