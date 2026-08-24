///|
test "capacity_analysis_reports_edge_and_node_constraints" {
  let g = @graph.FactoryGraphBuilder::new(takt_time_target_sec=30.0)
    .add_workstation("A", "Feeder", cycle_time_sec=20.0)
    .add_workstation("B", "Bottleneck", cycle_time_sec=45.0)
    .connect_material("A", "B", bandwidth=80.0)
    .build()

  let report = analyze_material_capacity(g, demand_per_hour=100.0)
  assert_eq(report.demand_per_hour, 100.0)
  assert_eq(report.constrained_capacity_per_hour, 80.0)
  assert_eq(report.output_capacity_per_hour, 80.0)
  assert_eq(report.overloaded_edge_ids, ["MAT-1"])
  assert_eq(report.constrained_node_ids, ["B"])
  assert_eq(report.edge_utilization[0].utilization_percent, 125.0)
  assert_eq(report.edge_utilization[0].is_congested, true)
}

///|
test "outage_portfolio_is_deterministic_and_rejects_unknown_assets" {
  let g = @graph.FactoryGraphBuilder::new()
    .add_power_source("PWR", "Main Power")
    .add_workstation("A", "Station A", safety_zone_id="SZ-1")
    .add_workstation("B", "Station B", safety_zone_id="SZ-1")
    .connect_material("A", "B")
    .connect_power_bus("PWR", ["A", "B"])
    .build()

  let portfolio = evaluate_outage_portfolio(
    g,
    ["B", "missing", "B", "PWR"],
    hourly_downtime_cost=10000.0,
  )
  assert_eq(portfolio.valid_scenario_count, 2)
  assert_eq(portfolio.invalid_node_ids, ["missing"])
  assert_eq(portfolio.scenarios.length(), 2)
  assert_eq(portfolio.worst_case_node_id, "PWR")
  assert_true(portfolio.max_capacity_loss_percent >= 50.0)
  assert_true(portfolio.average_capacity_loss_percent > 0.0)
}

///|
test "capacity_analysis_handles_zero_bandwidth_and_empty_scenarios" {
  let g = @graph.FactoryGraphBuilder::new(takt_time_target_sec=60.0)
    .add_workstation("A", "Station A", cycle_time_sec=30.0)
    .add_workstation("B", "Station B", cycle_time_sec=30.0)
    .connect_material("A", "B", bandwidth=0.0)
    .build()
  let capacity = analyze_material_capacity(g)
  assert_eq(capacity.demand_per_hour, 60.0)
  assert_eq(capacity.constrained_capacity_per_hour, 0.0)
  assert_eq(capacity.output_capacity_per_hour, 0.0)
  assert_eq(capacity.edge_utilization[0].utilization_percent, 100.0)
  assert_eq(capacity.overloaded_edge_ids, ["MAT-1"])

  let inactive = @graph.FactoryGraph::new()
  inactive.add_node(
    @graph.Node::create("A", "Station A", @types.NodeType::Workstation),
  )
  inactive.add_node(
    @graph.Node::create("B", "Station B", @types.NodeType::Workstation),
  )
  inactive.add_edge(
    @graph.Edge::create(
      "MAT-OFF",
      "A",
      "B",
      @types.FlowType::MaterialFlow,
      bandwidth_units_per_hour=1000.0,
      is_active=false,
    ),
  )
  let inactive_capacity = analyze_material_capacity(
    inactive,
    demand_per_hour=100.0,
  )
  assert_eq(inactive_capacity.output_capacity_per_hour, 0.0)
  assert_eq(inactive_capacity.edge_utilization[0].is_active, false)
  assert_eq(inactive_capacity.overloaded_edge_ids, ["MAT-OFF"])

  let empty = evaluate_outage_portfolio(g, [])
  assert_eq(empty.valid_scenario_count, 0)
  assert_eq(empty.invalid_node_ids, [])
  assert_eq(empty.worst_case_node_id, "")
  assert_eq(empty.average_capacity_loss_percent, 0.0)
}
