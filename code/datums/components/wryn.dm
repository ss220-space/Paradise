#define WRYN_WAX_DAMAGE 15

/datum/component/wryn_destruction
	var/mob/living/carbon/human/user

/datum/component/wryn_destruction/Initialize()
	START_PROCESSING(SSprocessing, src)


/datum/component/wryn_destruction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))

/datum/component/wryn_destruction/proc/attack_hand(datum/source, mob/living/carbon/human/user)
	SIGNAL_HANDLER

	if(!iswryn(user))
		return

	var/obj/obj_parent = parent
	if(user.a_intent == INTENT_HARM)
		obj_parent.take_damage(WRYN_WAX_DAMAGE, BRUTE, 0, 'sound/effects/attackblob.ogg')
		user.do_attack_animation(src)

#undef WRYN_WAX_DAMAGE
