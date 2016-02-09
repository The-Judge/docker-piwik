FROM centos:centos7
MAINTAINER mail@marc-richter.info

# Update System
RUN yum -y update \
    && yum -y upgrade
# Install piwik requirements
RUN yum -y install php php-pdo php-mysql php-pgsql php-bcmath php-gd php-mbstring php-xml httpd-tools httpd mariadb \
    postgresql unzip cronie
# Install helpers
RUN yum -y install python-setuptools unzip wget
RUN easy_install supervisor \
    && echo_supervisord_conf > /etc/supervisord.conf \
    && mkdir -p /etc/supervisord.d \
    && sed -i'' 's#nodaemon=false#nodaemon=true#g' /etc/supervisord.conf \
    && sed -i'' 's#^;\[include#\[include#g' /etc/supervisord.conf \
    && sed -i'' 's#^;files .*$#files = /etc/supervisord.d/*#g' /etc/supervisord.conf
# Install GeoIP PECL support for fast Geolocation support in Piwik
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm \
    && yum install -y epel-release-7-5.noarch.rpm \
    && rm -f epel-release-7-5.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-7.rpm \
    && yum install -y remi-release-7.rpm \
    && rm -f remi-release-7.rpm
RUN yum install -y php-pecl-geoip
# ... and use it
RUN echo "geoip.custom_directory=/var/www/html/piwik/misc" >> /etc/php.d/geoip.ini

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
