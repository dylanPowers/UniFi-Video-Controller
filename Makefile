UVC_VERSION := 3.10.13
IMAGE_VERSION := 0
IMAGE_REGISTRY := docker-registry.home-admin.svc.k8s.dylankpowers.com

build:
	docker build \
		--pull \
		-t $(IMAGE_REGISTRY)/unifi-video-controller:$(UVC_VERSION)-$(IMAGE_VERSION) \
		.

push:
	docker push $(IMAGE_REGISTRY)/unifi-video-controller:$(UVC_VERSION)-$(IMAGE_VERSION)
	docker tag $(IMAGE_REGISTRY)/unifi-video-controller:$(UVC_VERSION)-$(IMAGE_VERSION) $(IMAGE_REGISTRY)/unifi-video-controller:$(UVC_VERSION)
	docker push $(IMAGE_REGISTRY)/unifi-video-controller:$(UVC_VERSION)

release:
	$(MAKE) build
	$(MAKE) push
