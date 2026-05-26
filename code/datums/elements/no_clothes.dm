/datum/element/no_clothes
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/mob/living/body
	var/datum/mind/owner

/datum/element/no_clothes/Attach(datum/target)
	.=..()
	owner = target
	START_PROCESSING(SSprocessing, src)

/datum/element/no_clothes/Detach(datum/source)
	.=..()
	body.remove_status_effect(STATUS_EFFECT_NO_CLOTHES)
	STOP_PROCESSING(SSprocessing, src)

/datum/element/no_clothes/process(seconds_per_tick)
	if(!owner.current || owner.current == body)
		return
	if(body)
		body.remove_status_effect(STATUS_EFFECT_NO_CLOTHES)
	body = owner.current
	body.apply_status_effect(STATUS_EFFECT_NO_CLOTHES)

