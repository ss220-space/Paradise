
/datum/stack_recipe
	/// Visible title of recipe
	var/title = "ERROR"
	/// Resulting typepath of crafted atom
	var/result_type
	/// Generated base64 image. Used only if result has color
	var/result_image
	/// Required stack amount to make
	var/req_amount = 1
	/// Amount of atoms made
	var/res_amount = 1
	/// Maximum amount of atoms made
	var/max_res_amount = 1
	/// Time to make
	var/time = 0
	/// Only one resulting atom is allowed per turf
	var/one_per_turf = FALSE
	/// Requires a floor underneath to make
	var/on_floor = FALSE
	/// Setting this to true will effectively set check_direction to true.
	var/is_fulltile = FALSE
	/// Requires a floor OR lattice underneath to make
	var/on_lattice = FALSE
	/// If this atom should run the direction check, for use when building things like directional windows where you can have more than one per turf
	var/check_direction = FALSE
	/// Resulting atom is a cult structure
	var/cult_structure = FALSE

/datum/stack_recipe/New(
		title,
		result_type,
		req_amount = 1,
		res_amount = 1,
		max_res_amount = 1,
		time = 0,
		one_per_turf = FALSE,
		on_floor = FALSE,
		is_fulltile = FALSE,
		on_lattice = FALSE,
		check_direction = FALSE,
		cult_structure = FALSE
	)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.is_fulltile = is_fulltile
	src.on_floor = on_floor
	src.on_lattice = on_lattice
	src.check_direction = check_direction || is_fulltile
	src.cult_structure = cult_structure

	// We create base64 image only if item have color. Otherwise use icon_ref for TGUI
	var/obj/item/result = result_type

	var/paint = result::color


	if(!isnull(paint) && paint != COLOR_WHITE)
		var/icon/result_icon = icon(result::icon, result::icon_state, SOUTH, 1)
		result_icon.Scale(32, 32)
		result_icon.Blend(paint, ICON_MULTIPLY)
		src.result_image = "[icon2base64(result_icon)]"


/// Returns TRUE if the recipe can be built, otherwise returns FALSE. This proc is only meant as a series of tests to check if construction is possible; the actual creation of the resulting atom should be handled in do_build()
/datum/stack_recipe/proc/try_build(mob/user, obj/item/stack/material, multiplier)
	if(material.get_amount() < req_amount * multiplier)
		if(req_amount * multiplier > 1)
			to_chat(user, span_warning("You haven't got enough [material] to build [res_amount * multiplier] [title]\s!"))
		else
			to_chat(user, span_warning("You haven't got enough [material] to build [title]!"))
		return FALSE

	if(check_direction && !valid_build_direction(usr.loc, usr.dir, is_fulltile = is_fulltile))
		to_chat(usr, span_warning("The [title] won't fit here!"))
		return FALSE

	if(one_per_turf && (locate(result_type) in get_turf(material)))
		to_chat(user, span_warning("There is another [title] here!"))
		return FALSE

	if(on_floor && !issimulatedturf(get_turf(material)))
		if(!on_lattice)
			to_chat(usr, span_warning("\The [title] must be constructed on the floor!"))
			return FALSE

		if(!(locate(/obj/structure/lattice) in usr.drop_location()))
			to_chat(usr, span_warning("\The [title] must be constructed on the floor or lattice!"))
			return FALSE

	if(cult_structure)
		if(!is_level_reachable(usr.z))
			to_chat(usr, span_warning("The energies of this place interfere with the metal shaping!"))
			return FALSE
		if(locate(/obj/structure/cult) in usr.drop_location())
			to_chat(usr, span_warning("There is a structure here!"))
			return FALSE
		if(locate(/obj/structure/clockwork) in usr.drop_location())
			to_chat(usr, span_warning("There is a structure here!"))
			return FALSE
		if(locate(/obj/structure/falsewall) in usr.drop_location())
			to_chat(usr, span_warning("There is a structure here!"))
			return FALSE

	var/area/A = get_area(usr)
	if(result_type == /obj/structure/clockwork/functional/beacon)
		if(!is_station_level(usr.z))
			to_chat(usr, span_warning("The beacon cannot guide from this place! It must be on station!"))
			return FALSE
		if(istype(A, /area/space))
			to_chat(usr, span_warning("The beacon must be inside the station itself to properly work."))
			return FALSE
		if(!A.type == /area) //The only one that is made by blueprints
			to_chat(usr, span_warning("This area is too fresh for the beacon!"))
			return FALSE
		if(locate(/obj/structure/clockwork/functional/beacon) in A)
			to_chat(usr, span_warning("This area already has beacon!"))
			return FALSE
	if(result_type == /obj/structure/clockwork/functional/cogscarab_fabricator)
		if(GLOB.clockwork_fabricators.len >= MAX_COG_FABRICATORS)
			to_chat(usr, span_warning("You can't build more than [MAX_COG_FABRICATORS] fabricators!"))
			return FALSE
		if(usr.type == /mob/living/silicon/robot/cogscarab)
			to_chat(usr, span_warning("You're too small to build this machinery."))
			return FALSE

	return TRUE

