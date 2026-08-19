output "instance_name" {
  description = "Nombre de la instancia de Lightsail creada"
  value       = aws_lightsail_instance.this.name
}

output "arn" {
  description = "ARN de la instancia"
  value       = aws_lightsail_instance.this.arn
}
