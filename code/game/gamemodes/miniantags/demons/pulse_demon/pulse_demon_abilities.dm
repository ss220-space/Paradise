#define KW *1000
#define PULSEDEMON_REMOTE_DRAIN_MULTIPLIER 5

#define PD_UPGRADE_HIJACK_SPEED "Speed"
#define PD_UPGRADE_DRAIN_SPEED "Absorption"
#define PD_UPGRADE_HEALTH_LOSS "Endurance"
#define PD_UPGRADE_HEALTH_REGEN "Recovery"
#define PD_UPGRADE_MAX_HEALTH "Strength"
#define PD_UPGRADE_HEALTH_COST "Efficiency"
#define PD_UPGRADE_MAX_CHARGE "Capacity"

/datum/action/cooldown/spell/pointed/pulse_demon
	school = SCHOOL_ENERGY
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	background_icon_state = "bg_pulsedemon"
	background_icon_state_active = "bg_pulsedemon"
	cooldown_time = 20 SECONDS
	var/locked = TRUE
	var/unlock_cost = 1 KW
	var/cast_cost = 1 KW
	var/upgrade_cost = 1 KW
	var/requires_area = FALSE

/datum/action/cooldown/spell/pointed/pulse_demon/New(Target)
	. = ..()
	update_info()

/datum/action/cooldown/spell/pointed/pulse_demon/proc/update_info()
	if(locked)
		name = "[initial(name)] (Locked) ([format_si_suffix(unlock_cost)]W)"
		desc = "[initial(desc)] It costs [format_si_suffix(unlock_cost)]W to unlock."
	else
		name = "[initial(name)][cast_cost == 0 ? "" : " ([format_si_suffix(cast_cost)]W)"]"
		desc = "[initial(desc)][spell_level == spell_max_level ? "" : " It costs [format_si_suffix(upgrade_cost)]W to upgrade."]"
	UpdateButtonIcon()

/datum/action/cooldown/spell/pointed/pulse_demon/can_cast_spell(feedback)
	if(!..())
		return FALSE
	if(!ispulsedemon(owner))
		return FALSE
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(locked)
		if(feedback)
			to_chat(user, span_warning("This ability is locked! Right click the button to purchase this ability."))
			to_chat(user, span_notice("It costs [format_si_suffix(unlock_cost)]W to unlock."))
		return FALSE
	if(user.charge < cast_cost)
		if(feedback)
			to_chat(user, span_warning("You do not have enough charge to use this ability!"))
			to_chat(user, span_notice("It costs [format_si_suffix(cast_cost)]W to use."))
		return FALSE
	if(requires_area && !user.controlling_area)
		if(feedback)
			to_chat(user, span_warning("You need to be controlling an area to use this ability!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/cast(atom/cast_on)
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user) || locked || user.charge < cast_cost || !cast_on)
		return
	if(requires_area && !user.controlling_area)
		return
	if(requires_area && user.controlling_area != get_area(cast_on))
		to_chat(user, span_warning("You can only use this ability in your controlled area!"))
		return
	if(try_cast_action(user, cast_on))
		user.adjust_charge(-cast_cost)
		return ..()
	reset_spell_cooldown()

/datum/action/cooldown/spell/pointed/pulse_demon/proc/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	return FALSE

/datum/action/cooldown/spell/pointed/pulse_demon/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		try_buy()
		return CLICK_ACTION_SUCCESS
	return ..()

