/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/datum)
	if(!datum)
		return

	var/add_or_remove = tgui_input_list(usr, "Remove/Add?", "Trait Remove/Add", list("Add", "Remove"))
	if(!add_or_remove)
		return
	var/list/availible_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(datum,key))
					availible_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.global_trait_name_map)
				GLOB.global_trait_name_map = generate_global_trait_name_map()
			for(var/trait in datum._status_traits)
				var/name = GLOB.global_trait_name_map[trait] || trait
				availible_traits[name] = trait

	var/chosen_trait = tgui_input_list(usr, "Select trait to modify", "Trait", sort_list(availible_traits))
	if(!chosen_trait)
		return
	chosen_trait = availible_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			if(GLOB.movement_type_trait_to_flag[chosen_trait]) //include the required element.
				datum.AddElement(/datum/element/movetype_handler)
			ADD_TRAIT(datum, chosen_trait, source)
		if("Remove")
			var/specific = tgui_input_list(usr, "All or specific source ?", "Trait Remove/Add", list("All","Specific"))
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = tgui_input_list(usr, "Source to be removed", "Trait Remove/Add", sort_list(GET_TRAIT_SOURCES(datum, chosen_trait)))
					if(!source)
						return
			REMOVE_TRAIT(datum, chosen_trait, source)
