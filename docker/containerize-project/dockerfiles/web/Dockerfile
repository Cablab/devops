FROM nginx
LABEL "Project"="Vprofile"
LABEL "Author"="Imran"

# Remove default configuration, add our own custom config
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginvproapp.conf /etc/nginx/conf.d/vproapp.conf