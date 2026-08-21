///|
priv struct TarjanContext {
  graph : @graph.FactoryGraph
  flow_type : @types.FlowType
  indices : Map[String, Int]
  lowlink : Map[String, Int]
  on_stack : Map[String, Bool]
  stack : Array[String]
  mut index : Int
  components : Array[Array[String]]
}

///|
fn strongconnect(u : String, ctx : TarjanContext) -> Unit {
  ctx.indices[u] = ctx.index
  ctx.lowlink[u] = ctx.index
  ctx.index = ctx.index + 1
  ctx.stack.push(u)
  ctx.on_stack[u] = true

  let out_edges = ctx.graph.get_layer_out_edges(ctx.flow_type, u)
  for edge in out_edges {
    if edge.is_active() {
      let v = edge.target_id()
      match ctx.indices.get(v) {
        None => {
          strongconnect(v, ctx)
          let u_low = ctx.lowlink[u]
          let v_low = ctx.lowlink[v]
          if v_low < u_low {
            ctx.lowlink[u] = v_low
          }
        }
        Some(v_idx) =>
          if ctx.on_stack.contains(v) && ctx.on_stack[v] {
            let u_low = ctx.lowlink[u]
            if v_idx < u_low {
              ctx.lowlink[u] = v_idx
            }
          }
      }
    }
  }

  if ctx.lowlink[u] == ctx.indices[u] {
    let scc = []
    while true {
      let w = ctx.stack.pop()
      match w {
        Some(node_id) => {
          ctx.on_stack[node_id] = false
          scc.push(node_id)
          if node_id == u {
            break
          }
        }
        None => break
      }
    }
    ctx.components.push(scc)
  }
}

///|
pub fn strongly_connected_components(
  graph : @graph.FactoryGraph,
  flow_type? : @types.FlowType = @types.FlowType::MaterialFlow,
) -> Array[Array[String]] {
  let ctx : TarjanContext = {
    graph,
    flow_type,
    indices: Map([]),
    lowlink: Map([]),
    on_stack: Map([]),
    stack: [],
    index: 0,
    components: [],
  }

  let nodes = graph.get_all_nodes()
  for node in nodes {
    let id = node.id()
    if !ctx.indices.contains(id) {
      strongconnect(id, ctx)
    }
  }

  ctx.components
}
