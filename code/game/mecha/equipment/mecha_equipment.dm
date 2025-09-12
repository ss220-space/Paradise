//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/obj/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	origin_tech = "materials=2;engineering=2"
	max_integrity = 300
	/// Only used in start_cooldown() and do_after_cooldown(), so be sure to add one of these procs to your successful action().
	var/equip_cooldown = 0
	/// Can we use equip?
	var/equip_ready = TRUE
	/// Is equip active?
	var/active = FALSE
	/// Label used in the ui next to the Activate/Enable/Disable buttons
	var/active_label = "Статус"
	var/energy_drain = 0
	var/obj/mecha/chassis = null
	var/range = MECHA_MELEE //bitflags
	var/salvageable = TRUE
/*
	MODULE_SELECTABLE_FULL		- Regular selectable equipment.
	MODULE_SELECTABLE_TOGGLE	- Equipment toggles On/Off instead of regular selecting.
	MODULE_SELECTABLE_NONE		- Not selectable equipment.
*/
	var/selectable = MODULE_SELECTABLE_FULL
	var/harmful = FALSE //Controls if equipment can be used to attack by a pacifist.
	var/integrated = FALSE // Preventing modules from getting detached.
	var/alert_category = "mecha_module" //change if you want custom alerts

/obj/item/mecha_parts/mecha_equipment/Destroy()//missiles detonating, teleporter creating singularity?
	if(chassis)
		chassis.occupant_message(span_danger("The [src] is destroyed!"))
		SEND_SOUND(chassis.occupant, sound(get_destroy_sound(), volume = 50))
		detach(chassis)
	return ..()

/obj/item/mecha_parts/mecha_equipment/proc/get_destroy_sound()
	return chassis.critdestrsound

/obj/item/mecha_parts/mecha_equipment/proc/critfail()
	return

/obj/item/mecha_parts/mecha_equipment/proc/get_snowflake_data()
	return

/obj/item/mecha_parts/mecha_equipment/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("detach")
			detach(get_turf(src))
			return TRUE
		if("toggle")
			if(selectable != MODULE_SELECTABLE_TOGGLE)
				return FALSE
			toggle_module()
			return TRUE
		if("select")
			if(selectable != MODULE_SELECTABLE_FULL)
				return FALSE
			select_module()
			return TRUE

	return handle_ui_act(action,params,ui,state)

/obj/item/mecha_parts/mecha_equipment/proc/handle_ui_act(action, list/params)
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/is_ranged()//add a distance restricted equipment. Why not?
	return range & MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/proc/is_melee()
	return range & MECHA_MELEE

/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return FALSE
	if(!chassis)
		return FALSE
	if(!equip_ready)
		return FALSE
	if(crit_fail)
		return FALSE
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	return TRUE

/**
 * Proc that checks if the target of the mecha is in front of it
 *
 * Arguments
 * * target - target we want to check
 */
/obj/item/mecha_parts/mecha_equipment/proc/is_faced_target(atom/target)
	if(!chassis || !target)
		return FALSE
	var/dir_to_target = get_dir(chassis, target)
	return dir_to_target == chassis.dir || dir_to_target == get_clockwise_dir(chassis.dir) || dir_to_target == get_anticlockwise_dir(chassis.dir)

/obj/item/mecha_parts/mecha_equipment/proc/action(atom/target)
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/start_cooldown()
	set_ready_state(FALSE)
	chassis.use_power(energy_drain)

	var/cooldown = equip_cooldown
	var/obj/item/mecha_parts/mecha_equipment/weapon/W = src
	if(istype(W))
		cooldown += (W.projectiles_per_shot - 1) * W.projectile_delay

	addtimer(CALLBACK(src, PROC_REF(set_ready_state), TRUE), cooldown)

