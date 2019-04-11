default: container

.PHONY: container
container:
	docker build --tag gcr.io/kubtest-237215/iot-rest:$(shell git rev-parse HEAD) .
