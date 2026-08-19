variable "instance_name" {
  description = "Nombre de la instancia de Lightsail"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidad (ej: us-east-1a)"
  type        = string
}

variable "blueprint_id" {
  description = "Blueprint del SO (ej: ubuntu_24_04)"
  type        = string
}

variable "bundle_id" {
  description = "Plan de hardware (ej: medium_2_0)"
  type        = string
}

variable "key_pair_name" {
  description = "Nombre de la clave SSH asignada"
  type        = string
}

variable "user_data_script" {
  description = "Script bash de inicialización"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Etiquetas para el recurso"
  type        = map(string)
  default     = {}
}
