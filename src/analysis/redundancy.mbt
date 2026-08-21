///|
pub(all) struct RedundancyReport {
  overall_resilience_index : Double
  fully_redundant_routes_count : Int
  single_point_vulnerable_stations : Array[String]
  bypass_path_available : Bool
  resilience_grade : String
} derive(Debug, Eq)

///|
pub fn evaluate_line_redundancy(
  graph : @graph.FactoryGraph,
  source_id : String,
  target_id : String,
) -> RedundancyReport {
  let disjoint_paths = @algorithms.find_disjoint_paths(
    graph,
    source_id,
    target_id,
    flow_type=@types.FlowType::MaterialFlow,
    node_disjoint=true,
  )
  let k_paths = @algorithms.k_shortest_paths(graph, source_id, target_id, 3)
  let spofs = @algorithms.find_critical_spof_assets(graph)

  let disjoint_count = disjoint_paths.length()
  let has_bypass = disjoint_count > 1 || k_paths.length() > 1

  let mut score = 50.0
  if disjoint_count >= 2 {
    score = score + 30.0
  }
  if k_paths.length() >= 2 {
    score = score + 10.0
  }
  let spof_penalty = spofs.single_points_of_failure.length().to_double() * 5.0
  score = score - spof_penalty
  if score < 0.0 {
    score = 0.0
  }
  if score > 100.0 {
    score = 100.0
  }

  let grade = if score >= 85.0 {
    "A (Highly Resilient - Redundant Topology)"
  } else if score >= 65.0 {
    "B (Adequate Resilience - Minor Single Points of Failure)"
  } else if score >= 40.0 {
    "C (Moderate Risk - Critical Serial Dependencies)"
  } else {
    "D (High Vulnerability - Immediate Line Redundancy Needed)"
  }

  {
    overall_resilience_index: score,
    fully_redundant_routes_count: disjoint_count,
    single_point_vulnerable_stations: spofs.single_points_of_failure,
    bypass_path_available: has_bypass,
    resilience_grade: grade,
  }
}
