# cron PHP application docker images - Webserver

## Abstract

Part of the `docker-phpapp` image suite.

See https://github.com/cron-eu/docker-phpapp-php/ for a complete explanation and
example usage.

This is the Webserver container, with images for **amd64** and **arm64** (i.e. also run on Apple M1).

## Tags available

* `croneu/phpapp-web:apache-2.4`

Currently, only Apache 2.4, so that the `.htaccess` files work out of the box. This
is based on the official image with pre-configured VirtualHost's to work with any
PHP-FPM image.

It also includes full HTTP/2 and HTTPS support.

To activate **HTTPS**, simply generate your certificates with `mkcert` and include these
in your `.env` - the image will automatically use these and generate a valid HTTPS
Vhost.

## `croneu/phpapp-web` settings

* `APP_WEBROOT`: defaults to `/app/html`, change, if your application public folder  is not
  called `html`. Examples:
   * TYPO3@cron: `/app/html`
   * Laravel:  `/app/public`
   * Neos:  `/app/Web`

* `HTTPD_EXTRA_CONF`: multiline string of extra configuration to put into httpd.conf. For example
  can be used to load extra Apache modules, i.e.
  ```
  HTTPD_EXTRA_CONF="
  LoadModule deflate_module modules/mod_deflate.so
  "
  ```

* `SSL_CRT`, `SSL_KEY`: Add your SSL certificate and private key here (the PEM strings,
  not the filenames) to enable Apache with SSL support. It will automatically listen to port "8443"

* `WEB_PORTS_HTTP` and `WEB_PORTS_HTTPS`: comma separated list of ports the webserver should bind
  to. Defaults to `80` and `443` but you can add additional ports for convenience, i.e. `8080`
  or `8000`. This makes the webserver reachable through the same ports as they are via docker
  port mapping and could ease working with i.e. 404-handling, direct mail fetching, solr indexing. See below for an example.

## Using

To access the web-server, make sure you have a DNS entry in your local `/etc/hosts`
or local DNS server:

For `docker-machine`:
```
192.168.99.100 my-app.vm
```

For Docker for Mac or locally on Linux:
```
127.0.0.1 my-app.vm
```

Then you can access the web-server:

* http://my-app.vm:8080/
* https://my-app.vm:8443/

### Ports and hostname

You can also make the other containers access it with the same hostname and port.
Sample `docker-compose.yml` for that:

```
services:
  web:
    image: croneu/phpapp-web:apache-2.4
    ports:
      - "8080:80"
      - "8443:443"
    volumes:
      - app:/app
    environment:
      WEB_PORTS_HTTP: '8080 80'
      WEB_PORTS_HTTPS: '8443 43'
    networks:
      default:
        aliases:
          - my-app.vm
```

This way you can reach `http://my-app.vm:8080` from outside and also from inside docker
(other containers).

### SSL certificate

Generate a SSL certificate with `mkcert` and configure it in your `.env`:
```
mkcert my-app.vm
( echo 'SSL_CRT="' ; cat my-app.vm.pem; echo '"' ; echo 'SSL_KEY="' ; cat my-app.vm-key.pem ; echo '"' ) >> .env
```

Your `.env` should then contain something like:

```
SSL_CRT="
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
"

SSL_KEY="
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
"
```

----

## Docker Image Development

Build is triggered automatically via Github Actions.

To create them locally for testing purposes (and load created images to your docker):

```
make build BUILDX_OPTIONS=--load PLATFORMS=linux/amd64
```

## MIT Licence

See the [LICENSE](LICENSE) file.

## Author

Ernesto Baschny, [cron IT GmbH](https://www.cron.eu)