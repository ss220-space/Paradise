/datum/component/stumbling
	var/damage
	var/damage_type
	var/effect_time
	var/effect_types
	var/sound

/datum/component/stumbling/Initialize(_damage = 0, _damage_type = BRUTE, _effect_time = 2, _effect_types = list("weak"), _sound = null)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	damage = _damage
	damage_type = _damage_type
	effect_time = _effect_time
	effect_types = _effect_types
	sound = _sound

/datum/component/stumbling/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), PROC_REF(Stumble))

/datum/component/stumbling/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED))

/datum/component/stumbling/proc/Stumble(datum/source,  mob/living/carbon/C)
	if(C?.mind.martial_art && istype(C.mind.martial_art,/datum/martial_art/steroids))
		return
	if(!(C?.pulledby || C.flying || C.buckled || C.m_intent == MOVE_INTENT_WALK))
		to_chat(C,span_warning(pick(\
									"Watch your step!", \
									"Watch your feet!", \
									"Watch where you are going!")))
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
