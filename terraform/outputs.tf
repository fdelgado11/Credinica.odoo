output "static_ip_address" {
  description = "IP Estática Pública asignada a la instancia de Lightsail"
  value       = module.network_and_firewall.static_ip_address
}

output "odoo_domain_url" {
  description = "URL principal para acceder a Odoo 19"
  value       = "https://${module.route53_dns.fqdn}"
}

output "npm_admin_url" {
  description = "URL de acceso al panel de NGINX Proxy Manager"
  value       = "http://${module.network_and_firewall.static_ip_address}:81"
}

output "ssh_command" {
  description = "Comando de conexión SSH sugerido"
  value       = "ssh -i ./odoo_private_key.pem ubuntu@${module.network_and_firewall.static_ip_address}"
}

output "private_key_pem" {
  description = "Clave privada SSH de la instancia en formato PEM"
  value       = module.ssh_key.private_key_pem
  sensitive   = true
}
