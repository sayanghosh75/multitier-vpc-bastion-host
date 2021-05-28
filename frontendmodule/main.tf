##############################################################################
# Frontend Module
#
# Sample module to deploy a 'frontend' subnet and security group  
# No NACL is defined. As no floating (public) IPs are defined # Security Group 
# configuration by itself is considered sufficient to protect access to the webserver.
# Public gateways are defined in the 'vpc' module. 
##############################################################################

# Create VPC address prefix for frontend subnets
resource "ibm_is_vpc_address_prefix" "frontend_subnet_prefix" {
  count = var.frontend_count
  name  = "${var.unique_id}-frontend-prefix-zone-${count.index + 1}"
  zone  = "${var.ibm_region}-${count.index % 3 + 1}"
  vpc   = var.ibm_is_vpc_id
  cidr  = var.frontend_cidr_blocks[count.index]
}

# Create frontend subnets in all zones
resource "ibm_is_subnet" "frontend_subnet" {
  count           = var.frontend_count
  name            = "${var.unique_id}-frontend-subnet-${count.index + 1}"
  vpc             = var.ibm_is_vpc_id
  zone            = "${var.ibm_region}-${count.index % 3 + 1}"
  ipv4_cidr_block = var.frontend_cidr_blocks[count.index]
  #network_acl     = ibm_is_network_acl.multizone_acl.id
  public_gateway = var.public_gateway_ids[count.index]
  resource_group = var.ibm_is_resource_group_id
  depends_on     = [ibm_is_vpc_address_prefix.frontend_subnet_prefix]
}

# Security group for frontend subnets and instances
resource "ibm_is_security_group" "frontend" {
  name           = "${var.unique_id}-frontend-sg"
  vpc            = var.ibm_is_vpc_id
  resource_group = var.ibm_is_resource_group_id
}

# Define security group rules that we want to apply for frontend subnets
locals {
  sg_keys = ["direction", "remote", "type", "port_min", "port_max"]

  sg_rules = [
    ["outbound", var.app_backend_sg_id, "tcp", 27017, 27017],
    ["inbound", var.bastion_remote_sg_id, "tcp", 22, 22],
    ["outbound", "161.26.0.0/24", "tcp", 443, 443],
    ["outbound", "161.26.0.0/24", "tcp", 80, 80],
    ["outbound", "161.26.0.0/24", "udp", 53, 53],

    ["outbound", var.pub_repo_egress_cidr, "tcp", 80, 80],
    ["outbound", var.pub_repo_egress_cidr, "tcp", 443, 443],
    ["inbound", "0.0.0.0/0", "tcp", 80, 80]
  ]

  sg_mappedrules = [
    for entry in local.sg_rules :
    merge(zipmap(local.sg_keys, entry))
  ]
}

# Iteratively create security group rules for backend subnets and instances
resource "ibm_is_security_group_rule" "frontend_access" {
  count     = length(local.sg_mappedrules)
  group     = ibm_is_security_group.frontend.id
  direction = (local.sg_mappedrules[count.index]).direction
  remote    = (local.sg_mappedrules[count.index]).remote
  dynamic "tcp" {
    for_each = local.sg_mappedrules[count.index].type == "tcp" ? [
      {
        port_max = local.sg_mappedrules[count.index].port_max
        port_min = local.sg_mappedrules[count.index].port_min
      }
    ] : []
    content {
      port_max = tcp.value.port_max
      port_min = tcp.value.port_min

    }
  }
  dynamic "udp" {
    for_each = local.sg_mappedrules[count.index].type == "udp" ? [
      {
        port_max = local.sg_mappedrules[count.index].port_max
        port_min = local.sg_mappedrules[count.index].port_min
      }
    ] : []
    content {
      port_max = udp.value.port_max
      port_min = udp.value.port_min
    }
  }
  dynamic "icmp" {
    for_each = local.sg_mappedrules[count.index].type == "icmp" ? [
      {
        type = local.sg_mappedrules[count.index].port_max
        code = local.sg_mappedrules[count.index].port_min
      }
    ] : []
    content {
      type = icmp.value.type
      code = icmp.value.code
    }
  }
}
