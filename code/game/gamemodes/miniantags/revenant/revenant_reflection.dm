/datum/status_effect/revenant_reflection
	id = "revenant reflection"
	duration = 20 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/rev_reflection
	var/mob/living/simple_animal/revenant/reflect_from
	var/reflectpercent
	var/suf_beam

/datum/status_effect/revenant_reflection/New(list/arguments)
	if(arguments[2])
		duration = arguments[2]
	reflect_from = arguments[3]
	reflectpercent = arguments[4]
	reflect_from.reflection = src
	. = ..()
	suf_beam = owner.Beam(reflect_from, "sufferline", 'icons/effects/revenant.dmi')

/datum/status_effect/revenant_reflection/Destroy()
	. = ..()
	reflect_from.reflection = null
	qdel(suf_beam)

/datum/status_effect/revenant_reflection/tick(seconds_between_ticks)
	var/holywater = owner.reagents.has_reagent(/datum/reagent/holywater, 5)
	if(holywater)
		owner.reagents.remove_reagent("holy_water", 5)
		qdel(src)

/datum/status_effect/revenant_reflection/proc/reflect(reflected_damage)
	owner.adjustStaminaLoss(reflected_damage)

/atom/movable/screen/alert/status_effect/rev_reflection
	name = "Отражение мук"
	desc = "Неизввестное существо присосалось к вашей душе, перенаправляя на нее часть получаемых им повреждений!"
	icon_state = "rev_reflect"
