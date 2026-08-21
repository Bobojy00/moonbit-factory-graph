///|
test "all_industrial_presets_instantiation" {
  let auto_plant = build_automotive_plant()
  assert_eq(auto_plant.node_count() > 20, true)
  assert_eq(auto_plant.edge_count() > 30, true)

  let bat_plant = build_lithium_battery_plant()
  assert_eq(bat_plant.node_count() > 20, true)
  assert_eq(bat_plant.edge_count() > 30, true)

  let semi_plant = build_semiconductor_packaging_plant()
  assert_eq(semi_plant.node_count() > 18, true)
  assert_eq(semi_plant.edge_count() > 25, true)

  let chem_plant = build_chemical_plant()
  assert_eq(chem_plant.node_count() > 10, true)
  assert_eq(chem_plant.edge_count() > 15, true)
}
