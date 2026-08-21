///|
pub(all) struct PlantHealthKPIs {
  total_asset_count : Int
  active_asset_count : Int
  operational_availability_percent : Double
  total_power_demand_kw : Double
  target_takt_time_sec : Double
  max_output_per_hour : Double
  plant_health_score : Double
} derive(Debug, Eq)

///|
pub fn compute_plant_kpis(graph : @graph.FactoryGraph) -> PlantHealthKPIs {
  let total_nodes = graph.node_count()
  let active_nodes = graph.calculate_active_nodes_count()
  let total_power = graph.calculate_total_power_kw()
  let b_report = analyze_production_bottlenecks(graph)

  let avail_pct = if total_nodes > 0 {
    active_nodes.to_double() / total_nodes.to_double() * 100.0
  } else {
    0.0
  }

  let health_score = avail_pct * 0.5 +
    b_report.line_balance_efficiency_percent * 0.5

  {
    total_asset_count: total_nodes,
    active_asset_count: active_nodes,
    operational_availability_percent: avail_pct,
    total_power_demand_kw: total_power,
    target_takt_time_sec: b_report.takt_time_target_sec,
    max_output_per_hour: b_report.max_theoretical_hourly_output,
    plant_health_score: health_score,
  }
}
