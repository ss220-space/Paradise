/datum/action/cooldown/spell/no_clothes
	name = "No Clothes"
	desc = "This always-on spell allows you to cast magic without your garments."
	button_icon_state = "no_clothes"

/datum/action/cooldown/spell/no_clothes/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/no_clothes/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = cast_on
	to_chat(caster, span_notice("Вы активировали заклинание, отныне вам не нужна одежда для использования заклинаний!"))
	caster.mind.AddElement(/datum/element/no_clothes)
	qdel(src)

/datum/status_effect/no_clothes
	id = "no_clothes"
	alert_type = /atom/movable/screen/alert/status_effect/no_clothes
	on_remove_on_mob_delete = TRUE

/datum/status_effect/no_clothes/on_apply()
	return TRUE

/datum/status_effect/no_clothes/on_remove()

/atom/movable/screen/alert/status_effect/no_clothes
	name = "Усиление магии"
	desc = "Вам больше не нужна одежда для использования заклинаний!"
	icon_state = "no_clothes"
