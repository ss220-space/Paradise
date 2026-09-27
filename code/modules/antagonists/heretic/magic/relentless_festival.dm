/datum/action/cooldown/spell/aoe/relentless_festival
	name = "Безустанный Фестиваль"
	desc = "Объявляет фестиваль: все, кто окажется рядом, теряют власть над собственными ногами \
			и повторяют каждый ваш шаг, теряя силы с каждым движением."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_rhytm"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "relentless_festival"
	sound = 'sound/magic/heretic/rhytm/timpan1.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS

	invocation = "Т'НЦ'ЙТ' В'С'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	aoe_radius = 5


/datum/action/cooldown/spell/aoe/relentless_festival/get_things_to_cast_on(atom/center, radius_override)
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


/datum/action/cooldown/spell/aoe/relentless_festival/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner || owner
	var/datum/status_effect/heretic_passive/rhytm/beat = get_heretic_rhytm(caster)
	beat?.flourish()
	new /obj/effect/temp_visual/relentless_festival(get_turf(caster))
	for(var/mob/living/victim as anything in get_things_to_cast_on(caster))
		victim.apply_status_effect(/datum/status_effect/festival_puppet, caster)
		new /obj/effect/temp_visual/relentless_festival(get_turf(victim))
