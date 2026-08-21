///|
pub struct FactoryGraphBuilder {
  graph : FactoryGraph
  mut edge_counter : Int
} derive(Debug)

///|
pub fn FactoryGraphBuilder::new(
  plant_name? : String = "Automated Smart Factory",
  location? : String = "Industrial High-Tech Zone",
  takt_time_target_sec? : Double = 45.0,
) -> FactoryGraphBuilder {
  let cfg = @types.FactoryConfig::default()
  let updated_cfg : @types.FactoryConfig = {
    plant_name,
    site_location: location,
    version: "1.0.0",
    takt_time_target_sec,
    planned_shifts_per_day: cfg.planned_shifts_per_day,
    shift_duration_hours: cfg.shift_duration_hours,
    target_oee: cfg.target_oee,
    default_currency: cfg.default_currency,
  }
  { graph: FactoryGraph::new(config=updated_cfg), edge_counter: 0 }
}

///|
pub fn FactoryGraphBuilder::add_workstation(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "AssemblyLine",
  subzone? : String = "",
  cycle_time_sec? : Double = 40.0,
  nominal_power_kw? : Double = 15.0,
  mtbf_hours? : Double = 1200.0,
  mttr_hours? : Double = 1.5,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Workstation,
    zone~,
    subzone~,
    cycle_time_sec~,
    nominal_power_kw~,
    mtbf_hours~,
    mttr_hours~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_machine(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "MachiningZone",
  subzone? : String = "",
  cycle_time_sec? : Double = 30.0,
  nominal_power_kw? : Double = 25.0,
  mtbf_hours? : Double = 800.0,
  mttr_hours? : Double = 3.0,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Machine,
    zone~,
    subzone~,
    cycle_time_sec~,
    nominal_power_kw~,
    mtbf_hours~,
    mttr_hours~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_conveyor(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "LogisticsZone",
  subzone? : String = "",
  nominal_power_kw? : Double = 5.5,
  capacity? : Double = 50.0,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Conveyor,
    zone~,
    subzone~,
    nominal_power_kw~,
    capacity~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_buffer(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "WIP_Storage",
  subzone? : String = "",
  capacity? : Double = 200.0,
  initial_wip? : Double = 20.0,
  safety_zone_id? : String = "SZ-0",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Buffer,
    zone~,
    subzone~,
    capacity~,
    initial_wip~,
    max_wip=capacity,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_sensor(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "SensingZone",
  subzone? : String = "",
  nominal_power_kw? : Double = 0.05,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Sensor,
    zone~,
    subzone~,
    nominal_power_kw~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_power_source(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "PowerSubstation",
  subzone? : String = "",
  capacity_kw? : Double = 500.0,
  safety_zone_id? : String = "SZ-0",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::PowerSource,
    zone~,
    subzone~,
    nominal_power_kw=capacity_kw,
    capacity=capacity_kw,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_safety_gate(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "SafetyZone",
  subzone? : String = "",
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::SafetyGate,
    zone~,
    subzone~,
    nominal_power_kw=0.1,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_plc(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "ControlRoom",
  subzone? : String = "",
  safety_zone_id? : String = "SZ-0",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::PLCController,
    zone~,
    subzone~,
    nominal_power_kw=0.5,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_robot(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "RoboticCell",
  subzone? : String = "",
  cycle_time_sec? : Double = 25.0,
  nominal_power_kw? : Double = 12.0,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::RobotArm,
    zone~,
    subzone~,
    cycle_time_sec~,
    nominal_power_kw~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
pub fn FactoryGraphBuilder::add_inspection(
  self : FactoryGraphBuilder,
  id : String,
  name : String,
  zone? : String = "QualityZone",
  subzone? : String = "",
  cycle_time_sec? : Double = 20.0,
  nominal_power_kw? : Double = 3.5,
  safety_zone_id? : String = "SZ-1",
) -> FactoryGraphBuilder {
  let n = Node::create(
    id,
    name,
    @types.NodeType::Inspection,
    zone~,
    subzone~,
    cycle_time_sec~,
    nominal_power_kw~,
    safety_zone_id~,
  )
  self.graph.add_node(n)
  self
}

///|
fn FactoryGraphBuilder::next_edge_id(
  self : FactoryGraphBuilder,
  prefix : String,
) -> String {
  self.edge_counter = self.edge_counter + 1
  prefix + "-" + self.edge_counter.to_string()
}

///|
pub fn FactoryGraphBuilder::connect_material(
  self : FactoryGraphBuilder,
  src : String,
  dst : String,
  bandwidth? : Double = 1200.0,
  delay? : Double = 2.0,
  distance? : Double = 10.0,
  medium? : @types.TransferMedium = @types.TransferMedium::BeltConveyor,
  redundancy_priority? : Int = 1,
) -> FactoryGraphBuilder {
  let eid = self.next_edge_id("MAT")
  let e = Edge::create(
    eid,
    src,
    dst,
    @types.FlowType::MaterialFlow,
    bandwidth_units_per_hour=bandwidth,
    transport_delay_sec=delay,
    distance_meters=distance,
    medium~,
    redundancy_priority~,
  )
  self.graph.add_edge(e)
  self
}

///|
pub fn FactoryGraphBuilder::connect_control(
  self : FactoryGraphBuilder,
  plc_id : String,
  target_id : String,
  protocol? : @types.ControlProtocol = @types.ControlProtocol::Profinet,
  latency_ms? : Double = 5.0,
) -> FactoryGraphBuilder {
  let eid = self.next_edge_id("CTL")
  let e = Edge::create(
    eid,
    plc_id,
    target_id,
    @types.FlowType::ControlFlow,
    transport_delay_sec=latency_ms / 1000.0,
    protocol~,
  )
  self.graph.add_edge(e)
  self
}

///|
pub fn FactoryGraphBuilder::connect_energy(
  self : FactoryGraphBuilder,
  power_source_id : String,
  target_id : String,
  energy_type? : @types.EnergyType = @types.EnergyType::AC_380V_3Phase,
  loss_kw? : Double = 0.2,
) -> FactoryGraphBuilder {
  let eid = self.next_edge_id("PWR")
  let e = Edge::create(
    eid,
    power_source_id,
    target_id,
    @types.FlowType::EnergyFlow,
    energy_loss_kw=loss_kw,
    energy_type~,
  )
  self.graph.add_edge(e)
  self
}

///|
pub fn FactoryGraphBuilder::connect_safety(
  self : FactoryGraphBuilder,
  safety_source_id : String,
  target_id : String,
  level? : @types.SafetyLevel = @types.SafetyLevel::SIL3,
) -> FactoryGraphBuilder {
  let eid = self.next_edge_id("SAF")
  let e = Edge::create(
    eid,
    safety_source_id,
    target_id,
    @types.FlowType::SafetyInterlock,
    safety_level=level,
  )
  self.graph.add_edge(e)
  self
}

///|
pub fn FactoryGraphBuilder::connect_telemetry(
  self : FactoryGraphBuilder,
  sensor_id : String,
  collector_id : String,
  protocol? : @types.ControlProtocol = @types.ControlProtocol::MQTT,
) -> FactoryGraphBuilder {
  let eid = self.next_edge_id("TEL")
  let e = Edge::create(
    eid,
    sensor_id,
    collector_id,
    @types.FlowType::DataTelemetry,
    protocol~,
  )
  self.graph.add_edge(e)
  self
}

///|
pub fn FactoryGraphBuilder::connect_line(
  self : FactoryGraphBuilder,
  station_ids : Array[String],
  bandwidth? : Double = 1200.0,
  delay? : Double = 2.0,
) -> FactoryGraphBuilder {
  for i = 0; i < station_ids.length() - 1; i = i + 1 {
    let src = station_ids[i]
    let dst = station_ids[i + 1]
    let _ = self.connect_material(src, dst, bandwidth~, delay~)
  }
  self
}

///|
pub fn FactoryGraphBuilder::connect_power_bus(
  self : FactoryGraphBuilder,
  source_id : String,
  target_ids : Array[String],
  energy_type? : @types.EnergyType = @types.EnergyType::AC_380V_3Phase,
) -> FactoryGraphBuilder {
  for target in target_ids {
    let _ = self.connect_energy(source_id, target, energy_type~)
  }
  self
}

///|
pub fn FactoryGraphBuilder::connect_plc_network(
  self : FactoryGraphBuilder,
  plc_id : String,
  target_ids : Array[String],
  protocol? : @types.ControlProtocol = @types.ControlProtocol::Profinet,
) -> FactoryGraphBuilder {
  for target in target_ids {
    let _ = self.connect_control(plc_id, target, protocol~)
  }
  self
}

///|
pub fn FactoryGraphBuilder::connect_safety_domain(
  self : FactoryGraphBuilder,
  safety_gate_id : String,
  target_ids : Array[String],
  level? : @types.SafetyLevel = @types.SafetyLevel::SIL3,
) -> FactoryGraphBuilder {
  for target in target_ids {
    let _ = self.connect_safety(safety_gate_id, target, level~)
  }
  self
}

///|
pub fn FactoryGraphBuilder::build(self : FactoryGraphBuilder) -> FactoryGraph {
  self.graph
}
