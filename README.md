# Hysteria v2 Backhaul Installer

This project provides a **simple automated script** to set up a Hysteria v2 reverse tunnel (backhaul) between two servers — typically one in **Iran** and one in a **free region** like the UK. This setup is perfect for bypassing heavy filtering and preserving high-speed, resilient VPN connectivity.

---

## 📦 Features
- One-click setup for **Hysteria v2 Server (Iran)** or **Client (UK)**
- Uses strong TLS and obfuscation (FakeTLS)
- Automatically generates TLS certificates and a strong password
- SOCKS5 proxy ready on the client for routing VPN or traffic

---

## ⚙️ Usage

### 1. Clone or Download
```bash
git clone https://github.com/freecyberhawk/hysteria-backhaul.git
cd hysteria-backhaul
```

### 2. Run Installer
```bash
bash install.sh
```
Choose:
- `1` for Iran server (opens port & waits for client)
- `2` for UK client (connects to Iran & provides local proxy)

---

## 🗃 Directory Structure
```
hysteria-backhaul/
├── install.sh          # Main installer script
└── binaries/
    └── hy2            # Pre-downloaded Hysteria v2 binary
```

If `get.hy2.sh` is blocked, this repo avoids it by using the local binary from `binaries/hy2`.

---

## ☕ Support This Project
If you find this helpful and want to support my work:

**TRON Wallet:**
```
TAAJsdT3AnVD8cnKWP9SH3rKgi6zgfLWMt
```

Thank you 🙏

---

## 🔐 Disclaimer
Use responsibly. This project is intended to help users in censored regions access free and open internet. You are responsible for your own usage.