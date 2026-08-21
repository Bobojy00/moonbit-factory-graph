///|
pub fn export_to_mermaid(
  graph : @graph.FactoryGraph,
  direction? : String = "TD",
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("graph " + direction + "\n")

  let zones = graph.get_all_zones()
  let mut z_idx = 0
  for z in zones {
    z_idx = z_idx + 1
    buf.write_string(
      "  subgraph Sub_" + z_idx.to_string() + " [\"" + z + "\"]\n",
    )
    let z_nodes = graph.get_nodes_in_zone(z)
    for n in z_nodes {
      let label = n.id() + " - " + n.name()
      buf.write_string("    " + n.id() + "[\"" + label + "\"]\n")
    }
    buf.write_string("  end\n")
  }

  let edges = graph.get_all_edges()
  for e in edges {
    if e.is_active() {
      let ft = e.flow_type()
      let link_symbol = match ft {
        MaterialFlow => "-->"
        ControlFlow => "-.->"
        EnergyFlow => "==>"
        SafetyInterlock => "-. Safety .->"
        _ => "-->"
      }
      buf.write_string(
        "  " +
        e.source_id() +
        " " +
        link_symbol +
        "|\"" +
        ft.to_string() +
        "\"| " +
        e.target_id() +
        "\n",
      )
    }
  }

  buf.to_string()
}
