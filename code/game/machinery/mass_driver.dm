#define MASS_DRIVER_BUILD_LOOSE 0
#define MASS_DRIVER_BUILD_ANCHORED 1
#define MASS_DRIVER_BUILD_WELDED 2
#define MASS_DRIVER_BUILD_WIRED 3
#define MASS_DRIVER_BUILD_GRILLE 4

/obj/machinery/mass_driver
	name = "mass driver"
	desc = "Shoots things into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 50

	var/power = 1.0
	var/code = 1.0
	var/id_tag = "default"
	var/drive_range = 50 //this is mostly irrelevant since current mass drivers throw into space, but you could make a lower-range mass driver for interstation transport or something I guess.

	multitool_menu_type = /datum/multitool_menu/idtag/mass_driver

/obj/machinery/mass_driver/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)


/obj/machinery/mass_driver/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	to_chat(user, "You begin to unscrew the bolts off [src]...")
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
		return .
	var/obj/machinery/mass_driver_frame/frame = new(loc)
	frame.setDir(dir)
	frame.set_anchored(TRUE)
	frame.build = MASS_DRIVER_BUILD_GRILLE
	frame.update_icon()
	qdel(src)


/obj/machinery/mass_driver/proc/drive(amount)
	if(stat & (BROKEN|NOPOWER))
		return
	use_power(500*power)
	var/O_limit = 0
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if((!O.anchored && O.move_resist != INFINITY) || ismecha(O)) //Mechs need their launch platforms. Also checks if something is anchored or has move resist INFINITY, which should stop ghost flinging.
			O_limit++
			if(O_limit >= 20)//so no more than 20 items are sent at a time, probably for counter-lag purposes
				break
			use_power(500)
			spawn()
				var/coef = 1
				if(emagged)
					coef = 5
				O.throw_at(target, drive_range * power * coef, power * coef)
	flick("mass_driver1", src)
	return

/obj/machinery/mass_driver/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	drive()
	..(severity)

/obj/machinery/mass_driver/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			to_chat(user, "You hack the Mass Driver, radically increasing the force at which it'll throw things. Better not stand in its way.")
		return 1
	return -1

////////////////MASS BUMPER///////////////////

/obj/machinery/mass_driver/bumper
	name = "mass bumper"
	desc = "Now you're here, now you're over there."
	density = TRUE


/obj/machinery/mass_driver/bumper/Bumped(atom/movable/moving_atom)
	. = ..()
	set_density(FALSE)
	step(moving_atom, get_dir(moving_atom, src))
	spawn(1)
		set_density(TRUE)
	drive()

////////////////MASS DRIVER FRAME///////////////////

/obj/machinery/mass_driver_frame
	name = "mass driver frame"
	icon = 'icons/obj/objects.dmi'
	icon_state = "mass_driver_frame"
	density = FALSE
	anchored = FALSE
	/// Current construction stage
	var/build = MASS_DRIVER_BUILD_LOOSE


/obj/machinery/mass_driver_frame/wrench_act(mob/living/user, obj/item/I)
	if(build != MASS_DRIVER_BUILD_LOOSE && build != MASS_DRIVER_BUILD_ANCHORED)
		return FALSE
	. = TRUE
	switch(build)
		if(MASS_DRIVER_BUILD_LOOSE)
			to_chat(user, "You begin to anchor [src] on the floor.")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_LOOSE)
				return .
			set_anchored(TRUE)
			build = MASS_DRIVER_BUILD_ANCHORED
			to_chat(user, span_notice("You anchor [src]!"))
		if(MASS_DRIVER_BUILD_ANCHORED)
			to_chat(user, "You begin to de-anchor [src] from the floor.")
			if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_ANCHORED)
				return .
			set_anchored(FALSE)
			build = MASS_DRIVER_BUILD_LOOSE
			to_chat(user, span_notice("You de-anchored [src]!"))


