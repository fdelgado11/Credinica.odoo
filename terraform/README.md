# Despliegue Automatizado con Terraform en AWS Lightsail

Este directorio contiene la infraestructura como código (IaC) para aprovisionar automáticamente la instancia de **AWS Lightsail**, la **IP Estática**, las **reglas de Firewall** y la **instalación automática de Docker**.

---

## 📋 Requisitos Previos

1. Tener instalado [Terraform](https://developer.hashicorp.com/terraform/downloads) o [OpenTofu](https://opentofu.org/).
2. Tener configurado el CLI de AWS con credenciales válidas:
   ```bash
   aws configure
   ```

---

## 🚀 Pasos para Aprovisionar la Infraestructura

```bash
# 1. Entrar a la carpeta de Terraform
cd terraform

# 2. Inicializar los proveedores de Terraform
terraform init

# 3. Ver la vista previa del plan de ejecución
terraform plan

# 4. Crear toda la infraestructura en AWS Lightsail
terraform apply -auto-approve
```

---

## 📤 Obtener la Clave SSH Generada

Una vez finalizado el `terraform apply`, puedes extraer la clave SSH generada automáticamente:

```bash
terraform output -raw private_key_pem > ../odoo_private_key.pem
chmod 400 ../odoo_private_key.pem
```

Para conectarte:
```bash
ssh -i ../odoo_private_key.pem ubuntu@$(terraform output -raw static_ip_address)
```

---

## 🧹 Destruir la Infraestructura (Si deseas eliminar el servidor)

```bash
terraform destroy -auto-approve
```
