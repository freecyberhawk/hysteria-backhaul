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
# --- End: Banner ---

set -e

# Generate a random strong password

GEN\_PASS=\$(openssl rand -base64 18 | tr -dc 'a-zA-Z0-9' | head -c 20)

# Colors

GREEN="\e\[32m"
CYAN="\e\[36m"
RESET="\e\[0m"

function install\_hysteria() {
echo -e "\${CYAN}Installing Hysteria (from GitHub mirror)...\${RESET}"
echo -ne "\[                    ] 0%\r"
curl -# -L [https://github.com/freecyberhawk/hysteria-backhaul/raw/main/binaries/hy2](https://github.com/freecyberhawk/hysteria-backhaul/raw/main/binaries/hy2) -o /usr/local/bin/hy2
chmod +x /usr/local/bin/hy2
echo -e "\[####################] 100%"
echo -e "\${GREEN}✅ Hysteria binary installed.\${RESET}"
}

function setup\_server() {
read -p "Enter port for Hysteria server (e.g. 8443): " PORT
mkdir -p /etc/hysteria
cd /etc/hysteria

echo -e "\${CYAN}Generating TLS certificate...\${RESET}"
openssl req -x509 -newkey rsa:2048 -nodes -keyout hysteria.key -out hysteria.crt -days 3650 -subj "/CN=localhost"

cat > /etc/hysteria/server.yaml <\<EOF
listen: :\$PORT
tls:
cert: /etc/hysteria/hysteria.crt
key: /etc/hysteria/hysteria.key
auth:
type: password
password: \$GEN\_PASS
obfuscation:
type: faketls
hostname: [www.cloudflare.com](http://www.cloudflare.com)
bandwidth:
up\_mbps: 1000
down\_mbps: 1000
udp:
disabled: false
EOF

cat > /etc/systemd/system/hysteria-server.service <\<EOF
\[Unit]
Description=Hysteria 2 Server
After=network.target

\[Service]
ExecStart=/usr/local/bin/hy2 server -c /etc/hysteria/server.yaml
Restart=always
User=root

\[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hysteria-server

echo -e "\${GREEN}✅ Hysteria Server installed and running on UDP port \$PORT\${RESET}"
echo -e "\${CYAN}🔐 Password: \$GEN\_PASS\${RESET}"
}

function setup\_client() {
read -p "Enter IP of Iran server: " SERVER\_IP
read -p "Enter port of Hysteria server (e.g. 8443): " SERVER\_PORT
read -p "Enter password used on server: " CLIENT\_PASS
read -p "Enter local ports to expose over SOCKS5 (comma-separated, e.g. 8080,2053): " FORWARD\_PORTS

mkdir -p /etc/hysteria
cat > /etc/hysteria/client.yaml <\<EOF
server: \$SERVER\_IP:\$SERVER\_PORT
auth: \$CLIENT\_PASS
tls:
insecure: true
obfuscation:
type: faketls
hostname: [www.cloudflare.com](http://www.cloudflare.com)
socks5:
listen: 127.0.0.1:1080
remote\_ports: \[\$(echo \$FORWARD\_PORTS | sed 's/,/, /g')]
EOF

cat > /etc/systemd/system/hysteria-client.service <\<EOF
\[Unit]
Description=Hysteria 2 Client
After=network.target

\[Service]
ExecStart=/usr/local/bin/hy2 client -c /etc/hysteria/client.yaml
Restart=always
User=root

\[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now hysteria-client

echo -e "\${GREEN}✅ Hysteria Client is now running and connected to \$SERVER\_IP:\$SERVER\_PORT\${RESET}"
echo -e "\${CYAN}SOCKS5 proxy is available at 127.0.0.1:1080\${RESET}"
echo -e "\${CYAN}Forwarded ports: \$FORWARD\_PORTS\${RESET}"
}

function check\_status() {
echo -e "\n\${CYAN}== Service Status ==\${RESET}"
systemctl status hysteria-server 2>/dev/null || systemctl status hysteria-client
}

function follow\_logs() {
echo -e "\n\${CYAN}== Streaming Logs (press Ctrl+C to stop) ==\${RESET}"
journalctl -u hysteria-server -f 2>/dev/null || journalctl -u hysteria-client -f
}

# Main menu

echo -e "\${CYAN}==== HYSTERIA v2 BACKHAUL SETUP ====\${RESET}"
echo "1) Setup Iran Server (Server mode)"
echo "2) Setup UK Client (Client mode)"
echo "3) Check Service Status"
echo "4) Follow Service Logs"
echo -n "Select mode (1, 2, 3 or 4): "
read mode

install\_hysteria

case \$mode in

1. setup\_server ;;
2. setup\_client ;;
3. check\_status ;;
4. follow\_logs ;;
   \*) echo "Invalid option. Exiting." && exit 1 ;;
   esac
