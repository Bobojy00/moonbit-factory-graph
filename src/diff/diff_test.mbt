///|
test "topology_diff_comparison" {
  let builder_v1 = @graph.FactoryGraphBuilder::new(plant_name="Plant_V1")
  let g1 = builder_v1
    .add_workstation("WS-1", "Machining Station 1", cycle_time_sec=20.0)
    .add_workstation("WS-2", "Assembly Station 2", cycle_time_sec=25.0)
    .connect_material("WS-1", "WS-2", bandwidth=1200.0)
    .build()

  let builder_v2 = @graph.FactoryGraphBuilder::new(plant_name="Plant_V2")
  let g2 = builder_v2
    .add_workstation("WS-1", "Machining Station 1", cycle_time_sec=28.0) // Cycle time increased!
    .add_workstation("WS-3", "Automated Inspection", cycle_time_sec=15.0) // Added WS-3, removed WS-2
    .connect_material("WS-1", "WS-3", bandwidth=1200.0)
    .build()

  let diff_rep = compare_factory_topologies(g1, g2)
  assert_eq(diff_rep.added_nodes, ["WS-3"])
  assert_eq(diff_rep.removed_nodes, ["WS-2"])
  assert_eq(diff_rep.modified_nodes.length(), 1)
  assert_eq(diff_rep.mitigation_recommendations.length(), 1)
}
