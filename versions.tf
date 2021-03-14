
terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.20"
    }
    external = {
      source = "hashicorp/external"
    }
  }
  required_version = ">= 0.13"
}
