/proc/hazard_flavour(obj/overmap/feature/hazard/hazard)
	switch(hazard?.icon_state)
		if(OVERMAP_HAZARD_ICON_EMP)
			return "emp"
		if(OVERMAP_HAZARD_ICON_CARP)
			return "carp"
		if(OVERMAP_HAZARD_ICON_ASTEROID)
			return "asteroid"
	return null
