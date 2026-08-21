///|
pub(all) enum CycleClassification {
  ValidPalletRecirculationLoop
  DeadlockingMaterialDependency
} derive(Debug, Eq)

///|
pub(all) struct DetectedCycle {
  nodes : Array[String]
  classification : CycleClassification
  description : String
} derive(Debug)

///|
pub fn detect_material_cycles(
  graph : @graph.FactoryGraph,
) -> Array[DetectedCycle] {
  let sccs = strongly_connected_components(
    graph,
    flow_type=@types.FlowType::MaterialFlow,
  )
  let cycles = []

  for scc in sccs {
    if scc.length() > 1 {
      // Check if this SCC is a buffer/conveyor return loop or workstation deadlock
      let mut workstation_count = 0
      for nid in scc {
        match graph.get_node(nid) {
          Some(n) =>
            if n.node_type() == @types.NodeType::Workstation ||
              n.node_type() == @types.NodeType::Machine {
              workstation_count = workstation_count + 1
            }
          None => ()
        }
      }

      let (classification, desc) = if workstation_count <= 1 {
        (
          CycleClassification::ValidPalletRecirculationLoop,
          "Pallet or carrier return conveyor loop with " +
          scc.length().to_string() +
          " transport nodes",
        )
      } else {
        (
          CycleClassification::DeadlockingMaterialDependency,
          "Potentially deadlocking circular dependency among " +
          workstation_count.to_string() +
          " processing workstations",
        )
      }

      cycles.push({ nodes: scc, classification, description: desc })
    }
  }

  cycles
}
