#!/bin/bash


if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi


read -sp "Enter the MySQL root password: " MYSQL_ROOT_PASSWORD
echo
read -sp "Confirm the MySQL root password: " MYSQL_ROOT_PASSWORD_CONFIRM
echo

if [ "$MYSQL_ROOT_PASSWORD" != "$MYSQL_ROOT_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match. Please run the script again."
  exit 1
fi

echo "Updating package list..."
apt-get update -y


echo "Installing MySQL Server..."
apt-get install mysql-server -y

echo "Starting MySQL service..."
systemctl start mysql

echo "Enabling MySQL to start on boot..."
systemctl enable mysql
echo "Securing MySQL installation..."

mysql_secure_installation <<EOF

Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
EOF

echo "Info : MySQL root password : $MYSQL_ROOT_PASSWORD"
echo "MySQL installation and initial setup complete."
echo "MySQL root password has been set."
echo "All done!"
