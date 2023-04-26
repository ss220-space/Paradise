//Quick type checks for some tools
/proc/isscrewdriver(O)
	if(istype(O, /obj/item/screwdriver))
		return TRUE
	return FALSE

/proc/iscoil(O)
	if(istype(O, /obj/item/stack/cable_coil))
		return TRUE
	return FALSE

/proc/ispowertool(O)//used to check if a tool can force powered doors
	if(istype(O, /obj/item/crowbar/power) || istype(O, /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw))
		return TRUE
	return FALSE
