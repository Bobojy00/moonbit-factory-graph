///|
pub(all) struct BottleneckAnalysisReport {
  takt_time_target_sec : Double
  primary_bottleneck_node_id : String
  primary_bottleneck_cycle_time : Double
  secondary_bottlenecks : Array[String]
  conveyor_bandwidth_bottlenecks : Array[String]
  max_theoretical_hourly_output : Double
  line_balance_efficiency_percent : Double
} derive(Debug, Eq)

///|
pub fn analyze_production_bottlenecks(
  graph : @graph.FactoryGraph,
) -> BottleneckAnalysisReport {
  let target_takt = graph.config().takt_time_target_sec
  let nodes = graph.get_all_nodes()

  let mut max_ct = 0.0
  let mut primary_id = ""
  let mut total_ct = 0.0
  let mut station_count = 0

  for node in nodes {
    let nt = node.node_type()
    if nt == @types.NodeType::Workstation ||
      nt == @types.NodeType::Machine ||
      nt == @types.NodeType::RobotArm ||
      nt == @types.NodeType::Inspection {
      let ct = node.cycle_time_sec()
      if ct > 0.0 {
        total_ct = total_ct + ct
        station_count = station_count + 1
        if ct > max_ct {
          max_ct = ct
          primary_id = node.id()
        }
      }
    }
  }

  let secondary = []
  for node in nodes {
    let nt = node.node_type()
    if nt == @types.NodeType::Workstation ||
      nt == @types.NodeType::Machine ||
      nt == @types.NodeType::RobotArm {
      let ct = node.cycle_time_sec()
      if ct > target_takt && node.id() != primary_id {
        secondary.push(node.id() + " (" + ct.to_string() + "s)")
      }
    }
  }

  // Conveyor bandwidth bottlenecks
  let edges = graph.get_all_edges()
  let conveyor_bottlenecks = []
  let required_th = if target_takt > 0.0 {
    3600.0 / target_takt
  } else {
    1200.0
  }
  for edge in edges {
    if edge.flow_type() == @types.FlowType::MaterialFlow {
      if edge.bandwidth() < required_th {
        conveyor_bottlenecks.push(
          edge.id() +
          " [" +
          edge.source_id() +
          " -> " +
          edge.target_id() +
          "]: " +
          edge.bandwidth().to_string() +
          " u/h",
        )
      }
    }
  }

  let max_throughput = if max_ct > 0.0 { 3600.0 / max_ct } else { 0.0 }
  let line_balance_eff = if station_count > 0 && max_ct > 0.0 {
    total_ct / (station_count.to_double() * max_ct) * 100.0
  } else {
    100.0
  }

  {
    takt_time_target_sec: target_takt,
    primary_bottleneck_node_id: primary_id,
    primary_bottleneck_cycle_time: max_ct,
    secondary_bottlenecks: secondary,
    conveyor_bandwidth_bottlenecks: conveyor_bottlenecks,
    max_theoretical_hourly_output: max_throughput,
    line_balance_efficiency_percent: line_balance_eff,
  }
}
