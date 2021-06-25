NS ?= j3ff
VERSION ?= $(shell git rev-parse --short HEAD)
IMAGE_NAME := nt-server

.PHONY: build push run

build:
	docker build $(EXTRA_BUILD_ARGS) -t $(NS)/$(IMAGE_NAME):latest -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

push: build
	docker push $(NS)/$(IMAGE_NAME):latest
	docker push $(NS)/$(IMAGE_NAME):$(VERSION)

run:
	docker run -it -v $(CURDIR)/data:/data -p 1735:1735  --name=$(IMAGE_NAME) $(NS)/$(IMAGE_NAME)
