param location string = 'eastus'
param environment_name string
param processorVersion string

resource nodeapp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'orderprocessor'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'acr-password'
          value: '<password>'
        }
        {
          name: 'servicebus-connectionstring'
          value: '<connectionstring>'
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
          image: '<registry>.azurecr.io/orderprocessor:${processorVersion}'
          name: 'orderprocessor'
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
        minReplicas: 0
        maxReplicas: 10
        rules: [
          {
            name: 'queue-based-autoscaling'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: 'ordercreated'
                subscriptionName: 'orderprocessor'
                queueLength: '1'
              }
              auth: [
                {
                  secretRef: 'servicebus-connectionstring'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'orderprocessor'
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
