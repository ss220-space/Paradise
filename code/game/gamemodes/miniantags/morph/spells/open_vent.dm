/datum/action/cooldown/spell/aoe/open_vent
	name = "Открыть вентиляцию"
	desc = "Выплюньте кислотную рвоту на ближайшие вентиляционные решётки или скрубберы. Кислоте потребуется некоторое время, чтобы подействовать. Нельзя использовать изнутри вентиляции."
	button_icon_state = "acid_vent"
	background_icon_state = "bg_morph"
	spell_requirements = NONE
	aoe_radius = 1
	var/hunger_cost = 10

/datum/action/cooldown/spell/aoe/open_vent/create_new_handler()
	var/datum/spell_handler/morph/handler = new
	handler.hunger_cost = hunger_cost
	name = "[initial(name)] ([hunger_cost])"
	build_all_button_icons()

/datum/action/cooldown/spell/aoe/open_vent/is_valid_target(atom/cast_on)
	if(istype(cast_on, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/S = target
		return S.welded
	if(istype(cast_on, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_pump/V = target
		return V.welded
	return FALSE

/datum/action/cooldown/spell/aoe/open_vent/cast(atom/cast_on)
	to_chat(owner, span_sinister("Вы начинаете изрыгать кислотную рвоту!"))
	owner.balloon_alert(owner, "подготовка...")
	if(!do_after(owner, 2 SECONDS, owner, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		owner.balloon_alert(owner, "отменено")
		reset_spell_cooldown()
		return
	return  ..()

/datum/action/cooldown/spell/aoe/open_vent/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/obj/machinery/atmospherics/unary/unary = victim
	unary.add_overlay(GLOB.acid_overlay)
	addtimer(CALLBACK(src, PROC_REF(unweld_vent), unary), 2 SECONDS)
	playsound(unary, 'sound/items/welder.ogg', 100, TRUE)

/datum/action/cooldown/spell/aoe/open_vent/proc/unweld_vent(obj/machinery/atmospherics/unary/unary)
	if(istype(unary, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/scrubber = unary
		scrubber.set_welded(FALSE)
	else if(istype(unary, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/vent = unary
		vent.set_welded(FALSE)
	unary.cut_overlay(GLOB.acid_overlay)

