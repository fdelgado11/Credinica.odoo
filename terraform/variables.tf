variable "aws_region" {
  description = "Región de AWS donde se creará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto y de los recursos"
  type        = string
  default     = "odoo-credinica"
}

variable "environment" {
  description = "Entorno de despliegue (production, staging, dev)"
  type        = string
  default     = "production"
}

variable "blueprint_id" {
  description = "Identificador del sistema operativo (Blueprint) en Lightsail"
  type        = string
  default     = "ubuntu_24_04"
}

variable "bundle_id" {
  description = "Plan de la instancia en Lightsail (ej: medium_2_0 = 4 GB RAM, 2 vCPUs)"
  type        = string
  default     = "medium_2_0"
}

variable "route53_zone_name" {
  description = "Nombre de la Zona Hospedada existente en AWS Route 53"
  type        = string
  default     = "grupocuadel.org"
}

variable "subdomain_name" {
  description = "Subdominio completo para acceder a Odoo 19"
  type        = string
  default     = "credinica.grupocuadel.org"
}
