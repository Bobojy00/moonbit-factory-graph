///|
pub fn build_chemical_plant() -> @graph.FactoryGraph {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="Continuous Polymer Chemical Processing Plant",
    location="Nanjing Chemical Industrial Park",
    takt_time_target_sec=60.0,
  )

  builder
  // Power & SIS Safety Instrumented System
  .add_power_source(
    "PWR-CHEM-01",
    "Chemical Substation & Dual UPS",
    zone="PowerSubstation",
    capacity_kw=3500.0,
  )
  .add_plc(
    "PLC-DCS-MASTER",
    "Plant Distributed Control System (DCS)",
    zone="ControlRoom",
  )
  .add_plc(
    "PLC-SIS",
    "Safety Instrumented System (SIS) SIL3 Controller",
    zone="ControlRoom",
  )

  // Feed & Pre-treatment
  .add_buffer(
    "CHEM-FEED-TANK-A",
    "Monomer A Raw Storage Tank",
    zone="TankFarm",
    capacity=50000.0,
  )
  .add_buffer(
    "CHEM-FEED-TANK-B",
    "Catalyst B Storage Tank",
    zone="TankFarm",
    capacity=20000.0,
  )
  .add_machine(
    "CHEM-PUMP-A",
    "High-Pressure Metering Dosing Pump A",
    zone="ReactorUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=45.0,
    safety_zone_id="SZ-REACTOR",
  )
  .add_machine(
    "CHEM-PUMP-B",
    "Catalyst Micro-Injection Pump B",
    zone="ReactorUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=15.0,
    safety_zone_id="SZ-REACTOR",
  )
  .add_machine(
    "CHEM-PREHEATER",
    "Shell-and-Tube Feed Preheater",
    zone="ReactorUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=120.0,
    safety_zone_id="SZ-REACTOR",
  )

  // Reaction & Separation
  .add_machine(
    "CHEM-CSTR-REACTOR",
    "Continuous Stirred-Tank Polymerizer (CSTR)",
    zone="ReactorUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=250.0,
    safety_zone_id="SZ-REACTOR",
  )
  .add_machine(
    "CHEM-DISTILL-COL",
    "Fractional Distillation Separation Column",
    zone="DistillationUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=320.0,
    safety_zone_id="SZ-DISTILL",
  )
  .add_machine(
    "CHEM-CONDENSER",
    "Overhead Vapor Condenser & Cooling Tower",
    zone="DistillationUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=160.0,
    safety_zone_id="SZ-DISTILL",
  )
  .add_machine(
    "CHEM-REBOILER",
    "Bottom Thermosyphon Steam Reboiler",
    zone="DistillationUnit",
    cycle_time_sec=60.0,
    nominal_power_kw=280.0,
    safety_zone_id="SZ-DISTILL",
  )
  .add_buffer(
    "CHEM-REFLUX-DRUM",
    "Overhead Reflux Accumulator Drum",
    zone="DistillationUnit",
    capacity=5000.0,
  )

  // Storage & Safety Flare
  .add_buffer(
    "CHEM-PRODUCT-TANK",
    "Purified Polymer Product Tank",
    zone="TankFarm",
    capacity=80000.0,
  )
  .add_machine(
    "CHEM-FLARE-RELIEF",
    "Emergency Flare Overpressure Relief Stack",
    zone="SafetyFlare",
    cycle_time_sec=0.0,
    nominal_power_kw=5.0,
    safety_zone_id="SZ-FLARE",
  )

  // Safety Gates & Relief Valves
  .add_safety_gate(
    "SG-CHEM-SIS-1",
    "Reactor Thermal Runaway Rapid Depressurization Interlock",
    zone="ReactorUnit",
    safety_zone_id="SZ-REACTOR",
  )
  .add_safety_gate(
    "SG-CHEM-SIS-2",
    "Distillation Column High-Pressure Relief Interlock",
    zone="DistillationUnit",
    safety_zone_id="SZ-DISTILL",
  )

  // Piping Material / Chemical Flow
  .connect_material(
    "CHEM-FEED-TANK-A",
    "CHEM-PUMP-A",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-FEED-TANK-B",
    "CHEM-PUMP-B",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-PUMP-A",
    "CHEM-PREHEATER",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-PUMP-B",
    "CHEM-PREHEATER",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-PREHEATER",
    "CHEM-CSTR-REACTOR",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-CSTR-REACTOR",
    "CHEM-DISTILL-COL",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-DISTILL-COL",
    "CHEM-CONDENSER",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-CONDENSER",
    "CHEM-REFLUX-DRUM",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-DISTILL-COL",
    "CHEM-REBOILER",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-REFLUX-DRUM",
    "CHEM-PRODUCT-TANK",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )
  .connect_material(
    "CHEM-CSTR-REACTOR",
    "CHEM-FLARE-RELIEF",
    bandwidth=5000.0,
    medium=@types.TransferMedium::Pipe,
  )

  // Power Bus
  .connect_power_bus("PWR-CHEM-01", [
    "CHEM-PUMP-A", "CHEM-PUMP-B", "CHEM-PREHEATER", "CHEM-CSTR-REACTOR", "CHEM-DISTILL-COL",
    "CHEM-CONDENSER", "CHEM-REBOILER", "CHEM-FLARE-RELIEF", "PLC-DCS-MASTER", "PLC-SIS",
  ])

  // DCS Control
  .connect_plc_network("PLC-DCS-MASTER", [
    "CHEM-PUMP-A", "CHEM-PUMP-B", "CHEM-PREHEATER", "CHEM-CSTR-REACTOR", "CHEM-DISTILL-COL",
    "CHEM-CONDENSER", "CHEM-REBOILER", "CHEM-FLARE-RELIEF",
  ])

  // Safety Interlocks
  .connect_safety_domain("SG-CHEM-SIS-1", [
    "CHEM-PUMP-A", "CHEM-PUMP-B", "CHEM-PREHEATER", "CHEM-CSTR-REACTOR",
  ])
  .connect_safety_domain("SG-CHEM-SIS-2", [
    "CHEM-DISTILL-COL", "CHEM-CONDENSER", "CHEM-REBOILER",
  ])
  .build()
}
