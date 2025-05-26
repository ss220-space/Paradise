// The Marine mortar, the M402 Mortar
// Works like a contemporary crew weapon mortar
/obj/structure/mortar
	name = "\improper M402S mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses an advanced targeting computer. Insert round to fire."
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_m402"
	anchored = TRUE
	density = TRUE
	// So you can't hide it under corpses
	layer = ABOVE_MOB_LAYER
	resistance_flags = ACID_PROOF
	// Initial target coordinates
	var/targ_x = 0
	var/targ_y = 0
	var/targ_z = 0
	// Automatic offsets from target
	var/offset_x = 0
	var/offset_y = 0
	/// Number of turfs to offset from target by 1
	var/offset_per_turfs = 20
	// Dial adjustments from target
	var/dial_x = 0
	var/dial_y = 0
	/// Constant, assuming perfect parabolic trajectory. ONLY THE DELAY BEFORE INCOMING WARNING WHICH ADDS 45 TICKS
	var/travel_time = 4.5 SECONDS
	var/busy = FALSE
	/// Used for deconstruction and aiming sanity
	var/firing = FALSE
	/// If set to 1, can't unanchor and move the mortar, used for map spawns and WO
	var/fixed = FALSE
	/// Can fire across sectors
	var/cross_sector = FALSE
	/// The max range the mortar can fire at
	var/max_range = 75
	/// The min range the mortar can fire at
	var/min_range = 25

	var/obj/machinery/computer/security/mortar/internal_camera

	var/skin

/obj/structure/mortar/Initialize(mapload, skin)
	. = ..()
	// Makes coords appear as 0 in UI
	targ_x = 0
	targ_y = 0
	targ_z = 0
	internal_camera = new(loc)

	src.skin = skin
	switch(skin)
		if("desert")
			icon_state = "d_" + initial(icon_state)
		if("snow")
			icon_state = "s_" + initial(icon_state)
		if("urban")
			icon_state = "u_" + initial(icon_state)
		if("classic")
			icon_state = "c_" + initial(icon_state)

/obj/structure/mortar/Destroy()
	QDEL_NULL(internal_camera)
	return ..()

/obj/structure/mortar/attack_alien(mob/living/carbon/alien/xeno)
	if(fixed)
		to_chat(xeno, span_alien("\The [src]'s supports are bolted and welded into the floor. It looks like it's going to be staying there."))
		return

	if(firing)
		playsound(src, "acid_hit", 25, 1)
		playsound(xeno, "alien_help", 25, 1)
		xeno.apply_damage(10, BURN)
		xeno.visible_message(span_danger("[xeno] tried to knock the steaming hot [src] over, but burned itself and pulled away!"),
		span_alertalien("\The [src] is burning hot! Wait a few seconds."))
		return

	xeno.visible_message(span_danger("[xeno] lashes at \the [src] and knocks it over!"),
	span_danger("You knock \the [src] over!"))
	playsound(loc, 'sound/effects/metalhit.ogg', 25)
	var/obj/item/mortar_kit/MK = new /obj/item/mortar_kit(loc)
	MK.name = name
	qdel(src)
	return

