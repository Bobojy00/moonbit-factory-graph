///|
pub(all) struct NodeCentralityRanking {
  node_id : String
  degree_centrality : Int
  betweenness_score : Double
  closeness_score : Double
} derive(Debug)

///|
pub fn compute_asset_centrality(
  graph : @graph.FactoryGraph,
) -> Array[NodeCentralityRanking] {
  let nodes = graph.get_all_nodes()
  let rankings : Array[NodeCentralityRanking] = []

  for node in nodes {
    let id = node.id()
    let out_e = graph.get_out_edges(id)
    let in_e = graph.get_in_edges(id)
    let deg = out_e.length() + in_e.length()

    // Approximate betweenness by counting shortest path pass-throughs
    let mut pass_count = 0.0
    for s in nodes {
      let sid = s.id()
      if sid != id {
        for t in nodes {
          let tid = t.id()
          if tid != id && tid != sid {
            let p_opt = dijkstra_shortest_path(graph, sid, tid)
            match p_opt {
              Some(p) =>
                for n in p.nodes {
                  if n == id {
                    pass_count = pass_count + 1.0
                    break
                  }
                }
              None => ()
            }
          }
        }
      }
    }

    let closeness = if deg > 0 { 1.0 / (deg.to_double() + 1.0) } else { 0.0 }

    rankings.push({
      node_id: id,
      degree_centrality: deg,
      betweenness_score: pass_count,
      closeness_score: closeness,
    })
  }

  rankings
}
