/// Path of Ash abilities want fire that actually burns, not the decorative kind. A hotspot spawned with a
/// bare new() on Paradise isn't MILLA-managed, so it never expires and never ignites anyone; we instead use
/// the self-deleting /obj/effect/hotspot/fake and set things alight ourselves, the same way fireflash() does.
/proc/ash_flame_turf(turf/target, burn_damage, mob/living/exempt, stacks_to_add = 3)
	if(!isturf(target))
		return
	var/obj/effect/hotspot/fake/eldritch/flame_tile = locate() in target
	if(!flame_tile)
		flame_tile = new(target)
	target.hotspot_expose(flame_tile.temperature, flame_tile.volume)
	for(var/atom/movable/burnable in target)
		if(burnable == flame_tile || isliving(burnable))
			continue
		burnable.fire_act(flame_tile.temperature, flame_tile.volume)
	for(var/mob/living/fried_living in target)
		if(fried_living == exempt)
			continue
		fried_living.apply_damage(burn_damage, BURN)
		fried_living.adjust_fire_stacks(stacks_to_add)
		fried_living.IgniteMob()

/obj/effect/hotspot/fake/eldritch
	burn_time = 1 SECONDS
	temperature = 2500
	alpha = 200

/obj/effect/hotspot/fake/eldritch/Initialize(mapload)
	. = ..()
	recolor()

/obj/effect/hotspot/fake/eldritch/recolor()
	color = COLOR_MOSTLY_PURE_RED
	set_light(l_color = color)

/// Creates a constant Ring of Fire around the caster for a set duration of time, which follows them.
/obj/effect/proc_holder/spell/fire_sworn
	name = "Клятва Пламени"
	desc = "Во время действия вы будете пассивно создавать вокруг себя огненные кольца."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 70 SECONDS

	invocation = "ПЛ'М"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it the ring lasts
	var/duration = 1 MINUTES


/obj/effect/proc_holder/spell/fire_sworn/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/fire_sworn/on_spell_loss(mob/living/remove_from)
	remove_from.remove_status_effect(/datum/status_effect/fire_ring)
	return ..()


/obj/effect/proc_holder/spell/fire_sworn/valid_target(atom/cast_on)
	return isliving(cast_on)


/obj/effect/proc_holder/spell/fire_sworn/cast(list/targets, mob/user = usr)
	var/mob/living/cast_on = targets[1]
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/fire_ring, duration, fire_radius)


/// Simple status effect for adding a ring of fire around a mob.
/datum/status_effect/fire_ring
	id = "fire_ring"
	tick_interval = 0.2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The radius of the ring around us.
	var/ring_radius = 1


/datum/status_effect/fire_ring/on_creation(mob/living/new_owner, duration = 1 MINUTES, radius = 1)
	src.duration = duration
	src.ring_radius = radius
	return ..()


/datum/status_effect/fire_ring/tick(seconds_between_ticks)
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return

	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		ash_flame_turf(nearby_turf, 2.5 * seconds_between_ticks, owner)


/// Creates one, large, expanding ring of fire around the caster, which does not follow them.
/obj/effect/proc_holder/spell/fire_cascade
	name = "Малый Каскад Пламени"
	desc = "Нагревает воздух вокруг вас."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "fire_ring"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "К'СК'Д"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius the flames will go around the caster.
	var/flame_radius = 4


/obj/effect/proc_holder/spell/fire_cascade/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/fire_cascade/cast(list/targets, mob/user = usr)
	var/atom/cast_on = targets[1]
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fire_cascade), get_turf(cast_on), flame_radius)


/// Spreads a huge wave of fire in a radius around us, staggered between levels
/obj/effect/proc_holder/spell/fire_cascade/proc/fire_cascade(atom/centre, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			ash_flame_turf(nearby_turf, 5, action.owner)

		stoplag(0.3 SECONDS)


/obj/effect/proc_holder/spell/fire_cascade/big
	name = "Высший Каскад Пламени"
	flame_radius = 6


/obj/effect/proc_holder/spell/pointed/ash_beams
	name = "Обряд Ночного Дозорного"
	desc = "Мощное заклинание, выпускающее в цель пять потоков потустороннего пламени."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "flames"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 300

	invocation = "F'R."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The length of the flame line spit out.
	var/flame_line_length = 15


/obj/effect/proc_holder/spell/pointed/ash_beams/valid_target(atom/cast_on)
	return TRUE


/obj/effect/proc_holder/spell/pointed/ash_beams/cast(list/targets, mob/user = usr)
	. = ..()
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, PROC_REF(fire_line), action.owner, line_target(offset, flame_line_length, targets[1], action.owner))


/obj/effect/proc_holder/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	var/turf/user_loc = get_turf(user)
	if(!at)
		return

	var/angle = ATAN2(at.x - user_loc.x, at.y - user_loc.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user_loc.x + cos(angle) * i, user_loc.y + sin(angle) * i, user_loc.z)
		if(!check)
			break

		T = check

	return (get_line(user_loc, T) - user_loc)


/obj/effect/proc_holder/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(iswallturf(T))
			break

		for(var/mob/living/L in T.contents)
			if(L.can_block_magic())
				L.visible_message(
					span_danger("[DECLENT_RU_CAP(L, NOMINATIVE)] отражает заклинание!"),
					span_danger("Заклинание рассеивается, не успев коснуться вас!")
				)
				continue

			if((L in hit_list) || L == source)
				continue

			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("Жуткое пламя опаляет вас!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700, 50, 1)
		for(var/obj/mecha/M in T.contents)
			if(M in hit_list)
				continue

			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)

		sleep(0.15 SECONDS)
