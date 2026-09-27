/datum/action/cooldown/spell/aoe/void_pull
	name = "Притяжение Пустоты"
	desc = "Призывает пустоту: наносит урон, сбивает с ног, притягивает и оглушает всех находящихся поблизости."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"
	sound = 'sound/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "ПР'В'Д' 'Х К' МН'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	aoe_radius = 2


/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(owner))


/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center, radius_override)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things


/datum/action/cooldown/spell/aoe/void_pull/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner || owner
	for(var/mob/living/victim as anything in get_things_to_cast_on(caster))
		victim.apply_damage(30, BRUTE/*, wound_bonus = CANT_WOUND*/)
		victim.apply_status_effect(/datum/status_effect/void_chill, 3)
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalysis(0.5 SECONDS)
		for(var/i in 1 to 3)
			victim.forceMove(get_step_towards(victim, caster))
	return TRUE
