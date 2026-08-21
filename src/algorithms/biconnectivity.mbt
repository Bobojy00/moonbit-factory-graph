///|
pub(all) struct CriticalAssetReport {
  single_points_of_failure : Array[String]
  critical_bridges : Array[String]
} derive(Debug)

///|
priv struct BiconnectivityContext {
  graph : @graph.FactoryGraph
  visited : Map[String, Bool]
  tin : Map[String, Int]
  low : Map[String, Int]
  parent : Map[String, String]
  articulation_points : Map[String, Bool]
  bridges : Array[String]
  mut timer : Int
}

///|
fn dfs_biconnectivity(
  u : String,
  p : String,
  ctx : BiconnectivityContext,
) -> Unit {
  ctx.visited[u] = true
  ctx.tin[u] = ctx.timer
  ctx.low[u] = ctx.timer
  ctx.timer = ctx.timer + 1
  let mut children = 0

  let neighbors = ctx.graph.get_out_neighbors(u)
  let in_neighbors = ctx.graph.get_in_neighbors(u)
  let all_adj = []
  for n in neighbors {
    all_adj.push(n)
  }
  for n in in_neighbors {
    all_adj.push(n)
  }

  for v in all_adj {
    if v == p {
      continue
    }
    if ctx.visited.contains(v) && ctx.visited[v] {
      let u_low = ctx.low[u]
      let v_tin = ctx.tin[v]
      if v_tin < u_low {
        ctx.low[u] = v_tin
      }
    } else {
      ctx.parent[v] = u
      dfs_biconnectivity(v, u, ctx)
      let u_low = ctx.low[u]
      let v_low = ctx.low[v]
      if v_low < u_low {
        ctx.low[u] = v_low
      }
      if v_low >= ctx.tin[u] && p.length() > 0 {
        ctx.articulation_points[u] = true
      }
      if v_low > ctx.tin[u] {
        ctx.bridges.push(u + " <-> " + v)
      }
      children = children + 1
    }
  }

  if p.length() == 0 && children > 1 {
    ctx.articulation_points[u] = true
  }
}

///|
pub fn find_critical_spof_assets(
  graph : @graph.FactoryGraph,
) -> CriticalAssetReport {
  let ctx : BiconnectivityContext = {
    graph,
    visited: Map([]),
    tin: Map([]),
    low: Map([]),
    parent: Map([]),
    articulation_points: Map([]),
    bridges: [],
    timer: 0,
  }

  let nodes = graph.get_all_nodes()
  for node in nodes {
    let id = node.id()
    if !ctx.visited.contains(id) {
      dfs_biconnectivity(id, "", ctx)
    }
  }

  let spofs = []
  for k, _ in ctx.articulation_points {
    spofs.push(k)
  }

  { single_points_of_failure: spofs, critical_bridges: ctx.bridges }
}
