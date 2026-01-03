#define BRASS_POWER_COST 200
#define REGULAR_POWER_COST (BRASS_POWER_COST / 4)

/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "replica_fabricator"
	item_state = "replica_fabricator"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	/// List of things that the fabricator can build for the radial menu
	var/static/list/crafting_possibilities = list(
		"floor" = image(icon = 'icons/turf/floors.dmi', icon_state = "clockwork_floor"),
		"wall" = image(icon = 'icons/turf/walls/clockwork_wall.dmi', icon_state = "clockwork_wall-0"),
		"wall gear" = image(icon = 'icons/obj/clockwork.dmi', icon_state = "gear"),
		"window" = image(icon = 'icons/obj/smooth_structures/clockwork_window.dmi', icon_state = "clockwork_window"),
		"airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "closed"),
		"glass airlock" = image(icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi', icon_state = "construction"),
		"brass" = image(icon = 'icons/obj/items.dmi', icon_state = "sheet-brass"),
	)
	/// List of initialized fabrication datums, created on Initialize
	var/static/list/fabrication_datums = list()
	/// Ref to the datum we have selected currently
	var/datum/replica_fabricator_output/selected_output


/obj/item/clockwork/replica_fabricator/Initialize(mapload)
	. = ..()
	if(!length(fabrication_datums))
		create_fabrication_list()

/obj/item/clockwork/replica_fabricator/Destroy(force)
	selected_output = null
	return ..()

/obj/item/clockwork/replica_fabricator/examine(mob/user)
	. = ..()
	if(isclocker(user))
		. += span_clockitalic("Current power: [GLOB.clockwork_power]")
		. += span_clockitalic("Use on brass to convert it into power.")
		. += span_clockitalic("Use on other materials to convert them into power, but less efficiently.")
		. += span_clockitalic("<b>Use</b> in-hand to select what to fabricate.")
		. += span_clockitalic("<b>Right Click</b> in-hand to fabricate bronze sheets.")
		. += span_clockitalic("Walls and windows will be built slower while on reebe.")


/obj/item/clockwork/replica_fabricator/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isclocker(user))
		return

	if(istype(target, /obj/item/stack/sheet)) // If it's an item, handle it seperately
		attempt_convert_materials(target, user)
		return

	if(!selected_output) // Now we handle objects
		return

	if(GLOB.clockwork_power < selected_output.cost)
		to_chat(user, span_clockitalic("[src] needs at least [selected_output.cost]W of power to create this."))
		return

	var/turf/creation_turf = get_turf(target)
	var/atom/movable/possible_replaced
	if(locate(selected_output.to_create_path) in creation_turf)
		to_chat(user, span_clockitalic("There is already one of these on this tile!"))
		return

	if(selected_output.replace_types_of && istype(selected_output, /datum/replica_fabricator_output/turf_output))
		if(!isturf(target) && !(locate(creation_turf) in selected_output.replace_types_of))
			return
	else if(selected_output.replace_types_of)
		for(var/checked_type in selected_output.replace_types_of)
			var/atom/movable/found_replaced = locate(checked_type) in creation_turf
			if(found_replaced)
				possible_replaced = found_replaced
				break
		if(!possible_replaced && !isturf(target))
			return
	else if(!isturf(target))
		return

	var/delay = selected_output.creation_delay
	if(istype(get_turf(target.loc), /turf/simulated/floor/clockwork))
		delay = delay/2

	var/obj/effect/temp_visual/ratvar/constructing_effect/effect = new(creation_turf, delay)
	if(!do_after(user, delay, target))
		qdel(effect)
		return

	if(GLOB.clockwork_power < selected_output.cost) // Just in case
		return

	GLOB.clockwork_power -= selected_output.cost
	var/atom/created
	if(!istype(selected_output, /datum/replica_fabricator_output/turf_output))
		if(possible_replaced)
			qdel(possible_replaced)
		created = new selected_output.to_create_path(creation_turf)

	selected_output.on_create(created, creation_turf, user)

/obj/item/clockwork/replica_fabricator/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!isclocker(user))
		return

	attempt_convert_materials(attacking_item, user)

/obj/item/clockwork/replica_fabricator/attack_self(mob/user, modifiers)
	. = ..()
	if(!isclocker(user))
		to_chat(user, span_clockitalic("[src] странно жужжит!"))
		return

	var/choice = show_radial_menu(user, src, crafting_possibilities, radius = 36, custom_check = PROC_REF(check_menu), require_near = TRUE)

	if(!choice)
		return

	if(choice == "brass")
		create_brass(user)

	selected_output = fabrication_datums[choice]

// Create brass from power
/obj/item/clockwork/replica_fabricator/proc/create_brass(mob/living/carbon/human/user)
	var/sheets = tgui_input_number(user, "How many sheets do you want to fabricate?", "Sheet Fabrication", 0, round(GLOB.clockwork_power / BRASS_POWER_COST), 0)
	var/cost = BRASS_POWER_COST*sheets
	if(GLOB.clockwork_power < cost)
		to_chat(user, span_clockitalic("You need at least [cost]W of power to fabricate bronze."))
		return

	if(!sheets)
		return

	GLOB.clockwork_power -= cost

	var/obj/item/stack/sheet/brass/sheet_stack = new(user.loc, sheets)
	if(istype(user))
		user.put_in_hands(sheet_stack)
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, span_clockitalic("You fabricate [sheets] bronze."))


