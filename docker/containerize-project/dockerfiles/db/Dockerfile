FROM mysql:5.7.25
LABEL "Project"="Vprofile"
LABEL "Author"="Imran"

# Set default password and database
ENV MYSQL_ROOT_PASSWORD="vprodbpass"
ENV MYSQL_DATABASE="accounts"

# mysql image runs any scripts added to docker-entrypoint-initdb.d,
# so add our custom database initialization script to that place
ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql