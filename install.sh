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
# --- End: Hawk Proxy Banner ---


set -e

# Generate a random strong password
GEN_PASS=$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c 20)

# Colors
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

function install_hysteria() {
  echo -e "${CYAN}Installing Hysteria (from GitHub mirror)...${RESET}"
  wget -q https://github.com/freecyberhawk/hysteria-backhaul/raw/main/binaries/hy2 -O /usr/local/bin/hy2
  chmod +x /usr/local/bin/hy2
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
}

# Main menu
echo -e "${CYAN}==== HYSTERIA v2 BACKHAUL SETUP ====${RESET}"
echo "1) Setup Iran Server (Server mode)"
echo "2) Setup UK Client (Client mode)"
echo -n "Select mode (1 or 2): "
read mode

install_hysteria

if [ "$mode" == "1" ]; then
  setup_server
elif [ "$mode" == "2" ]; then
  setup_client
else
  echo "Invalid option. Exiting."
  exit 1
fi
