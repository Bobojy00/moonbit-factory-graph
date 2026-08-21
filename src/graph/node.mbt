///|
pub struct Node {
  meta : @types.NodeMetadata
} derive(Debug, Eq)

///|
pub fn Node::new(meta : @types.NodeMetadata) -> Node {
  { meta, }
}

///|
pub fn Node::create(
  id : String,
  name : String,
  node_type : @types.NodeType,
  zone? : String = "MainPlant",
  subzone? : String = "",
  cycle_time_sec? : Double = 0.0,
  nominal_power_kw? : Double = 0.0,
  mtbf_hours? : Double = 1000.0,
  mttr_hours? : Double = 2.0,
  capacity? : Double = 100.0,
  initial_wip? : Double = 0.0,
  max_wip? : Double = 100.0,
  is_bottleneck_candidate? : Bool = false,
  status? : @types.OperatingStatus = @types.OperatingStatus::Online,
  safety_zone_id? : String = "SZ-0",
  description? : String = "",
) -> Node {
  let meta = @types.NodeMetadata::new(
    id,
    name,
    node_type,
    zone~,
    subzone~,
    cycle_time_sec~,
    nominal_power_kw~,
    mtbf_hours~,
    mttr_hours~,
    capacity~,
    initial_wip~,
    max_wip~,
    is_bottleneck_candidate~,
    status~,
    safety_zone_id~,
    description~,
  )
  { meta, }
}

///|
pub fn Node::id(self : Node) -> String {
  self.meta.id
}

///|
pub fn Node::name(self : Node) -> String {
  self.meta.name
}

///|
pub fn Node::node_type(self : Node) -> @types.NodeType {
  self.meta.node_type
}

///|
pub fn Node::zone(self : Node) -> String {
  self.meta.zone
}

///|
pub fn Node::subzone(self : Node) -> String {
  self.meta.subzone
}

///|
pub fn Node::status(self : Node) -> @types.OperatingStatus {
  self.meta.status
}

///|
pub fn Node::set_status(self : Node, status : @types.OperatingStatus) -> Unit {
  self.meta.status = status
}

///|
pub fn Node::is_operational(self : Node) -> Bool {
  self.meta.status.is_operational()
}

///|
pub fn Node::cycle_time_sec(self : Node) -> Double {
  self.meta.cycle_time_sec
}

///|
pub fn Node::nominal_power_kw(self : Node) -> Double {
  self.meta.nominal_power_kw
}

///|
pub fn Node::capacity(self : Node) -> Double {
  self.meta.capacity
}

///|
pub fn Node::initial_wip(self : Node) -> Double {
  self.meta.initial_wip
}

///|
pub fn Node::max_wip(self : Node) -> Double {
  self.meta.max_wip
}

///|
pub fn Node::is_bottleneck_candidate(self : Node) -> Bool {
  self.meta.is_bottleneck_candidate
}

///|
pub fn Node::mtbf_hours(self : Node) -> Double {
  self.meta.mtbf_hours
}

///|
pub fn Node::mttr_hours(self : Node) -> Double {
  self.meta.mttr_hours
}

///|
pub fn Node::availability(self : Node) -> Double {
  self.meta.availability()
}

///|
pub fn Node::hourly_throughput_limit(self : Node) -> Double {
  self.meta.hourly_throughput_limit()
}

///|
pub fn Node::safety_zone_id(self : Node) -> String {
  self.meta.safety_zone_id
}

///|
pub fn Node::description(self : Node) -> String {
  self.meta.description
}

///|
pub fn Node::metadata(self : Node) -> @types.NodeMetadata {
  self.meta
}

///|
pub fn Node::to_string(self : Node) -> String {
  "Node(" +
  self.meta.id +
  " [" +
  self.meta.node_type.to_string() +
  "]: " +
  self.meta.name +
  ")"
}

///|
pub impl Show for Node with fn output(self, logger) {
  logger.write_string(self.to_string())
}
