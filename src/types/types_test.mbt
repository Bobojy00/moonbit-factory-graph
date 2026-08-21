///|
test "types_enum_conversions" {
  let nt = NodeType::Workstation
  assert_eq(nt.to_string(), "Workstation")
  assert_eq(NodeType::from_string("RobotArm"), NodeType::RobotArm)

  let ft = FlowType::MaterialFlow
  assert_eq(ft.to_string(), "MaterialFlow")
  assert_eq(FlowType::from_string("SafetyInterlock"), FlowType::SafetyInterlock)

  let op = OperatingStatus::Online
  assert_eq(op.is_operational(), true)
  assert_eq(OperatingStatus::EmergencyStop.is_operational(), false)
}

///|
test "metadata_calculations" {
  let node = NodeMetadata::new(
    "WS-101",
    "Robotic Welding Station",
    NodeType::Workstation,
    cycle_time_sec=40.0,
    mtbf_hours=900.0,
    mttr_hours=100.0,
  )
  let avail = node.availability()
  assert_eq(avail, 0.9)
  let th = node.hourly_throughput_limit()
  assert_eq(th, 90.0)
}

///|
test "formatting_helpers" {
  let str = format_double(12.3456, 2)
  assert_eq(str, "12.35")
}
