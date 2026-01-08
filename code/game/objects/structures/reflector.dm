/obj/structure/reflector
	name = "reflector base"
	icon_state = "reflector_map"
	desc = "A base for reflector assemblies."
	var/deflector_icon_state
	var/mutable_appearance/deflector_overlay
	var/finished = FALSE
	var/admin = FALSE //Can't be rotated or deconstructed
	var/can_rotate = TRUE
	var/framebuildstacktype = /obj/item/stack/sheet/metal
	var/framebuildstackamount = 5
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 0
	var/list/allowed_projectile_typecache = list(/obj/projectile/beam)
	var/rotation_angle = -1

/obj/structure/reflector/Initialize(mapload)
	. = ..()
	icon_state = "reflector_base"
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(deflector_icon_state)
		deflector_overlay = mutable_appearance(icon, deflector_icon_state)
		// We offset our physical position DOWN, because TRANSFORM IS A FUCK
		deflector_overlay.pixel_y = -32
		deflector_overlay.pixel_z = 32
		add_overlay(deflector_overlay)

	if(rotation_angle == -1)
		set_reflector_angle(dir2angle(dir))
	else
		set_reflector_angle(rotation_angle)

	if(admin)
		can_rotate = FALSE

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/reflector,
	))

/obj/structure/reflector/examine(mob/user)
	. = ..()
	if(!finished)
		return
	. += "It is set to [rotation_angle] degrees, and the rotation is [can_rotate ? "unlocked" : "locked"]."
	if(!admin)
		if(can_rotate)
			. += span_notice("Use your <b>hand</b> to adjust its direction.")
			. += span_notice("Use a <b>screwdriver</b> to lock the rotation.")
		else
			. += span_notice("Use <b>screwdriver</b> to unlock the rotation.")

/obj/structure/reflector/proc/set_reflector_angle(new_angle)
	if(!can_rotate)
		return

	rotation_angle = new_angle

	if(!deflector_overlay)
		return

	cut_overlay(deflector_overlay)
	deflector_overlay.transform = turn(matrix(), new_angle)
	add_overlay(deflector_overlay)

/obj/structure/reflector/setDir(new_dir)
	return ..(NORTH)

/obj/structure/reflector/bullet_act(obj/projectile/proj)
	var/pdir = proj.dir
	var/pangle = proj.Angle
	var/ploc = get_turf(proj)
	if(!finished || !allowed_projectile_typecache[proj.type])
		return ..()
	if(!auto_reflect(proj, pdir, ploc, pangle))
		return ..()
	return -1

/obj/structure/reflector/proc/auto_reflect(obj/projectile/proj, pdir, turf/ploc, pangle)
	proj.ignore_source_check = TRUE
	proj.range = proj.range
	proj.range = max(proj.range--, 0)
	return TRUE

/obj/structure/reflector/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	can_rotate = !can_rotate
	to_chat(user, span_notice("You [can_rotate ? "unlock" : "lock"] [src]'s rotation."))
	tool.play_tool_sound(src)

/obj/structure/reflector/wrench_act(mob/user, obj/item/I)
	. = TRUE

	if(anchored)
		to_chat(user, "Unweld [src] first!")
		return

	if(!I.tool_use_check(user, 0))
		return

	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 80, volume = I.tool_volume))
		return

	playsound(user, 'sound/items/Ratchet.ogg', 50, TRUE)
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	new framebuildstacktype(drop_location(), framebuildstackamount)

	if(buildstackamount)
		new buildstacktype(drop_location(), buildstackamount)

	qdel(src)

/obj/structure/reflector/welder_act(mob/user, obj/item/tool)
	. = TRUE
	if(!tool.tool_use_check(user, 0))
		return

	if(!tool.use_tool(src, user, 20, volume = tool.tool_volume))
		return

	if(anchored)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
		set_anchored(FALSE)
	else
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
		set_anchored(TRUE)

	WELDER_FLOOR_WELD_SUCCESS_MESSAGE

