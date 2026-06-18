/obj/effect/proc_holder/spell/pointed/rust_construction
	name = "Ржавая постройка"
	desc = "Превращает ржавый пол в сплошную стену ржавчины. Создание стены под врагом нанесёт ему вред."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	// tg's Rust Formation button is actions_spells.dmi "shield" (NOT actions.dmi "shield", which is a
	// completely different blue badge in master220). action_spells.dmi is copied 1:1 from tg for this.
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "shield"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	//check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	// TG's Rust Formation is a toggle (unset_after_click = FALSE) on a short cooldown: you keep the
	// click ability armed and raise a wall every couple seconds. See should_remove_click_intercept below.
	base_cooldown = 2 SECONDS

	// Both of these are changed in before_cast
	invocation = "Кто-то возводит стену ржавчины."
	//invocation_self_message = "You raise a wall of rust."
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	cast_range = 4

	/// How long does the filter last on walls we make?
	var/filter_duration = 2 MINUTES


/**
 * Overrides 'aim assist' because we always want to hit just the turf we clicked on.
 */
/obj/effect/proc_holder/spell/pointed/rust_construction/aim_assist(mob/living/clicker, atom/target)
	return get_turf(target)

// Toggleable: keep the click ability armed after each cast (TG's unset_after_click = FALSE) so the
// heretic can raise several walls in a row. Click the ability button again to disarm it.
/obj/effect/proc_holder/spell/pointed/rust_construction/should_remove_click_intercept(mob/user)
	return FALSE


// While the ability is armed, re-assert the throw-target cursor whenever the caster moves. BYOND resets
// client.mouse_pointer_icon to default on movement/perspective changes, which is why the "hand" cursor
// vanished after a step. on_activation/on_deactivation are the pointed-spell hooks fired on arm/disarm.
/obj/effect/proc_holder/spell/pointed/rust_construction/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return
	RegisterSignal(on_who, COMSIG_MOVABLE_MOVED, PROC_REF(reassert_cursor), override = TRUE)


/obj/effect/proc_holder/spell/pointed/rust_construction/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(on_who)
		UnregisterSignal(on_who, COMSIG_MOVABLE_MOVED)


// Re-apply the cursor DIRECTLY rather than via add_mousepointer(): for pointed spells add_mousepointer()
// also calls on_activation(), which to_chat()s the "You prepare to use..." line - doing that on every
// single step is the chat spam. Setting mouse_pointer_icon here keeps the hand without re-announcing.
/obj/effect/proc_holder/spell/pointed/rust_construction/proc/reassert_cursor(mob/source)
	SIGNAL_HANDLER
	if(source != ranged_ability_user)
		return
	var/client/our_client = source.client
	if(our_client && ranged_mousepointer && our_client.mouse_pointer_icon != ranged_mousepointer)
		our_client.mouse_pointer_icon = ranged_mousepointer


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

	// If we casted at a wall we'll try to rust it. In the case of an enchanted wall it'll deconstruct it
	if(iswallturf(cast_on))
		cast_on.visible_message(span_warning("[cast_on.declent_ru(NOMINATIVE)] содрагается под давлением быстро растущей ржавчины!"))
		var/mob/living/living_owner = action.owner
		living_owner?.do_rust_heretic_act(cast_on)
		// ref transfers to floor
		cast_on.Shake(/*shake_interval = 0.1 SECONDS, */duration = 0.5 SECONDS)
		// which we need to re-rust
		living_owner?.do_rust_heretic_act(cast_on)
		playsound(cast_on, 'sound/effects/bang.ogg', 50, vary = TRUE)
		return

	var/turf/simulated/wall/new_wall = cast_on.ChangeTurf(/turf/simulated/wall)
	if(!istype(new_wall))
		return

	playsound(new_wall, 'sound/effects/constructform.ogg', 50, TRUE)
	new_wall.rust_heretic_act()
	new_wall.name = "зачарованн[genderize_ru(new_wall.gender, "ый", "ая", "ое", "ые")] [new_wall.name]"
	new_wall.AddComponent(/datum/component/torn_wall)
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
				span_warning("[new_wall] [rises_message] и отталкивает [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_notice("[new_wall] [rises_message] и отталкивает вас!"),
			)
		else
			living_mob.visible_message(
				span_warning("[new_wall] [rises_message] и врезается в [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[new_wall] [rises_message] под вами, раня вас!"),
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
