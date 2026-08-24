///|
test "root_facade_end_to_end" {
  let g = load_automotive_plant()
  assert_eq(g.node_count() > 20, true)

  let p = find_shortest_material_path(g, "STAMP-UNCOIL", "ASSY-INSPECT")
  match p {
    Some(res) => assert_eq(res.nodes.length() > 5, true)
    None => abort("Expected material path across full automotive line")
  }

  let outage = simulate_plant_outage(g, "WELD-FLOOR")
  assert_eq(outage.failed_node_id, "WELD-FLOOR")
  assert_eq(outage.affected_workstations_count > 0, true)

  let b_rep = analyze_bottlenecks(g)
  assert_eq(b_rep.primary_bottleneck_node_id.length() > 0, true)

  let dot_str = export_dot(g)
  assert_eq(dot_str.length() > 100, true)

  let mermaid_str = export_mermaid_diagram(g)
  assert_eq(mermaid_str.length() > 100, true)

  let json_str = export_json_spec(g)
  assert_eq(json_str.length() > 100, true)

  let audit = generate_audit_report(g)
  assert_eq(audit.length() > 100, true)

  let health = inspect_graph_health(g)
  assert_eq(health.total_node_count, g.node_count())
  assert_eq(health.total_edge_count, g.edge_count())

  let capacity = analyze_material_capacity(g)
  assert_eq(capacity.demand_per_hour > 0.0, true)
  assert_eq(capacity.output_capacity_per_hour > 0.0, true)

  let portfolio = evaluate_outage_portfolio(g, [
    "SUB-02", "WELD-FLOOR", "UNKNOWN-ASSET",
  ])
  assert_eq(portfolio.valid_scenario_count, 2)
  assert_eq(portfolio.invalid_node_ids, ["UNKNOWN-ASSET"])
}
