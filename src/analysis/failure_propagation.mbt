///|
pub(all) struct OutageSimulationResult {
  failed_node_id : String
  power_blackout_nodes : Array[String]
  plc_timeout_nodes : Array[String]
  safety_tripped_nodes : Array[String]
  starved_workstations : Array[String]
  blocked_workstations : Array[String]
  all_impacted_nodes : Array[String]
  production_capacity_loss_percent : Double
  estimated_hourly_loss_cny : Double
  affected_workstations_count : Int
} derive(Debug, Eq)

///|
pub fn simulate_device_outage(
  graph : @graph.FactoryGraph,
  failed_node_id : String,
  hourly_downtime_cost? : Double = 50000.0,
) -> OutageSimulationResult {
  let power_blackout : Array[String] = []
  let plc_timeout : Array[String] = []
  let safety_tripped : Array[String] = []
  let starved : Array[String] = []
  let blocked : Array[String] = []
  let all_impacted : Map[String, Bool] = Map([])

  all_impacted[failed_node_id] = true

  let failed_node = graph.get_node(failed_node_id)
  let failed_nt = match failed_node {
    Some(n) => n.node_type()
    None => @types.NodeType::Machine
  }

  // 1. Power blackout cascade: If PowerSource fails, all reachable via EnergyFlow lose power
  if failed_nt == @types.NodeType::PowerSource {
    let q = [failed_node_id]
    let visited_pwr : Map[String, Bool] = Map([])
    visited_pwr[failed_node_id] = true
    while q.length() > 0 {
      let u = q.remove(0)
      let out_e = graph.get_layer_out_edges(@types.FlowType::EnergyFlow, u)
      for e in out_e {
        let v = e.target_id()
        if !visited_pwr.contains(v) {
          visited_pwr[v] = true
          power_blackout.push(v)
          all_impacted[v] = true
          q.push(v)
        }
      }
    }
  }

  // 2. PLC Controller timeout: If PLC fails, all controlled nodes trip
  if failed_nt == @types.NodeType::PLCController {
    let q = [failed_node_id]
    let visited_ctl : Map[String, Bool] = Map([])
    visited_ctl[failed_node_id] = true
    while q.length() > 0 {
      let u = q.remove(0)
      let out_e = graph.get_layer_out_edges(@types.FlowType::ControlFlow, u)
      for e in out_e {
        let v = e.target_id()
        if !visited_ctl.contains(v) {
          visited_ctl[v] = true
          plc_timeout.push(v)
          all_impacted[v] = true
          q.push(v)
        }
      }
    }
  }

  // 3. Safety Interlock zone trip: All nodes in the same safety zone trip
  match failed_node {
    Some(n) => {
      let sz = n.safety_zone_id()
      if sz.length() > 0 && sz != "SZ-0" {
        let sz_nodes = graph.get_nodes_in_safety_zone(sz)
        for target_node in sz_nodes {
          let tid = target_node.id()
          if tid != failed_node_id && !all_impacted.contains(tid) {
            safety_tripped.push(tid)
            all_impacted[tid] = true
          }
        }
      }
    }
    None => ()
  }

  // 4. Downstream Material Starvation: Nodes that only receive material from failed nodes
  let q_mat = []
  for nid, _ in all_impacted {
    q_mat.push(nid)
  }
  let visited_starve : Map[String, Bool] = Map([])
  while q_mat.length() > 0 {
    let u = q_mat.remove(0)
    let out_mat = graph.get_layer_out_edges(@types.FlowType::MaterialFlow, u)
    for e in out_mat {
      let v = e.target_id()
      if !visited_starve.contains(v) && !all_impacted.contains(v) {
        // Check if all in-edges for material come from impacted nodes
        let in_mat = graph.get_layer_in_edges(@types.FlowType::MaterialFlow, v)
        let mut has_unimpacted_supplier = false
        for in_e in in_mat {
          let sup = in_e.source_id()
          if !all_impacted.contains(sup) {
            has_unimpacted_supplier = true
            break
          }
        }
        if !has_unimpacted_supplier {
          visited_starve[v] = true
          starved.push(v)
          all_impacted[v] = true
          q_mat.push(v)
        }
      }
    }
  }

  // 5. Upstream Material Blockage: Nodes upstream that have nowhere to send WIP
  let q_block = []
  for nid, _ in all_impacted {
    q_block.push(nid)
  }
  let visited_block : Map[String, Bool] = Map([])
  while q_block.length() > 0 {
    let u = q_block.remove(0)
    let in_mat = graph.get_layer_in_edges(@types.FlowType::MaterialFlow, u)
    for e in in_mat {
      let v = e.source_id()
      if !visited_block.contains(v) && !all_impacted.contains(v) {
        let out_mat = graph.get_layer_out_edges(
          @types.FlowType::MaterialFlow,
          v,
        )
        let mut has_unimpacted_consumer = false
        for out_e in out_mat {
          let cons = out_e.target_id()
          if !all_impacted.contains(cons) {
            has_unimpacted_consumer = true
            break
          }
        }
        if !has_unimpacted_consumer {
          visited_block[v] = true
          blocked.push(v)
          all_impacted[v] = true
          q_block.push(v)
        }
      }
    }
  }

  let total_nodes = graph.node_count()
  let impacted_count = all_impacted.length()
  let loss_pct = if total_nodes > 0 {
    impacted_count.to_double() / total_nodes.to_double() * 100.0
  } else {
    0.0
  }

  let mut ws_count = 0
  let all_impacted_arr = []
  for nid, _ in all_impacted {
    all_impacted_arr.push(nid)
    match graph.get_node(nid) {
      Some(n) => {
        let nt = n.node_type()
        if nt == @types.NodeType::Workstation ||
          nt == @types.NodeType::Machine ||
          nt == @types.NodeType::RobotArm {
          ws_count = ws_count + 1
        }
      }
      None => ()
    }
  }

  let financial_loss = hourly_downtime_cost * (loss_pct / 100.0)

  {
    failed_node_id,
    power_blackout_nodes: power_blackout,
    plc_timeout_nodes: plc_timeout,
    safety_tripped_nodes: safety_tripped,
    starved_workstations: starved,
    blocked_workstations: blocked,
    all_impacted_nodes: all_impacted_arr,
    production_capacity_loss_percent: loss_pct,
    estimated_hourly_loss_cny: financial_loss,
    affected_workstations_count: ws_count,
  }
}
