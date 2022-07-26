# Creates an Apache2 Web Server Container
# Requires a file called 'nano.tar.gz' to exist in the directory where `docker build` is run
# 'nano.tar.gz' is an archive of a full static web template (like from tooplate.com)

FROM ubuntu:latest
LABEL "Author"="Cablab"
LABEL "Project"="nano"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install apache2 git -y
# RUN apt install apache2 git -y
CMD [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND" ]
EXPOSE 80
WORKDIR /var/www/html
VOLUME /var/log/apache2
ADD nano.tar.gz /var/www/html
# COPY /home/ubuntu/images/nano/nano.tar.gz /var/www/html