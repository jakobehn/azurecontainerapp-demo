$RESOURCE_GROUP="<group>"
$LOCATION="eastus"
$LOG_ANALYTICS_WORKSPACE="<workspace>"
$CONTAINERAPPS_ENVIRONMENT="<environment"

# Create resource group
az group create `
  --name $RESOURCE_GROUP `
  --location "$LOCATION"

# Create log analytics workspace
az monitor log-analytics workspace create `
  --resource-group $RESOURCE_GROUP `
  --workspace-name $LOG_ANALYTICS_WORKSPACE

$LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)

# Create container apps environment
az containerapp env create `
  --name $CONTAINERAPPS_ENVIRONMENT `
  --resource-group $RESOURCE_GROUP `
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
  --location "$LOCATION"

# Deploy orderweb
az containerapp create `
    --name orderweb `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image jakob.azurecr.io/orderweb:1.5 `
    --target-port 5000 `
    --ingress 'external' `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderweb `
    --dapr-components .\statestore.yaml `
    --registry-login-server <registry>.azurecr.io `
    --registry-username <registry> `
    --registry-password <password> `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy orderapi
az containerapp create `
    --name orderapi `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image <registry>.azurecr.io/orderapi:1.5 `
    --target-port 5000 `
    --ingress 'internal' `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderapi `
    --dapr-components .\statestore.yaml `
    --registry-login-server <registry>.azurecr.io `
    --registry-username <registry> `
    --registry-password <password> `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy orderprocessor
az containerapp create `
    --name orderprocessor `
    --resource-group $RESOURCE_GROUP `
    --environment $CONTAINERAPPS_ENVIRONMENT `
    --image <registry>.azurecr.io/orderprocessor:1.6 `
    --target-port 5000 `
    --ingress 'internal' `
    --min-replicas 1 `
    --max-replicas 10 `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderprocessor `
    --dapr-components .\statestore.yaml `
    --registry-login-server <registry>.azurecr.io `
    --registry-username <registry> `
    --registry-password <passwor> `
    --environment-variables DAPR_HTTP_PORT=3500