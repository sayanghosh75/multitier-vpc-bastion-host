##############################################################################
# Bastion Module
#
# Sample module to deploy a 'bastion' subnet and security group  
# No NACL is defined. 
##############################################################################

##############################################################################
# This file creates the Bastion host, subnet and security group. NACL and
# Security Group rules are created in nacl.tf and sg_rules.tf respectively.  
#
# All resources required to configure secure SSH access via a bastion host to 
# VSIs in a VPC are contained within this module. The module can be used with 
# the associated VPC module or used to add bastion host functionality to 
# other VPC configurations  
##############################################################################

# Create floating IP address in each zone
resource "ibm_is_floating_ip" "bastion" {
  count  = var.bastion_count
  name   = "${var.unique_id}-float-bastion-ip-${count.index + 1}"
  zone   = "${var.ibm_region}-${count.index % 3 + 1}"
}

# Create VPC address prefix for bastion subnets
resource "ibm_is_vpc_address_prefix" "bast_subnet_prefix" {
  count = var.bastion_count
  name  = "${var.unique_id}-bastion-prefix-zone-${count.index + 1}"
  zone  = "${var.ibm_region}-${count.index % 3 + 1}"
  vpc   = var.ibm_is_vpc_id
  cidr  = var.bastion_cidr_blocks[count.index]
}

# Create bastion subnets in requested number of zones
resource "ibm_is_subnet" "bastion_subnet" {
  count           = var.bastion_count
  name            = "${var.unique_id}-bastion-subnet-${count.index + 1}"
  vpc             = var.ibm_is_vpc_id
  zone            = "${var.ibm_region}-${count.index % 3 + 1}"
  ipv4_cidr_block = ibm_is_vpc_address_prefix.bast_subnet_prefix.*.cidr[count.index]
  resource_group  = var.ibm_is_resource_group_id
  network_acl     = ibm_is_network_acl.bastion_acl.id
  depends_on      = [ibm_is_vpc_address_prefix.bast_subnet_prefix]
}
