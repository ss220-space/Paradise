/datum/component/cleave_attack
	/// We can toggle the component ON and OFF with item action, by default its ON
	var/toggled = TRUE
	var/datum/action/item_action/toggle_cleave_attack/toggle_action
	/// Size of the attack arc in degrees
	var/arc_size
	/// Make this TRUE for two-handed weapons like axes
	var/requires_wielded
	/// How much slower is it to swing
	var/swing_speed_mod
	/// How much player will be slowed after swing
	var/afterswing_slowdown
	/// For how long slowdown will be applied
	var/slowdown_duration
	/// Which effect should this use
	var/cleave_effect
	/// Whether this item is disallowed from hitting more than one target
	var/no_multi_hit
	/// Which sound will be played on swing
	var/swing_sound
	/// Callback when the cleave attack is finished
	var/datum/callback/cleave_end_callback


/datum/component/cleave_attack/Initialize(
		arc_size = 90,
		swing_speed_mod = 1.5, // default cleave attack is 50% slower than regular
		afterswing_slowdown = 0.2,
		slowdown_duration = 0.5 SECONDS,
		requires_wielded = FALSE,
		no_multi_hit = FALSE,
		datum/callback/cleave_end_callback,
		swing_sound = SFX_GENERIC_SWING_LIGHT, // Pass it in format 'sound/weapons/sound_name.ogg' or look into /proc/get_sfx(soundin)
		cleave_effect,
		...
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.arc_size = arc_size
	src.swing_speed_mod = swing_speed_mod
	src.afterswing_slowdown = afterswing_slowdown
	src.slowdown_duration = slowdown_duration
	src.requires_wielded = requires_wielded
	src.no_multi_hit = no_multi_hit
	src.cleave_end_callback = cleave_end_callback
	src.swing_sound = swing_sound
	set_cleave_effect(cleave_effect) // set it based on arc size if an effect wasn't specified

	var/obj/item/parent_item = parent
	toggle_action = new /datum/action/item_action/toggle_cleave_attack(parent_item)


/datum/component/cleave_attack/InheritComponent(
		datum/component/C,
		i_am_original,
		arc_size,
		swing_speed_mod,
		afterswing_slowdown,
		slowdown_duration,
		requires_wielded,
		no_multi_hit,
		datum/callback/cleave_end_callback,
		swing_sound,
		cleave_effect,
	)

	if(!i_am_original)
		return
	if(arc_size)
		src.arc_size = arc_size
	if(swing_speed_mod)
		src.swing_speed_mod = swing_speed_mod
	if(afterswing_slowdown)
		src.afterswing_slowdown = afterswing_slowdown
	if(slowdown_duration)
		src.slowdown_duration = slowdown_duration
	if(requires_wielded)
		src.requires_wielded = requires_wielded
	if(no_multi_hit)
		src.no_multi_hit = no_multi_hit
	if(cleave_end_callback)
		src.cleave_end_callback = cleave_end_callback
	if(swing_sound)
		src.swing_sound = swing_sound
	set_cleave_effect(cleave_effect)


/// Sets the cleave effect to the specified effect, or based on arc size if one wasn't specified.
/datum/component/cleave_attack/proc/set_cleave_effect(new_effect)
	if(new_effect)
		cleave_effect = new_effect
		return
	switch(arc_size)
		if(0 to 120)
			cleave_effect = /obj/effect/temp_visual/dir_setting/firing_effect/sweep_attack
		if(120 to 240)
			cleave_effect = /obj/effect/temp_visual/dir_setting/firing_effect/sweep_attack/semicircle
		else
			cleave_effect = /obj/effect/temp_visual/dir_setting/firing_effect/sweep_attack/full_circle


/datum/component/cleave_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_TOGGLE_CLEAVE_ATTACK, PROC_REF(on_toggle_cleave_attack))


/datum/component/cleave_attack/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_AFTERATTACK, COMSIG_TOGGLE_CLEAVE_ATTACK))


