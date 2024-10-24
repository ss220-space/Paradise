/obj/mecha
	//Action datums
	var/datum/action/innate/mecha/mech_eject/eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/internals_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/stats_action = new
	var/datum/action/innate/mecha/mech_defence_mode/defense_action = new
	var/datum/action/innate/mecha/mech_overload_mode/overload_action = new
	var/datum/action/innate/mecha/mech_toggle_thrusters/thrusters_action = new
	var/datum/effect_system/smoke_spread/smoke_system = new //not an action, but trigged by one
	var/datum/action/innate/mecha/mech_smoke/smoke_action = new
	var/datum/action/innate/mecha/mech_zoom/zoom_action = new
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new
	var/datum/action/innate/mecha/mech_energywall/energywall_action = new
	var/datum/action/innate/mecha/mech_strafe/strafe_action = new
	var/list/module_actions = list()

/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	if(strafe_allowed)
		strafe_action.Grant(user, src)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.give_targeted_action()

/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)
	if(strafe_allowed)
		strafe_action.Remove(user)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.remove_targeted_action()

/datum/action/innate/mecha
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/mecha/chassis

/datum/action/innate/mecha/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
	. = ..()

/datum/action/innate/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/innate/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/mech_eject/Activate()
	if(!owner)
		return
	if(!chassis || chassis.occupant != owner)
		return
	chassis.go_out()

/datum/action/innate/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/innate/mecha/mech_toggle_internals/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.occupant_message("Now taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"].")
	chassis.log_message("Now taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.lights = !chassis.lights
	if(chassis.lights)
		chassis.set_light(chassis.lights_power, null, chassis.lights_color, l_on = TRUE)
		button_icon_state = "mech_lights_on"
	else
		chassis.set_light(-chassis.lights_power, l_on = TRUE)
		button_icon_state = "mech_lights_off"
	chassis.occupant_message("Toggled lights [chassis.lights ? "on" : "off"].")
	chassis.log_message("Toggled lights [chassis.lights ? "on" : "off"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/innate/mecha/mech_view_stats/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.occupant << browse(chassis.get_stats_html(), "window=exosuit")

/datum/action/innate/mecha/mech_defence_mode
	name = "Toggle Defence Mode"
	button_icon_state = "mech_defense_mode_off"

/datum/action/innate/mecha/mech_defence_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.defence_mode = forced_state
	else
		chassis.defence_mode = !chassis.defence_mode
	button_icon_state = "mech_defense_mode_[chassis.defence_mode ? "on" : "off"]"
	if(chassis.defence_mode)
		chassis.deflect_chance = chassis.defence_mode_deflect_chance
		chassis.occupant_message(span_notice("You enable [chassis] defence mode."))
	else
		chassis.deflect_chance = initial(chassis.deflect_chance)
		chassis.occupant_message(span_danger("You disable [chassis] defence mode."))
	chassis.log_message("Toggled defence mode.")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/mech_overload_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.obj_integrity < chassis.max_integrity - chassis.max_integrity / 3)
		chassis.occupant_message(span_danger("The leg actuators are too damaged to overload!"))
		return // Can't activate them if the mech is too damaged
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.")
	if(chassis.leg_overload_mode)
		chassis.leg_overload_mode = 1
		// chassis.bumpsmash = 1
		chassis.step_in = min(1, round(chassis.step_in / 2))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min, chassis.step_energy_drain * chassis.leg_overload_coeff)
		chassis.occupant_message(span_danger("You enable leg actuators overload."))
	else
		chassis.leg_overload_mode = 0
		// chassis.bumpsmash = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message(span_notice("You disable leg actuators overload."))
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.get_charge() > 0)
		chassis.thrusters_active = !chassis.thrusters_active
		button_icon_state = "mech_thrusters_[chassis.thrusters_active ? "on" : "off"]"
		chassis.log_message("Toggled thrusters.")
		chassis.occupant_message("<font color='[chassis.thrusters_active ? "blue" : "red"]'>Thrusters [chassis.thrusters_active ? "en" : "dis"]abled.")
	if(chassis.thrusters_active)
		chassis.icon_state = "[chassis.icon_state]-thruster"
	else
		chassis.icon_state = splittext(chassis.icon_state, "-")[1]

/datum/action/innate/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/mech_smoke/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.smoke_ready && chassis.smoke > 0)
		chassis.smoke_system.start()
		chassis.smoke--
		chassis.smoke_ready = FALSE
		addtimer(CALLBACK(chassis, TYPE_PROC_REF(/obj/mecha, set_smoke_ready)), chassis.smoke_cooldown)
	else
		chassis.occupant_message(span_warning("You are either out of smoke, or the smoke isn't ready yet."))

