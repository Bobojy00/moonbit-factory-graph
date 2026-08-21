///|
pub(all) struct NodeMetadata {
  id : String
  name : String
  zone : String
  subzone : String
  node_type : NodeType
  cycle_time_sec : Double
  nominal_power_kw : Double
  mtbf_hours : Double
  mttr_hours : Double
  capacity : Double
  initial_wip : Double
  max_wip : Double
  is_bottleneck_candidate : Bool
  mut status : OperatingStatus
  safety_zone_id : String
  description : String
} derive(Debug, Eq)

///|
pub fn NodeMetadata::new(
  id : String,
  name : String,
  node_type : NodeType,
  zone? : String = "DefaultZone",
  subzone? : String = "",
  cycle_time_sec? : Double = 0.0,
  nominal_power_kw? : Double = 0.0,
  mtbf_hours? : Double = 1000.0,
  mttr_hours? : Double = 2.0,
  capacity? : Double = 100.0,
  initial_wip? : Double = 0.0,
  max_wip? : Double = 100.0,
  is_bottleneck_candidate? : Bool = false,
  status? : OperatingStatus = Online,
  safety_zone_id? : String = "SZ-0",
  description? : String = "",
) -> NodeMetadata {
  {
    id,
    name,
    zone,
    subzone,
    node_type,
    cycle_time_sec,
    nominal_power_kw,
    mtbf_hours,
    mttr_hours,
    capacity,
    initial_wip,
    max_wip,
    is_bottleneck_candidate,
    status,
    safety_zone_id,
    description,
  }
}

///|
pub fn NodeMetadata::availability(self : NodeMetadata) -> Double {
  if self.mtbf_hours + self.mttr_hours <= 0.0 {
    1.0
  } else {
    self.mtbf_hours / (self.mtbf_hours + self.mttr_hours)
  }
}

///|
pub fn NodeMetadata::hourly_throughput_limit(self : NodeMetadata) -> Double {
  if self.cycle_time_sec <= 0.0 {
    3600.0 * 100.0
  } else {
    3600.0 / self.cycle_time_sec
  }
}

///|
pub(all) struct EdgeMetadata {
  id : String
  source_id : String
  target_id : String
  flow_type : FlowType
  mut bandwidth_units_per_hour : Double
  transport_delay_sec : Double
  distance_meters : Double
  energy_loss_kw : Double
  safety_level : SafetyLevel
  protocol : ControlProtocol
  medium : TransferMedium
  energy_type : EnergyType
  is_bidirectional : Bool
  mut is_active : Bool
  redundancy_priority : Int
  description : String
} derive(Debug, Eq)

///|
pub fn EdgeMetadata::new(
  id : String,
  source_id : String,
  target_id : String,
  flow_type : FlowType,
  bandwidth_units_per_hour? : Double = 1200.0,
  transport_delay_sec? : Double = 1.0,
  distance_meters? : Double = 5.0,
  energy_loss_kw? : Double = 0.1,
  safety_level? : SafetyLevel = Standard,
  protocol? : ControlProtocol = OPC_UA,
  medium? : TransferMedium = BeltConveyor,
  energy_type? : EnergyType = AC_380V_3Phase,
  is_bidirectional? : Bool = false,
  is_active? : Bool = true,
  redundancy_priority? : Int = 1,
  description? : String = "",
) -> EdgeMetadata {
  {
    id,
    source_id,
    target_id,
    flow_type,
    bandwidth_units_per_hour,
    transport_delay_sec,
    distance_meters,
    energy_loss_kw,
    safety_level,
    protocol,
    medium,
    energy_type,
    is_bidirectional,
    is_active,
    redundancy_priority,
    description,
  }
}

///|
pub(all) struct PlantZone {
  id : String
  name : String
  workshop : String
  description : String
  max_operators : Int
  safety_zone_id : String
  is_cleanroom : Bool
} derive(Debug, Eq)

///|
pub fn PlantZone::new(
  id : String,
  name : String,
  workshop? : String = "MainPlant",
  description? : String = "",
  max_operators? : Int = 10,
  safety_zone_id? : String = "SZ-0",
  is_cleanroom? : Bool = false,
) -> PlantZone {
  {
    id,
    name,
    workshop,
    description,
    max_operators,
    safety_zone_id,
    is_cleanroom,
  }
}

///|
pub(all) struct PlantAlarm {
  alarm_id : String
  source_node_id : String
  severity : AlarmSeverity
  timestamp_sec : Int
  message : String
  is_acknowledged : Bool
  tripped_nodes : Array[String]
} derive(Debug, Eq)

///|
pub fn PlantAlarm::new(
  alarm_id : String,
  source_node_id : String,
  severity : AlarmSeverity,
  timestamp_sec : Int,
  message : String,
  is_acknowledged? : Bool = false,
  tripped_nodes? : Array[String] = [],
) -> PlantAlarm {
  {
    alarm_id,
    source_node_id,
    severity,
    timestamp_sec,
    message,
    is_acknowledged,
    tripped_nodes,
  }
}

///|
pub(all) struct TelemetryPoint {
  timestamp_sec : Int
  node_id : String
  metric_name : String
  value : Double
  unit : String
  is_normal : Bool
} derive(Debug, Eq)

///|
pub fn TelemetryPoint::new(
  timestamp_sec : Int,
  node_id : String,
  metric_name : String,
  value : Double,
  unit : String,
  is_normal? : Bool = true,
) -> TelemetryPoint {
  { timestamp_sec, node_id, metric_name, value, unit, is_normal }
}

///|
pub(all) struct ValidationIssue {
  rule_id : String
  severity : ValidationSeverity
  target_id : String
  message : String
  suggested_fix : String
} derive(Debug, Eq)

///|
pub fn ValidationIssue::new(
  rule_id : String,
  severity : ValidationSeverity,
  target_id : String,
  message : String,
  suggested_fix? : String = "",
) -> ValidationIssue {
  { rule_id, severity, target_id, message, suggested_fix }
}

///|
pub(all) struct FactoryConfig {
  plant_name : String
  site_location : String
  version : String
  takt_time_target_sec : Double
  planned_shifts_per_day : Int
  shift_duration_hours : Double
  target_oee : Double
  default_currency : String
} derive(Debug, Eq)

///|
pub fn FactoryConfig::default() -> FactoryConfig {
  {
    plant_name: "Smart Automation Factory",
    site_location: "Smart Manufacturing Industrial Park",
    version: "1.0.0",
    takt_time_target_sec: 45.0,
    planned_shifts_per_day: 2,
    shift_duration_hours: 8.0,
    target_oee: 0.85,
    default_currency: "CNY",
  }
}
