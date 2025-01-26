/obj/structure/blob/normal
	name = "normal blob"
	icon_state = "blob"
	light_range = 0
	max_integrity = BLOB_REGULAR_MAX_HP
	var/initial_integrity = BLOB_REGULAR_HP_INIT
	health_regen = BLOB_REGULAR_HP_REGEN
	brute_resist = BLOB_BRUTE_RESIST * 0.5


/obj/structure/blob/normal/Initialize(mapload, owner_overmind)
	. = ..()
	update_integrity(initial_integrity)

/obj/structure/blob/normal/scannerreport()
	if(compromised_integrity)
		return "В настоящее время слаб к урону травмами."
	return "N/A"

/obj/structure/blob/normal/update_name()
	. = ..()
	name = "[(compromised_integrity) ? "fragile " : (overmind ? null : "dead ")][initial(name)]"

/obj/structure/blob/normal/update_desc()
	. = ..()
	if(compromised_integrity)
		desc = "Тонкая решетка слегка подергивающихся щупалец."
	else if(overmind)
		desc = "Толстая стена извивающихся щупалец."
	else
		desc = "Толстая стена извивающихся щупалец."

/obj/structure/blob/normal/update_icon_state()
	icon_state = "blob[(compromised_integrity) ? "_damaged" : null]"
	return ..()


/obj/structure/blob/normal/update_state()
	if(obj_integrity <= 15)
		compromised_integrity = TRUE
	else
		compromised_integrity = FALSE

	if(compromised_integrity)
		brute_resist = BLOB_BRUTE_RESIST
	else if(overmind)
		brute_resist = BLOB_BRUTE_RESIST * 0.5
	else
		brute_resist = BLOB_BRUTE_RESIST * 0.5
