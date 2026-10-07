/obj/structure/swarmer/nanobot_fabricator
	name = "swarmer nanobot fabricator"
	desc = "Сооружение \"Свармеров\", которое производит наноботов, способных напрямую извлекать материю из живых существ, и конструировать \"Свармеров\" из неё на месте."
	icon = 'icons/obj/swarmer_96x96.dmi'
	icon_state = "citadel"
	layer = HIGH_OBJ_LAYER
	bound_width = 96
	bound_height = 96
	max_integrity = 500
	projectiles_pass = FALSE
	lon_range = 3

/obj/structure/swarmer/nanobot_fabricator/Initialize(mapload)
	. = ..()
	var/datum/team/swarmer_team/swarmer_team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!swarmer_team)
		return INITIALIZE_HINT_QDEL

	swarmer_team.on_nanobot_fabricator_init(src)


