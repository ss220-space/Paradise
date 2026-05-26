/datum/element/no_clothes
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/mob/living/body
	var/datum/mind/owner

/datum/element/no_clothes/Attach(datum/target)
	.=..()
	owner = target
	body = owner.current
	RegisterSignals(body, list(COMSIG_LIVING_SHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED), PROC_REF(add_status_effect))
	body.apply_status_effect(STATUS_EFFECT_NO_CLOTHES)

/datum/element/no_clothes/Detach(datum/source)
	.=..()
	UnregisterSignal(body, list(COMSIG_LIVING_SHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED))

/datum/element/no_clothes/proc/add_status_effect()
	if(check_new_body())
		body.apply_status_effect(STATUS_EFFECT_NO_CLOTHES)

/datum/element/no_clothes/proc/check_new_body()
	if(owner.current == body)
		return FALSE
	UnregisterSignal(body, list(COMSIG_LIVING_SHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED))
	body = owner.current
	RegisterSignals(body, list(COMSIG_LIVING_SHAPESHIFTED, COMSIG_MOB_CHANGED_TYPE, COMSIG_LIVING_ON_WABBAJACKED, COMSIG_LIVING_UNSHAPESHIFTED), PROC_REF(add_status_effect))
	return TRUE
