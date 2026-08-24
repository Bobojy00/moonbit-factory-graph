///|
fn print_banner() -> Unit {
  println(
    "================================================================================",
  )
  println(
    "                MoonBit FactoryGraph - Industrial Plant Engine                  ",
  )
  println(
    "       Multi-Layer Topology, Material/Control/Energy Flow & Failure Twin        ",
  )
  println(
    "================================================================================",
  )
}

///|
fn print_help() -> Unit {
  print_banner()
  println("Usage: moon run cmd/main -- [COMMAND] [OPTIONS]")
  println("")
  println("Commands:")
  println(
    "  info     <preset>                Display plant summary, assets & power grid",
  )
  println(
    "  health   <preset>                Inspect topology completeness and flow layers",
  )
  println(
    "  capacity <preset>                Analyze material demand and edge utilization",
  )
  println(
    "  analyze  <preset>                Run bottleneck, SPOF and resilience analysis",
  )
  println(
    "  outage   <preset> <node_id>      Simulate device outage and failure cascade",
  )
  println(
    "  path     <preset> <from> <to>    Find optimal material flow routing",
  )
  println(
    "  diff     <preset1> <preset2>     Compare two topologies and compute risk",
  )
  println(
    "  export   <preset> <format>       Export plant model (dot|mermaid|puml|json|report|csv)",
  )
  println(
    "  optimize <preset>                Generate line balancing & energy schedules",
  )
  println(
    "  demo                             Run full end-to-end multi-factory demo",
  )
  println(
    "  bench                            Run high-scale graph scaling benchmark",
  )
  println("")
  println("Available Presets:")
  println("  automotive, battery, semiconductor, chemical")
}

///|
fn get_preset_graph(name : String) -> @graph.FactoryGraph? {
  match name {
    "automotive" | "auto" => Some(@lib.load_automotive_plant())
    "battery" | "bat" => Some(@lib.load_battery_plant())
    "semiconductor" | "semi" => Some(@lib.load_semiconductor_plant())
    "chemical" | "chem" => Some(@lib.load_chemical_plant())
    _ => None
  }
}

///|
fn cmd_info(preset_name : String) -> Unit {
  match get_preset_graph(preset_name) {
    None =>
      println(
        "Error: Unknown preset '" +
        preset_name +
        "'. Available: automotive, battery, semiconductor, chemical",
      )
    Some(g) => {
      let cfg = g.config()
      let kpis = @analysis.compute_plant_kpis(g)
      let zones = g.get_all_zones()
      let szones = g.get_all_safety_zones()

      println("Plant Topology Information:")
      println("  Facility Name    : " + cfg.plant_name)
      println("  Location         : " + cfg.site_location)
      println("  Model Version    : " + cfg.version)
      println(
        "  Target Takt Time : " + cfg.takt_time_target_sec.to_string() + "s",
      )
      println(
        "  Total Assets     : " +
        kpis.total_asset_count.to_string() +
        " (" +
        kpis.active_asset_count.to_string() +
        " active)",
      )
      println("  Total Edges      : " + g.edge_count().to_string())
      println(
        "  Total Connected Power: " +
        @types.format_double(kpis.total_power_demand_kw, 1) +
        " kW",
      )
      println("  Workshop Zones   : " + zones.length().to_string())
      for z in zones {
        let zn = g.get_nodes_in_zone(z)
        println("    - " + z + ": " + zn.length().to_string() + " nodes")
      }
      println("  Safety Domains   : " + szones.length().to_string())
    }
  }
}

///|
fn cmd_health(preset_name : String) -> Unit {
  match get_preset_graph(preset_name) {
    None => println("Error: Unknown preset '" + preset_name + "'")
    Some(g) => {
      let report = @graph.inspect_graph_health(g)
      println("================ Topology Health ================")
      println(
        "Assets: " +
        report.active_node_count.to_string() +
        "/" +
        report.total_node_count.to_string() +
        " active",
      )
      println(
        "Edges: " +
        report.active_edge_count.to_string() +
        "/" +
        report.total_edge_count.to_string() +
        " active",
      )
      println("Orphan nodes: " + report.orphan_node_ids.length().to_string())
      for layer in report.layer_health {
        if layer.active_edge_count > 0 || layer.inactive_edge_count > 0 {
          println(
            "  " +
            layer.flow_type.to_string() +
            ": " +
            layer.active_edge_count.to_string() +
            " active, " +
            @types.format_double(layer.total_bandwidth_units_per_hour, 1) +
            " units/h capacity",
          )
        }
      }
      for node_id in report.orphan_node_ids {
        println("  Orphan: " + node_id)
      }
    }
  }
}

