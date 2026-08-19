output "static_ip_address" {
  description = "Dirección IP estática asignada"
  value       = aws_lightsail_static_ip.this.ip_address
}
