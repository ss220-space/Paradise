/datum/action/cooldown/spell/pointed/charge/rust
	name = "Заряд Ржавчины"
	desc = "Заклинание, которое необходимо начать стоя на ржавой плитке. \
			После применения вы совершите рывок в выбранную точку. \
			Уничтожит все ржавые предметы, с которыми вы соприкоснётесь. \
			Нанесёт большой урон окружающим и распространит ржавчину."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	charge_distance = 10
	cast_range = 10
	charge_damage = 25
	charge_past = 0
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	school = SCHOOL_FORBIDDEN
	/// The human we handed the +100 damage_resistance to while charging, so we only ever remove it once.
	var/mob/living/carbon/human/shielded_owner


/datum/action/cooldown/spell/pointed/charge/rust/cast(atom/cast_on)
	. = ..()
	var/turf/start_turf = get_turf(owner)
	var/turf/target_turf = get_turf(cast_on)
	if(!istype(start_turf) || !HAS_TRAIT(start_turf, TRAIT_RUSTY) || !istype(target_turf))
		return FALSE

	if(ishuman(owner))
		shielded_owner = owner
		shielded_owner.physiology.damage_resistance += 100
	RegisterSignal(owner, COMSIG_FINISHED_CHARGE, PROC_REF(affect_aoe))
	addtimer(CALLBACK(src, PROC_REF(drop_shield)), 15 SECONDS)

	INVOKE_ASYNC(src, PROC_REF(charge_sequence), owner, target_turf, charge_delay, charge_past)
	return TRUE


/// When the charge ends, deal damage + knock down everyone next to us and drop our invulnerability.
/datum/action/cooldown/spell/pointed/charge/rust/proc/affect_aoe()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_FINISHED_CHARGE)
	for(var/mob/living/nearby_mob in view(1, owner))
		if(nearby_mob == owner)
			continue
		nearby_mob.apply_damage(charge_damage, BRUTE)
		nearby_mob.Knockdown(5 SECONDS)
	drop_shield()


/// Removes the temporary charge invulnerability. Safe to call more than once (only the shielded owner loses it).
/datum/action/cooldown/spell/pointed/charge/rust/proc/drop_shield()
	if(isnull(shielded_owner))
		return
	shielded_owner.physiology.damage_resistance -= 100
	shielded_owner = null


/datum/action/cooldown/spell/pointed/charge/rust/on_move(atom/source, atom/new_loc, atom/target)
	..()
	var/turf/victim = get_turf(owner)

	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, PROC_REF(DestroySurroundings), source)
	victim.rust_heretic_act()
	for(var/dir in GLOB.cardinal)
		var/turf/nearby_turf = get_step(victim, dir)
		if(!istype(nearby_turf))
			continue

		nearby_turf.rust_heretic_act()


/datum/action/cooldown/spell/pointed/charge/rust/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return

	for(var/dir in GLOB.cardinal)
		var/turf/source = get_turf(owner)
		var/turf/simulated/wall/next_turf = get_step(charger, dir)
		if(!istype(source) || !istype(next_turf) || !HAS_TRAIT(source, TRAIT_RUSTY) || !HAS_TRAIT(next_turf, TRAIT_RUSTY))
			continue

		next_turf.ex_act(EXPLODE_HEAVY)


/datum/action/cooldown/spell/pointed/charge/rust/on_bump(atom/movable/source, atom/target)
	..()
	if(owner == target)
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
