##############################################################################
# Bastion subnet module input variables
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

# Frontend CIDR blocks for each zone
variable "frontend_cidr_blocks" {
}

variable "frontend_count" {
  description = "Number of front end zones"
  default     = 1
}

# Public gateways to be attached to backend subnets
variable "public_gateway_ids" {
}

# Bastion SG requiring access to frontend security group
variable "bastion_remote_sg_id" {
}

# Bastion subnet CIDR requiring access to frontend subnets - not sure this is needed
variable "bastion_subnet_CIDR" {
}

variable "app_backend_sg_id" {
}

# Allowable CIDRs of public repos from which Ansible can deploy code
variable "pub_repo_egress_cidr" {
}
