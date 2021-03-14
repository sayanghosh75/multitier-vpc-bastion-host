##############################################################################
# Backend subnet module input variables
##############################################################################

# Unique string added to the front of all created resource names
variable "unique_id" {
} 

# Create resources in this vpc id
variable "ibm_is_vpc_id" {
}

# Create resources in this resource group id
variable "ibm_is_resource_group_id" {
}

variable "ibm_region" {
  description = "IBM Cloud region where all resources will be deployed"
  default     = "au-syd"
}

# Backend CIDR blocks for each zone
variable "backend_cidr_blocks" {
}

variable "backend_count" {
  description = "Number of back end zones"
  default     = 1
}

# Public gateways to be attached to backend subnets
variable "public_gateway_ids" {
}

# Frontend SG requiring access to backend security group
variable "app_frontend_sg_id" {
}

# Bastion SG requiring access to backend security group
variable "bastion_remote_sg_id" {
}

# Bastion subnet CIDR requiring access to backend subnets - Not sure this is needed if we instead allow bastion security group
variable "bastion_subnet_CIDR" {
}

# Allowable CIDRs of public repos from which Ansible can deploy code
variable "pub_repo_egress_cidr" {
}