/obj/machinery/mass_driver_frame/wirecutter_act(mob/living/user, obj/item/I)
	if(build != MASS_DRIVER_BUILD_WIRED)
		return FALSE
	. = TRUE
	to_chat(user, "You begin to remove the wiring from [src].")
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_WIRED)
		return .
	build = MASS_DRIVER_BUILD_WELDED
	to_chat(user, span_notice("You've removed the cables from [src]."))


/obj/machinery/mass_driver_frame/crowbar_act(mob/living/user, obj/item/I)
	if(build != MASS_DRIVER_BUILD_GRILLE)
		return FALSE
	. = TRUE
	to_chat(user, "You begin to pry off the grille from [src]...")
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_GRILLE)
		return .
	build = MASS_DRIVER_BUILD_WIRED
	new /obj/item/stack/rods(loc, 2)


/obj/machinery/mass_driver_frame/screwdriver_act(mob/living/user, obj/item/I)
	if(build != MASS_DRIVER_BUILD_GRILLE) // Grille in place
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, "You finalize the Mass Driver...")
	var/obj/machinery/mass_driver/driver = new(loc)
	driver.setDir(dir)
	qdel(src)


/obj/machinery/mass_driver_frame/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(build)
		if(MASS_DRIVER_BUILD_WELDED)
			if(istype(I, /obj/item/stack/cable_coil))
				add_fingerprint(user)
				var/obj/item/stack/cable_coil/coil = I
				if(coil.get_amount() < 2)
					to_chat(user, span_warning("You need more cable for this!"))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, "You start adding cables to [src]...")
				playsound(loc, coil.usesound, 50, TRUE)
				if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || build != MASS_DRIVER_BUILD_WELDED || QDELETED(coil) || !coil.use(2))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, span_notice("You've added cables to [src]."))
				build = MASS_DRIVER_BUILD_WIRED
				return ATTACK_CHAIN_PROCEED_SUCCESS

		if(MASS_DRIVER_BUILD_WIRED)
			if(istype(I, /obj/item/stack/rods))
				add_fingerprint(user)
				var/obj/item/stack/rods/rods = I
				if(rods.get_amount() < 2)
					to_chat(user, span_warning("You need more rods for this!"))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, "You start adding rods to [src]...")
				playsound(loc, rods.usesound, 50, TRUE)
				if(!do_after(user, 2 SECONDS * rods.toolspeed, src, category = DA_CAT_TOOL) || build != MASS_DRIVER_BUILD_WIRED || QDELETED(rods) || !rods.use(2))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, span_notice("You've added rods to [src]."))
				build = MASS_DRIVER_BUILD_GRILLE
				return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/mass_driver_frame/welder_act(mob/user, obj/item/I)
	if(build != MASS_DRIVER_BUILD_LOOSE && build != MASS_DRIVER_BUILD_ANCHORED && build != MASS_DRIVER_BUILD_WELDED)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return .
	switch(build)
		if(MASS_DRIVER_BUILD_LOOSE)
			WELDER_ATTEMPT_SLICING_MESSAGE
			if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_LOOSE)
				return .
			WELDER_SLICING_SUCCESS_MESSAGE
			new /obj/item/stack/sheet/plasteel(drop_location(),3)
			qdel(src)

		if(MASS_DRIVER_BUILD_ANCHORED)
			WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
			if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_ANCHORED)
				return .
			WELDER_FLOOR_WELD_SUCCESS_MESSAGE
			build = MASS_DRIVER_BUILD_WELDED

		if(MASS_DRIVER_BUILD_WELDED)
			WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE
			if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || build != MASS_DRIVER_BUILD_WELDED)
				return .
			WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
			build = MASS_DRIVER_BUILD_ANCHORED


/obj/machinery/mass_driver_frame/verb/rotate()
	set category = "Object"
	set name = "Rotate Frame"
	set src in view(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(usr, TRAIT_FAKEDEATH))
		return

	setDir(turn(dir, -90))


#undef MASS_DRIVER_BUILD_LOOSE
#undef MASS_DRIVER_BUILD_ANCHORED
#undef MASS_DRIVER_BUILD_WIRED
#undef MASS_DRIVER_BUILD_WELDED
#undef MASS_DRIVER_BUILD_GRILLE

