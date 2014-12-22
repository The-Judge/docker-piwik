FROM centos:centos7
MAINTAINER mail@marc-richter.info

RUN yum -y update \
    && yum -y upgrade

EXPOSE 80
EXPOSE 443

VOLUME ["/home/redmine/data"]
VOLUME ["/var/log/redmine"]