/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target)
	if(!chassis)
		return
	var/C = chassis.loc
	set_ready_state(FALSE)
	chassis.use_power(energy_drain)
	. = do_after(chassis.occupant, equip_cooldown, target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM, category = DA_CAT_TOOL)
	set_ready_state(TRUE)
	if(!chassis ||	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target) & chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, delay)
	if(!chassis)
		return
	var/C = chassis.loc
	. = do_after(chassis.occupant, delay, target, category = DA_CAT_TOOL)
	if(!chassis ||	chassis.loc != C || src != chassis.selected || !(get_dir(chassis, target) & chassis.dir))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/mecha/M)
	if(istype(M))
		if(length(M.equipment) < M.max_equip)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/can_detach()
	if(integrated)
		occupant_message(span_warning("Unable to detach integrated module!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/mecha/M)
	M.equipment += src
	chassis = M
	if(loc != M)
		forceMove(M)
	if(!M.selected)
		select_module()
	attach_act(M)
	ADD_TRAIT(src, TRAIT_NODROP, MECHA_EQUIPMENT_TRAIT)
	if(M.occupant)
		give_targeted_action()

/obj/item/mecha_parts/mecha_equipment/proc/attach_act(obj/mecha/M)
	return

/obj/item/mecha_parts/mecha_equipment/proc/give_targeted_action()
	var/datum/action/innate/mecha/module_action
	switch(selectable)
		if(MODULE_SELECTABLE_FULL)
			module_action = new /datum/action/innate/mecha/select_module
		if(MODULE_SELECTABLE_TOGGLE)
			module_action = new /datum/action/innate/mecha/toggle_module
		if(MODULE_SELECTABLE_NONE)
			return
	module_action.Grant(chassis.occupant, chassis, src)
	chassis.module_actions[src] = module_action

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto = null)
	if(!can_detach())
		return
	if(chassis.occupant)
		remove_targeted_action()
		if(chassis.selected == src)
			if(selectable == MODULE_SELECTABLE_FULL)
				chassis.occupant.clear_alert(alert_category)
	detach_act()
	moveto = moveto || get_turf(chassis)
	if(Move(moveto))
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		chassis = null
		REMOVE_TRAIT(src, TRAIT_NODROP, MECHA_EQUIPMENT_TRAIT)
		set_ready_state(TRUE)

/obj/item/mecha_parts/mecha_equipment/proc/detach_act()
	return

/obj/item/mecha_parts/mecha_equipment/proc/remove_targeted_action()
	if(!selectable)
		return

	if(chassis.module_actions[src])
		var/datum/action/innate/mecha/module_action = chassis.module_actions[src]
		module_action.Remove(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/proc/handle_occupant_exit()
	return

/obj/item/mecha_parts/mecha_equipment/proc/set_ready_state(state)
	equip_ready = state

/obj/item/mecha_parts/mecha_equipment/proc/set_active(state)
	active = state

/obj/item/mecha_parts/mecha_equipment/proc/occupant_message(message)
	if(chassis)
		chassis.occupant_message("[bicon(src)] [message]")

/obj/item/mecha_parts/mecha_equipment/proc/self_occupant_attack()
	return

/obj/item/mecha_parts/mecha_equipment/proc/select_module()
	select_set_alert()
	chassis.selected?.set_active(FALSE)
	chassis.selected = src
	chassis.selected.set_active(TRUE)
	chassis.occupant_message(span_notice("You switch to [src]."))
	chassis.visible_message("[chassis] raises [src]")

/obj/item/mecha_parts/mecha_equipment/proc/select_set_alert()
	if(selectable == MODULE_SELECTABLE_FULL)
		var/mob/living/carbon/occupant = chassis.occupant
		if(chassis.selected)
			occupant.clear_alert(chassis.selected.alert_category)
		return throw_default_alert(occupant)
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/throw_default_alert(mob/living/carbon/occupant)
	if(!occupant || !occupant.client)
		return FALSE

	if(alert_category != "mecha_module")
		return FALSE

	var/atom/movable/screen/alert/empty_alert/default_alert = occupant.throw_alert(alert_category, /atom/movable/screen/alert/empty_alert, new_master = src)
	default_alert.name = name
	default_alert.desc = "Выбран модуль [declent_ru(NOMINATIVE)]"

	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/toggle_module()
	return
