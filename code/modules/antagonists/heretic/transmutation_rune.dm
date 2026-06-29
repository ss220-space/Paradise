/// Bakes a single coloured, animated icon for a heretic rune state, replicating TG's GAGS
/// heretic_rune.json by hand (master220 has no GAGS compositing on atoms).
/// * [colour_state] - the greyscale linework state. It is multiplied by [rune_colour], so white
///   pixels take the full path colour and darker pixels a darker shade — identical to GAGS' color_ids.
/// * [white_state] - optional matching linework overlaid untinted on top, so the bright "pen"
///   accents stay white (the second, uncoloured GAGS layer).
/// * [draw_duration] / [native_delays] - when both are set, the draw-in animation is re-timed so its
///   frames (the ones in [native_delays] — the actual drawing, excluding the trailing "hold" frame) play
///   across exactly [draw_duration] deciseconds. The source states are authored ~12s/~24s long, so a faster
///   codex (Codex Morbus draws in 5s) would otherwise place the rune at ~40% drawn — the "skip" the
///   animation is reported as not keeping up with.
///   IMPORTANT: the source frames have deliberately UNEVEN delays (quick pen strokes punctuated by long
///   pauses). Flattening them to one uniform delay turns the draw into a low-fps slideshow that reads as
///   "laggy" on the slower draws (pen / Codex of Torture). Instead we keep each frame's authored delay and
///   scale them all by the same factor, so the fast strokes stay fast (smooth) and only the pauses stretch
///   or shrink to make the whole thing land on [draw_duration].
/proc/heretic_rune_icon(icon_file, colour_state, rune_colour, white_state, draw_duration = 0, list/native_delays)
	var/icon/composite = icon(icon_file, colour_state)
	composite.Blend(rune_colour, ICON_MULTIPLY)
	if(white_state)
		composite.Blend(icon(icon_file, white_state), ICON_OVERLAY)

	if(draw_duration <= 0 || !length(native_delays))
		return composite

	var/native_total = 0
	for(var/delay in native_delays)
		native_total += delay
	var/scale = draw_duration / native_total

	var/icon/timed = new
	for(var/i in 1 to length(native_delays))
		// Extract by the default state ("") rather than colour_state — icon() resolves "" to the composite's
		// single state regardless of whether the bake preserved its name, so the per-frame copy is reliable.
		timed.Insert(icon(composite, "", SOUTH, i), "", SOUTH, i, FALSE, max(native_delays[i] * scale, 0.5))
	return timed


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
	return alist(
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

	// Codices (Истезания / Морбус) wipe the rune in their own melee_attack_chain (before reaching here);
	// this branch is a safety net so a codex never accidentally pops the ritual menu instead of erasing.
	if(istype(item, /obj/item/codex_cicatrix))
		return ..()

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

	var/list/banned_atom_types = ritual.banned_atom_types.Copy()
	// A list of all atoms we've selected to use in this recipe.
	var/list/selected_atoms = list()

	// Do the snowflake check to see if we can continue or not.
	// selected_atoms is passed and can be modified by this proc.
	if(!ritual.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc, TRUE))
		return FALSE

	// A copy of our requirements list, which we decrement to determine if enough of each key is present.
	// IMPORTANT: copied AFTER recipe_snowflake_check. Some rituals (Unsealed Arts paintings) rewrite their
	// required_atoms inside that proc based on which ingredient is present, and the change persists on the
	// ritual datum. Copying before would carry over the PREVIOUS craft's ingredient, so the next painting
	// would demand the wrong item and fail to craft. Only the painting mutates required_atoms, so for every
	// other ritual this is identical to copying earlier.
	var/list/requirements_list = ritual.required_atoms.Copy()

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
	play_activation_animation()
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


/// Plays the rune's "ritual completed" animation. Overridden by subtypes that need to composite
/// the GAGS-style coloured animation by hand (see [/obj/effect/decal/heretic_rune/big]).
/obj/effect/decal/heretic_rune/proc/play_activation_animation()
	flick("[icon_state]_active", src)


