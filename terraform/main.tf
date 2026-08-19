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

# ---------------------------------------------------------------------
# Módulo 1: Gestión de la Clave SSH
# ---------------------------------------------------------------------
module "ssh_key" {
  source   = "./modules/ssh_key"
  key_name = "${var.project_name}-key"
}

# ---------------------------------------------------------------------
# Módulo 2: Instancia Compute Lightsail
# ---------------------------------------------------------------------
module "compute_instance" {
  source            = "./modules/compute_instance"
  instance_name     = var.project_name
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  key_pair_name     = module.ssh_key.key_pair_name
  user_data_script  = file("${path.module}/../scripts/setup_vps.sh")

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ---------------------------------------------------------------------
# Módulo 3: Redes, IP Estática y Firewall
# ---------------------------------------------------------------------
module "network_and_firewall" {
  source         = "./modules/network_and_firewall"
  static_ip_name = "${var.project_name}-static-ip"
  instance_name  = module.compute_instance.instance_name
}
