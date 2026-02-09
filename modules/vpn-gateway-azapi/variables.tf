variable "name_prefix" {
  type        = string
  description = "Name prefix for gateway resources."
}

variable "location" {
  type        = string
  description = "Azure region for the gateway resources."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the gateway resources."
}

variable "resource_group_id" {
  type        = string
  description = "Resource group ID for the gateway resources."
}

variable "gateway_subnet_id" {
  type        = string
  description = "GatewaySubnet ID for the VPN gateway."
}

variable "vpn_gateway_sku" {
  type        = string
  description = "VPN gateway SKU (e.g., VpnGw1, VpnGw2)."
}

variable "vpn_gateway_generation" {
  type        = string
  description = "VPN gateway generation (Generation1 or Generation2)."
}

variable "vpn_gateway_active_active" {
  type        = bool
  description = "Enable active-active mode for the VPN gateway."
}

variable "vpn_gateway_enable_bgp" {
  type        = bool
  description = "Enable BGP on the VPN gateway."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
