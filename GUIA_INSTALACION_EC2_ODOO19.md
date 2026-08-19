# Guía Completa de Instalación y Despliegue: Odoo 19 + NGINX Proxy Manager en AWS EC2

Esta guía contiene las instrucciones paso a paso para desplegar **Odoo 19**, **PostgreSQL 16** y **NGINX Proxy Manager (NPM)** en producción en una instancia EC2 de AWS para la gestión de microfinanzas y contabilidad.

---

## 📁 Estructura del Proyecto Creada

```text
Credinica.odoo/
├── compose.yaml          # Archivo Docker Compose unificado (Odoo 19, Postgres 16, NPM)
├── .env                  # Variables de entorno y contraseñas de producción
├── .env.example          # Plantilla de ejemplo de variables de entorno
├── .gitignore            # Archivos excluidos de Git por seguridad
├── config/
│   └── odoo.conf         # Configuración oficial de Odoo (proxy_mode, admin_passwd)
├── addons/
│   └── README.md         # Instrucciones para el módulo de Microfinance Management
└── GUIA_INSTALACION_EC2_ODOO19.md  # Esta guía
```

---

## 🔒 1. Cambio Obligatorio de Contraseñas (Antes de Subir al Servidor)

Edita el archivo `.env` y el archivo `config/odoo.conf` reemplazando las contraseñas de ejemplo por contraseñas seguras y alfanuméricas:

