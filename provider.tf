terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "0.12.3"
    }
  }
}

provider "azurerm" {
    features {}
    client_id       = "3d37bf1f-1b26-47ad-9e90-9e0a28f6d0b8"
    client_secret   = "HNk.-O0vCF4_vO6xC9F~QT-EjUhAB348zZ"
    tenant_id       = "105c24b7-cab2-471b-80b4-0b2d40037b01"
    subscription_id = "b71589c6-3061-403e-9600-569f06662f20" 
}
