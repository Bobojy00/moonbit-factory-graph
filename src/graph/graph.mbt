///|
pub struct FactoryGraph {
  nodes : Map[String, Node]
  edges : Map[String, Edge]
  out_edges : Map[String, Array[Edge]]
  in_edges : Map[String, Array[Edge]]
  layer_out_edges : Map[String, Map[String, Array[Edge]]]
  layer_in_edges : Map[String, Map[String, Array[Edge]]]
  zones : Map[String, Array[String]]
  safety_zones : Map[String, Array[String]]
  mut config : @types.FactoryConfig
} derive(Debug)

///|
pub fn FactoryGraph::new(
  config? : @types.FactoryConfig = @types.FactoryConfig::default(),
) -> FactoryGraph {
  {
    nodes: Map([]),
    edges: Map([]),
    out_edges: Map([]),
    in_edges: Map([]),
    layer_out_edges: Map([]),
    layer_in_edges: Map([]),
    zones: Map([]),
    safety_zones: Map([]),
    config,
  }
}

///|
pub fn FactoryGraph::config(self : FactoryGraph) -> @types.FactoryConfig {
  self.config
}

///|
pub fn FactoryGraph::set_config(
  self : FactoryGraph,
  config : @types.FactoryConfig,
) -> Unit {
  self.config = config
}

///|
pub fn FactoryGraph::add_node(self : FactoryGraph, node : Node) -> Unit {
  let id = node.id()
  self.nodes[id] = node
  if !self.out_edges.contains(id) {
    self.out_edges[id] = []
  }
  if !self.in_edges.contains(id) {
    self.in_edges[id] = []
  }

  // Record zone
  let zone_id = node.zone()
  match self.zones.get(zone_id) {
    Some(arr) => {
      let mut found = false
      for item in arr {
        if item == id {
          found = true
          break
        }
      }
      if !found {
        arr.push(id)
      }
    }
    None => self.zones[zone_id] = [id]
  }

  // Record safety zone
  let sz_id = node.safety_zone_id()
  if sz_id.length() > 0 {
    match self.safety_zones.get(sz_id) {
      Some(arr) => {
        let mut found = false
        for item in arr {
          if item == id {
            found = true
            break
          }
        }
        if !found {
          arr.push(id)
        }
      }
      None => self.safety_zones[sz_id] = [id]
    }
  }
}

///|
pub fn FactoryGraph::add_edge(self : FactoryGraph, edge : Edge) -> Unit {
  let eid = edge.id()
  let src = edge.source_id()
  let dst = edge.target_id()
  let ftype_str = edge.flow_type().to_string()

  self.edges[eid] = edge

  // Ensure nodes exist or register empty adjacency
  if !self.out_edges.contains(src) {
    self.out_edges[src] = []
  }
  if !self.in_edges.contains(dst) {
    self.in_edges[dst] = []
  }

  match self.out_edges.get(src) {
    Some(arr) => arr.push(edge)
    None => ()
  }
  match self.in_edges.get(dst) {
    Some(arr) => arr.push(edge)
    None => ()
  }

  // Layer out edges
  if !self.layer_out_edges.contains(ftype_str) {
    self.layer_out_edges[ftype_str] = Map([])
  }
  match self.layer_out_edges.get(ftype_str) {
    Some(m) => {
      if !m.contains(src) {
        m[src] = []
      }
      match m.get(src) {
        Some(arr) => arr.push(edge)
        None => ()
      }
    }
    None => ()
  }

  // Layer in edges
  if !self.layer_in_edges.contains(ftype_str) {
    self.layer_in_edges[ftype_str] = Map([])
  }
  match self.layer_in_edges.get(ftype_str) {
    Some(m) => {
      if !m.contains(dst) {
        m[dst] = []
      }
      match m.get(dst) {
        Some(arr) => arr.push(edge)
        None => ()
      }
    }
    None => ()
  }

  // Handle bidirectional
  if edge.is_bidirectional() {
    let rev_id = eid + "_rev"
    let rev_meta = @types.EdgeMetadata::new(
      rev_id,
      dst,
      src,
      edge.flow_type(),
      bandwidth_units_per_hour=edge.bandwidth(),
      transport_delay_sec=edge.transport_delay_sec(),
      distance_meters=edge.distance_meters(),
      energy_loss_kw=edge.energy_loss_kw(),
      safety_level=edge.safety_level(),
      protocol=edge.protocol(),
      medium=edge.medium(),
      energy_type=edge.energy_type(),
      is_bidirectional=false,
      is_active=edge.is_active(),
      redundancy_priority=edge.redundancy_priority(),
    )
    let rev_edge = Edge::new(rev_meta)
    self.edges[rev_id] = rev_edge
    if !self.out_edges.contains(dst) {
      self.out_edges[dst] = []
    }
    if !self.in_edges.contains(src) {
      self.in_edges[src] = []
    }
    match self.out_edges.get(dst) {
      Some(arr) => arr.push(rev_edge)
      None => ()
    }
    match self.in_edges.get(src) {
      Some(arr) => arr.push(rev_edge)
      None => ()
    }
  }
}