/obj/structure/reflector/attackby(obj/item/tool, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	if(finished)
		to_chat(user, span_warning("The reflector is already completed!"))
		return ATTACK_CHAIN_PROCEED

	//Finishing the frame
	var/obj/item/stack/sheet/sheet = tool
	if(istype(sheet, /obj/item/stack/sheet/glass))
		if(!sheet.use(5))
			to_chat(user, span_warning("You need at least five sheets of glass to create a reflector!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/reflector/single/reflector = new(loc)
		transfer_fingerprints_to(reflector)
		reflector.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(sheet, /obj/item/stack/sheet/rglass))
		if(!sheet.use(10))
			to_chat(user, span_warning("You need at least ten sheets of reinforced glass to create a double reflector!"))
			return .
		var/obj/structure/reflector/double/reflector = new(loc)
		transfer_fingerprints_to(reflector)
		reflector.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(sheet, /obj/item/stack/sheet/mineral/diamond))
		if(!sheet.use(1))
			to_chat(user, span_warning("You need at least one diamond to create a reflector box!"))
			return .
		var/obj/structure/reflector/box/reflector = new(loc)
		transfer_fingerprints_to(reflector)
		reflector.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	deflector_icon_state = "reflector"
	desc = "An angled mirror for reflecting laser beams."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/glass
	buildstackamount = 5

/obj/structure/reflector/single/anchored
	anchored = TRUE

/obj/structure/reflector/single/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/single/auto_reflect(obj/projectile/proj, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (proj.Angle + 180))
	if(abs(incidence) > 90 && abs(incidence) < 270)
		return FALSE
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	proj.set_angle_centered(new_angle)
	return ..()

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	deflector_icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting laser beams."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/rglass
	buildstackamount = 10

/obj/structure/reflector/double/anchored
	anchored = TRUE

/obj/structure/reflector/double/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/double/auto_reflect(obj/projectile/proj, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (proj.Angle + 180))
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	proj.forceMove(loc)
	proj.set_angle_centered(new_angle)
	return ..()

//BOX

/obj/structure/reflector/box
	name = "reflector box"
	deflector_icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser beams in a single direction."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/mineral/diamond
	buildstackamount = 1

/obj/structure/reflector/box/anchored
	anchored = TRUE

/obj/structure/reflector/box/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/box/auto_reflect(obj/projectile/proj)
	proj.set_angle_centered(rotation_angle)
	return ..()

/obj/structure/reflector/ex_act()
	if(admin)
		return FALSE
	return ..()

/obj/structure/reflector/singularity_act()
	if(admin)
		return
	return ..()

//	USB

/obj/item/circuit_component/reflector
	display_name = "Отражатель"
	desc = "Позволяет регулировать угол отражателя."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// Angle the reflector will be set to at trigger unless locked
	var/datum/port/input/angle

	var/obj/structure/reflector/attached_reflector

/obj/item/circuit_component/reflector/populate_ports()
	angle = add_input_port("Угол", PORT_TYPE_NUMBER)

/obj/item/circuit_component/reflector/register_usb_parent(atom/movable/parent)
	. = ..()
	if(!istype(parent, /obj/structure/reflector))
		return

	attached_reflector = parent

/obj/item/circuit_component/reflector/unregister_usb_parent(atom/movable/parent)
	attached_reflector = null
	return ..()

/obj/item/circuit_component/reflector/input_received(datum/port/input/port)
	attached_reflector?.set_reflector_angle(angle.value)

// tgui menu

/obj/structure/reflector/ui_interact(mob/user, datum/tgui/ui)
	if(!finished)
		balloon_alert(user, "нечего разворачивать!")
		return

	if(!can_rotate)
		balloon_alert(user, "невозможно развернуть!")
		ui?.close()
		return

	ui = SStgui.try_update_ui(user, src, ui)

	if(ui)
		return

	ui = new(user, src, "Reflector")
	ui.open()

/obj/structure/reflector/attack_hand(mob/living/user)
	ui_interact(user)
	return

/obj/structure/reflector/attack_robot(mob/user)
	ui_interact(user)
	return

/obj/structure/reflector/ui_state(mob/user)
	return GLOB.physical_state //Prevents borgs from adjusting this at range

/obj/structure/reflector/ui_data(mob/user)
	var/list/data = list()
	data["rotation_angle"] = rotation_angle
	data["reflector_name"] = name

	return data

/obj/structure/reflector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("rotate")
			if(!can_rotate || admin)
				return FALSE

			var/new_angle = params["rotation_angle"]

			if(!isnull(new_angle))
				set_reflector_angle(SIMPLIFY_DEGREES(new_angle))

			return TRUE

		if("calculate")
			if(!can_rotate || admin)
				return FALSE

			var/new_angle = rotation_angle + params["rotation_angle"]

			if(!isnull(new_angle))
				set_reflector_angle(SIMPLIFY_DEGREES(new_angle))

			return TRUE

/obj/structure/reflector/wrenched

/obj/structure/reflector/wrenched/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)
