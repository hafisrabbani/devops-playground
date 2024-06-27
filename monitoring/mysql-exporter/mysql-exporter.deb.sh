#!/usr/bin/env bash

# Pastikan skrip dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Meminta input dari pengguna
read -sp "Enter the MariaDB/MySQL Username For Exporter: " MARIADB_EXPORTER_USERNAME
echo
read -sp "Enter the MariaDB/MySQL Password For Exporter: " MARIADB_EXPORTER_PASSWORD
echo

# Memeriksa apakah wget sudah diinstal
echo "Checking if wget is installed..."
if ! [ -x "$(command -v wget)" ]; then
  echo "wget is not installed. Installing wget..."
  apt-get update
  apt-get install wget -y
fi

# Mendapatkan versi terbaru mysqld_exporter
LATEST_RELEASE=$(curl -s https://api.github.com/repos/prometheus/mysqld_exporter/releases/latest | grep tag_name | cut -d '"' -f 4)

# Mengunduh dan menginstal mysqld_exporter
echo "Downloading MySQL Exporter..."
wget https://github.com/prometheus/mysqld_exporter/releases/download/$LATEST_RELEASE/mysqld_exporter-$LATEST_RELEASE.linux-amd64.tar.gz

echo "Extracting MySQL Exporter..."
tar -xvf mysqld_exporter-$LATEST_RELEASE.linux-amd64.tar.gz

echo "Moving MySQL Exporter..."
mv mysqld_exporter-$LATEST_RELEASE.linux-amd64/mysqld_exporter /usr/local/bin

# Membuat file konfigurasi untuk mysqld_exporter
echo "Creating configuration file for MySQL Exporter..."
cat <<EOF > /etc/.mysqld_exporter.cnf
[client]
user=$MARIADB_EXPORTER_USERNAME
password=$MARIADB_EXPORTER_PASSWORD
EOF

# Membuat file service untuk mysqld_exporter
echo "Creating MySQL Exporter service file..."
cat <<EOF > /etc/systemd/system/mysql-exporter.service
[Unit]
Description=Prometheus MySQL Exporter
After=network.target

[Service]
User=nobody
Group=nogroup
Type=simple
ExecStart=/usr/local/bin/mysqld_exporter \
  --config.my-cnf="/etc/.mysqld_exporter.cnf"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai mysqld_exporter
echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Starting MySQL Exporter service..."
systemctl start mysql-exporter

echo "Enabling MySQL Exporter service on boot..."
systemctl enable mysql-exporter

echo "MySQL Exporter installation and setup is complete."
