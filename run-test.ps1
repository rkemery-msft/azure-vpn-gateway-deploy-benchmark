param(
  [switch]$FullApply,
  [switch]$Optimized,
  [string]$OptimizedSku = "VpnGw1",
  [string]$OptimizedGeneration = "Generation1",
  [bool]$OptimizedUseAzapi = $true,
  [switch]$NoLog
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
  throw "Terraform is not available in PATH. Open a new terminal or refresh PATH and try again."
}

if ($FullApply -and $Optimized) {
  throw "Choose either -FullApply or -Optimized, not both."
}

Write-Host "Running terraform apply to measure VPN gateway deployment time..." -ForegroundColor Cyan
$null = terraform init
if ($LASTEXITCODE -ne 0) {
  throw "terraform init failed with exit code $LASTEXITCODE. Fix the error and re-run."
}
$start = Get-Date
$mode = "standard"
$applyArgs = @("-auto-approve")
if ($Optimized) {
  $mode = "optimized"
  $useAzapiValue = $OptimizedUseAzapi.ToString().ToLower()
  $applyArgs += "-var=use_azapi_gateway=$useAzapiValue"
  $applyArgs += "-var=vpn_gateway_sku=$OptimizedSku"
  $applyArgs += "-var=vpn_gateway_generation=$OptimizedGeneration"
  $applyArgs += "-var=vpn_gateway_active_active=false"
  $applyArgs += "-var=vpn_gateway_enable_bgp=false"
  if ($OptimizedUseAzapi) {
    $applyArgs += "-target=module.vpn_gateway_azapi"
  } else {
    $applyArgs += "-target=module.vpn_gateway"
  }
} elseif ($FullApply) {
  $mode = "full"
} else {
  $applyArgs += "-target=module.vpn_gateway"
}

terraform apply @applyArgs
$exitCode = $LASTEXITCODE
$end = Get-Date

if ($exitCode -ne 0) {
  throw "terraform apply failed with exit code $exitCode. Fix the error and re-run."
}

$elapsed = $end - $start
Write-Host ("Total apply time: {0} minutes {1} seconds" -f [int]$elapsed.TotalMinutes, $elapsed.Seconds) -ForegroundColor Green
Write-Host "Mode: $mode" -ForegroundColor Green
if ($Optimized) {
  Write-Host "Optimized SKU: $OptimizedSku" -ForegroundColor Green
  Write-Host "Optimized Generation: $OptimizedGeneration" -ForegroundColor Green
  Write-Host "Optimized Use AzAPI: $OptimizedUseAzapi" -ForegroundColor Green
}

$outputs = @{}
$outputsJson = terraform output -json 2>$null
if ($LASTEXITCODE -eq 0 -and $outputsJson) {
  try {
    $outputs = $outputsJson | ConvertFrom-Json
  } catch {
    $outputs = @{}
  }
}

$rg = $outputs.resource_group.value
$gwId = $outputs.vpn_gateway_id.value
$sku = $outputs.vpn_gateway_sku.value
$vpnType = $outputs.vpn_gateway_type.value
$gen = $outputs.vpn_gateway_generation.value
$active = $outputs.vpn_gateway_active_active.value
$bgp = $outputs.vpn_gateway_enable_bgp.value

Write-Host "VPN gateway characteristics:" -ForegroundColor Cyan
Write-Host "  Resource Group: $rg"
Write-Host "  Gateway ID: $gwId"
Write-Host "  SKU: $sku"
Write-Host "  VPN Type: $vpnType"
Write-Host "  Generation: $gen"
Write-Host "  Active-Active: $active"
Write-Host "  BGP Enabled: $bgp"

if (-not $NoLog) {
  $readmePath = Join-Path $PSScriptRoot "README.md"
  $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
  $minutes = [int]$elapsed.TotalMinutes
  $seconds = $elapsed.Seconds
  $entry = @(
    "",
    "### Deploy Results",
    "- Mode: $mode",
    "- Optimized SKU: $OptimizedSku",
    "- Optimized Generation: $OptimizedGeneration",
    "- Optimized Use AzAPI: $OptimizedUseAzapi",
    "- Timestamp: $timestamp",
    "- Total apply time: ${minutes}m ${seconds}s",
    "- Resource group: $rg",
    "- Gateway ID: $gwId",
    "- SKU: $sku",
    "- VPN type: $vpnType",
    "- Generation: $gen",
    "- Active-active: $active",
    "- BGP enabled: $bgp"
  )
  Add-Content -Path $readmePath -Value $entry
  Write-Host "Appended deploy results to README.md" -ForegroundColor Green
} else {
  Write-Host "Skipping README logging (-NoLog)" -ForegroundColor Yellow
}
