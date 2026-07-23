# Makefile for Blue Archive Linux

ISO_DIR = src/out
ISO_FILE = $(shell ls $(ISO_DIR)/*.iso 2>/dev/null | sort -t. -k2,4 -r | head -1)
DISK = bal.qcow2

.PHONY: all build debug clean run run-efi docker-build

all: build

build:
	@echo "Starting standard build..."
	./src/build.sh

debug:
	@echo "Starting debug build (no compression)..."
	./src/build.sh --debug

clean:
	@echo "Cleaning build artifacts..."
	sudo rm -rf src/work src/out

run:
	@if [ -z "$(ISO_FILE)" ]; then \
		echo "Error: No ISO found in $(ISO_DIR). Run 'make build' first." >&2; \
		exit 1; \
	fi
	./run.sh

run-efi:
	@if [ -z "$(ISO_FILE)" ]; then \
		echo "Error: No ISO found in $(ISO_DIR). Run 'make build' first." >&2; \
		exit 1; \
	fi
	./run.sh --efi

docker-build:
	@echo "Building Docker image..."
	docker build -t blue-archive-linux .
	@echo "Running build inside Docker container..."
	docker run --privileged --rm -v $(PWD):/repo blue-archive-linux
