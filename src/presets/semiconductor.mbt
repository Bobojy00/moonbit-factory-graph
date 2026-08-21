///|
pub fn build_semiconductor_packaging_plant() -> @graph.FactoryGraph {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="Advanced Semiconductor OSAT Packaging & Test Facility",
    location="Suzhou High-Tech Microelectronics Park",
    takt_time_target_sec=12.0,
  )

  builder
  // Substation & Central PLC
  .add_power_source(
    "PWR-SEMI-01",
    "Cleanroom High-Reliability UPS Grid",
    zone="Substation",
    capacity_kw=4000.0,
  )
  .add_plc(
    "PLC-SEMI-MASTER",
    "OSAT Central MES Host & Master PLC",
    zone="MES_ServerRoom",
  )
  .add_plc(
    "PLC-FRONTEND",
    "Dicing & Die Attach Line Controller",
    zone="CleanroomClass100",
  )
  .add_plc(
    "PLC-BACKEND",
    "WireBond & Molding Line Controller",
    zone="CleanroomClass1000",
  )
  .add_plc(
    "PLC-TESTING",
    "Final ATE Handler Line Controller",
    zone="TestingZone",
  )

  // Class 100 Cleanroom (Wafer Prep, Dicing, Die Attach)
  .add_machine(
    "SEMI-BACKGRIND",
    "Ultra-Thin Wafer Backgrinding Station",
    zone="CleanroomClass100",
    cycle_time_sec=10.0,
    nominal_power_kw=45.0,
    safety_zone_id="SZ-CLEAN-1",
  )
  .add_machine(
    "SEMI-DICING",
    "High-Precision Dual-Spindle Wafer Saw",
    zone="CleanroomClass100",
    cycle_time_sec=12.0,
    nominal_power_kw=35.0,
    safety_zone_id="SZ-CLEAN-1",
  )
  .add_robot(
    "SEMI-DIE-ATTACH",
    "Sub-Micron High-Speed Epoxy Die Bonder",
    zone="CleanroomClass100",
    cycle_time_sec=11.0,
    nominal_power_kw=28.0,
    safety_zone_id="SZ-CLEAN-1",
  )
  .add_buffer(
    "BUF-DIE-CARRIER",
    "Nitrogen Purged Die Carrier SMIF Pod Buffer",
    zone="CleanroomClass100",
    capacity=1000.0,
  )

  // Class 1000 Cleanroom (Wirebonding, Flip-Chip, Molding, Trim)
  .add_machine(
    "SEMI-WIREBOND",
    "Thermo-Sonic High-Density Gold Wire Bonder",
    zone="CleanroomClass1000",
    cycle_time_sec=12.0,
    nominal_power_kw=32.0,
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_machine(
    "SEMI-MOLDING",
    "Multi-Plunger Auto Epoxy Transfer Mold",
    zone="CleanroomClass1000",
    cycle_time_sec=12.0,
    nominal_power_kw=65.0,
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_machine(
    "SEMI-CURING",
    "Post-Mold High-Temperature Nitrogen Oven",
    zone="CleanroomClass1000",
    cycle_time_sec=10.0,
    nominal_power_kw=80.0,
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_machine(
    "SEMI-LASER-MARK",
    "Picosecond Laser IC Package Marking System",
    zone="CleanroomClass1000",
    cycle_time_sec=8.0,
    nominal_power_kw=15.0,
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_machine(
    "SEMI-TRIM-FORM",
    "Automatic Leadframe Trim & Forming Tool",
    zone="CleanroomClass1000",
    cycle_time_sec=10.0,
    nominal_power_kw=22.0,
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_buffer(
    "BUF-LEADFRAME",
    "JEDEC Tray Strip Magazine Buffer",
    zone="CleanroomClass1000",
    capacity=1200.0,
  )

  // Test & Quality Zone
  .add_inspection(
    "SEMI-AOI",
    "3D Automated Optical Inspection & X-Ray",
    zone="TestingZone",
    cycle_time_sec=10.0,
    nominal_power_kw=18.0,
    safety_zone_id="SZ-TEST",
  )
  .add_machine(
    "SEMI-ATE-TEST",
    "Multi-Site High-Speed Automated Test Handler",
    zone="TestingZone",
    cycle_time_sec=12.0,
    nominal_power_kw=50.0,
    safety_zone_id="SZ-TEST",
  )
  .add_workstation(
    "SEMI-TAPE-REEL",
    "Automated Tape & Reel Carrier Packaging",
    zone="TestingZone",
    cycle_time_sec=10.0,
    nominal_power_kw=12.0,
    safety_zone_id="SZ-TEST",
  )

  // Safety Interlocks & Cleanroom Airlocks
  .add_safety_gate(
    "SG-SEMI-01",
    "Class 100 Airlock & E-Stop Interlock",
    zone="CleanroomClass100",
    safety_zone_id="SZ-CLEAN-1",
  )
  .add_safety_gate(
    "SG-SEMI-02",
    "Molding High-Pressure Clamp Safety Shield",
    zone="CleanroomClass1000",
    safety_zone_id="SZ-CLEAN-2",
  )
  .add_safety_gate(
    "SG-SEMI-03",
    "ATE Handler Robotic Enclosure Interlock",
    zone="TestingZone",
    safety_zone_id="SZ-TEST",
  )

  // Material Routing
  .connect_material(
    "SEMI-BACKGRIND",
    "SEMI-DICING",
    bandwidth=3000.0,
    delay=1.0,
  )
  .connect_material(
    "SEMI-DICING",
    "SEMI-DIE-ATTACH",
    bandwidth=3000.0,
    delay=1.0,
  )
  .connect_material(
    "SEMI-DIE-ATTACH",
    "BUF-DIE-CARRIER",
    bandwidth=3000.0,
    delay=1.5,
  )
  .connect_material(
    "BUF-DIE-CARRIER",
    "SEMI-WIREBOND",
    bandwidth=3000.0,
    delay=2.0,
  )
  .connect_material(
    "SEMI-WIREBOND",
    "SEMI-MOLDING",
    bandwidth=3000.0,
    delay=1.0,
  )
  .connect_material("SEMI-MOLDING", "SEMI-CURING", bandwidth=3000.0, delay=1.5)
  .connect_material(
    "SEMI-CURING",
    "SEMI-LASER-MARK",
    bandwidth=3000.0,
    delay=1.0,
  )
  .connect_material(
    "SEMI-LASER-MARK",
    "SEMI-TRIM-FORM",
    bandwidth=3000.0,
    delay=1.0,
  )
  .connect_material(
    "SEMI-TRIM-FORM",
    "BUF-LEADFRAME",
    bandwidth=3000.0,
    delay=1.5,
  )
  .connect_material("BUF-LEADFRAME", "SEMI-AOI", bandwidth=3000.0, delay=1.0)
  .connect_material("SEMI-AOI", "SEMI-ATE-TEST", bandwidth=3000.0, delay=1.0)
  .connect_material(
    "SEMI-ATE-TEST",
    "SEMI-TAPE-REEL",
    bandwidth=3000.0,
    delay=1.0,
  )

  // Power Delivery
  .connect_power_bus("PWR-SEMI-01", [
    "SEMI-BACKGRIND", "SEMI-DICING", "SEMI-DIE-ATTACH", "SEMI-WIREBOND", "SEMI-MOLDING",
    "SEMI-CURING", "SEMI-LASER-MARK", "SEMI-TRIM-FORM", "SEMI-AOI", "SEMI-ATE-TEST",
    "SEMI-TAPE-REEL", "PLC-SEMI-MASTER", "PLC-FRONTEND", "PLC-BACKEND", "PLC-TESTING",
  ])

  // Control Hierarchy
  .connect_control("PLC-SEMI-MASTER", "PLC-FRONTEND")
  .connect_control("PLC-SEMI-MASTER", "PLC-BACKEND")
  .connect_control("PLC-SEMI-MASTER", "PLC-TESTING")
  .connect_plc_network("PLC-FRONTEND", [
    "SEMI-BACKGRIND", "SEMI-DICING", "SEMI-DIE-ATTACH",
  ])
  .connect_plc_network("PLC-BACKEND", [
    "SEMI-WIREBOND", "SEMI-MOLDING", "SEMI-CURING", "SEMI-LASER-MARK", "SEMI-TRIM-FORM",
  ])
  .connect_plc_network("PLC-TESTING", [
    "SEMI-AOI", "SEMI-ATE-TEST", "SEMI-TAPE-REEL",
  ])

  // Safety Interlocks
  .connect_safety_domain("SG-SEMI-01", [
    "SEMI-BACKGRIND", "SEMI-DICING", "SEMI-DIE-ATTACH",
  ])
  .connect_safety_domain("SG-SEMI-02", [
    "SEMI-WIREBOND", "SEMI-MOLDING", "SEMI-CURING", "SEMI-LASER-MARK", "SEMI-TRIM-FORM",
  ])
  .connect_safety_domain("SG-SEMI-03", [
    "SEMI-AOI", "SEMI-ATE-TEST", "SEMI-TAPE-REEL",
  ])
  .build()
}
