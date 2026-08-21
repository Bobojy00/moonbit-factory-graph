///|
pub(all) struct FailoverRoutePlan {
  failed_node_id : String
  alternate_route_found : Bool
  suggested_bypass_path : Array[String]
  derated_capacity_units_per_hour : Double
  action_summary : String
} derive(Debug, Eq)

///|
pub fn synthesize_failover_routing(
  graph : @graph.FactoryGraph,
  failed_node_id : String,
  source_id : String,
  target_id : String,
) -> FailoverRoutePlan {
  // Clone graph and mark failed node inactive
  let failover_graph = graph.clone()
  match failover_graph.get_node(failed_node_id) {
    Some(n) => n.set_status(@types.OperatingStatus::Offline)
    None => ()
  }

  // Deactivate all edges touching failed node
  let in_e = failover_graph.get_in_edges(failed_node_id)
  for e in in_e {
    e.set_active(false)
  }
  let out_e = failover_graph.get_out_edges(failed_node_id)
  for e in out_e {
    e.set_active(false)
  }

  let path_opt = @algorithms.dijkstra_shortest_path(
    failover_graph,
    source_id,
    target_id,
    flow_type=@types.FlowType::MaterialFlow,
  )

  match path_opt {
    Some(p) =>
      {
        failed_node_id,
        alternate_route_found: true,
        suggested_bypass_path: p.nodes,
        derated_capacity_units_per_hour: p.bottleneck_bandwidth,
        action_summary: "Dynamic rerouting active: diverting material via " +
        p.nodes.length().to_string() +
        " stations at " +
        p.bottleneck_bandwidth.to_string() +
        " units/hour.",
      }
    None =>
      {
        failed_node_id,
        alternate_route_found: false,
        suggested_bypass_path: [],
        derated_capacity_units_per_hour: 0.0,
        action_summary: "No valid alternate path exists between " +
        source_id +
        " and " +
        target_id +
        "; production line paused.",
      }
  }
}
