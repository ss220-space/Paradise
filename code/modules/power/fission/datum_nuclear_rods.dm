/datum/nuclear_rod_design
	var/type_path
	var/category = "Unknown"
	var/list/metadata

/datum/nuclear_rod_design/proc/build_metadata_list(path)
	metadata = list()
	type_path = path

	var/obj/item/nuclear_rod/rod_path = path

	metadata["name"] = initial(rod_path.name)
	metadata["desc"] = initial(rod_path.desc)
	metadata["icon"] = initial(rod_path.icon)
	metadata["icon_state"] = initial(rod_path.icon_state)
	metadata["type_path"] = path

	metadata["max_durability"] = initial(rod_path.max_durability)
	metadata["degradation_speed"] = initial(rod_path.degradation_speed)
	metadata["heat_amount"] = initial(rod_path.heat_amount)
	metadata["heat_amp_mod"] = initial(rod_path.heat_amp_mod)
	metadata["power_amount"] = initial(rod_path.power_amount)
	metadata["power_amp_mod"] = initial(rod_path.power_amp_mod)
	metadata["radiation_range"] = initial(rod_path.radiation_range)
	metadata["radiation_treshhold"] = initial(rod_path.radiation_treshhold)
	metadata["radiation_chance"] = initial(rod_path.radiation_chance)
	metadata["minimum_temp_modifier"] = initial(rod_path.minimum_temp_modifier)
	metadata["upgrade_required"] = initial(rod_path.upgrade_required)

	metadata["required_object"] = initial(rod_path.required_object)

	// Temp object lets us read in materials and adjacent requirements because you can't initial() a list
	var/obj/item/nuclear_rod/temp_rod = new path()
	var/list/raw_materials = temp_rod.materials
	var/list/requirements = temp_rod.adjacent_requirements
	qdel(temp_rod)

	if(raw_materials && length(raw_materials))
		var/list/formatted_materials = list()
		for(var/mat_id in raw_materials)
			var/display_name = CallMaterialName(mat_id)
			formatted_materials[display_name] = raw_materials[mat_id]
		metadata["materials"] = formatted_materials
	else
		metadata["materials"] = list()

	if(ispath(path, /obj/item/nuclear_rod/fuel))
		var/obj/item/nuclear_rod/fuel/fuel_rod_path = path
		metadata["craftable"] = initial(fuel_rod_path.craftable)
		metadata["enrichment_cycles"] = initial(fuel_rod_path.enrichment_cycles)
		metadata["power_enrich_threshold"] = initial(fuel_rod_path.power_enrich_threshold)
		metadata["heat_enrich_threshold"] = initial(fuel_rod_path.heat_enrich_threshold)

		// Get enrichment result names
		if(initial(fuel_rod_path.power_enrich_result))
			var/obj/item/nuclear_rod/power_result = initial(fuel_rod_path.power_enrich_result)
			metadata["power_enrichment"] = initial(power_result.name)
			metadata["power_enrichment_requirement"] = initial(fuel_rod_path.power_enrich_threshold)
		else
			metadata["power_enrichment"] = null
			metadata["power_enrichment_requirement"] = null

		if(initial(fuel_rod_path.heat_enrich_result))
			var/obj/item/nuclear_rod/heat_result = initial(fuel_rod_path.heat_enrich_result)
			metadata["heat_enrichment"] = initial(heat_result.name)
			metadata["heat_enrichment_requirement"] = initial(fuel_rod_path.heat_enrich_threshold)
		else
			metadata["heat_enrichment"] = null
			metadata["heat_enrichment_requirement"] = null
	else if(ispath(path, /obj/item/nuclear_rod/moderator))
		var/obj/item/nuclear_rod/moderator/M = path
		metadata["craftable"] = initial(M.craftable)
	else if(ispath(path, /obj/item/nuclear_rod/coolant))
		var/obj/item/nuclear_rod/coolant/C = path
		metadata["craftable"] = initial(C.craftable)
	else
		metadata["craftable"] = FALSE

	if(requirements && length(requirements))
		var/list/temp_reqs = list()
		var/list/req_counts = list()

		// Count occurrences of each requirement type
		for(var/req_path in requirements)
			var/obj/item/nuclear_rod/req = req_path
			var/req_name = initial(req.name)
			if(req_counts[req_name])
				req_counts[req_name]++
			else
				req_counts[req_name] = 1

		// Format the requirements with counts
		for(var/req_name in req_counts)
			var/count = req_counts[req_name]
			temp_reqs += "[count]x [req_name]"

		metadata["neighbor_requirements"] = temp_reqs
		metadata["adjacent_requirements_display"] = english_list(temp_reqs, and_text = ", ")
	else
		metadata["neighbor_requirements"] = list()
		metadata["adjacent_requirements_display"] = "None"

	return TRUE
