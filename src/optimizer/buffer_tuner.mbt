///|
pub(all) struct BufferTuningRecommendation {
  buffer_id : String
  upstream_station_id : String
  downstream_station_id : String
  current_capacity : Double
  recommended_capacity : Double
  rationale : String
} derive(Debug, Eq)

///|
pub fn optimize_buffer_capacities(
  graph : @graph.FactoryGraph,
) -> Array[BufferTuningRecommendation] {
  let recs : Array[BufferTuningRecommendation] = []
  let nodes = graph.get_all_nodes()

  for node in nodes {
    if node.node_type() == @types.NodeType::Buffer {
      let bid = node.id()
      let in_e = graph.get_layer_in_edges(@types.FlowType::MaterialFlow, bid)
      let out_e = graph.get_layer_out_edges(@types.FlowType::MaterialFlow, bid)

      let up_id = if in_e.length() > 0 { in_e[0].source_id() } else { "N/A" }
      let down_id = if out_e.length() > 0 {
        out_e[0].target_id()
      } else {
        "N/A"
      }

      let up_node = graph.get_node(up_id)
      let mttr = match up_node {
        Some(un) => un.mttr_hours()
        None => 1.5
      }
      let cycle_time = match up_node {
        Some(un) => un.cycle_time_sec()
        None => 30.0
      }

      let current_cap = node.capacity()
      // Recommended buffer size: absorb MTTR duration * production rate
      let rate_per_hour = if cycle_time > 0.0 {
        3600.0 / cycle_time
      } else {
        100.0
      }
      let recommended = rate_per_hour * mttr * 0.5

      let rationale = "Calculated buffer size to absorb " +
        mttr.to_string() +
        "h upstream MTTR variance with 50% decoupling safety margin."

      recs.push({
        buffer_id: bid,
        upstream_station_id: up_id,
        downstream_station_id: down_id,
        current_capacity: current_cap,
        recommended_capacity: recommended,
        rationale,
      })
    }
  }

  recs
}
