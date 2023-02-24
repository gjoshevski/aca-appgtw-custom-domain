resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem          = acme_registration.reg.account_key_pem
  common_name              = var.domain_name
  certificate_p12_password = var.cert_password

  dns_challenge {
    provider = "azure"
  }
}