///|
fn cmd_capacity(preset_name : String) -> Unit {
  match get_preset_graph(preset_name) {
    None => println("Error: Unknown preset '" + preset_name + "'")
    Some(g) => {
      let report = @analysis.analyze_material_capacity(g)
      println("================ Material Capacity ================")
      println(
        "Demand: " +
        @types.format_double(report.demand_per_hour, 1) +
        " units/hour",
      )
      println(
        "Output capacity: " +
        @types.format_double(report.output_capacity_per_hour, 1) +
        " units/hour",
      )
      println(
        "Capacity margin: " +
        @types.format_double(report.capacity_margin_percent, 1) +
        "%",
      )
      println(
        "Overloaded edges: " + report.overloaded_edge_ids.length().to_string(),
      )
      for edge_id in report.overloaded_edge_ids {
        println("  Congested: " + edge_id)
      }
      println(
        "Constrained assets: " +
        report.constrained_node_ids.length().to_string(),
      )
      for node_id in report.constrained_node_ids {
        println("  Constrained: " + node_id)
      }
    }
  }
}

///|
fn cmd_analyze(preset_name : String) -> Unit {
  match get_preset_graph(preset_name) {
    None => println("Error: Unknown preset '" + preset_name + "'")
    Some(g) => {
      let b_rep = @analysis.analyze_production_bottlenecks(g)
      let spofs = @algorithms.find_critical_spof_assets(g)
      let s_audit = @analysis.audit_plant_safety_systems(g)

      println("================ Production & Risk Analysis ================")
      println(
        "Primary Bottleneck Station : " +
        b_rep.primary_bottleneck_node_id +
        " (" +
        @types.format_double(b_rep.primary_bottleneck_cycle_time, 1) +
        "s)",
      )
      println(
        "Line Balancing Efficiency  : " +
        @types.format_double(b_rep.line_balance_efficiency_percent, 1) +
        "%",
      )
      println(
        "Max Capacity Ceiling       : " +
        @types.format_double(b_rep.max_theoretical_hourly_output, 1) +
        " units/hour",
      )
      println(
        "Single Points of Failure   : " +
        spofs.single_points_of_failure.length().to_string() +
        " assets",
      )
      for s in spofs.single_points_of_failure {
        println("  - SPOF: " + s)
      }
      println("Safety Compliance Grade    : " + s_audit.audit_status)
      println(
        "E-Stop Protection Coverage : " +
        @types.format_double(s_audit.estop_coverage_percent, 1) +
        "%",
      )
    }
  }
}

///|
fn cmd_outage(preset_name : String, node_id : String) -> Unit {
  match get_preset_graph(preset_name) {
    None => println("Error: Unknown preset '" + preset_name + "'")
    Some(g) => {
      if !g.has_node(node_id) {
        println("Error: Node '" + node_id + "' not found in plant topology.")
        return
      }
      let res = @analysis.simulate_device_outage(g, node_id)
      println(
        "================ Device Outage Cascade Simulation ================",
      )
      println("Failed Root Asset     : " + res.failed_node_id)
      println(
        "Power Blackout Nodes  : " +
        res.power_blackout_nodes.length().to_string(),
      )
      println(
        "PLC Disconnect Nodes  : " + res.plc_timeout_nodes.length().to_string(),
      )
      println(
        "Safety Interlock Trips: " +
        res.safety_tripped_nodes.length().to_string(),
      )
      for sn in res.safety_tripped_nodes {
        println("  * Tripped E-Stop: " + sn)
      }
      println(
        "Starved Workstations  : " +
        res.starved_workstations.length().to_string(),
      )
      println(
        "Blocked Workstations  : " +
        res.blocked_workstations.length().to_string(),
      )
      println(
        "Capacity Loss         : " +
        @types.format_double(res.production_capacity_loss_percent, 1) +
        "%",
      )
      println(
        "Est. Financial Loss   : " +
        @types.format_double(res.estimated_hourly_loss_cny, 2) +
        " CNY/hour",
      )
    }
  }
}

