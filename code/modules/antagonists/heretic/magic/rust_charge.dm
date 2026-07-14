/obj/effect/proc_holder/spell/mob_cooldown/charge/rust
	name = "Заряд Ржавчины"
	desc = "Заклинание, которое необходимо начать стоя на ржавой плитке. \
			После применения вы совершите рывок в выбранную точку. \
			Уничтожит все ржавые предметы, с которыми вы соприкоснётесь. \
			Нанесёт большой урон окружающим и распространит ржавчину."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_items.dmi'
	action_icon_state = "sniper_zoom"
	charge_distance = 10
	charge_damage = 25
	charge_past = 0
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	school = SCHOOL_FORBIDDEN
	/// The human we handed the +100 damage_resistance to while charging, so we only ever remove it once.
	var/mob/living/carbon/human/shielded_owner


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/cast(list/targets, mob/user = usr)
	. = ..()
	var/turf/start_turf = get_turf(action.owner)
	var/turf/target_turf = get_turf(targets[1])
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY) || !istype(target_turf))
		return FALSE

	if(ishuman(action.owner))
		shielded_owner = action.owner
		shielded_owner.physiology.damage_resistance += 100
	RegisterSignal(action.owner, COMSIG_FINISHED_CHARGE, PROC_REF(affect_aoe))
	addtimer(CALLBACK(src, PROC_REF(drop_shield)), 15 SECONDS)

	INVOKE_ASYNC(src, PROC_REF(charge_sequence), action.owner, target_turf, charge_delay, charge_past)
	return TRUE


/// When the charge ends, deal damage + knock down everyone next to us and drop our invulnerability.
/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/proc/affect_aoe()
	SIGNAL_HANDLER
	UnregisterSignal(action.owner, COMSIG_FINISHED_CHARGE)
	for(var/mob/living/nearby_mob in view(1, action.owner))
		if(nearby_mob == action.owner)
			continue
		nearby_mob.apply_damage(charge_damage, BRUTE)
		nearby_mob.Knockdown(5 SECONDS)
	drop_shield()


/// Removes the temporary charge invulnerability. Safe to call more than once (only the shielded owner loses it).
/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/proc/drop_shield()
	if(isnull(shielded_owner))
		return
	shielded_owner.physiology.damage_resistance -= 100
	shielded_owner = null


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/on_move(atom/source, atom/new_loc, atom/target)
	..()
	var/turf/victim = get_turf(action.owner)

	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	victim.rust_heretic_act()
	for(var/dir in GLOB.cardinal)
		var/turf/nearby_turf = get_step(victim, dir)
		if(!istype(nearby_turf))
			continue

		nearby_turf.rust_heretic_act()


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return

	for(var/dir in GLOB.cardinal)
		var/turf/source = get_turf(action.owner)
		var/turf/simulated/wall/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf) || !HAS_TRAIT(source, TRAIT_RUSTY) || !HAS_TRAIT(next_turf, TRAIT_RUSTY))
			continue

		next_turf.ex_act(EXPLODE_HEAVY)


/obj/effect/proc_holder/spell/mob_cooldown/charge/rust/on_bump(atom/movable/source, atom/target)
	..()
	if(action.owner == target)
		return

	if(!destroy_objects)
		INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
		try_hit_target(source, target, charge_damage)
		return

	if(isturf(target))
		INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)

	if(isobj(target) && target.density)
		target.ex_act(EXPLODE_HEAVY)

	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	try_hit_target(source, target, charge_damage)
