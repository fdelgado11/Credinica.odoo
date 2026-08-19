output "fqdn" {
  description = "Nombre de dominio completo (FQDN) creado"
  value       = aws_route53_record.subdomain.fqdn
}
