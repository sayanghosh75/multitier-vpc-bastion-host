
output security_group_id {
  value = ibm_is_security_group.frontend.id
}

output "frontend_subnet_ids" {
  value = ibm_is_subnet.frontend_subnet.*.id
}
