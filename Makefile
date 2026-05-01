# Makefile for Blue Archive Linux

ISO_DIR = src/out
# Find the first .iso file in the output directory
ISO_FILE = $(shell ls $(ISO_DIR)/*.iso 2>/dev/null | head -n 1)

# Memory: 2/3 of available memory in MB
RAM = $(shell free -m | awk '/^Mem:/ {print int($$7 * 2 / 3)}')

# KVM acceleration if available
KVM = $(shell [ -e /dev/kvm ] && echo "-enable-kvm" || echo "")

# QEMU graphics acceleration (virtio)
# Using virtio-vga-gl for best 3D acceleration
QEMU_FLAGS = -m $(RAM) $(KVM) -device virtio-vga-gl -display default,gl=on -cdrom $(ISO_FILE)

.PHONY: build debug clean run docker-build

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
		echo "Error: No ISO found in $(ISO_DIR). Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Running ISO: $(ISO_FILE) with $(RAM)MB RAM..."
	qemu-system-x86_64 $(QEMU_FLAGS)

docker-build:
	@echo "Building Docker image..."
	docker build -t blue-archive-linux .
	@echo "Running build inside Docker container..."
	docker run --privileged --rm -v $(PWD):/repo blue-archive-linux
