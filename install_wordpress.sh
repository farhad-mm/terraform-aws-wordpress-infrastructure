#!/bin/bash
set -e

# 1. Update system and install required packages
apt-get update -y
apt-get install -y apache2 php php-mysql php-curl php-gd php-xml php-mbstring libapache2-mod-php mysql-client

# 2. Detect and format/mount the extra EBS volume for persistent storage
DATA_DIR="/var/www/wordpress-data"
mkdir -p "$DATA_DIR"

DEVICE=""
for i in 1 2 3 4 5 6 7 8 9 10; do
DEVICE=$(lsblk -ndo NAME,TYPE | awk '$2=="disk"' | awk '{print $1}' | grep -v "^xvda$\|^nvme0n1$" | head -n1)
if [ -n "$DEVICE" ]; then
break
fi
sleep 5
done

if [ -n "$DEVICE" ]; then
DEVICE_PATH="/dev/$DEVICE"
if ! blkid "$DEVICE_PATH" > /dev/null 2>&1; then
mkfs -t ext4 "$DEVICE_PATH"
fi
mount "$DEVICE_PATH" "$DATA_DIR"
echo "$DEVICE_PATH $DATA_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# 3. Download and extract WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm -rf /var/www/html
mv wordpress /var/www/html

# 4. Configure WordPress to use the RDS database
cd /var/www/html
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_username}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_endpoint}/" wp-config.php

# 5. Permissions and start Apache
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
systemctl enable apache2
systemctl restart apache2

# 6. Bonus: configure self-signed HTTPS on port 443
a2enmod ssl

INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/wordpress-selfsigned.key \
-out /etc/ssl/certs/wordpress-selfsigned.crt \
-subj "/C=DE/ST=MV/L=Rostock/O=Bootcamp/CN=$INSTANCE_IP"

cat > /etc/apache2/sites-available/wordpress-ssl.conf << EOC

ServerName $INSTANCE_IP
DocumentRoot /var/www/html

SSLEngine on
SSLCertificateFile /etc/ssl/certs/wordpress-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/wordpress-selfsigned.key

AllowOverride All
Require all granted

EOC

a2ensite wordpress-ssl.conf
systemctl restart apache2
