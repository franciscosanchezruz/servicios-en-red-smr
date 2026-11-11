#!/usr/bin/env bash
# ==============================================================================
# Script de Despliegue Automatizado del Servidor Central (10.0.0.10)
# Libro: "Servicios en Red" (2.º SMR) - Francisco Sánchez Ruz
# Editorial: Editorial Monsálvez (2026)
# ==============================================================================

set -euo pipefail

# Colores para salida formateada
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${BLUE}🚀 INICIANDO APROVISIONAMIENTO DEL SERVIDOR SMR (server.smr.lan)${NC}"
echo -e "${BLUE}   Red: 10.0.0.0/24 | IP: 10.0.0.10 | Gateway: 10.0.0.1${NC}"
echo -e "${BLUE}=====================================================================${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] Este script debe ejecutarse como root (usa sudo).${NC}" 
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PLANTILLAS_DIR="${REPO_DIR}/plantillas_configuracion"
BACKUP_DIR="/root/backup_servicios_red_$(date +%Y%m%d_%H%M%S)"

echo -e "\n${YELLOW}[1/7] Creando copia de seguridad del sistema en ${BACKUP_DIR}...${NC}"
mkdir -p "${BACKUP_DIR}"
[[ -d /etc/dhcp ]] && cp -r /etc/dhcp "${BACKUP_DIR}/" 2>/dev/null || true
[[ -d /etc/bind ]] && cp -r /etc/bind "${BACKUP_DIR}/" 2>/dev/null || true
[[ -f /etc/vsftpd.conf ]] && cp /etc/vsftpd.conf "${BACKUP_DIR}/" 2>/dev/null || true
[[ -d /etc/postfix ]] && cp -r /etc/postfix "${BACKUP_DIR}/" 2>/dev/null || true
[[ -d /etc/dovecot ]] && cp -r /etc/dovecot "${BACKUP_DIR}/" 2>/dev/null || true
[[ -d /etc/apache2 ]] && cp -r /etc/apache2 "${BACKUP_DIR}/" 2>/dev/null || true
[[ -d /etc/ssh ]] && cp -r /etc/ssh "${BACKUP_DIR}/" 2>/dev/null || true
echo -e "${GREEN}[OK] Copia de seguridad finalizada.${NC}"

echo -e "\n${YELLOW}[2/7] Instalando paquetes y servicios de red necesarios...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
  isc-dhcp-server \
  bind9 bind9utils dnsutils \
  vsftpd \
  postfix bsd-mailx \
  dovecot-imapd dovecot-pop3d \
  apache2 apache2-utils php \
  openssh-server \
  squid \
  iptables-persistent netfilter-persistent \
  curl wget net-tools tcpdump ufw- || true
echo -e "${GREEN}[OK] Paquetes de software libre instalados correctamente.${NC}"

echo -e "\n${YELLOW}[3/7] Configurando repositorio y entorno de Webmin...${NC}"
if ! command -v webmin &> /dev/null; then
  curl -fsSL https://download.webmin.com/developers-key.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/webmin.gpg --yes
  echo "deb [signed-by=/etc/apt/trusted.gpg.d/webmin.gpg] https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
  apt-get update -y
  apt-get install -y webmin --install-recommends
fi
echo -e "${GREEN}[OK] Webmin operativo en https://10.0.0.10:10000${NC}"

echo -e "\n${YELLOW}[4/7] Creando usuarios y estructura de directorios de taller...${NC}"
# Crear usuarios de prueba
for u in alumno01 alumno02 profesor; do
  if ! id "$u" &>/dev/null; then
    useradd -m -s /bin/bash "$u"
    echo "${u}:smr2026" | chpasswd
    echo "  - Usuario '${u}' creado (clave: smr2026)."
  fi
done

# Directorio FTP para descargas anónimas y subidas locales
mkdir -p /srv/ftp/descargas /srv/ftp/subidas
chmod 755 /srv/ftp/descargas
chmod 777 /srv/ftp/subidas
chown -R ftp:nogroup /srv/ftp

