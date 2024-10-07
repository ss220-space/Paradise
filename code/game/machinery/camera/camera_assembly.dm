#define ASSEMBLY_UNBUILT		0 // Nothing done to it
#define ASSEMBLY_WRENCHED		1 // Wrenched in place
#define ASSEMBLY_WELDED		2 // Welded in place
#define ASSEMBLY_WIRED		3 // Wires attached (Upgradable now)
#define ASSEMBLY_BUILT		4 // Fully built (incl panel closed)
#define HEY_IM_WORKING_HERE	666 //So nobody can mess with the camera while we're inputting settings

/obj/item/camera_assembly
	name = "camera assembly"
	desc = "A pre-fabricated security camera kit, ready to be assembled and mounted to a surface."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "cameracase"
	w_class = WEIGHT_CLASS_SMALL
	anchored = FALSE
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/analyzer)
	var/list/upgrades = list()
	var/state = ASSEMBLY_UNBUILT


/obj/item/camera_assembly/Destroy()
	QDEL_LIST(upgrades)
	return ..()


/obj/item/camera_assembly/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(state == ASSEMBLY_WELDED && iscoil(I))
		var/obj/item/stack/cable_coil/coil = I
		if(!coil.use(2))
			to_chat(user, span_warning("You need two coils of cable to wire the assembly."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You add wires to the assembly."))
		playsound(loc, I.usesound, 50, TRUE)
		state = ASSEMBLY_WIRED
		return ATTACK_CHAIN_PROCEED_SUCCESS

	// Upgrades!
	if(is_type_in_list(I, possible_upgrades) && !is_type_in_list(I, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(isstack(I))
			if(!I.use(1))
				to_chat(user, span_warning("You need more of [I]."))
				return ATTACK_CHAIN_PROCEED
			var/obj/item/stack/new_stack = new(src, 1)
			to_chat(user, span_notice("You attach [new_stack] into the assembly inner circuits."))
			upgrades += new_stack
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You attach [I] into the assembly inner circuits."))
		upgrades += I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/camera_assembly/crowbar_act(mob/user, obj/item/I)
	if(!length(upgrades))
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	var/obj/upgrade = locate() in upgrades
	if(!upgrade)
		return .
	to_chat(user, span_notice("You unattach [upgrade] from the assembly."))
	playsound(loc, I.usesound, 50, TRUE)
	upgrade.forceMove(loc)
	upgrades -= upgrade


/obj/item/camera_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	state = HEY_IM_WORKING_HERE
	var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
	if(!input)
		state = ASSEMBLY_WIRED
		to_chat(usr, span_warning("No input found please hang up and try your call again."))
		return

	var/list/tempnetwork = splittext(input, ",")
	if(tempnetwork.len < 1)
		state = ASSEMBLY_WIRED
		to_chat(user, span_warning("No network found please hang up and try your call again."))
		return

	var/area/camera_area = get_area(src)
	var/temptag = "[sanitize(camera_area.name)] ([rand(1, 999)])"
	input = strip_html(input(user, "How would you like to name the camera?", "Set Camera Name", temptag))
	state = ASSEMBLY_BUILT
	var/obj/machinery/camera/camera = new(loc, uniquelist(tempnetwork), input, src)
	forceMove(camera)
	camera.auto_turn()

	for(var/i = 5; i >= 0; i -= 1)
		var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
		if(direct != "LEAVE IT")
			camera.setDir(text2dir(direct))
		if(i != 0)
			var/confirm = tgui_alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", list("Yes", "No"))
			if(confirm == "Yes")
				break


/obj/item/camera_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new/obj/item/stack/cable_coil(get_turf(src), 2)
	WIRECUTTER_SNIP_MESSAGE
	state = ASSEMBLY_WELDED
	return

/obj/item/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != ASSEMBLY_UNBUILT && state != ASSEMBLY_WRENCHED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state == ASSEMBLY_UNBUILT && isturf(loc))
		WRENCH_ANCHOR_TO_WALL_MESSAGE
		set_anchored(TRUE)
		state = ASSEMBLY_WRENCHED
		update_icon(UPDATE_ICON_STATE)
		auto_turn()
	else if(state == ASSEMBLY_WRENCHED)
		WRENCH_UNANCHOR_WALL_MESSAGE
		set_anchored(FALSE)
		update_icon(UPDATE_ICON_STATE)
		state = ASSEMBLY_UNBUILT
	else
		to_chat(user, span_warning("[src] can't fit here!"))

/obj/item/camera_assembly/welder_act(mob/user, obj/item/I)
	if(state == ASSEMBLY_UNBUILT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(state == ASSEMBLY_WRENCHED)
		if(!I.use_tool(src, user, 50, volume = I.tool_volume))
			return
		to_chat(user, span_notice("You weld [src] into place."))
		state = ASSEMBLY_WELDED
	else if(state == ASSEMBLY_WELDED)
		if(!I.use_tool(src, user, 50, volume = I.tool_volume))
			return
		to_chat(user, span_notice("You unweld [src] from its place."))
		state = ASSEMBLY_WRENCHED

/obj/item/camera_assembly/update_icon_state()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)


#undef ASSEMBLY_UNBUILT
#undef ASSEMBLY_WRENCHED
#undef ASSEMBLY_WELDED
#undef ASSEMBLY_WIRED
#undef ASSEMBLY_BUILT
#undef HEY_IM_WORKING_HERE
