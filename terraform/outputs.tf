output "static_ip_address" {
  description = "IP Estática Pública asignada a la instancia de Lightsail"
  value       = aws_lightsail_static_ip.odoo_static_ip.ip_address
}

output "private_key_pem" {
  description = "Clave privada SSH de la instancia en formato PEM"
  value       = aws_lightsail_key_pair.odoo_key.private_key
  sensitive   = true
}

output "ssh_command" {
  description = "Comando de conexión SSH sugerido"
  value       = "ssh -i ./odoo_private_key.pem ubuntu@${aws_lightsail_static_ip.odoo_static_ip.ip_address}"
}

output "npm_admin_url" {
  description = "URL de acceso al panel de NGINX Proxy Manager"
  value       = "http://${aws_lightsail_static_ip.odoo_static_ip.ip_address}:81"
}