/datum/action/cooldown/spell/pointed/pulse_demon/proc/try_buy()
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user))
		return

	if(locked)
		if(user.charge < unlock_cost)
			to_chat(user, span_warning("You cannot afford this ability! It costs [format_si_suffix(unlock_cost)]W to unlock."))
			return
		user.adjust_charge(-unlock_cost)
		locked = FALSE
		to_chat(user, span_notice("You have unlocked [initial(name)]!"))

		if(cast_cost > 0)
			to_chat(user, span_notice("It costs [format_si_suffix(cast_cost)]W to use once."))
		if(spell_max_level > 0 && spell_level < spell_max_level)
			to_chat(user, span_notice("It will cost [format_si_suffix(upgrade_cost)]W to upgrade."))

		update_info()

	else
		if(spell_level >= spell_max_level)
			to_chat(user, span_warning("You have already fully upgraded this ability!"))
		else if(user.charge >= upgrade_cost)
			user.adjust_charge(-upgrade_cost)
			spell_level = min(spell_level + 1, spell_max_level)
			upgrade_cost = round(initial(upgrade_cost) * (1.5 ** spell_level))
			do_upgrade(user)

			if(spell_level == spell_max_level)
				to_chat(user, span_notice("You have fully upgraded [initial(name)]!"))
			else
				to_chat(user, span_notice("The next upgrade will cost [format_si_suffix(upgrade_cost)]W to unlock."))

			update_info()
		else
			to_chat(user, span_warning("You cannot afford to upgrade this ability! It costs [format_si_suffix(upgrade_cost)]W to upgrade."))

/datum/action/cooldown/spell/pointed/pulse_demon/proc/do_upgrade(mob/living/simple_animal/demon/pulse_demon/user)
	cooldown_time = round(initial(cooldown_time) / (1.5 ** spell_level))
	to_chat(user, span_notice("You have upgraded [initial(name)] to level [spell_level + 1], it now takes [cooldown_time / 10] seconds to recharge."))

/datum/action/cooldown/spell/pointed/pulse_demon/cablehop
	name = "Cable Hop"
	desc = "Jump to another cable in view."
	button_icon_state = "pd_cablehop"
	unlock_cost = 15 KW
	cast_cost = 5 KW
	upgrade_cost = 75 KW

/datum/action/cooldown/spell/pointed/pulse_demon/cablehop/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/turf/O = get_turf(user)
	var/turf/T = get_turf(target)
	var/obj/structure/cable/C = locate(/obj/structure/cable) in T
	if(!istype(C))
		to_chat(user, span_warning("No cable found!"))
		return FALSE
	playsound(T, 'sound/magic/lightningshock.ogg', 50, TRUE)
	O.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)
	for(var/turf/working as anything in get_line(O, T))
		for(var/mob/living/L in working)
			if(!electrocute_mob(L, C.powernet, user)) // give a little bit of non-lethal counterplay against insuls
				L.Jitter(5 SECONDS)
				L.apply_status_effect(STATUS_EFFECT_DELAYED, 1 SECONDS, CALLBACK(L, TYPE_PROC_REF(/mob/living, Stun), 5 SECONDS))
	user.forceMove(T)
	user.Move(T)
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/emagtamper
	name = "Electromagnetic Tamper"
	desc = "Unlocks hidden programming in machines. Must be inside a hijacked APC to use."
	button_icon_state = "pd_emag"
	unlock_cost = 50 KW
	cast_cost = 20 KW
	upgrade_cost = 200 KW
	requires_area = TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/emagtamper/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	to_chat(user, span_warning("You attempt to tamper with [target]!"))
	target.emag_act(user)
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/emp
	name = "Electromagnetic Pulse"
	desc = "Creates an EMP where you click. Be careful not to use it on yourself!"
	button_icon_state = "pd_emp"
	unlock_cost = 50 KW
	cast_cost = 10 KW
	upgrade_cost = 200 KW
	requires_area = TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/emp/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	to_chat(user, span_warning("You attempt to EMP [target]!"))
	empulse(get_turf(target), 1, 1)
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/overload
	name = "Overload Machine"
	desc = "Overloads a machine, causing it to explode."
	button_icon_state = "pd_overload"
	unlock_cost = 300 KW
	cast_cost = 50 KW
	upgrade_cost = 500 KW
	requires_area = TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/obj/machinery/M = target
	if(!istype(M))
		to_chat(user, span_warning("That is not a machine."))
		return FALSE
	if(M.resistance_flags & NO_MALF_EFFECT)
		to_chat(user, span_warning("That machine cannot be overloaded."))
		return FALSE
	target.audible_message(span_italics(">You hear a loud electrical buzzing sound coming from [target]!"))
	addtimer(CALLBACK(src, PROC_REF(detonate), M), 5 SECONDS)
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/proc/detonate(obj/machinery/target)
	if(!QDELETED(target))
		explosion(get_turf(target), devastation_range = 0, heavy_impact_range = 1, light_impact_range = 1, flash_range = 0)
		if(!QDELETED(target))
			qdel(target)

