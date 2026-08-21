///|
test "exporters_dot_mermaid_json_report" {
  let builder = @graph.FactoryGraphBuilder::new(plant_name="ExportTestPlant")
  let g = builder
    .add_workstation(
      "A",
      "Station A",
      cycle_time_sec=20.0,
      nominal_power_kw=10.0,
      safety_zone_id="SZ-1",
    )
    .add_workstation(
      "B",
      "Station B",
      cycle_time_sec=30.0,
      nominal_power_kw=20.0,
      safety_zone_id="SZ-1",
    )
    .connect_material("A", "B", bandwidth=1200.0)
    .build()

  let dot = export_to_graphviz_dot(g)
  assert_eq(dot.length() > 0, true)

  let mermaid = export_to_mermaid(g)
  assert_eq(mermaid.length() > 0, true)

  let puml = export_to_plantuml(g)
  assert_eq(puml.length() > 0, true)

  let json_str = export_to_json(g)
  assert_eq(json_str.length() > 0, true)

  let rep = generate_executive_audit_report(g)
  assert_eq(rep.length() > 0, true)

  let nodes_csv = export_nodes_csv(g)
  assert_eq(nodes_csv.length() > 0, true)

  let edges_csv = export_edges_csv(g)
  assert_eq(edges_csv.length() > 0, true)
}
