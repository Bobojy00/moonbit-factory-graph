///|
pub struct Edge {
  meta : @types.EdgeMetadata
} derive(Debug, Eq)

///|
pub fn Edge::new(meta : @types.EdgeMetadata) -> Edge {
  { meta, }
}

///|
pub fn Edge::create(
  id : String,
  source_id : String,
  target_id : String,
  flow_type : @types.FlowType,
  bandwidth_units_per_hour? : Double = 1200.0,
  transport_delay_sec? : Double = 1.0,
  distance_meters? : Double = 5.0,
  energy_loss_kw? : Double = 0.1,
  safety_level? : @types.SafetyLevel = @types.SafetyLevel::Standard,
  protocol? : @types.ControlProtocol = @types.ControlProtocol::OPC_UA,
  medium? : @types.TransferMedium = @types.TransferMedium::BeltConveyor,
  energy_type? : @types.EnergyType = @types.EnergyType::AC_380V_3Phase,
  is_bidirectional? : Bool = false,
  is_active? : Bool = true,
  redundancy_priority? : Int = 1,
  description? : String = "",
) -> Edge {
  let meta = @types.EdgeMetadata::new(
    id,
    source_id,
    target_id,
    flow_type,
    bandwidth_units_per_hour~,
    transport_delay_sec~,
    distance_meters~,
    energy_loss_kw~,
    safety_level~,
    protocol~,
    medium~,
    energy_type~,
    is_bidirectional~,
    is_active~,
    redundancy_priority~,
    description~,
  )
  { meta, }
}

///|
pub fn Edge::id(self : Edge) -> String {
  self.meta.id
}

///|
pub fn Edge::source_id(self : Edge) -> String {
  self.meta.source_id
}

///|
pub fn Edge::target_id(self : Edge) -> String {
  self.meta.target_id
}

///|
pub fn Edge::flow_type(self : Edge) -> @types.FlowType {
  self.meta.flow_type
}

///|
pub fn Edge::bandwidth(self : Edge) -> Double {
  self.meta.bandwidth_units_per_hour
}

///|
pub fn Edge::transport_delay_sec(self : Edge) -> Double {
  self.meta.transport_delay_sec
}

///|
pub fn Edge::distance_meters(self : Edge) -> Double {
  self.meta.distance_meters
}

///|
pub fn Edge::energy_loss_kw(self : Edge) -> Double {
  self.meta.energy_loss_kw
}

///|
pub fn Edge::safety_level(self : Edge) -> @types.SafetyLevel {
  self.meta.safety_level
}

///|
pub fn Edge::protocol(self : Edge) -> @types.ControlProtocol {
  self.meta.protocol
}

///|
pub fn Edge::medium(self : Edge) -> @types.TransferMedium {
  self.meta.medium
}

///|
pub fn Edge::energy_type(self : Edge) -> @types.EnergyType {
  self.meta.energy_type
}

///|
pub fn Edge::is_bidirectional(self : Edge) -> Bool {
  self.meta.is_bidirectional
}

///|
pub fn Edge::is_active(self : Edge) -> Bool {
  self.meta.is_active
}

///|
pub fn Edge::set_active(self : Edge, active : Bool) -> Unit {
  self.meta.is_active = active
}

///|
pub fn Edge::set_bandwidth(self : Edge, bw : Double) -> Unit {
  self.meta.bandwidth_units_per_hour = bw
}

///|
pub fn Edge::redundancy_priority(self : Edge) -> Int {
  self.meta.redundancy_priority
}

///|
pub fn Edge::description(self : Edge) -> String {
  self.meta.description
}

///|
pub fn Edge::metadata(self : Edge) -> @types.EdgeMetadata {
  self.meta
}

///|
pub fn Edge::to_string(self : Edge) -> String {
  "Edge(" +
  self.meta.id +
  ": " +
  self.meta.source_id +
  " -> " +
  self.meta.target_id +
  " [" +
  self.meta.flow_type.to_string() +
  "])"
}

///|
pub impl Show for Edge with fn output(self, logger) {
  logger.write_string(self.to_string())
}
