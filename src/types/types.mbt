///|
pub(all) enum NodeType {
  Workstation
  Machine
  Conveyor
  Buffer
  Sensor
  PowerSource
  SafetyGate
  AGVTrack
  Diverter
  Inspection
  StorageRack
  RobotArm
  PneumaticPump
  Chiller
  PLCController
} derive(Debug, Eq, Compare)

///|
pub fn NodeType::to_string(self : NodeType) -> String {
  match self {
    Workstation => "Workstation"
    Machine => "Machine"
    Conveyor => "Conveyor"
    Buffer => "Buffer"
    Sensor => "Sensor"
    PowerSource => "PowerSource"
    SafetyGate => "SafetyGate"
    AGVTrack => "AGVTrack"
    Diverter => "Diverter"
    Inspection => "Inspection"
    StorageRack => "StorageRack"
    RobotArm => "RobotArm"
    PneumaticPump => "PneumaticPump"
    Chiller => "Chiller"
    PLCController => "PLCController"
  }
}

///|
pub fn NodeType::from_string(s : String) -> NodeType {
  match s {
    "Workstation" => Workstation
    "Machine" => Machine
    "Conveyor" => Conveyor
    "Buffer" => Buffer
    "Sensor" => Sensor
    "PowerSource" => PowerSource
    "SafetyGate" => SafetyGate
    "AGVTrack" => AGVTrack
    "Diverter" => Diverter
    "Inspection" => Inspection
    "StorageRack" => StorageRack
    "RobotArm" => RobotArm
    "PneumaticPump" => PneumaticPump
    "Chiller" => Chiller
    "PLCController" => PLCController
    _ => Machine
  }
}

///|
pub impl Show for NodeType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum FlowType {
  MaterialFlow
  ControlFlow
  EnergyFlow
  SafetyInterlock
  PneumaticFlow
  CoolantFlow
  DataTelemetry
} derive(Debug, Eq, Compare)

///|
pub fn FlowType::to_string(self : FlowType) -> String {
  match self {
    MaterialFlow => "MaterialFlow"
    ControlFlow => "ControlFlow"
    EnergyFlow => "EnergyFlow"
    SafetyInterlock => "SafetyInterlock"
    PneumaticFlow => "PneumaticFlow"
    CoolantFlow => "CoolantFlow"
    DataTelemetry => "DataTelemetry"
  }
}

///|
pub fn FlowType::from_string(s : String) -> FlowType {
  match s {
    "MaterialFlow" => MaterialFlow
    "ControlFlow" => ControlFlow
    "EnergyFlow" => EnergyFlow
    "SafetyInterlock" => SafetyInterlock
    "PneumaticFlow" => PneumaticFlow
    "CoolantFlow" => CoolantFlow
    "DataTelemetry" => DataTelemetry
    _ => MaterialFlow
  }
}

///|
pub impl Show for FlowType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum SafetyLevel {
  SIL1
  SIL2
  SIL3
  SIL4
  PL_a
  PL_b
  PL_c
  PL_d
  PL_e
  Standard
} derive(Debug, Eq, Compare)

///|
pub fn SafetyLevel::to_string(self : SafetyLevel) -> String {
  match self {
    SIL1 => "SIL1"
    SIL2 => "SIL2"
    SIL3 => "SIL3"
    SIL4 => "SIL4"
    PL_a => "PL_a"
    PL_b => "PL_b"
    PL_c => "PL_c"
    PL_d => "PL_d"
    PL_e => "PL_e"
    Standard => "Standard"
  }
}

///|
pub impl Show for SafetyLevel with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum OperatingStatus {
  Online
  Degraded
  Offline
  Maintenance
  EmergencyStop
  Standby
  Calibrating
} derive(Debug, Eq, Compare)

///|
pub fn OperatingStatus::to_string(self : OperatingStatus) -> String {
  match self {
    Online => "Online"
    Degraded => "Degraded"
    Offline => "Offline"
    Maintenance => "Maintenance"
    EmergencyStop => "EmergencyStop"
    Standby => "Standby"
    Calibrating => "Calibrating"
  }
}

