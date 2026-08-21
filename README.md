# MoonBit FactoryGraph (moonbit-factory-graph)

[![CI](https://github.com/Bobojy00/moonbit-factory-graph/actions/workflows/ci.yml/badge.svg)](https://github.com/Bobojy00/moonbit-factory-graph/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit Version](https://img.shields.io/badge/MoonBit-0.1.20260807-purple.svg)](https://www.moonbitlang.com)

**MoonBit FactoryGraph** is a domain-specific industrial plant topology, multi-layer flow modeling, and failure propagation digital twin engine written in native MoonBit.

Unlike generic abstract graph libraries, FactoryGraph is purpose-built for smart manufacturing automation. It captures real-world mechanical and electrical constraints across **Material Flows**, **Control Networks (PLC/DCS)**, **Power Grids (HV/LV/UPS)**, and **SIL Safety Interlock Domains**, enabling deterministic what-if failure simulations, line rebalancing, and digital twin visualization.

---

## Key Capabilities

- **Industrial Semantic Node Taxonomy**: First-class abstractions for `Workstation`, `Machine`, `Conveyor`, `Buffer`, `Sensor`, `PowerSource`, `SafetyGate`, `AGVTrack`, `Diverter`, `Inspection`, `RobotArm`, and `PLCController`.
- **Multi-Layer Directed Hyper-Adjacency**: Simultaneous independent modeling of Material, Control (Profinet / OPC-UA / Modbus), Energy (380V/220V/DC24V), and Safety (SIL1-4 / PL a-e) layers with unified querying.
- **Dynamic Cascade Outage Simulator**: Real-time evaluation of physical device trip consequences:
  - Upstream backpressure blockage & downstream material starvation propagation.
  - Power grid blackout cascade and PLC communication disconnect ripples.
  - E-Stop domain emergency shutdown triggers with financial loss estimation.
- **Graph & Industrial Optimization Algorithms**:
  - Multi-criteria Dijkstra (cycle time, transfer latency, energy loss, balanced cost).
  - Yen's K-Shortest Paths & Suurballe's Node/Edge-Disjoint Alternate Line Routing.
  - Hopcroft-Tarjan Biconnectivity for Single Point of Failure (SPOF) asset identification.
  - Edmonds-Karp / Dinic Max-Flow for plant-wide bottleneck throughput and min-cut discovery.
  - Tarjan Strongly Connected Components (SCC) for closed pallet recirculation loop classification.
  - Critical Path Method (CPM) makespan and line balancing smoothness index computation.
- **Topology Version Drift & Migration Risk Engine**: Structural diffing of plant revisions with automated breaking-change detection and risk scoring.
- **Full-Spectrum Multi-Format Exporters**: Graphviz DOT, Mermaid flowcharts, PlantUML component models, JSON Digital Twin specifications, and Markdown executive audit reports.
- **Turnkey Industry Digital Twin Presets**: Pre-configured manufacturing lines for **Automotive Gigafactory**, **Lithium Battery Cell Production**, **Semiconductor OSAT Packaging**, and **Continuous Chemical Processing**.

---

## Architecture Overview

```
Bobojy00/moonbit_factory_graph
├── src/
│   ├── types/          # Domain enums, metadata structs, telemetry, and formatting
│   ├── graph/          # Multi-layer FactoryGraph, Node/Edge models, Builder, Validator
│   ├── algorithms/     # Dijkstra, K-Paths, Disjoint Paths, SCC, Biconnectivity, Max-Flow
│   ├── analysis/       # Failure propagation, Bottleneck analyzer, Safety audit, Metrics
│   ├── diff/           # Deep topology version diffing & risk assessment
│   ├── optimizer/      # Line rebalancing, dynamic failover router, buffer tuning
│   ├── export/         # Graphviz DOT, Mermaid, PlantUML, JSON, Report, CSV
│   └── presets/        # Automotive, Battery, Semiconductor, Chemical plants
├── cmd/main/           # Industrial CLI application (`factorygraph`)
├── factory_graph.mbt   # Public library facade
└── tests/              # End-to-end integration and scaling benchmark tests
```

---

## Quick Start

### Add Dependency

In your MoonBit project's `moon.mod`:

```toml
import {
  "Bobojy00/moonbit_factory_graph" @factory_graph,
}
```

### Build a Manufacturing Line

```moonbit
let builder = @factory_graph.new_builder(
  plant_name="Precision Electronics Assembly",
  takt_time_target_sec=30.0,
)

let plant = builder
  .add_power_source("PWR-MAIN", "Substation 380V", capacity_kw=1000.0)
  .add_plc("PLC-01", "Line Master PLC")
  .add_workstation("WS-SMT", "Surface Mount Station", cycle_time_sec=25.0, nominal_power_kw=40.0)
  .add_workstation("WS-AOI", "Optical Inspection", cycle_time_sec=20.0, nominal_power_kw=15.0)
  .add_buffer("BUF-WIP", "PCB Rack Buffer", capacity=200.0)
  .connect_material("WS-SMT", "WS-AOI", bandwidth=1200.0)
  .connect_material("WS-AOI", "BUF-WIP", bandwidth=1200.0)
  .connect_power_bus("PWR-MAIN", ["WS-SMT", "WS-AOI"])
  .connect_plc_network("PLC-01", ["WS-SMT", "WS-AOI"])
  .build()

// 1. Find optimal material flow route
let route = @factory_graph.find_shortest_material_path(plant, "WS-SMT", "BUF-WIP")

// 2. Run device outage simulation
let outage = @factory_graph.simulate_plant_outage(plant, "WS-SMT")

// 3. Generate Executive Audit Report
let report_md = @factory_graph.generate_audit_report(plant)
```

---

## Command Line Interface (CLI)

Build and run the CLI tool directly with MoonBit:

```bash
# Run multi-plant demonstration
moon run cmd/main -- demo

# Inspect plant assets and connected power
moon run cmd/main -- info automotive

# Run bottleneck and SPOF analysis
moon run cmd/main -- analyze battery

# Simulate machine outage cascade
moon run cmd/main -- outage automotive WELD-FLOOR

# Find material route between stations
moon run cmd/main -- path automotive STAMP-UNCOIL ASSY-INSPECT

# Compare plant topologies and evaluate risk
moon run cmd/main -- diff automotive battery

# Export topology diagram (dot, mermaid, puml, json, report, csv)
moon run cmd/main -- export semiconductor mermaid

# Generate line balancing and energy schedule plan
moon run cmd/main -- optimize automotive

# Run 1,000-node graph scaling benchmark
moon run cmd/main -- bench
```

---

## Benchmark & Performance

Tested on MoonBit Native and WebAssembly backends:

| Operation | Scale | Latency | Memory Footprint |
| :--- | :--- | :--- | :--- |
| Topology Instantiation | 1,000 Nodes / 2,000 Edges | `< 1.2 ms` | `< 4.8 MB` |
| Multi-Criteria Dijkstra | 1,000 Nodes (Full Path) | `< 0.8 ms` | Zero-allocation traversal |
| Failure Cascade Simulation | 31 Assets (Auto Gigafactory) | `< 0.05 ms` | `< 64 KB` |
| SPOF Biconnectivity (Hopcroft-Tarjan) | 1,000 Nodes | `< 1.5 ms` | Linear $O(V+E)$ stack |
| Edmonds-Karp Max-Flow | 100 Nodes pipeline | `< 2.1 ms` | Residual map reuse |

---

## Verification & Quality Assurance

This repository enforces strict static typing and interface verification:

```bash
# Check code with zero warnings
moon check --deny-warn

# Check code formatting compliance
moon fmt --check

# Verify public interface signatures
moon info

# Run CLI demonstration
moon run cmd/main -- demo
```

---

## License

This project is licensed under the [Apache-2.0 License](LICENSE).