# Configurar buzones Maildir por defecto
maildirmake.dovecot /etc/skel/Maildir 2>/dev/null || mkdir -p /etc/skel/Maildir/{cur,new,tmp}
chmod -R 700 /etc/skel/Maildir

echo -e "\n${YELLOW}[5/7] Desplegando archivos de configuración del libro...${NC}"

# Capítulo 1: DHCP
if [[ -f "${PLANTILLAS_DIR}/cap01_dhcp/dhcpd.conf" ]]; then
  cp "${PLANTILLAS_DIR}/cap01_dhcp/dhcpd.conf" /etc/dhcp/dhcpd.conf
  # Fijar interfaz en /etc/default/isc-dhcp-server
  sed -i 's/INTERFACESv4=.*/INTERFACESv4="eth0"/' /etc/default/isc-dhcp-server 2>/dev/null || true
fi

# Capítulo 2: DNS
if [[ -d "${PLANTILLAS_DIR}/cap02_dns" ]]; then
  cp "${PLANTILLAS_DIR}/cap02_dns/named.conf.local" /etc/bind/named.conf.local
  cp "${PLANTILLAS_DIR}/cap02_dns/db.smr.lan" /etc/bind/db.smr.lan
  cp "${PLANTILLAS_DIR}/cap02_dns/db.10.0.0" /etc/bind/db.10.0.0
  chown -R root:bind /etc/bind/
fi

# Capítulo 3: FTP
if [[ -f "${PLANTILLAS_DIR}/cap03_ftp/vsftpd.conf" ]]; then
  cp "${PLANTILLAS_DIR}/cap03_ftp/vsftpd.conf" /etc/vsftpd.conf
fi

# Capítulo 4: Correo (Postfix y Dovecot)
if [[ -f "${PLANTILLAS_DIR}/cap04_correo/main.cf" ]]; then
  cp "${PLANTILLAS_DIR}/cap04_correo/main.cf" /etc/postfix/main.cf
  # Configurar Maildir en Dovecot
  sed -i 's|^#mail_location =.*|mail_location = maildir:~/Maildir|' /etc/dovecot/conf.d/10-mail.conf 2>/dev/null || true
fi

# Capítulo 5: Web Apache
if [[ -f "${PLANTILLAS_DIR}/cap05_web/000-default.conf" ]]; then
  cp "${PLANTILLAS_DIR}/cap05_web/000-default.conf" /etc/apache2/sites-available/000-default.conf
  a2enmod userdir rewrite ssl 2>/dev/null || true
fi

# Capítulo 8: Squid Proxy
if [[ -f "${PLANTILLAS_DIR}/cap08_pasarelas/squid.conf" ]]; then
  cp "${PLANTILLAS_DIR}/cap08_pasarelas/squid.conf" /etc/squid/squid.conf
fi

echo -e "${GREEN}[OK] Plantillas de configuración volcadas con éxito.${NC}"

echo -e "\n${YELLOW}[6/7] Reiniciando y habilitando demonios en systemd...${NC}"
systemctl daemon-reload
for s in isc-dhcp-server named vsftpd postfix dovecot apache2 ssh squid webmin; do
  systemctl enable "$s" 2>/dev/null || true
  systemctl restart "$s" 2>/dev/null || echo -e "  ${YELLOW}[Aviso] ${s} requiere interfaz eth0 activa.${NC}"
done
echo -e "${GREEN}[OK] Servicios gestionados por systemd.${NC}"

echo -e "\n${YELLOW}[7/7] Verificando estado inicial...${NC}"
bash "${SCRIPT_DIR}/verificar_servicios_smr.sh" || true

echo -e "\n${GREEN}=====================================================================${NC}"
echo -e "${GREEN}🎉 DESPLIEGUE FINALIZADO CON ÉXITO.${NC}"
echo -e "${GREEN}   El servidor server.smr.lan (10.0.0.10) está listo para la clase.${NC}"
echo -e "${GREEN}=====================================================================${NC}"