/datum/action/cooldown/spell/pointed/pulse_demon/remotehijack
	name = "Remote Hijack"
	desc = "Remotely hijacks an APC."
	button_icon_state = "pd_remotehack"
	unlock_cost = 15 KW
	cast_cost = 10 KW
	spell_max_level = 0
	cooldown_time = 3 SECONDS // you have to wait for the regular hijack time anyway

/datum/action/cooldown/spell/pointed/pulse_demon/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	var/obj/machinery/power/apc/A = target
	if(!istype(A))
		to_chat(user, span_warning("That is not an APC."))
		return FALSE
	if(!user.try_hijack_apc(A, TRUE))
		to_chat(user, span_warning("You cannot hijack that APC right now!"))
	return TRUE

/datum/action/cooldown/spell/pointed/pulse_demon/remotedrain
	name = "Remote Drain"
	desc = "Remotely drains a power source."
	button_icon_state = "pd_remotedrain"
	unlock_cost = 5 KW
	cast_cost = 100
	upgrade_cost = 100 KW

/datum/action/cooldown/spell/pointed/pulse_demon/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	if(isapc(target))
		var/drained = user.drain_APC(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		if(drained == PULSEDEMON_SOURCE_DRAIN_INVALID)
			to_chat(user, span_warning("This APC is being hijacked, you cannot drain from it right now."))
		else
			to_chat(user, span_notice("You drain [format_si_suffix(drained)]W from [target]."))
	else if(istype(target, /obj/machinery/power/smes))
		var/drained = user.drain_SMES(target, PULSEDEMON_REMOTE_DRAIN_MULTIPLIER)
		to_chat(user, span_notice("You drain [format_si_suffix(drained)]W from [target]."))
	else
		to_chat(user, span_warning("That is not a valid source."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pulse_demon_toggle
	school = SCHOOL_ENERGY
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	background_icon_state = "bg_pulsedemon"
	var/locked = TRUE
	var/unlock_cost = 0 KW
	var/cast_cost = 0 KW
	var/upgrade_cost = 0 KW
	var/requires_area = FALSE
	var/initstate = FALSE
	var/base_message = "see messages you shouldn't!"

/datum/action/cooldown/spell/pulse_demon_toggle/New(Target, original)
	. = ..()
	do_toggle(initstate, null)
	update_info()

/datum/action/cooldown/spell/pulse_demon_toggle/proc/do_toggle(varstate, mob/user)
	background_icon_state = varstate ? initial(background_icon_state) : "[initial(background_icon_state)]_disabled"
	UpdateButtonIcon()
	if(user)
		to_chat(user, span_notice("You will [varstate ? "now" : "no longer"] [base_message]"))
	return varstate

/datum/action/cooldown/spell/pulse_demon_toggle/proc/update_info()
	if(locked)
		name = "[initial(name)] (Locked) ([format_si_suffix(unlock_cost)]W)"
		desc = "[initial(desc)] It costs [format_si_suffix(unlock_cost)]W to unlock."
	else
		name = "[initial(name)][cast_cost == 0 ? "" : " ([format_si_suffix(cast_cost)]W)"]"
		desc = "[initial(desc)][spell_level == spell_max_level ? "" : " It costs [format_si_suffix(upgrade_cost)]W to upgrade."]"
	UpdateButtonIcon()

/datum/action/cooldown/spell/pulse_demon_toggle/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!ispulsedemon(owner))
		return FALSE
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(locked)
		if(feedback)
			to_chat(user, span_warning("This ability is locked! Right click the button to purchase this ability."))
			to_chat(user, span_notice("It costs [format_si_suffix(unlock_cost)]W to unlock."))
		return FALSE
	if(user.charge < cast_cost)
		if(feedback)
			to_chat(user, span_warning("You do not have enough charge to use this ability!"))
			to_chat(user, span_notice("It costs [format_si_suffix(cast_cost)]W to use."))
		return FALSE
	if(requires_area && !user.controlling_area)
		if(feedback)
			to_chat(user, span_warning("You need to be controlling an area to use this ability!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pulse_demon_toggle/cast(atom/cast_on)
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user) || locked || user.charge < cast_cost || !cast_on)
		return
	if(requires_area && !user.controlling_area)
		return
	if(requires_area && user.controlling_area != get_area(cast_on))
		to_chat(user, span_warning("You can only use this ability in your controlled area!"))
		return
	if(try_cast_action(user, cast_on))
		user.adjust_charge(-cast_cost)
		return ..()
	reset_spell_cooldown()

/datum/action/cooldown/spell/pulse_demon_toggle/proc/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	return FALSE

/datum/action/cooldown/spell/pulse_demon_toggle/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		try_buy()
		return CLICK_ACTION_SUCCESS
	return ..()

/datum/action/cooldown/spell/pulse_demon_toggle/proc/try_buy()
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user))
		return

	if(locked)
		if(user.charge < unlock_cost)
			to_chat(user, span_warning("You cannot afford this ability! It costs [format_si_suffix(unlock_cost)]W to unlock."))
			return
		user.adjust_charge(-unlock_cost)
		locked = FALSE
		to_chat(user, span_notice("You have unlocked [initial(name)]!"))

		if(cast_cost > 0)
			to_chat(user, span_notice("It costs [format_si_suffix(cast_cost)]W to use once."))
		if(spell_max_level > 0 && spell_level < spell_max_level)
			to_chat(user, span_notice("It will cost [format_si_suffix(upgrade_cost)]W to upgrade."))

		update_info()

	else
		if(spell_level >= spell_max_level)
			to_chat(user, span_warning("You have already fully upgraded this ability!"))
		else if(user.charge >= upgrade_cost)
			user.adjust_charge(-upgrade_cost)
			spell_level = min(spell_level + 1, spell_max_level)
			upgrade_cost = round(initial(upgrade_cost) * (1.5 ** spell_level))
			do_upgrade(user)

			if(spell_level == spell_max_level)
				to_chat(user, span_notice("You have fully upgraded [initial(name)]!"))
			else
				to_chat(user, span_notice("The next upgrade will cost [format_si_suffix(upgrade_cost)]W to unlock."))

			update_info()
		else
			to_chat(user, span_warning("You cannot afford to upgrade this ability! It costs [format_si_suffix(upgrade_cost)]W to upgrade."))

