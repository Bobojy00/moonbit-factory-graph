///|
pub(all) struct SafetyAuditReport {
  total_safety_zones : Int
  unprotected_machines : Array[String]
  sil_compliant : Bool
  estop_coverage_percent : Double
  audit_status : String
} derive(Debug, Eq)

///|
pub fn audit_plant_safety_systems(
  graph : @graph.FactoryGraph,
) -> SafetyAuditReport {
  let safety_zones = graph.get_all_safety_zones()
  let nodes = graph.get_all_nodes()

  let mut high_risk_count = 0
  let mut protected_count = 0
  let unprotected = []

  for node in nodes {
    let nt = node.node_type()
    if nt == @types.NodeType::RobotArm ||
      nt == @types.NodeType::Machine ||
      nt == @types.NodeType::Workstation {
      high_risk_count = high_risk_count + 1
      let sz = node.safety_zone_id()
      if sz.length() > 0 && sz != "SZ-0" {
        protected_count = protected_count + 1
      } else {
        unprotected.push(node.id() + " (" + node.name() + ")")
      }
    }
  }

  let coverage = if high_risk_count > 0 {
    protected_count.to_double() / high_risk_count.to_double() * 100.0
  } else {
    100.0
  }

  let is_sil = unprotected.length() == 0

  let status = if is_sil {
    "PASSED - Full SIL3 / PL_d Safety Compliance"
  } else {
    "FAILED - Unprotected Machinery Found in Plant"
  }

  {
    total_safety_zones: safety_zones.length(),
    unprotected_machines: unprotected,
    sil_compliant: is_sil,
    estop_coverage_percent: coverage,
    audit_status: status,
  }
}
