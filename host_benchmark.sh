#!/bin/bash
# Comprehensive host machine benchmarking script
# Usage: ./host_benchmark.sh <run_id>

set -eo pipefail

RUN_ID=${1:-native}
RESULTS_DIR="results/host"
THREADS=$(nproc)
TEST_DURATION=60
FIO_SIZE="4G"
SYSBENCH_PRIME=20000

mkdir -p "${RESULTS_DIR}"

# CPU Profiling
echo "[${RUN_ID}] Starting CPU profiling..."
sysbench cpu --threads=${THREADS} --time=${TEST_DURATION} \
    --cpu-max-prime=${SYSBENCH_PRIME} run \
    > "${RESULTS_DIR}/cpu_${RUN_ID}.log"

# Memory Latency
echo "[${RUN_ID}] Measuring memory latency..."
sysbench memory --memory-block-size=4K --memory-total-size=100G \
    --memory-oper=read --memory-access-mode=rnd run \
    > "${RESULTS_DIR}/mem_${RUN_ID}.log"

# I/O Subsystem Analysis
echo "[${RUN_ID}] Starting storage subsystem analysis..."
fio --name=storage_test --directory=/tmp --size=${FIO_SIZE} \
    --rw=randrw --bs=4k --ioengine=libaio --iodepth=64 \
    --runtime=${TEST_DURATION} --time_based --direct=1 \
    --output="${RESULTS_DIR}/io_${RUN_ID}.log" \
    --output-format=json

# Hardware Performance Counters
echo "[${RUN_ID}] Collecting CPU performance counters..."
perf stat -e cycles,instructions,cache-misses,cache-references \
    -a --delay=1000 -o "${RESULTS_DIR}/perf_${RUN_ID}.log" \
    sleep ${TEST_DURATION} &

# Scheduling Latency Tracing
echo "[${RUN_ID}] Tracing scheduler behavior..."
trace-cmd record -e sched:sched_switch -e sched:sched_wakeup \
    -o "${RESULTS_DIR}/trace_${RUN_ID}.dat" sleep ${TEST_DURATION} >/dev/null 2>&1

wait
echo "[${RUN_ID}] Benchmarking complete. Results in ${RESULTS_DIR}/"
