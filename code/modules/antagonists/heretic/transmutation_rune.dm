/// The heretic's rune, which they use to complete transmutation rituals.
/obj/effect/decal/heretic_rune
	name = "Руна Трансформации"
	desc = "Жуткий круг фигур и рун изображенный на полу, заполненный густой черной как смоль жидкостью. Выглядит довольно маленьким."
	icon = 'icons/obj/rune.dmi'
	icon_state = "main1"
	plane = BELOW_GAME_PLANE
	layer = ABOVE_CLEANABLES_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE


/obj/effect/decal/heretic_rune/get_ru_names()
	return list(
		NOMINATIVE = "Руна Трансформации",
		GENITIVE = "Руны Трансформации",
		DATIVE = "Руне Трансформации",
		ACCUSATIVE = "Руну Трансформации",
		INSTRUMENTAL = "Руной Трансформации",
		PREPOSITIONAL = "Руне Трансформации"
	)


/obj/effect/decal/heretic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)
	ADD_TRAIT(src, TRAIT_MOPABLE, INNATE_TRAIT)


/obj/effect/decal/heretic_rune/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	. += span_notice("Позволяет трансмутировать предметы, после соблюдения некоторых условий.")
	. += span_notice("Вы можете использовать <i>Прикосновение Мансуса</i> на руне, чтобы стереть её.")


/obj/effect/decal/heretic_rune/proc/can_interact(mob/living/user)
	if(!isheretic(user))
		return FALSE

	if(is_in_use)
		return FALSE

	return TRUE


/obj/effect/decal/heretic_rune/attack_hand(mob/living/user, list/modifiers)
	if(!can_interact(user))
		return ATTACK_CHAIN_BLOCKED_ALL

	. = ..()
	INVOKE_ASYNC(src, PROC_REF(try_rituals), user)
	return ATTACK_CHAIN_PROCEED


/obj/effect/decal/heretic_rune/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/melee/touch_attack/mansus_fist))
		user.balloon_alert(user, "руна стерта")
		qdel(src)
		return ATTACK_CHAIN_PROCEED

	. = ..()
	INVOKE_ASYNC(src, PROC_REF(try_rituals), user)
	return ATTACK_CHAIN_PROCEED


/**
 * Attempt to begin a ritual, giving them an input list to chose from.
 * Also ensures is_in_use is enabled and disabled before and after.
 */
/obj/effect/decal/heretic_rune/proc/try_rituals(mob/living/user)
	is_in_use = TRUE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/rituals = heretic_datum.get_rituals()
	if(!length(rituals))
		loc.balloon_alert(user, "нет доступных ритуалов")
		is_in_use = FALSE
		return

	var/chosen = tgui_input_list(user, "Выберите ритуал, который хотите провести.", "Выбор ритуала", rituals)
	if(!chosen || !istype(rituals[chosen], /datum/heretic_knowledge) || QDELETED(src) || QDELETED(user) || QDELETED(heretic_datum))
		is_in_use = FALSE
		return

	do_ritual(user, rituals[chosen])
	is_in_use = FALSE


/**
 * Attempt to invoke a ritual from the past list of knowledges.
 *
 * Arguments
 * * user - the heretic / the person who invoked the rune
 * * knowledge_list - a non-assoc list of heretic_knowledge datums.
 *
 * returns TRUE if any rituals passed succeeded, FALSE if they all failed.
 */
