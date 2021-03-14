output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "public_gateway_ids" {
  value = ibm_is_public_gateway.repo_gateway.*.id
}


