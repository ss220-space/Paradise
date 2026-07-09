/**
 * Adding this element to an atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first paramter; if not set it defaults to rust_overlay's rust_default
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	if(rust_icon && !rust_overlay)
		rust_overlay = image(rust_icon, rust_icon_state)

	ADD_TRAIT(target, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(handle_examine))
	// master220 emits COMSIG_ATOM_ATTACKBY (from /atom/attackby) when struck with an item; the old
	// COMSIG_ATOM_ATTACK is never sent, so the tile-block + sharp-scrape were dead.
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(on_interaction))
	// Burn the rust off on the SECONDARY (right-click) weld, exactly like tg. This keeps the PRIMARY weld
	// free for /datum/component/torn_wall (which a rust-construction wall also has) - so LMB-welding a rust
	// wall repairs/handles the torn wall, while RMB-welding burns the rust off. No more fighting over the act.
	RegisterSignal(target, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welder_act))
	// NOTE: space-cola / acid removal is NOT done via a signal here. master220 only fires
	// COMSIG_ATOM_EXPOSE_REAGENTS from /atom/water_act (water only, and with a different arg layout), so it
	// never reached us for a splashed drink. Instead the reagents themselves strip rust in their
	// reaction_turf()/reaction_obj() (see space_cola / acid), calling /atom/proc/clean_rust().
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_appearance()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(source, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER))
	REMOVE_TRAIT(source, TRAIT_RUSTY, ELEMENT_TRAIT(type))
	source.update_appearance()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/atom/atom = source
	examine_text += span_notice("[DECLENT_RU_CAP(atom, NOMINATIVE)] очень ржав[GEND_YI_AYA_OE_YE(atom)]. Ржавчину, вероятно, можно <i>сжечь</i> или <i>соскрести</i>.")

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(rust_overlay)
		overlays += rust_overlay

/// Burning the rust off with a welder (right-click / secondary act). do_after sleeps, so defer via async.
/datum/element/rust/proc/on_welder_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, item)
	return ITEM_INTERACT_BLOCKING

/// We call this from the tool/attack hooks because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	if(item.tool_behaviour == TOOL_WELDER)
		if(!item.tool_start_check(user, amount=1))
			return

		user.balloon_alert(user, "сжигание ржавчины...")
		if(!item.use_tool(source, user, 5 SECONDS))
			return

		user.balloon_alert(user, "ржавчина сожжена")
		// Burning the eldritch rust off kicks up acrid corrosion - the welder catches a dose of disgust.
		if(isliving(user))
			var/mob/living/burner = user
			burner.Disgust(20)
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

/// Strips heretic/standard rust off an atom (used when it's doused with space cola or acid - see those
/// reagents' reaction_turf()/reaction_obj()). RemoveElement matches the no-arg AddElement call rust_turf
/// makes, so this triggers the element's Detach (overlay/trait/glowing-rune cleanup) properly.
/atom/proc/clean_rust()
	if(!HAS_TRAIT(src, TRAIT_RUSTY))
		return FALSE
	RemoveElement(/datum/element/rust/heretic)
	RemoveElement(/datum/element/rust)
	return TRUE

/// Blocks tiling over rusted plating, and lets a sharp tool scrape the rust off.
/datum/element/rust/proc/on_interaction(atom/source, obj/item/tool, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(istype(tool, /obj/item/stack/tile) || istype(tool, /obj/item/stack/rods))
		user.balloon_alert(user, "пол заржавел!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	// A sharp tool scrapes the rust off (handle_tool_use sleeps via do_after, so defer it).
	if(tool?.sharp)
		INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, tool)
		return COMPONENT_CANCEL_ATTACK_CHAIN

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