///|
pub fn FactoryGraph::get_node(self : FactoryGraph, id : String) -> Node? {
  self.nodes.get(id)
}

///|
pub fn FactoryGraph::has_node(self : FactoryGraph, id : String) -> Bool {
  self.nodes.contains(id)
}

///|
pub fn FactoryGraph::get_edge(self : FactoryGraph, id : String) -> Edge? {
  self.edges.get(id)
}

///|
pub fn FactoryGraph::has_edge(self : FactoryGraph, id : String) -> Bool {
  self.edges.contains(id)
}

///|
pub fn FactoryGraph::node_count(self : FactoryGraph) -> Int {
  self.nodes.length()
}

///|
pub fn FactoryGraph::edge_count(self : FactoryGraph) -> Int {
  self.edges.length()
}

///|
pub fn FactoryGraph::get_all_nodes(self : FactoryGraph) -> Array[Node] {
  let res = []
  for _, node in self.nodes {
    res.push(node)
  }
  res
}

///|
pub fn FactoryGraph::get_all_edges(self : FactoryGraph) -> Array[Edge] {
  let res = []
  for _, edge in self.edges {
    res.push(edge)
  }
  res
}

///|
pub fn FactoryGraph::get_out_edges(
  self : FactoryGraph,
  node_id : String,
) -> Array[Edge] {
  match self.out_edges.get(node_id) {
    Some(arr) => arr
    None => []
  }
}

///|
pub fn FactoryGraph::get_in_edges(
  self : FactoryGraph,
  node_id : String,
) -> Array[Edge] {
  match self.in_edges.get(node_id) {
    Some(arr) => arr
    None => []
  }
}

///|
pub fn FactoryGraph::get_layer_out_edges(
  self : FactoryGraph,
  flow_type : @types.FlowType,
  node_id : String,
) -> Array[Edge] {
  let ftype_str = flow_type.to_string()
  match self.layer_out_edges.get(ftype_str) {
    Some(m) =>
      match m.get(node_id) {
        Some(arr) => arr
        None => []
      }
    None => []
  }
}

///|
pub fn FactoryGraph::get_layer_in_edges(
  self : FactoryGraph,
  flow_type : @types.FlowType,
  node_id : String,
) -> Array[Edge] {
  let ftype_str = flow_type.to_string()
  match self.layer_in_edges.get(ftype_str) {
    Some(m) =>
      match m.get(node_id) {
        Some(arr) => arr
        None => []
      }
    None => []
  }
}

///|
pub fn FactoryGraph::get_out_neighbors(
  self : FactoryGraph,
  node_id : String,
) -> Array[String] {
  let res = []
  let edges = self.get_out_edges(node_id)
  for e in edges {
    if e.is_active() {
      let tid = e.target_id()
      let mut found = false
      for x in res {
        if x == tid {
          found = true
          break
        }
      }
      if !found {
        res.push(tid)
      }
    }
  }
  res
}

///|
pub fn FactoryGraph::get_in_neighbors(
  self : FactoryGraph,
  node_id : String,
) -> Array[String] {
  let res = []
  let edges = self.get_in_edges(node_id)
  for e in edges {
    if e.is_active() {
      let sid = e.source_id()
      let mut found = false
      for x in res {
        if x == sid {
          found = true
          break
        }
      }
      if !found {
        res.push(sid)
      }
    }
  }
  res
}

