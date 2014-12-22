FROM centos:centos7
MAINTAINER mail@marc-richter.info

# Update System
RUN yum -y update \
    && yum -y upgrade
# Install piwik requirements
RUN yum -y install php php-pdo php-mysql php-pgsql php-bcmath php-gd httpd-tools httpd mariadb postgresql
# Install helpers
RUN yum -y install python-setuptools unzip wget
RUN easy_install supervisor \
    && echo_supervisord_conf > /etc/supervisord.conf \
    && mkdir -p /etc/supervisord.d \
    && sed -i'' 's#nodaemon=false#nodaemon=true#g' /etc/supervisord.conf \
    && sed -i'' 's#^;\[include#\[include#g' /etc/supervisord.conf \
    && sed -i'' 's#^;files .*$#files = /etc/supervisord.d/*#g' /etc/supervisord.conf

EXPOSE 80
EXPOSE 443

ADD init.sh /init.sh
ADD supervisord_httpd.conf /etc/supervisord.d/supervisord_httpd.conf

RUN chmod +x /init.sh

VOLUME ["/var/log"]
VOLUME ["/var/www/html"]

CMD ["/init.sh"]
