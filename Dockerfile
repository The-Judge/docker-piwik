FROM centos:centos7
MAINTAINER mail@marc-richter.info

ENV EPEL_RELEASE "7"
ENV REMI_RELEASE "7"

# Update System
RUN yum -y update \
    && yum -y upgrade

# Install helpers
RUN yum -y install python-setuptools unzip wget

# Make PHP 7 available
RUN wget "https://centos7.iuscommunity.org/ius-release.rpm" \
    && rpm -i ius-release.rpm \
    && rm -f ius-release.rpm \
    && rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY

# Install piwik requirements
# Workarround for cap_set_file - error
#RUN yum -y install php php-pdo php-mysql php-pgsql php-bcmath php-gd php-mbstring php-xml httpd httpd-tools mariadb \
#    postgresql unzip cronie ; exit 0
RUN yum -y install php70u-cli php70u-fpm php70u-gd php70u-imap php70u-intl php70u-json php70u-ldap php70u-mbstring \
    php70u-mcrypt php70u-mysqlnd php70u-pdo php70u-pear php70u-pgsql php70u-process php70u-pspell php70u-recode \
    php70u-soap php70u-xml php70u-xmlrpc php70u-devel ; exit 0

# Install supervisor
RUN easy_install supervisor \
    && echo_supervisord_conf > /etc/supervisord.conf \
    && mkdir -p /etc/supervisord.d \
    && sed -i'' 's#nodaemon=false#nodaemon=true#g' /etc/supervisord.conf \
    && sed -i'' 's#^;\[include#\[include#g' /etc/supervisord.conf \
    && sed -i'' 's#^;files .*$#files = /etc/supervisord.d/*#g' /etc/supervisord.conf

# Install GeoIP PECL support for fast Geolocation support in Piwik
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-${EPEL_RELEASE}.noarch.rpm \
    && yum install -y epel-release-latest-${EPEL_RELEASE}.noarch.rpm \
    && rm -f epel-release-latest-${EPEL_RELEASE}.noarch.rpm
RUN wget http://rpms.famillecollet.com/enterprise/remi-release-${REMI_RELEASE}.rpm \
    && yum install -y remi-release-${REMI_RELEASE}.rpm \
    && rm -f remi-release-${REMI_RELEASE}.rpm
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
