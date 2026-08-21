///|
pub fn generate_executive_audit_report(graph : @graph.FactoryGraph) -> String {
  let buf = StringBuilder::new()
  let cfg = graph.config()
  let kpis = @analysis.compute_plant_kpis(graph)
  let b_report = @analysis.analyze_production_bottlenecks(graph)
  let s_report = @analysis.audit_plant_safety_systems(graph)

  buf.write_string("# Smart Factory Topology & Operations Audit Report\n\n")
  buf.write_string("**Facility Name:** " + cfg.plant_name + "  \n")
  buf.write_string("**Location:** " + cfg.site_location + "  \n")
  buf.write_string("**Topology Model Version:** " + cfg.version + "  \n\n")

  buf.write_string("## 1. Executive KPIs Summary\n\n")
  buf.write_string("| Metric | Value | Unit | Evaluation |\n")
  buf.write_string("| :--- | :--- | :--- | :--- |\n")
  buf.write_string(
    "| Total Plant Assets | " +
    kpis.total_asset_count.to_string() +
    " | units | Operational Base |\n",
  )
  buf.write_string(
    "| Active Assets | " +
    kpis.active_asset_count.to_string() +
    " | units | " +
    @types.format_double(kpis.operational_availability_percent, 1) +
    "% Availability |\n",
  )
  buf.write_string(
    "| Total Power Demand | " +
    @types.format_double(kpis.total_power_demand_kw, 1) +
    " | kW | Connected Load |\n",
  )
  buf.write_string(
    "| Target Takt Time | " +
    @types.format_double(kpis.target_takt_time_sec, 1) +
    " | sec | Production Beat |\n",
  )
  buf.write_string(
    "| Max Theoretical Output | " +
    @types.format_double(kpis.max_output_per_hour, 1) +
    " | units/h | Capacity Ceiling |\n",
  )
  buf.write_string(
    "| Plant Overall Health Score | " +
    @types.format_double(kpis.plant_health_score, 1) +
    " | / 100 | Composite Health |\n\n",
  )

  buf.write_string("## 2. Production Bottleneck Analysis\n\n")
  buf.write_string(
    "- **Primary Bottleneck Station:** `" +
    b_report.primary_bottleneck_node_id +
    "` (Cycle Time: " +
    @types.format_double(b_report.primary_bottleneck_cycle_time, 1) +
    "s)\n",
  )
  buf.write_string(
    "- **Line Balancing Efficiency:** " +
    @types.format_double(b_report.line_balance_efficiency_percent, 1) +
    "%\n",
  )
  buf.write_string(
    "- **Secondary Bottlenecks:** " +
    b_report.secondary_bottlenecks.length().to_string() +
    " stations identified exceeding target takt time.\n\n",
  )

  buf.write_string("## 3. Safety & SIL Compliance Status\n\n")
  buf.write_string("- **Compliance Grade:** " + s_report.audit_status + "\n")
  buf.write_string(
    "- **Total Safety Domains:** " +
    s_report.total_safety_zones.to_string() +
    "\n",
  )
  buf.write_string(
    "- **E-Stop Protection Coverage:** " +
    @types.format_double(s_report.estop_coverage_percent, 1) +
    "%\n",
  )

  buf.to_string()
}