///|
pub fn FactoryGraph::get_layer_out_neighbors(
  self : FactoryGraph,
  flow_type : @types.FlowType,
  node_id : String,
) -> Array[String] {
  let res = []
  let edges = self.get_layer_out_edges(flow_type, node_id)
  for e in edges {
    if e.is_active() {
      let tid = e.target_id()
      let mut found = false
      for x in res {
        if x == tid {
          found = true
          break
        }
      }
      if !found {
        res.push(tid)
      }
    }
  }
  res
}

///|
pub fn FactoryGraph::get_layer_in_neighbors(
  self : FactoryGraph,
  flow_type : @types.FlowType,
  node_id : String,
) -> Array[String] {
  let res = []
  let edges = self.get_layer_in_edges(flow_type, node_id)
  for e in edges {
    if e.is_active() {
      let sid = e.source_id()
      let mut found = false
      for x in res {
        if x == sid {
          found = true
          break
        }
      }
      if !found {
        res.push(sid)
      }
    }
  }
  res
}

///|
pub fn FactoryGraph::get_nodes_in_zone(
  self : FactoryGraph,
  zone_id : String,
) -> Array[Node] {
  let res = []
  match self.zones.get(zone_id) {
    Some(arr) =>
      for id in arr {
        match self.get_node(id) {
          Some(n) => res.push(n)
          None => ()
        }
      }
    None => ()
  }
  res
}

///|
pub fn FactoryGraph::get_nodes_in_safety_zone(
  self : FactoryGraph,
  safety_zone_id : String,
) -> Array[Node] {
  let res = []
  match self.safety_zones.get(safety_zone_id) {
    Some(arr) =>
      for id in arr {
        match self.get_node(id) {
          Some(n) => res.push(n)
          None => ()
        }
      }
    None => ()
  }
  res
}

///|
pub fn FactoryGraph::get_all_zones(self : FactoryGraph) -> Array[String] {
  let res = []
  for z, _ in self.zones {
    res.push(z)
  }
  res
}

///|
pub fn FactoryGraph::get_all_safety_zones(self : FactoryGraph) -> Array[String] {
  let res = []
  for sz, _ in self.safety_zones {
    res.push(sz)
  }
  res
}

///|
pub fn FactoryGraph::calculate_total_power_kw(self : FactoryGraph) -> Double {
  let mut total = 0.0
  for _, node in self.nodes {
    if node.is_operational() {
      total = total + node.nominal_power_kw()
    }
  }
  total
}

///|
pub fn FactoryGraph::calculate_active_nodes_count(self : FactoryGraph) -> Int {
  let mut count = 0
  for _, node in self.nodes {
    if node.is_operational() {
      count = count + 1
    }
  }
  count
}

///|
pub fn FactoryGraph::clone(self : FactoryGraph) -> FactoryGraph {
  let g = FactoryGraph::new(config=self.config)
  for _, node in self.nodes {
    let meta = node.metadata()
    let n = Node::create(
      meta.id,
      meta.name,
      meta.node_type,
      zone=meta.zone,
      subzone=meta.subzone,
      cycle_time_sec=meta.cycle_time_sec,
      nominal_power_kw=meta.nominal_power_kw,
      mtbf_hours=meta.mtbf_hours,
      mttr_hours=meta.mttr_hours,
      capacity=meta.capacity,
      initial_wip=meta.initial_wip,
      max_wip=meta.max_wip,
      is_bottleneck_candidate=meta.is_bottleneck_candidate,
      status=meta.status,
      safety_zone_id=meta.safety_zone_id,
      description=meta.description,
    )
    g.add_node(n)
  }
  for _, edge in self.edges {
    let meta = edge.metadata()
    let e = Edge::create(
      meta.id,
      meta.source_id,
      meta.target_id,
      meta.flow_type,
      bandwidth_units_per_hour=meta.bandwidth_units_per_hour,
      transport_delay_sec=meta.transport_delay_sec,
      distance_meters=meta.distance_meters,
      energy_loss_kw=meta.energy_loss_kw,
      safety_level=meta.safety_level,
      protocol=meta.protocol,
      medium=meta.medium,
      energy_type=meta.energy_type,
      is_bidirectional=meta.is_bidirectional,
      is_active=meta.is_active,
      redundancy_priority=meta.redundancy_priority,
      description=meta.description,
    )
    g.add_edge(e)
  }
  g
}
