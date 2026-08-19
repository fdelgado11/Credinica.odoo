variable "static_ip_name" {
  description = "Nombre para la IP estática"
  type        = string
}

variable "instance_name" {
  description = "Nombre de la instancia a la cual asociar la IP y las reglas de red"
  type        = string
}

variable "allowed_ports" {
  description = "Lista de reglas de puertos de red a permitir"
  type = list(object({
    protocol  = string
    from_port = number
    to_port   = number
    cidrs     = list(string)
  }))
  default = [
    { protocol = "tcp", from_port = 22, to_port = 22, cidrs = ["0.0.0.0/0"] },
    { protocol = "tcp", from_port = 80, to_port = 80, cidrs = ["0.0.0.0/0"] },
    { protocol = "tcp", from_port = 443, to_port = 443, cidrs = ["0.0.0.0/0"] },
    { protocol = "tcp", from_port = 81, to_port = 81, cidrs = ["0.0.0.0/0"] }
  ]
}
