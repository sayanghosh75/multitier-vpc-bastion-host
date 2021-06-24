##############################################################################
# Account Variables
##############################################################################

# Target region
variable "ibm_region" {
  description = "IBM Cloud region where all VPC resources will be deployed"
  default     = "au-syd"
  # default     = "us-south"
  # default     = "us-east"
  # default     = "eu-gb"
}

# Update only in standalone mode
$variable "ibmcloud_api_key" {
#  description = "IBM Cloud API Key"
#  default = ""
$}

# Resource group name
variable "resource_group_name" {
  description = "Name of IBM Cloud resource group to be used for all VPC resources"
  default     = "VPC-admin"
}

# Unique name for the VPC in the account 
variable "vpc_name" {
  description = "Name of VPC"
  default     = "sayan-tf-vpc"
}


##############################################################################
# Network variables
##############################################################################

# When running under Schematics the default here is overriden to only SSH access 
# from remove-exec or Redhat Ansible running under Schematics 

variable "ssh_source_cidr_override" {
  type        = list
  description = "Override CIDR range that is allowed to ssh to the bastion"
  default     = ["0.0.0.0/0"]
}


locals {
  pub_repo_egress_cidr = "0.0.0.0/0" # cidr range required to contact public software repositories 
}

# Predefine subnet IP address ranges for all app tiers for use with `ibm_is_address_prefix`.  
# Each app tier uses: 
# frontend_cidr_blocks = [cidrsubnet(var.frontend_cidr, 4, 0), cidrsubnet(var.frontend_cidr, 4, 2), cidrsubnet(var.frontend_cidr, 4, 4)]
# to create individual zone subnets for use with `ibm_is_address_prefix`

variable "bastion_cidr" {
  description = "Complete CIDR range across all three zones for bastion host subnets"
  default     = "172.16.0.0/20"
}

variable "frontend_cidr" {
  description = "Complete CIDR range across all three zones for frontend subnets"
  default     = "172.17.0.0/20"
}

variable "backend_cidr" {
  description = "Complete CIDR range across all three zones for backend subnets"
  default     = "172.18.0.0/20"
}

variable "bastion_count" {
  description = "Number of bastion zones"
  default     = 1
}

variable "frontend_count" {
  description = "Number of front end zones (and public gateways)"
  default     = 1
}

variable "backend_count" {
  description = "Number of back end zones"
  default     = 1
}
