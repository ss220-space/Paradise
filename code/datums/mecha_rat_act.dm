GLOBAL_LIST_INIT(ratvar_mechas, typesof(/datum/ratvar_mecha))

/datum/ratvar_mecha
	var/ratvarized_icon = null
	var/list/mech_types = list(MECH_TYPE_NONE)

/datum/ratvar_mecha/proc/convert(obj/mecha/mecha_to_convert)
	mecha_to_convert.ratvarized = TRUE
	mecha_to_convert.initial_icon = ratvarized_icon
	mecha_to_convert.update_icon(UPDATE_ICON_STATE)
	mecha_to_convert.emag_act()
	mecha_to_convert.armor = mecha_to_convert.armor.modifyAllRatings(10)
	mecha_to_convert.operation_req_access = null
	mecha_to_convert.internals_req_access = null
	if(!mecha_to_convert.occupant)
		return
	if(isclocker(mecha_to_convert.occupant))
		return
	mecha_to_convert.occupant.SetSleeping(mecha_to_convert.destruction_sleep_duration)
	mecha_to_convert.go_out()


/datum/ratvar_mecha/ripley
	ratvarized_icon = "ripley_ratvar"
	mech_types = list(MECH_TYPE_RIPLEY)

/datum/ratvar_mecha/clarke
	ratvarized_icon = "clarke_ratvar"
	mech_types = list(MECH_TYPE_CLARKE)

/datum/ratvar_mecha/gygax
	ratvarized_icon = "gygax_ratvar"
	mech_types = list(MECH_TYPE_GYGAX, MECH_TYPE_DARK_GYGAX)

/datum/ratvar_mecha/durand
	ratvarized_icon = "durand_ratvar"
	mech_types = list(MECH_TYPE_DURAND, MECH_TYPE_MARAUDER)

/datum/ratvar_mecha/honker
	ratvarized_icon = null
	mech_types = list(MECH_TYPE_HONKER)

/datum/ratvar_mecha/honker/convert(obj/mecha/mecha_to_convert)
	mecha_to_convert.visible_message(span_clown("Силы Хонкоматери защищают этот механизм!"))
	return

/datum/ratvar_mecha/locker
	ratvarized_icon = "lockermech_ratvar"
	mech_types = list(MECH_TYPE_LOCKER)

/datum/ratvar_mecha/odysseus
	ratvarized_icon = "odysseus_ratvar"
	mech_types = list(MECH_TYPE_ODYSSEUS)

/datum/ratvar_mecha/old_durand
	ratvarized_icon = "old_durand_ratvar"
	mech_types = list(MECH_TYPE_OLD_DURAND)

/datum/ratvar_mecha/phazon
	ratvarized_icon = "phazon_ratvar"
	mech_types = list(MECH_TYPE_PHAZON)

/datum/ratvar_mecha/phazon/convert(obj/mecha/mecha_to_convert)
	mecha_to_convert.phase_state = "phazon_ratvar-phaze"
	.=..()

/datum/ratvar_mecha/reticense
	ratvarized_icon = null
	mech_types = list(MECH_TYPE_RETICENCE)

/datum/ratvar_mecha/reticense/convert(obj/mecha/mecha_to_convert)
	mecha_to_convert.visible_message(span_boldnotice("..."))
	return

/datum/ratvar_mecha/sidewinter
	ratvarized_icon = null
	mech_types = list(MECH_TYPE_SIDEWINTER)

/datum/ratvar_mecha/reticense/convert(obj/mecha/mecha_to_convert)
	mecha_to_convert.visible_message(span_clocklarge("ЧТО ЭТО ЗА ЕРЕСЬ?!?!?!"))
	return
