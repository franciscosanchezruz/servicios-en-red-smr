#!/usr/bin/env bash
# ==============================================================================
# Suite de Auditoría y Verificación Forense de Servicios de Red (smr.lan)
# Libro: "Servicios en Red" (2.º SMR) - Francisco Sánchez Ruz
# Editorial: Editorial Monsálvez (2026)
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_TESTS=9
PASSED_TESTS=0

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  AUDITORÍA OFICIAL DE SERVICIOS EN RED (server.smr.lan - 10.0.0.10)  ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Función auxiliar de comprobación
check_service() {
  local name="$1"
  local port_type="$2"
  local port="$3"
  local desc="$4"

  if ss "-${port_type}lnp" | grep -q ":${port} "; then
    echo -e "  [${GREEN}PASS${NC}] ${name} (${port_type^^} ${port}) ........... ${GREEN}ACTIVO${NC} (${desc})"
    ((PASSED_TESTS++))
  else
    echo -e "  [${RED}FAIL${NC}] ${name} (${port_type^^} ${port}) ........... ${RED}INACTIVO${NC} (${desc})"
  fi
}

# 1. DHCP (UDP 67)
check_service "DHCP isc-dhcp-server" "u" "67" "Pool dinámico y leases listos"

# 2. DNS BIND9 (UDP 53)
if dig @127.0.0.1 server.smr.lan +short +timeout=2 &>/dev/null; then
  echo -e "  [${GREEN}PASS${NC}] DNS BIND9 (UDP/TCP 53) ........... ${GREEN}ACTIVO${NC} (Resolución smr.lan correcta)"
  ((PASSED_TESTS++))
else
  check_service "DNS BIND9 (named)" "u" "53" "Servidor de nombres escuchando"
fi

# 3. FTP vsftpd (TCP 21)
check_service "FTP Servidor vsftpd" "t" "21" "Control FTP y transferencias"

# 4. SMTP Postfix (TCP 25)
check_service "SMTP Postfix (MTA)" "t" "25" "Recepción y retransmisión de correo"

# 5. IMAP Dovecot (TCP 143)
check_service "IMAP Dovecot (MDA)" "t" "143" "Acceso a buzones de alumnos Maildir"

# 6. Web Apache (TCP 80)
if curl -s -I http://127.0.0.1 | grep -q "200 OK\|301 Moved\|Apache"; then
  echo -e "  [${GREEN}PASS${NC}] Web Apache2 (TCP 80) ............. ${GREEN}ACTIVO${NC} (HTTP 200 OK respondiendo)"
  ((PASSED_TESTS++))
else
  check_service "Web Apache2 Server" "t" "80" "Alojamiento web y userdir"
fi

# 7. SSH Remoto (TCP 22)
check_service "SSH OpenSSH Server" "t" "22" "Administración remota cifrada"

# 8. Webmin GUI (TCP 10000)
check_service "Webmin HTTPS Console" "t" "10000" "Interfaz web de administración"

# 9. Enrutamiento / Gateway
if sysctl net.ipv4.ip_forward | grep -q "1"; then
  echo -e "  [${GREEN}PASS${NC}] Enrutamiento IP Kernel ............ ${GREEN}ACTIVO${NC} (net.ipv4.ip_forward = 1)"
  ((PASSED_TESTS++))
else
  echo -e "  [${YELLOW}INFO${NC}] Enrutamiento IP Kernel ............ ${YELLOW}MODO SERVIDOR HOST${NC} (Típico si no es Router)"
  ((PASSED_TESTS++))
fi

echo -e "${BLUE}======================================================================${NC}"
if [[ $PASSED_TESTS -ge 8 ]]; then
  echo -e "${GREEN}RESULTADO: ${PASSED_TESTS} / ${TOTAL_TESTS} COMPROBACIONES SUPERADAS (EXCELENTE ESTADO)${NC}"
else
  echo -e "${RED}RESULTADO: ${PASSED_TESTS} / ${TOTAL_TESTS} COMPROBACIONES SUPERADAS (REVISA LOS SERVICIOS MARCADOS)${NC}"
fi
echo -e "${BLUE}======================================================================${NC}"

