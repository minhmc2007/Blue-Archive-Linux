FROM archlinux:latest

# Install archiso and base-devel for building
RUN pacman -Syu --noconfirm archiso base-devel

# Set the working directory
WORKDIR /repo

# Run the build script by default
# Note: Container must be run with --privileged for mkarchiso to work
CMD ["./src/build.sh"]