/datum/action/cooldown/spell/pulse_demon_toggle/proc/do_upgrade(mob/living/simple_animal/demon/pulse_demon/user)
	cooldown_time = round(initial(cooldown_time) / (1.5 ** spell_level))
	to_chat(user, span_notice("You have upgraded [initial(name)] to level [spell_level + 1], it now takes [cooldown_time / 10] seconds to recharge."))

/datum/action/cooldown/spell/pulse_demon_toggle/do_drain
	name = "Toggle Draining"
	desc = "Toggle whether you drain charge from power sources."
	base_message = "drain charge from power sources."
	button_icon_state = "pd_toggle_steal"
	locked = FALSE
	spell_max_level = 0

/datum/action/cooldown/spell/pulse_demon_toggle/do_drain/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	user.do_drain = do_toggle(!user.do_drain, user)
	return TRUE

/datum/action/cooldown/spell/pulse_demon_toggle/do_drain/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		var/mob/living/simple_animal/demon/pulse_demon/user = clicker
		if(!istype(user))
			return NONE

		var/amount = tgui_input_number(user, "Input a value between 1 and [user.max_drain_rate]. 0 will reset it to the maximum.", "Drain Speed Setting")
		if(amount == null || amount < 0)
			to_chat(user, span_warning("Invalid input. Drain speed has not been modified."))
			return CLICK_ACTION_BLOCKING

		if(amount == 0)
			amount = user.max_drain_rate
		user.power_drain_rate = amount
		to_chat(user, span_notice("Drain speed has been set to [format_si_suffix(user.power_drain_rate)]W per second."))
		return CLICK_ACTION_SUCCESS
	return ..()

