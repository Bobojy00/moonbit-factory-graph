///|
pub fn compare_factory_topologies(
  base_graph : @graph.FactoryGraph,
  target_graph : @graph.FactoryGraph,
) -> TopologyDiffReport {
  let added_nodes = []
  let removed_nodes = []
  let modified_nodes = []
  let breaking_changes = []
  let recommendations = []

  let base_nodes = base_graph.get_all_nodes()
  let target_nodes = target_graph.get_all_nodes()

  // Check removed and modified nodes
  for base_n in base_nodes {
    let nid = base_n.id()
    match target_graph.get_node(nid) {
      None => {
        removed_nodes.push(nid)
        if base_n.node_type() == @types.NodeType::PowerSource ||
          base_n.node_type() == @types.NodeType::PLCController {
          breaking_changes.push(
            "Removed core plant infrastructure node: " + nid,
          )
        }
      }
      Some(tgt_n) => {
        let prop_changes = []
        if base_n.cycle_time_sec() != tgt_n.cycle_time_sec() {
          let ct_increased = tgt_n.cycle_time_sec() > base_n.cycle_time_sec()
          prop_changes.push({
            field_name: "cycle_time_sec",
            old_value: base_n.cycle_time_sec().to_string(),
            new_value: tgt_n.cycle_time_sec().to_string(),
            is_breaking: ct_increased,
          })
          if ct_increased {
            recommendations.push(
              "Node " +
              nid +
              " cycle time increased from " +
              base_n.cycle_time_sec().to_string() +
              "s to " +
              tgt_n.cycle_time_sec().to_string() +
              "s; check takt time impact.",
            )
          }
        }

        if base_n.nominal_power_kw() != tgt_n.nominal_power_kw() {
          prop_changes.push({
            field_name: "nominal_power_kw",
            old_value: base_n.nominal_power_kw().to_string(),
            new_value: tgt_n.nominal_power_kw().to_string(),
            is_breaking: false,
          })
        }

        if base_n.safety_zone_id() != tgt_n.safety_zone_id() {
          prop_changes.push({
            field_name: "safety_zone_id",
            old_value: base_n.safety_zone_id(),
            new_value: tgt_n.safety_zone_id(),
            is_breaking: true,
          })
          breaking_changes.push(
            "Node " +
            nid +
            " safety domain reassigned from " +
            base_n.safety_zone_id() +
            " to " +
            tgt_n.safety_zone_id(),
          )
        }

        if prop_changes.length() > 0 {
          modified_nodes.push({
            node_id: nid,
            diff_type: NodeDiffType::NodeModified,
            property_changes: prop_changes,
          })
        }
      }
    }
  }

  // Check added nodes
  for tgt_n in target_nodes {
    let nid = tgt_n.id()
    if !base_graph.has_node(nid) {
      added_nodes.push(nid)
    }
  }

  // Check edges
  let added_edges = []
  let removed_edges = []
  let modified_edges = []

  let base_edges = base_graph.get_all_edges()
  let target_edges = target_graph.get_all_edges()

  for base_e in base_edges {
    let eid = base_e.id()
    match target_graph.get_edge(eid) {
      None => {
        removed_edges.push(eid)
        if base_e.flow_type() == @types.FlowType::SafetyInterlock ||
          base_e.flow_type() == @types.FlowType::EnergyFlow {
          breaking_changes.push(
            "Removed critical flow connection: " +
            eid +
            " (" +
            base_e.source_id() +
            " -> " +
            base_e.target_id() +
            ")",
          )
        }
      }
      Some(tgt_e) =>
        if base_e.bandwidth() != tgt_e.bandwidth() {
          modified_edges.push({
            edge_id: eid,
            source_id: base_e.source_id(),
            target_id: base_e.target_id(),
            flow_type: base_e.flow_type(),
            diff_type: EdgeDiffType::EdgeModified,
            old_bandwidth: base_e.bandwidth(),
            new_bandwidth: tgt_e.bandwidth(),
          })
        }
    }
  }

  for tgt_e in target_edges {
    let eid = tgt_e.id()
    if !base_graph.has_edge(eid) {
      added_edges.push(eid)
    }
  }

  // Compute risk score
  let mut score = 0.0
  score = score + removed_nodes.length().to_double() * 15.0
  score = score + removed_edges.length().to_double() * 10.0
  score = score + breaking_changes.length().to_double() * 20.0
  score = score + modified_nodes.length().to_double() * 5.0

  if score > 100.0 {
    score = 100.0
  }

  let risk_level = if score >= 70.0 {
    MigrationRiskLevel::CriticalRisk
  } else if score >= 40.0 {
    MigrationRiskLevel::HighRisk
  } else if score >= 15.0 {
    MigrationRiskLevel::MediumRisk
  } else {
    MigrationRiskLevel::LowRisk
  }

  {
    added_nodes,
    removed_nodes,
    modified_nodes,
    added_edges,
    removed_edges,
    modified_edges,
    overall_risk_level: risk_level,
    risk_score: score,
    breaking_changes,
    mitigation_recommendations: recommendations,
  }
}