/obj/structure/mortar/attack_hand(mob/user)
	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	if(firing)
		to_chat(user, span_warning("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
		return

	add_fingerprint(user)

	ui_interact(user)

/obj/structure/mortar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mortar", "Mortar Interface")
		ui.open()

/obj/structure/mortar/ui_data(mob/user)
	return list(
		"data_target_x" = targ_x,
		"data_target_y" = targ_y,
		"data_target_z" = targ_z,
		"data_dial_x" = dial_x,
		"data_dial_y" = dial_y
	)

/obj/structure/mortar/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/user = usr
	if(get_dist(user, src) > 1)
		return FALSE

	switch(action)
		if("set_target")
			handle_target(user, text2num(params["target_x"]),  text2num(params["target_y"]), text2num(params["target_z"]))
			return TRUE

		if("set_offset")
			handle_dial(user, text2num(params["dial_x"]), text2num(params["dial_y"]))
			return TRUE

		if("operate_cam")
			internal_camera.ui_interact(user)

/obj/structure/mortar/proc/handle_target(mob/user, temp_targ_x = 0, temp_targ_y = 0, temp_targ_z = 0)

	if(!can_fire_at(user, test_targ_x = temp_targ_x, test_targ_y = temp_targ_y, test_targ_z = temp_targ_z))
		return

	user.visible_message(span_notice("[user] starts adjusting [src]'s firing angle and distance."),
	span_notice("You start adjusting [src]'s firing angle and distance to match the new coordinates."))
	busy = TRUE
	var/soundfile = 'sound/machines/scanning.ogg'
	playsound(loc, soundfile, 25, 1)

	var/success = do_after(user, 3 SECONDS)
	busy = FALSE

	if(!success)
		return

	user.visible_message(span_notice("[user] finishes adjusting [src]'s firing angle and distance."),
	span_notice("You finish adjusting [src]'s firing angle and distance to match the new coordinates."))
	targ_x = temp_targ_x
	targ_y = temp_targ_y
	targ_z = temp_targ_z
	var/offset_x_max = floor(abs((targ_x) - x)/offset_per_turfs) //Offset of mortar shot, grows by 1 every 20 tiles travelled
	var/offset_y_max = floor(abs((targ_y) - y)/offset_per_turfs)
	offset_x = rand(-offset_x_max, offset_x_max)
	offset_y = rand(-offset_y_max, offset_y_max)

	dir = get_cardinal_dir(loc, locate(targ_x, targ_y, targ_z))
	SStgui.update_uis(src)
	add_game_logs("set mortar target to ([targ_x], [targ_y], [targ_z]).", user)
	message_admins("[user] set mortar target to ([targ_x], [targ_y], [targ_z]).[ADMIN_JMP(src)]")

/obj/structure/mortar/proc/handle_dial(mob/user, temp_dial_x = 0, temp_dial_y = 0, manual = FALSE)
	if(manual)
		temp_dial_x = tgui_input_number(user, "Set longitude adjustement from -10 to 10.", "Longitude", 0, 10, -10)
		temp_dial_y = tgui_input_number(user, "Set latitude adjustement from -10 to 10.", "Latitude", 0, 10, -10)

	if(!can_fire_at(user, test_dial_x = temp_dial_x, test_dial_y = temp_dial_y))
		return

	user.visible_message(span_notice("[user] starts dialing [src]'s firing angle and distance."),
	span_notice("You start dialing [src]'s firing angle and distance to match the new coordinates."))
	busy = TRUE

	var/soundfile = 'sound/machines/scanning.ogg'
	if(manual)
		soundfile = 'sound/items/Ratchet.ogg'
	playsound(loc, soundfile, 25, 1)

	var/success = do_after(user, 1.5 SECONDS)
	busy = FALSE
	if(!success)
		return
	user.visible_message(span_notice("[user] finishes dialing [src]'s firing angle and distance."),
	span_notice("You finish dialing [src]'s firing angle and distance to match the new coordinates."))
	dial_x = temp_dial_x
	dial_y = temp_dial_y

	SStgui.update_uis(src)

/obj/structure/mortar/attackby(obj/item/item, mob/user)
	if(!istype(item, /obj/item/mortar_shell))
		return ATTACK_CHAIN_PROCEED
	var/obj/item/mortar_shell/mortar_shell = item

	if(!mortar_shell.locked)
		return ATTACK_CHAIN_PROCEED
	var/turf/target_turf = locate(targ_x + dial_x + offset_x, targ_y + dial_y + offset_y, targ_z)
	var/area/target_area = get_area(target_turf)
	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	if(targ_x == 0 && targ_y == 0 && targ_z == 0) //Mortar wasn't set
		to_chat(user, span_warning("[src] needs to be aimed first."))
		return ATTACK_CHAIN_PROCEED

	if(!target_turf)
		to_chat(user, span_warning("You cannot fire [src] to this target."))
		return ATTACK_CHAIN_PROCEED

	if(!istype(target_area))
		to_chat(user, span_warning("This area is out of bounds!"))
		return ATTACK_CHAIN_PROCEED

	var/turf/above_turf = GET_TURF_ABOVE(target_turf)
	if(above_turf && !isopenspaceturf(above_turf))
		to_chat(user, span_warning("You cannot hit the target. It is probably underground."))
		return ATTACK_CHAIN_PROCEED

	var/turf/deviation_turf = locate(target_turf.x + pick(-1,0,0,1), target_turf.y + pick(-1,0,0,1), target_turf.z) //Small amount of spread so that consecutive mortar shells don't all land on the same tile
	if(deviation_turf)
		target_turf = deviation_turf

	user.visible_message(span_notice("[user] starts loading \a [mortar_shell.name] into [src]."),
	span_notice("You start loading \a [mortar_shell.name] into [src]."))
	playsound(loc, 'sound/weapons/gun_mortar_reload.ogg', 50, 1)
	busy = TRUE
	var/success = do_after(user, 1.5 SECONDS)
	busy = FALSE

	if(!success)
		return ATTACK_CHAIN_PROCEED

	user.visible_message(span_notice("[user] loads \a [mortar_shell.name] into [src]."),
	span_notice("You load \a [mortar_shell.name] into [src]."))
	visible_message("[icon2html(src, viewers(src))] [span_danger("The [name] fires!")]")
	user.drop_transfer_item_to_loc(mortar_shell, src, TRUE, TRUE)
	playsound(loc, 'sound/weapons/gun_mortar_fire.ogg', 50, 1)
	busy = FALSE
	firing = TRUE
	flick(icon_state + "_fire", src)
	mortar_shell.sended = TRUE
	mortar_shell.forceMove(src)
	for(var/mob/mob in range(7))
		shake_camera(mob, 3, 1)

	addtimer(CALLBACK(src, PROC_REF(handle_shell), target_turf, mortar_shell), travel_time)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/structure/mortar/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(fixed)
		to_chat(user, span_warning("[src]'s supports are bolted and welded into the floor. It looks like it's going to be staying there."))
		return

	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	if(firing)
		to_chat(user, span_warning("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
		return

	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message(span_notice("[user] starts undeploying [src]."),
		span_notice("You start undeploying [src]."))

	if(!do_after(user, 4 SECONDS))
		return

	user.visible_message(span_notice("[user] undeploys [src]."),
		span_notice("You undeploy [src]."))
	playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
	var/obj/item/mortar_kit/mortar = new /obj/item/mortar_kit(loc, skin)
	mortar.name = src.name
	qdel(src)

/obj/structure/mortar/ex_act(severity)
	switch(severity)
		if(2 to INFINITY)
			qdel(src)

/obj/effect/mortar_effect
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_ammo_custom_locked"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_MAXIMUM

/obj/structure/mortar/proc/handle_shell(turf/target, obj/item/mortar_shell/shell)
	if(istype(shell, /obj/item/mortar_shell/custom)) // big shell warning for ghosts
		var/obj/effect/effect = new /obj/effect/mortar_effect(target)
		QDEL_IN(effect, 5 SECONDS)
		notify_ghosts(title = "Custom Shell", message = "A custom mortar shell is about to land at [get_area(target)].", source = effect)
	add_game_logs("fired an explosive shell from a mortar to ([target.x], [target.y], [target.z]).", usr)
	message_admins("[usr] set mortar target to ([target.x], [target.y], [target.z]).[ADMIN_JMP(target)] [ADMIN_FLW(usr, usr)].")
	if(!shell.silent)
		handle_messages(target)
	else
		sleep(5.5 SECONDS)
	shell.detonate(target)
	qdel(shell)
	firing = FALSE

/obj/structure/mortar/proc/handle_messages(turf/target)
	playsound(target, 'sound/weapons/gun_mortar_travel.ogg', 50, 1)
	var/relative_dir
	for(var/mob/mob in range(15, target))
		if(get_turf(mob) == target)
			relative_dir = 0
		else
			relative_dir = get_dir(mob, target)
		mob.show_message( \
			span_danger("A SHELL IS COMING DOWN [span_bolddanger((relative_dir ? uppertext(("TO YOUR " + dir2text(relative_dir))) : uppertext("right above you")))]!"), EMOTE_VISIBLE, \
			span_danger("YOU HEAR SOMETHING COMING DOWN [span_bolddanger((relative_dir ? uppertext(("TO YOUR " + dir2text(relative_dir))) : uppertext("right above you")))]!"), EMOTE_AUDIBLE \
		)
	sleep(2.5 SECONDS) // Sleep a bit to give a message
	new /obj/effect/overlay/temp/blinking_laser(target)
	sleep(2 SECONDS) // Wait out the rest of the landing time


/obj/structure/mortar/proc/can_fire_at(mob/user, test_targ_x = targ_x, test_targ_y = targ_y, test_targ_z = targ_z, test_dial_x, test_dial_y)
	var/dialing = test_dial_x || test_dial_y

	if(test_dial_x + test_targ_x > world.maxx || test_dial_x + test_targ_x < 0)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is outside of the area of operations."))
		return FALSE

	if(test_dial_x < -10 || test_dial_x > 10 || test_dial_y < -10 || test_dial_y > 10)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too far away from the original target."))
		return FALSE

	if(test_dial_y + test_targ_y > world.maxy || test_dial_y + test_targ_y < 0)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is outside of the area of operations."))
		return FALSE

	var/turf/turf = locate(test_targ_x + test_dial_x, test_targ_y + test_dial_y, test_targ_z);
	if(!turf)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate. Location not exist."))
		return FALSE

	if(get_dist(src, turf) < min_range)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too close to your mortar."))
		return FALSE

	if(isspaceturf(turf))
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is in space."))
		return FALSE

	var/turf/above_turf = GET_TURF_ABOVE(turf)
	if(above_turf && !isopenspaceturf(above_turf))
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it isn't first floor to impact."))
		return FALSE

	var/turf/top_turf = get_highest_turf(turf)
	var/turf/low_turf = get_lowest_turf(turf)

	if(!cross_sector && (test_targ_z < low_turf.z || test_targ_z > top_turf.z))
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate. It isn't in your sector."))
		return FALSE

	if(get_dist(src, turf) > max_range)
		to_chat(user, span_warning("You cannot [dialing ? "dial to" : "aim at"] this coordinate, it is too far from your mortar."))
		return FALSE

	if(busy)
		to_chat(user, span_warning("Someone else is currently using this mortar."))
		return FALSE

	return TRUE

/obj/structure/mortar/fixed
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Uses manual targeting dials. Insert round to fire. This one is bolted and welded into the ground."
	fixed = TRUE

/obj/structure/mortar/wo
	fixed = TRUE
	cross_sector = TRUE
	offset_per_turfs = 30
	max_range = 999

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper M402S mortar portable kit"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first"
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_m402_carry"
	item_state = "mortar_m402_carry"
	ru_names = list()
	lefthand_file = 'icons/mob/inhands/items_by_map/jungle_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_by_map/jungle_righthand.dmi'
	resistance_flags = ACID_PROOF

	w_class = WEIGHT_CLASS_HUGE //No dumping this in a backpack. Carry it, fatso
	flags = CONDUCT
	var/skin

/obj/item/mortar_kit/Initialize(mapload, skin)
	. = ..()
	select_skin(skin)

/obj/item/mortar_kit/ex_act(severity)
	switch(severity)
		if(2 to INFINITY)
			deconstruct(FALSE)
/obj/item/mortar_kit/select_skin(new_skin)
	. = ..()
	var/new_icon_state
	var/new_item_state
	if(!isnull(icon_state) || new_icon_state || new_item_state)
		switch(new_skin)
			if("snow")
				icon_state = new_icon_state ? new_icon_state : "s_" + initial(icon_state)
				item_state = new_item_state ? new_item_state : "s_" + initial(item_state)
			if("desert")
				icon_state = new_icon_state ? new_icon_state : "d_" + initial(icon_state)
				item_state = new_item_state ? new_item_state : "d_" + initial(item_state)
			if("classic")
				icon_state = new_icon_state ? new_icon_state : "c_" + initial(icon_state)
				item_state = new_item_state ? new_item_state : "c_" + initial(item_state)
			if("urban")
				icon_state = new_icon_state ? new_icon_state : "u_" + initial(icon_state)
				item_state = new_item_state ? new_item_state : "u_" + initial(item_state)
			else
				icon_state = new_icon_state ? new_icon_state : initial(icon_state)
				item_state = new_item_state ? new_item_state : initial(item_state)

		switch(new_skin)
			if("jungle")
				lefthand_file = 'icons/mob/inhands/items_by_map/jungle_lefthand.dmi'
				righthand_file = 'icons/mob/inhands/items_by_map/jungle_righthand.dmi'
			if("snow")
				lefthand_file = 'icons/mob/inhands/items_by_map/snow_lefthand.dmi'
				righthand_file = 'icons/mob/inhands/items_by_map/snow_righthand.dmi'
			if("desert")
				lefthand_file = 'icons/mob/inhands/items_by_map/desert_lefthand.dmi'
				righthand_file = 'icons/mob/inhands/items_by_map/desert_righthand.dmi'
			if("classic")
				lefthand_file = 'icons/mob/inhands/items_by_map/classic_lefthand.dmi'
				righthand_file = 'icons/mob/inhands/items_by_map/classic_righthand.dmi'
			if("urban")
				lefthand_file = 'icons/mob/inhands/items_by_map/urban_lefthand.dmi'
				righthand_file = 'icons/mob/inhands/items_by_map/urban_righthand.dmi'
	if(isliving(loc))
		var/mob/mob = loc
		mob.update_inv_hands()
	return TRUE

/obj/item/mortar_kit/AltShiftClick(mob/user)
	. = ..()
	skin = tgui_input_list(user, "Выберите тип камуфляжа", "Тип камуфляжа", list("snow", "desert", "classic", "urban", "jungle"))
	select_skin(skin)

/obj/item/mortar_kit/attack_self(mob/user)
	..()
	var/turf/deploy_turf = get_turf(user)
	if(!deploy_turf)
		return
	var/turf/above_turf = GET_TURF_ABOVE(deploy_turf)
	if(!isfloorturf(deploy_turf))
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] может быть размещена только на поверхности."))
		return
	if(above_turf && !isopenspaceturf(above_turf))
		to_chat(user, span_warning("You probably shouldn't deploy [src] indoors."))
		return
	user.visible_message(span_notice("[user] starts deploying [src]."),
	span_notice("You start deploying [src]."))
	playsound(deploy_turf, 'sound/items/Deconstruct.ogg', 25, 1)

	if(!do_after(user, 4 SECONDS))
		return

	var/obj/structure/mortar/mortar = new /obj/structure/mortar(deploy_turf, skin)
	user.visible_message(span_notice("[user] deploys [src]."),
	span_notice("You deploy [src]."))
	playsound(deploy_turf, 'sound/weapons/gun_mortar_unpack.ogg', 25, 1)
	mortar.name = src.name
	mortar.setDir(user.dir)
	qdel(src)


//used to show where dropship ordnance will impact.
/obj/effect/overlay/temp/blinking_laser
	name = "blinking laser"
	anchored = TRUE
	light_range = 2
	var/effect_duration = 1 SECONDS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/effects.dmi'
	icon_state = "impact_laser"

/obj/effect/overlay/temp/blinking_laser/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), effect_duration )
