///|
pub(all) enum NodeDiffType {
  NodeAdded
  NodeRemoved
  NodeModified
} derive(Debug, Eq)

///|
pub fn NodeDiffType::to_string(self : NodeDiffType) -> String {
  match self {
    NodeAdded => "Added"
    NodeRemoved => "Removed"
    NodeModified => "Modified"
  }
}

///|
pub impl Show for NodeDiffType with fn output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub(all) struct NodePropertyDiff {
  field_name : String
  old_value : String
  new_value : String
  is_breaking : Bool
} derive(Debug, Eq)

///|
pub(all) struct NodeDiffEntry {
  node_id : String
  diff_type : NodeDiffType
  property_changes : Array[NodePropertyDiff]
} derive(Debug, Eq)
