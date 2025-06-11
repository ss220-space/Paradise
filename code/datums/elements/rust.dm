/**
 * Adding this element to an atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first paramter; if not set it defaults to rust_overlay's rust_default
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	if(!rust_overlay)
		rust_overlay = image(rust_icon, rust_icon_state)

	ADD_TRAIT(target, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal (target, COMSIG_ATOM_ATTACK, PROC_REF(on_interaction))
	RegisterSignal(target, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_reagent_expose))
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_ATOM_ATTACK)
	UnregisterSignal(source, COMSIG_ATOM_EXPOSE_REAGENTS)
	REMOVE_TRAIT(source, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/atom/atom = source
	examine_text += span_notice("[atom.declent_ru(NOMINATIVE)] очень ржав[genderize_ru(atom.gender, "ый", "ая", "ое", "ые")]. Ржавчину, вероятно, можно <i>сжечь</i> или <i>соскрести</i>.")

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(rust_overlay)
		overlays += rust_overlay

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, item)
	return ATTACK_CHAIN_BLOCKED

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WELDER)
		if(!item.tool_start_check(user, amount=1))
			return

		user.balloon_alert(user, "сжигание ржавчины...")
		if(!item.use_tool(source, user, 5 SECONDS))
			return

		user.balloon_alert(user, "ржавчина сожжена")
		Detach(source)
		return

	if(!item.sharp)
		return

	if(!item.tool_start_check(user))
		return

	user.balloon_alert(user, "счистка ржавчины...")
	if(!item.use_tool(source, user, 2 SECONDS))
		return

	user.balloon_alert(user, "ржавчина счищена")
	Detach(source)

///Immediately removes rust if exposed to space cola.
/datum/element/rust/proc/on_reagent_expose(atom/source, datum/reagents/reagents_splashed, methods, reac_volume)
	SIGNAL_HANDLER

	if(!(methods & REAGENT_TOUCH))
		return

	var/has_antirust = FALSE
	for(var/datum/reagent/reagent in reagents_splashed.reagent_list)
		if(!isspacecola(reagent) && !isacid(reagent))
			continue

		has_antirust = TRUE
		break

	if(!has_antirust)
		return

	Detach(source)

/// Prevents placing floor tiles on rusted turf
/datum/element/rust/proc/on_interaction(datum/source, mob/user, obj/item/tool, modifiers)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods))
		user.balloon_alert(user, "пол заржавел!")
		return ATTACK_CHAIN_BLOCKED

/// For rust applied by heretics
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return .

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)

	for(var/mob/living/victim in source)
		victim.remove_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return

	var/mob/living/victim = entered
	if(isheretic(victim))
		return

	if(victim.can_block_magic(MAGIC_RESISTANCE))
		return

	victim.apply_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return

	var/mob/living/leaver = gone
	leaver.remove_status_effect(/datum/status_effect/rust_corruption)
