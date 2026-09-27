#define HEART_RESONANCE_DURATION (1 MINUTES)


/datum/action/cooldown/spell/aoe/heart_resonance
	name = "Резонанс Сердец"
	desc = "Связывает все сердца поблизости с вашим на минуту. Пока связь держится, каждое \
			ваше сердцебиение бьёт по всему живому вокруг, а чужой страх поднимает ваш ритм."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_rhytm"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "heart_resonance"
	sound = 'sound/magic/heretic/rhytm/timpan2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 90 SECONDS

	invocation = "'ДН' С'РДЦ' Н' В'С'Х"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	aoe_radius = 2


/datum/action/cooldown/spell/aoe/heart_resonance/is_valid_target(atom/cast_on)
	return !isnull(get_heretic_rhytm(cast_on))


/datum/action/cooldown/spell/aoe/heart_resonance/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = owner || owner
	var/datum/status_effect/heretic_passive/rhytm/beat = get_heretic_rhytm(caster)
	if(!beat)
		return

	beat.pulse_until = world.time + HEART_RESONANCE_DURATION
	beat.flourish()
	new /obj/effect/temp_visual/resonant_pulse(get_turf(caster))
	to_chat(caster, span_hierophant("Все сердца вокруг сбиваются на ваш такт."))

	for(var/mob/living/nearby_mob in view(aoe_radius, caster))
		if(nearby_mob == caster || IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		to_chat(nearby_mob, span_userdanger("Ваше сердце сбивается и начинает биться в чужом такте!"))


#undef HEART_RESONANCE_DURATION
