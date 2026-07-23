#!/usr/bin/env bash
set -euo pipefail

ISODIR="src/out"
DISK="bal.qcow2"
RAM="4096"
SMP="12"
EFI=0

for arg in "$@"; do
  case "$arg" in
    --efi) EFI=1 ;;
    *) echo "Usage: $0 [--efi]" >&2; exit 1 ;;
  esac
done

ISO=$(find "$ISODIR" -name '*.iso' -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
if [ -z "$ISO" ]; then
  echo "No ISO found in $ISODIR" >&2
  exit 1
fi
echo "Using: $ISO"

if [ ! -f "$DISK" ]; then
  echo "Creating 40G qcow2 disk..."
  qemu-img create -f qcow2 "$DISK" 40G
fi

EFI_OPTS=()
if [ "$EFI" -eq 1 ]; then
  OVMF_CODE="/usr/share/edk2-ovmf/OVMF_CODE.fd"
  OVMF_VARS="/usr/share/edk2-ovmf/OVMF_VARS.fd"
  if [ -f "$OVMF_CODE" ] && [ -f "$OVMF_VARS" ]; then
    EFI_OPTS=(-bios "$OVMF_CODE" -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" -drive "if=pflash,format=raw,file=$OVMF_VARS")
  else
    echo "UEFI firmware not found; install edk2-ovmf or fall back to BIOS" >&2
    exit 1
  fi
fi

qemu-system-x86_64 \
  -machine type=q35,accel=kvm \
  -cpu host \
  -smp "$SMP" \
  -m "$RAM" \
  -drive file="$DISK",format=qcow2,if=virtio \
  -cdrom "$ISO" \
  -boot order=d \
  -vga virtio \
  -display gtk,gl=on \
  -device virtio-net,netdev=net0 \
  -netdev user,id=net0 \
  "${EFI_OPTS[@]}"
