# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile Oficial para el Laboratorio del Libro "Servicios en Red" (2.º SMR)
# Autor: Francisco Sánchez Ruz (Profesor de Enseñanza Secundaria y FP - Informática)
# Editorial: Editorial Monsálvez (2026)
# Topología: Red de Aula 10.0.0.0/24 y Dominio smr.lan

Vagrant.configure("2") do |config|
  # Imagen base oficial: Debian 12 Bookworm (64 bits)
  config.vm.box = "debian/bookworm64"

  # =========================================================================
  # 1. SERVIDOR CENTRAL DE SERVICIOS (server.smr.lan - 10.0.0.10)
  # =========================================================================
  config.vm.define "servidor-smr" do |srv|
    srv.vm.hostname = "server.smr.lan"

    # Red interna aislada de taller: 10.0.0.10
    srv.vm.network "private_network",
      ip: "10.0.0.10",
      netmask: "255.255.255.0",
      virtualbox__intnet: "red_taller_smr"

    # Reenvío de puertos hacia la máquina anfitriona para pruebas directas
    srv.vm.network "forwarded_port", guest: 10000, host: 10000, id: "webmin"
    srv.vm.network "forwarded_port", guest: 80, host: 8080, id: "apache_http"
    srv.vm.network "forwarded_port", guest: 443, host: 8443, id: "apache_https"
    srv.vm.network "forwarded_port", guest: 21, host: 2121, id: "ftp_control"

    srv.vm.provider "virtualbox" do |vb|
      vb.name = "SMR_Servidor_10.0.0.10"
      vb.memory = "2048"
      vb.cpus = 2
    end

    # Aprovisionamiento inicial del servidor
    srv.vm.provision "shell", inline: <<-SHELL
      echo "=== Configurando Servidor Central SMR (10.0.0.10) ==="
      apt-get update -y
      apt-get install -y curl wget gnupg2 sudo net-tools dnsutils tcpdump git
      
      # Habilitar repositorio oficial de Webmin
      curl -fsSL https://download.webmin.com/developers-key.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/webmin.gpg
      echo "deb [signed-by=/etc/apt/trusted.gpg.d/webmin.gpg] https://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
      apt-get update -y
      apt-get install -y webmin --install-recommends
      
      # Crear usuario docente/alumno con sudo
      useradd -m -s /bin/bash alumno01
      echo "alumno01:smr2026" | chpasswd
      usermod -aG sudo alumno01
      
      echo "=== Servidor preparado. Ejecuta 'bash /vagrant/scripts/desplegar_servidor_smr.sh' para cargar todos los servicios ==="
    SHELL
  end

  # =========================================================================
  # 2. ROUTER / PASARELA DE ENLACE (router.smr.lan - 10.0.0.1)
  # =========================================================================
  config.vm.define "router-smr" do |rtr|
    rtr.vm.hostname = "router.smr.lan"

    # Interfaz LAN de taller: 10.0.0.1/24
    rtr.vm.network "private_network",
      ip: "10.0.0.1",
      netmask: "255.255.255.0",
      virtualbox__intnet: "red_taller_smr"

    rtr.vm.provider "virtualbox" do |vb|
      vb.name = "SMR_Router_10.0.0.1"
      vb.memory = "1024"
      vb.cpus = 1
    end

    # Habilitar enrutamiento IP y enmascaramiento NAT
    rtr.vm.provision "shell", inline: <<-SHELL
      echo "=== Configurando Router / Pasarela NAT (10.0.0.1) ==="
      apt-get update -y
      apt-get install -y iptables iptables-persistent tcpdump traceroute
      
      # Activar IP forwarding en el kernel
      echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
      sysctl -p
      
      # Regla de enmascaramiento NAT para la salida a Internet (eth0 -> WAN)
      iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
      netfilter-persistent save
      echo "=== Router Pasarela operativo y enrutando paquetes ==="
    SHELL
  end

  # =========================================================================
  # 3. CLIENTE DE AULA DE PRÁCTICAS (cliente01.smr.lan - DHCP)
  # =========================================================================
  config.vm.define "cliente-smr" do |cli|
    cli.vm.hostname = "cliente01.smr.lan"

    # Conectado a la misma red interna para recibir configuración DHCP
    cli.vm.network "private_network",
      type: "dhcp",
      virtualbox__intnet: "red_taller_smr"

    cli.vm.provider "virtualbox" do |vb|
      vb.name = "SMR_Cliente_DHCP"
      vb.memory = "1024"
      vb.cpus = 1
    end

    cli.vm.provision "shell", inline: <<-SHELL
      echo "=== Cliente de Aula preparado para recibir IP dinámica de 10.0.0.10 ==="
      apt-get update -y
      apt-get install -y dnsutils curl ftp traceroute net-tools
    SHELL
  end
end

