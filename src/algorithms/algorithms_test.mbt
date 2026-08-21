///|
test "dijkstra_shortest_path_and_k_paths" {
  let builder = @graph.FactoryGraphBuilder::new(plant_name="LineTest")
  let g = builder
    .add_workstation("A", "Station A", cycle_time_sec=10.0)
    .add_workstation("B", "Station B", cycle_time_sec=15.0)
    .add_workstation("C", "Station C", cycle_time_sec=20.0)
    .add_workstation("D", "Station D", cycle_time_sec=10.0)
    .connect_material("A", "B", bandwidth=1000.0, delay=2.0)
    .connect_material("B", "D", bandwidth=1000.0, delay=3.0)
    .connect_material("A", "C", bandwidth=800.0, delay=1.0)
    .connect_material("C", "D", bandwidth=800.0, delay=2.0)
    .build()

  let p = dijkstra_shortest_path(g, "A", "D")
  match p {
    Some(res) => {
      assert_eq(res.nodes, ["A", "C", "D"])
      assert_eq(res.total_delay_sec, 3.0)
      assert_eq(res.bottleneck_bandwidth, 800.0)
    }
    None => abort("Expected path from A to D")
  }

  let k_paths = k_shortest_paths(g, "A", "D", 2)
  assert_eq(k_paths.length(), 2)
}

///|
test "spof_biconnectivity_and_max_flow" {
  let builder = @graph.FactoryGraphBuilder::new()
  let g = builder
    .add_workstation("S", "Source")
    .add_workstation("B", "Bottleneck Center")
    .add_workstation("T", "Sink")
    .connect_material("S", "B", bandwidth=1500.0)
    .connect_material("B", "T", bandwidth=1200.0)
    .build()

  let spof_rep = find_critical_spof_assets(g)
  assert_eq(spof_rep.single_points_of_failure.length(), 1)
  assert_eq(spof_rep.single_points_of_failure[0], "B")

  let mf = edmonds_karp_max_flow(g, "S", "T")
  assert_eq(mf.max_throughput_units_per_hour, 1200.0)
}
