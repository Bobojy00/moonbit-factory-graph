///|
test "failure_propagation_and_bottleneck_analysis" {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="BatteryCellLine",
    takt_time_target_sec=30.0,
  )
  let g = builder
    .add_power_source("PWR-1", "Main Substation", capacity_kw=800.0)
    .add_plc("PLC-1", "Plant Central PLC")
    .add_workstation(
      "WS-1",
      "Cathode Mixer",
      cycle_time_sec=28.0,
      nominal_power_kw=50.0,
      safety_zone_id="SZ-1",
    )
    .add_workstation(
      "WS-2",
      "Coating & Drying",
      cycle_time_sec=35.0,
      nominal_power_kw=80.0,
      safety_zone_id="SZ-1",
    )
    .add_workstation(
      "WS-3",
      "Cell Assembly",
      cycle_time_sec=25.0,
      nominal_power_kw=30.0,
      safety_zone_id="SZ-2",
    )
    .connect_material("WS-1", "WS-2")
    .connect_material("WS-2", "WS-3")
    .connect_power_bus("PWR-1", ["WS-1", "WS-2", "WS-3"])
    .connect_plc_network("PLC-1", ["WS-1", "WS-2", "WS-3"])
    .build()

  let outage = simulate_device_outage(g, "WS-1")
  assert_eq(outage.failed_node_id, "WS-1")
  assert_eq(outage.safety_tripped_nodes.length(), 1) // WS-2 in SZ-1 trips
  assert_eq(outage.safety_tripped_nodes[0], "WS-2")

  let b_report = analyze_production_bottlenecks(g)
  assert_eq(b_report.primary_bottleneck_node_id, "WS-2")
  assert_eq(b_report.primary_bottleneck_cycle_time, 35.0)

  let kpis = compute_plant_kpis(g)
  assert_eq(kpis.total_asset_count, 5)
  assert_eq(kpis.active_asset_count, 5)
}

///|
test "safety_and_redundancy_evaluation" {
  let builder = @graph.FactoryGraphBuilder::new()
  let g = builder
    .add_workstation("A", "Station A", safety_zone_id="SZ-1")
    .add_workstation("B", "Station B", safety_zone_id="SZ-1")
    .connect_material("A", "B")
    .build()

  let audit = audit_plant_safety_systems(g)
  assert_eq(audit.sil_compliant, true)
  assert_eq(audit.total_safety_zones, 1)

  let red = evaluate_line_redundancy(g, "A", "B")
  assert_eq(red.bypass_path_available, false)
}
