#!/bin/bash

# Configuration
VM_NAME="win10"
ISO_PATH="/path/to/windows.iso"
VIRTIO_ISO="/path/to/virtio-win.iso"
DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
RAM_MB=4096
VCPUS=2
DISK_SIZE="60G"

# Check if VM already exists
VM_EXISTS=$(virsh list --all --name | grep -w $VM_NAME)

if [ -z "$VM_EXISTS" ]; then
    echo "[*] VM not found. Creating and installing..."

    # Create disk if it doesn't exist
    if [ ! -f "$DISK_PATH" ]; then
        echo "[*] Creating virtual disk..."
        qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
    fi

    # Install VM using virt-install
    virt-install \
      --name "$VM_NAME" \
      --os-variant win10 \
      --ram "$RAM_MB" \
      --vcpus "$VCPUS" \
      --cpu host \
      --disk path="$DISK_PATH",format=qcow2,bus=virtio \
      --cdrom "$ISO_PATH" \
      --disk path="$VIRTIO_ISO",device=cdrom \
      --network network=default,model=virtio \
      --graphics spice \
      --boot cdrom,hd \
      --noautoconsole

    echo "[✔] Installation launched. Use a SPICE client like 'remote-viewer' to view it."
else
    echo "[*] VM already exists. Launching..."
    virsh start "$VM_NAME"
    sleep 2
    echo "[✔] Connecting via SPICE viewer..."
    remote-viewer spice://localhost:5900
fi

