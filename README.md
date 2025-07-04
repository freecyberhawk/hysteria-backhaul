# Hysteria Backhaul Setup

This repository allows you to quickly set up a **Hysteria v2 reverse tunnel** for VPN backhaul from an Iran server to a foreign server (e.g., UK). Ideal for bypassing restrictions where **incoming connections to Iran are allowed, but outgoing are filtered**.

## 📦 Features

* Auto-install `hy2` binary
* Backhaul setup with TLS and password authentication
* faketls obfuscation using `www.cloudflare.com`
* Easy interactive menu

## 🚀 Quick Start

Run this command on your server (Iran or UK):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/freecyberhawk/hysteria-backhaul/main/install.sh)
```

Choose:

* `1` for **Iran server** (runs Hysteria server on specified UDP port)
* `2` for **UK server** (connects as Hysteria client, sets up local SOCKS5)

---

## 📁 Repo Structure

```
hysteria-backhaul/
├── install.sh           # Main setup script
└── binaries/
    └── hy2             # Hysteria binary (Linux AMD64)
```

---

## ☕ Support the Author

If this tool helps you, consider buying me a coffee via Tron (TRX):

**`TAAJsdT3AnVD8cnKWP9SH3rKgi6zgfLWMt`**

> Maintained by [freecyberhawk](https://github.com/freecyberhawk)
