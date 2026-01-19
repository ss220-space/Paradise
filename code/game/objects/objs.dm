/obj
	abstract_type = /obj
	animate_movement = SLIDE_STEPS
	var/obj_flags = NONE
	/// Used by R&D to determine what research bonuses it grants.
	var/origin_tech = null
	var/crit_fail = FALSE
	/// Can this object cut?
	var/sharp = FALSE
	/// If we have a user using us, this will become `TRUE`. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/in_use = FALSE
	/// What type of damage does this object deal?
	var/damtype = BRUTE
	/// How much damage this object does in melee.
	var/force = 0
	// You can define armor as a list in datum definition (e.g. `armor = list("fire" = 80, "brute" = 10)`),
	// which would be converted to armor datum during initialization.
	// Setting `armor` to a list on an *existing* object would inevitably runtime. Use `getArmor()` instead.
	var/datum/armor/armor
	/// Health of the object. If unspecified, defaults to `max_integrity`.
	var/obj_integrity
	/// Maximum health of the object, and default value of `obj_integrity`.
	var/max_integrity = 500
	/// Health threshold below which the object will break. Defaults to 0 for no special broken behavior.
	var/integrity_failure = 0
	/// Damage under this value will be completely ignored.
	var/damage_deflection = 0
	/// If provided, a custom overlay representing being the object being on fire.
	var/custom_fire_overlay
	/// How much acid is on this object?
	var/acid_level = 0
	/// Is this object currently being zapped by lightning?
	var/being_shocked = FALSE
	/// Should this object speed process? Greatly increases the frequency of process events (5 times more frequent).
	var/speed_process = FALSE
	/// Are we visible on the station blueprints at roundstart?
	var/on_blueprints = FALSE
	/// Does this object require you to hold it to commit suicide with it?
	var/suicidal_hands = FALSE
	/// Typepath of a datum/multitool_menu subtype or null.
	var/multitool_menu_type = null
	var/datum/multitool_menu/multitool_menu

	/// Amount of multiplicative slowdown applied if pulled/pushed. >1 makes you slower, <1 makes you faster.
	var/pull_push_slowdown = 0

	/// List of accesses needed to use this object: The user must possess all accesses in this list in order to use the object.
	/// Example: If req_access = list(ACCESS_ENGINE, ACCESS_CE)- then the user must have both ACCESS_ENGINE and ACCESS_CE in order to use the object.
	var/list/req_access
	var/check_one_access = TRUE

	/// Icon to use as a 32x32 preview in crafting menus and such
	var/icon_preview
	var/icon_state_preview

	/// Is this object emagged?
	var/emagged = FALSE

/obj/Initialize(mapload)
	. = ..()
	if(obj_integrity == null)
		update_integrity(max_integrity)
	if(islist(armor))
		armor = getArmor(arglist(armor))
	else if(!armor)
		armor = getArmor()
	else if(!istype(armor, /datum/armor))
		stack_trace("Invalid type [armor.type] found in .armor during /obj Initialize()")
	if(sharp)
		AddComponent(/datum/component/surgery_initiator)

	if(on_blueprints && isturf(loc))
		var/turf/T = loc
		T.add_blueprints_preround(src)

	add_debris_element()

/obj/Topic(href, href_list, nowindow = FALSE, datum/ui_state/state = GLOB.default_state)
	// Calling Topic without a corresponding window open causes runtime errors
	if(!nowindow && ..())
		return TRUE

	// In the far future no checks are made in an overriding Topic() beyond if(..()) return
	// Instead any such checks are made in CanUseTopic()
	if(ui_status(usr, state, href_list) == UI_INTERACTIVE)
		CouldUseTopic(usr)
		return FALSE

	CouldNotUseTopic(usr)
	return TRUE

/obj/proc/CouldUseTopic(mob/user)
	var/atom/host = ui_host()
	host.add_fingerprint(user)

/obj/proc/CouldNotUseTopic(mob/user)
	// Nada
	return

/obj/Destroy(force)
	if(!ismachinery(src))
		if(!speed_process)
			STOP_PROCESSING(SSobj, src) // TODO: Have a processing bitflag to reduce on unnecessary loops through the processing lists
		else
			STOP_PROCESSING(SSfastprocess, src)
	SStgui.close_uis(src)
	QDEL_NULL(multitool_menu)
	return ..()

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//SHAME = 16
//OBLITERATION = 32

