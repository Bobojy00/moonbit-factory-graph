///|
/// One deduplicated outage candidate and its modeled operational impact.
pub(all) struct OutageScenarioScore {
  failed_node_id : String
  affected_asset_count : Int
  affected_workstations_count : Int
  capacity_loss_percent : Double
  estimated_hourly_loss_cny : Double
  resilience_score : Double
  risk_band : String
} derive(Debug, Eq)

///|
/// Aggregate result for a batch of outage candidates.
pub(all) struct OutagePortfolioReport {
  valid_scenario_count : Int
  invalid_node_ids : Array[String]
  scenarios : Array[OutageScenarioScore]
  worst_case_node_id : String
  max_capacity_loss_percent : Double
  average_capacity_loss_percent : Double
} derive(Debug, Eq)

///|
fn risk_band(score : Double) -> String {
  if score >= 80.0 {
    "low"
  } else if score >= 50.0 {
    "moderate"
  } else {
    "high"
  }
}

///|
fn scenario_score(
  graph : @graph.FactoryGraph,
  node_id : String,
  hourly_downtime_cost : Double,
) -> OutageScenarioScore {
  let result = simulate_device_outage(graph, node_id, hourly_downtime_cost~)
  let resilience = if result.production_capacity_loss_percent >= 100.0 {
    0.0
  } else {
    100.0 - result.production_capacity_loss_percent
  }
  {
    failed_node_id: node_id,
    affected_asset_count: result.all_impacted_nodes.length(),
    affected_workstations_count: result.affected_workstations_count,
    capacity_loss_percent: result.production_capacity_loss_percent,
    estimated_hourly_loss_cny: result.estimated_hourly_loss_cny,
    resilience_score: resilience,
    risk_band: risk_band(resilience),
  }
}

///|
/// Evaluate unique outage candidates while retaining unknown IDs for input QA.
///
/// Scenarios are evaluated in first-seen order. Duplicate IDs are ignored so
/// a caller can safely concatenate candidate lists from several asset teams.
pub fn evaluate_outage_portfolio(
  graph : @graph.FactoryGraph,
  candidate_node_ids : Array[String],
  hourly_downtime_cost? : Double = 50000.0,
) -> OutagePortfolioReport {
  let seen_valid : Map[String, Bool] = Map([])
  let seen_invalid : Map[String, Bool] = Map([])
  let scenarios = []
  let invalid = []
  for node_id in candidate_node_ids {
    if graph.has_node(node_id) {
      if !seen_valid.contains(node_id) {
        seen_valid[node_id] = true
        scenarios.push(scenario_score(graph, node_id, hourly_downtime_cost))
      }
    } else if !seen_invalid.contains(node_id) {
      seen_invalid[node_id] = true
      invalid.push(node_id)
    }
  }

  let mut total_loss = 0.0
  let mut max_loss = 0.0
  let mut worst_case = ""
  for scenario in scenarios {
    total_loss = total_loss + scenario.capacity_loss_percent
    if scenario.capacity_loss_percent > max_loss || worst_case == "" {
      max_loss = scenario.capacity_loss_percent
      worst_case = scenario.failed_node_id
    }
  }
  let average_loss = if scenarios.length() > 0 {
    total_loss / scenarios.length().to_double()
  } else {
    0.0
  }
  {
    valid_scenario_count: scenarios.length(),
    invalid_node_ids: invalid,
    scenarios,
    worst_case_node_id: worst_case,
    max_capacity_loss_percent: max_loss,
    average_capacity_loss_percent: average_loss,
  }
}
