/* Windoor (window door) assembly -Nodrak //I hope you step on a plug
 * Step 1: Create a windoor out of rglass
 * Step 2: Add plasteel to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Crowbar the door to complete
 */


/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'
	name = "windoor assembly"
	icon_state = "l_windoor_assembly01"
	desc = "A small glass and wire assembly for windoors."
	anchored = FALSE
	density = FALSE
	dir = NORTH
	max_integrity = 300
	pass_flags_self = PASSGLASS
	obj_flags = BLOCKS_CONSTRUCTION_DIR
	set_dir_on_move = FALSE
	var/ini_dir
	var/obj/item/access_control/electronics
	var/created_name

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = FALSE		//Whether or not this creates a secure windoor
	var/state = "01"	//How far the door assembly has progressed

/obj/structure/windoor_assembly/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to rotate it clockwise.</span>"

/obj/structure/windoor_assembly/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		dir = set_dir
	ini_dir = dir
	air_update_turf(1)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/windoor_assembly/Destroy()
	set_density(FALSE)
	QDEL_NULL(electronics)
	air_update_turf(1)
	return ..()

/obj/structure/windoor_assembly/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/windoor_assembly/update_icon_state()
	var/temp_state = state
	if(temp_state == "03")
		temp_state = "02"
	icon_state = "[facing]_[secure ? "secure_" : ""]windoor_assembly[temp_state]"


