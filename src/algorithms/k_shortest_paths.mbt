///|
pub fn k_shortest_paths(
  graph : @graph.FactoryGraph,
  source : String,
  target : String,
  k : Int,
  flow_type? : @types.FlowType = @types.FlowType::MaterialFlow,
  criteria? : CostCriteria = MinimumTransportDelay,
) -> Array[PathResult] {
  let result : Array[PathResult] = []
  let initial = dijkstra_shortest_path(
    graph,
    source,
    target,
    flow_type~,
    criteria~,
  )
  match initial {
    None => return result
    Some(p0) => result.push(p0)
  }

  let candidates : Array[PathResult] = []

  for iter = 1; iter < k; iter = iter + 1 {
    let prev_path = result[iter - 1]
    for i = 0; i < prev_path.nodes.length() - 1; i = i + 1 {
      let spur_node = prev_path.nodes[i]
      let root_path_nodes = []
      let root_path_edges = []
      for j = 0; j <= i; j = j + 1 {
        root_path_nodes.push(prev_path.nodes[j])
        if j < i {
          root_path_edges.push(prev_path.edges[j])
        }
      }

      // Clone graph to temporarily disable edges
      let spur_graph = graph.clone()

      // Remove edges that are part of previous paths that share root path
      for p in result {
        let mut match_root = true
        for j = 0; j <= i; j = j + 1 {
          if j >= p.nodes.length() || p.nodes[j] != root_path_nodes[j] {
            match_root = false
            break
          }
        }
        if match_root && i < p.edges.length() {
          let edge_to_disable = p.edges[i]
          match spur_graph.get_edge(edge_to_disable.id()) {
            Some(e) => e.set_active(false)
            None => ()
          }
        }
      }

      // Hide root path nodes except spur node
      for j = 0; j < i; j = j + 1 {
        let n_hide = root_path_nodes[j]
        let out_e = spur_graph.get_out_edges(n_hide)
        for e in out_e {
          e.set_active(false)
        }
      }

      // Find spur path
      let spur_path_opt = dijkstra_shortest_path(
        spur_graph,
        spur_node,
        target,
        flow_type~,
        criteria~,
      )

      match spur_path_opt {
        Some(spur_path) => {
          let total_nodes = []
          for n in root_path_nodes {
            total_nodes.push(n)
          }
          for j = 1; j < spur_path.nodes.length(); j = j + 1 {
            total_nodes.push(spur_path.nodes[j])
          }

          let total_edges = []
          for e in root_path_edges {
            total_edges.push(e)
          }
          for e in spur_path.edges {
            total_edges.push(e)
          }

          let mut total_delay = 0.0
          let mut min_bw = 1.0e9
          let mut total_cost = 0.0
          for e in total_edges {
            total_delay = total_delay + e.transport_delay_sec()
            if e.bandwidth() < min_bw {
              min_bw = e.bandwidth()
            }
            let target_node = graph.get_node(e.target_id())
            total_cost = total_cost +
              compute_edge_weight(e, target_node, criteria)
          }

          let candidate_path : PathResult = {
            nodes: total_nodes,
            edges: total_edges,
            total_cost,
            total_delay_sec: total_delay,
            bottleneck_bandwidth: min_bw,
          }

          // Check if candidate already in candidates
          let mut exists = false
          for c in candidates {
            if c.nodes.length() == candidate_path.nodes.length() {
              let mut same = true
              for idx = 0; idx < c.nodes.length(); idx = idx + 1 {
                if c.nodes[idx] != candidate_path.nodes[idx] {
                  same = false
                  break
                }
              }
              if same {
                exists = true
                break
              }
            }
          }
          if !exists {
            candidates.push(candidate_path)
          }
        }
        None => ()
      }
    }

    if candidates.length() == 0 {
      break
    }

    // Sort candidate paths by total_cost
    let mut best_idx = 0
    let mut best_cost = 1.0e12
    for c_idx = 0; c_idx < candidates.length(); c_idx = c_idx + 1 {
      if candidates[c_idx].total_cost < best_cost {
        best_cost = candidates[c_idx].total_cost
        best_idx = c_idx
      }
    }

    let chosen = candidates[best_idx]
    let _ = candidates.remove(best_idx)
    result.push(chosen)
  }

  result
}