///|
fn cmd_diff(p1 : String, p2 : String) -> Unit {
  let g1_opt = get_preset_graph(p1)
  let g2_opt = get_preset_graph(p2)
  match (g1_opt, g2_opt) {
    (Some(g1), Some(g2)) => {
      let report = @diff.compare_factory_topologies(g1, g2)
      println(
        "================ Topology Drift & Risk Evaluation ================",
      )
      println("Risk Level           : " + report.overall_risk_level.to_string())
      println(
        "Risk Score           : " +
        @types.format_double(report.risk_score, 1) +
        " / 100",
      )
      println(
        "Added Nodes          : " + report.added_nodes.length().to_string(),
      )
      println(
        "Removed Nodes        : " + report.removed_nodes.length().to_string(),
      )
      println(
        "Modified Nodes       : " + report.modified_nodes.length().to_string(),
      )
      println(
        "Breaking Changes     : " + report.breaking_changes.length().to_string(),
      )
      for bc in report.breaking_changes {
        println("  ! " + bc)
      }
    }
    _ => println("Error: Presets '" + p1 + "' and/or '" + p2 + "' not found.")
  }
}

///|
fn cmd_demo() -> Unit {
  print_banner()
  println(
    "Running Comprehensive Multi-Plant Digital Twin Simulation Demonstration...\n",
  )

  println("1. Instantiating Automotive Manufacturing Gigafactory...")
  let auto_g = @presets.build_automotive_plant()
  println(
    "   -> Created " +
    auto_g.node_count().to_string() +
    " assets, " +
    auto_g.edge_count().to_string() +
    " flow edges.",
  )

  println("2. Calculating Optimal End-to-End Material Flow...")
  let p = @algorithms.dijkstra_shortest_path(
    auto_g, "STAMP-UNCOIL", "ASSY-INSPECT",
  )
  match p {
    Some(res) => {
      println(
        "   -> Found critical production route: " +
        res.nodes.length().to_string() +
        " stations.",
      )
      println(
        "   -> Cumulative transport delay: " +
        @types.format_double(res.total_delay_sec, 1) +
        "s",
      )
      println(
        "   -> Line bottleneck bandwidth : " +
        @types.format_double(res.bottleneck_bandwidth, 1) +
        " units/h",
      )
    }
    None => println("   -> No path found.")
  }

  println("3. Simulating Catastrophic Substation Failure...")
  let outage = @analysis.simulate_device_outage(auto_g, "SUB-02")
  println(
    "   -> Affected Workstations: " +
    outage.affected_workstations_count.to_string(),
  )
  println(
    "   -> Production Line Capacity Loss: " +
    @types.format_double(outage.production_capacity_loss_percent, 1) +
    "%",
  )

  println("4. Generating Plant Operations Executive Audit Report...")
  let rep = @export.generate_executive_audit_report(auto_g)
  println(
    "   -> Generated " +
    rep.length().to_string() +
    " bytes Markdown report successfully.\n",
  )

  println("Demo execution completed successfully.")
}

///|

///|
fn build_benchmark_graph() -> @graph.FactoryGraph {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="BenchmarkPlant",
    takt_time_target_sec=30.0,
  )
  for i = 1; i <= 1000; i = i + 1 {
    let _ = builder.add_workstation(
      "N-" + i.to_string(),
      "Machine " + i.to_string(),
      cycle_time_sec=20.0,
      nominal_power_kw=15.0,
    )
  }
  // A chain plus skip links gives the benchmark both serial and alternate
  // routing pressure while keeping the topology deterministic.
  for i = 1; i < 1000; i = i + 1 {
    let _ = builder.connect_material(
      "N-" + i.to_string(),
      "N-" + (i + 1).to_string(),
      bandwidth=1200.0,
    )
  }
  for i = 1; i < 999; i = i + 1 {
    let _ = builder.connect_material(
      "N-" + i.to_string(),
      "N-" + (i + 2).to_string(),
      bandwidth=900.0,
      delay=1.0,
    )
  }
  builder.build()
}

