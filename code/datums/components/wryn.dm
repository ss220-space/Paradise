#define WRYN_WAX_DAMAGE 15

/datum/component/wryn_destruction
	var/obj/obj_parent
	var/mob/living/carbon/human/user

/datum/component/wryn_destruction/Initialize()
	obj_parent = parent
	START_PROCESSING(SSprocessing, src)


/datum/component/wryn_destruction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))

/datum/component/wryn_destruction/proc/attack_hand(datum/source, mob/living/carbon/human/user)
	SIGNAL_HANDLER

	if(!iswryn(user))
		return

	if(user.a_intent == INTENT_HARM)
		take_damage(WRYN_WAX_DAMAGE, BRUTE, 0, 'sound/effects/attackblob.ogg')
		user.do_attack_animation(src)

