///|
pub(all) struct RebalanceRecommendation {
  station_id : String
  current_cycle_time : Double
  target_takt_time : Double
  suggested_action : String
  suggested_parallel_count : Int
} derive(Debug, Eq)

///|
pub(all) struct LineBalancePlan {
  recommendations : Array[RebalanceRecommendation]
  current_smoothness_index : Double
  projected_smoothness_index : Double
  projected_throughput_increase_percent : Double
} derive(Debug, Eq)

///|
pub fn optimize_line_balance(graph : @graph.FactoryGraph) -> LineBalancePlan {
  let target_takt = graph.config().takt_time_target_sec
  let nodes = graph.get_all_nodes()
  let recs : Array[RebalanceRecommendation] = []

  let mut max_ct = 0.0
  let mut sum_sq_diff = 0.0
  let mut count = 0

  for node in nodes {
    let nt = node.node_type()
    if nt == @types.NodeType::Workstation ||
      nt == @types.NodeType::Machine ||
      nt == @types.NodeType::RobotArm {
      let ct = node.cycle_time_sec()
      if ct > 0.0 {
        count = count + 1
        if ct > max_ct {
          max_ct = ct
        }
        let diff = ct - target_takt
        sum_sq_diff = sum_sq_diff + diff * diff

        if ct > target_takt {
          let parallel_needed = (ct / target_takt + 0.999).to_int()
          let action = if parallel_needed > 1 {
            "Deploy " +
            parallel_needed.to_string() +
            " parallel units or split tooling into multiple stations"
          } else {
            "Optimize robot trajectory and reduce tooling transfer time"
          }
          recs.push({
            station_id: node.id(),
            current_cycle_time: ct,
            target_takt_time: target_takt,
            suggested_action: action,
            suggested_parallel_count: parallel_needed,
          })
        }
      }
    }
  }

  let current_si = if count > 0 { sum_sq_diff / count.to_double() } else { 0.0 }

  let projected_si = current_si * 0.25
  let projected_increase = if max_ct > target_takt && target_takt > 0.0 {
    (max_ct - target_takt) / target_takt * 100.0
  } else {
    0.0
  }

  {
    recommendations: recs,
    current_smoothness_index: current_si,
    projected_smoothness_index: projected_si,
    projected_throughput_increase_percent: projected_increase,
  }
}
