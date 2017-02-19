FROM centos:centos7
MAINTAINER mail@marc-richter.info

ENV EPEL_RELEASE "7"
ENV REMI_RELEASE "7"

# Update System
RUN yum -y update \
    && yum -y upgrade

# Install helpers
RUN yum -y install python-setuptools unzip wget

# Add EPEL repo
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-${EPEL_RELEASE}.noarch.rpm \
    && yum install -y epel-release-latest-${EPEL_RELEASE}.noarch.rpm \
    && rm -f epel-release-latest-${EPEL_RELEASE}.noarch.rpm
# Add REMI repo
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-${REMI_RELEASE}.rpm \
    && yum install -y remi-release-${REMI_RELEASE}.rpm \
    && rm -f remi-release-${REMI_RELEASE}.rpm

# Install base packages
RUN yum -y install httpd httpd-tools mariadb postgresql unzip cronie

# Install piwik requirements
# Workarround for cap_set_file - error
RUN yum -y install php71-php php71-php-cli php71-php-fpm php71-php-gd php71-php-imap php71-php-intl php71-php-json \
    php71-php-ldap php71-php-mbstring php71-php-mcrypt php71-php-mysqlnd php71-php-pdo php71-php-pear php71-php-pgsql \
    php71-php-process php71-php-pspell php71-php-recode php71-php-soap php71-php-xml php71-php-xmlrpc \
    php71-php-devel ; exit 0
RUN update-alternatives --install /usr/bin/php php /usr/bin/php71 1 \
    && update-alternatives --install /usr/bin/php-cgi php-cgi /usr/bin/php71-cgi 1 \
    && update-alternatives --install /usr/bin/php-pear php-pear /usr/bin/php71-pear 1 \
    && update-alternatives --install /usr/bin/php-phar php-phar /usr/bin/php71-phar 1

# Install supervisor
RUN easy_install supervisor \
    && echo_supervisord_conf > /etc/supervisord.conf \
    && mkdir -p /etc/supervisord.d \
    && sed -i'' 's#nodaemon=false#nodaemon=true#g' /etc/supervisord.conf \
    && sed -i'' 's#^;\[include#\[include#g' /etc/supervisord.conf \
    && sed -i'' 's#^;files .*$#files = /etc/supervisord.d/*#g' /etc/supervisord.conf

# Install GeoIP PECL support for fast Geolocation support in Piwik
#RUN yum install -y php-pecl-geoip
# ... and use it
#RUN echo "geoip.custom_directory=/var/www/html/piwik/misc" >> /etc/php.d/geoip.ini

EXPOSE 80
EXPOSE 443

ADD init.sh /init.sh
ADD supervisord_httpd.conf /etc/supervisord.d/supervisord_httpd.conf
ADD supervisord_crond.conf /etc/supervisord.d/supervisord_crond.conf

ADD crontab /tmp/crontab
RUN crontab -u apache /tmp/crontab && rm -f /tmp/crontab

RUN chmod +x /init.sh
RUN mkdir /mnt/piwik-config

VOLUME ["/var/log"]
VOLUME ["/var/www/html"]

CMD ["/init.sh"]