/datum/action/innate/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/mech_zoom/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.")
		chassis.occupant_message("<font color='[chassis.zoom_mode ? "blue" : "red"]'>Zoom mode [chassis.zoom_mode ? "en" : "dis"]abled.</font>")
		if(chassis.zoom_mode)
			owner.client.AddViewMod("mecha", 12)
			SEND_SOUND(owner, sound(chassis.zoomsound, volume = 50))
		else
			owner.client.RemoveViewMod("mecha")
		UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[chassis.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	UpdateButtonIcon()


/datum/action/innate/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/new_damtype
	switch(chassis.damtype)
		if("tox")
			new_damtype = "brute"
			chassis.occupant_message("Your exosuit's hands form into fists.")
		if("brute")
			new_damtype = "fire"
			chassis.occupant_message("A torch tip extends from your exosuit's hand, glowing red.")
		if("fire")
			new_damtype = "tox"
			chassis.occupant_message("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_energywall
	name = "Energy Wall"
	button_icon_state = "energywall"

/datum/action/innate/mecha/mech_energywall/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.wall_ready)
		new chassis.wall_type(get_turf(chassis), chassis)
		if(chassis.large_wall)
			if(chassis.dir == SOUTH || chassis.dir == NORTH)
				new chassis.wall_type(get_step(chassis, EAST), chassis)
				new chassis.wall_type(get_step(chassis, WEST), chassis)
			else
				new chassis.wall_type(get_step(chassis, NORTH), chassis)
				new chassis.wall_type(get_step(chassis, SOUTH), chassis)
		chassis.wall_ready = FALSE
		addtimer(CALLBACK(chassis, TYPE_PROC_REF(/obj/mecha, set_wall_ready)), chassis.wall_cooldown)
	else
		chassis.occupant_message(span_warning("Energy wall is not ready yet!"))

/////////////////////////////////// STRAFE PROCS ////////////////////////////////////////////////
/datum/action/innate/mecha/mech_strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/innate/mecha/mech_strafe/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.toggle_strafe()

/obj/mecha/AltClick(mob/living/user) //Strafing is toggled by interface button or by Alt-clicking on mecha
	if(!occupant || occupant != user)
		return

	toggle_strafe()

/**
 * Proc that toggles strafe mode of the mecha ON/OFF
 *
 * Arguments
 * * silent - if we want to stop showing messages for mecha pilot and prevent logging
 */
/obj/mecha/proc/toggle_strafe(silent = FALSE)
	if(!strafe_allowed)
		occupant_message("This mecha doesn't support strafing!")
		return
	var/datum/action/innate/mecha/mech_strafe/mech_strafe = locate(/datum/action/innate/mecha/mech_strafe) in occupant.actions
	if(!mech_strafe)
		return
	strafe = !strafe
	mech_strafe.button_icon_state = "strafe[strafe ? "_on" : ""]"
	mech_strafe.UpdateButtonIcon()
	if(!silent)
		occupant_message("<font color='[strafe ? "green" : "red"]'>Strafing mode [strafe ? "en" : "dis"]abled.")
		log_message("Toggled strafing mode [strafe ? "on" : "off"].")

/datum/action/innate/mecha/select_module
	name = "Hey, you shouldn't see it"
	var/obj/item/mecha_parts/mecha_equipment/equipment

/datum/action/innate/mecha/select_module/Grant(mob/living/L, obj/mecha/M, obj/item/mecha_parts/mecha_equipment/_equipment)
	if(!_equipment)
		return FALSE
	equipment = _equipment
	name = "Switched module to [equipment.name]"
	icon_icon = equipment.icon
	button_icon_state = equipment.icon_state
	. = ..()

/datum/action/innate/mecha/select_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	equipment.select_module()
/datum/action/innate/mecha/toggle_module
	var/obj/item/mecha_parts/mecha_equipment/equipment

/datum/action/innate/mecha/toggle_module/Grant(mob/living/L, obj/mecha/M, obj/item/mecha_parts/mecha_equipment/_equipment)
	if(!_equipment)
		return FALSE
	equipment = _equipment
	name = "Toggles [equipment.name] module"
	icon_icon = equipment.icon
	button_icon_state = equipment.icon_state
	. = ..()

/datum/action/innate/mecha/toggle_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	equipment.toggle_module()
