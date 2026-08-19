# Carpeta de Módulos Extra de Odoo (`./addons`)

Coloca aquí los módulos de terceros descomprimidos que vayas a utilizar en tu instalación de Odoo.

## Instrucciones para el Módulo de Microfinance Management:

1. Descomprime el archivo zip del módulo de Microfinance Management.
2. Copia la carpeta del módulo descomprimida dentro de este directorio (`./addons/`).
   - Ejemplo de estructura:
     ```text
     addons/
     └── microfinance_management/
         ├── __manifest__.py
         ├── models/
         ├── views/
         └── ...
     ```
3. Reinicia Odoo si está en ejecución (`docker compose restart odoo-web`).
4. En Odoo:
   - Ve a **Ajustes** -> Activa el **Modo Desarrollador**.
   - Ve al menú **Aplicaciones** -> Haz clic en **Actualizar Lista de Aplicaciones**.
   - Busca "Microfinance" o el nombre del módulo e instálalo.
