#!/usr/bin/env bash
# ==============================================================================
# Script de Configuración y Verificación del Cliente de Aula (cliente01.smr.lan)
# Libro: "Servicios en Red" (2.º SMR) - Francisco Sánchez Ruz
# Editorial: Editorial Monsálvez (2026)
# ==============================================================================

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${BLUE}💻 CONFIGURANDO CLIENTE DE AULA (cliente01.smr.lan)${NC}"
echo -e "${BLUE}=====================================================================${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] Este script debe ejecutarse como root (usa sudo).${NC}" 
   exit 1
fi

echo -e "\n[1/3] Liberando y solicitando nueva IP por DHCP al servidor 10.0.0.10..."
dhclient -r 2>/dev/null || true
dhclient -v eth0 2>/dev/null || dhclient -v enp0s3 2>/dev/null || true

echo -e "\n[2/3] Comprobando parámetros de red obtenidos:"
ip -4 addr show | grep -E "inet " | grep -v "127.0.0.1" || true
ip route show default || true

echo -e "\n[3/3] Ejecutando pruebas de conectividad y servicios:"
echo -n "  - Prueba de resolución DNS contra 10.0.0.10: "
if dig @10.0.0.10 server.smr.lan +short +timeout=2 | grep -q "10.0.0.10"; then
  echo -e "${GREEN}[OK] server.smr.lan -> 10.0.0.10${NC}"
else
  echo -e "${RED}[FALLO] No resuelve correctamente${NC}"
fi

echo -n "  - Prueba de descarga HTTP web: "
if curl -s -I http://server.smr.lan/ | grep -q "200 OK\|Apache"; then
  echo -e "${GREEN}[OK] Servidor Web Apache operativo${NC}"
else
  echo -e "${RED}[FALLO] No responde el servidor web${NC}"
fi

echo -n "  - Prueba de acceso a puerto SSH (22): "
if nc -z -w2 10.0.0.10 22 2>/dev/null; then
  echo -e "${GREEN}[OK] Puerto SSH 22 abierto${NC}"
else
  echo -e "${RED}[FALLO] Puerto SSH inaccesible${NC}"
fi

echo -e "\n${GREEN}Comprobaciones finalizadas en el puesto del alumno.${NC}"

