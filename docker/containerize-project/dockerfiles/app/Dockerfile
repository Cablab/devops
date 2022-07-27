FROM tomcat:8-jre11
LABEL "Project"="Vprofile"
LABEL "Author"="Imran"

# Remove default web apps
RUN rm -rf /usr/local/tomcat/webapps/*

# We built this artifact locally, it needs to be in the image
COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

# catalina.sh is built into the tomcat:8-jre11 image
CMD ["catalina.sh", "run"]
WORKDIR /usr/local/tomcat/

# Make this directory mountable for users
VOLUME /usr/local/tomcat/webapps