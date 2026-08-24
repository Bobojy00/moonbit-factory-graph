///|
test "readiness_audit_accepts_a_connected_operational_line" {
  let g = @graph.FactoryGraphBuilder::new(takt_time_target_sec=30.0)
    .add_power_source("PWR", "Main Power")
    .add_plc("PLC", "Line PLC")
    .add_workstation("A", "Feeder", cycle_time_sec=20.0, safety_zone_id="SZ-1")
    .add_workstation(
      "B",
      "Assembler",
      cycle_time_sec=25.0,
      safety_zone_id="SZ-1",
    )
    .connect_material("A", "B", bandwidth=120.0)
    .connect_power_bus("PWR", ["A", "B"])
    .connect_plc_network("PLC", ["A", "B"])
    .build()

  let report = audit_operational_readiness(g, demand_per_hour=80.0)
  assert_eq(report.readiness_level, ReadinessLevel::Ready)
  assert_eq(report.ready_for_deployment, true)
  assert_eq(report.critical_issue_count, 0)
  assert_eq(report.error_issue_count, 0)
  assert_eq(report.inactive_node_ids, [])
  assert_true(report.readiness_score >= 90.0)
  assert_true(report.recommendations.length() >= 1)
}

///|
test "readiness_audit_exposes_isolated_and_unpowered_assets" {
  let g = @graph.FactoryGraphBuilder::new()
    .add_workstation("A", "Unpowered Station", cycle_time_sec=40.0)
    .add_plc("PLC", "Disconnected PLC")
    .add_sensor("SENSOR", "Loose Sensor")
    .build()

  let report = audit_operational_readiness(g, demand_per_hour=100.0)
  assert_eq(report.readiness_level, ReadinessLevel::Blocked)
  assert_eq(report.ready_for_deployment, false)
  assert_true(report.error_issue_count >= 1)
  assert_true(report.warning_issue_count >= 2)
  assert_eq(report.orphan_node_ids, ["A", "PLC", "SENSOR"])
  assert_true(report.unpowered_asset_ids.contains("A"))
  assert_true(report.disconnected_controller_ids.contains("PLC"))
  assert_true(report.recommendations.length() >= 3)
}

///|
test "readiness_audit_handles_empty_and_inactive_graphs" {
  let empty = audit_operational_readiness(@graph.FactoryGraph::new())
  assert_eq(empty.readiness_level, ReadinessLevel::Ready)
  assert_eq(empty.ready_for_deployment, true)
  assert_eq(empty.readiness_score, 100.0)
  assert_eq(empty.active_node_ratio_percent, 100.0)
  assert_eq(empty.active_edge_ratio_percent, 100.0)

  let g = @graph.FactoryGraph::new()
  g.add_node(@graph.Node::create("A", "A", @types.NodeType::Machine))
  g.add_node(
    @graph.Node::create(
      "B",
      "B",
      @types.NodeType::Machine,
      status=@types.OperatingStatus::Maintenance,
    ),
  )
  g.add_edge(
    @graph.Edge::create(
      "MAT-OFF",
      "A",
      "B",
      @types.FlowType::MaterialFlow,
      bandwidth_units_per_hour=0.0,
      is_active=false,
    ),
  )
  let inactive = audit_operational_readiness(g, demand_per_hour=10.0)
  assert_eq(inactive.inactive_node_ids, ["B"])
  assert_eq(inactive.inactive_edge_ids, ["MAT-OFF"])
  assert_true(inactive.active_node_ratio_percent < 100.0)
  assert_true(inactive.active_edge_ratio_percent < 100.0)
  assert_true(inactive.readiness_level != ReadinessLevel::Ready)
}
