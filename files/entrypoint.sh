#!/usr/bin/env bash
set -e

# Export these so that apache can use them in the configuration files directly
export APP_WEBROOT=${APP_WEBROOT:-/app/html}
export PHP_HOSTNAME=${PHP_HOSTNAME:-php}
export PHP_PORT=${PHP_PORT:-9000}

# List of ports to listen to, space separated list
WEB_PORTS_HTTP=${WEB_PORTS_HTTP:-80}

echo "* DocumentRoot: $APP_WEBROOT"
echo "* PHP-FPM: $PHP_HOSTNAME:$PHP_PORT"

# If env variables SSL_KEY and SSL_CRT are set, configure apache for SSL access
if [ ! -z "$SSL_KEY" ] && [ ! -z "$SSL_CRT" ]; then
  echo -n "* Enabling SSL..."
  echo "$SSL_KEY" | sed 's/^ *//;s/ *$//' > /etc/ssl/certs/server.key
  echo "$SSL_CRT" | sed 's/^ *//;s/ *$//' > /etc/ssl/certs/server.crt
  servername=$(openssl x509 -in /etc/ssl/certs/server.crt  -noout -ext subjectAltName | grep DNS | cut -f 2 -d ":")
  echo " certificate for servername: $servername"

  # prepare vhost conf for HTTPS
  WEB_PORTS_HTTPS=${WEB_PORTS_HTTPS:-443}
  VHOST="*:${WEB_PORTS_HTTPS// / *:}"
  sed -e "s/###VHOST###/$VHOST/g;" /opt/docker-phpapp-web/httpd-vhost-ssl.conf > /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf
  echo "* HTTPS ports: $WEB_PORTS_HTTPS"
else
  rm -f /usr/local/apache2/conf/extra/httpd-vhost-ssl.conf
fi

# Add extra configuration from HTTPD_EXTRA_CONF variable
if [ ! -z "$HTTPD_EXTRA_CONF" ]; then
  echo $HTTPD_EXTRA_CONF > /usr/local/apache2/conf/extra/custom.conf
else
  echo> /usr/local/apache2/conf/extra/custom.conf
fi

# prepare vhost conf for HTTP
VHOST="*:${WEB_PORTS_HTTP// / *:}"
sed -e "s/###VHOST###/$VHOST/g;" /opt/docker-phpapp-web/httpd-vhost.conf > /usr/local/apache2/conf/extra/httpd-vhost.conf
echo "* HTTP ports: $WEB_PORTS_HTTP"

cp /opt/docker-phpapp-web/httpd-vhost-global.conf /usr/local/apache2/conf/extra/
for port in $WEB_PORTS_HTTP $WEB_PORTS_HTTPS; do
  echo "Listen $port" >> /usr/local/apache2/conf/extra/httpd-vhost-global.conf
done

cp /opt/docker-phpapp-web/httpd.conf /usr/local/apache2/conf/

# Now start the original entrypoint of the httpd container
exec httpd-foreground
