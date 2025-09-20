/obj/effect/proc_holder/spell/aoe/void_pull
	name = "Притяжение пустоты"
	desc = "Временно открывает врата в пустоту, нанося урон, сбивая с ног и оглушая всех находящихся поблизости. \
			Далёкие враги притягиваются к вам (но не получают урона)."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "voidpull"
	sound = 'sound/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "ПР'В'Д' 'Х К' МН'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4


// Before the cast, we do some small AOE damage around the caster
/obj/effect/proc_holder/spell/aoe/void_pull/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/atom/cast_on = targets[1]
	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

	// Before we cast the actual effects, deal AOE damage to anyone adjacent to us
	for(var/mob/living/nearby_living as anything in get_things_to_cast_on(cast_on, damage_radius))
		nearby_living.apply_damage(30, BRUTE/*, wound_bonus = CANT_WOUND*/)
		nearby_living.apply_status_effect(/datum/status_effect/void_chill, 1)


/obj/effect/proc_holder/spell/aoe/void_pull/get_things_to_cast_on(atom/center, radius_override)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_range, center))
		if(nearby_mob == action.owner || nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things


// For the actual cast, we microstun people nearby and pull them in
/obj/effect/proc_holder/spell/aoe/void_pull/cast(list/targets, mob/caster = usr)
	for(var/mob/living/victim as anything in targets)
		// If the victim's within the stun radius, they're stunned / knocked down
		if(get_dist(victim, caster) < stun_radius)
			victim.AdjustKnockdown(3 SECONDS)
			victim.AdjustParalysis(0.5 SECONDS)

		// Otherwise, they take a few steps closer
		for(var/i in 1 to 3)
			victim.forceMove(get_step_towards(victim, caster))
