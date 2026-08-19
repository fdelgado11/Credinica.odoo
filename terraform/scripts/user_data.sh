#!/bin/bash
set -e

# 1. Actualización de paquetes del sistema
apt-get update && apt-get upgrade -y

# 2. Instalación de dependencias básicas
apt-get install -y curl git apt-transport-https ca-certificates gnupg

# 3. Instalación de Docker y Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 4. Otorgar permisos al usuario ubuntu para ejecutar Docker
usermod -aG docker ubuntu

# 5. Crear el directorio de trabajo del proyecto
mkdir -p /home/ubuntu/odoo-microfinanzas
chown -R ubuntu:ubuntu /home/ubuntu/odoo-microfinanzas

echo "Servidor Lightsail aprovisionado con éxito para Odoo 19" > /var/log/user-data-setup.log