/datum/action/cooldown/spell/pulse_demon_toggle/can_exit_cable
	name = "Toggle Self-Sustaining"
	desc = "Toggle whether you can move outside of cables or power sources."
	base_message = "move outside of cables."
	button_icon_state = "pd_toggle_exit"
	unlock_cost = 100 KW
	upgrade_cost = 300 KW
	spell_max_level = 3

/datum/action/cooldown/spell/pulse_demon_toggle/can_exit_cable/try_cast_action(mob/living/simple_animal/demon/pulse_demon/user, atom/target)
	if(user.can_exit_cable && !(user.current_cable || user.current_power))
		to_chat(user, span_warning("Enter a cable or power source first!"))
		return FALSE
	user.can_exit_cable = do_toggle(!user.can_exit_cable, user)
	return TRUE

/datum/action/cooldown/spell/pulse_demon_toggle/can_exit_cable/do_upgrade(mob/living/simple_animal/demon/pulse_demon/user)
	user.outside_cable_speed = max(initial(user.outside_cable_speed) - spell_level, 1)
	to_chat(user, span_notice("You have upgraded [initial(name)] to level [spell_level + 1], you will now move faster outside of cables."))

/datum/action/cooldown/spell/pulse_demon_cycle_camera
	name = "Cycle Camera View"
	desc = "Jump between the cameras in your APC's area. Right click to return to the APC."
	button_icon_state = "pd_camera_view"
	background_icon_state = "bg_pulsedemon"
	var/current_camera = 0

/datum/action/cooldown/spell/pulse_demon_cycle_camera/proc/exit_camera(mob/living/simple_animal/demon/pulse_demon)
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user))
		return NONE
	current_camera = 0

	if(!isapc(user.current_power))
		return NONE
	if(get_area(user.loc) != user.controlling_area)
		return NONE
	user.forceMove(user.current_power)

/datum/action/cooldown/spell/pulse_demon_cycle_camera/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		exit_camera()
		return CLICK_ACTION_SUCCESS
	return ..()

/datum/action/cooldown/spell/pulse_demon_cycle_camera/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	if(!istype(user))
		return
	if(!length(user.controlling_area.cameras))
		return FALSE

	if(isapc(user.loc))
		current_camera = 0
	else if(istype(user.loc, /obj/machinery/camera))
		current_camera = (current_camera + 1) % length(user.controlling_area.cameras)
		if(current_camera == 0)
			user.forceMove(user.current_power)
			return TRUE

	if(length(user.controlling_area.cameras) < current_camera)
		current_camera = 0

	user.forceMove(locateUID(user.controlling_area.cameras[current_camera + 1]))
	return TRUE

