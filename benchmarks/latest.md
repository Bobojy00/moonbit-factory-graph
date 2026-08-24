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
| Build 1,000 nodes / 1,997 edges | 8,058.328 | 7,959.991 | 7,729.349 | 8,564.507 | 11 |
| Dijkstra, 1,000 nodes | 24,747.347 | 24,523.725 | 23,958.155 | 26,344.830 | 4 |
| Biconnectivity/SPOF, 1,000 nodes | 1,733.062 | 1,732.844 | 1,707.451 | 1,759.045 | 55 |
| Capacity + health report | 1,308.253 | 1,333.842 | 1,221.035 | 1,367.329 | 81 |

The repository CI requires a stable compiler of at least `moonc 0.10.9`; the record above is a local native run and is not presented as a CI result.
