
# Profiling & Analysis of Scheduling in Vanilla Processes vs Virtual Machines (QEMU/KVM)

**CS 594 Project – Sai Kasyap Jannabhatla**  
*May 2025*



## Overview

This repository contains scripts, configurations, and analysis tools for benchmarking and optimizing scheduling performance in native Linux processes versus QEMU/KVM virtual machines.

The project automates CPU and I/O workload benchmarking, collects key metrics (IPC, latency, I/O bandwidth, context switches), and implements advanced optimizations including vCPU pinning, VirtIO tuning, and real-time scheduling (SCHED_FIFO). Results and analysis offer insights into the overheads of nested scheduling and demonstrate how targeted tuning can significantly narrow the performance gap between virtualized and native workloads.

---

## Table of Contents

- [Motivation & Objectives](#motivation--objectives)
- [Repository Structure](#repository-structure)
- [Benchmarking Setup](#benchmarking-setup)
- [How to Use](#how-to-use)
- [Optimization Strategies](#optimization-strategies)
- [Metrics & Analysis](#metrics--analysis)
- [Findings & Results](#findings--results)
- [Challenges & Limitations](#challenges--limitations)
- [References](#references)

---

## Motivation & Objectives

- **Nested Scheduling Overhead:** Understand the interplay between host and guest schedulers in VMs.
- **Performance Metrics:** IPC, latency, I/O bandwidth, context switches.
- **Goal:** Quantify inefficiencies, propose and validate optimizations to narrow the native-VM performance gap.

---

## Repository Structure

```
.
├── host_benchmark.sh            # Native (host) benchmarking script
├── vm_benchmark.sh              # VM benchmarking script
├── analyze_results.py           # Python analysis tool
├── optimizations/
│   ├── benchmark_vcpu_pinned.sh     # vCPU pinning benchmarking
│   ├── benchmark_virtio_tuned.xml   # VirtIO-optimized VM config
│   └── benchmark_sched_fifo.sh      # SCHED_FIFO real-time benchmarking
└── results/
    ├── host/
    ├── vm/
    └── optimized/
```

---

## Benchmarking Setup

- **CPU Benchmark:** Uses `sysbench` to stress-test CPU with multiple threads.
- **I/O Benchmark:** Uses `fio` for random read/write workloads.
- **Performance Counters:** Uses `perf stat` to collect IPC, cycles, cache misses.
- **Scheduling Traces:** Uses `trace-cmd` to capture context switches and KVM events.

### Scripts

- `host_benchmark.sh` – Run on the native Linux host.
- `vm_benchmark.sh` – Run inside the VM.
- `analyze_results.py` – Parses benchmark outputs and generates summary tables.
- `optimizations/benchmark_vcpu_pinned.sh` – Runs benchmarks with vCPU pinning.
- `optimizations/benchmark_virtio_tuned.xml` – Sample XML for VirtIO tuning.
- `optimizations/benchmark_sched_fifo.sh` – Runs QEMU with SCHED_FIFO real-time scheduling.

---

## How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/YOURUSERNAME/vm-scheduling-benchmarks.git
cd vm-scheduling-benchmarks
```

### 2. Run Benchmarks

#### On Host

```bash
bash host_benchmark.sh
```

#### Inside VM

```bash
bash vm_benchmark.sh
```

#### With Optimizations

- **vCPU Pinning:**  
  ```bash
  bash optimizations/benchmark_vcpu_pinned.sh  
  ```
- **VirtIO Tuning:**  
  Use `benchmark_virtio_tuned.xml` as your VM definition in libvirt.
- **SCHED_FIFO:**  
  ```bash
  bash optimizations/benchmark_sched_fifo.sh 
  ```

### 3. Analyze Results

```bash
python3 analyze_results.py
```

---

## Optimization Strategies

- **vCPU Pinning:** Bind vCPUs to dedicated physical cores to reduce cache thrashing and context switches.
- **VirtIO Tuning:** Enable direct I/O and multiple I/O threads for improved disk throughput and lower latency.
- **Scheduler Hints (SCHED_FIFO):** Assign real-time priority to QEMU threads to minimize preemption and improve latency.

---

## Metrics & Analysis

Key metrics collected and analyzed:

- **IPC (Instructions Per Cycle):** Measures CPU efficiency.
- **CPU Time:** Total execution time.
- **I/O Bandwidth:** Data throughput (KB/s).
- **95th Percentile Latency:** High-percentile I/O response time.
- **Context Switches:** Number of CPU task switches.
- **LLC Cache Misses:** Last-level cache misses (from `perf`).
- **VM Exits:** Transitions between guest and host (from `perf kvm`).

The `analyze_results.py` script parses logs and generates summary tables for easy comparison.

---

## Findings & Results

- **Baseline:**  
  - IPC dropped by 48% in VMs vs native.
  - Latency increased by 7.4x.
  - Context switches increased by 14.8x.
- **Optimizations:**  
  - vCPU pinning improved IPC by 13%, reduced latency by 20%, and cut context switches by 27%.
  - VirtIO tuning increased I/O bandwidth by 14% and reduced latency by 17%.
  - SCHED_FIFO real-time scheduling further improved IPC and reduced context switches by 34%.

| Policy      | IPC  | Latency (ms) | Context Switches | Notes                        |
|:-----------:|:----:|:------------:|:----------------:|:-----------------------------|
| SCHED_FIFO  | 1.45 | 54           | 987              | Best for latency-sensitive VMs|
| SCHED_RR    | 1.38 | 62           | 1124             | Slightly worse than FIFO      |
| SCHED_OTHER | 1.12 | 89           | 2109             | Default (worst for VMs)       |

---

## Challenges & Limitations

- **Nested Virtualization:** Experiments ran inside VirtualBox, adding extra overhead.
- **Hardware Constraints:** Limited CPU cores and RAM.
- **Tooling Gaps:** Some profiling tools limited in guest VMs.

Absolute numbers may vary on other hardware, but relative trends and optimization effects remain valid.

---

## References

- [Red Hat KVM Optimization Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/assembly_performance-tuning-for-virtual-machines_configuring-and-managing-virtualization)
- [Linux Kernel Documentation: Scheduling](https://www.kernel.org/doc/html/latest/scheduler/index.html)
- [QEMU Documentation](https://wiki.qemu.org/Main_Page)
- [fio Documentation](https://fio.readthedocs.io/en/latest/)
- [sysbench Documentation](https://github.com/akopytov/sysbench)
- [perf Documentation](https://perf.wiki.kernel.org/index.php/Main_Page)

---

---

## Author

Sai Kasyap Jannabhatla  
CS 594 Project, 2025

---

*For questions or collaboration, please open an issue or contact me via GitHub.*

---
