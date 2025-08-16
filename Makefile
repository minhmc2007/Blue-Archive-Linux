# Makefile for building Blue Archive Linux ISO inside a Docker container
# This Makefile is self-contained and does not require any external shell scripts.
# Plz note that if you run sudo make so the iso will be inside /root
# --- Configuration ---
# Load the build configuration. It can be set via 'make menuconfig'.
-include .build_config

# If BUILD_TYPE is not set by the config file, default to 'debug'.
BUILD_TYPE ?= debug

DOCKER_IMAGE   := debian:stable-slim
CONTAINER_NAME := blue-archive-builder

# Use the current working directory for the temporary output
ISO_OUTPUT_DIR := $(PWD)/iso_output
FINAL_ISO_NAME := Blue_Archive_Linux_amd64-$(BUILD_TYPE).iso

# Define the multi-line shell command to be executed inside Docker.
# Using '$$' escapes the dollar sign for make, passing a single '$' to the shell.
# We use 'set -e' to make the script exit immediately if any command fails.
DOCKER_COMMAND = \
	set -e; \
	\
	echo "--- [Docker] Installing dependencies: live-build, git, etc. ---"; \
	apt-get update >/dev/null && apt-get install -y sudo live-build git >/dev/null; \
	\
	echo "--- [Docker] Cloning repository... ---"; \
	git clone https://github.com/minhmc2007/Blue-Archive-Linux /build_dir; \
	cd /build_dir; \
	\
	if [ "$(BUILD_TYPE)" = "stable" ]; then \
		echo "--- [Docker] Entering STABLE build directory... ---"; \
		cd blue_archive_linux/stable; \
	else \
		echo "--- [Docker] Entering DEBUG build directory... ---"; \
		cd blue_archive_linux/debug; \
	fi; \
	\
	echo "--- [Docker] Executing build.sh... This is the longest step. ---"; \
	./build.sh; \
	\
	echo "--- [Docker] Moving generated ISO to output volume... ---"; \
	mv Blue_Archive_Linux_amd64*.iso /output/final.iso; \
	\
	echo "--- [Docker] Build process finished successfully. Exiting container. ---";

# --- Targets ---
.PHONY: all build menuconfig clean help

# Default target
all: build

# The interactive configuration target
menuconfig:
	@echo "=========================================================="
	@echo "  Blue Archive Linux Build Configuration"
	@echo "=========================================================="
	@echo "  Current Build Type: $(BUILD_TYPE)"
	@echo ""
	@echo "  Select the build type you want to configure:"
	@echo "    1. Stable (Recommended for general use)"
	@echo "    2. Debug  (For development and testing)"
	@echo ""
	@read -p "  Enter your choice [1-2]: " choice; \
	case "$$choice" in \
		1) \
			echo "BUILD_TYPE := stable" > .build_config; \
			echo "==> Configuration set to: stable"; \
			;; \
		2) \
			echo "BUILD_TYPE := debug" > .build_config; \
			echo "==> Configuration set to: debug"; \
			;; \
		*) \
			echo "!!! Invalid choice. No changes were made."; \
			;; \
	esac
	@echo "=========================================================="
	@echo "Run 'make' to start the build with the new configuration."


# The main build process


# The main build process
build:
	@echo "=========================================================="
	@echo ">>> Starting Blue Archive Linux ISO build"
	@echo ">>> Build Type: $(BUILD_TYPE)"
	@echo "=========================================================="

	# 1. Prepare the host output directory
	@echo "\n[STEP 1/4] Preparing output directory..."
	rm -rf $(ISO_OUTPUT_DIR)
	mkdir -p $(ISO_OUTPUT_DIR)

	# 2. Run the Docker container and execute the build commands directly.
	@echo "\n[STEP 2/4] Pulling Docker image and starting the build process..."
	@echo "         This will take a very long time. Please be patient."
	docker run \
		--rm \
		--name $(CONTAINER_NAME) \
		--privileged \
		-v "$(ISO_OUTPUT_DIR):/output" \
		$(DOCKER_IMAGE) \
		bash -c '$(DOCKER_COMMAND)'



	# 3. Copy the final ISO from the output directory to the home directory.
	@echo "\n[STEP 3/4] Copying generated ISO to your home directory (~/)..."
	@if [ ! -f "$(ISO_OUTPUT_DIR)/final.iso" ]; then \
		echo ""; \
		echo "!!! BUILD FAILED: No ISO file was found in the output directory." ; \
		echo "!!! Please check the logs above for errors." ; \
		exit 1; \
	fi
	mv $(ISO_OUTPUT_DIR)/final.iso ~/$(FINAL_ISO_NAME)
	@echo ">>> Success! ISO moved to: ~/$(FINAL_ISO_NAME)"

	# 4. Clean up the temporary build directory on the host.
	@echo "\n[STEP 4/4] Cleaning up temporary files..."
	rm -rf $(ISO_OUTPUT_DIR)
	@echo "\n=========================================================="
	@echo ">>> Build complete!"
	@echo "=========================================================="

# Target for cleaning up all generated files
clean:
	@echo ">>> Cleaning up generated ISOs from home directory..."
	rm -f ~/blue-archive-debug.iso ~/blue-archive-stable.iso
	@echo ">>> Cleaning up temporary build directory..."
	rm -rf $(ISO_OUTPUT_DIR)
	@echo ">>> Cleaning up build configuration file..."
	rm -f .build_config
	@echo ">>> Cleanup complete."

# Help target to show usage
help:
	@echo "Usage:"
	@echo "  make menuconfig - Interactively choose between 'stable' and 'debug' builds."
	@echo "                    Your choice is saved in a '.build_config' file."
	@echo ""
	@echo "  make            - Builds the ISO using the type set in '.build_config'."
	@echo "  make build      - (Defaults to 'debug' if menuconfig has not been run)."
	@echo ""
	@echo "  make clean      - Removes generated ISOs, temporary directories, and the"
	@echo "                    .build_config file."
