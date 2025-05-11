import re
import json
from pathlib import Path
import statistics

class BenchmarkAnalyzer:
    def __init__(self, native_dir="results/host", vm_dir="results/vm"):
        self.native_dir = Path(native_dir)
        self.vm_dir = Path(vm_dir)
        
    def parse_sysbench(self, log_path):
        metrics = {}
        with open(log_path) as f:
            content = f.read()
            metrics['events_per_sec'] = float(
                re.search(r'events per second:\s+(\d+\.\d+)', content).group(1))
            latency_matches = re.findall(r'latency \(ms\):\s+min:\s+(\d+\.\d+).+max:\s+(\d+\.\d+)', content)
            metrics['latency_min'] = float(latency_matches[0][0])
            metrics['latency_max'] = float(latency_matches[0][1])
        return metrics

    def parse_fio(self, log_path):
        with open(log_path) as f:
            data = json.load(f)
        job = data['jobs'][0]
        return {
            'read_bw': job['read']['bw'],
            'read_iops': job['read']['iops'],
            'write_bw': job['write']['bw'],
            'write_iops': job['write']['iops'],
            'lat_99th': job['read']['lat_ns']['percentile']['99.000000']
        }

    def compare_results(self):
        native_metrics = self._gather_metrics(self.native_dir)
        vm_metrics = self._gather_metrics(self.vm_dir)
        
        print("\nPerformance Comparison: Native vs Virtualized")
        print(f"{'Metric':<25} | {'Native':<10} | {'VM':<10} | {'Delta (%)':<10}")
        print("-"*65)
        for key in native_metrics:
            native_val = native_metrics[key]
            vm_val = vm_metrics.get(key, 0)
            delta = ((vm_val - native_val) / native_val) * 100
            print(f"{key:<25} | {native_val:>10.2f} | {vm_val:>10.2f} | {delta:>+10.2f}")

    def _gather_metrics(self, directory):
        return {
            **self.parse_sysbench(directory / "cpu_native.log"),
            **self.parse_fio(directory / "io_native.log")
        }

if __name__ == "__main__":
    analyzer = BenchmarkAnalyzer()
    analyzer.compare_results()
