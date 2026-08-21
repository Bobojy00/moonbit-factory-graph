///|
pub(all) enum EdgeDiffType {
  EdgeAdded
  EdgeRemoved
  EdgeModified
} derive(Debug, Eq)

///|
pub fn EdgeDiffType::to_string(self : EdgeDiffType) -> String {
  match self {
    EdgeAdded => "Added"
    EdgeRemoved => "Removed"
    EdgeModified => "Modified"
  }
}

///|
pub impl Show for EdgeDiffType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) struct EdgeDiffEntry {
  edge_id : String
  source_id : String
  target_id : String
  flow_type : @types.FlowType
  diff_type : EdgeDiffType
  old_bandwidth : Double
  new_bandwidth : Double
} derive(Debug, Eq)
