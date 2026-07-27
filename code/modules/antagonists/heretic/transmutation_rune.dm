/// Bakes a single coloured, animated icon for a heretic rune state, replicating TG's GAGS
/// heretic_rune.json by hand (master220 has no GAGS compositing on atoms).
/// * [colour_state] - the greyscale linework state. It is multiplied by [rune_colour], so white
///   pixels take the full path colour and darker pixels a darker shade, matching GAGS' color_ids.
/// * [white_state] - optional matching linework overlaid untinted on top, so the bright "pen"
///   accents stay white (the second, uncoloured GAGS layer).
/// * [draw_duration] / [native_delays] - when both are set, the draw-in animation is re-timed so its
///   frames (the actual drawing frames in [native_delays], excluding the trailing "hold" frame) play
///   across exactly [draw_duration] deciseconds. The source states are authored ~12s/~24s long, so a faster
///   codex (Codex Morbus draws in 5s) would otherwise cut the animation off partway through.
///   The source frames have deliberately uneven delays (quick pen strokes punctuated by long pauses).
///   Flattening them to one uniform delay turns the draw into a low-fps slideshow, so instead we keep each
///   frame's authored delay and scale them all by the same factor, landing on [draw_duration] while keeping
///   fast strokes fast and only stretching/shrinking the pauses.
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
		timed.Insert(icon(composite, "", SOUTH, i), "", SOUTH, i, FALSE, max(native_delays[i] * scale, 0.5))
	return timed


/// The heretic's rune, which they use to complete transmutation rituals.
/obj/effect/decal/heretic_rune
	name = "transmutation rune"
	desc = "Жуткий круг непонятных маслянисто-чёрных знаков и рун, выгравированный на полу."
	icon = 'icons/obj/rune.dmi'
	icon_state = "main1"
	plane = BELOW_GAME_PLANE
	layer = ABOVE_CLEANABLES_LAYER
	///Used mainly for summoning ritual to prevent spamming the rune to create millions of monsters.
	var/is_in_use = FALSE


/obj/effect/decal/heretic_rune/get_ru_names()
	return alist(
		NOMINATIVE = "руна трансформации",
		GENITIVE = "руны трансформации",
		DATIVE = "руне трансформации",
		ACCUSATIVE = "руну трансформации",
		INSTRUMENTAL = "руной трансформации",
		PREPOSITIONAL = "руне трансформации"
	)


/obj/effect/decal/heretic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "heretic_rune", silicon_image)
	ADD_TRAIT(src, TRAIT_MOPABLE, INNATE_TRAIT)


/obj/effect/decal/heretic_rune/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Позволяет трансмутировать предметы, после соблюдения некоторых условий.")
	. += span_notice("Вы можете использовать <i>хватку Обители</i> на руне, чтобы стереть её.")


/obj/effect/decal/heretic_rune/proc/can_interact(mob/living/user)
	if(!IS_HERETIC(user))
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
		user.balloon_alert(user, "руна стёрта")
		qdel(src)
		return ATTACK_CHAIN_PROCEED

	if(istype(item, /obj/item/codex_cicatrix))
		return ..()

	. = ..()
	INVOKE_ASYNC(src, PROC_REF(try_rituals), user)
	return ATTACK_CHAIN_PROCEED


