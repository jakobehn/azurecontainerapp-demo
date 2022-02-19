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
          value: 'BNZ4Cn50Q0=CW+g6IH1sYFpOSk1XaYGV'
        }
        {
          name: 'servicebus-connectionstring'
          value: 'Endpoint=sb://daprbus-demo.servicebus.windows.net/;SharedAccessKeyName=containerapp;SharedAccessKey=N/n1/EdY8QQ6cTvRsR+AxCTDOReobuHsAkOfXGikCr0=;EntityPath=orders'
        }        
      ]
      registries: [
        {
          server: 'jakob.azurecr.io'
          username: 'jakob'
          passwordSecretRef: 'acr-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'jakob.azurecr.io/orderprocessor:${processorVersion}'
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
                  value: 'Endpoint=sb://daprbus-demo.servicebus.windows.net/;SharedAccessKeyName=containerapp;SharedAccessKey=N/n1/EdY8QQ6cTvRsR+AxCTDOReobuHsAkOfXGikCr0=;EntityPath=orders'
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
                  value: 'https://daprstate.documents.azure.com:443/'
              }
              {
                  name: 'masterKey'
                  value: 'fIVJ8fN74uG4gKRdw7lzxYBEio9WUer7IX9Z4MFOewrEXIzNvfwf9vm4D6A0ir1q4yGmFuBCUGjdHPFEhJwyPg=='
              }
              {
                  name: 'database'
                  value: 'daprdemo'
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
