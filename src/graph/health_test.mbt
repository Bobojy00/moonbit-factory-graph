///|
test "graph_health_counts_layers_and_orphans" {
  let g = FactoryGraphBuilder::new()
    .add_power_source("PWR", "Main Power")
    .add_workstation("WS", "Assembly", cycle_time_sec=30.0)
    .add_sensor("SENSOR", "Quality Sensor")
    .connect_material("PWR", "WS", bandwidth=120.0)
    .connect_control("PWR", "WS")
    .build()

  let report = inspect_graph_health(g)
  assert_eq(report.total_node_count, 3)
  assert_eq(report.active_node_count, 3)
  assert_eq(report.total_edge_count, 2)
  assert_eq(report.active_edge_count, 2)
  assert_eq(report.orphan_node_ids, ["SENSOR"])
  assert_eq(report.layer_health[0].active_edge_count, 1)
  assert_eq(report.layer_health[0].total_bandwidth_units_per_hour, 120.0)
  assert_eq(report.layer_health[1].active_edge_count, 1)
}

///|
test "graph_health_handles_empty_graph" {
  let report = inspect_graph_health(FactoryGraph::new())
  assert_eq(report.total_node_count, 0)
  assert_eq(report.total_edge_count, 0)
  assert_eq(report.orphan_node_ids, [])
  assert_eq(report.layer_health.length(), 7)
}

///|
test "graph_health_keeps_inactive_edges_visible" {
  let g = FactoryGraph::new()
  g.add_node(Node::create("A", "A", @types.NodeType::Machine))
  g.add_node(Node::create("B", "B", @types.NodeType::Machine))
  g.add_edge(
    Edge::create(
      "MAT-OFF",
      "A",
      "B",
      @types.FlowType::MaterialFlow,
      bandwidth_units_per_hour=400.0,
      is_active=false,
    ),
  )
  let report = inspect_graph_health(g)
  assert_eq(report.active_edge_count, 0)
  assert_eq(report.inactive_edge_count, 1)
  assert_eq(report.orphan_node_ids, [])
  assert_eq(report.layer_health[0].inactive_edge_count, 1)
}
