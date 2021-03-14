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

variable "bastion_count" {
  description = "Number of MZR zones bastions will be created in. First bastion is in Zone 1 "
  default     = 1
}

##############################################################################
# Network variables
##############################################################################

# variable "bastion_cidr" {
#   description = "CIDR for range of bastion zone subnets"
# }

variable "bastion_cidr_blocks" {
  description = "CIDR blocks for bastion zone subnets"

}

# All CIDR blocks of servers connectinhg to the bastion host
# To limit total number of rules in ACL, restrict number of source CIDRs to 4. For a total of 8 ACL rules 
variable "ssh_source_cidr_blocks" {
  description = "Public Source CIDRs"
  default     = []
}

# Remote subnets bastion will egress to (frontend, backend)
# To limit total number of rules in ACL to under 25, use single CIDR range across all zones per SG 
# CIDR per zone exceeds number of allowed ACL rules
variable "destination_cidr_blocks" {
  description = "CIDRs of destination private subnets in VPC"
  default     = []
}

# Remote security groups bastion will egress to (frontend, backend)
variable "destination_sgs" {
  description = "Destination Security Groups in VPC"
  default     = []
}

# Allow user to pass in additional rules e.g. icmp
variable "extrarules" {
  description = "Additional rules supplied by user"
  default = [
    #["allow", "0.0.0.0/0", "0.0.0.0/0", "inbound", "tcp", 1024, 65535, 22, 22],
    #["allow", "0.0.0.0/0", "0.0.0.0/0", "outbound", "tcp", 22, 22, 1024, 65535]
  ]
}

