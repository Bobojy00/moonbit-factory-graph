///|
/// Material edge utilization at a requested production demand.
pub(all) struct EdgeUtilizationSnapshot {
  edge_id : String
  source_id : String
  target_id : String
  bandwidth_units_per_hour : Double
  is_active : Bool
  utilization_percent : Double
  is_congested : Bool
} derive(Debug, Eq)

///|
/// Capacity report for material edges and production assets.
pub(all) struct MaterialCapacityReport {
  demand_per_hour : Double
  constrained_capacity_per_hour : Double
  output_capacity_per_hour : Double
  capacity_margin_percent : Double
  edge_utilization : Array[EdgeUtilizationSnapshot]
  overloaded_edge_ids : Array[String]
  constrained_node_ids : Array[String]
} derive(Debug, Eq)

///|
fn is_production_asset(node : @graph.Node) -> Bool {
  match node.node_type() {
    @types.NodeType::Workstation
    | @types.NodeType::Machine
    | @types.NodeType::Conveyor
    | @types.NodeType::Inspection
    | @types.NodeType::RobotArm
    | @types.NodeType::Diverter
    | @types.NodeType::AGVTrack => true
    _ => false
  }
}

///|
fn requested_demand(
  graph : @graph.FactoryGraph,
  demand_per_hour : Double,
) -> Double {
  if demand_per_hour > 0.0 {
    demand_per_hour
  } else {
    let takt = graph.config().takt_time_target_sec
    if takt > 0.0 {
      3600.0 / takt
    } else {
      0.0
    }
  }
}

///|
/// Analyze material-flow congestion and the limiting production capacity.
///
/// If `demand_per_hour` is omitted, the target takt time in the graph
/// configuration is converted to units per hour. Zero or negative edge
/// bandwidth is treated as unavailable capacity instead of producing an
/// infinite utilization value.
pub fn analyze_material_capacity(
  graph : @graph.FactoryGraph,
  demand_per_hour? : Double = 0.0,
) -> MaterialCapacityReport {
  let demand = requested_demand(graph, demand_per_hour)
  let utilization = []
  let overloaded = []
  let mut edge_capacity = 1.0e18
  let mut material_edge_count = 0

  for edge in graph.get_all_edges() {
    if edge.flow_type() == @types.FlowType::MaterialFlow {
      material_edge_count = material_edge_count + 1
      let bandwidth = edge.bandwidth()
      let effective_bandwidth = if edge.is_active() && bandwidth > 0.0 {
        bandwidth
      } else {
        0.0
      }
      if effective_bandwidth < edge_capacity {
        edge_capacity = effective_bandwidth
      }
      let is_congested = demand > effective_bandwidth
      let utilization_percent = if effective_bandwidth > 0.0 {
        demand / effective_bandwidth * 100.0
      } else if demand > 0.0 {
        100.0
      } else {
        0.0
      }
      let snapshot = {
        edge_id: edge.id(),
        source_id: edge.source_id(),
        target_id: edge.target_id(),
        bandwidth_units_per_hour: bandwidth,
        is_active: edge.is_active(),
        utilization_percent,
        is_congested,
      }
      utilization.push(snapshot)
      if is_congested {
        overloaded.push(edge.id())
      }
    }
  }

  let constrained_nodes = []
  let mut node_capacity = 1.0e18
  let mut production_node_count = 0
  for node in graph.get_all_nodes() {
    if is_production_asset(node) {
      production_node_count = production_node_count + 1
      let capacity = node.hourly_throughput_limit()
      if capacity < node_capacity {
        node_capacity = capacity
      }
      if demand > capacity {
        constrained_nodes.push(node.id())
      }
    }
  }

  let constrained_capacity = if material_edge_count == 0 {
    node_capacity
  } else if production_node_count == 0 {
    edge_capacity
  } else if edge_capacity < node_capacity {
    edge_capacity
  } else {
    node_capacity
  }
  let output_capacity = if graph.node_count() == 0 {
    0.0
  } else {
    constrained_capacity
  }
  let margin = if demand > 0.0 {
    (output_capacity - demand) / demand * 100.0
  } else {
    100.0
  }
  {
    demand_per_hour: demand,
    constrained_capacity_per_hour: constrained_capacity,
    output_capacity_per_hour: output_capacity,
    capacity_margin_percent: margin,
    edge_utilization: utilization,
    overloaded_edge_ids: overloaded,
    constrained_node_ids: constrained_nodes,
  }
}
