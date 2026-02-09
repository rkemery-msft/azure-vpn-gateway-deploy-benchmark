# Azure Test Case (VPN Gateway Deploy Time)

This Terraform config deploys a minimal VNet + VM plus a VPN gateway. It is
intended to measure VPN gateway deployment time and record its characteristics.

This public version is sanitized for demo and testing use. It does not contain
any secrets or account identifiers.

## What this demonstrates

- Baseline and optimized VPN gateway deployment timing in Azure.
- A comparison of azurerm vs azapi for provisioning the same gateway shape.
- Repeatable, self-contained test harness for demos and CI-style validation.

## Pre-checks

- Azure CLI is installed and logged in: `az account show`
- Terraform is installed: `terraform version`
- SSH public key exists at `../.ssh/vpn-bench.pub`

Optional: copy `terraform.tfvars.example` to `terraform.tfvars` and edit as needed.

## Deploy (optional)

```powershell
cd .\azure-testcase-public
terraform init
terraform apply
```

## Run the test (measures deploy time)

This runs `terraform apply` and prints the total apply time plus VPN gateway
characteristics from outputs. By default it targets only the VPN gateway module
to avoid deploying the VM.

```powershell
.\run-test.ps1
```

To run a full apply (VM + gateway):

```powershell
.\run-test.ps1 -FullApply
```

To run the optimized comparison (azapi gateway create):

```powershell
.\run-test.ps1 -Optimized
```

You can override the optimized defaults:

```powershell
.\run-test.ps1 -Optimized -OptimizedSku VpnGw2 -OptimizedGeneration Generation2 -OptimizedUseAzapi:$true
```

Note: Microsoft documents that VPN gateway creation can take 45 minutes or more,
depending on SKU. The backend provisioning time dominates, so optimizations in
Terraform (including azapi) may not significantly reduce wall-clock time.
See: https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-vnet-vnet-resource-manager-portal#create-and-configure-vnet1

## Destroy

```powershell
terraform destroy
```

## Results

The results below are anonymized for public sharing.

### Deploy Results
- Timestamp: 2026-02-08 (backfilled)
- Total apply time: 48m 42s
- Resource group: <resource-group>
- Gateway ID: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworkGateways/<gateway-name>
- SKU: VpnGw1
- VPN type: RouteBased
- Generation: Generation1
- Active-active: false
- BGP enabled: false

### Deploy Results
- Timestamp: 2026-02-08 21:32:26 UTC
- Total apply time: 48m 53s
- Resource group: <resource-group>
- Gateway ID: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworkGateways/<gateway-name>
- SKU: VpnGw2
- VPN type: RouteBased
- Generation: Generation1
- Active-active: false
- BGP enabled: false

### Deploy Results
- Mode: optimized
- Optimized SKU: VpnGw2
- Optimized Generation: Generation2
- Optimized Use AzAPI: True
- Timestamp: 2026-02-08 22:23:15 UTC
- Total apply time: 27m 15s
- Resource group: <resource-group>
- Gateway ID: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworkGateways/<gateway-name>
- SKU: VpnGw2
- VPN type: RouteBased
- Generation: Generation2
- Active-active: false
- BGP enabled: false

### Deploy Results
- Mode: optimized
- Optimized SKU: VpnGw2
- Optimized Generation: Generation2
- Optimized Use AzAPI: False
- Timestamp: 2026-02-08 23:10:43 UTC
- Total apply time: 29m 15s
- Resource group: <resource-group>
- Gateway ID: /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworkGateways/<gateway-name>
- SKU: VpnGw2
- VPN type: RouteBased
- Generation: Generation2
- Active-active: False
- BGP enabled: False
