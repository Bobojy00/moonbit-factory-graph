///|
pub(all) enum MigrationRiskLevel {
  LowRisk
  MediumRisk
  HighRisk
  CriticalRisk
} derive(Debug, Eq)

///|
pub fn MigrationRiskLevel::to_string(self : MigrationRiskLevel) -> String {
  match self {
    LowRisk => "Low Risk"
    MediumRisk => "Medium Risk"
    HighRisk => "High Risk"
    CriticalRisk => "Critical Risk"
  }
}

///|
pub impl Show for MigrationRiskLevel with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) struct TopologyDiffReport {
  added_nodes : Array[String]
  removed_nodes : Array[String]
  modified_nodes : Array[NodeDiffEntry]
  added_edges : Array[String]
  removed_edges : Array[String]
  modified_edges : Array[EdgeDiffEntry]
  overall_risk_level : MigrationRiskLevel
  risk_score : Double
  breaking_changes : Array[String]
  mitigation_recommendations : Array[String]
} derive(Debug, Eq)