/// A 3x3 heretic rune. The kind heretics actually draw in game.
/obj/effect/decal/heretic_rune/big
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = -30
	//pixel_y = 18
	//pixel_z = -48
	//greyscale_config = /datum/greyscale_config/heretic_rune
	/// The path colour this rune is tinted with, kept so the activation animation can match it.
	var/rune_colour = COLOR_WHITE
	/// Pre-baked, rsc-registered "ritual completed" animation. Baking it lazily inside flick() meant the
	/// very first craft raced the client's download of the freshly-generated icon and showed nothing - the
	/// animation only appeared on later uses once it was cached. Building it once here and registering it in
	/// the rsc (fcopy_rsc) gives it a stable resource the client receives reliably, so the first flick plays.
	var/icon/activation_icon


/obj/effect/decal/heretic_rune/big/Initialize(mapload, path_colour)
	. = ..()
	if(path_colour)
		rune_colour = path_colour

	// master220 has no GAGS, so bake the coloured static rune by hand (multiply greyscale * colour).
	// fcopy_rsc registers each hand-baked icon as a proper resource file (see activation_icon comment).
	var/source_icon = icon
	icon = fcopy_rsc(heretic_rune_icon(source_icon, "transmutation_rune", rune_colour))
	icon_state = ""

	// Composite the two-layer "activate" animation (coloured linework + untinted white pen) up-front.
	activation_icon = fcopy_rsc(heretic_rune_icon(source_icon, "transmutation_rune_activate_colour", rune_colour, "transmutation_rune_activate_white"))


/obj/effect/decal/heretic_rune/big/play_activation_animation()
	flick(activation_icon, src)


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
	/// The "_colour" linework state baked (with its "_white" companion) into the coloured draw animation.
	var/animation_state = "transmutation_rune_draw_colour"
	/// The per-frame delays of [animation_state]'s draw-in frames — every frame EXCEPT the trailing "hold"
	/// frame — copied verbatim from icons/effects/96x96.dmi. heretic_rune_icon scales these to the caster's
	/// drawing_time, preserving the authored stroke/pause rhythm so slow draws stay smooth instead of choppy.
	var/list/native_delays = list(1,1,1,1,1,1,1,1,1,25,1,1,1,1,5,1,1,1,25,1,1,1,1,1,1,1,1,1,10,1,1,1,1,1,1,1,1,25,1,1,1,1,1,1,1,1,1,1,1,25,1,1,1,1,1,1,25,1,1,1,1,25,1,1,1,1)


/obj/effect/temp_visual/drawing_heretic_rune/Initialize(mapload, path_colour = COLOR_LIME, drawing_time = 0)
	. = ..()
	if(!path_colour)
		path_colour = COLOR_LIME
	// master220 has no GAGS set_greyscale on atoms, so we bake TG's heretic_rune.json by hand into a
	// single animated icon (see heretic_rune_icon): the "_colour" linework is multiplied by the path
	// colour (lime for PATH_START, blood-red for ASH, ...) and the matching "_white" pen accents are
	// overlaid untinted on top. Both source states are 67-frame draw-in animations, so the whole rune
	// animates as it's being drawn. drawing_time re-times that draw-in so it finishes exactly when the
	// caster's do_after does (otherwise a fast Codex Morbus draw cuts the ~12s animation off mid-draw).
	var/source_icon = icon
	var/white_state = replacetext(animation_state, "_colour", "_white")
	// fcopy_rsc registers the hand-baked icon as a real resource file so EVERY client receives the draw
	// animation. Without it, the raw in-memory /icon distributes unreliably - the drawer sees the animation
	// but bystanders (and the freshly-joined) often see nothing (same race the big rune's bake comment covers).
	icon = fcopy_rsc(heretic_rune_icon(source_icon, animation_state, path_colour, white_state, drawing_time, drawing_time > 0 ? native_delays : null))
	icon_state = ""
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)


/obj/effect/temp_visual/drawing_heretic_rune/fast
	duration = 12 SECONDS
	animation_state = "transmutation_rune_fast_colour"
	native_delays = list(1,1,1,1,1,1,1,1,1,5,1,1,1,1,5,1,1,1,5,1,1,1,1,1,1,1,1,1,5,1,1,1,1,1,1,1,1,5,1,1,1,1,1,1,1,1,1,1,1,5,1,1,1,1,1,1,25,1,1,1,1,5,1,1,1,1)


/obj/effect/temp_visual/drawing_heretic_rune/fail
	duration = 0.25 SECONDS
	animation_state = "transmutation_rune_fail_colour"
