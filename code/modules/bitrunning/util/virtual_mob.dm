/mob/living/carbon/proc/make_virtual_mob()
	add_traits(list(TRAIT_NO_BREATH, TRAIT_NO_BLOOD, TRAIT_NO_HUNGER, TRAIT_RESIST_COLD, TRAIT_WEATHER_IMMUNE), VIRTUAL_ENTITY_TRAIT)
	if(ishuman(src))
		var/mob/living/carbon/human/human = src
		human.physiology.pressure_mod = 0

/mob/living/carbon/human/proc/set_service_style()
	var/static/list/approved_hair_colors = list(
		"#4B3D28",
		COLOR_BLACK,
		"#8D4A43",
		"#D2B48C",
	)
	var/static/list/approved_hairstyles = list(
		"Combover",
		"Crewcut",
		"Flat Top",
		"Mulder",
		"Parted",
	)

	change_facial_hair("Shaved")
	change_hair_color(pick(approved_hair_colors))
	change_hair(pick(approved_hairstyles))
