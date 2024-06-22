#!/bin/bash


if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Minta input password root MariaDB dari pengguna
read -sp "Enter the MariaDB root password: " MARIADB_ROOT_PASSWORD
echo
read -sp "Confirm the MariaDB root password: " MARIADB_ROOT_PASSWORD_CONFIRM
echo

# Pastikan password yang dikonfirmasi cocok
if [ "$MARIADB_ROOT_PASSWORD" != "$MARIADB_ROOT_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match. Please run the script again."
  exit 1
fi

# Update daftar paket
echo "Updating package list..."
apt-get update -y

# Instal MariaDB Server
echo "Installing MariaDB Server..."
apt-get install mariadb-server -y

# Memulai layanan MariaDB
echo "Starting MariaDB service..."
systemctl start mariadb

# Mengaktifkan layanan MariaDB untuk memulai secara otomatis saat boot
echo "Enabling MariaDB to start on boot..."
systemctl enable mariadb

# Mengamankan instalasi MariaDB
echo "Securing MariaDB installation..."

# Jalankan mysql_secure_installation tanpa prompt
mysql_secure_installation <<EOF

Y
$MARIADB_ROOT_PASSWORD
$MARIADB_ROOT_PASSWORD
Y
Y
Y
Y
EOF


echo "Info : MySQL root password : $MARIADB_ROOT_PASSWORD"
echo "MySQL installation and initial setup complete."
echo "MySQL root password has been set."
echo "All done!"
