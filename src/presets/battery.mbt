///|
pub fn build_lithium_battery_plant() -> @graph.FactoryGraph {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="Lithium Battery Cell Gigafactory",
    location="Yibin Lithium Giga Industrial Base",
    takt_time_target_sec=20.0,
  )

  builder
  // Power & Master Automation
  .add_power_source(
    "PWR-BAT-01",
    "Main 35kV/10kV Battery Substation",
    zone="Utility",
    capacity_kw=6000.0,
  )
  .add_power_source(
    "PWR-BAT-02",
    "380V Low Voltage Transformer Bank",
    zone="Utility",
    capacity_kw=3000.0,
  )
  .add_plc(
    "PLC-CELL-MASTER",
    "Cell Line Supervisory Master PLC",
    zone="Control",
  )
  .add_plc(
    "PLC-ELECTRODE",
    "Electrode Coating & Calendering PLC",
    zone="ElectrodeShop",
  )
  .add_plc(
    "PLC-CELL-ASSY",
    "Cell Stacking & Canning PLC",
    zone="CellAssemblyShop",
  )
  .add_plc(
    "PLC-FORMATION",
    "Formation & Aging Warehouse PLC",
    zone="FormationShop",
  )

  // Electrode Shop (Mixing, Coating, Calendering, Slitting)
  .add_machine(
    "BAT-MIXER-POS",
    "Cathode Slurry Vacuum Planetary Mixer",
    zone="ElectrodeShop",
    cycle_time_sec=18.0,
    nominal_power_kw=150.0,
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_machine(
    "BAT-MIXER-NEG",
    "Anode Slurry High-Speed Disperser",
    zone="ElectrodeShop",
    cycle_time_sec=18.0,
    nominal_power_kw=120.0,
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_machine(
    "BAT-COATER",
    "Dual-Sided Slot-Die High-Speed Coater",
    zone="ElectrodeShop",
    cycle_time_sec=20.0,
    nominal_power_kw=280.0,
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_machine(
    "BAT-CALENDER",
    "Tandem Precision Heated Calender Roll",
    zone="ElectrodeShop",
    cycle_time_sec=18.0,
    nominal_power_kw=180.0,
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_machine(
    "BAT-SLITTER",
    "Laser Slitter & Continuous Tab Notcher",
    zone="ElectrodeShop",
    cycle_time_sec=19.0,
    nominal_power_kw=90.0,
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_buffer(
    "BUF-JUMBO-ROLLS",
    "Slit Electrode Roll Vacuum Storage Buffer",
    zone="ElectrodeShop",
    capacity=600.0,
  )

  // Cell Assembly Shop (Stacking, Tab Welding, Canning, Electrolyte)
  .add_robot(
    "BAT-STACKER",
    "High-Speed Z-Stacking Robotic Cell",
    zone="CellAssemblyShop",
    cycle_time_sec=20.0,
    nominal_power_kw=45.0,
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_machine(
    "BAT-TAB-WELD",
    "Ultrasonic Multi-Layer Tab Welder",
    zone="CellAssemblyShop",
    cycle_time_sec=18.0,
    nominal_power_kw=35.0,
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_workstation(
    "BAT-CANNING",
    "Aluminum Prismatic Can Insertion",
    zone="CellAssemblyShop",
    cycle_time_sec=19.0,
    nominal_power_kw=25.0,
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_machine(
    "BAT-LID-WELD",
    "Fiber Laser Top Cover Seal Welder",
    zone="CellAssemblyShop",
    cycle_time_sec=20.0,
    nominal_power_kw=40.0,
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_machine(
    "BAT-ELECTROLYTE",
    "Vacuum Precise Electrolyte Injection",
    zone="CellAssemblyShop",
    cycle_time_sec=20.0,
    nominal_power_kw=55.0,
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_buffer(
    "BUF-UNFORMED-CELLS",
    "Degassing & Soaking WIP Buffer",
    zone="CellAssemblyShop",
    capacity=800.0,
  )

  // Formation, Aging & Testing Shop
  .add_machine(
    "BAT-FORMATION",
    "High-Precision High-Bay Formation Channel",
    zone="FormationShop",
    cycle_time_sec=20.0,
    nominal_power_kw=220.0,
    safety_zone_id="SZ-FORMATION",
  )
  .add_machine(
    "BAT-AGING",
    "Constant-Temperature Aging High-Bay System",
    zone="FormationShop",
    cycle_time_sec=20.0,
    nominal_power_kw=160.0,
    safety_zone_id="SZ-FORMATION",
  )
  .add_inspection(
    "BAT-OCV-ACIR",
    "OCV / ACIR / DCIR Multi-Parameter Sorter",
    zone="FormationShop",
    cycle_time_sec=18.0,
    nominal_power_kw=30.0,
    safety_zone_id="SZ-FORMATION",
  )
  .add_workstation(
    "BAT-MODULE-PACK",
    "Pack Sorting & Palletizing Station",
    zone="FormationShop",
    cycle_time_sec=20.0,
    nominal_power_kw=25.0,
    safety_zone_id="SZ-FORMATION",
  )

  // Safety Gates
  .add_safety_gate(
    "SG-BAT-01",
    "Electrode Solvent Explosion-Proof Gate",
    zone="ElectrodeShop",
    safety_zone_id="SZ-ELECTRODE",
  )
  .add_safety_gate(
    "SG-BAT-02",
    "Cell Assembly Laser & High Voltage Gate",
    zone="CellAssemblyShop",
    safety_zone_id="SZ-CELL-ASSY",
  )
  .add_safety_gate(
    "SG-BAT-03",
    "Formation Thermal Runaway Fire Isolation",
    zone="FormationShop",
    safety_zone_id="SZ-FORMATION",
  )

  // Material Flow
  .connect_material("BAT-MIXER-POS", "BAT-COATER", bandwidth=1800.0, delay=2.0)
  .connect_material("BAT-MIXER-NEG", "BAT-COATER", bandwidth=1800.0, delay=2.0)
  .connect_material("BAT-COATER", "BAT-CALENDER", bandwidth=1800.0, delay=1.5)
  .connect_material("BAT-CALENDER", "BAT-SLITTER", bandwidth=1800.0, delay=1.5)
  .connect_material(
    "BAT-SLITTER",
    "BUF-JUMBO-ROLLS",
    bandwidth=1800.0,
    delay=2.0,
  )
  .connect_material(
    "BUF-JUMBO-ROLLS",
    "BAT-STACKER",
    bandwidth=1800.0,
    delay=3.0,
  )
  .connect_material("BAT-STACKER", "BAT-TAB-WELD", bandwidth=1800.0, delay=1.0)
  .connect_material("BAT-TAB-WELD", "BAT-CANNING", bandwidth=1800.0, delay=1.0)
  .connect_material("BAT-CANNING", "BAT-LID-WELD", bandwidth=1800.0, delay=1.0)
  .connect_material(
    "BAT-LID-WELD",
    "BAT-ELECTROLYTE",
    bandwidth=1800.0,
    delay=1.5,
  )
  .connect_material(
    "BAT-ELECTROLYTE",
    "BUF-UNFORMED-CELLS",
    bandwidth=1800.0,
    delay=2.0,
  )
  .connect_material(
    "BUF-UNFORMED-CELLS",
    "BAT-FORMATION",
    bandwidth=1800.0,
    delay=3.0,
  )
  .connect_material("BAT-FORMATION", "BAT-AGING", bandwidth=1800.0, delay=2.0)
  .connect_material("BAT-AGING", "BAT-OCV-ACIR", bandwidth=1800.0, delay=2.0)
  .connect_material(
    "BAT-OCV-ACIR",
    "BAT-MODULE-PACK",
    bandwidth=1800.0,
    delay=1.5,
  )

  // Energy Grid
  .connect_energy("PWR-BAT-01", "PWR-BAT-02")
  .connect_power_bus("PWR-BAT-02", [
    "BAT-MIXER-POS", "BAT-MIXER-NEG", "BAT-COATER", "BAT-CALENDER", "BAT-SLITTER",
    "BAT-STACKER", "BAT-TAB-WELD", "BAT-CANNING", "BAT-LID-WELD", "BAT-ELECTROLYTE",
    "BAT-FORMATION", "BAT-AGING", "BAT-OCV-ACIR", "BAT-MODULE-PACK", "PLC-CELL-MASTER",
    "PLC-ELECTRODE", "PLC-CELL-ASSY", "PLC-FORMATION",
  ])

  // Control Wiring
  .connect_control("PLC-CELL-MASTER", "PLC-ELECTRODE")
  .connect_control("PLC-CELL-MASTER", "PLC-CELL-ASSY")
  .connect_control("PLC-CELL-MASTER", "PLC-FORMATION")
  .connect_plc_network("PLC-ELECTRODE", [
    "BAT-MIXER-POS", "BAT-MIXER-NEG", "BAT-COATER", "BAT-CALENDER", "BAT-SLITTER",
  ])
  .connect_plc_network("PLC-CELL-ASSY", [
    "BAT-STACKER", "BAT-TAB-WELD", "BAT-CANNING", "BAT-LID-WELD", "BAT-ELECTROLYTE",
  ])
  .connect_plc_network("PLC-FORMATION", [
    "BAT-FORMATION", "BAT-AGING", "BAT-OCV-ACIR", "BAT-MODULE-PACK",
  ])

  // Safety Interlocks
  .connect_safety_domain("SG-BAT-01", [
    "BAT-MIXER-POS", "BAT-MIXER-NEG", "BAT-COATER", "BAT-CALENDER", "BAT-SLITTER",
  ])
  .connect_safety_domain("SG-BAT-02", [
    "BAT-STACKER", "BAT-TAB-WELD", "BAT-CANNING", "BAT-LID-WELD", "BAT-ELECTROLYTE",
  ])
  .connect_safety_domain("SG-BAT-03", [
    "BAT-FORMATION", "BAT-AGING", "BAT-OCV-ACIR", "BAT-MODULE-PACK",
  ])
  .build()
}
