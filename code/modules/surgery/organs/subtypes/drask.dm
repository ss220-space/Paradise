//DRASK ORGAN
/obj/item/organ/internal/drask
	species_type = /datum/species/drask
	name = "drask organ"
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "innards"
	desc = "A greenish, slightly translucent organ. It is extremely cold."

/obj/item/organ/internal/heart/drask
	species_type = /datum/species/drask
	name = "drask heart"
	icon = 'icons/obj/species_organs/drask.dmi'
	parent_organ_zone = BODY_ZONE_HEAD
	organ_actions = list(/datum/action/innate/drask_coma)

/obj/item/organ/internal/liver/drask
	species_type = /datum/species/drask
	name = "metabolic strainer"
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "kidneys"
	alcohol_intensity = 0.8

/obj/item/organ/internal/brain/drask
	species_type = /datum/species/drask
	icon = 'icons/obj/species_organs/drask.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/drask.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/eyes/drask
	species_type = /datum/species/drask
	name = "drask eyeballs"
	icon = 'icons/obj/species_organs/drask.dmi'
	desc = "Drask eyes. They look even stranger disembodied."
	see_in_dark = 5

/datum/action/innate/drask_coma
	name = "Enter coma"
	desc = "Постепенно усыпляет, понижает температуру тела. Повторная активация способности позволит прервать вход в кому, либо выйти из нее."

	button_icon = 'icons/obj/species_organs/drask.dmi'
	button_icon_state = "heart_on"

	COOLDOWN_DECLARE(wake_up_cooldown)
	var/activation_time

/datum/action/innate/drask_coma/activate()
	activation_time = world.time

	if(!owner.has_status_effect(STATUS_EFFECT_DRASK_COMA))
		if(!do_after(owner, 5 SECONDS, owner, ALL, extra_checks = CALLBACK(src, PROC_REF(stopped_channeling)), max_interaction_count = 1))
			to_chat(owner, span_notice("Вы подсознательно возобновляете метаболизм"))
			return FALSE

		owner.apply_status_effect(STATUS_EFFECT_DRASK_COMA)
		COOLDOWN_START(src, wake_up_cooldown, 10 SECONDS)
		return

	if(!COOLDOWN_FINISHED(src, wake_up_cooldown))
		to_chat(owner, span_warning("Вы не можете пробудиться сейчас."))
		return

	to_chat(owner, span_notice("Вы начинаете пробуждаться."))

	if(!do_after(owner, 10 SECONDS, owner, ALL, extra_checks = CALLBACK(src, PROC_REF(stopped_channeling)) max_interaction_count = 1))
		to_chat(owner, span_notice("Вы решили продолжить сон."))
		return

	owner.remove_status_effect(STATUS_EFFECT_DRASK_COMA)
	return

/datum/action/innate/drask_coma/proc/stopped_channeling()
	return activation_time != 0
