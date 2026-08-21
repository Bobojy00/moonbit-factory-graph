///|
pub fn find_disjoint_paths(
  graph : @graph.FactoryGraph,
  source : String,
  target : String,
  flow_type? : @types.FlowType = @types.FlowType::MaterialFlow,
  node_disjoint? : Bool = true,
) -> Array[PathResult] {
  let paths : Array[PathResult] = []
  let g = graph.clone()

  while true {
    let p_opt = dijkstra_shortest_path(g, source, target, flow_type~)
    match p_opt {
      None => break
      Some(p) => {
        paths.push(p)
        if node_disjoint {
          // Disable intermediate nodes
          for i = 1; i < p.nodes.length() - 1; i = i + 1 {
            let nid = p.nodes[i]
            let in_e = g.get_in_edges(nid)
            for e in in_e {
              e.set_active(false)
            }
            let out_e = g.get_out_edges(nid)
            for e in out_e {
              e.set_active(false)
            }
          }
        } else {
          // Only disable edges
          for e in p.edges {
            match g.get_edge(e.id()) {
              Some(target_e) => target_e.set_active(false)
              None => ()
            }
          }
        }
      }
    }
  }

  paths
}
