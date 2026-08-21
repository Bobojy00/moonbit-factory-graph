///|
pub fn export_to_plantuml(graph : @graph.FactoryGraph) -> String {
  let buf = StringBuilder::new()
  buf.write_string("@startuml\n")
  buf.write_string("skinparam componentStyle uml2\n\n")

  let zones = graph.get_all_zones()
  for z in zones {
    buf.write_string("package \"" + z + "\" {\n")
    let z_nodes = graph.get_nodes_in_zone(z)
    for n in z_nodes {
      buf.write_string("  [" + n.name() + "] as " + n.id() + "\n")
    }
    buf.write_string("}\n\n")
  }

  let edges = graph.get_all_edges()
  for e in edges {
    if e.is_active() {
      let arrow = match e.flow_type() {
        MaterialFlow => "-->"
        ControlFlow => "..>"
        EnergyFlow => "==>"
        SafetyInterlock => "..[#red]>"
        _ => "-->"
      }
      buf.write_string(
        e.source_id() +
        " " +
        arrow +
        " " +
        e.target_id() +
        " : " +
        e.flow_type().to_string() +
        "\n",
      )
    }
  }

  buf.write_string("@enduml\n")
  buf.to_string()
}
