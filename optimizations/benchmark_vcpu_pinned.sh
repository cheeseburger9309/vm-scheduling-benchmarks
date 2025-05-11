#!/bin/bash
# Benchmark with vCPU pinning optimization
# Usage: ./benchmark_vcpu_pinned.sh <vm_name> <host_cpu_list>

VM_NAME=$1
HOST_CPUS=$2
RUN_ID="vcpu_pinned"
RESULTS_DIR="results/optimized"

virsh vcpupin $VM_NAME --live $(virsh vcpulist $VM_NAME | awk '/^ [0-9]/{print $1}') $HOST_CPUS

mkdir -p "${RESULTS_DIR}"

# Pinned CPU Benchmark
taskset -c ${HOST_CPUS} sysbench cpu --threads=$(echo $HOST_CPUS | tr -cd ',' | wc -c) \
    --time=60 --cpu-max-prime=50000 run > "${RESULTS_DIR}/cpu_${RUN_ID}.log"

# Pinned I/O Benchmark
taskset -c ${HOST_CPUS} fio --name=pinned_io --rw=randread --bs=4k --direct=1 \
    --ioengine=libaio --iodepth=64 --runtime=60 --output="${RESULTS_DIR}/io_${RUN_ID}.log"

echo "vCPU pinned benchmarking complete. Results in ${RESULTS_DIR}/"