1. En [`.env`](file:///Users/mariajosealvarado/Documents/Credinica.odoo/.env):
   - `POSTGRES_PASSWORD`: Pon una contraseña fuerte para la base de datos PostgreSQL.
   - `ODOO_MASTER_PASSWORD`: Pon una contraseña fuerte para administrar Odoo.

2. En [`config/odoo.conf`](file:///Users/mariajosealvarado/Documents/Credinica.odoo/config/odoo.conf):
   - Asegúrate de que `admin_passwd` sea igual al `ODOO_MASTER_PASSWORD`.
   - Asegúrate de que `db_password` sea igual a `POSTGRES_PASSWORD`.

---

## ☁️ 2. Paso a Paso: Instalación en AWS EC2

### Paso 2.1: Lanzar Instancia EC2 en AWS
1. Ve a la consola de AWS -> **EC2** -> **Launch Instance**.
2. **Sistema Operativo**: `Ubuntu 24.04 LTS` o `Ubuntu 22.04 LTS`.
3. **Tipo de Instancia**: `t3.medium` (Recomendado: 2 vCPU, 4GB RAM) o superior.
4. **Almacenamiento**: Mínimo `30 GB` en disco SSD `gp3`.
5. **Security Group (Grupo de Seguridad)**:
   - Configura las siguientes reglas de entrada (Inbound Rules):

| Tipo de Tráfico | Puerto | Origen | Descripción |
| :--- | :--- | :--- | :--- |
| **SSH** | `22` | Mi IP | Acceso a la terminal por SSH |
| **HTTP** | `80` | `0.0.0.0/0` | Tráfico Web HTTP y Validación de SSL |
| **HTTPS** | `443` | `0.0.0.0/0` | Tráfico Web Seguro SSL/TLS |
| **Custom TCP** | `81` | Mi IP | Panel Administrativo de NGINX Proxy Manager |

---

### Paso 2.2: Preparar el Servidor AWS EC2 por SSH

Conéctate a tu servidor mediante SSH:
```bash
ssh -i tu-clave.pem ubuntu@<IP_PUBLICA_EC2>
```

Una vez dentro del servidor, ejecuta los siguientes comandos:

```bash
# 1. Actualizar paquetes del sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Permitir ejecutar Docker sin usar 'sudo'
sudo usermod -aG docker $USER
newgrp docker

# 4. Crear carpeta del proyecto
mkdir -p ~/odoo-microfinanzas
```

---

### Paso 2.3: Subir los Archivos del Proyecto a la EC2

Puedes subir la carpeta completa de tu proyecto desde tu máquina local a la instancia EC2 utilizando `scp` o `rsync`:

```bash
# Ejecutar desde tu computadora local:
rsync -avz -e "ssh -i /ruta/a/tu-clave.pem" /Users/mariajosealvarado/Documents/Credinica.odoo/ ubuntu@<IP_PUBLICA_EC2>:~/odoo-microfinanzas/
```

*Nota: Asegúrate de haber descomprimido tu módulo de **Microfinance Management** dentro de la carpeta `addons/` antes o después de sincronizar los archivos.*

---

### Paso 2.4: Lanzar los Servicios con Docker Compose

En la terminal de la instancia EC2:

```bash
cd ~/odoo-microfinanzas

# Iniciar los contenedores en segundo plano
docker compose up -d

# Verificar que los 3 contenedores (npm-app, odoo-web, odoo-db) estén 'Up'
docker compose ps
```

---

### Paso 2.5: Configuración de NGINX Proxy Manager (NPM) y SSL

1. Apunta tu dominio o subdominio (ejemplo: `odoo.micredinica.com`) a la **IP Pública** de la instancia EC2 en el panel de tu proveedor DNS (Cloudflare, Route53, GoDaddy, etc.).
2. Abre en tu navegador: `http://<IP_PUBLICA_EC2>:81`
3. Ingresa con las credenciales por defecto de NPM:
   - **Email**: `admin@example.com`
   - **Password**: `changeme`
4. Cambia inmediatamente el email y la contraseña según lo solicite NPM.
5. Ve al menú **Hosts** -> **Proxy Hosts** -> Clic en **Add Proxy Host**:
   - **Domain Names**: `odoo.micredinica.com` (Tu dominio registrado)
   - **Scheme**: `http`
   - **Forward Hostname / IP**: `odoo-web` *(Nombre del contenedor en docker)*
   - **Forward Port**: `8069`
   - Activa las casillas:
     - [x] **Block Common Exploits**
     - [x] **Websockets Support** (Indispensable para chat/notificaciones en vivo de Odoo)
6. Pestaña **SSL**:
   - SSL Certificate: Selecciona **Request a new SSL Certificate**.
   - Activa:
     - [x] **Force SSL**
     - [x] **HTTP/2 Support**
   - Acepta los términos de Let's Encrypt e ingresa tu email.
   - Presiona **Save**.

¡Listo! Tu sitio ya estará disponible de forma segura bajo HTTPS en `https://odoo.micredinica.com`.

---

## 📑 3. Creación de Base de Datos e Instalación de Módulos

1. Abre tu navegador y navega a `https://tu-dominio.com`.
2. Completa los datos iniciales de Odoo:
   - **Master Password**: Ingresa el `ODOO_MASTER_PASSWORD` definido en tu `.env`.
   - **Database Name**: ej: `credinica_db`
   - **Email**: Correo del administrador de la empresa.
   - **Password**: Contraseña de inicio de sesión para el admin en Odoo.
   - **Language**: Spanish / Español.
   - **Country**: Nicaragua / Tu país.
   - **Demo Data**: UNCHECKED / NO MARCAR (para entorno de producción).
3. Una vez dentro de Odoo:
   - Ve a **Aplicaciones**.
   - Busca e instala **Contabilidad** (Invoicing / Accounting).
   - Ve a **Ajustes** -> Activa el **Modo Desarrollador**.
   - Regresa a **Aplicaciones** -> Presiona **Actualizar Lista de Aplicaciones**.
   - Busca el módulo **Microfinance Management** e instálalo.

---

## 🛠️ Comandos de Mantenimiento Útiles

```bash
# Ver logs en tiempo real de Odoo
docker compose logs -f odoo-web

# Reiniciar Odoo tras agregar nuevos módulos a ./addons
docker compose restart odoo-web

# Detener los servicios
docker compose down

# Hacer respaldo manual de la base de datos de PostgreSQL
docker exec -t odoo-db pg_dump -U odoo_user postgres > respaldo_$(date +%Y%m%m).sql
```
