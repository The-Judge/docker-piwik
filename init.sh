#!/bin/bash
# Install piwik
if [ ! -d /var/www/html/piwik ]; then
    wget http://builds.piwik.org/piwik.zip
    mv piwik.zip /var/www/html/
    cd /var/www/html
    unzip piwik.zip
    rm -f piwik.zip
    chown apache:apache -R piwik
fi

# Configure Piwik if unconfigured
if [ ! -e /var/www/html/piwik/config/config.ini.php ]; then
    cp -f /tmp/default_piwik_config.ini /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_DBHOST#${DB_HOST}#g" /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_DBUSER#${DB_USER}#g" /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_DBPASS#${DB_PASS}#g" /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_DBNAME#${DB_NAME}#g" /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_SALT#$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)#g" /var/www/html/piwik/config/config.ini.php
    sed -i'' "s#CHANGE_ME_TRHOST#${TR_HOST}#g" /var/www/html/piwik/config/config.ini.php
fi

# Start supervisord in foreground (must be the last action of this script)
/usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
