/obj/structure/wryn
	max_integrity = 100
	var/damage = 0
	var/modifier = 0

/obj/structure/wryn/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/wryn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wryn_destruction)



// wax structures procs

/obj/structure/wryn/wax
	name = "wax"
	desc = "Похоже на толстую стенку из воска."
	icon = 'icons/obj/smooth_structures/wryn/wall.dmi'
	icon_state = "wall"
	base_icon_state = "wall"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	canSmoothWith = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	max_integrity = 30
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX
	smooth = SMOOTH_BITMASK


/obj/structure/wryn/wax/Initialize()
	if(usr)
		add_fingerprint(usr)
	air_update_turf(1)
	..()

/obj/structure/wryn/wax/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/wryn/wax/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/wryn/wax/CanAtmosPass(turf/T, vertical)
	return !density

// Structure themselfs

/obj/structure/wryn/wax/wall
	name = "wax wall"
	desc = "Похоже на затвердевшую массу воска."
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP

/obj/structure/wryn/wax/window
	name = "wax window"
	desc = "Воск на этой стенке настолько тонкий, что через него может проходить свет."
	icon = 'icons/obj/smooth_structures/wryn/window.dmi'
	base_icon_state = "window"
	icon_state = "window-0"
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	opacity = FALSE
	max_integrity = 20

/obj/structure/wryn/floor
	icon = 'icons/obj/smooth_structures/wryn/floor.dmi'
	gender = PLURAL
	name = "wax floor"
	desc = "Что-то жёлтое и липкое покрывает пол... Так стоп..."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	var/list/icons = list("wax_floor1", "wax_floor2", "wax_floor3")
	icon_state = "wax_floor1"
	max_integrity = 10
	var/current_dir
	var/static/list/floorImageCache
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP

// wax floor procs

/obj/structure/wryn/floor/update_overlays()
	. = ..()
	for(var/check_dir in GLOB.cardinal)
		var/turf/check = get_step(src, check_dir)
		if(issimulatedturf(check) && !(locate(/obj/structure/wryn) in check))
			. += floorImageCache["[GetOppositeDir(check_dir)]"]


/obj/structure/wryn/floor/proc/fullUpdateWeedOverlays()
	if(!length(floorImageCache))
		floorImageCache = list(4)
		floorImageCache["[NORTH]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_n", layer=2.11, pixel_y = -32)
		floorImageCache["[SOUTH]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_s", layer=2.11, pixel_y = 32)
		floorImageCache["[EAST]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_e", layer=2.11, pixel_x = -32)
		floorImageCache["[WEST]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_w", layer=2.11, pixel_x = 32)

	for(var/obj/structure/wryn/floor/floor in range(1,src))
		floor.update_icon(UPDATE_OVERLAYS)


/obj/structure/wryn/floor/New(pos)
	..()
	var/picked = pick(icons)
	icon_state = picked
	fullUpdateWeedOverlays()

/obj/structure/wryn/floor/Destroy()
	fullUpdateWeedOverlays()
	return ..()


/obj/structure/wryn/wax/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(checkpass(mover, PASSGLASS))
		return !opacity


/obj/structure/wryn/floor/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

#define WAX_DOOR_CLOSED 0
#define WAX_DOOR_OPENED 1

// wax door procs

/obj/machinery/door/airlock/wax/wax
	name = "wax door"
	desc = "Объёмная масса воска, напоминающая дверь."
	icon = 'icons/obj/smooth_structures/wryn/wax_door.dmi'
	icon_state = "wax_door_closed"
	max_integrity = 50
	assemblytype = null
	doorOpen = 'sound/creatures/alien/xeno_door_open.ogg'
	doorClose = 'sound/creatures/alien/xeno_door_close.ogg'
	integrity_failure = null
	damage_deflection = null
	explosion_block = 0
	assemblytype = null
	siemens_strength = 0
	interaction_flags_click = null

	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = AICONTROLDISABLED_OFF
	var/hackProof = FALSE // if TRUE, this door can't be hacked by the AI
	var/electrified_until = 0	// World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 //World time when main power is restored.
	var/backup_power_lost_until = -1 //World time when backup power is restored.
	var/electrified_timer
	var/main_power_timer
	var/backup_power_timer
	var/spawnPowerRestoreRunning = 0
	var/lights = TRUE // bolt lights show by default
	var/datum/wires/airlock/wires
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/obj/machinery/door/airlock/wax/closeOther
	var/closeOtherId
	var/lockdownbyai = FALSE
	var/justzap = FALSE
	var/obj/item/airlock_electronics/airlock_electronics
	var/obj/item/access_control/access_electronics
	var/has_access_electronics = TRUE
	var/shockCooldown = FALSE //Prevents multiple shocks from happening
	var/obj/item/note //Any papers pinned to the airlock
	var/previous_airlock = /obj/structure/door_assembly //what airlock assembly mineral plating was applied to
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	var/paintable = TRUE // If the airlock type can be painted with an airlock painter
	var/id //ID for tint controlle

	var/mutable_appearance/old_buttons_underlay
	var/mutable_appearance/old_lights_underlay
	var/mutable_appearance/old_damag_underlay
	var/mutable_appearance/old_sparks_underlay

	var/doorOpen = 'sound/machines/airlock_open.ogg'
	var/doorClose = 'sound/machines/airlock_close.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/is_special = FALSE