/datum/action/cooldown/spell/pulse_demon_menu
	name = "Open Upgrade Menu"
	desc = "Open the upgrades menu. Alt-click for descriptions and costs."
	button_icon_state = "pd_upgrade"
	var/static/list/upgrade_icons = list(
		PD_UPGRADE_HIJACK_SPEED = image(icon = 'icons/obj/engines_and_power/power.dmi', icon_state = "apcemag"),
		PD_UPGRADE_DRAIN_SPEED  = image(icon = 'icons/obj/engines_and_power/power.dmi', icon_state = "ccharger1"),
		PD_UPGRADE_MAX_HEALTH   = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "bluespace_matter_bin"),
		PD_UPGRADE_HEALTH_REGEN = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "femto_mani"),
		PD_UPGRADE_HEALTH_LOSS  = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "triphasic_scan_module"),
		PD_UPGRADE_HEALTH_COST  = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "quadultra_micro_laser"),
		PD_UPGRADE_MAX_CHARGE   = image(icon = 'icons/obj/stock_parts.dmi', icon_state = "quadratic_capacitor")
	)
	var/static/list/upgrade_descs = list(
		PD_UPGRADE_HIJACK_SPEED = "Decrease the amount of time required to hijack an APC.",
		PD_UPGRADE_DRAIN_SPEED  = "Increase the amount of charge drained from a power source per cycle.",
		PD_UPGRADE_MAX_HEALTH   = "Increase the total amount of health you can have at once.",
		PD_UPGRADE_HEALTH_REGEN = "Increase the amount of health regenerated when powered per cycle.",
		PD_UPGRADE_HEALTH_LOSS  = "Decrease the amount of health lost when unpowered per cycle.",
		PD_UPGRADE_HEALTH_COST  = "Decrease the amount of power required to regenerate per cycle.",
		PD_UPGRADE_MAX_CHARGE   = "Increase the total amount of charge you can have at once."
	)

/datum/action/cooldown/spell/pulse_demon_menu/proc/calc_cost(mob/living/simple_animal/demon/pulse_demon/user, upgrade)
	var/cost
	switch(upgrade)
		if(PD_UPGRADE_HIJACK_SPEED)
			if(user.hijack_time <= 1 SECONDS)
				return -1
			cost = (100 / (user.hijack_time / (1 SECONDS))) * 20 KW
		if(PD_UPGRADE_DRAIN_SPEED)
			if(user.max_drain_rate >= 500 KW)
				return -1
			cost = user.max_drain_rate * 15
		if(PD_UPGRADE_MAX_HEALTH)
			if(user.maxHealth >= 200)
				return -1
			cost = user.maxHealth * 5 KW
		if(PD_UPGRADE_HEALTH_REGEN)
			if(user.health_regen_rate >= 100)
				return -1
			cost = user.health_regen_rate * 50 KW
		if(PD_UPGRADE_HEALTH_LOSS)
			if(user.health_loss_rate <= 1)
				return -1
			cost = (100 / user.health_loss_rate) * 20 KW
		if(PD_UPGRADE_HEALTH_COST)
			if(user.power_per_regen <= 1)
				return -1
			cost = (100 / user.power_per_regen) * 50 KW
		if(PD_UPGRADE_MAX_CHARGE)
			cost = user.maxcharge
		else
			return -1
	return round(cost)

/datum/action/cooldown/spell/pulse_demon_menu/Trigger(mob/clicker, trigger_flags, atom/target)
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		get_upgrades()
		return CLICK_ACTION_SUCCESS
	return ..()

/datum/action/cooldown/spell/pulse_demon_menu/proc/get_upgrades(mob/living/simple_animal/demon/pulse_demon/user)
	var/upgrades = list()
	for(var/upgrade in upgrade_icons)
		var/cost = calc_cost(user, upgrade)
		if(cost == -1)
			continue
		upgrades["[upgrade] ([format_si_suffix(cost)]W)"] = upgrade_icons[upgrade]
	return upgrades

