///|
pub fn export_to_json(graph : @graph.FactoryGraph) -> String {
  let buf = StringBuilder::new()
  let cfg = graph.config()

  buf.write_string("{\n")
  buf.write_string(
    "  \"plant_name\": \"" + @types.json_escape_string(cfg.plant_name) + "\",\n",
  )
  buf.write_string(
    "  \"site_location\": \"" +
    @types.json_escape_string(cfg.site_location) +
    "\",\n",
  )
  buf.write_string(
    "  \"version\": \"" + @types.json_escape_string(cfg.version) + "\",\n",
  )
  buf.write_string(
    "  \"takt_time_target_sec\": " +
    cfg.takt_time_target_sec.to_string() +
    ",\n",
  )

  // Nodes
  buf.write_string("  \"nodes\": [\n")
  let nodes = graph.get_all_nodes()
  for i = 0; i < nodes.length(); i = i + 1 {
    let n = nodes[i]
    buf.write_string("    {\n")
    buf.write_string("      \"id\": \"" + n.id() + "\",\n")
    buf.write_string(
      "      \"name\": \"" + @types.json_escape_string(n.name()) + "\",\n",
    )
    buf.write_string(
      "      \"node_type\": \"" + n.node_type().to_string() + "\",\n",
    )
    buf.write_string("      \"zone\": \"" + n.zone() + "\",\n")
    buf.write_string(
      "      \"cycle_time_sec\": " + n.cycle_time_sec().to_string() + ",\n",
    )
    buf.write_string(
      "      \"nominal_power_kw\": " + n.nominal_power_kw().to_string() + ",\n",
    )
    buf.write_string("      \"capacity\": " + n.capacity().to_string() + ",\n")
    buf.write_string("      \"status\": \"" + n.status().to_string() + "\",\n")
    buf.write_string(
      "      \"safety_zone_id\": \"" + n.safety_zone_id() + "\"\n",
    )
    buf.write_string("    }")
    if i < nodes.length() - 1 {
      buf.write_string(",")
    }
    buf.write_string("\n")
  }
  buf.write_string("  ],\n")

  // Edges
  buf.write_string("  \"edges\": [\n")
  let edges = graph.get_all_edges()
  for i = 0; i < edges.length(); i = i + 1 {
    let e = edges[i]
    buf.write_string("    {\n")
    buf.write_string("      \"id\": \"" + e.id() + "\",\n")
    buf.write_string("      \"source_id\": \"" + e.source_id() + "\",\n")
    buf.write_string("      \"target_id\": \"" + e.target_id() + "\",\n")
    buf.write_string(
      "      \"flow_type\": \"" + e.flow_type().to_string() + "\",\n",
    )
    buf.write_string(
      "      \"bandwidth\": " + e.bandwidth().to_string() + ",\n",
    )
    buf.write_string(
      "      \"transport_delay_sec\": " +
      e.transport_delay_sec().to_string() +
      ",\n",
    )
    buf.write_string(
      "      \"is_active\": " +
      (if e.is_active() { "true" } else { "false" }) +
      "\n",
    )
    buf.write_string("    }")
    if i < edges.length() - 1 {
      buf.write_string(",")
    }
    buf.write_string("\n")
  }
  buf.write_string("  ]\n")
  buf.write_string("}\n")
  buf.to_string()
}