///|
fn cmd_bench() -> Unit {
  println("Running Industrial Graph Scaling Benchmark...")
  let graph = build_benchmark_graph()
  println(
    "Benchmark Graph Built: " +
    graph.node_count().to_string() +
    " nodes, " +
    graph.edge_count().to_string() +
    " material edges.",
  )

  let bench = @bench.Bench::Bench()
  bench.bench(
    name="build_1000_nodes_1997_edges",
    () => {
      let candidate = build_benchmark_graph()
      bench.keep(candidate.node_count() + candidate.edge_count())
    },
    count=5,
  )
  bench.bench(
    name="dijkstra_1000_nodes",
    () => {
      match @algorithms.dijkstra_shortest_path(graph, "N-1", "N-1000") {
        Some(result) => bench.keep(result.nodes.length())
        None => bench.keep(0)
      }
    },
    count=5,
  )
  bench.bench(
    name="spof_biconnectivity_1000_nodes",
    () => {
      let report = @algorithms.find_critical_spof_assets(graph)
      bench.keep(report.single_points_of_failure.length())
    },
    count=5,
  )
  bench.bench(
    name="capacity_and_health_report",
    () => {
      let capacity = @analysis.analyze_material_capacity(
        graph,
        demand_per_hour=120.0,
      )
      let health = @graph.inspect_graph_health(graph)
      bench.keep(
        capacity.overloaded_edge_ids.length() + health.active_edge_count,
      )
    },
    count=5,
  )
  println("Measured summaries (microseconds per operation):")
  println(bench.dump_summaries())
  println("Benchmark complete.")
}

///|
fn main {
  let args = @env.args()
  if args.length() <= 1 {
    cmd_demo()
    return
  }

  let cmd = args[1]
  match cmd {
    "info" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      cmd_info(preset)
    }
    "health" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      cmd_health(preset)
    }
    "capacity" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      cmd_capacity(preset)
    }
    "analyze" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      cmd_analyze(preset)
    }
    "outage" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      let node_id = if args.length() > 3 { args[3] } else { "WELD-FLOOR" }
      cmd_outage(preset, node_id)
    }
    "diff" => {
      let p1 = if args.length() > 2 { args[2] } else { "automotive" }
      let p2 = if args.length() > 3 { args[3] } else { "battery" }
      cmd_diff(p1, p2)
    }
    "path" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      let src = if args.length() > 3 { args[3] } else { "STAMP-UNCOIL" }
      let dst = if args.length() > 4 { args[4] } else { "ASSY-INSPECT" }
      match get_preset_graph(preset) {
        None => println("Error: Unknown preset '" + preset + "'")
        Some(g) => {
          let p = @algorithms.dijkstra_shortest_path(g, src, dst)
          match p {
            Some(res) => {
              println(
                "Path Found: " + res.nodes.length().to_string() + " nodes",
              )
              for n in res.nodes {
                println("  -> " + n)
              }
              println("Total Delay: " + res.total_delay_sec.to_string() + "s")
              println(
                "Bottleneck Bandwidth: " +
                res.bottleneck_bandwidth.to_string() +
                " u/h",
              )
            }
            None => println("No path found between " + src + " and " + dst)
          }
        }
      }
    }
    "export" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      let fmt = if args.length() > 3 { args[3] } else { "dot" }
      match get_preset_graph(preset) {
        None => println("Error: Unknown preset '" + preset + "'")
        Some(g) => {
          let out = match fmt {
            "dot" => @export.export_to_graphviz_dot(g)
            "mermaid" => @export.export_to_mermaid(g)
            "puml" => @export.export_to_plantuml(g)
            "json" => @export.export_to_json(g)
            "report" => @export.generate_executive_audit_report(g)
            "nodes_csv" => @export.export_nodes_csv(g)
            "edges_csv" => @export.export_edges_csv(g)
            _ => @export.export_to_graphviz_dot(g)
          }
          println(out)
        }
      }
    }
    "optimize" => {
      let preset = if args.length() > 2 { args[2] } else { "automotive" }
      match get_preset_graph(preset) {
        None => println("Error: Unknown preset '" + preset + "'")
        Some(g) => {
          let plan = @optimizer.optimize_line_balance(g)
          println(
            "Line Balancing Recommendations: " +
            plan.recommendations.length().to_string(),
          )
          for rec in plan.recommendations {
            println(
              "  - Station " +
              rec.station_id +
              ": " +
              rec.suggested_action +
              " (Current CT: " +
              rec.current_cycle_time.to_string() +
              "s)",
            )
          }
        }
      }
    }
    "demo" => cmd_demo()
    "bench" => cmd_bench()
    "help" | "-h" | "--help" => print_help()
    _ => {
      println("Unknown command: " + cmd)
      print_help()
    }
  }
}
