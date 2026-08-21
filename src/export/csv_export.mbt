///|
pub fn export_nodes_csv(graph : @graph.FactoryGraph) -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "id,name,node_type,zone,cycle_time_sec,nominal_power_kw,capacity,status,safety_zone_id\n",
  )
  let nodes = graph.get_all_nodes()
  for n in nodes {
    buf.write_string(
      n.id() +
      ",\"" +
      n.name() +
      "\"," +
      n.node_type().to_string() +
      "," +
      n.zone() +
      "," +
      n.cycle_time_sec().to_string() +
      "," +
      n.nominal_power_kw().to_string() +
      "," +
      n.capacity().to_string() +
      "," +
      n.status().to_string() +
      "," +
      n.safety_zone_id() +
      "\n",
    )
  }
  buf.to_string()
}

///|
pub fn export_edges_csv(graph : @graph.FactoryGraph) -> String {
  let buf = StringBuilder::new()
  buf.write_string(
    "id,source_id,target_id,flow_type,bandwidth_units_per_hour,transport_delay_sec,is_active\n",
  )
  let edges = graph.get_all_edges()
  for e in edges {
    buf.write_string(
      e.id() +
      "," +
      e.source_id() +
      "," +
      e.target_id() +
      "," +
      e.flow_type().to_string() +
      "," +
      e.bandwidth().to_string() +
      "," +
      e.transport_delay_sec().to_string() +
      "," +
      (if e.is_active() { "true" } else { "false" }) +
      "\n",
    )
  }
  buf.to_string()
}