//Output a creative message and then return the damagetype done
/obj/proc/suicide_act(mob/user)
	return FALSE

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request, datum/gas_mixture/environment)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request > 0)
		var/datum/gas_mixture/air = return_obj_air()

		if(isnull(air))
			air = environment

		if(isnull(air))
			return

		var/breath_percentage = BREATH_VOLUME / air.return_volume()
		return air.remove(air.total_moles() * breath_percentage)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = FALSE
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = TRUE
				src.attack_hand(M)
		if(istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if(!(usr in nearby))
				if(usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = TRUE
					src.attack_ai(usr)

		// check for TK users

		if(ishuman(usr))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine == src)
						is_in_use = TRUE
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = FALSE
		for(var/mob/M in nearby)
			if(M.client && M.machine == src)
				is_in_use = TRUE
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = FALSE

/**
 * Hidden uplink interaction proc. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
 *
 * Arguments:
 * * user - who interacts with uplink.
 */
/obj/proc/interact(mob/user)
	return

/mob/proc/unset_machine()
	if(machine)
		machine.on_unset_machine(src)
		machine = null

//called when the user unsets the machine.
/atom/movable/proc/on_unset_machine(mob/user)
	return

/mob/proc/set_machine(obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = TRUE

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

/obj/proc/hide(h)
	return

/obj/proc/hear_talk(mob/speaker, list/message_pieces)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, speaker, message_pieces)
	return

/obj/proc/hear_message(mob/M, text)
	return

/obj/proc/default_welder_repair(mob/user, obj/item/I) //Returns TRUE if the object was successfully repaired. Fully repairs an object (setting BROKEN to FALSE), default repair time = 40
	add_fingerprint(user)
	if(obj_integrity >= max_integrity)
		to_chat(user, span_notice("[src] does not need repairs."))
		return
	if(I.tool_behaviour != TOOL_WELDER)
		return
	if(!I.tool_use_check(user, 0))
		return
	var/time = max(50 * (1 - obj_integrity / max_integrity), 5)
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, time, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		update_integrity(max_integrity)
		update_icon()
	return TRUE

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	add_fingerprint(user)
	if(!anchored && !isfloorturf(loc))
		user.visible_message(span_warning("A floor must be present to secure [src]!"))
		return FALSE
	if(I.tool_behaviour != TOOL_WRENCH)
		return FALSE
	if(!I.tool_use_check(user, 0))
		return FALSE
	if(!(obj_flags & NODECONSTRUCT))
		to_chat(user, span_notice("Now [anchored ? "un" : ""]securing [name]."))
		if(I.use_tool(src, user, time, volume = I.tool_volume))
			to_chat(user, span_notice("You've [anchored ? "un" : ""]secured [name]."))
			set_anchored(!anchored)
		return TRUE
	return FALSE

/obj/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	extinguish()
	acid_level = 0

/obj/singularity_pull(S, current_size)
	..()
	if(!anchored || current_size >= STAGE_FIVE)
		step_towards(src, S)

/obj/proc/container_resist(mob/living)
	return

/obj/proc/on_mob_move(mob/user, dir)
	return

/obj/proc/makeSpeedProcess()
	if(speed_process)
		return
	speed_process = TRUE
	STOP_PROCESSING(SSobj, src)
	START_PROCESSING(SSfastprocess, src)

/obj/proc/makeNormalProcess()
	if(!speed_process)
		return
	speed_process = FALSE
	START_PROCESSING(SSobj, src)
	STOP_PROCESSING(SSfastprocess, src)

/obj/vv_get_dropdown()
	. = ..()
	.["Delete all of type"] = "byond://?_src_=vars;delall=[UID()]"
	if(!speed_process)
		.["Make speed process"] = "byond://?_src_=vars;makespeedy=[UID()]"
	else
		.["Make normal process"] = "byond://?_src_=vars;makenormalspeed=[UID()]"
	.["Modify armor values"] = "byond://?_src_=vars;modifyarmor=[UID()]"

/obj/proc/check_uplink_validity()
	return TRUE

/obj/proc/cult_conceal() //Called by cult conceal spell
	return

/obj/proc/cult_reveal() //Called by cult reveal spell and chaplain's bible
	return

/obj/proc/is_mob_spawnable() //Called by spawners_menu methods to determine if you can use an object through spawn-menu
	//just override it to return TRUE in your object if you want to use it through spawn menu
	return

/// Set whether the item should be sharp or not
/obj/proc/set_sharpness(new_sharp_val)
	if(sharp == new_sharp_val)
		return
	sharp = new_sharp_val
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_SHARPNESS)
	if(!sharp && new_sharp_val)
		AddComponent(/datum/component/surgery_initiator)

/obj/proc/force_eject_occupant(mob/target)
	// This proc handles safely removing occupant mobs from the object if they must be teleported out (due to being SSD/AFK, by admin teleport, etc) or transformed.
	// In the event that the object doesn't have an overriden version of this proc to do it, log a runtime so one can be added.
	CRASH("Proc force_eject_occupant() is not overriden on a machine containing a mob.")

/obj/proc/multitool_menu_interact(mob/user, obj/item/multitool)
	if(!multitool_menu_type)
		return
	if(!multitool_menu)
		multitool_menu = new multitool_menu_type(src)
	multitool_menu.interact(user, multitool)

/proc/get_obj_in_atom_without_warning(atom/A)
	if(!istype(A))
		return null
	if(isobj(A))
		return A

	return locate(/obj) in A

#define MOB_DAMAGE_FROM_OBJECTS_MODIFIER 0.75

/obj/hit_by_thrown_mob(mob/living/throwned_mob, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	damage *= MOB_DAMAGE_FROM_OBJECTS_MODIFIER
	playsound(src, 'sound/weapons/punch1.ogg', 35, TRUE)
	if(mob_hurt) //Density check probably not needed, one should only bump into something if it is dense, and blob tiles are not dense, because of course they are not.
		return
	throwned_mob.visible_message(
		span_danger("[capitalize(throwned_mob.declent_ru(NOMINATIVE))] с размаху вреза[PLUR_ET_UT(throwned_mob)]ся в [declent_ru(ACCUSATIVE)]!"),
		span_userdanger("Вы с размаху врезаетесь в [declent_ru(ACCUSATIVE)]!")
	)
	throwned_mob.take_organ_damage(damage)
	if(!self_hurt)
		take_damage(damage, BRUTE)
	throwned_mob.Knockdown(3 SECONDS)

#undef MOB_DAMAGE_FROM_OBJECTS_MODIFIER

/obj/proc/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(isobj(loc))
		var/obj/object = loc
		return object.return_obj_air()
	else
		return null