///|
pub fn OperatingStatus::from_string(s : String) -> OperatingStatus {
  match s {
    "Online" => Online
    "Degraded" => Degraded
    "Offline" => Offline
    "Maintenance" => Maintenance
    "EmergencyStop" => EmergencyStop
    "Standby" => Standby
    "Calibrating" => Calibrating
    _ => Offline
  }
}

///|
pub fn OperatingStatus::is_operational(self : OperatingStatus) -> Bool {
  match self {
    Online | Degraded | Standby => true
    Offline | Maintenance | EmergencyStop | Calibrating => false
  }
}

///|
pub impl Show for OperatingStatus with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum TransferMedium {
  BeltConveyor
  RollerConveyor
  OverheadMonorail
  AGV
  RoboticPickAndPlace
  PneumaticTube
  GravityChute
  ManualTransfer
  Pipe
} derive(Debug, Eq, Compare)

///|
pub fn TransferMedium::to_string(self : TransferMedium) -> String {
  match self {
    BeltConveyor => "BeltConveyor"
    RollerConveyor => "RollerConveyor"
    OverheadMonorail => "OverheadMonorail"
    AGV => "AGV"
    RoboticPickAndPlace => "RoboticPickAndPlace"
    PneumaticTube => "PneumaticTube"
    GravityChute => "GravityChute"
    ManualTransfer => "ManualTransfer"
    Pipe => "Pipe"
  }
}

///|
pub impl Show for TransferMedium with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum ControlProtocol {
  OPC_UA
  Modbus_TCP
  Modbus_RTU
  Profinet
  EtherNet_IP
  EtherCAT
  MQTT
  CANopen
  IO_Link
  DiscreteWiring
} derive(Debug, Eq, Compare)

///|
pub fn ControlProtocol::to_string(self : ControlProtocol) -> String {
  match self {
    OPC_UA => "OPC_UA"
    Modbus_TCP => "Modbus_TCP"
    Modbus_RTU => "Modbus_RTU"
    Profinet => "Profinet"
    EtherNet_IP => "EtherNet_IP"
    EtherCAT => "EtherCAT"
    MQTT => "MQTT"
    CANopen => "CANopen"
    IO_Link => "IO_Link"
    DiscreteWiring => "DiscreteWiring"
  }
}

///|
pub impl Show for ControlProtocol with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum EnergyType {
  AC_380V_3Phase
  AC_220V_SinglePhase
  DC_24V
  DC_48V
  Pneumatic_6Bar
  Hydraulic_160Bar
  CoolingWater
  NitrogenGas
} derive(Debug, Eq, Compare)

///|
pub fn EnergyType::to_string(self : EnergyType) -> String {
  match self {
    AC_380V_3Phase => "AC_380V_3Phase"
    AC_220V_SinglePhase => "AC_220V_SinglePhase"
    DC_24V => "DC_24V"
    DC_48V => "DC_48V"
    Pneumatic_6Bar => "Pneumatic_6Bar"
    Hydraulic_160Bar => "Hydraulic_160Bar"
    CoolingWater => "CoolingWater"
    NitrogenGas => "NitrogenGas"
  }
}

///|
pub impl Show for EnergyType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum ValidationSeverity {
  Info
  Warning
  Error
  Critical
} derive(Debug, Eq, Compare)

///|
pub fn ValidationSeverity::to_string(self : ValidationSeverity) -> String {
  match self {
    Info => "Info"
    Warning => "Warning"
    Error => "Error"
    Critical => "Critical"
  }
}

///|
pub impl Show for ValidationSeverity with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) enum AlarmSeverity {
  Notice
  Minor
  Major
  Emergency
} derive(Debug, Eq, Compare)

///|
pub fn AlarmSeverity::to_string(self : AlarmSeverity) -> String {
  match self {
    Notice => "Notice"
    Minor => "Minor"
    Major => "Major"
    Emergency => "Emergency"
  }
}

///|
pub impl Show for AlarmSeverity with fn output(self, logger) {
  logger.write_string(self.to_string())
}