/obj/machinery/door/airlock/wax/wax/welded
	return

/obj/machinery/door/airlock/wax/wax/New()
	return


/*
 * reimp, imitate an access denied event.
 */
/obj/machinery/door/airlock/wax/wax/flicker()
	. = ..()

/obj/machinery/door/airlock/wax/wax/Initialize(mapload)
	AddComponent(/datum/component/wryn_destruction)

// Remove shielding to prevent metal/plasteel duplication
/obj/machinery/door/airlock/wax/wax/remove_shielding()
	return

/obj/machinery/door/airlock/wax/wax/update_other_id()
	return

/obj/machinery/door/airlock/wax/wax/Destroy()
	set_density(FALSE)
	update_freelook_sight()
	return ..()

/obj/machinery/door/airlock/wax/wax/handle_atom_del(atom/A)
	return

/obj/machinery/door/airlock/wax/wax/MouseDrop_T(atom/dropping, mob/user, params)
	..()

/obj/machinery/door/airlock/wax/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	return



/obj/machinery/door/airlock/wax/isElectrified()
	return

/obj/machinery/door/airlock/wax/canAIControl()
	return

/obj/machinery/door/airlock/wax/canAIHack()
	return

/obj/machinery/door/airlock/wax/arePowerSystemsOn()
	return

/obj/machinery/door/airlock/wax/requiresID()
	return

/obj/machinery/door/airlock/wax/isAllPowerLoss()
	return FALSE

/obj/machinery/door/airlock/wax/loseMainPower()
	return

/obj/machinery/door/airlock/wax/loseBackupPower()
	return

/obj/machinery/door/airlock/wax/regainMainPower()
	return

/obj/machinery/door/airlock/wax/regainBackupPower()
	backup_power_timer = null

	if(!wires.is_cut(WIRE_BACKUP_POWER1))
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0
		update_icon()

/obj/machinery/door/airlock/wax/electrify(duration, mob/user = usr, feedback = FALSE)
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/wax/shock(mob/living/user, prb)
	return

//Checks if the user can get shocked and shocks him if it can. Returns TRUE if it happened
/obj/machinery/door/airlock/wax/shock_user(mob/user, prob)
	return (!issilicon(user) && isElectrified() && shock(user, prob))


/obj/machinery/door/airlock/wax/update_icon(state = NONE, override = FALSE)
	if(operating && !override)
		return

	icon_state = density ? "closed" : "open"
	switch(state)
		if(NONE)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
		if(AIRLOCK_OPENING, AIRLOCK_CLOSING)
			icon_state = "nonexistenticonstate" //MADNESS

	. = ..(UPDATE_ICON_STATE) // Sent after the icon_state is changed

	set_airlock_overlays(state)
	SSdemo.mark_dirty(src)

/obj/machinery/door/airlock/wax/update_icon_state()
	return


/obj/machinery/door/airlock/wax/set_airlock_overlays(state)
	return

/obj/machinery/door/airlock/wax/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(arePowerSystemsOn())
				update_icon(AIRLOCK_DENY)
				playsound(src, doorDeni, 50, FALSE, 3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)


/// Called when a player uses an airlock painter on this airlock
/obj/machinery/door/airlock/wax/change_paintjob(obj/item/airlock_painter/painter, mob/user)
	return


/obj/machinery/door/airlock/wax/examine(mob/user)
	return


