/datum/component/wryn_destruction

/datum/component/wryn_destruction/Initialize()
	if(!isstructure(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/wryn_destruction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))

/datum/component/wryn_destruction/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/wryn_destruction/proc/attack_hand(source, user)
	SIGNAL_HANDLER

	if(!iswryn(user))
		return
	INVOKE_ASYNC(src, PROC_REF(harming))

/datum/component/wryn_destruction/proc/harming(source, user)
	if(user.a_intent == INTENT_HARM)
		source.take_damage(15, BRUTE, 0, 'sound/effects/attackblob.ogg')
		user.do_attack_animation(src)
