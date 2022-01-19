# cron PHP application docker images - Webserver

## Abstract

Part of the `docker-phpapp` image suite.

See https://github.com/cron-eu/docker-phpapp-php/README.md for a complete explanation.

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

* `SSL_CRT`, `SSL_KEY`: Add your SSL certificate and private key here (the PEM strings,
  not the filenames) to enable Apache with SSL support. It will automatically listen to port "8443"

## Using

To access the web-server, make sure you have a DNS entry in your local `/etc/hosts`
or local DNS server:

`/etc/hosts` for `docker-machine`:
```
192.168.99.100 my-app.vm
```

`/etc/hosts` for Docker for Mac or locally on Linux:
```
127.0.0.1 my-app.vm
```

Then you can access the web-server:

* http://my-app.vm:8080/
* https://my-app.vm:8443/

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