/obj/machinery/door/airlock/wax/attack_ghost(mob/user)
	return

/obj/machinery/door/airlock/wax/attack_ai(mob/user)
	return

/obj/machinery/door/airlock/wax/ui_interact(mob/user, datum/tgui/ui = null)
	return


/obj/machinery/door/airlock/wax/ui_data(mob/user)
	return

/obj/machinery/door/airlock/wax/ui_status(mob/user, datum/ui_state/state)
	return

/obj/machinery/door/airlock/wax/hack(mob/user)
	return

/obj/machinery/door/check_unres() //unrestricted sides. This overlay indicates which directions the player can access even without an ID
	return


/obj/machinery/door/airlock/wax/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(checkpass(mover, PASSGLASS))
		return !opacity

/obj/machinery/door/airlock/wax/attack_animal(mob/user)
	..()

/obj/machinery/door/airlock/wax/attack_hand(mob/living/carbon/human/user)
	..()
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!iswryn(user))
		to_chat(user, span_notice("Вы даже не знаете, что делать с этой массой воска."))

	try_to_activate_door(user)


//Checks if the user can headbutt the airlock and does it if it can. Returns TRUE if it happened
/obj/machinery/door/airlock/wax/headbutt_airlock(mob/user)
	return

//For the tools being used on the door. Since you don't want to call the attack_hand method if you're using hands. That would be silly
//Also it's a bit inconsistent that when you access the panel you headbutt it. But not while crowbarring
//Try to interact with the panel. If the user can't it'll try activating the door
/obj/machinery/door/airlock/wax/interact_with_panel(mob/user)
	return

/obj/machinery/door/airlock/wax/ai_control_check(mob/user)
	return FALSE

/obj/machinery/door/airlock/wax/ui_act(action, params)
	return

/obj/machinery/door/airlock/wax/open_close(mob/user)
	if(welded)
		to_chat(user, span_warning("The airlock has been welded shut!"))
		return FALSE
	else if(locked)
		to_chat(user, span_warning("The door bolts are down!"))
		return FALSE
	else if(density)
		return open()
	else
		return close()

/obj/machinery/door/airlock/wax/toggle_light(mob/user)
	return

/obj/machinery/door/airlock/wax/toggle_bolt(mob/user)
	return

/obj/machinery/door/airlock/wax/toggle_emergency_status(mob/user)
	return


/obj/machinery/door/airlock/wax/attackby(obj/item/I, mob/user, params)
	return

/obj/machinery/door/airlock/wax/screwdriver_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/wax/crowbar_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/wax/wirecutter_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/wax/multitool_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/wax/wrench_act(mob/user, obj/item/I)
	return

/obj/machinery/door/airlock/wax/welder_act(mob/user, obj/item/I) //This is god awful but I don't care
	return

/obj/machinery/door/airlock/wax/weld_checks(obj/item/I, mob/user)
	return

/obj/machinery/door/airlock/wax/headbutt_shock_check(mob/user)
	return

/obj/machinery/door/airlock/wax/try_to_crowbar(mob/living/user, obj/item/I)
	return


/obj/machinery/door/airlock/wax/open(forced = 0)
	set waitfor = FALSE

	if(istype(closeOther, /obj/machinery/door/airlock/wax) && !closeOther.density)
		closeOther.close()

	if(autoclose)
		autoclose_in(normalspeed ? auto_close_time : auto_close_time_dangerous)

	if(!density)
		return TRUE

	SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, forced)
	operating = DOOR_OPENING
	update_icon(AIRLOCK_OPENING, TRUE)
	sleep(1)
	set_opacity(FALSE)
	update_freelook_sight()
	sleep(4)
	set_density(FALSE)
	air_update_turf(TRUE)
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, TRUE)
	operating = NONE
	return TRUE


/obj/machinery/door/airlock/wax/close(forced = 0, override = FALSE)
	set waitfor = FALSE

	playsound(loc, doorClose, 30, TRUE)
	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)//Smashin windows

	operating = DOOR_CLOSING
	update_icon(AIRLOCK_CLOSING, TRUE)
	layer = CLOSED_DOOR_LAYER
	if(!override)
		sleep(1)
	set_density(TRUE)
	air_update_turf(TRUE)
	if(!override)
		sleep(4)
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(TRUE)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, TRUE)
	operating = NONE
	if(safe)
		CheckForMobs()
	return TRUE


