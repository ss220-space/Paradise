/datum/action/cooldown/spell/pointed/break_vent
	name = "Break Welded Vent"
	desc = "Breaks welded vent nearby. Can be used from inside the pipes."
	button_icon_state = "acid_vent"
	background_icon_state = "bg_alien"
	active_background_icon_state = "bg_alien"
	cooldown_time = 1 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	cast_range = 1

/datum/action/cooldown/spell/pointed/break_vent/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/pointed/break_vent/is_valid_target(atom/cast_on)
	if(istype(cast_on, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = cast_on
		return scrubber.welded

	if(istype(cast_on, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/vent = cast_on
		return vent.welded

	return FALSE

/datum/action/cooldown/spell/pointed/break_vent/cast(atom/cast_on)
	. = ..()
	var/obj/machinery/atmospherics/vent = cast_on
	if(!vent)
		to_chat(owner, span_warning("No nearby welded vents found!"))
		reset_spell_cooldown()
		return

	playsound(get_turf(owner),'sound/weapons/bladeslice.ogg' , 100, FALSE)

	if(!do_after(owner, 4 SECONDS, vent, max_interact_count = 1))
		to_chat(owner, span_danger("There is no welded vent or scrubber close enough to do this."))
		reset_spell_cooldown()
		return

	playsound(get_turf(owner),'sound/weapons/bladeslice.ogg' , 100, FALSE)

	if(vent?.welded)
		vent.set_welded(FALSE)
		owner.forceMove(vent.loc)
		vent.visible_message(span_danger("[owner] smashes the welded cover off [vent]!"))

