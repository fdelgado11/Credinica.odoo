variable "route53_zone_name" {
  description = "Nombre de la zona hospedada principal en Route 53 (ej: grupocuadel.org)"
  type        = string
}

variable "subdomain_name" {
  description = "Nombre del subdominio completo (ej: credinica.grupocuadel.org)"
  type        = string
}

variable "target_ip" {
  description = "Dirección IP estática de Lightsail"
  type        = string
}
