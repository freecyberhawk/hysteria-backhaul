#!/bin/bash

echo -e "\033[1;36m"
cat << "EOF"
                  _            _               ____
  /\  /\_   _ ___| |_ ___ _ __(_) __ _  __   _|___ \
 / /_/ / | | / __| __/ _ \ '__| |/ _` | \ \ / / __) |
/ __  /| |_| \__ \ ||  __/ |  | | (_| |  \ V / / __/
\/ /_/  \__, |___/\__\___|_|  |_|\__,_|   \_/ |_____|
        |___/

EOF
echo -e "          github.com/\033[4mfreecyberhawk\033[0m"
echo -e "\033[0m"

set -e

# Generate a random strong password
GEN_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c 20)

# Colors
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

function install_hysteria() {
  echo -e "${CYAN}Installing Hysteria (from GitHub mirror)...${RESET}"
  echo -ne "[                    ] 0%\r"
  curl -# -L https://github.com/freecyberhawk/hysteria-backhaul/raw/main/binaries/hy2 -o /usr/local/bin/hy2
  chmod +x /usr/local/bin/hy2
  echo -e "[####################] 100%"
  echo -e "${GREEN}✅ Hysteria binary installed.${RESET}"
}

function setup_server() {
  read -p "Enter port for Hysteria server (e.g. 8443): " PORT
  mkdir -p /etc/hysteria
  cd /etc/hysteria

  echo -e "${CYAN}Generating TLS certificate...${RESET}"
  openssl req -x509 -newkey rsa:2048 -nodes -keyout hysteria.key -out hysteria.crt -days 3650 -subj "/CN=localhost"

  cat > /etc/hysteria/server.yaml <<EOF
listen: :$PORT
tls:
  cert: /etc/hysteria/hysteria.crt
  key: /etc/hysteria/hysteria.key
auth:
  type: password
  password: $GEN_PASS
obfuscation:
  type: faketls
  hostname: www.cloudflare.com
bandwidth:
  up_mbps: 1000
  down_mbps: 1000
udp:
  disabled: false
EOF

  cat > /etc/systemd/system/hysteria-server.service <<EOF
[Unit]
Description=Hysteria 2 Server
After=network.target

[Service]
ExecStart=/usr/local/bin/hy2 server -c /etc/hysteria/server.yaml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now hysteria-server

  echo -e "${GREEN}✅ Hysteria Server installed and running on UDP port $PORT${RESET}"
  echo -e "${CYAN}🔐 Password: $GEN_PASS${RESET}"
}

function setup_client() {
  read -p "Enter IP of Iran server: " SERVER_IP
  read -p "Enter port of Hysteria server (e.g. 8443): " SERVER_PORT
  read -p "Enter password used on server: " CLIENT_PASS
  read -p "Enter local ports to expose over SOCKS5 (comma-separated, e.g. 8080,2053): " FORWARD_PORTS

  mkdir -p /etc/hysteria
  cat > /etc/hysteria/client.yaml <<EOF
server: $SERVER_IP:$SERVER_PORT
auth: $CLIENT_PASS
tls:
  insecure: true
obfuscation:
  type: faketls
  hostname: www.cloudflare.com
socks5:
  listen: 127.0.0.1:1080
  remote_ports: [$(echo $FORWARD_PORTS | sed 's/,/, /g')]
EOF

  cat > /etc/systemd/system/hysteria-client.service <<EOF
[Unit]
Description=Hysteria 2 Client
After=network.target

[Service]
ExecStart=/usr/local/bin/hy2 client -c /etc/hysteria/client.yaml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now hysteria-client

  echo -e "${GREEN}✅ Hysteria Client is now running and connected to $SERVER_IP:$SERVER_PORT${RESET}"
  echo -e "${CYAN}SOCKS5 proxy is available at 127.0.0.1:1080${RESET}"
  echo -e "${CYAN}Forwarded ports: $FORWARD_PORTS${RESET}"
}

function check_status() {
  echo -e "\n${CYAN}== Service Status ==${RESET}"
  systemctl status hysteria-server 2>/dev/null || systemctl status hysteria-client
}

function follow_logs() {
  echo -e "\n${CYAN}== Streaming Logs (press Ctrl+C to stop) ==${RESET}"
  journalctl -u hysteria-server -f 2>/dev/null || journalctl -u hysteria-client -f
}

function stop_service() {
  echo -e "\n${CYAN}== Stopping Hysteria Service ==${RESET}"
  systemctl stop hysteria-server 2>/dev/null || systemctl stop hysteria-client
  echo -e "${GREEN}✅ Hysteria service stopped.${RESET}"
}

# Main menu
echo -e "${CYAN}==== HYSTERIA v2 BACKHAUL SETUP ====${RESET}"
echo "1) Install Hysteria Core (Required)"
echo "2) Setup Iran Server (Server mode)"
echo "3) Setup Kharej Client (Client mode)"
echo "4) Check Service Status"
echo "5) Follow Service Logs"
echo "6) Stop Hysteria Service"
echo -n "Select mode (1, 2, 3, 4 or 5): "
read mode


case $mode in
  1) install_hysteria ;;
  2) setup_server ;;
  3) setup_client ;;
  4) check_status ;;
  5) follow_logs ;;
  6) stop_service ;;
  *) echo "Invalid option. Exiting." && exit 1 ;;
esac