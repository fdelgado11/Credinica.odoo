#!/bin/bash
# =====================================================================
# Script de Aprovisionamiento y Optimización para VPS Ubuntu en AWS Lightsail
# =====================================================================
set -e

echo "[1/5] Actualizando repositorios y paquetes del sistema..."
apt-get update && apt-get upgrade -y
apt-get install -y curl git apt-transport-https ca-certificates gnupg htop ufw net-tools

echo "[2/5] Configurando archivo SWAP de 4GB para evitar congelamientos por OOM..."
if [ ! -f /swapfile ]; then
    fallocate -l 4G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=4096
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "SWAP de 4GB activado con éxito."
else
    echo "El archivo SWAP ya existe."
fi

echo "[3/5] Aplicando optimizaciones de Kernel (sysctl) para gestión de memoria..."
cat <<'EOF' > /etc/sysctl.d/99-odoo-vps.conf
# Reducir agresividad de intercambio a Swap (priorizar uso de RAM física)
vm.swappiness = 10
vm.vfs_cache_pressure = 50
# Mejorar rendimiento de conexiones de red y sockets
net.core.somaxconn = 2048
net.ipv4.tcp_max_syn_backlog = 2048
EOF
sysctl --system > /dev/null

echo "[4/5] Instalando Docker y Docker Compose..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    usermod -aG docker ubuntu
    echo "Docker instalado correctamente."
else
    echo "Docker ya se encuentra instalado."
fi

echo "[5/5] Creando directorio de trabajo para Odoo..."
mkdir -p /home/ubuntu/odoo-microfinanzas
chown -R ubuntu:ubuntu /home/ubuntu/odoo-microfinanzas

echo "====================================================================="
echo "  VPS Aprovisionada y Optimizada con Éxito para Odoo 19"
echo "====================================================================="
