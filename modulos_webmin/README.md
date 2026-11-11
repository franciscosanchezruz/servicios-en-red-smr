# Módulos de Webmin para Servicios en Red (2.º SMR)

Este directorio contiene los paquetes y extensiones para el panel de administración web **Webmin**, desarrollados y adaptados para las prácticas del libro *Servicios en Red: Administración de Servidores Linux* (Francisco Sánchez Ruz • Editorial Monsálvez).

---

## 📦 Módulos Disponibles

### 1. `vsftpd.wbm.gz` (Módulo de Servidor FTP Seguro)
* **Descripción:** Añade a Webmin la interfaz gráfica completa de gestión del demonio `vsftpd` (acceso anónimo, enjaulado chroot de usuarios locales, seguridad TLS/FTPS y control del servicio vía `systemctl`).
* **Archivo descargable:** [`vsftpd.wbm.gz`](./vsftpd.wbm.gz)

---

## 🚀 Instrucciones de Instalación en Webmin

1. Descarga el archivo [`vsftpd.wbm.gz`](https://github.com/franciscosanchezruz/servicios-en-red-smr/raw/main/modulos_webmin/vsftpd.wbm.gz) a tu equipo anfitrión o cliente.
2. Inicia sesión en Webmin como administrador (`https://10.0.0.10:10000`).
3. En el menú lateral, dirígete a:  
   **Configuración de Webmin (*Webmin Configuration*) → Módulos de Webmin (*Webmin Modules*)**.
4. En la pestaña **Instalar módulo (*Install Module*)**:
   * Marca la opción **Desde archivo subido (*From uploaded file*)**.
   * Haz clic en **Examinar (*Browse*)** y selecciona `vsftpd.wbm.gz`.
5. Pulsa el botón verde **Instalar módulo (*Install Module*)**.
6. Una vez finalizada la instalación, refresca la página: el módulo estará disponible en la sección **Servidores (*Servers*) → Servidor FTP (vsftpd)**.

