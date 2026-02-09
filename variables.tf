variable "location" {
  type        = string
  description = "Azure region for the test deployment."
  default     = "eastus"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources. Leave blank to auto-generate."
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM."
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the SSH public key for the VM."
  default     = ""
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
  default     = "Standard_D2s_v5"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to access SSH/ICMP/iperf (e.g., your public IP /32)."
  default     = "0.0.0.0/0"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default = {
    project = "vpn-benchmark-test"
  }
}

variable "vpn_gateway_sku" {
  type        = string
  description = "VPN gateway SKU (e.g., VpnGw1, VpnGw2)."
  default     = "VpnGw1"
}

variable "vpn_gateway_generation" {
  type        = string
  description = "VPN gateway generation (Generation1 or Generation2)."
  default     = "Generation1"
}

variable "vpn_gateway_active_active" {
  type        = bool
  description = "Enable active-active mode for the VPN gateway."
  default     = false
}

variable "vpn_gateway_enable_bgp" {
  type        = bool
  description = "Enable BGP on the VPN gateway."
  default     = false
}

variable "use_azapi_gateway" {
  type        = bool
  description = "Use azapi to create the VPN gateway (optimized comparison run)."
  default     = false
}