/// Standard confirmation for the radial menu proc
/obj/item/clockwork/replica_fabricator/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE

	if(user.incapacitated())
		return FALSE

	return TRUE

/// Attempt to convert the targeted item into power, if it's a sheet item
/obj/item/clockwork/replica_fabricator/proc/attempt_convert_materials(atom/attacking_item, mob/user)
	if(istype(attacking_item, /obj/item/stack/sheet/brass) || istype(attacking_item, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/bronze_stack = attacking_item
		GLOB.clockwork_power += bronze_stack.amount * BRASS_POWER_COST
		qdel(bronze_stack)
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockitalic("You convert [bronze_stack.amount] bronze into [bronze_stack.amount * BRASS_POWER_COST] watts of power."))

		return TRUE

	else if(istype(attacking_item, /obj/item/stack/sheet))
		var/obj/item/stack/stack = attacking_item
		GLOB.clockwork_power += stack.amount * REGULAR_POWER_COST
		qdel(stack)
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_clockitalic("You convert [stack.amount] [stack.name] into [stack.amount * REGULAR_POWER_COST] watts of power."))
		return TRUE

	return FALSE

/// Creates the list of initialized fabricator datums, done once on init
/obj/item/clockwork/replica_fabricator/proc/create_fabrication_list()
	for(var/type in subtypesof(/datum/replica_fabricator_output))
		var/datum/replica_fabricator_output/output_ref = new type
		fabrication_datums[output_ref.name] = output_ref


/datum/replica_fabricator_output
	/// Name of the output
	var/name = "parent"
	/// Power cost of the output
	var/cost = 0
	/// Typepath to spawn
	var/to_create_path
	/// How long the creation actionbar is
	var/creation_delay = 1 SECONDS
	/// List of objs this output can replace, normal walls for clock walls, windows for clock windows, ETC
	var/list/replace_types_of
	/// Multiplier for creation_delay when used on reebe

/// Any extra actions that need to be taken when an object is created
/datum/replica_fabricator_output/proc/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	SHOULD_CALL_PARENT(TRUE)
	playsound(creation_turf, 'sound/machines/clockcult/integration_cog_install.ogg', 50, 1) // better sound?
	to_chat(creator, span_clockitalic("You create \an [name] for [cost]W of power."))

/datum/replica_fabricator_output/turf_output/on_create(atom/created_atom, turf/creation_turf, mob/creator)
	creation_turf.ChangeTurf(to_create_path)
	return ..()

/datum/replica_fabricator_output/turf_output/brass_floor
	name = "floor"
	cost = BRASS_POWER_COST * 0.25 // 1/4th the cost, since one sheet = 4 floor tiles
	to_create_path = /turf/simulated/floor/clockwork

/datum/replica_fabricator_output/turf_output/brass_floor/on_create(obj/created_object, turf/creation_turf, mob/creator)
	. = ..()

	new /obj/effect/temp_visual/ratvar/floor(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)

/datum/replica_fabricator_output/turf_output/brass_wall
	name = "wall"
	cost = BRASS_POWER_COST * 4
	to_create_path = /turf/simulated/wall/clockwork
	creation_delay = 7 SECONDS
	replace_types_of = list(/turf/simulated/wall)

/datum/replica_fabricator_output/turf_output/brass_wall/on_create(obj/created_object, turf/creation_turf, mob/creator)
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)

/datum/replica_fabricator_output/wall_gear
	name = "wall gear"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/clockwork/wall_gear
	creation_delay = 3 SECONDS
	replace_types_of = list(/obj/structure/girder)

/datum/replica_fabricator_output/wall_gear/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/gear(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/brass_window
	name = "window"
	cost = BRASS_POWER_COST * 2
	to_create_path = /obj/structure/window/reinforced/clockwork/fulltile
	creation_delay = 5 SECONDS
	replace_types_of = list(/obj/structure/window)

/datum/replica_fabricator_output/brass_window/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/window(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock
	name = "airlock"
	cost = BRASS_POWER_COST * 5 // Breaking it only gets 2 but this is the exception to the rule of equivalent exchange, due to all the small parts inside
	to_create_path = /obj/machinery/door/airlock/clockwork
	creation_delay = 5 SECONDS

/datum/replica_fabricator_output/pinion_airlock/on_create(obj/created_object, turf/creation_turf, mob/creator)
	new /obj/effect/temp_visual/ratvar/door(creation_turf)
	new /obj/effect/temp_visual/ratvar/beam(creation_turf)
	return ..()

/datum/replica_fabricator_output/pinion_airlock/glass
	name = "glass airlock"
	to_create_path = /obj/machinery/door/airlock/clockwork/glass

#undef BRASS_POWER_COST
#undef REGULAR_POWER_COST
