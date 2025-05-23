/datum/component/wryn_destruction

/datum/component/wryn_destruction/Initialize()
	if(isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/wryn_destruction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))

/datum/component/wryn_destruction/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/wryn_destruction/proc/attack_hand(mob/living/user)
	SIGNAL_HANDLER

	if(iswryn(user))
		INVOKE_ASYNC(src, PROC_REF(harming))

	return

/datum/component/wryn_destruction/proc/harming(mob/living/user, obj/obj_parent)
	obj_parent = parent
	if(!user.a_intent == INTENT_HARM)
		return
	obj_parent.take_damage(15, BRUTE, 0, 'sound/effects/attackblob.ogg')
	user.do_attack_animation(src)
