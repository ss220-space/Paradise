/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall-0"
	base_icon_state = "r_wall"
	opacity = TRUE
	density = TRUE
	explosion_block = 2
	explosion_vertical_block = 1
	damage_cap = 600
	max_temperature = 6000
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	can_dismantle_with_welder = FALSE
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS
	var/d_state = RWALL_INTACT
	var/can_be_reinforced = 1

/turf/simulated/wall/r_wall/examine(mob/user)
	. = ..()
	switch(d_state)
		if(RWALL_INTACT)
			. += span_notice("The outer <b>grille</b> is fully intact.")
		if(RWALL_SUPPORT_LINES)
			. += span_notice("The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.")
		if(RWALL_COVER)
			. += span_notice("The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.")
		if(RWALL_CUT_COVER)
			. += span_notice("The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.")
		if(RWALL_BOLTS)
			. += span_notice("The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.")
		if(RWALL_SUPPORT_RODS)
			. += span_notice("The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.")
		if(RWALL_SHEATH)
			. += span_notice("The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.")


/turf/simulated/wall/r_wall/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	add_fingerprint(user)

	if(d_state == RWALL_SUPPORT_LINES)
		if(!istype(I, /obj/item/stack/rods))
			to_chat(user, span_warning("You need one rod to replace the outer grille."))
			return .
		var/obj/item/stack/rods/rods = I
		if(!rods.use(1))
			to_chat(user, span_warning("You need at least one rod to replace the outer grille."))
			return .
		d_state = RWALL_INTACT
		update_icon()
		to_chat(user, span_notice("You replace the outer grille."))
		return .|ATTACK_CHAIN_SUCCESS

	if(d_state != RWALL_INTACT)
		if(!istype(I, /obj/item/stack/sheet/metal))
			to_chat(user, span_warning("You need metal sheets to repair the damage."))
			return .
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < d_state)
			to_chat(user, span_warning("You need at least [d_state] sheets of metal repair the damage."))
			return .
		to_chat(user, span_notice("You begin patching-up the wall with [metal]..."))
		if(!do_after(user, max(2 SECONDS * d_state, 10 SECONDS) * metal.toolspeed, src, category = DA_CAT_TOOL) || d_state == RWALL_INTACT || QDELETED(metal))
			return .
		if(!metal.use(d_state))
			to_chat(user, span_warning("At some point during the repair process you lost some metal or the wall state has changed. Make sure you have [d_state] sheets of metal before trying again."))
			return .
		d_state = RWALL_INTACT
		update_icon()
		queue_smooth_neighbors(src)
		to_chat(user, span_notice("You repair the last of the damage."))
		return .|ATTACK_CHAIN_SUCCESS

	if(istype(I, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/plasteel = I
		if(!can_be_reinforced)
			to_chat(user, span_notice("The wall is already coated!"))
			return .
		to_chat(user, span_notice("You begin adding an additional layer of coating to the wall with [plasteel]..."))
		if(!do_after(user, 4 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || d_state != RWALL_INTACT || QDELETED(plasteel))
			return .
		if(!plasteel.use(2))
			to_chat(user, span_warning("You don't have enough [plasteel.name] for that!"))
			return .
		to_chat(user, span_notice("You add an additional layer of coating to the wall."))
		ChangeTurf(/turf/simulated/wall/r_wall/coated)
		update_icon()
		queue_smooth_neighbors(src)
		can_be_reinforced = FALSE
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/wall/r_wall/welder_act(mob/user, obj/item/I)
	if(reagents?.get_reagent_amount("thermite") && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return TRUE
	if(!(d_state in list(RWALL_COVER, RWALL_SUPPORT_RODS, RWALL_CUT_COVER)))
		return ..()
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(d_state == RWALL_COVER)
		to_chat(user, span_notice("You begin slicing through the metal cover..."))
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_COVER)
			d_state = RWALL_CUT_COVER
			to_chat(user, span_notice("You press firmly on the cover, dislodging it."))
	else if(d_state == RWALL_SUPPORT_RODS)
		to_chat(user, span_notice("You begin slicing through the support rods..."))
		if(I.use_tool(src, user, 100, volume = I.tool_volume) && d_state == RWALL_SUPPORT_RODS)
			d_state = RWALL_SHEATH
	else if(d_state == RWALL_CUT_COVER)
		to_chat(user, span_notice("You begin welding the metal cover back to the frame..."))
		if(I.use_tool(src, user, 60, volume = I.tool_volume) && d_state == RWALL_CUT_COVER)
			to_chat(user, span_notice("The metal cover has been welded securely to the frame."))
			d_state = RWALL_COVER
	update_icon()

/turf/simulated/wall/r_wall/crowbar_act(mob/user, obj/item/I)
	if(!(d_state in list(RWALL_CUT_COVER, RWALL_SHEATH, RWALL_BOLTS)))
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	switch(d_state)
		if(RWALL_CUT_COVER)
			to_chat(user, span_notice("You struggle to pry off the cover..."))
			if(!I.use_tool(src, user, 100, volume = I.tool_volume) || d_state != RWALL_CUT_COVER)
				return
			d_state = RWALL_BOLTS
			to_chat(user, span_notice("You pry off the cover."))
		if(RWALL_SHEATH)
			to_chat(user, span_notice("You struggle to pry off the outer sheath..."))
			if(!I.use_tool(src, user, 100, volume = I.tool_volume))
				return
			if(dismantle_wall())
				to_chat(user, span_notice("You pry off the outer sheath."))

		if(RWALL_BOLTS)
			to_chat(user, span_notice("You start to pry the cover back into place..."))
			playsound(src, I.usesound, 100, 1)
			if(!I.use_tool(src, user, 20, volume = I.tool_volume) || d_state != RWALL_BOLTS)
				return
			d_state = RWALL_CUT_COVER
			to_chat(user, span_notice("The metal cover has been pried back into place."))
	update_icon()

/turf/simulated/wall/r_wall/screwdriver_act(mob/user, obj/item/I)
	if(d_state != RWALL_SUPPORT_LINES && d_state != RWALL_COVER)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_SUPPORT_LINES)
		to_chat(user, span_notice("You begin unsecuring the support lines..."))
	else
		to_chat(user, span_notice("You begin securing the support lines..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_SUPPORT_LINES)
		d_state = RWALL_COVER
		to_chat(user, span_notice("You unsecure the support lines."))
	else
		d_state = RWALL_SUPPORT_LINES
		to_chat(user, span_notice("The support lines have been secured."))
	update_icon()

/turf/simulated/wall/r_wall/wirecutter_act(mob/user, obj/item/I)
	if(d_state != RWALL_INTACT)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	d_state = RWALL_SUPPORT_LINES
	update_icon()
	new /obj/item/stack/rods(src)
	to_chat(user, span_notice("You cut the outer grille."))

/turf/simulated/wall/r_wall/wrench_act(mob/user, obj/item/I)
	if(d_state != RWALL_BOLTS && d_state != RWALL_SUPPORT_RODS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/state_check = d_state
	if(d_state == RWALL_BOLTS)
		to_chat(user, span_notice("You start loosening the anchoring bolts which secure the support rods to their frame..."))
	else
		to_chat(user, span_notice("You start tightening the bolts which secure the support rods to their frame..."))
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state_check != d_state)
		return
	if(d_state == RWALL_BOLTS)
		d_state = RWALL_SUPPORT_RODS
		to_chat(user, span_notice("You remove the bolts anchoring the support rods."))
	else
		d_state = RWALL_BOLTS
		to_chat(user, span_notice("You tighten the bolts anchoring the support rods."))
	update_icon()


/turf/simulated/wall/r_wall/try_decon(obj/item/I, mob/user, params)
	if(d_state != RWALL_COVER && d_state != RWALL_SUPPORT_RODS)	//Plasma cutter only works in the deconstruction steps!
		return FALSE
	if(d_state == RWALL_COVER)
		to_chat(user, span_notice("You begin slicing through the metal cover..."))
		if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || d_state != RWALL_COVER)
			return FALSE
		d_state = RWALL_CUT_COVER
		update_icon()
		to_chat(user, span_notice("You press firmly on the cover, dislodging it."))
		return TRUE
	to_chat(user, span_notice("You begin slicing through the support rods..."))
	if(!I.use_tool(src, user, 7 SECONDS, volume = I.tool_volume) || d_state != RWALL_SUPPORT_RODS)
		return FALSE
	d_state = RWALL_SHEATH
	update_icon()
	return TRUE


/turf/simulated/wall/r_wall/try_destroy(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, span_notice("You begin to drill though the wall..."))

		if(do_after(user, 80 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL)) // Diamond drill has 0.25 toolspeed, so 200
			to_chat(user, span_notice("Your drill tears through the last of the reinforced plating."))
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("You begin to disintegrate the wall..."))
		var/obj/item/pickaxe/drill/jackhammer/jh = I
		if(do_after(user, 100 SECONDS * jh.wall_toolspeed, src, category = DA_CAT_TOOL)) // Jackhammer has 0.1 toolspeed, so 100
			to_chat(user, span_notice("Your sonic jackhammer disintegrates the reinforced plating."))
			dismantle_wall()
		return TRUE

	if(istype(I, /obj/item/twohanded/required/pyro_claws))
		to_chat(user, span_notice("You begin to melt the wall..."))
		if(do_after(user, 15 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL)) // claws has 0.5 toolspeed, so 7.5 seconds
			to_chat(user, span_notice("Your [I] melt the reinforced plating."))
			dismantle_wall()
		return TRUE


/turf/simulated/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()


/turf/simulated/wall/r_wall/update_icon_state()
	if(d_state)
		icon_state = "r_wall-d-[d_state]"
		smooth = NONE
		clear_smooth_overlays()
	else
		smooth = SMOOTH_BITMASK
		queue_smooth(src)


/turf/simulated/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src, 2)

/turf/simulated/wall/r_wall/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	if(!our_rcd.canRwall)
		return RCD_NO_ACT
	. = ..()
