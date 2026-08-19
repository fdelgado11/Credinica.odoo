output "static_ip_address" {
  description = "IP Estática Pública asignada a la instancia de Lightsail"
  value       = module.network_and_firewall.static_ip_address
}

output "private_key_pem" {
  description = "Clave privada SSH de la instancia en formato PEM"
  value       = module.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_command" {
  description = "Comando de conexión SSH sugerido"
  value       = "ssh -i ./odoo_private_key.pem ubuntu@${module.network_and_firewall.static_ip_address}"
}

output "npm_admin_url" {
  description = "URL de acceso al panel de NGINX Proxy Manager"
  value       = "http://${module.network_and_firewall.static_ip_address}:81"
}
