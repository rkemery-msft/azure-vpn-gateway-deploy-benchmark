terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

resource "azapi_resource" "public_ip" {
  type      = "Microsoft.Network/publicIPAddresses@2023-11-01"
  name      = "pip-vpngw-${var.name_prefix}"
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags

  body = jsonencode({
    sku = {
      name = "Standard"
    }
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
    }
  })
}

resource "azapi_resource" "vpn_gw" {
  type      = "Microsoft.Network/virtualNetworkGateways@2023-11-01"
  name      = "vpngw-${var.name_prefix}"
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags
  schema_validation_enabled = false

  body = jsonencode({
    properties = {
      gatewayType          = "Vpn"
      vpnType              = "RouteBased"
      enableBgp            = var.vpn_gateway_enable_bgp
      activeActive         = var.vpn_gateway_active_active
      vpnGatewayGeneration = var.vpn_gateway_generation
      sku = {
        name = var.vpn_gateway_sku
        tier = var.vpn_gateway_sku
      }
      ipConfigurations = [
        {
          name = "vpngw-ipconfig"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            publicIPAddress = {
              id = azapi_resource.public_ip.id
            }
            subnet = {
              id = var.gateway_subnet_id
            }
          }
        }
      ]
    }
  })

  depends_on = [azapi_resource.public_ip]
}
