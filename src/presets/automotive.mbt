///|
pub fn build_automotive_plant() -> @graph.FactoryGraph {
  let builder = @graph.FactoryGraphBuilder::new(
    plant_name="Automotive Manufacturing Gigafactory",
    location="Shanghai Automotive Smart Industrial Park",
    takt_time_target_sec=45.0,
  )

  builder
  // Substation & Central Automation
  .add_power_source(
    "SUB-01",
    "110kV/10kV High-Voltage Substation",
    zone="Infrastructure",
    capacity_kw=5000.0,
  )
  .add_power_source(
    "SUB-02",
    "10kV/380V Low-Voltage Main Transformer",
    zone="Infrastructure",
    capacity_kw=2500.0,
  )
  .add_plc(
    "PLC-MASTER",
    "Plant Central SCADA & Master PLC",
    zone="ControlCenter",
  )
  .add_plc("PLC-STAMP", "Stamping Line PLC", zone="StampingShop")
  .add_plc("PLC-WELD", "Robotic BIW Welding Shop PLC", zone="WeldingShop")
  .add_plc("PLC-PAINT", "Paint Shop SCADA PLC", zone="PaintShop")
  .add_plc("PLC-ASSEMBLY", "Final Assembly Line PLC", zone="AssemblyShop")

  // Stamping Shop
  .add_workstation(
    "STAMP-UNCOIL",
    "Sheet Steel Uncoiler & Blanking",
    zone="StampingShop",
    cycle_time_sec=35.0,
    nominal_power_kw=120.0,
    safety_zone_id="SZ-STAMP",
  )
  .add_machine(
    "STAMP-PRESS-1",
    "2500-Ton Tandem Hydraulic Press",
    zone="StampingShop",
    cycle_time_sec=40.0,
    nominal_power_kw=350.0,
    safety_zone_id="SZ-STAMP",
  )
  .add_machine(
    "STAMP-PRESS-2",
    "1600-Ton Hydraulic Trimming Press",
    zone="StampingShop",
    cycle_time_sec=38.0,
    nominal_power_kw=220.0,
    safety_zone_id="SZ-STAMP",
  )
  .add_buffer(
    "BUF-PANELS",
    "Stamped Body Panels Buffer",
    zone="StampingShop",
    capacity=500.0,
  )

  // Body-in-White (BIW) Welding Shop
  .add_robot(
    "WELD-FLOOR",
    "Underbody Floor Robotic Welding Cell",
    zone="WeldingShop",
    cycle_time_sec=42.0,
    nominal_power_kw=65.0,
    safety_zone_id="SZ-WELD",
  )
  .add_robot(
    "WELD-SIDE",
    "Bodyside Left/Right Framing Cell",
    zone="WeldingShop",
    cycle_time_sec=44.0,
    nominal_power_kw=75.0,
    safety_zone_id="SZ-WELD",
  )
  .add_robot(
    "WELD-ROOF",
    "Roof Laser Brazing Robotic Station",
    zone="WeldingShop",
    cycle_time_sec=38.0,
    nominal_power_kw=45.0,
    safety_zone_id="SZ-WELD",
  )
  .add_workstation(
    "WELD-RESPOT",
    "Final BIW Respot & Geometric Audit",
    zone="WeldingShop",
    cycle_time_sec=40.0,
    nominal_power_kw=30.0,
    safety_zone_id="SZ-WELD",
  )
  .add_buffer(
    "BUF-BIW-STORAGE",
    "Body-in-White Painted Buffer High-Bay",
    zone="WeldingShop",
    capacity=300.0,
  )

  // Paint Shop
  .add_machine(
    "PAINT-ED-DIP",
    "Cathodic Electrodeposition Dip Tank",
    zone="PaintShop",
    cycle_time_sec=45.0,
    nominal_power_kw=180.0,
    safety_zone_id="SZ-PAINT",
  )
  .add_robot(
    "PAINT-PRIMER",
    "Primer Automated Spray Robot Cell",
    zone="PaintShop",
    cycle_time_sec=42.0,
    nominal_power_kw=55.0,
    safety_zone_id="SZ-PAINT",
  )
  .add_robot(
    "PAINT-TOPCOAT",
    "Topcoat Metallic Color Spray Cell",
    zone="PaintShop",
    cycle_time_sec=44.0,
    nominal_power_kw=60.0,
    safety_zone_id="SZ-PAINT",
  )
  .add_machine(
    "PAINT-OVEN",
    "High-Temperature Curing Baking Oven",
    zone="PaintShop",
    cycle_time_sec=45.0,
    nominal_power_kw=280.0,
    safety_zone_id="SZ-PAINT",
  )
  .add_buffer(
    "BUF-PAINTED-BODIES",
    "Painted Body Sequencing High-Bay Buffer",
    zone="PaintShop",
    capacity=400.0,
  )

  // Final Assembly Shop
  .add_workstation(
    "ASSY-TRIM-1",
    "Interior Wiring & Insulation Deck",
    zone="AssemblyShop",
    cycle_time_sec=42.0,
    nominal_power_kw=12.0,
    safety_zone_id="SZ-ASSY",
  )
  .add_workstation(
    "ASSY-COCKPIT",
    "Cockpit & Instrument Panel Install",
    zone="AssemblyShop",
    cycle_time_sec=44.0,
    nominal_power_kw=15.0,
    safety_zone_id="SZ-ASSY",
  )
  .add_robot(
    "ASSY-GLAZING",
    "Windshield & Rear Glass Robotic Gluing",
    zone="AssemblyShop",
    cycle_time_sec=38.0,
    nominal_power_kw=18.0,
    safety_zone_id="SZ-ASSY",
  )
  .add_workstation(
    "ASSY-CHASSIS",
    "Powertrain & Battery Marriage Decking",
    zone="AssemblyShop",
    cycle_time_sec=45.0,
    nominal_power_kw=40.0,
    safety_zone_id="SZ-ASSY",
  )
  .add_workstation(
    "ASSY-WHEELS",
    "Wheel Torque & Suspension Tightening",
    zone="AssemblyShop",
    cycle_time_sec=36.0,
    nominal_power_kw=22.0,
    safety_zone_id="SZ-ASSY",
  )
  .add_inspection(
    "ASSY-INSPECT",
    "End-of-Line Dynamic Dyno & ADAS Testing",
    zone="AssemblyShop",
    cycle_time_sec=45.0,
    nominal_power_kw=35.0,
    safety_zone_id="SZ-ASSY",
  )

  // Safety Gates & Sensors
  .add_safety_gate(
    "SG-STAMP",
    "Stamping Press Safety Optical Curtain",
    zone="StampingShop",
    safety_zone_id="SZ-STAMP",
  )
  .add_safety_gate(
    "SG-WELD",
    "BIW Laser Brazing Interlocked Enclosure",
    zone="WeldingShop",
    safety_zone_id="SZ-WELD",
  )
  .add_safety_gate(
    "SG-PAINT",
    "Paint VOC Explosion-Proof Interlock Gate",
    zone="PaintShop",
    safety_zone_id="SZ-PAINT",
  )
  .add_safety_gate(
    "SG-ASSY",
    "Assembly AGV Cross-Zone E-Stop Gate",
    zone="AssemblyShop",
    safety_zone_id="SZ-ASSY",
  )

  // Material Flow Wiring
  .connect_material(
    "STAMP-UNCOIL",
    "STAMP-PRESS-1",
    bandwidth=1200.0,
    delay=1.0,
  )
  .connect_material(
    "STAMP-PRESS-1",
    "STAMP-PRESS-2",
    bandwidth=1200.0,
    delay=1.5,
  )
  .connect_material("STAMP-PRESS-2", "BUF-PANELS", bandwidth=1200.0, delay=2.0)
  .connect_material("BUF-PANELS", "WELD-FLOOR", bandwidth=1200.0, delay=3.0)
  .connect_material("WELD-FLOOR", "WELD-SIDE", bandwidth=1200.0, delay=2.0)
  .connect_material("WELD-SIDE", "WELD-ROOF", bandwidth=1200.0, delay=2.0)
  .connect_material("WELD-ROOF", "WELD-RESPOT", bandwidth=1200.0, delay=1.5)
  .connect_material(
    "WELD-RESPOT",
    "BUF-BIW-STORAGE",
    bandwidth=1200.0,
    delay=4.0,
  )
  .connect_material(
    "BUF-BIW-STORAGE",
    "PAINT-ED-DIP",
    bandwidth=1200.0,
    delay=3.0,
  )
  .connect_material("PAINT-ED-DIP", "PAINT-PRIMER", bandwidth=1200.0, delay=2.5)
  .connect_material(
    "PAINT-PRIMER",
    "PAINT-TOPCOAT",
    bandwidth=1200.0,
    delay=2.5,
  )
  .connect_material("PAINT-TOPCOAT", "PAINT-OVEN", bandwidth=1200.0, delay=3.0)
  .connect_material(
    "PAINT-OVEN",
    "BUF-PAINTED-BODIES",
    bandwidth=1200.0,
    delay=4.0,
  )
  .connect_material(
    "BUF-PAINTED-BODIES",
    "ASSY-TRIM-1",
    bandwidth=1200.0,
    delay=3.0,
  )
  .connect_material("ASSY-TRIM-1", "ASSY-COCKPIT", bandwidth=1200.0, delay=2.0)
  .connect_material("ASSY-COCKPIT", "ASSY-GLAZING", bandwidth=1200.0, delay=2.0)
  .connect_material("ASSY-GLAZING", "ASSY-CHASSIS", bandwidth=1200.0, delay=2.0)
  .connect_material("ASSY-CHASSIS", "ASSY-WHEELS", bandwidth=1200.0, delay=2.0)
  .connect_material("ASSY-WHEELS", "ASSY-INSPECT", bandwidth=1200.0, delay=2.0)

  // Power Grid Wiring
  .connect_energy(
    "SUB-01",
    "SUB-02",
    energy_type=@types.EnergyType::AC_380V_3Phase,
  )
  .connect_power_bus("SUB-02", [
    "STAMP-UNCOIL", "STAMP-PRESS-1", "STAMP-PRESS-2", "WELD-FLOOR", "WELD-SIDE",
    "WELD-ROOF", "WELD-RESPOT", "PAINT-ED-DIP", "PAINT-PRIMER", "PAINT-TOPCOAT",
    "PAINT-OVEN", "ASSY-TRIM-1", "ASSY-COCKPIT", "ASSY-GLAZING", "ASSY-CHASSIS",
    "ASSY-WHEELS", "ASSY-INSPECT", "PLC-MASTER", "PLC-STAMP", "PLC-WELD", "PLC-PAINT",
    "PLC-ASSEMBLY",
  ])

  // Control Hierarchy
  .connect_control("PLC-MASTER", "PLC-STAMP")
  .connect_control("PLC-MASTER", "PLC-WELD")
  .connect_control("PLC-MASTER", "PLC-PAINT")
  .connect_control("PLC-MASTER", "PLC-ASSEMBLY")
  .connect_plc_network("PLC-STAMP", [
    "STAMP-UNCOIL", "STAMP-PRESS-1", "STAMP-PRESS-2",
  ])
  .connect_plc_network("PLC-WELD", [
    "WELD-FLOOR", "WELD-SIDE", "WELD-ROOF", "WELD-RESPOT",
  ])
  .connect_plc_network("PLC-PAINT", [
    "PAINT-ED-DIP", "PAINT-PRIMER", "PAINT-TOPCOAT", "PAINT-OVEN",
  ])
  .connect_plc_network("PLC-ASSEMBLY", [
    "ASSY-TRIM-1", "ASSY-COCKPIT", "ASSY-GLAZING", "ASSY-CHASSIS", "ASSY-WHEELS",
    "ASSY-INSPECT",
  ])

  // Safety Interlock Wiring
  .connect_safety_domain("SG-STAMP", [
    "STAMP-UNCOIL", "STAMP-PRESS-1", "STAMP-PRESS-2",
  ])
  .connect_safety_domain("SG-WELD", [
    "WELD-FLOOR", "WELD-SIDE", "WELD-ROOF", "WELD-RESPOT",
  ])
  .connect_safety_domain("SG-PAINT", [
    "PAINT-ED-DIP", "PAINT-PRIMER", "PAINT-TOPCOAT", "PAINT-OVEN",
  ])
  .connect_safety_domain("SG-ASSY", [
    "ASSY-TRIM-1", "ASSY-COCKPIT", "ASSY-GLAZING", "ASSY-CHASSIS", "ASSY-WHEELS",
    "ASSY-INSPECT",
  ])
  .build()
}
