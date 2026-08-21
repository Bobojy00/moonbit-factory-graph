///|
pub(all) enum CostCriteria {
  MinimumTransportDelay
  MinimumCycleTime
  MinimumEnergyLoss
  BalancedManufacturingCost
} derive(Debug, Eq)

///|
pub(all) struct PathResult {
  nodes : Array[String]
  edges : Array[@graph.Edge]
  total_cost : Double
  total_delay_sec : Double
  bottleneck_bandwidth : Double
} derive(Debug, Eq)

///|
fn compute_edge_weight(
  edge : @graph.Edge,
  target_node : @graph.Node?,
  criteria : CostCriteria,
) -> Double {
  let delay = edge.transport_delay_sec()
  let energy = edge.energy_loss_kw()
  let cycle_time = match target_node {
    Some(n) => n.cycle_time_sec()
    None => 0.0
  }
  match criteria {
    MinimumTransportDelay => delay
    MinimumCycleTime => cycle_time + delay
    MinimumEnergyLoss => energy * 10.0 + delay
    BalancedManufacturingCost => cycle_time * 0.5 + delay + energy * 2.0
  }
}

///|
pub fn dijkstra_shortest_path(
  graph : @graph.FactoryGraph,
  source : String,
  target : String,
  flow_type? : @types.FlowType = @types.FlowType::MaterialFlow,
  criteria? : CostCriteria = MinimumTransportDelay,
) -> PathResult? {
  if !graph.has_node(source) || !graph.has_node(target) {
    return None
  }
  if source == target {
    return Some({
      nodes: [source],
      edges: [],
      total_cost: 0.0,
      total_delay_sec: 0.0,
      bottleneck_bandwidth: 1.0e9,
    })
  }

  let dist : Map[String, Double] = Map([])
  let prev_node : Map[String, String] = Map([])
  let prev_edge : Map[String, @graph.Edge] = Map([])
  let visited : Map[String, Bool] = Map([])

  dist[source] = 0.0

  while true {
    let mut min_node : String? = None
    let mut min_dist = 1.0e12

    for node_id, d in dist {
      if !visited.contains(node_id) && d < min_dist {
        min_dist = d
        min_node = Some(node_id)
      }
    }

    match min_node {
      None => break
      Some(u) => {
        if u == target {
          break
        }
        visited[u] = true
        let out_edges = graph.get_layer_out_edges(flow_type, u)
        for edge in out_edges {
          if edge.is_active() {
            let v = edge.target_id()
            let v_node = graph.get_node(v)
            let w = compute_edge_weight(edge, v_node, criteria)
            let new_dist = min_dist + w
            let old_dist = match dist.get(v) {
              Some(od) => od
              None => 1.0e12
            }
            if new_dist < old_dist {
              dist[v] = new_dist
              prev_node[v] = u
              prev_edge[v] = edge
            }
          }
        }
      }
    }
  }

  if !dist.contains(target) {
    return None
  }

  // Reconstruct path
  let path_nodes = []
  let path_edges = []
  let mut curr = target
  path_nodes.push(curr)

  while curr != source {
    match prev_node.get(curr) {
      Some(p) => {
        match prev_edge.get(curr) {
          Some(e) => path_edges.push(e)
          None => ()
        }
        curr = p
        path_nodes.push(curr)
      }
      None => break
    }
  }

  // Reverse path
  let rev_nodes = []
  for i = path_nodes.length() - 1; i >= 0; i = i - 1 {
    rev_nodes.push(path_nodes[i])
  }
  let rev_edges = []
  for i = path_edges.length() - 1; i >= 0; i = i - 1 {
    rev_edges.push(path_edges[i])
  }

  let mut total_delay = 0.0
  let mut min_bw = 1.0e9
  for e in rev_edges {
    total_delay = total_delay + e.transport_delay_sec()
    if e.bandwidth() < min_bw {
      min_bw = e.bandwidth()
    }
  }

  let total_cost = match dist.get(target) {
    Some(c) => c
    None => 0.0
  }

  Some({
    nodes: rev_nodes,
    edges: rev_edges,
    total_cost,
    total_delay_sec: total_delay,
    bottleneck_bandwidth: min_bw,
  })
}
