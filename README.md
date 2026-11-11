# 🌐 Servicios en Red (2.º SMR) — Repositorio Oficial de Recursos y Automatización

[![Licencia](https://img.shields.io/badge/Licencia-GPLv3%2FMIT-blue.svg)](LICENSE)
[![Ciclo](https://img.shields.io/badge/Ciclo-FP%20Grado%20Medio%20SMR-green.svg)](https://www.juntadeandalucia.es/educacion/portals/web/formacion-profesional-andaluza)
[![Módulo](https://img.shields.io/badge/M%C3%B3dulo-0228%20Servicios%20en%20Red-orange.svg)](#)
[![Editorial](https://img.shields.io/badge/Editorial-Mons%C3%A1lvez%20(2026)-purple.svg)](#)
[![ISBN](https://img.shields.io/badge/ISBN-978--84--123456--7--8-lightgrey.svg)](#)

Este repositorio contiene los recursos digitales, plantillas de configuración del sistema (`/etc/`) y scripts de aprovisionamiento automatizado que acompañan al libro:

> **«Servicios en Red: Administración Práctica y Configuración Dual en Sistemas Linux (Debian/Ubuntu) y Entorno Webmin»**  
> **Autor:** Francisco Sánchez Ruz (Profesor de Enseñanza Secundaria y Formación Profesional &bull; Especialidad de Informática).  
> **Publicación:** Editorial Monsálvez (1.ª Edición, 2026).  
> **Depósito Legal:** En trámite por Editorial Monsálvez &bull; **ISBN:** En trámite por Editorial Monsálvez.

---

## 🧭 Estructura del Repositorio

```text
.
├── README.md                      # Documentación general y guía de inicio rápido
├── Vagrantfile                    # Despliegue automatizado de laboratorio con 3 VMs (VirtualBox)
├── scripts/
│   ├── desplegar_servidor_smr.sh  # Script de instalación y aprovisionamiento del Servidor 10.0.0.10
│   ├── configurar_cliente_smr.sh  # Script de configuración y comprobación de clientes DHCP/DNS
│   └── verificar_servicios_smr.sh # Suite de auditoría y diagnóstico automático en consola (PASS/FAIL)
├── modulos_webmin/                # Extensiones y módulos empaquetados para el panel Webmin
│   ├── README.md                  # Instrucciones de importación e instalación en Webmin
│   └── vsftpd.wbm.gz              # Módulo de administración para el servidor FTP seguro vsftpd
├── docker/                        # Suite de despliegue con Docker y Docker Compose
│   ├── README.md                  # Guía rápida de orquestación en contenedores
│   ├── cap01_dhcp/                # isc-dhcp-server en contenedor (network_mode: host)
│   ├── cap02_dns/                 # BIND9 autoritativo y caché en contenedor (puertos 53 udp/tcp)
│   ├── cap03_ftp/                 # vsftpd con rangos pasivos fijos (40000-40050) y PASV_ADDRESS
│   ├── cap04_correo/              # Pila de correo integral (Postfix + Dovecot + Roundcube Webmail)
│   ├── cap05_web/                 # Apache2 con PHP 8.2 y discriminación de VirtualHosts por volumen
│   └── cap06_remoto/              # Pasarela web universal HTML5 (Apache Guacamole + guacd)
└── plantillas_configuracion/
    ├── cap01_dhcp/                # isc-dhcp-server: dhcpd.conf con pools y reservas MAC
    ├── cap02_dns/                 # BIND 9: named.conf.local, db.smr.lan y db.10.0.0 (inversa)
    ├── cap03_ftp/                 # vsftpd: vsftpd.conf con chroot local y rangos pasivos TLS
    ├── cap04_correo/              # Postfix y Dovecot: main.cf y buzones Maildir
    ├── cap05_web/                 # Apache2: VirtualHosts HTTP/HTTPS y módulo userdir
    ├── cap06_remoto/              # OpenSSH: sshd_config securizado y banners de acceso
    ├── cap07_wifi/                # Configuración de interfaces y clientes inalámbricos WPA2/WPA3
    └── cap08_pasarelas/           # iptables: enmascaramiento NAT, reenvío y proxy caché Squid
```

---

## 🚀 Inicio Rápido: Despliegue del Laboratorio en 1 Minuto

Para levantar el laboratorio completo de aula con **VirtualBox** y **Vagrant**, asegúrate de tener instalado Vagrant y ejecuta:

```bash
# 1. Clonar el repositorio oficial
git clone https://github.com/franciscosanchezruz/servicios-en-red-smr.git
cd servicios-en-red-smr

# 2. Levantar el laboratorio completo (Servidor 10.0.0.10 + Router 10.0.0.1 + Cliente)
vagrant up
```

Vagrant creará tres máquinas virtuales enlazadas por una red interna aislada (`red_taller_smr`):
1. **`router-smr` (10.0.0.1 / WAN DHCP):** Actúa como pasarela, NAT e inspección de tráfico.
2. **`servidor-smr` (10.0.0.10):** Servidor central con Debian 12, Webmin y todos los demonios listos.
3. **`cliente-smr` (DHCP Dinámico):** Equipo de aula para verificar la asignación de parámetros.

Para acceder por SSH al servidor de prácticas:
```bash
vagrant ssh servidor-smr
```

Acceso a la interfaz web de administración Webmin desde tu equipo anfitrión:
* **URL:** `https://localhost:10000` (o `https://10.0.0.10:10000` en red interna)
* **Usuario:** `admin` | **Contraseña:** `smr2026`

---

## 🛠️ Despliegue Manual en Equipos Físicos o Máquinas Virtuales Existentes

Si ya dispones de una máquina con **Debian 12 Bookworm** o **Ubuntu Server 24.04**, puedes ejecutar el script maestro de aprovisionamiento como `root`:

```bash
sudo bash scripts/desplegar_servidor_smr.sh
```

El script se encargará automáticamente de:
1. Asignar la IP estática `10.0.0.10/24` en `eth0` y configurar `smr.lan`.
2. Añadir el repositorio oficial y clave GPG de **Webmin**.
3. Instalar los paquetes oficiales: `isc-dhcp-server`, `bind9`, `vsftpd`, `postfix`, `dovecot-imapd`, `dovecot-pop3d`, `apache2`, `openssh-server`, `squid`, `iptables-persistent`.
4. Crear una copia de seguridad en `/root/backup_servicios_red/` antes de aplicar cambios.
5. Volcar las plantillas preconfiguradas y arrancar los servicios mediante `systemctl`.

---

## 🧪 Suite de Verificación Automática (`verificar_servicios_smr.sh`)

Al finalizar cualquier práctica, el alumno o profesor puede ejecutar la suite de auditoría:

```bash
sudo bash scripts/verificar_servicios_smr.sh
```

El script ejecutará pruebas de diagnóstico en tiempo real sobre cada puerto y protocolo, generando un informe con código de colores:

```text
======================================================================
  AUDITORÍA OFICIAL DE SERVICIOS EN RED (smr.lan - 10.0.0.10)
======================================================================
[PASS] DHCP Server (UDP 67) ................... ACTIVO (daemon listening)
[PASS] DNS Resolver (UDP/TCP 53) .............. ACTIVO (dig server.smr.lan -> 10.0.0.10)
[PASS] FTP vsftpd (TCP 21) .................... ACTIVO (banner vsftpd 3.x)
[PASS] SMTP Postfix (TCP 25) .................. ACTIVO (ESMTP Postfix)
[PASS] IMAP Dovecot (TCP 143) ................. ACTIVO (Dovecot ready)
[PASS] Web Apache (TCP 80 / 443) .............. ACTIVO (HTTP 200 OK)
[PASS] SSH Remoto (TCP 22) .................... ACTIVO (OpenSSH Server)
[PASS] Webmin Admin GUI (TCP 10000) ........... ACTIVO (HTTPS Webmin listening)
[PASS] Enrutamiento IP Forward ................ ACTIVO (net.ipv4.ip_forward = 1)
======================================================================
RESULTADO: 9 / 9 SERVICIOS VERIFICADOS Y OPERATIVOS (100 % OK)
======================================================================
```

---

## 📄 Licencia y Reconocimiento

El código y las plantillas de configuración de este repositorio se distribuyen bajo licencia **GNU General Public License v3 (GPLv3)**. Los textos didácticos y las referencias curriculares están protegidos por derechos de autor pertenecientes a **Francisco Sánchez Ruz** y **Editorial Monsálvez**.

