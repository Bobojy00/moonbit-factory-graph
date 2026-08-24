# Benchmark record

This file records one real local run of the repository benchmark. Values are machine- and toolchain-dependent; rerun the command below when comparing environments.

- Date: 2026-08-24
- Command: `moon run cmd/main -- bench`
- Toolchain: Moon `0.1.20260819`, moonc `0.10.9+6e6c44045`
- Target: native
- Workload: 1,000 nodes and 1,997 material edges; 5 samples per benchmark

The benchmark reports microseconds per operation. The raw summaries below were printed by `moonbitlang/core/bench`:

| Workload | Mean (µs) | Median (µs) | Min (µs) | Max (µs) | Batch size |
| --- | ---: | ---: | ---: | ---: | ---: |
| Build 1,000 nodes / 1,997 edges | 25,389.297 | 25,620.425 | 21,121.345 | 29,501.565 | 4 |
| Dijkstra, 1,000 nodes | 54,653.130 | 56,936.150 | 45,058.520 | 61,209.130 | 2 |
| Biconnectivity/SPOF, 1,000 nodes | 3,202.853 | 3,276.421 | 2,680.278 | 3,858.149 | 29 |
| Capacity + health report | 2,032.844 | 2,052.052 | 1,850.744 | 2,153.593 | 52 |

The repository CI requires a stable compiler of at least `moonc 0.10.9`; the record above is a local native run and is not presented as a CI result.
