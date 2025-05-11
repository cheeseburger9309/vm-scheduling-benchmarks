#!/bin/bash
# Real-time scheduled benchmarking
# Usage: ./benchmark_sched_fifo.sh <vm_image>

KVM_IMAGE=$1
RUN_ID="sched_fifo"
RESULTS_DIR="results/optimized"
RT_PRIORITY=1  # SCHED_FIFO priority

mkdir -p "${RESULTS_DIR}"

# Start QEMU with real-time scheduling
chrt -f ${RT_PRIORITY} qemu-system-x86_64 -enable-kvm -cpu host \
    -smp 4 -m 8G -drive file=${KVM_IMAGE},format=qcow2,cache=none \
    -object iothread,id=io1 -device virtio-blk-pci,iothread=io1 &

# Allow VM to boot
sleep 30  

# Run benchmarks inside VM via SSH
ssh vm-host "sysbench cpu --threads=4 --time=60 run" > "${RESULTS_DIR}/cpu_${RUN_ID}.log"
ssh vm-host "fio --name=rt_io --rw=randwrite --bs=4k --direct=1 \
    --ioengine=libaio --iodepth=32 --runtime=60" > "${RESULTS_DIR}/io_${RUN_ID}.log"

# Cleanup
virsh destroy $(virsh list --name)

echo "Real-time scheduled benchmarking complete. Results in ${RESULTS_DIR}/"
