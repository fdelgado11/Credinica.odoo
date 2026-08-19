output "key_pair_name" {
  description = "Nombre del par de claves creado"
  value       = aws_lightsail_key_pair.this.name
}

output "private_key_pem" {
  description = "Contenido de la clave privada PEM"
  value       = aws_lightsail_key_pair.this.private_key
  sensitive   = true
}
