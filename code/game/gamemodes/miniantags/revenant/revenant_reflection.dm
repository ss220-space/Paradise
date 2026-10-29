/datum/status_effect/revenant_reflection
	id = "revenant reflection"
	duration = 20 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/rev_reflection
	var/mob/living/simple_animal/revenant/reflect_from
	var/reflectpercent
	var/suf_beam

/datum/status_effect/revenant_reflection/on_creation(mob/living/new_owner, duration, mob/living/simple_animal/revenant/inflicter, percent)
	if(duration)
		duration = duration
	reflect_from = inflicter
	reflectpercent = percent
	reflect_from.reflection = src
	. = ..()
	suf_beam = owner.Beam(reflect_from, "sufferline", 'icons/effects/revenant.dmi')

/datum/status_effect/revenant_reflection/Destroy()
	. = ..()
	reflect_from.reflection = null
	qdel(suf_beam)

/datum/status_effect/revenant_reflection/tick(seconds_between_ticks)ы
	var/holywater = owner.reagents.has_reagent(/datum/reagent/holywater, 5)
	if(holywater)
		owner.reagents.remove_reagent("holy_water", 5)
		qdel(src)

/datum/status_effect/revenant_reflection/proc/reflect(reflected_damage)
	owner.adjustStaminaLoss(reflected_damage)

/atom/movable/screen/alert/status_effect/rev_reflection
	name = "Отражение мук"
	desc = "Неизвестное существо вцепилось в вашу душу и перенаправляет на вас часть получаемого им урона!"
	icon_state = "rev_reflect"
