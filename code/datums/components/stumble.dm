/datum/component/stumbling
	var/damage
	var/damage_type
	var/effect_time
	var/effect_types
	var/sound
	var/phrases_to_target = list()

/datum/component/stumbling/Initialize(_damage = 0, _damage_type = BRUTE, _effect_time = 2, _effect_types = list("weak"), _sound = null, _phrases_to_target = list(\
																																								"Watch your step!", \
																																								"Watch your feet!", \
																																								"Watch where you are going!"))
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	damage = _damage
	damage_type = _damage_type
	effect_time = _effect_time
	effect_types = _effect_types
	sound = _sound
	phrases_to_target = _phrases_to_target

/datum/component/stumbling/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), PROC_REF(Stumble))

/datum/component/stumbling/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED))

/datum/component/stumbling/proc/Stumble(datum/source,  mob/living/carbon/target)
	var/mob/living/carbon/C = target

	if(!iscarbon(C))
		return

	if(isobj(parent))
		var/obj/I = parent
		if(!I.component_can_stumble(C))
			return

	if(istype(C, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = C
		if(H.shoes && istype(H.shoes, /obj/item/clothing/shoes/magboots))
			var/obj/item/clothing/shoes/magboots/S = H.shoes
			if(S.flags & NOSLIP)
				return

	if(!(C?.pulledby || C.flying || C.buckled || C.m_intent == MOVE_INTENT_WALK))
		to_chat(C,span_warning(pick(phrases_to_target)))
		for(var/effect in effect_types)
			switch(effect)
				if("weak")
					C.Weaken(effect_time SECONDS)
				if("stun")
					C.Stun(effect_time SECONDS)
				if("slow")
					C.Slowed(effect_time SECONDS)
				if("immobileze")
					C.Immobilize(effect_time SECONDS)
		if(!isnull(sound))
			playsound(C.loc, sound, 50, 1, -3)

		C.apply_damage(damage, damage_type, pick("l_foot", "r_foot"))
		return

/atom/proc/component_can_stumble(mob/target)
	return TRUE
