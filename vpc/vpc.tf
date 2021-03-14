##############################################################################
# This file creates the VPC, Zones, subnets, acls and public gateway for the 
# example VPC. It is not intended to be a full working application 
# environment. 
#
# Separately setup up any required load balancers, listeners, pools and members
##############################################################################

##############################################################################
# Create a VPC
##############################################################################
data "ibm_resource_group" "all_rg" {
  name = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name                      = var.unique_id
  resource_group            = data.ibm_resource_group.all_rg.id
  address_prefix_management = "manual"
}

##############################################################################






##############################################################################
# Prefixes and subnets for each zone
##############################################################################




##############################################################################


# Increase count to create gateways in all zones
resource "ibm_is_public_gateway" "repo_gateway" {
  count = var.frontend_count
  name  = "${var.unique_id}-public-gw-${count.index + 1}"
  vpc   = ibm_is_vpc.vpc.id
  zone  = "${var.ibm_region}-${count.index % 3 + 1}"

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}




