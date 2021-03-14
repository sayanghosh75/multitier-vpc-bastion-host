
output security_group_id {
  value = ibm_is_security_group.backend.id
}

output "backend_subnet_ids" {
  value = ibm_is_subnet.backend_subnet.*.id
}