/datum/component/cleave_attack/proc/on_examine(atom/examined_item, mob/user, list/examine_list)
	var/arc_desc
	switch(arc_size)
		if(0 to 90)
			arc_desc = "по узкой дуге перед собой"
		if(90 to 180)
			arc_desc = "по широкой дуге перед собой"
		if(180 to 270)
			arc_desc = "по очень широкой дуге перед собой"
		if(270 to INFINITY)
			arc_desc = "в радиусе вокруг себя"
	examine_list += "Этим можно размахивать [arc_desc]."


/datum/component/cleave_attack/proc/on_afterattack(obj/item/item, atom/target, mob/user, proximity_flag, click_parameters)
	if(!toggled)
		return

	if(proximity_flag || user.a_intent != INTENT_HARM)
		return // don't sweep on precise hits or non-harmful intents

	if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		to_chat(user, span_warning("Вы не хотите никому вредить."))
		return

	perform_sweep(item, target, user, click_parameters)


/datum/component/cleave_attack/proc/on_toggle_cleave_attack()
	toggled = !toggled


/datum/component/cleave_attack/proc/perform_sweep(obj/item/item, atom/target, mob/living/user, params)
	if(user.next_move > world.time)
		return // don't spam it

	if(requires_wielded && !HAS_TRAIT(item, TRAIT_WIELDED))
		return // if it needs to be wielded, check to make sure it is

	if(istype(item, /obj/item/melee/energy))
		var/obj/item/melee/energy/energy
		energy = item
		if(energy.active == FALSE)
			return

	// some information we're going to need later
	var/turf/user_turf = get_turf(user)
	var/turf/center_turf = get_turf_in_angle(get_angle(user, target), user_turf)
	var/facing_dir = get_dir(user, center_turf)
	// left hand swing - clockwise, right hand - counter clockwise
	var/swing_direction = user.hand == ACTIVE_HAND_LEFT ? -1 : 1

	// make a list of turfs to swing across
	var/list/turf_list = list()
	var/turfs_count = round(arc_size / 90, 1)
	for(var/i in -min(turfs_count, 3) to min(turfs_count, 4)) // do NOT hit the same tile more than once
		turf_list.Add(get_step(user_turf, turn(facing_dir, i * 45 * swing_direction)))

	// do some effects so everyone knows you're swinging a weapon
	playsound(item, swing_sound, 40, FALSE)
	new cleave_effect(user_turf, facing_dir)

	// now swing across those turfs
	ADD_TRAIT(item, TRAIT_CLEAVING, UNIQUE_TRAIT_SOURCE(src))
	for(var/turf/turf as anything in turf_list)
		if(hit_atoms_on_turf(item, target, user, turf, params))
			break
	REMOVE_TRAIT(item, TRAIT_CLEAVING, UNIQUE_TRAIT_SOURCE(src))

	// do these last so they don't get overridden during the attack loop
	add_attack_logs(user, "Performed swing attack with [item]", ATKLOG_MOST)
	cleave_end_callback?.Invoke(item, user)
	user.do_attack_animation(center_turf, no_effect = TRUE)
	user.changeNext_move(item.attack_speed * swing_speed_mod)
	user.apply_afterswing_slowdown(user, afterswing_slowdown, slowdown_duration)


/// Hits all possible atoms on a turf, returns TRUE if the swing should end early
/datum/component/cleave_attack/proc/hit_atoms_on_turf(obj/item/item, atom/target, mob/living/user, turf/hit_turf, params)
	for(var/atom/movable/hit_atom in hit_turf)
		if(hit_atom == user || hit_atom == target)
			continue // why are you hitting yourself

		if(!(SEND_SIGNAL(hit_atom, COMSIG_ATOM_CLEAVE_ATTACK, item, user) & ATOM_ALLOW_CLEAVE_ATTACK))
			if(hit_atom.pass_flags & LETPASSTHROW)
				continue // if you can throw something over it, you can swing over it too

			if(isliving(hit_atom) && HAS_TRAIT(hit_atom, TRAIT_DWARF)) // cant hit smol people with swing
				continue

			if(!hit_atom.density)
				continue

		item.melee_attack_chain(user, hit_atom, params)
		if(no_multi_hit && isliving(hit_atom))
			return TRUE

	return FALSE


/datum/component/cleave_attack/Destroy(force)
	cleave_end_callback = null
	if(toggle_action)
		QDEL_NULL(toggle_action)
	return ..()
