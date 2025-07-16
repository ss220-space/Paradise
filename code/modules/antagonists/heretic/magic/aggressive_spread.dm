/obj/effect/proc_holder/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "corrode"
	sound = 'sound/items/tools/welder.ogg'

	school = SCHOOL_FORBIDDEN
	base_cooldown = 30 SECONDS

	invocation = "A'GRSV SPR'D."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 2

/obj/effect/proc_holder/spell/aoe/get_things_to_cast_on(atom/center)

	var/list/things_to_convert = RANGE_TURFS(aoe_range, center)

	// Also converts things right next to you.
	for(var/atom/movable/nearby_movable in view(1, center))
		if(nearby_movable == action.owner || !isstructure(nearby_movable) )
			continue
		things_to_convert += nearby_movable

	return things_to_convert

/obj/effect/proc_holder/spell/aoe/cast_on_thing_in_aoe(turf/victim, mob/living/caster)
	// We have less chance of rusting stuff that's further
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_range + 1)

	if(prob(chance_of_not_rusting))
		return

	if(ismob(caster))
		caster.do_rust_heretic_act(victim)
	else
		victim.rust_heretic_act()

/obj/effect/proc_holder/spell/aoe/construct
	name = "Construct Spread"
	base_cooldown = 15 SECONDS
