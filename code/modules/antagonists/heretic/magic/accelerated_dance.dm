#define ACCELERATED_DANCE_RHYTM 10


/datum/action/cooldown/spell/accelerated_dance
	name = "Ускоренный Танец"
	desc = "Сорваться в танец: ритм подскакивает, вы двигаетесь заметно быстрее, вдвое хуже \
			чувствуете усталость и вас нельзя сбить с ног. Когда танец кончится, тело потребует своё."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_rhytm"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "accelerated_dance"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS
	invocation = "Т'НЦ'Й!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE


/datum/action/cooldown/spell/accelerated_dance/is_valid_target(atom/cast_on)
	return isliving(cast_on)


/datum/action/cooldown/spell/accelerated_dance/cast(mob/living/cast_on)
	. = ..()
	var/datum/status_effect/heretic_passive/rhytm/beat = get_heretic_rhytm(cast_on)
	beat?.adjust_rhythm(ACCELERATED_DANCE_RHYTM)
	beat?.flourish()
	cast_on.emote("dance", ignore_cooldowns = TRUE)
	cast_on.apply_status_effect(/datum/status_effect/accelerated_dance)


#undef ACCELERATED_DANCE_RHYTM
