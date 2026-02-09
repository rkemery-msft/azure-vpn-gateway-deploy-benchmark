output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "ssh_command" {
  value = "ssh -i ${local.ssh_public_key_path} ${var.admin_username}@${azurerm_public_ip.vm.ip_address}"
}

output "vpn_gateway_id" {
  value = local.vpn_gateway_id
}

output "vpn_gateway_sku" {
  value = local.vpn_gateway_sku
}

output "vpn_gateway_type" {
  value = local.vpn_gateway_type
}

output "vpn_gateway_generation" {
  value = local.vpn_gateway_generation
}

output "vpn_gateway_active_active" {
  value = local.vpn_gateway_active_active
}

output "vpn_gateway_enable_bgp" {
  value = local.vpn_gateway_enable_bgp
}
