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
