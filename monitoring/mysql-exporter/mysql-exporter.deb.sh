#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Meminta input dari pengguna
read -p "Enter the MariaDB/MySQL Username For Exporter: " MARIADB_EXPORTER_USERNAME
echo
read -s -p "Enter the MariaDB/MySQL Password For Exporter: " MARIADB_EXPORTER_PASSWORD
echo

# Memeriksa apakah wget sudah diinstal
echo "Checking if wget is installed..."
if ! [ -x "$(command -v wget)" ]; then
  echo "wget is not installed. Installing wget..."
  apt-get update
  apt-get install wget -y
fi

echo "Downloading mysqld_exporter..."
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.1/mysqld_exporter-0.15.1.linux-amd64.tar.gz

echo "Extracting mysqld_exporter..."
tar xvfz mysqld_exporter-0.15.1.linux-amd64.tar.gz

echo "Moving mysqld_exporter to /usr/local/bin..."
mv mysqld_exporter-0.15.1.linux-amd64/mysqld_exporter /usr/local/bin

echo "Creating mysqld_exporter user..."
useradd -rs /bin/false mysqld_exporter

echo "Create .my.cnf file..."
echo "[client]" > /home/mysqld_exporter/.my.cnf
echo "user=$MARIADB_EXPORTER_USERNAME" >> /home/mysqld_exporter/.my.cnf
echo "password=$MARIADB_EXPORTER_PASSWORD" >> /home/mysqld_exporter/.my.cnf

echo "Setting permissions for .my.cnf..."
chown mysqld_exporter:mysqld_exporter /home/mysqld_exporter/.my.cnf
chmod 600 /home/mysqld_exporter/.my.cnf

echo "Creating systemd service file..."
echo "[Unit]" > /etc/systemd/system/mysqld_exporter.service
echo "Description=Prometheus MySQL Exporter" >> /etc/systemd/system/mysqld_exporter.service
echo "After=network.target" >> /etc/systemd/system/mysqld_exporter.service
echo "" >> /etc/systemd/system/mysqld_exporter.service
echo "[Service]" >> /etc/systemd/system/mysqld_exporter.service
echo "User=mysqld_exporter" >> /etc/systemd/system/mysqld_exporter.service
echo "ExecStart=/usr/local/bin/mysqld_exporter" >> /etc/systemd/system/mysqld_exporter.service
echo "" >> /etc/systemd/system/mysqld_exporter.service
echo "[Install]" >> /etc/systemd/system/mysqld_exporter.service
echo "WantedBy=default.target" >> /etc/systemd/system/mysqld_exporter.service

echo "Reloading systemd service..."
systemctl daemon-reload

echo "Starting mysqld_exporter service..."
systemctl start mysqld_exporter

echo "Enabling mysqld_exporter service to start on boot..."
systemctl enable mysqld_exporter

echo "Checking mysqld_exporter service status..."
systemctl status mysqld_exporter

echo "MySQL Exporter installation and initial setup complete."
echo "All done!"
