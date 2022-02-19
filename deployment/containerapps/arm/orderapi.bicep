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
          value: 'BNZ4Cn50Q0=CW+g6IH1sYFpOSk1XaYGV'
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
          image: 'jakob.azurecr.io/orderapi:${apiVersion}'
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
