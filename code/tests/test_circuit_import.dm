/datum/unit_test/circuit_import/Run()
	var/obj/item/integrated_circuit/circuit = allocate(/obj/item/integrated_circuit)
	circuit.add_component(new /obj/item/circuit_component/arithmetic(circuit))
	circuit.add_component(new /obj/item/circuit_component/compare/comparison(circuit))

	var/list/circuit_data = safe_json_decode(circuit.convert_to_json())
	circuit_data["admin_only"] = TRUE
	circuit_data["external_objects"] = list("forged" = list("type" = "/obj/item/stack/sheet/mineral/diamond", "connected_components" = list()))

	var/list/stats = list("count" = 0, "size" = 0)
	var/list/sanitized = sanitize_imported_circuit_data(circuit_data, stats)

	if(!sanitized)
		TEST_FAIL("Sanitizer rejected a circuit saved by the game itself!")
		return

	if(sanitized["admin_only"])
		TEST_FAIL("Sanitized circuit data kept the admin_only flag written in the file!")

	if(sanitized["external_objects"])
		TEST_FAIL("Sanitized circuit data kept the external objects written in the file!")

	if(stats["size"] != circuit.current_size)
		TEST_FAIL("Sanitizer measured a size of [stats["size"]] instead of [circuit.current_size]!")

	circuit_data["components"]["forged"] = list("type" = "/obj/item/stack/sheet/glass")
	if(sanitize_imported_circuit_data(circuit_data, list("count" = 0, "size" = 0)))
		TEST_FAIL("Sanitizer accepted a component that is not a circuit component!")

	var/obj/machinery/r_n_d/circuit_imprinter/imprinter = allocate(/obj/machinery/r_n_d/circuit_imprinter)
	var/mob/living/carbon/human/scientist = allocate(/mob/living/carbon/human)
	imprinter.save_circuit_by_import(scientist, list(
		"name" = "forged design",
		"desc" = "forged design",
		"dupe_data" = circuit.convert_to_json(),
		"integrated_circuit" = TRUE,
		"materials" = list(MAT_GLASS = 0),
	))

	var/list/design = LAZYACCESS(imprinter.scanned_designs, 1)
	if(!design)
		TEST_FAIL("Imprinter rejected a circuit saved by the game itself!")
		return

	var/list/design_materials = design["materials"]
	if(design_materials[MAT_GLASS] <= 0)
		TEST_FAIL("Imported design kept the material cost written in the file!")
