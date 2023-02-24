
locals {
  backend_address_pool_name      = "${var.prefix}-beap"
  frontend_port_name             = "${var.prefix}-feport"
  frontend_ip_configuration_name = "${var.prefix}-feipp"
  http_setting_name              = "${var.prefix}-be-htst"
  probe_name                     = "${var.prefix}-be-probe"
  listener_name                  = "${var.prefix}-httplstn"
  request_routing_rule_name      = "${var.prefix}-rqrt"
  redirect_configuration_name    = "${var.prefix}-rdrcfg"
  ssl_cert_name                  = "${var.prefix}-sslcert"
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_application_gateway" "appgtw" {
  name                = "${var.prefix}-appgtw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgtw.id
  }


  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [var.domain_name]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 80
    protocol                            = "Http"
    probe_name                          = local.probe_name
    pick_host_name_from_backend_address = true

  }

  ssl_certificate {
    name     = var.domain_name
    data     = acme_certificate.certificate.certificate_p12
    password = acme_certificate.certificate.certificate_p12_password
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    host_name                      = var.domain_name
    ssl_certificate_name           = var.domain_name

  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

}

output "appgtw_static_ip" {
  value = azurerm_public_ip.pip.ip_address
}