/obj/machinery/door/airlock/wax/lock(forced = FALSE)
	return


/obj/machinery/door/airlock/wax/unlock(forced = FALSE)
	return


/obj/machinery/door/airlock/wax/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return

/obj/machinery/door/airlock/wax/emag_act(mob/user)
	return FALSE


/obj/machinery/door/airlock/wax/cmag_act(mob/user)
	return FALSE


/obj/machinery/door/airlock/wax/emp_act(severity)
	return


/obj/machinery/door/airlock/wax/attack_alien(mob/living/carbon/alien/humanoid/user)
	return


/obj/machinery/door/airlock/wax/power_change(forced = FALSE) //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	return

/obj/machinery/door/airlock/wax/prison_open()
	return

/obj/machinery/door/airlock/wax/hostile_lockdown(mob/origin)
	return

/obj/machinery/door/airlock/wax/disable_lockdown()
	return

/obj/machinery/door/airlock/wax/obj_break(damage_flag)
	return

/obj/machinery/door/airlock/wax/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return . = ..()

/obj/machinery/door/airlock/wax/deconstruct(disassembled = TRUE, mob/user)
	return

/obj/machinery/door/airlock/wax/build_access_electronics()
	access_electronics = new(src)
	access_electronics.selected_accesses = length(req_access) ? req_access : list()
	access_electronics.one_access = check_one_access

/obj/machinery/door/airlock/wax/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	if(istype(note, /obj/item/paper))
		var/obj/item/paper/pinned_paper = note
		if(pinned_paper.info)
			return "note_words"
		else
			return "note"
	if(istype(note, /obj/item/photo))
		return "photo"

//Removes the current note on the door if any. Returns if a note is removed
/obj/machinery/door/airlock/wax/remove_airlock_note(mob/user, wirecutters_used = TRUE)
	if(!note)
		return FALSE

	if(!wirecutters_used)
		if (ishuman(user) && (user.a_intent == INTENT_GRAB)) //grab that note
			user.visible_message(span_notice("[user] removes [note] from [src]."), span_notice("You remove [note] from [src]."))
			playsound(src, 'sound/items/poster_ripped.ogg', 50, 1)
		else
			return FALSE
	else
		user.visible_message(span_notice("[user] cuts down [note] from [src]."), span_notice("You remove [note] from [src]."))
		playsound(src, 'sound/items/wirecutter.ogg', 50, 1)
	note.add_fingerprint(user)
	add_misc_logs(user, "removed [note] from", src)
	note.forceMove_turf()
	user.put_in_hands(note, ignore_anim = FALSE)
	note = null
	update_icon()
	return TRUE

/obj/machinery/door/airlock/wax/narsie_act(weak = FALSE)
	var/turf/T = get_turf(src)
	var/runed = prob(20)
	var/obj/machinery/door/airlock/wax/cult/A
	if(weak)
		A = new/obj/machinery/door/airlock/wax/cult/weak(T)
	else
		if(glass)
			if(runed)
				A = new/obj/machinery/door/airlock/wax/cult/glass(T)
			else
				A = new/obj/machinery/door/airlock/wax/cult/unruned/glass(T)
		else
			if(runed)
				A = new/obj/machinery/door/airlock/wax/cult(T)
			else
				A = new/obj/machinery/door/airlock/wax/cult/unruned(T)
	A.name = name
	A.stealth_icon = icon
	A.stealth_overlays = overlays_file
	A.stealth_opacity = opacity
	A.stealth_glass = glass
	A.stealth_airlock_material = airlock_material
	qdel(src)

/obj/machinery/door/airlock/wax/ratvar_act(weak = FALSE)
	var/obj/machinery/door/airlock/wax/clockwork/A
	if(weak)
		A = new/obj/machinery/door/airlock/wax/clockwork/weak(get_turf(src))
	else
		if(glass)
			A = new/obj/machinery/door/airlock/wax/clockwork/glass(get_turf(src))
		else
			A = new/obj/machinery/door/airlock/wax/clockwork(get_turf(src))
	A.name = name
	qdel(src)

