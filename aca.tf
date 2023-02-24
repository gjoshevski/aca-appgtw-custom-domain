resource "azurerm_log_analytics_workspace" "main" {
  name                = format("%s-%s", var.prefix, "logs")
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = format("%s-%s", var.prefix, "env")
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  infrastructure_subnet_id       = azurerm_subnet.aca.id
  internal_load_balancer_enabled = true
}

resource "azurerm_container_app" "main" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    custom_domain {
      name           = var.domain_name
      certificate_id = azurerm_container_app_environment_certificate.main.id
    }
  }
}

resource "azurerm_container_app_environment_certificate" "main" {
  name                         = "mycertificate"
  container_app_environment_id = azurerm_container_app_environment.main.id
  certificate_blob_base64      = acme_certificate.certificate.certificate_p12
  certificate_password         = acme_certificate.certificate.certificate_p12_password
}
