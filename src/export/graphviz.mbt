///|
fn node_shape_for_type(nt : @types.NodeType) -> String {
  match nt {
    Workstation => "box"
    Machine => "component"
    Conveyor => "cds"
    Buffer => "cylinder"
    Sensor => "diamond"
    PowerSource => "house"
    SafetyGate => "hexagon"
    AGVTrack => "tab"
    Diverter => "trapezium"
    Inspection => "invtrapezium"
    StorageRack => "folder"
    RobotArm => "doublecircle"
    PneumaticPump => "oval"
    Chiller => "septagon"
    PLCController => "square"
  }
}

///|
fn edge_color_for_flow(ft : @types.FlowType) -> (String, String) {
  match ft {
    MaterialFlow => ("#2ecc71", "solid")
    ControlFlow => ("#3498db", "dashed")
    EnergyFlow => ("#e67e22", "bold")
    SafetyInterlock => ("#e74c3c", "dotted")
    PneumaticFlow => ("#1abc9c", "solid")
    CoolantFlow => ("#9b59b6", "solid")
    DataTelemetry => ("#95a5a6", "dashed")
  }
}

///|
pub fn export_to_graphviz_dot(
  graph : @graph.FactoryGraph,
  title? : String = "FactoryTopology",
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("digraph " + title + " {\n")
  buf.write_string(
    "  graph [rankdir=LR, bgcolor=\"#f8f9fa\", fontname=\"Helvetica\"];\n",
  )
  buf.write_string(
    "  node [fontname=\"Helvetica\", style=\"filled\", fillcolor=\"#ffffff\", color=\"#333333\"];\n",
  )
  buf.write_string("  edge [fontname=\"Helvetica\", fontsize=10];\n\n")

  // Zones as clustered subgraphs
  let zones = graph.get_all_zones()
  let mut cluster_idx = 0
  for z in zones {
    cluster_idx = cluster_idx + 1
    buf.write_string("  subgraph cluster_" + cluster_idx.to_string() + " {\n")
    buf.write_string("    label = \"" + z + "\";\n")
    buf.write_string("    style = \"filled,rounded\";\n")
    buf.write_string("    color = \"#bdc3c7\";\n")
    buf.write_string("    fillcolor = \"#ecf0f1\";\n")

    let zone_nodes = graph.get_nodes_in_zone(z)
    for n in zone_nodes {
      let shape = node_shape_for_type(n.node_type())
      let label = n.id() +
        "\\n" +
        n.name() +
        "\\n(" +
        n.node_type().to_string() +
        ")"
      buf.write_string(
        "    \"" +
        n.id() +
        "\" [label=\"" +
        label +
        "\", shape=" +
        shape +
        "];\n",
      )
    }
    buf.write_string("  }\n\n")
  }

  // Edges
  let edges = graph.get_all_edges()
  for e in edges {
    if e.is_active() {
      let (color, style) = edge_color_for_flow(e.flow_type())
      let label = e.flow_type().to_string() +
        " (" +
        e.bandwidth().to_string() +
        " u/h)"
      buf.write_string(
        "  \"" +
        e.source_id() +
        "\" -> \"" +
        e.target_id() +
        "\" [label=\"" +
        label +
        "\", color=\"" +
        color +
        "\", style=\"" +
        style +
        "\"];\n",
      )
    }
  }

  buf.write_string("}\n")
  buf.to_string()
}
