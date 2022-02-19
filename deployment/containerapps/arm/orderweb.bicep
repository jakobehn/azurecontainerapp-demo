param location string = 'eastue'
param environment_name string
param webVersion string

resource nodeapp 'Microsoft.Web/containerapps@2021-03-01' = {
  name: 'orderweb'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration: {
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
          image: 'jakob.azurecr.io/orderweb:${webVersion}'
          name: 'orderweb'
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
        appId: 'orderweb'
      }
    }
  }
}