/datum/action/cooldown/spell/pulse_demon_menu/proc/get_descriptions()
	if(!istype(owner))
		return NONE

	to_chat(owner, "<b>Pulse Demon upgrades:</b>")
	for(var/upgrade in upgrade_descs)
		var/cost = calc_cost(owner, upgrade)
		to_chat(owner, "<b>[upgrade]</b> ([cost == -1 ? "Fully Upgraded" : "[format_si_suffix(cost)]W"]) - [upgrade_descs[upgrade]]")
	return CLICK_ACTION_SUCCESS

/datum/action/cooldown/spell/pulse_demon_menu/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/demon/pulse_demon/user = owner
	var/upgrades = get_upgrades(user)
	if(!length(upgrades))
		to_chat(user, span_warning("You have already fully upgraded everything available!"))
		return FALSE

	var/raw_choice = show_radial_menu(user, isturf(user.loc) ? user : user.loc, upgrades, radius = 48)
	if(!raw_choice)
		return
	var/choice = splittext(raw_choice, " ")[1]

	var/cost = calc_cost(user, choice)
	if(cost == -1)
		return FALSE
	if(user.charge < cost)
		to_chat(user, span_warning("You do not have enough charge to purchase this upgrade!"))
		return FALSE

	user.adjust_charge(-cost)
	switch(choice)
		if(PD_UPGRADE_HIJACK_SPEED)
			user.hijack_time = max(round(user.hijack_time / 1.5), 1 SECONDS)
			to_chat(user, span_notice("You have upgraded your [choice], it now takes [user.hijack_time / (1 SECONDS)] second\s to hijack APCs."))
		if(PD_UPGRADE_DRAIN_SPEED)
			var/old = user.max_drain_rate
			user.max_drain_rate = min(round(user.max_drain_rate * 1.5), 500 KW)
			if(user.power_drain_rate == old)
				user.power_drain_rate = user.max_drain_rate
			to_chat(user, span_notice("You have upgraded your [choice], you can now drain [format_si_suffix(user.max_drain_rate)]W per cycle."))
		if(PD_UPGRADE_MAX_HEALTH)
			user.maxHealth = min(round(user.maxHealth * 1.5), 200)
			to_chat(user, span_notice("You have upgraded your [choice], your max health is now [user.maxHealth]."))
		if(PD_UPGRADE_HEALTH_REGEN)
			user.health_regen_rate = min(round(user.health_regen_rate * 1.5), 100)
			to_chat(user, span_notice("You have upgraded your [choice], you will now regenerate [user.health_regen_rate] health per cycle when powered."))
		if(PD_UPGRADE_HEALTH_LOSS)
			user.health_loss_rate = max(round(user.health_loss_rate / 1.5), 1)
			to_chat(user, span_notice("You have upgraded your [choice], you will now lose [user.health_loss_rate] health per cycle when unpowered."))
		if(PD_UPGRADE_HEALTH_COST)
			user.power_per_regen = max(round(user.power_per_regen / 1.5), 1)
			to_chat(user, span_notice("You have upgraded your [choice], it now takes [format_si_suffix(user.power_per_regen)]W of power to regenerate health."))
			to_chat(user, span_notice("Additionally, if you enable draining while on a cable, any excess power that would've been used regenerating will be added to your charge."))
		if(PD_UPGRADE_MAX_CHARGE)
			user.maxcharge = round(user.maxcharge * 2)
			to_chat(user, span_notice("You have upgraded your [choice], you can now store [format_si_suffix(user.maxcharge)]W of charge."))
		else
			return FALSE
	return TRUE

#undef KW
#undef PULSEDEMON_REMOTE_DRAIN_MULTIPLIER

#undef PD_UPGRADE_HIJACK_SPEED
#undef PD_UPGRADE_DRAIN_SPEED
#undef PD_UPGRADE_HEALTH_LOSS
#undef PD_UPGRADE_HEALTH_REGEN
#undef PD_UPGRADE_MAX_HEALTH
#undef PD_UPGRADE_HEALTH_COST
#undef PD_UPGRADE_MAX_CHARGE
