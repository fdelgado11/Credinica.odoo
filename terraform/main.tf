terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Crear el Key Pair en AWS Lightsail
resource "aws_lightsail_key_pair" "odoo_key" {
  name = "${var.project_name}-key"
}

# 2. Crear la Instancia AWS Lightsail (Ubuntu 24.04)
resource "aws_lightsail_instance" "odoo_instance" {
  name              = var.project_name
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  key_pair_name     = aws_lightsail_key_pair.odoo_key.name

  user_data = file("${path.module}/scripts/user_data.sh")

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# 3. Crear IP Estática
resource "aws_lightsail_static_ip" "odoo_static_ip" {
  name = "${var.project_name}-static-ip"
}

# 4. Asociar IP Estática a la Instancia
resource "aws_lightsail_static_ip_attachment" "odoo_static_ip_attach" {
  static_ip_name = aws_lightsail_static_ip.odoo_static_ip.name
  instance_name  = aws_lightsail_instance.odoo_instance.name
}

# 5. Configurar el Firewall (Reglas de Puertos)
resource "aws_lightsail_instance_public_ports" "odoo_firewall" {
  instance_name = aws_lightsail_instance.odoo_instance.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    protocol  = "tcp"
    from_port = 81
    to_port   = 81
    cidrs     = ["0.0.0.0/0"]
  }
}
