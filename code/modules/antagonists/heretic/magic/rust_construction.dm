/obj/effect/proc_holder/spell/pointed/rust_construction
	name = "Ржавая Постройка"
	desc = "Превращает ржавый пол в сплошную стену ржавчины. Создание стены под врагом нанесёт ему вред."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	// Rust Formation's button is actions_spells.dmi "shield" (NOT actions.dmi "shield", which is a
	// completely different blue badge).
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "shield"
	// The button's background is backgrounds.dmi (bg_heretic), which has NO "targeting" state, so the default
	// targeting frame never drew. backgrounds.dmi DOES have bg_spell_border_active_red - the red active frame
	// the ability is supposed to show while armed. Point the targeting overlay at it.
	action_targeting_overlay = "bg_spell_border_active_red"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	//check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	// Rust Formation is a toggle on a short cooldown: you keep the click ability armed and raise a wall
	// every couple seconds. See should_remove_click_intercept below.
	base_cooldown = 2 SECONDS

	// Both of these are changed in before_cast
	invocation = "Это баг."
	//invocation_self_message = "You raise a wall of rust."
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	cast_range = 4

	/// How long does the filter last on walls we make?
	var/filter_duration = 2 MINUTES


/// Overrides 'aim assist' because we always want to hit just the turf we clicked on.
/obj/effect/proc_holder/spell/pointed/rust_construction/aim_assist(mob/living/clicker, atom/target)
	return get_turf(target)

// Toggleable: keep the click ability armed after each cast so the heretic can raise several walls in a
// row. Click the ability button again to disarm it.
/obj/effect/proc_holder/spell/pointed/rust_construction/should_remove_click_intercept(mob/user)
	return FALSE


// Make the throw-target cursor STICKY while the ability is armed. The spell system only sets
// client.mouse_pointer_icon, but update_mouse_pointer() (run on every movement keypress - see
// bindings_client.dm) wipes that straight back to the default, which is why the red "hand" cursor
// vanished the moment you walked. mouse_override_icon is the persistent slot update_mouse_pointer() always
// re-applies (the same one mechs / the ninja katana use), so the cursor now survives moving and running.
// on_activation/on_deactivation are the pointed-spell hooks fired when the click ability is armed/disarmed.
/obj/effect/proc_holder/spell/pointed/rust_construction/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return
	var/client/our_client = on_who?.client
	if(our_client)
		our_client.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()


/obj/effect/proc_holder/spell/pointed/rust_construction/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	var/client/our_client = on_who?.client
	// Only clear the override if it's still OURS (don't stomp a mech / throw-mode cursor that took over).
	if(our_client && our_client.mouse_override_icon == ranged_mousepointer)
		our_client.mouse_override_icon = null
		on_who.update_mouse_pointer()


/obj/effect/proc_holder/spell/pointed/rust_construction/valid_target(atom/cast_on)
	if(!isturf(cast_on))
		cast_on.balloon_alert(action.owner, "не стена или пол!")
		return FALSE

	if(HAS_TRAIT(cast_on, TRAIT_RUSTY))
		return TRUE

	if(!action.owner)
		return FALSE

	cast_on.balloon_alert(action.owner, "нет ржавчины!")
	return FALSE

/*
/obj/effect/proc_holder/spell/pointed/rust_construction/before_cast(turf/spacecast_on)
	. = ..()
	if(!isliving(action.owner))
		return

	var/mob/living/living_owner = action.owner
	invocation = span_danger("<b>[action.owner]</b> drags [action.owner.p_their()] hand[living_owner.usable_hands == 1 ? "":"s"] upwards as a wall of rust rises out of [cast_on]!")
	invocation_self_message = span_notice("You drag [living_owner.usable_hands == 1 ? "a hand":"your hands"] upwards as a wall of rust rises out of [cast_on].")
*/