/obj/machinery/door/airlock/wax/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	. = ..()
	if(our_rcd.checkResource(20, user))
		to_chat(user, "Deconstructing airlock...")
		playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 5 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
			if(!our_rcd.useResource(20, user))
				return RCD_ACT_FAILED
			playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
			add_attack_logs(user, src, "Deconstructed airlock with RCD")
			qdel(src)
			return RCD_ACT_SUCCESSFULL
		to_chat(user, span_warning("ERROR! Deconstruction interrupted!"))
		return RCD_ACT_FAILED
	to_chat(user, span_warning("ERROR! Not enough matter in unit to deconstruct this airlock!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/obj/machinery/door/airlock/wax/ai_control_callback()
	if(aiControlDisabled == AICONTROLDISABLED_ON)
		aiControlDisabled = AICONTROLDISABLED_OFF
	else if(aiControlDisabled == AICONTROLDISABLED_BYPASS)
		aiControlDisabled = AICONTROLDISABLED_PERMA
/obj/structure/wryn/wax/door


	canSmoothWith = null
	smooth = NONE
	pass_flags_self = PASSDOOR
	var/state = WAX_DOOR_CLOSED
	var/operating = FALSE
	var/autoclose = TRUE
	var/autoclose_delay = 10 SECONDS



/obj/structure/wryn/wax/door/Initialize()
	. = ..()
	update_freelook_sight()


/obj/structure/wryn/wax/door/Destroy()
	set_density(FALSE)
	update_freelook_sight()
	return ..()


/obj/structure/wryn/wax/door/update_icon_state()
	switch(state)
		if(WAX_DOOR_CLOSED)
			icon_state = "wax_door_closed"
		if(WAX_DOOR_OPENED)
			icon_state = "wax_door_opened"

/obj/structure/wryn/wax/door/attack_animal(mob/living/simple_animal/animal)
	if(animal.a_intent == INTENT_HARM)
		return ..()

	return try_switch_state(animal)

/obj/structure/wryn/wax/door/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!iswryn(user))
		to_chat(user, span_notice("Вы даже не знаете, что делать с этой массой воска."))

	return try_switch_state(user)

/obj/structure/wryn/wax/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		switch_state()

/obj/structure/wryn/wax/door/attack_tk(mob/user)
	return

/obj/structure/wryn/wax/door/try_switch_state(atom/movable/user)
	if(operating)
		return FALSE

	add_fingerprint(user)
	if(!isliving(user))
		return FALSE
	// var/mob/living/mob = user
	if(!istype(user, /mob/living/carbon/human/wryn))
		return FALSE

	var/mob/living/carbon/human/wryn/wryn = user
	if(wryn.incapacitated())
		return FALSE

	switch_state()
	return TRUE

/obj/structure/wryn/wax/door/switch_state()
	switch(state)
		if(WAX_DOOR_CLOSED)
			open()
		if(WAX_DOOR_OPENED)
			close()

/obj/structure/wryn/wax/door/open()

	if(operating || !density)
		return

	if(autoclose)
		autoclose_in(autoclose_delay)

	flick("wax_door_opening", src)
	playsound(loc, 'sound/creatures/alien/xeno_door_open.ogg', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_opacity(FALSE)
	update_freelook_sight()

	sleep(0.4 SECONDS)
	set_density(FALSE)
	air_update_turf(TRUE)

	sleep(0.1 SECONDS)
	operating = FALSE
	state = WAX_DOOR_OPENED
	update_icon()


/obj/structure/wryn/wax/door/close()

	if(operating || density)
		return

	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/moving_atom in source_turf)
		if(moving_atom.density && moving_atom != src)
			if(autoclose)
				autoclose_in(autoclose_delay * 0.5)
			return

	flick("wax_door_closing", src)
	playsound(loc, '', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_density(TRUE)
	air_update_turf(TRUE)

	sleep(0.4 SECONDS)
	set_opacity(TRUE)
	update_freelook_sight()

	sleep(0.1 SECONDS)
	operating = FALSE
	state = WAX_DOOR_CLOSED
	update_icon()
	check_mobs()


/obj/structure/wryn/wax/door/check_mobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(0.1 SECONDS)
		open()


/obj/structure/wryn/wax/door/autoclose()
	if(!QDELETED(src) && !density && !operating && autoclose)
		close()


/obj/structure/wryn/wax/door/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)


/obj/structure/wryn/wax/door/update_freelook_sight()
	if(GLOB.cameranet)
		GLOB.cameranet.updateVisibility(src, opacity_check = FALSE)


#undef WAX_DOOR_CLOSED
#undef WAX_DOOR_OPENED
