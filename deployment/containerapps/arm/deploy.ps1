[CmdletBinding()]
param (
    [Parameter()]
    [string]$resourceGroup,
    [Parameter()]
    [string]$location,
    [Parameter()]
    [string]$logAnalyticsWorkspace,
    [Parameter()]
    [string]$environment,
    [Parameter()]
    [string]$version
)

az deployment group create `
  --resource-group "$resourceGroup" `
  --template-file ./main.bicep `
  --parameters `
      environment_name="$environment" `
      location="$location" `
      version="$version"