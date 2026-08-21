///|
pub fn validate_graph(graph : FactoryGraph) -> Array[@types.ValidationIssue] {
  let issues = []

  // Check for dangling edges
  let all_edges = graph.get_all_edges()
  for edge in all_edges {
    let src = edge.source_id()
    let dst = edge.target_id()
    if !graph.has_node(src) {
      issues.push(
        @types.ValidationIssue::new(
          "RULE-DANGLING-SRC",
          @types.ValidationSeverity::Critical,
          edge.id(),
          "Edge references non-existent source node: " + src,
          suggested_fix="Create node " + src + " or remove edge " + edge.id(),
        ),
      )
    }
    if !graph.has_node(dst) {
      issues.push(
        @types.ValidationIssue::new(
          "RULE-DANGLING-DST",
          @types.ValidationSeverity::Critical,
          edge.id(),
          "Edge references non-existent target node: " + dst,
          suggested_fix="Create node " + dst + " or remove edge " + edge.id(),
        ),
      )
    }
  }

  // Check for isolated nodes (no in or out edges at all)
  let all_nodes = graph.get_all_nodes()
  for node in all_nodes {
    let id = node.id()
    let in_e = graph.get_in_edges(id)
    let out_e = graph.get_out_edges(id)
    if in_e.length() == 0 && out_e.length() == 0 {
      issues.push(
        @types.ValidationIssue::new(
          "RULE-ISOLATED-NODE",
          @types.ValidationSeverity::Warning,
          id,
          "Node " +
          id +
          " is completely isolated with 0 incoming or outgoing edges",
          suggested_fix="Connect node " +
            id +
            " to power, control, or material flows",
        ),
      )
    }
  }

  // Check for machines/workstations without power connection
  for node in all_nodes {
    let nt = node.node_type()
    if nt == @types.NodeType::Workstation ||
      nt == @types.NodeType::Machine ||
      nt == @types.NodeType::RobotArm {
      let pwr_in = graph.get_layer_in_edges(
        @types.FlowType::EnergyFlow,
        node.id(),
      )
      if pwr_in.length() == 0 {
        issues.push(
          @types.ValidationIssue::new(
            "RULE-UNPOWERED-ASSET",
            @types.ValidationSeverity::Error,
            node.id(),
            "Operational asset " +
            node.id() +
            " has no incoming EnergyFlow connection",
            suggested_fix="Connect a PowerSource to " + node.id(),
          ),
        )
      }
    }
  }

  // Check for PLC controllers with zero control connections
  for node in all_nodes {
    if node.node_type() == @types.NodeType::PLCController {
      let ctl_out = graph.get_layer_out_edges(
        @types.FlowType::ControlFlow,
        node.id(),
      )
      if ctl_out.length() == 0 {
        issues.push(
          @types.ValidationIssue::new(
            "RULE-PLC-DISCONNECTED",
            @types.ValidationSeverity::Warning,
            node.id(),
            "PLC Controller " +
            node.id() +
            " has no outgoing ControlFlow connections",
            suggested_fix="Connect PLC to field workstations or actuators",
          ),
        )
      }
    }
  }

  issues
}
