param location string = 'eastus'
param environment_name string
param apiVersion string

resource nodeapp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'orderapi'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: true
        targetPort: 5000
      }
      secrets: [
        {
          name: 'acr-password'
          value: '<password>'
        }
      ]
      registries: [
        {
          server: '<registry>.azurecr.io'
          username: '<registry>'
          passwordSecretRef: 'acr-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: '<registry>.azurecr.io/orderapi:${apiVersion}'
          name: 'orderapi'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
          env: [
            {
              name: 'DAPR_HTTP_PORT'
              value: '3500'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'orderapi'
        components: [
          {
            name: 'orderpubsub'
            type: 'pubsub.azure.servicebus'
            version: 'v1'
            metadata: [
              {
                  name: 'connectionString'
                  value: '<connectionstring>'
              }
            ]
          }
          {
            name: 'statestore'
            type: 'state.azure.cosmosdb'
            version: 'v1'
            metadata: [
              {
                  name: 'url'
                  value: 'https://<database>.documents.azure.com:443/'
              }
              {
                  name: 'masterKey'
                  value: '<key>'
              }
              {
                  name: 'database'
                  value: '<database>'
              }
              {
                  name: 'collection'
                  value: 'orders'
              }
            ]
          }            
        ]
      }
    }
  }
}
