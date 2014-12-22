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

# Start supervisord in foreground (must be the last action of this script)
/usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
