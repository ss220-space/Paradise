/datum/action/cooldown/spell/mime
	name = "Обет молчания"
	desc = "Примите или нарушьте обет молчания."
	school = SCHOOL_MIME
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 5 MINUTES
	button_icon_state = "mime_silence"
	background_icon_state = "bg_mime"

// IDK how to do it
/*
/obj/effect/proc_holder/spell/mime/speak/Click()
	if(!usr)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(HAS_MIND_TRAIT(user, TRAIT_MIMING))
		still_recharging_msg = span_warning("Вы не можете так быстро нарушить свой обет молчания!")
	else
		still_recharging_msg = span_warning("Вам придётся подождать, прежде чем вы сможете снова дать обет молчания!")
	..()*/

/datum/action/cooldown/spell/mime/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	if(!target.mind)
		return

	if(HAS_MIND_TRAIT(target, TRAIT_MIMING))
		REMOVE_TRAIT(target.mind, TRAIT_MIMING, "mime_vow")
		to_chat(target, span_notice("Вы нарушаете свой обет молчания."))
	else
		ADD_TRAIT(target.mind, TRAIT_MIMING, "mime_vow")
		to_chat(target, span_notice("Вы даёте обет молчания."))
