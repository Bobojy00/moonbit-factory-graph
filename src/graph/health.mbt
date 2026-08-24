///|
/// A compact view of one physical or logical flow layer.
pub(all) struct FlowLayerHealth {
  flow_type : @types.FlowType
  active_edge_count : Int
  inactive_edge_count : Int
  total_bandwidth_units_per_hour : Double
  max_bandwidth_units_per_hour : Double
} derive(Debug, Eq)

///|
/// Structural and operational health indicators for a factory topology.
pub(all) struct GraphHealthReport {
  total_node_count : Int
  active_node_count : Int
  inactive_node_count : Int
  total_edge_count : Int
  active_edge_count : Int
  inactive_edge_count : Int
  orphan_node_ids : Array[String]
  layer_health : Array[FlowLayerHealth]
} derive(Debug, Eq)

///|
fn inspect_flow_layer(
  graph : FactoryGraph,
  flow_type : @types.FlowType,
) -> FlowLayerHealth {
  let mut active = 0
  let mut inactive = 0
  let mut total_bandwidth = 0.0
  let mut max_bandwidth = 0.0
  for edge in graph.get_all_edges() {
    if edge.flow_type() == flow_type {
      if edge.is_active() {
        active = active + 1
      } else {
        inactive = inactive + 1
      }
      let bandwidth = edge.bandwidth()
      total_bandwidth = total_bandwidth + bandwidth
      if bandwidth > max_bandwidth {
        max_bandwidth = bandwidth
      }
    }
  }
  {
    flow_type,
    active_edge_count: active,
    inactive_edge_count: inactive,
    total_bandwidth_units_per_hour: total_bandwidth,
    max_bandwidth_units_per_hour: max_bandwidth,
  }
}

///|
/// Inspect topology completeness and per-layer operational capacity.
///
/// Orphan nodes have no incoming or outgoing edge in any layer. Inactive
/// edges remain visible in the report so callers can distinguish a planned
/// maintenance path from a missing connection.
pub fn inspect_graph_health(graph : FactoryGraph) -> GraphHealthReport {
  let nodes = graph.get_all_nodes()
  let edges = graph.get_all_edges()
  let mut active_nodes = 0
  let orphan_ids = []
  for node in nodes {
    if node.is_operational() {
      active_nodes = active_nodes + 1
    }
    if graph.get_in_edges(node.id()).length() == 0 &&
      graph.get_out_edges(node.id()).length() == 0 {
      orphan_ids.push(node.id())
    }
  }

  let mut active_edges = 0
  for edge in edges {
    if edge.is_active() {
      active_edges = active_edges + 1
    }
  }

  let layer_health = [
    inspect_flow_layer(graph, @types.FlowType::MaterialFlow),
    inspect_flow_layer(graph, @types.FlowType::ControlFlow),
    inspect_flow_layer(graph, @types.FlowType::EnergyFlow),
    inspect_flow_layer(graph, @types.FlowType::SafetyInterlock),
    inspect_flow_layer(graph, @types.FlowType::PneumaticFlow),
    inspect_flow_layer(graph, @types.FlowType::CoolantFlow),
    inspect_flow_layer(graph, @types.FlowType::DataTelemetry),
  ]
  {
    total_node_count: nodes.length(),
    active_node_count: active_nodes,
    inactive_node_count: nodes.length() - active_nodes,
    total_edge_count: edges.length(),
    active_edge_count: active_edges,
    inactive_edge_count: edges.length() - active_edges,
    orphan_node_ids: orphan_ids,
    layer_health,
  }
}