/// Attempt to begin a ritual, giving them an input list to choose from. Also ensures is_in_use is enabled
/// and disabled before and after.
/obj/effect/decal/heretic_rune/proc/try_rituals(mob/living/user)
	is_in_use = TRUE

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/list/rituals = heretic_datum.get_rituals()
	if(!length(rituals))
		loc.balloon_alert(user, "нет доступных ритуалов!")
		is_in_use = FALSE
		return

	var/static/list/ritual_images = list()
	var/list/ritual_radial = list()
	for(var/ritual_name in rituals)
		var/datum/heretic_knowledge/ritual = rituals[ritual_name]
		var/ritual_info = ""
		var/list/ritual_requirements = list()
		for(var/req_type in ritual.required_atoms)
			if(islist(req_type))
				var/list/req_type_list = req_type
				var/list/req_text_list = list()
				for(var/atom/possible_type as anything in req_type_list)
					req_text_list += ritual.parse_required_item(possible_type, 1)
				ritual_requirements += russian_list(req_text_list, and_text = " или ")

			else
				ritual_requirements += ritual.parse_required_item(req_type, ritual.required_atoms[req_type])

		if(length(ritual_requirements))
			ritual_info = "Требуется: [russian_list(ritual_requirements)]"

		var/image/ritual_image = ritual_images[ritual.type]
		if(!ritual_image)
			var/list/ritual_icon_info = heretic_datum.get_icon_of_knowledge(ritual.type)
			var/list/tree_entry = GLOB.heretic_research_tree[ritual.type]
			ritual_image = image(icon(ritual_icon_info["icon"], ritual_icon_info["state"], ritual_icon_info["dir"], ritual_icon_info["frame"]))
			ritual_image.underlays += image(icon = 'icons/ui_icons/antags/heretic/knowledge.dmi', icon_state = tree_entry ? tree_entry[HKT_UI_BGR] : BGR_SIDE)
			ritual_images[ritual.type] = ritual_image

		var/datum/radial_menu_choice/choice = new()
		choice.name = ritual.name
		choice.info = ritual_info
		choice.image = ritual_image
		ritual_radial[ritual.name] = choice

	var/chosen = show_radial_menu(user, loc, ritual_radial, radius = 48, require_near = TRUE)
	if(!chosen || !istype(rituals[chosen], /datum/heretic_knowledge) || QDELETED(src) || QDELETED(user) || QDELETED(heretic_datum))
		is_in_use = FALSE
		return

	do_ritual(user, rituals[chosen])
	is_in_use = FALSE


/// Attempt to invoke a ritual from the passed list of knowledges. Returns TRUE if the ritual succeeded,
/// FALSE if it failed.
/obj/effect/decal/heretic_rune/proc/do_ritual(mob/living/user, datum/heretic_knowledge/ritual)

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
	var/list/selected_atoms = list()

	if(!ritual.recipe_snowflake_check(user, atoms_in_range, selected_atoms, loc, TRUE))
		return FALSE

	var/list/requirements_list = ritual.required_atoms.Copy()

	for(var/atom/nearby_atom as anything in atoms_in_range)
		for(var/req_type in requirements_list)
			if(requirements_list[req_type] <= 0)
				continue
			if(islist(req_type) && !is_type_in_list(nearby_atom, req_type))
				continue

			else if(!islist(req_type) && !istype(nearby_atom, req_type))
				continue

			if(length(banned_atom_types) && (nearby_atom.type in banned_atom_types))
				continue

			selected_atoms |= nearby_atom
			if(!isstack(nearby_atom))
				requirements_list[req_type]--
				continue

			var/obj/item/stack/picked_stack = nearby_atom
			requirements_list[req_type] -= picked_stack.amount // Can go negative, but doesn't matter. Negative = fulfilled


	var/list/what_are_we_missing = list()
	for(var/req_type in requirements_list)
		var/fulfilled_amount = requirements_list[req_type]
		if(fulfilled_amount <= 0)
			continue

		if(islist(req_type))
			var/list/req_type_list = req_type
			var/list/req_text_list = list()
			for(var/atom/possible_type as anything in req_type_list)
				req_text_list += ritual.parse_required_item(possible_type, fulfilled_amount)
			what_are_we_missing += russian_list(req_text_list, and_text = "или")

		else
			what_are_we_missing += ritual.parse_required_item(req_type, fulfilled_amount)

	if(length(what_are_we_missing))
		loc.balloon_alert(user, "не хватает компонентов!")
		to_chat(user, span_mansus("Для завершения ритуала \"[ritual.name]\" не хватает [russian_list(what_are_we_missing)]."))
		return FALSE

	ritual_animation()

	var/ritual_result = ritual.on_finished_recipe(user, selected_atoms, loc)

	if(ritual_result)
		ritual.cleanup_atoms(selected_atoms)
		SSblackbox.record_feedback("tally", "heretic_ritual_completed", 1, ritual.type)

	if(ritual_result)
		loc.balloon_alert(user, "ритуал завершён")

	return ritual_result


