output "id" {
  value = azapi_resource.vpn_gw.id
}

output "sku" {
  value = var.vpn_gateway_sku
}

output "vpn_type" {
  value = "RouteBased"
}

output "generation" {
  value = var.vpn_gateway_generation
}

output "active_active" {
  value = var.vpn_gateway_active_active
}

output "enable_bgp" {
  value = var.vpn_gateway_enable_bgp
}