/obj/effect/proc_holder/spell/pointed/rust_construction/cast(list/targets, mob/user = usr)
	var/turf/cast_on = targets[1]
	// The /spell_targeting/clicked_atom datum these pointed spells use does NOT call valid_target(), so
	// the rust requirement has to be enforced here or walls could be raised on any tile. Refund the
	// cooldown on a bad target so an off-rust misclick doesn't punish the (now toggleable) ability.
	if(!isturf(cast_on) || !HAS_TRAIT(cast_on, TRAIT_RUSTY))
		cast_on?.balloon_alert(user, "нет ржавчины!")
		cooldown_handler.revert_cast()
		return
	. = ..()
	var/rises_message = "поднимается из [cast_on.declent_ru(GENITIVE)]"

	// Casting at a (rusty - enforced above) wall crumbles it. The old port leaned on a side effect of
	// /turf/simulated/wall/rust_turf() dismantling an already-rusted wall, but that override was removed so
	// ambient rust spread no longer shreds walls - so the spell now dismantles the wall itself. This is how
	// the heretic tears down their own rust walls (and any wall they've rusted) with Rust Formation.
	if(iswallturf(cast_on))
		cast_on.visible_message(span_warning("[DECLENT_RU_CAP(cast_on, NOMINATIVE)] содрогается под давлением быстро растущей ржавчины!"))
		cast_on.Shake(/*shake_interval = 0.1 SECONDS, */duration = 0.5 SECONDS)
		playsound(cast_on, 'sound/effects/bang.ogg', 50, vary = TRUE)
		var/turf/simulated/wall/wall = cast_on
		wall.dismantle_wall()
		return

	var/turf/simulated/wall/new_wall = cast_on.ChangeTurf(/turf/simulated/wall)
	if(!istype(new_wall))
		return

	playsound(new_wall, 'sound/effects/constructform.ogg', 50, TRUE)
	new_wall.rust_heretic_act()
	new_wall.name = "зачарованн[GEND_YI_AYA_OE_YE(new_wall)] [new_wall.name]"
	new_wall.AddComponent(/datum/component/torn_wall)
	new_wall.AddComponent(/datum/component/rust_construction_wall)
	new_wall.hardness = 60
	new_wall.sheet_amount = 0
	new_wall.girder_type = null

	// I wanted to do a cool animation of a wall raising from the ground
	// but I guess a fading filter will have to do for now as walls have 0 depth (currently)
	// damn though with 3/4ths walls this'll look sick just imagine it
	new_wall.add_filter("rust_wall", 2, list("type" = "outline", "color" = "#85be299c", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(fade_wall_filter), new_wall), filter_duration * 0.5)
	addtimer(CALLBACK(src, PROC_REF(remove_wall_filter), new_wall), filter_duration)

	var/message_shown = FALSE
	for(var/mob/living/living_mob in cast_on)
		message_shown = TRUE
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == action.owner)
			living_mob.visible_message(
				span_warning("[DECLENT_RU_CAP(new_wall, NOMINATIVE)] [rises_message] и отталкивает [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_notice("[DECLENT_RU_CAP(new_wall, NOMINATIVE)] [rises_message] и отталкивает вас!"),
			)
		else
			living_mob.visible_message(
				span_warning("[DECLENT_RU_CAP(new_wall, NOMINATIVE)] [rises_message] и врезается в [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[DECLENT_RU_CAP(new_wall, NOMINATIVE)] [rises_message] под вами, раня вас!"),
			)
			living_mob.apply_damage(10, BRUTE/*, wound_bonus = 10*/)
			living_mob.Knockdown(5 SECONDS)

		living_mob.SpinAnimation(5, 1)

		// If we're a multiz map send them to the next floor
		var/turf/above_us = get_step_multiz(cast_on, UP)
		if(above_us)
			living_mob.forceMove(above_us)
			continue

		// If we're not throw them to a nearby (open) turf
		var/list/turfs_by_us = get_adjacent_open_turfs(cast_on)
		// If there is no side by us, hardstun them
		if(!length(turfs_by_us))
			living_mob.Paralyse(5 SECONDS)
			continue

		// If there's an open turf throw them to the side
		living_mob.throw_at(pick(turfs_by_us), 1, 3, thrower = action.owner, spin = FALSE)

	if(!message_shown)
		new_wall.visible_message(span_warning("\A [new_wall] [rises_message]!"))


/obj/effect/proc_holder/spell/pointed/rust_construction/proc/fade_wall_filter(turf/simulated/wall/wall)
	if(QDELETED(wall))
		return

	var/rust_filter = wall.get_filter("rust_wall")
	if(!rust_filter)
		return

	animate(rust_filter, alpha = 0, time = filter_duration * (9/20))


/obj/effect/proc_holder/spell/pointed/rust_construction/proc/remove_wall_filter(turf/simulated/wall/wall)
	if(QDELETED(wall))
		return

	wall.remove_filter("rust_wall")


// Added (alongside /datum/component/torn_wall) to walls raised by Rust Formation. Handles two things the
// base rust element and torn_wall don't:
//  - If the wall is still rusty when it's removed (e.g. the heretic crumbles it with the spell again),
//    the floor left behind STAYS rusty - the rust soaks back into the ground instead of vanishing with
//    the wall. Burning the rust off first (RMB weld) and then tearing the wall down leaves clean floor.
//  - Lets the wall be torn down with a welder on RIGHT-click once its rust has been burned off. LMB weld
//    stays the torn_wall repair; RMB weld on a de-rusted wall dismantles it for nothing (0 sheets / no
//    girder), matching the order the heretic uncreates their own walls.
/datum/component/rust_construction_wall
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/rust_construction_wall/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(on_turf_changed))
	RegisterSignal(parent, COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER), PROC_REF(on_welder_secondary))

/datum/component/rust_construction_wall/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_TURF_CHANGE,
		COMSIG_ATOM_SECONDARY_TOOL_ACT(TOOL_WELDER),
	))

/// When a still-rusty wall turns into another turf, re-rust whatever floor is left behind. We can't touch
/// the new turf here (it doesn't exist yet, and we're about to be deleted with the old one), so we queue a
/// post-change callback - ChangeTurf runs those with the freshly created turf as their argument.
/datum/component/rust_construction_wall/proc/on_turf_changed(turf/source, path, list/post_change_callbacks)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_RUSTY))
		return
	post_change_callbacks += CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(rust_construction_rerust_turf))

/// Right-click weld. While the wall is still rusty, leave it to the rust element (its secondary weld burns
/// the rust off). Once the rust is gone, a second right-click weld tears the wall down.
/datum/component/rust_construction_wall/proc/on_welder_secondary(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_RUSTY))
		return
	INVOKE_ASYNC(src, PROC_REF(dismantle_with_welder), source, user, item)
	return ITEM_INTERACT_BLOCKING

/// do_after sleeps, so this is deferred from the signal handler.
/datum/component/rust_construction_wall/proc/dismantle_with_welder(turf/simulated/wall/source, mob/user, obj/item/item)
	if(!item.tool_start_check(source, user, amount = 1))
		return
	source.balloon_alert(user, "разборка стены...")
	if(!item.use_tool(source, user, 4 SECONDS))
		return
	if(!iswallturf(source))
		return
	source.balloon_alert(user, "стена разобрана")
	source.dismantle_wall()

/// Re-applies heretic rust to the floor left behind by a removed (still-rusty) rust-construction wall.
/proc/rust_construction_rerust_turf(turf/new_turf)
	if(isfloorturf(new_turf))
		new_turf.rust_heretic_act()
