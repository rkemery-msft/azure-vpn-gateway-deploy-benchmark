resource "random_pet" "suffix" {
  length = 2
}

locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "vpnbench-${random_pet.suffix.id}"
  ssh_public_key_path = var.ssh_public_key_path != "" ? var.ssh_public_key_path : "${path.module}/../.ssh/vpn-bench.pub"
  cloud_init = <<-EOF
  #cloud-config
  package_update: true
  packages:
    - iperf3
    - iputils-ping
  runcmd:
    - sysctl -w net.ipv4.ip_forward=1
  EOF
  vpn_gateway_id = try(module.vpn_gateway_azapi[0].id, module.vpn_gateway[0].id)
  vpn_gateway_sku = try(module.vpn_gateway_azapi[0].sku, module.vpn_gateway[0].sku)
  vpn_gateway_type = try(module.vpn_gateway_azapi[0].vpn_type, module.vpn_gateway[0].vpn_type)
  vpn_gateway_generation = try(module.vpn_gateway_azapi[0].generation, module.vpn_gateway[0].generation)
  vpn_gateway_active_active = try(module.vpn_gateway_azapi[0].active_active, module.vpn_gateway[0].active_active)
  vpn_gateway_enable_bgp = try(module.vpn_gateway_azapi[0].enable_bgp, module.vpn_gateway[0].enable_bgp)
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.255.0/27"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${local.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.allowed_ssh_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_icmp" {
  name                        = "allow-icmp"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allowed_ssh_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_iperf" {
  name                        = "allow-iperf"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5201"
  source_address_prefix       = var.allowed_ssh_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-${local.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

module "vpn_gateway" {
  source = "./modules/vpn-gateway"
  count  = var.use_azapi_gateway ? 0 : 1

  name_prefix               = local.name_prefix
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  gateway_subnet_id         = azurerm_subnet.gateway_subnet.id
  vpn_gateway_sku           = var.vpn_gateway_sku
  vpn_gateway_generation    = var.vpn_gateway_generation
  vpn_gateway_active_active = var.vpn_gateway_active_active
  vpn_gateway_enable_bgp    = var.vpn_gateway_enable_bgp
  tags                      = var.tags
}

module "vpn_gateway_azapi" {
  source = "./modules/vpn-gateway-azapi"
  count  = var.use_azapi_gateway ? 1 : 0

  name_prefix               = local.name_prefix
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  resource_group_id         = azurerm_resource_group.rg.id
  gateway_subnet_id         = azurerm_subnet.gateway_subnet.id
  vpn_gateway_sku           = var.vpn_gateway_sku
  vpn_gateway_generation    = var.vpn_gateway_generation
  vpn_gateway_active_active = var.vpn_gateway_active_active
  vpn_gateway_enable_bgp    = var.vpn_gateway_enable_bgp
  tags                      = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${local.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(local.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(local.cloud_init)

  disable_password_authentication = true
}
