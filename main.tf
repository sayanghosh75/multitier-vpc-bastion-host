##############################################################################
# Main routine to create multi-tier VPC
##############################################################################

# Provider block required with Schematics to set VPC region
# Uncomment ibmcloud_api_key only in standalone mode
provider "ibm" {
  region = var.ibm_region
#  ibmcloud_api_key = var.ibmcloud_api_key         
  generation = local.generation
}

data "ibm_resource_group" "all_rg" {
  name = var.resource_group_name
}

locals {
  generation     = 2
}


##################################################################################################
#  Select CIDRs allowed to access bastion host  
#  When running under Schematics allowed ingress CIDRs are set to only allow access from Schematics  
#  for use with Remote-exec and Redhat Ansible
#  When running under Terraform local execution ingress is set to 0.0.0.0/0
#  Access CIDRs are overridden if user_bastion_ingress_cidr is set to anything other than "0.0.0.0/0" 
##################################################################################################

data "external" "env" { program = ["jq", "-n", "env"] }
locals {
  region = lookup(data.external.env.result, "TF_VAR_SCHEMATICSLOCATION", "")
  geo    = substr(local.region, 0, 2)
  schematics_ssh_access_map = {
    us = ["169.44.0.0/14", "169.60.0.0/14"],
    eu = ["0.0.0.0/0", "0.0.0.0/0"],
  }
  schematics_ssh_access = lookup(local.schematics_ssh_access_map, local.geo, ["0.0.0.0/0"])
  bastion_ingress_cidr  = var.ssh_source_cidr_override[0] != "0.0.0.0/0" ? var.ssh_source_cidr_override : local.schematics_ssh_access
}

# Create VPC
module "vpc" {
  source               = "./vpc"
  ibm_region           = var.ibm_region
  resource_group_name  = var.resource_group_name
  generation           = local.generation
  unique_id            = var.vpc_name
  bastion_count        = var.bastion_count
  bastion_cidr_blocks  = local.bastion_cidr_blocks
  frontend_count       = var.frontend_count
  frontend_cidr_blocks = local.frontend_cidr_blocks
  backend_count        = var.backend_count
  backend_cidr_blocks  = local.backend_cidr_blocks
}

locals {
  bastion_cidr_blocks  = [cidrsubnet(var.bastion_cidr, 4, 0), cidrsubnet(var.bastion_cidr, 4, 2), cidrsubnet(var.bastion_cidr, 4, 4)]   
  frontend_cidr_blocks = [cidrsubnet(var.frontend_cidr, 4, 0), cidrsubnet(var.frontend_cidr, 4, 2), cidrsubnet(var.frontend_cidr, 4, 4)]
  backend_cidr_blocks  = [cidrsubnet(var.backend_cidr, 4, 0), cidrsubnet(var.backend_cidr, 4, 2), cidrsubnet(var.backend_cidr, 4, 4)]
}


# Create Bastion zone 
module "bastion" {
  source                   = "./bastionmodule"
  ibm_region               = var.ibm_region
  bastion_count            = var.bastion_count
  unique_id                = var.vpc_name
  ibm_is_vpc_id            = module.vpc.vpc_id
  ibm_is_resource_group_id = data.ibm_resource_group.all_rg.id
  # bastion_cidr             = var.bastion_cidr
  bastion_cidr_blocks      = local.bastion_cidr_blocks
  ssh_source_cidr_blocks   = local.bastion_ingress_cidr
  destination_cidr_blocks  = [var.frontend_cidr, var.backend_cidr]
  destination_sgs          = [module.frontend.security_group_id, module.backend.security_group_id]
}

# Create Frontend zone 
module "frontend" {
  source                   = "./frontendmodule"
  ibm_region               = var.ibm_region
  unique_id                = var.vpc_name
  ibm_is_vpc_id            = module.vpc.vpc_id
  ibm_is_resource_group_id = data.ibm_resource_group.all_rg.id
  frontend_count           = var.frontend_count
  frontend_cidr_blocks     = local.frontend_cidr_blocks
  public_gateway_ids       = module.vpc.public_gateway_ids
  bastion_remote_sg_id     = module.bastion.security_group_id
  bastion_subnet_CIDR      = var.bastion_cidr
  app_backend_sg_id        = module.backend.security_group_id
  pub_repo_egress_cidr     = local.pub_repo_egress_cidr
}

# Create Backend zone 
module "backend" {
  source                   = "./backendmodule"
  ibm_region               = var.ibm_region
  unique_id                = var.vpc_name
  ibm_is_vpc_id            = module.vpc.vpc_id
  ibm_is_resource_group_id = data.ibm_resource_group.all_rg.id
  backend_count            = var.backend_count
  backend_cidr_blocks      = local.backend_cidr_blocks
  public_gateway_ids       = module.vpc.public_gateway_ids
  bastion_remote_sg_id     = module.bastion.security_group_id
  bastion_subnet_CIDR      = var.bastion_cidr
  app_frontend_sg_id       = module.frontend.security_group_id
  pub_repo_egress_cidr     = local.pub_repo_egress_cidr
}
