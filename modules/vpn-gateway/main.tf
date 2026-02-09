resource "azurerm_public_ip" "vpn_gw" {
  name                = "pip-vpngw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "vpngw-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = var.vpn_gateway_sku
  generation    = var.vpn_gateway_generation
  active_active = var.vpn_gateway_active_active
  enable_bgp    = var.vpn_gateway_enable_bgp

  ip_configuration {
    name                          = "vpngw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  tags = var.tags
}
