output "id" {
  value = azurerm_virtual_network_gateway.vpn_gw.id
}

output "sku" {
  value = azurerm_virtual_network_gateway.vpn_gw.sku
}

output "vpn_type" {
  value = azurerm_virtual_network_gateway.vpn_gw.vpn_type
}

output "generation" {
  value = azurerm_virtual_network_gateway.vpn_gw.generation
}

output "active_active" {
  value = azurerm_virtual_network_gateway.vpn_gw.active_active
}

output "enable_bgp" {
  value = azurerm_virtual_network_gateway.vpn_gw.enable_bgp
}
