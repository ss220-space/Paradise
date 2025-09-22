// Applys braindamage when owner says word from list. Not so fust, so don't use it for many mobs!
/datum/component/brainrot_braingamage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/bad_words
	var/damage


/datum/component/brainrot_braingamage/Initialize(damage, list/bad_words)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	src.bad_words = bad_words
	src.damage = damage

/datum/component/brainrot_braingamage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_TRY_SPEECH, PROC_REF(on_mob_say))


/datum/component/brainrot_braingamage/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_TRY_SPEECH)


/datum/component/brainrot_braingamage/proc/on_mob_say(mob/living/carbon/human/mob, message)
	for(var/word in bad_words)
		if(!findtext(message, word))
			continue

		to_chat(mob, span_userdanger("[capitalize(word)] отдаётся эхом боли в вашей голове!"))
		mob.EyeBlurry(1 SECONDS)
		mob.adjustBrainLoss(damage)
		break