/obj/effect/decal/heretic_rune/proc/ritual_animation()
	flick("[icon_state]_active", src)
	playsound(src, 'sound/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)


/// A 3x3 heretic rune. The kind heretics actually draw in game.
/obj/effect/decal/heretic_rune/big
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = -30
	/// The path colour this rune is tinted with, kept so the activation animation can match it.
	var/rune_colour = COLOR_WHITE
	/// Per-colour cache of the baked rune icon FILES ("transmutation_rune" static state + its "_active"
	/// animation in ONE icon, like TG's GAGS output). One stable rsc resource per path colour: the rune
	/// displays this file the whole time it exists, so by ritual time every viewer already has it downloaded
	/// and the plain tg-style flick("[icon_state]_active") plays reliably. The old approach - flicking a
	/// SEPARATE baked animation icon - handed the client a brand-new resource at flick time, and the first
	/// ritual raced the download and showed nothing.
	var/static/list/baked_rune_icons = list()


/obj/effect/decal/heretic_rune/big/Initialize(mapload, path_colour)
	. = ..()
	if(path_colour)
		rune_colour = path_colour

	var/icon/baked = baked_rune_icons[rune_colour]
	if(!baked)
		var/icon/combined = new
		combined.Insert(heretic_rune_icon(icon, "transmutation_rune", rune_colour), "transmutation_rune")
		combined.Insert(heretic_rune_icon(icon, "transmutation_rune_activate_colour", rune_colour, "transmutation_rune_activate_white"), "transmutation_rune_active")
		baked = fcopy_rsc(combined)
		baked_rune_icons[rune_colour] = baked
	icon = baked
	icon_state = "transmutation_rune"


/obj/effect/temp_visual/drawing_heretic_rune
	duration = 30 SECONDS
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = -30
	plane = FLOOR_PLANE
	layer = ABOVE_CLEANABLES_LAYER
	/// The "_colour" linework state baked (with its "_white" companion) into the coloured draw animation.
	var/animation_state = "transmutation_rune_draw_colour"
	/// The per-frame delays of [animation_state]'s draw-in frames - every frame except the trailing "hold"
	/// frame - copied verbatim from icons/effects/96x96.dmi. heretic_rune_icon scales these to the caster's
	/// drawing_time, preserving the authored stroke/pause rhythm so slow draws stay smooth instead of choppy.
	var/list/native_delays = list(1,1,1,1,1,1,1,1,1,25,1,1,1,1,5,1,1,1,25,1,1,1,1,1,1,1,1,1,10,1,1,1,1,1,1,1,1,25,1,1,1,1,1,1,1,1,1,1,1,25,1,1,1,1,1,1,25,1,1,1,1,25,1,1,1,1)


/obj/effect/temp_visual/drawing_heretic_rune/Initialize(mapload, path_colour = COLOR_LIME, drawing_time = 0)
	. = ..()
	if(!path_colour)
		path_colour = COLOR_LIME
	var/source_icon = icon
	var/white_state = replacetext(animation_state, "_colour", "_white")
	var/static/list/baked_draw_icons = list()
	var/cache_key = "[animation_state]/[path_colour]/[drawing_time]"
	var/baked = baked_draw_icons[cache_key]
	if(!baked)
		baked = fcopy_rsc(heretic_rune_icon(source_icon, animation_state, path_colour, white_state, drawing_time, drawing_time > 0 ? native_delays : null))
		baked_draw_icons[cache_key] = baked
	icon = baked
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