/// Creates the atom defined by the recipe. Should always return the object it creates or FALSE. This proc assumes that the construction is already possible; for checking whether a recipe *can* be built before construction, use try_build()
/datum/stack_recipe/proc/do_build(mob/user, obj/item/stack/material, multiplier, atom/result)
	if(time)
		to_chat(user, span_notice("Building [title]..."))
		if(!do_after(user, time, target = material.loc))
			return FALSE

	if(cult_structure && locate(/obj/structure/cult) in get_turf(src)) //Check again after do_after to prevent queuing construction exploit.
		to_chat(usr, span_warning("There is a structure here!"))
		return FALSE

	if(cult_structure && locate(/obj/structure/clockwork) in get_turf(src))
		to_chat(usr, span_warning("There is a structure here!"))
		return FALSE

	if(material.get_amount() < req_amount * multiplier) // Check they still have enough.
		return FALSE

	if(max_res_amount > 1) // Is it a stack?
		result = new result_type(get_turf(material), res_amount * multiplier)
	else
		result = new result_type(get_turf(material))

	result.setDir(user.dir)
	result.update_icon()
	material.use(req_amount * multiplier)
	material.updateUsrDialog()
	return result

/// What should be done after the object is built? obj/item/stack/result might not actually be a stack, but this proc needs access to merge() to work, which is on obj/item/stack, so declare it as obj/item/stack anyways.
/datum/stack_recipe/proc/post_build(mob/user, obj/item/stack/material, obj/item/stack/result)
	result.add_fingerprint(user)

	if(isitem(result))
		if(isstack(result) && istype(result, user.get_inactive_hand()))
			result.merge(user.get_inactive_hand())
		user.put_in_hands(result)

	// BubbleWrap - so newly formed boxes are empty
	if(isstorage(result))
		for(var/obj/item/thing in result)
			qdel(thing)
	// BubbleWrap END

// Special Recipes
/datum/stack_recipe/cable_restraints
/datum/stack_recipe/cable_restraints/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/item/restraints/handcuffs/cable))
		result.color = S.color
	..()

/datum/stack_recipe/dangerous
/datum/stack_recipe/dangerous/post_build(mob/user, obj/item/stack/S, obj/result)
	var/turf/targ = get_turf(user)
	message_admins("[title] made by [key_name_admin(usr)] in [ADMIN_VERBOSEJMP(usr)]!",0,1)
	add_game_logs("made [title] at [AREACOORD(targ)].", usr)
	..()

/datum/stack_recipe/rods
/datum/stack_recipe/rods/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = result
		R.update_icon()
	..()

/datum/stack_recipe/window
/datum/stack_recipe/window/post_build(mob/user, obj/item/stack/S, obj/result)
	if(istype(result, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = result
		W.ini_dir = W.dir
	else if(istype(result, /obj/structure/window))
		var/obj/structure/window/W = result
		W.ini_dir = W.dir
		W.set_anchored(FALSE)
		W.state = WINDOW_OUT_OF_FRAME
	..()

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes


