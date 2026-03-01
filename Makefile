.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  build - Build the Docker image"
	@echo "  run - Run the Docker container"
	@echo "  stop - Stop the Docker container"
	@echo "  dev - Run the docsify serve"

.PHONY: build
build:
	docker build -t kingnand/blog .

.PHONY: run
run:
	docker run -itp 3000:3000 --name=blog kingnand/blog

.PHONY: stop
stop:
	docker stop blog

.PHONY: dev
dev:
	@echo "Running docsify serve ./docs"
	docsify serve -o ./docs