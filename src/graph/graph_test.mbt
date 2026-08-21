///|
test "factory_graph_builder_and_queries" {
  let builder = FactoryGraphBuilder::new(plant_name="BatteryGigafactory")
  let g = builder
    .add_power_source("PWR-1", "Main Substation 10kV/380V", capacity_kw=1000.0)
    .add_plc("PLC-1", "Main Assembly Line Master PLC")
    .add_workstation(
      "WS-1",
      "Electrode Coating Station",
      cycle_time_sec=30.0,
      nominal_power_kw=45.0,
    )
    .add_workstation(
      "WS-2",
      "Calendering & Slitting Station",
      cycle_time_sec=25.0,
      nominal_power_kw=35.0,
    )
    .add_buffer("BUF-1", "Jelly Roll WIP Buffer", capacity=500.0)
    .connect_material("WS-1", "WS-2", bandwidth=1200.0)
    .connect_material("WS-2", "BUF-1", bandwidth=1200.0)
    .connect_power_bus("PWR-1", ["WS-1", "WS-2"])
    .connect_plc_network("PLC-1", ["WS-1", "WS-2"])
    .build()

  assert_eq(g.node_count(), 5)
  assert_eq(g.edge_count(), 6)

  let ws1_out = g.get_layer_out_edges(@types.FlowType::MaterialFlow, "WS-1")
  assert_eq(ws1_out.length(), 1)
  assert_eq(ws1_out[0].target_id(), "WS-2")

  let pwr_out = g.get_layer_out_edges(@types.FlowType::EnergyFlow, "PWR-1")
  assert_eq(pwr_out.length(), 2)

  let total_pwr = g.calculate_total_power_kw()
  assert_eq(total_pwr, 1080.5)

  let issues = validate_graph(g)
  assert_eq(issues.length(), 0)
}

///|
test "factory_graph_clone_and_isolation_check" {
  let builder = FactoryGraphBuilder::new()
  let g = builder.add_workstation("WS-ISO", "Isolated Station").build()

  let issues = validate_graph(g)
  assert_eq(issues.length(), 2) // Isolated + Unpowered

  let cloned = g.clone()
  assert_eq(cloned.node_count(), 1)
  assert_eq(cloned.has_node("WS-ISO"), true)
}
