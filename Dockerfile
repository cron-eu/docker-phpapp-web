# See https://hub.docker.com/_/httpd/
FROM httpd:2.4

# We will need openssl tool for the entrypoint
RUN apt-get -qq update && apt-get -q install -y openssl netcat-traditional && rm -rf /var/lib/apt/lists/*

# Prepare our apache configuration
RUN rm /usr/local/apache2/conf/extra/httpd-vhosts.conf /usr/local/apache2/conf/original/extra/httpd-ssl.conf

# entrypoint.sh will copy the relevant files to /usr/local/apache2/conf/ on start
RUN mkdir -p /opt/docker-phpapp-web/
COPY files /opt/docker-phpapp-web/
RUN chmod 644 /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/extra/httpd-*

# We need an alternative entrypoint to do some stuff upon starting the container
COPY files/entrypoint.sh /
RUN chmod 755 /entrypoint.sh

# Configure healthcheck - use "nc" to see if port 80 is open, because curl might still get errors (403, etc)
HEALTHCHECK --interval=5s --timeout=3s CMD nc -z -v localhost 80 || exit 1

# Also expose SSL port
EXPOSE 80 443

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
