param location string = 'eastus'
param environment_name string
param version string

module orderwebModule 'orderweb.bicep' = {
  name: 'orderwebDeployent'
  params: {
    environment_name: environment_name
    location: location
    webVersion: version
  }
}

module orderapiModule 'orderapi.bicep' = {
  name: 'orderapiDeployent'
  params: {
    environment_name: environment_name
    location: location
    apiVersion: version
  }
}

module orderprocessorModule 'orderprocessor.bicep' = {
  name: 'orderprocessorDeployent'
  params: {
    environment_name: environment_name
    location: location
    processorVersion: version
  }
}
