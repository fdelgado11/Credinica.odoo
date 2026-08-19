# Guía Completa de Instalación y Despliegue: Odoo 19 + NGINX Proxy Manager en AWS Lightsail

Esta guía paso a paso te enseñará cómo crear, configurar y desplegar la infraestructura completa de **Odoo 19**, **PostgreSQL 16** y **NGINX Proxy Manager (NPM)** en **AWS Lightsail**.

---

## 📁 1. Estructura del Proyecto

Asegúrate de tener la siguiente estructura en tu máquina local antes de subir los archivos:

```text
Credinica.odoo/
├── compose.yaml                      # Configuración de servicios Docker (Odoo, DB, NPM)
├── .env                              # Variables de entorno y contraseñas (No subir a Git público)
├── .env.example                      # Plantilla de variables
├── config/
│   └── odoo.conf                     # Configuración de Odoo (proxy_mode = True, admin_passwd, etc.)
├── addons/                           # Módulos personalizados (ej. Microfinance Management)
└── GUIA_INSTALACION_LIGHTSAIL_ODOO19.md  # Esta guía
```

---

## 🔒 2. Seguridad Previa: Configuración de Contraseñas

Antes de subir el proyecto a la instancia de Lightsail, edita los siguientes archivos en tu máquina local:

1. **[`.env`](file:///Users/mariajosealvarado/Documents/Credinica.odoo/.env)**:
   - Configura una contraseña segura para `POSTGRES_PASSWORD`.
   - Configura una contraseña maestra fuerte para `ODOO_MASTER_PASSWORD`.

2. **[`config/odoo.conf`](file:///Users/mariajosealvarado/Documents/Credinica.odoo/config/odoo.conf)**:
   - Asegúrate de que `admin_passwd` coincida con tu `ODOO_MASTER_PASSWORD`.
   - Asegúrate de que `db_password` coincida con tu `POSTGRES_PASSWORD`.

---

## ☁️ 3. Paso a Paso: Configuración de AWS Lightsail

### Paso 3.1: Crear la Instancia en AWS Lightsail
1. Ingresa a la consola de [AWS Lightsail](https://lightsail.aws.amazon.com/).
2. Haz clic en **Create instance** (Crear instancia).
3. **Ubicación de la instancia (Instance location)**: Selecciona la región más cercana a tus usuarios (ejemplo: *us-east-1 N. Virginia*).
4. **Plataforma (Platform)**: Selecciona **Linux/Unix**.
5. **Blueprint**: Selecciona **OS Only** (Solo sistema operativo) -> **Ubuntu 24.04 LTS** (o **Ubuntu 22.04 LTS**).
6. **Plan de la instancia (Instance plan)**:
   - **Recomendado para producción**: Plan de **$20/mes** (4 GB RAM, 2 vCPUs, 80 GB SSD, 4 TB Transferencia).
   - **Mínimo para pruebas**: Plan de **$10/mes** (2 GB RAM, 1 vCPU, 60 GB SSD).
7. **Identificar la instancia**: Asigna un nombre, por ejemplo: `odoo-credinica-lightsail`.
8. Haz clic en **Create instance**.

---

### Paso 3.2: Asignar una IP Estática (Static IP)
*Importante: Por defecto, la IP de Lightsail cambia cuando la instancia se reinicia. Asignar una IP Estática es vital para que tu dominio no pierda conexión.*

1. En el panel principal de Lightsail, ve a la pestaña **Networking** (Redes) en el menú superior o entra en la instancia y ve a **Networking**.
2. Haz clic en **Create static IP** (Crear IP estática).
3. Selecciona la instancia `odoo-credinica-lightsail` para adjuntarla.
4. Asigna un nombre a la IP estática (ej: `odoo-static-ip`).
5. Haz clic en **Create** (Crear).
6. **Anota la IP Estática generada** (ejemplo: `54.210.xx.xx`), ya que será la IP definitiva de tu servidor.

---

### Paso 3.3: Configurar el Firewall (Reglas de Red) en Lightsail

1. Ve a tu instancia en Lightsail -> Pestaña **Networking** (Redes).
2. En la sección **IPv4 Firewall**, añade las siguientes reglas haciendo clic en **+ Add rule**:

| Aplicación / Tipo | Protocolo | Puerto | Origen Recomentado | Propósito |
| :--- | :--- | :--- | :--- | :--- |
| **SSH** | TCP | `22` | Tu IP / Any (`0.0.0.0/0`) | Acceso a terminal SSH |
| **HTTP** | TCP | `80` | Custom / Any (`0.0.0.0/0`) | Tráfico Web y SSL Let's Encrypt |
| **HTTPS** | TCP | `443` | Custom / Any (`0.0.0.0/0`) | Tráfico Web Seguro SSL/TLS |
| **Custom** | TCP | `81` | Tu IP (por seguridad) | Panel NGINX Proxy Manager |

3. Haz clic en **Save** para aplicar los cambios de red.

---

## 🔑 4. Conexión SSH al Servidor Lightsail

### Obtener la Clave Privada SSH
1. En la consola de Lightsail (arriba a la derecha), ve a **Account** (Cuenta) -> **Account** -> Pestaña **SSH keys**.
2. En la sección **Default keys**, descarga la llave correspondiente a la región donde creaste tu instancia (ej: `LightsailDefaultKey-us-east-1.pem`).
3. Guarda el archivo `.pem` en tu máquina local en una carpeta segura (ejemplo: `~/.ssh/`).

### Conectarse por SSH desde la Terminal Local
Abre la terminal en tu máquina local (desde la carpeta de tu proyecto):

```bash
# 1. Asignar permisos correctos a la llave privada
chmod 400 ./Odoo-Credinica.pem

# 2. Conectarte a la instancia (el usuario por defecto en Ubuntu Lightsail es 'ubuntu')
ssh -i ./Odoo-Credinica.pem ubuntu@<TU_IP_ESTATICA_LIGHTSAIL>
```

---

## 🐳 5. Preparar el Servidor e Instalar Docker

Una vez dentro de la terminal SSH de la instancia en Lightsail:

```bash
# 1. Actualizar repositorios y paquetes del sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker mediante el script oficial
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Otorgar permisos al usuario 'ubuntu' para ejecutar Docker sin 'sudo'
sudo usermod -aG docker ubuntu
newgrp docker

# 4. Verificar instalacion de Docker y Docker Compose
docker --version
docker compose version

# 5. Crear el directorio donde vivirá el proyecto
mkdir -p ~/odoo-microfinanzas
```

---

## 📤 6. Subir el Proyecto desde tu Computadora Local a Lightsail

Abre **otra ventana de terminal en tu máquina local** (en la ruta de tu proyecto `/Users/mariajosealvarado/Documents/Credinica.odoo`) y ejecuta el siguiente comando para sincronizar los archivos:

```bash
# Desde la terminal de tu máquina local:
rsync -avz --exclude '.git' --exclude '.DS_Store' --exclude '*.pem' \
  -e "ssh -i ./Odoo-Credinica.pem" \
  ./ ubuntu@<TU_IP_ESTATICA_LIGHTSAIL>:~/odoo-microfinanzas/
```

---

## 🚀 7. Iniciar los Servicios con Docker Compose

De regreso en la **terminal SSH de tu servidor Lightsail**:

```bash
# Entrar a la carpeta del proyecto
cd ~/odoo-microfinanzas

# Desplegar todos los contenedores en segundo plano (-d)
docker compose up -d

# Verificar el estado de los contenedores
docker compose ps
```

Deberías ver 3 contenedores activos (`Up`):
- `npm-app` (NGINX Proxy Manager)
- `odoo-web` (Odoo 19)
- `odoo-db` (PostgreSQL 16)

---

## 🌐 8. Configurar Dominio, NGINX Proxy Manager y SSL (HTTPS)

### Paso 8.1: Apuntar tu Dominio a la IP Estática
1. Ingresa al panel de control de tu proveedor DNS (Cloudflare, AWS Route53, GoDaddy, Namecheap, etc.).
2. Crea un registro de tipo **A**:
   - **Nombre / Host**: `odoo` (o `@` si es el dominio principal).
   - **Valor / Target**: `<TU_IP_ESTATICA_LIGHTSAIL>` (ej: `54.210.xx.xx`).
   - **TTL**: Auto / 300 segundos.

---

### Paso 8.2: Configurar NGINX Proxy Manager (NPM)
1. En tu navegador web, ingresa a: `http://<TU_IP_ESTATICA_LIGHTSAIL>:81`
2. Inicia sesión con los datos por defecto de NPM:
   - **Email**: `admin@example.com`
   - **Password**: `changeme`
3. Actualiza inmediatamente el nombre del administrador, email y contraseña personal.
4. Ve al menú **Hosts** -> **Proxy Hosts** -> Clic en **Add Proxy Host**:
   - **Details (Detalles)**:
     - **Domain Names**: `odoo.tudominio.com` (o tu subdominio configurado).
     - **Scheme**: `http`
     - **Forward Hostname / IP**: `odoo-web` *(Nombre del servicio/contenedor Docker)*
     - **Forward Port**: `8069`
     - Activa:
       - [x] **Block Common Exploits**
       - [x] **Websockets Support** *(Esencial para notificaciones en vivo y chat en Odoo)*
   - **SSL**:
     - **SSL Certificate**: Selecciona **Request a new SSL Certificate**.
     - Activa:
       - [x] **Force SSL**
       - [x] **HTTP/2 Support**
     - Ingresa tu correo electrónico y acepta los Términos de Servicio de Let's Encrypt.
5. Presiona **Save**.

¡Tu sistema ya cuenta con certificado de seguridad SSL gratis y acceso mediante `https://odoo.tudominio.com`!

---

## 🏬 9. Crear la Base de Datos e Instalar Módulos en Odoo

1. Ingresa en tu navegador a `https://odoo.tudominio.com`.
2. Se te mostrará la pantalla de creación de Base de Datos de Odoo:
   - **Master Password**: Ingresa el valor de `ODOO_MASTER_PASSWORD` de tu `.env`.
   - **Database Name**: ej. `credinica_prod`.
   - **Email**: Correo del administrador general.
   - **Password**: Contraseña con la que el admin iniciará sesión en Odoo.
   - **Language**: `Spanish (Nicaragua)` o tu país.
   - **Country**: Nicaragua.
   - **Demo data**: **Desmarcado** (No incluir datos de prueba).
3. Haz clic en **Create Database**.
4. Una vez dentro de Odoo:
   - Ve a **Aplicaciones**.
   - Busca e instala **Contabilidad / Invoicing**.
   - Ve a **Ajustes** -> Desplázate hacia abajo y activa el **Modo Desarrollador**.
   - Regresa a **Aplicaciones** -> Presiona **Actualizar lista de aplicaciones** en la barra superior.
   - Busca el módulo personalizado (**Microfinance Management**) e instálalo.

---

## 🛠️ 10. Comandos Útiles de Mantenimiento

```bash
# Ver los logs en tiempo real de Odoo
docker compose logs -f odoo-web

# Ver los logs del Proxy Manager
docker compose logs -f npm-app

# Reiniciar Odoo tras hacer cambios en los módulos o config
docker compose restart odoo-web

# Hacer un backup rápido de la base de datos PostgreSQL
docker exec -t odoo-db pg_dump -U odoo_user postgres > backup_$(date +%Y%m%d_%H%M%S).sql

# Detener todos los contenedores
docker compose down
```
