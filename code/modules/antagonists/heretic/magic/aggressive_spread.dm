/obj/effect/proc_holder/spell/aoe/rust_conversion
	name = "Агрессивное распространение"
	desc = "Покрывает всё вокруг ржавчиной."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "ГР'СС'ВН Р'СПР'СТР'Н'Н"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 2


/obj/effect/proc_holder/spell/aoe/rust_conversion/valid_target(target, user)
	return TRUE


/obj/effect/proc_holder/spell/aoe/rust_conversion/get_things_to_cast_on(atom/center)

	var/list/things_to_convert = RANGE_TURFS(aoe_range, center)

	// Also converts things right next to you.
	for(var/atom/movable/nearby_movable in view(1, center))
		if(nearby_movable == action.owner || !isstructure(nearby_movable))
			continue
		things_to_convert += nearby_movable

	return things_to_convert


/obj/effect/proc_holder/spell/aoe/rust_conversion/cast(list/targets, mob/caster = usr)
	for(var/mob/living/victim as anything in targets)
		// We have less chance of rusting stuff that's further
		var/distance_to_caster = get_dist(victim, caster)
		var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_range + 1)

		if(prob(chance_of_not_rusting))
			continue

		if(ismob(caster))
			caster.do_rust_heretic_act(victim)
		else
			victim.rust_heretic_act()


/obj/effect/proc_holder/spell/aoe/rust_conversion/construct
	name = "Агрессивное Распространение"
	base_cooldown = 15 SECONDS
