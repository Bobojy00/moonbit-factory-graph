///|
pub fn new_builder(
  plant_name? : String = "Automated Smart Factory",
  location? : String = "Industrial High-Tech Zone",
  takt_time_target_sec? : Double = 45.0,
) -> @graph.FactoryGraphBuilder {
  @graph.FactoryGraphBuilder::new(plant_name~, location~, takt_time_target_sec~)
}

///|
pub fn load_automotive_plant() -> @graph.FactoryGraph {
  @presets.build_automotive_plant()
}

///|
pub fn load_battery_plant() -> @graph.FactoryGraph {
  @presets.build_lithium_battery_plant()
}

///|
pub fn load_semiconductor_plant() -> @graph.FactoryGraph {
  @presets.build_semiconductor_packaging_plant()
}

///|
pub fn load_chemical_plant() -> @graph.FactoryGraph {
  @presets.build_chemical_plant()
}

///|
pub fn find_shortest_material_path(
  graph : @graph.FactoryGraph,
  src : String,
  dst : String,
) -> @algorithms.PathResult? {
  @algorithms.dijkstra_shortest_path(
    graph,
    src,
    dst,
    flow_type=@types.FlowType::MaterialFlow,
  )
}

///|
pub fn simulate_plant_outage(
  graph : @graph.FactoryGraph,
  failed_node_id : String,
) -> @analysis.OutageSimulationResult {
  @analysis.simulate_device_outage(graph, failed_node_id)
}

///|
pub fn analyze_bottlenecks(
  graph : @graph.FactoryGraph,
) -> @analysis.BottleneckAnalysisReport {
  @analysis.analyze_production_bottlenecks(graph)
}

///|
pub fn generate_audit_report(graph : @graph.FactoryGraph) -> String {
  @export.generate_executive_audit_report(graph)
}

///|
pub fn export_dot(graph : @graph.FactoryGraph) -> String {
  @export.export_to_graphviz_dot(graph)
}

///|
pub fn export_mermaid_diagram(graph : @graph.FactoryGraph) -> String {
  @export.export_to_mermaid(graph)
}

///|
pub fn export_json_spec(graph : @graph.FactoryGraph) -> String {
  @export.export_to_json(graph)
}

///|
pub fn diff_topologies(
  g1 : @graph.FactoryGraph,
  g2 : @graph.FactoryGraph,
) -> @diff.TopologyDiffReport {
  @diff.compare_factory_topologies(g1, g2)
}

///|
pub fn optimize_line(graph : @graph.FactoryGraph) -> @optimizer.LineBalancePlan {
  @optimizer.optimize_line_balance(graph)
}

///|
pub fn inspect_graph_health(
  graph : @graph.FactoryGraph,
) -> @graph.GraphHealthReport {
  @graph.inspect_graph_health(graph)
}

///|
pub fn analyze_material_capacity(
  graph : @graph.FactoryGraph,
  demand_per_hour? : Double = 0.0,
) -> @analysis.MaterialCapacityReport {
  @analysis.analyze_material_capacity(graph, demand_per_hour~)
}

///|
pub fn evaluate_outage_portfolio(
  graph : @graph.FactoryGraph,
  candidate_node_ids : Array[String],
  hourly_downtime_cost? : Double = 50000.0,
) -> @analysis.OutagePortfolioReport {
  @analysis.evaluate_outage_portfolio(
    graph,
    candidate_node_ids,
    hourly_downtime_cost~,
  )
}
