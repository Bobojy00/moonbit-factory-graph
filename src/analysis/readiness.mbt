///|
pub(all) enum ReadinessLevel {
  Ready
  Conditional
  Blocked
} derive(Debug, Eq, Compare)

///|
pub fn ReadinessLevel::to_string(self : ReadinessLevel) -> String {
  match self {
    Ready => "Ready"
    Conditional => "Conditional"
    Blocked => "Blocked"
  }
}

///|
pub(all) struct OperationalReadinessReport {
  readiness_level : ReadinessLevel
  ready_for_deployment : Bool
  readiness_score : Double
  total_validation_issue_count : Int
  critical_issue_count : Int
  error_issue_count : Int
  warning_issue_count : Int
  orphan_node_ids : Array[String]
  inactive_node_ids : Array[String]
  inactive_edge_ids : Array[String]
  unpowered_asset_ids : Array[String]
  disconnected_controller_ids : Array[String]
  congested_edge_ids : Array[String]
  active_node_ratio_percent : Double
  active_edge_ratio_percent : Double
  mean_asset_availability_percent : Double
  active_flow_layer_count : Int
  capacity_margin_percent : Double
  recommendations : Array[String]
} derive(Debug, Eq)

///|
fn append_unique(values : Array[String], value : String) -> Unit {
  if !values.contains(value) {
    values.push(value)
  }
}

///|
fn is_readiness_asset(node : @graph.Node) -> Bool {
  let node_type = node.node_type()
  node_type == @types.NodeType::Workstation ||
  node_type == @types.NodeType::Machine ||
  node_type == @types.NodeType::RobotArm
}

///|
fn clamp_percent(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 100.0 {
    100.0
  } else {
    value
  }
}

///|
fn active_ratio(active : Int, total : Int) -> Double {
  if total == 0 {
    100.0
  } else {
    active.to_double() / total.to_double() * 100.0
  }
}

///|
fn add_recommendation(
  recommendations : Array[String],
  message : String,
) -> Unit {
  if !recommendations.contains(message) {
    recommendations.push(message)
  }
}

///|
fn classify_readiness(
  critical_count : Int,
  error_count : Int,
  inactive_nodes : Int,
  inactive_edges : Int,
  score : Double,
) -> ReadinessLevel {
  if critical_count > 0 || error_count > 0 {
    Blocked
  } else if inactive_nodes > 0 || inactive_edges > 0 || score < 80.0 {
    Conditional
  } else {
    Ready
  }
}

///|
fn score_readiness(
  critical_count : Int,
  error_count : Int,
  warning_count : Int,
  inactive_node_ratio : Double,
  inactive_edge_ratio : Double,
  congested_count : Int,
) -> Double {
  let issue_penalty = critical_count.to_double() * 30.0 +
    error_count.to_double() * 18.0 +
    warning_count.to_double() * 4.0
  let topology_penalty = inactive_node_ratio * 0.20 + inactive_edge_ratio * 0.15
  let congestion_penalty = congested_count.to_double() * 5.0
  clamp_percent(100.0 - issue_penalty - topology_penalty - congestion_penalty)
}

///|
fn collect_validation_findings(
  issues : Array[@types.ValidationIssue],
  unpowered_assets : Array[String],
  disconnected_controllers : Array[String],
) -> (Int, Int, Int) {
  let mut critical_count = 0
  let mut error_count = 0
  let mut warning_count = 0
  for issue in issues {
    match issue.severity {
      @types.ValidationSeverity::Critical => critical_count = critical_count + 1
      @types.ValidationSeverity::Error => error_count = error_count + 1
      @types.ValidationSeverity::Warning => warning_count = warning_count + 1
      @types.ValidationSeverity::Info => ()
    }
    if issue.rule_id == "RULE-UNPOWERED-ASSET" {
      append_unique(unpowered_assets, issue.target_id)
    }
    if issue.rule_id == "RULE-PLC-DISCONNECTED" {
      append_unique(disconnected_controllers, issue.target_id)
    }
  }
  (critical_count, error_count, warning_count)
}

///|
fn collect_node_findings(
  graph : @graph.FactoryGraph,
  inactive_nodes : Array[String],
  unpowered_assets : Array[String],
  disconnected_controllers : Array[String],
) -> Double {
  let nodes = graph.get_all_nodes()
  let mut availability_sum = 0.0
  for node in nodes {
    availability_sum = availability_sum + node.availability() * 100.0
    if !node.is_operational() {
      inactive_nodes.push(node.id())
    }
    if is_readiness_asset(node) {
      let power_edges = graph.get_layer_in_edges(
        @types.FlowType::EnergyFlow,
        node.id(),
      )
      if power_edges.length() == 0 {
        append_unique(unpowered_assets, node.id())
      }
    }
    if node.node_type() == @types.NodeType::PLCController {
      let control_edges = graph.get_layer_out_edges(
        @types.FlowType::ControlFlow,
        node.id(),
      )
      if control_edges.length() == 0 {
        append_unique(disconnected_controllers, node.id())
      }
    }
  }
  if nodes.length() == 0 {
    100.0
  } else {
    availability_sum / nodes.length().to_double()
  }
}

