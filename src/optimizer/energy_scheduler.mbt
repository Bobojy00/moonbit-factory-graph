///|
pub(all) struct StartupSequenceStep {
  step_index : Int
  machine_ids : Array[String]
  step_power_kw : Double
  delay_after_sec : Double
} derive(Debug, Eq)

///|
pub(all) struct EnergySchedulePlan {
  startup_sequence : Array[StartupSequenceStep]
  total_installed_power_kw : Double
  peak_shaved_startup_power_kw : Double
} derive(Debug, Eq)

///|
pub fn plan_staggered_energy_startup(
  graph : @graph.FactoryGraph,
) -> EnergySchedulePlan {
  let nodes = graph.get_all_nodes()
  let mut total_pwr = 0.0

  let high_power : Array[String] = []
  let medium_power : Array[String] = []
  let low_power : Array[String] = []

  let mut high_pwr_sum = 0.0
  let mut med_pwr_sum = 0.0
  let mut low_pwr_sum = 0.0

  for node in nodes {
    let pwr = node.nominal_power_kw()
    total_pwr = total_pwr + pwr
    if pwr >= 30.0 {
      high_power.push(node.id())
      high_pwr_sum = high_pwr_sum + pwr
    } else if pwr >= 10.0 {
      medium_power.push(node.id())
      med_pwr_sum = med_pwr_sum + pwr
    } else if pwr > 0.0 {
      low_power.push(node.id())
      low_pwr_sum = low_pwr_sum + pwr
    }
  }

  let steps : Array[StartupSequenceStep] = [
    {
      step_index: 1,
      machine_ids: low_power,
      step_power_kw: low_pwr_sum,
      delay_after_sec: 5.0,
    },
    {
      step_index: 2,
      machine_ids: medium_power,
      step_power_kw: med_pwr_sum,
      delay_after_sec: 10.0,
    },
    {
      step_index: 3,
      machine_ids: high_power,
      step_power_kw: high_pwr_sum,
      delay_after_sec: 0.0,
    },
  ]

  let mut max_step_pwr = low_pwr_sum
  if med_pwr_sum > max_step_pwr {
    max_step_pwr = med_pwr_sum
  }
  if high_pwr_sum > max_step_pwr {
    max_step_pwr = high_pwr_sum
  }

  {
    startup_sequence: steps,
    total_installed_power_kw: total_pwr,
    peak_shaved_startup_power_kw: max_step_pwr,
  }
}
