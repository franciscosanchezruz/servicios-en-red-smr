# 🐳 Suite de Despliegue con Docker y Docker Compose
## Servicios en Red (2.º SMR) - Francisco Sánchez Ruz

Esta carpeta contiene las plantillas listas para producción y taller correspondientes a la **Tercera Vía didáctica** explicada en los Capítulos 1 al 6 del libro.

| Carpeta | Servicio Contenedorizado | Imagen de Referencia | Puertos / Modo |
| :--- | :--- | :--- | :--- |
| `cap01_dhcp/` | ISC-DHCP Server | `networkboot/dhcpd:latest` | `network_mode: host` (UDP 67) |
| `cap02_dns/` | BIND9 DNS Autoritative & Cache | `internetsystemsconsortium/bind9:9.18` | `53:53/udp`, `53:53/tcp` |
| `cap03_ftp/` | vsftpd Seguro con Modo Pasivo | `fauria/vsftpd:latest` | `20-21:20-21`, `40000-40050:40000-40050` |
| `cap04_correo/`| Postfix + Dovecot + Roundcube | `mailserver/docker-mailserver` + `roundcube` | `25, 587, 143, 993, 8080` |
| `cap05_web/` | Apache2 HTTP + PHP 8.2 | `php:8.2-apache` | `80:80`, `443:443` |
| `cap06_remoto/`| Pasarela Web HTML5 (Guacamole) | `guacamole/guacamole` + `guacd` | `8088:8080` (Tomcat) |

### Instrucciones Generales de Uso:
1. Accede a la carpeta del servicio: `cd cap01_dhcp` (o el capítulo deseado).
2. Asegúrate de que el servicio nativo está detenido para evitar colisiones de puertos (ej. `sudo systemctl stop isc-dhcp-server`).
3. Despliega el contenedor en segundo plano: `docker compose up -d`.
4. Inspecciona los registros en tiempo real: `docker compose logs -f`.
5. Detén y retira el contenedor: `docker compose down`.