///|
fn collect_edge_findings(
  graph : @graph.FactoryGraph,
  inactive_edges : Array[String],
) -> (Int, Int) {
  let edges = graph.get_all_edges()
  let mut active_count = 0
  for edge in edges {
    if edge.is_active() {
      active_count = active_count + 1
    } else {
      inactive_edges.push(edge.id())
    }
  }
  (active_count, edges.length())
}

///|
fn collect_recommendations(
  level : ReadinessLevel,
  orphan_nodes : Array[String],
  inactive_nodes : Array[String],
  inactive_edges : Array[String],
  unpowered_assets : Array[String],
  disconnected_controllers : Array[String],
  congested_edges : Array[String],
  recommendations : Array[String],
) -> Unit {
  if level == ReadinessLevel::Ready {
    add_recommendation(
      recommendations, "Topology is ready for deployment; keep the validation report with the release artifact.",
    )
  }
  if orphan_nodes.length() > 0 {
    add_recommendation(
      recommendations,
      "Connect or explicitly document orphan assets before commissioning: " +
      orphan_nodes.length().to_string() +
      " asset(s).",
    )
  }
  if inactive_nodes.length() > 0 {
    add_recommendation(
      recommendations, "Review inactive or maintenance assets and confirm the intended production window.",
    )
  }
  if inactive_edges.length() > 0 {
    add_recommendation(
      recommendations, "Restore or approve inactive flow edges before relying on their capacity.",
    )
  }
  if unpowered_assets.length() > 0 {
    add_recommendation(
      recommendations, "Provide an EnergyFlow connection for every production asset without incoming power.",
    )
  }
  if disconnected_controllers.length() > 0 {
    add_recommendation(
      recommendations, "Connect PLC controllers to their field assets through the ControlFlow layer.",
    )
  }
  if congested_edges.length() > 0 {
    add_recommendation(
      recommendations, "Increase bandwidth or reduce demand on congested material edges before launch.",
    )
  }
  if level == ReadinessLevel::Conditional {
    add_recommendation(
      recommendations, "Resolve conditional findings and rerun the readiness audit after topology changes.",
    )
  }
  if level == ReadinessLevel::Blocked {
    add_recommendation(
      recommendations, "Do not deploy until critical and error-level topology findings are resolved.",
    )
  }
}

///|
/// Audit whether a plant graph is complete enough for operational deployment.
///
/// The report combines structural validation, node/edge operating status,
/// flow-layer completeness, material capacity, and asset availability. It is
/// intentionally deterministic so it can be used in release gates and in
/// offline engineering review tools.
pub fn audit_operational_readiness(
  graph : @graph.FactoryGraph,
  demand_per_hour? : Double = 0.0,
) -> OperationalReadinessReport {
  let issues = @graph.validate_graph(graph)
  let health = @graph.inspect_graph_health(graph)
  let capacity = analyze_material_capacity(graph, demand_per_hour~)
  let inactive_nodes : Array[String] = []
  let inactive_edges : Array[String] = []
  let unpowered_assets : Array[String] = []
  let disconnected_controllers : Array[String] = []

  let (critical_count, error_count, warning_count) = collect_validation_findings(
    issues, unpowered_assets, disconnected_controllers,
  )
  let mean_availability = collect_node_findings(
    graph, inactive_nodes, unpowered_assets, disconnected_controllers,
  )
  let (active_edge_count, total_edge_count) = collect_edge_findings(
    graph, inactive_edges,
  )
  let active_node_ratio = active_ratio(
    health.active_node_count,
    health.total_node_count,
  )
  let active_edge_ratio = active_ratio(active_edge_count, total_edge_count)
  let inactive_node_ratio = 100.0 - active_node_ratio
  let inactive_edge_ratio = 100.0 - active_edge_ratio
  let score = score_readiness(
    critical_count,
    error_count,
    warning_count,
    inactive_node_ratio,
    inactive_edge_ratio,
    capacity.overloaded_edge_ids.length(),
  )
  let level = classify_readiness(
    critical_count,
    error_count,
    inactive_nodes.length(),
    inactive_edges.length(),
    score,
  )
  let active_layers = health.layer_health
    .filter(fn(layer) { layer.active_edge_count > 0 })
    .length()
  let recommendations : Array[String] = []
  collect_recommendations(
    level,
    health.orphan_node_ids,
    inactive_nodes,
    inactive_edges,
    unpowered_assets,
    disconnected_controllers,
    capacity.overloaded_edge_ids,
    recommendations,
  )
  {
    readiness_level: level,
    ready_for_deployment: level == ReadinessLevel::Ready,
    readiness_score: score,
    total_validation_issue_count: issues.length(),
    critical_issue_count: critical_count,
    error_issue_count: error_count,
    warning_issue_count: warning_count,
    orphan_node_ids: health.orphan_node_ids,
    inactive_node_ids: inactive_nodes,
    inactive_edge_ids: inactive_edges,
    unpowered_asset_ids: unpowered_assets,
    disconnected_controller_ids: disconnected_controllers,
    congested_edge_ids: capacity.overloaded_edge_ids,
    active_node_ratio_percent: active_node_ratio,
    active_edge_ratio_percent: active_edge_ratio,
    mean_asset_availability_percent: mean_availability,
    active_flow_layer_count: active_layers,
    capacity_margin_percent: capacity.capacity_margin_percent,
    recommendations,
  }
}
