/datum/action/cooldown/spell/greater_knock
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the station, and announce this spell's use to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"
	button_icon_state = "greater_knock"
	cooldown_time = 20 SECONDS
	invocation = "MAIOR OXIN FIERA"
	invocation_type = INVOCATION_SHOUT
	spell_max_level = 0 //Cannot be improved, quality of life since can't be refunded
	var/used = FALSE

/datum/action/cooldown/spell/greater_knock/can_cast_spell(feedback)
	return ..() && !used


/datum/action/cooldown/spell/greater_knock/cast(atom/cast_on)
	. = ..()
	used = TRUE
	for(var/obj/machinery/door/airlock/A as anything in GLOB.airlocks)
		if(is_station_level(A.z))
			A.req_access = list()
	GLOB.major_announcement.announce(
		message = "Мы убрали все доступы с шлюзов на вашей станции. Вы сможете поблагодарить нас позже!",
		new_title = "Послание Федерации Космических Волшебников.",
		new_sound = 'sound/misc/notice2.ogg',
		new_subtitle = "Приветствуем!",
		color_override = "purple"
	)
