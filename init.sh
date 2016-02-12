#!/bin/bash
# Install piwik
if [ ! -d /var/www/html/piwik ]; then
    wget http://builds.piwik.org/piwik.zip
    unzip piwik.zip -d /var/www/html/
    rm -f piwik.zip
    chown apache:apache -R /var/www/html/piwik
fi

# Use existing Piwik config if available
if [ -e /mnt/piwik-config/config.ini.php ]; then
    ln -sf /mnt/piwik-config/config.ini.php /var/www/html/piwik/config/config.ini.php
fi

# Download latest Geo-Database ...
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -O - | \
  gzip -d > /var/www/html/piwik/misc/GeoIPCity.dat
chown apache:apache /var/www/html/piwik/misc/GeoIPCity.dat

# Update Database
php /var/www/html/piwik/console core:update --yes --no-interaction --no-ansi

# Create needed folders
mkdir -p /var/log/httpd
chown apache:apache -R /var/log/httpd /var/www/html

# Start supervisord in foreground (must be the last action of this script)
/usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
