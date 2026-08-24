# MoonBit FactoryGraph

[![CI](https://github.com/Bobojy00/moonbit-factory-graph/actions/workflows/ci.yml/badge.svg)](https://github.com/Bobojy00/moonbit-factory-graph/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-stable-purple.svg)](https://www.moonbitlang.com)

MoonBit FactoryGraph is an industrial topology and digital-twin engine for modeling production assets, multi-layer flows, failure propagation, capacity constraints, and topology change risk.

It is designed for manufacturing engineering tools that need deterministic, inspectable results rather than a generic graph abstraction. A single model can represent material, control, energy, safety, pneumatic, coolant, and telemetry connections, then run routing, resilience, outage, capacity, export, and optimization analyses over those layers.

It has no network or database dependency. Inputs are constructed through the typed MoonBit API, which makes examples, tests, and CI runs reproducible on native and WebAssembly targets.

## Core capabilities

- **Industrial domain model**: workstations, machines, conveyors, buffers, sensors, power sources, PLCs, safety gates, robots, inspection assets, and other manufacturing entities.
- **Multi-layer topology**: material, control, energy, safety interlock, pneumatic, coolant, and telemetry flows with per-edge bandwidth, latency, medium, protocol, and safety metadata.
- **Graph algorithms**: multi-criteria Dijkstra, K-shortest paths, disjoint paths, strongly connected components, topological scheduling, centrality, biconnectivity/SPOF, and max-flow.
- **Operational analysis**: bottleneck and KPI reports, topology health summaries, material capacity utilization, safety audit, redundancy, and batch outage scenarios.
- **Optimization and change control**: line balancing, failover routing, buffer tuning, energy startup scheduling, topology diffing, and migration risk scoring.
- **Interoperability**: Graphviz DOT, Mermaid, PlantUML, JSON, CSV, and Markdown audit reports.
- **Industrial presets**: automotive, lithium battery, semiconductor packaging, and continuous chemical-processing examples.

## Quick start

### Run the repository

Install the MoonBit stable toolchain, then run:

```bash
moon check --deny-warn
moon test --target native
moon run cmd/main -- demo
```

The repository CI validates MoonBit compiler version `>= 0.10.9`, formatting, generated public interfaces, both default and native tests, and the command-line benchmark.

### Use the library

Add the package to `moon.mod`:

```toml
import {
  "Bobojy00/moonbit_factory_graph" @factory_graph,
}
```

Build and inspect a small line:

```moonbit
let plant = @factory_graph.new_builder(
  plant_name="Precision Electronics Assembly",
  takt_time_target_sec=30.0,
)
  .add_power_source("PWR-MAIN", "Substation 380V", capacity_kw=1000.0)
  .add_workstation("WS-SMT", "Surface Mount Station", cycle_time_sec=25.0)
  .add_workstation("WS-AOI", "Optical Inspection", cycle_time_sec=20.0)
  .add_buffer("BUF-WIP", "PCB Rack Buffer", capacity=200.0)
  .connect_material("WS-SMT", "WS-AOI", bandwidth=1200.0)
  .connect_material("WS-AOI", "BUF-WIP", bandwidth=1200.0)
  .connect_power_bus("PWR-MAIN", ["WS-SMT", "WS-AOI"])
  .build()

let health = @factory_graph.inspect_graph_health(plant)
let capacity = @factory_graph.analyze_material_capacity(plant)
let outage = @factory_graph.evaluate_outage_portfolio(
  plant,
  ["WS-SMT", "WS-AOI"],
)
```

The package facade in `factory_graph.mbt` covers the common workflow. Specialized algorithms and reports are also available from their `src/*` packages.

## CLI

Run the CLI with `moon run cmd/main -- <command>`:

| Command | Purpose |
| --- | --- |
| `info <preset>` | Asset, zone, power, and topology summary |
| `health <preset>` | Inspect topology completeness and active flow layers |
| `capacity <preset>` | Analyze material demand, capacity margin, and congestion |
| `analyze <preset>` | Bottleneck, SPOF, and safety analysis |
| `outage <preset> <node>` | Simulate a device outage cascade |
| `path <preset> <from> <to>` | Find a material-flow route |
| `diff <preset1> <preset2>` | Compare topology versions and risk |
| `export <preset> <format>` | Export `dot`, `mermaid`, `puml`, `json`, `report`, or CSV |
| `optimize <preset>` | Generate line-balance and energy-startup recommendations |
| `bench` | Run reproducible graph-scaling and analysis measurements |
| `demo` | Run an end-to-end multi-plant demonstration |

Available presets are `automotive`, `battery`, `semiconductor`, and `chemical`.

## Architecture

```text
.
├── factory_graph.mbt       # Stable library facade
├── cmd/main/                # Native/Wasm command-line application
├── src/types/               # Domain enums, metadata, validation values
├── src/graph/               # Graph, nodes, edges, builder, health checks
├── src/algorithms/          # Routing, flow, connectivity, scheduling
├── src/analysis/            # KPIs, safety, capacity, outage, resilience
├── src/diff/                # Topology comparison and migration risk
├── src/optimizer/           # Balancing, failover, buffers, energy
├── src/export/              # DOT, Mermaid, PlantUML, JSON, CSV, reports
├── src/presets/             # Four realistic industrial line models
├── **/*_test.mbt            # Package-local unit and black-box tests
└── benchmarks/latest.md     # Checked-in reproducibility record
```

Each `src/*` directory is an independent MoonBit package with a focused `moon.pkg`. Public concrete types are owned by the package that defines their domain, while the root package provides ergonomic facade functions.

## Benchmarks

The CLI benchmark uses `moonbitlang/core/bench` and reports measured microseconds per operation, five samples per workload, batch size, variance, and median. It covers construction of a 1,000-node/1,997-edge topology, Dijkstra routing, biconnectivity, and combined capacity/health analysis.

Run it locally:

```bash
moon run cmd/main -- bench
```

The checked-in result is a reproducibility record, not a hardware-independent promise. See [benchmarks/latest.md](benchmarks/latest.md) for the command, toolchain, environment, and raw output captured during validation.

## Testing and quality

The test suite includes package-level unit tests, black-box facade tests, algorithm fixtures, preset construction checks, export checks, and boundary cases for empty graphs, inactive edges, zero capacity, duplicate scenarios, unknown assets, and disconnected topology.

```bash
moon fmt --check
moon check --deny-warn
moon test --target native
moon test --enable-coverage
moon coverage report -f summary
moon info
python scripts/check_moonbit_source.py --minimum 6000
```

`moon info` generates the public `.mbti` interfaces used by CI to detect accidental API drift. The source-size check counts tracked production `.mbt` lines while excluding test files and build/cache directories; it does not count documentation or generated artifacts.

## CI

`.github/workflows/ci.yml` runs on Ubuntu, macOS, and Windows. It installs the current stable MoonBit toolchain, rejects compilers older than `moonc 0.10.9`, checks formatting and warnings, verifies generated interfaces, runs default and native tests with coverage, enforces the production source-size floor, and executes the benchmark on Ubuntu.

## License

Licensed under the [Apache License 2.0](LICENSE).
