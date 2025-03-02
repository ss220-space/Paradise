// This simple element is used for rituals for removing dyes from peoples and ash totems.
/datum/element/dye_removal
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/dye_removal/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_RITUAL_ENDED, PROC_REF(remove_dyes))

/datum/element/dye_removal/Detach(datum/source, force)
	. = ..()

	UnregisterSignal(source, COMSIG_RITUAL_ENDED)

/datum/element/dye_removal/proc/remove_dyes(datum/ritual/ashwalker/ritual, status_bitflag, atom/invoker, list/invokers, list/used_things)
	SIGNAL_HANDLER

	if(!HASBIT(status_bitflag, RITUAL_SUCCESSFUL))
		return

	if(ritual.needed_dye)
		if(isnull(invokers) && invoker) //this sometimes happens. There is nothing we can do
			var/mob/living/carbon/human/human = invoker
			human.m_styles["body"] = "None"
			to_chat(human, span_notice("Краска на вашем теле медленно испаряется."))
			human.update_markings()
			return

		for(var/mob/living/carbon/human/human in invokers)
			human.m_styles["body"] = "None"
			to_chat(human, span_notice("Краска на вашем теле медленно испаряется."))
			human.update_markings()
		for(var/obj/structure/ash_totem/totem in invokers)
			totem.applied_dye = null
			totem.applied_dye_fluff_name = null
			totem.visible_message(span_notice("Краска медленно испаряется с поверхности тотема."))
			totem.update_icon(UPDATE_OVERLAYS)

