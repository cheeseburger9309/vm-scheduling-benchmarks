#!/bin/bash
# Virtual machine benchmarking script with VM exit detection
# Usage: ./vm_benchmark.sh <run_id>

set -eo pipefail

RUN_ID=${1:-vm}
RESULTS_DIR="results/vm"
THREADS=$(nproc)
TEST_DURATION=60
FIO_SIZE="2G"  # Reduced for VM environments

mkdir -p "${RESULTS_DIR}"

# CPU Analysis with VM Exit Awareness
echo "[${RUN_ID}] Starting CPU profiling with exit tracking..."
sysbench cpu --threads=${THREADS} --time=${TEST_DURATION} \
    --cpu-max-prime=20000 run \
    > "${RESULTS_DIR}/cpu_${RUN_ID}.log" &
SYSCPU_PID=$!

# Simultaneous VM Exit Monitoring
sudo perf kvm --host stat record -p ${SYSCPU_PID} \
    -e 'kvm:*' -o "${RESULTS_DIR}/kvm_${RUN_ID}.data" >/dev/null 2>&1 &

# Storage Analysis with VirtIO Awareness
echo "[${RUN_ID}] Starting storage subsystem analysis..."
fio --name=vm_storage --size=${FIO_SIZE} --rw=randrw --bs=4k \
    --ioengine=libaio --iodepth=32 --runtime=${TEST_DURATION} \
    --time_based --direct=1 --output="${RESULTS_DIR}/io_${RUN_ID}.log" \
    --output-format=json

wait
echo "[${RUN_ID}] VM benchmarking complete. Results in ${RESULTS_DIR}/"
