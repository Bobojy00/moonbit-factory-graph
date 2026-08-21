///|
test "line_rebalance_and_failover_routing" {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="OptLine",
    takt_time_target_sec=30.0,
  )
  let g = builder
    .add_workstation("A", "Station A", cycle_time_sec=25.0)
    .add_workstation("B1", "Station B Primary", cycle_time_sec=65.0) // Bottleneck > 30s
    .add_workstation("B2", "Station B Bypass", cycle_time_sec=30.0)
    .add_workstation("C", "Station C", cycle_time_sec=28.0)
    .add_buffer("BUF-1", "Intermediate Buffer", capacity=50.0)
    .connect_material("A", "B1")
    .connect_material("B1", "BUF-1")
    .connect_material("A", "B2")
    .connect_material("B2", "BUF-1")
    .connect_material("BUF-1", "C")
    .build()

  let balance_plan = optimize_line_balance(g)
  assert_eq(balance_plan.recommendations.length(), 1)
  assert_eq(balance_plan.recommendations[0].station_id, "B1")
  assert_eq(balance_plan.recommendations[0].suggested_parallel_count, 3)

  let failover = synthesize_failover_routing(g, "B1", "A", "C")
  assert_eq(failover.alternate_route_found, true)
  assert_eq(failover.suggested_bypass_path, ["A", "B2", "BUF-1", "C"])

  let buf_recs = optimize_buffer_capacities(g)
  assert_eq(buf_recs.length(), 1)
  assert_eq(buf_recs[0].buffer_id, "BUF-1")

  let energy_plan = plan_staggered_energy_startup(g)
  assert_eq(energy_plan.startup_sequence.length(), 3)
}
