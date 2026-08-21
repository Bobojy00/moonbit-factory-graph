///|
pub(all) struct MaxFlowResult {
  max_throughput_units_per_hour : Double
  bottleneck_min_cut_edges : Array[String]
} derive(Debug)

///|
pub fn edmonds_karp_max_flow(
  graph : @graph.FactoryGraph,
  source : String,
  sink : String,
) -> MaxFlowResult {
  if !graph.has_node(source) || !graph.has_node(sink) || source == sink {
    return { max_throughput_units_per_hour: 0.0, bottleneck_min_cut_edges: [] }
  }

  // Build residual capacity map
  let capacity : Map[String, Double] = Map([])
  let flow : Map[String, Double] = Map([])

  let edges = graph.get_all_edges()
  for e in edges {
    if e.is_active() && e.flow_type() == @types.FlowType::MaterialFlow {
      let u = e.source_id()
      let v = e.target_id()
      let key_fwd = u + "->" + v
      let key_rev = v + "->" + u
      let current_cap = match capacity.get(key_fwd) {
        Some(c) => c + e.bandwidth()
        None => e.bandwidth()
      }
      capacity[key_fwd] = current_cap
      if !capacity.contains(key_rev) {
        capacity[key_rev] = 0.0
      }
      flow[key_fwd] = 0.0
      flow[key_rev] = 0.0
    }
  }

  let mut total_flow = 0.0

  while true {
    // BFS to find augmenting path
    let parent : Map[String, String] = Map([])
    let visited : Map[String, Bool] = Map([])
    let queue : Array[String] = []

    queue.push(source)
    visited[source] = true

    while queue.length() > 0 {
      let u = queue.remove(0)
      if u == sink {
        break
      }
      let neighbors = graph.get_layer_out_neighbors(
        @types.FlowType::MaterialFlow,
        u,
      )
      let in_neighbors = graph.get_layer_in_neighbors(
        @types.FlowType::MaterialFlow,
        u,
      )
      let all_adj = []
      for n in neighbors {
        all_adj.push(n)
      }
      for n in in_neighbors {
        all_adj.push(n)
      }

      for v in all_adj {
        let key = u + "->" + v
        let cap = match capacity.get(key) {
          Some(c) => c
          None => 0.0
        }
        let fl = match flow.get(key) {
          Some(f) => f
          None => 0.0
        }
        let residual = cap - fl
        if !visited.contains(v) && residual > 1.0e-5 {
          visited[v] = true
          parent[v] = u
          queue.push(v)
        }
      }
    }

    if !parent.contains(sink) {
      break
    }

    // Find bottleneck residual along path
    let mut push_amount = 1.0e12
    let mut curr = sink
    while curr != source {
      let prev = parent[curr]
      let key = prev + "->" + curr
      let cap = capacity[key]
      let fl = flow[key]
      let res = cap - fl
      if res < push_amount {
        push_amount = res
      }
      curr = prev
    }

    // Apply flow
    curr = sink
    while curr != source {
      let prev = parent[curr]
      let key_fwd = prev + "->" + curr
      let key_rev = curr + "->" + prev
      flow[key_fwd] = flow[key_fwd] + push_amount
      flow[key_rev] = flow[key_rev] - push_amount
      curr = prev
    }

    total_flow = total_flow + push_amount
  }

  // Compute min-cut reachable nodes from source in residual graph
  let reachable : Map[String, Bool] = Map([])
  let q = [source]
  reachable[source] = true

  while q.length() > 0 {
    let u = q.remove(0)
    let neighbors = graph.get_layer_out_neighbors(
      @types.FlowType::MaterialFlow,
      u,
    )
    for v in neighbors {
      let key = u + "->" + v
      let cap = match capacity.get(key) {
        Some(c) => c
        None => 0.0
      }
      let fl = match flow.get(key) {
        Some(f) => f
        None => 0.0
      }
      if !reachable.contains(v) && cap - fl > 1.0e-5 {
        reachable[v] = true
        q.push(v)
      }
    }
  }

  let min_cut_edges = []
  for e in edges {
    if e.flow_type() == @types.FlowType::MaterialFlow {
      let u = e.source_id()
      let v = e.target_id()
      if reachable.contains(u) && !reachable.contains(v) {
        min_cut_edges.push(e.id() + " (" + u + " -> " + v + ")")
      }
    }
  }

  {
    max_throughput_units_per_hour: total_flow,
    bottleneck_min_cut_edges: min_cut_edges,
  }
}