/obj/structure/windoor_assembly/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir == dir)
		return .

	if(isobj(mover))
		var/obj/object = mover
		if(object.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			var/obj/structure/window/window = object
			var/fulltile = istype(window) ? window.fulltile : FALSE
			if(!valid_build_direction(loc, object.dir, is_fulltile = fulltile))
				return FALSE


/obj/structure/windoor_assembly/CanAtmosPass(turf/T, vertical)
	if(get_dir(loc, T) == dir)
		return !density
	return TRUE


/obj/structure/windoor_assembly/proc/on_exit(datum/source, atom/movable/leaving, atom/newLoc)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if(leaving.pass_flags == PASSEVERYTHING || (pass_flags_self & leaving.pass_flags) || ((pass_flags_self & LETPASSTHROW) && leaving.throwing))
		return

	if(density && dir == get_dir(leaving, newLoc))
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT


/obj/structure/windoor_assembly/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		return
	. = ..()


/obj/structure/windoor_assembly/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	switch(state)
		if("01")
			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			if(istype(I, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/plasteel = I
				add_fingerprint(user)
				if(secure)
					to_chat(user, span_warning("The [name] is already reinforced."))
					return ATTACK_CHAIN_PROCEED
				if(plasteel.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets of [plasteel.name] to do this."))
					return ATTACK_CHAIN_PROCEED
				var/cached_sound = plasteel.usesound
				playsound(loc, cached_sound, 100, TRUE)
				to_chat(user, span_notice("You start to reinforce [src] with [plasteel]..."))
				if(!do_after(user, 4 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || state != "01" || secure || QDELETED(plasteel) || !plasteel.use(2))
					return ATTACK_CHAIN_PROCEED
				playsound(loc, cached_sound, 100, TRUE)
				to_chat(user, span_notice("You have reinforced [src]."))
				secure = TRUE
				name = "secure [(anchored) ? "anchored" : ""] windoor assembly"
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_PROCEED_SUCCESS

			//Adding cable to the assembly. Step 5 complete.
			if(iscoil(I))
				var/obj/item/stack/cable_coil/coil = I
				add_fingerprint(user)
				if(!anchored)
					to_chat(user, span_warning("You should anchor [src] first."))
					return ATTACK_CHAIN_PROCEED
				if(coil.get_amount() < 1)
					to_chat(user, span_warning("You need at least one length of cable to do this."))
					return ATTACK_CHAIN_PROCEED
				var/cached_sound = coil.usesound
				playsound(loc, cached_sound, 100, TRUE)
				to_chat(user, span_notice("You start to wire [src]..."))
				if(!do_after(user, 4 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || state != "01" || !anchored || QDELETED(coil) || !coil.use(1))
					return ATTACK_CHAIN_PROCEED
				playsound(loc, cached_sound, 100, TRUE)
				to_chat(user, span_notice("You have wired [src]."))
				state = "02"
				name = "[(secure) ? "secure" : ""] wired windoor assembly"
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_PROCEED

		if("02")
			if(is_pen(I))
				add_fingerprint(user)
				var/new_name = rename_interactive(user, I)
				if(!isnull(new_name))
					created_name = new_name
				return ATTACK_CHAIN_PROCEED_SUCCESS

			//Adding airlock electronics for access. Step 6 complete.
			if(istype(I, /obj/item/access_control))
				add_fingerprint(user)
				var/obj/item/access_control/control = I
				if(electronics)
					to_chat(user, span_warning("The windoor assembly already has [electronics] installed."))
					return ATTACK_CHAIN_PROCEED
				if(control.emagged)
					to_chat(user, span_warning("The [control.name] is broken."))
					return ATTACK_CHAIN_PROCEED
				control.play_tool_sound(src)
				user.visible_message(
					span_notice("[user] installs the access control electronics into the windoor assembly."),
					span_notice("You start to install the access control electronics into the windoor assembly..."),
				)
				if(!do_after(user, 4 SECONDS * control.toolspeed, src, category = DA_CAT_TOOL) || state != "02" || electronics || control.emagged)
					return ATTACK_CHAIN_PROCEED
				if(!user.drop_transfer_item_to_loc(control, src))
					return ..()
				to_chat(user, span_notice("You install the access control electronics."))
				electronics = control
				state = "03"
				name = "[(secure) ? "secure" : ""] near finished windoor assembly"
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/windoor_assembly/crowbar_act(mob/user, obj/item/I)	//Crowbar to complete the assembly, Step 7 complete.
	if(state != "03")
		return
	. = TRUE
	if(!electronics)
		to_chat(user, "<span class='warning'>[src] is missing electronics!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	user << browse(null, "window=windoor_access")
	user.visible_message("<span class='notice'>[user] pries [src] into the frame...</span>", "<span class='notice'>You start prying [src] into the frame...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return
	if(loc && electronics)
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				return
		to_chat(user, "<span class='notice'>You finish the [(src.secure) ? "secure" : ""] windoor.</span>")
		var/obj/machinery/door/window/windoor
		if(secure)
			windoor = new /obj/machinery/door/window/brigdoor(loc, dir)
			if(facing == "l")
				windoor.base_state = "leftsecure"
			else
				windoor.base_state = "rightsecure"
		else
			windoor = new /obj/machinery/door/window(loc, dir)
			if(facing == "l")
				windoor.base_state = "left"
			else
				windoor.base_state = "right"
		windoor.update_icon(UPDATE_ICON_STATE)
		windoor.unres_sides = electronics.unres_access_from
		windoor.req_access = electronics.selected_accesses
		windoor.check_one_access = electronics.one_access
		windoor.electronics = electronics
		electronics.forceMove(windoor)
		electronics = null

		if(created_name)
			windoor.name = created_name
		qdel(src)
		windoor.close()

/obj/structure/windoor_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != "03" || !electronics)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", "<span class='notice'>You begin removing the circuit board from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != "03" || !electronics)
		return
	to_chat(user, "<span class='notice'>You remove [electronics].</span>")
	name = "[(src.secure) ? "secure" : ""] wired windoor assembly"
	state = "02"
	electronics.forceMove(loc)
	electronics = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != "02")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] begin cutting the wires from [src]...</span>", "<span class='notice'>You begin cutting the wires from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != "02")
		return
	to_chat(user, "<span class='notice'>You cut [src] wires.</span>")
	new/obj/item/stack/cable_coil(get_turf(user), 1)
	state = "01"
	name = "[(src.secure) ? "secure" : ""] anchored windoor assembly"
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/wrench_act(mob/user, obj/item/I)
	if(state != "01")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!anchored)	//Wrenching an unsecure assembly anchors it in place. Step 4 complete
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		user.visible_message("<span class='notice'>[user] begin tightening the bolts on [src]...</span>", "<span class='notice'>You begin tightening the bolts on [src]...</span>")

		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || anchored || state != "01")
			return
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		to_chat(user, "<span class='notice'>You tighten bolts on [src].</span>")
		set_anchored(TRUE)
		name = "[(src.secure) ? "secure" : ""]  anchored windoor assembly"
	else	//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
		user.visible_message("<span class='notice'>[user] begin loosening the bolts on [src]...</span>", "<span class='notice'>You begin loosening the bolts on [src]...</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !anchored || state != "01")
			return
		to_chat(user, "<span class='notice'>You loosen bolts on [src].</span>")
		set_anchored(FALSE)
		name = "[(src.secure) ? "secure" : ""] windoor assembly"
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/welder_act(mob/user, obj/item/I)
	if(state != "01")
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume) && state == "01")
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/item/stack/sheet/rglass/RG = new (get_turf(src), 5)
		RG.add_fingerprint(user)
		if(secure)
			var/obj/item/stack/rods/R = new (get_turf(src), 4)
			R.add_fingerprint(user)
		qdel(src)


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
		return
	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE
	var/target_dir = turn(dir, 270)

	if(!valid_build_direction(loc, target_dir))
		to_chat(usr, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE

	setDir(target_dir)

	ini_dir = dir
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/structure/windoor_assembly/AltClick(mob/user)
	if(!Adjacent(user))
		return
	revrotate()

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(facing == "l")
		to_chat(usr, "The windoor will now slide to the right.")
		facing = "r"
	else
		facing = "l"
		to_chat(usr, "The windoor will now slide to the left.")

	update_icon(UPDATE_ICON_STATE)