/obj/effect/decal/heretic_rune/proc/do_ritual(mob/living/user, datum/heretic_knowledge/ritual)

	// Collect all nearby valid atoms over the rune for processing in rituals.
	var/list/atom/movable/atoms_in_range = list()
	for(var/atom/close_atom as anything in range(1, src))
		if(!ismovable(close_atom))
			continue

		if(isitem(close_atom))
			var/obj/item/close_item = close_atom
			if(close_item.item_flags & ABSTRACT) //woops sacrificed your own head
				continue

		if(close_atom.invisibility)
			continue

		if(close_atom == user)
			continue

		atoms_in_range += close_atom

	// A copy of our requirements list.
	// We decrement the values of to determine if enough of each key is present.
	var/list/requirements_list = ritual.required_atoms.Copy()
	var/list/banned_atom_types = ritual.banned_atom_types.Copy()
	// A list of all atoms we've selected to use in this recipe.
	var/list/selected_atoms = list()

	// Do the snowflake check to see if we can continue or not.
	// selected_atoms is passed and can be modified by this proc.
	if(!ritual.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc, TRUE))
		return FALSE

	// Now go through all our nearby atoms and see which are good for our ritual.
	for(var/atom/nearby_atom as anything in atoms_in_range)
		// Go through all of our required atoms
		for(var/req_type in requirements_list)
			// We already have enough of this type, skip
			if(requirements_list[req_type] <= 0)
				continue
			// If req_type is a list of types, check all of them for one match.
			if(islist(req_type) && !is_type_in_list(nearby_atom, req_type))
				continue

			else if(!islist(req_type) && !istype(nearby_atom, req_type))
				continue

			// if list has items, check if the strict type is banned.
			if(length(banned_atom_types) && (nearby_atom.type in banned_atom_types))
				continue

			// This item is a valid type. Add it to our selected atoms list.
			selected_atoms |= nearby_atom
			// If it's a stack, we gotta see if it has more than one inside,
			// as our requirements may want more than one item of a stack
			if(!isstack(nearby_atom))
				requirements_list[req_type]--
				continue

			var/obj/item/stack/picked_stack = nearby_atom
			requirements_list[req_type] -= picked_stack.amount // Can go negative, but doesn't matter. Negative = fulfilled


	// All of the atoms have been checked, let's see if the ritual was successful
	var/list/what_are_we_missing = list()
	for(var/req_type in requirements_list)
		var/number_of_things = requirements_list[req_type]
		// <= 0 means it's fulfilled, skip
		if(number_of_things <= 0)
			continue

		// > 0 means it's unfilfilled - the ritual has failed, we should tell them why
		// Lets format the thing they're missing and put it into our list
		var/formatted_thing = "[number_of_things] "
		if(islist(req_type))
			var/list/req_type_list = req_type
			var/list/req_text_list = list()
			for(var/atom/possible_type as anything in req_type_list)
				req_text_list += ritual.parse_required_item(possible_type)

			formatted_thing += english_list(req_text_list, and_text = "or")

		else
			formatted_thing = ritual.parse_required_item(req_type)

		what_are_we_missing += formatted_thing

	if(length(what_are_we_missing))
		// Let them know it screwed up
		loc.balloon_alert(user, "не хватает компонентов!")
		// Then let them know what they're missing
		to_chat(user, span_hierophant_warning("Для завершения ритуала \"[ritual.name]\" не хватает [english_list(what_are_we_missing)]."))
		return FALSE

	// If we made it here, the ritual had all necessary components, and we can try to cast it.
	// This doesn't necessarily mean the ritual will succeed, but it's valid!
	// Do the animations and associated feedback.
	flick("[icon_state]_active", src)
	playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)

	// All the components have been invisibled, time to actually do the ritual. Call on_finished_recipe
	// (Note: on_finished_recipe may sleep in the case of some rituals like summons, which expect ghost candidates.)
	// - If the ritual was success (Returned TRUE), proceede to clean up the atoms involved in the ritual. The result has already been spawned by this point.
	// - If the ritual failed for some reason (Returned FALSE), likely due to no ghosts taking a role or an error, we shouldn't clean up anything, and reset.
	var/ritual_result = ritual.on_finished_recipe(user, selected_atoms, loc)

	if(ritual_result)
		ritual.cleanup_atoms(selected_atoms)

	// And finally, give some user feedback
	// No feedback is given on failure here -
	// the ritual itself should handle it (providing specifics as to why it failed)
	if(ritual_result)
		loc.balloon_alert(user, "ритуал завершен")

	return ritual_result


/// A 3x3 heretic rune. The kind heretics actually draw in game.
/obj/effect/decal/heretic_rune/big
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = -30
	//pixel_y = 18
	//pixel_z = -48
	//greyscale_config = /datum/greyscale_config/heretic_rune


/obj/effect/decal/heretic_rune/big/Initialize(mapload, path_colour)
	. = ..()
	if(!path_colour)
		return

	add_atom_colour(path_colour, FIXED_COLOUR_PRIORITY)


/obj/effect/temp_visual/drawing_heretic_rune
	duration = 30 SECONDS
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = -30
	//pixel_y = 18
	//pixel_z = -48
	plane = FLOOR_PLANE
	layer = ABOVE_CLEANABLES_LAYER
	//greyscale_config = /datum/greyscale_config/heretic_rune
	/// We only set this state after setting the colour, otherwise the animation doesn't colour correctly
	var/animation_state = "transmutation_rune_draw_colour"


/obj/effect/temp_visual/drawing_heretic_rune/Initialize(mapload, path_colour = COLOR_WHITE)
	. = ..()
	add_atom_colour(path_colour, FIXED_COLOUR_PRIORITY)
	icon_state = animation_state
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)


/obj/effect/temp_visual/drawing_heretic_rune/fast
	duration = 12 SECONDS
	animation_state = "transmutation_rune_fast_colour"


/obj/effect/temp_visual/drawing_heretic_rune/fail
	duration = 0.25 SECONDS
	animation_state = "transmutation_rune_fail_colour"
