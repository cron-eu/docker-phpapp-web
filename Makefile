
PLATFORMS=linux/arm64/v8,linux/amd64

# Defaults:
HTTPD_VERSION=2.4

#BUILDX_OPTIONS=--push
DOCKER_CACHE=--cache-from "type=local,src=.buildx-cache" --cache-to "type=local,dest=.buildx-cache"

build:
	docker buildx build $(DOCKER_CACHE) $(BUILDX_OPTIONS) \
		--platform $(PLATFORMS) \
		--tag croneu/phpapp-web:apache-$(HTTPD_VERSION) \
		.
