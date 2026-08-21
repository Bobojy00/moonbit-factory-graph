///|
pub(all) struct ScheduleCriticalPath {
  ordered_stations : Array[String]
  makespan_sec : Double
  earliest_finish_times : Map[String, Double]
  critical_path : Array[String]
} derive(Debug)

///|
pub fn topological_production_schedule(
  graph : @graph.FactoryGraph,
) -> ScheduleCriticalPath? {
  let in_degree : Map[String, Int] = Map([])
  let nodes = graph.get_all_nodes()

  for node in nodes {
    let id = node.id()
    let in_edges = graph.get_layer_in_edges(@types.FlowType::MaterialFlow, id)
    in_degree[id] = in_edges.length()
  }

  let queue : Array[String] = []
  for node in nodes {
    let id = node.id()
    if in_degree[id] == 0 {
      queue.push(id)
    }
  }

  let ordered : Array[String] = []
  let ef : Map[String, Double] = Map([])

  for node in nodes {
    let id = node.id()
    ef[id] = node.cycle_time_sec()
  }

  while queue.length() > 0 {
    let u = queue.remove(0)
    ordered.push(u)

    let out_edges = graph.get_layer_out_edges(@types.FlowType::MaterialFlow, u)
    for edge in out_edges {
      if edge.is_active() {
        let v = edge.target_id()
        let v_node = graph.get_node(v)
        let v_ct = match v_node {
          Some(n) => n.cycle_time_sec()
          None => 0.0
        }
        let u_ef = ef[u]
        let candidate_ef = u_ef + edge.transport_delay_sec() + v_ct
        if candidate_ef > ef[v] {
          ef[v] = candidate_ef
        }

        in_degree[v] = in_degree[v] - 1
        if in_degree[v] == 0 {
          queue.push(v)
        }
      }
    }
  }

  if ordered.length() < nodes.length() {
    return None // Graph has cycles, cannot strictly DAG schedule
  }

  // Find max makespan
  let mut max_makespan = 0.0
  let mut end_node = ""
  for n, t in ef {
    if t > max_makespan {
      max_makespan = t
      end_node = n
    }
  }

  Some({
    ordered_stations: ordered,
    makespan_sec: max_makespan,
    earliest_finish_times: ef,
    critical_path: [end_node],
  })
}
