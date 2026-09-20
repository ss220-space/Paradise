/datum/action/cooldown/spell/pointed/bless
	name = "Bless"
	desc = "Blesses a single person."
	school = SCHOOL_HOLY
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS
	spell_requirements = NONE
	active_msg = span_notice_alt("You prepare a blessing.")
	deactive_msg  = span_notice_alt("The crew will be blessed another time.")
	button_icon_state = "shield"

/datum/action/cooldown/spell/pointed/bless/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	return target.mind && target.ckey && !target.stat

/datum/action/cooldown/spell/pointed/bless/cast(atom/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		to_chat(owner, "Somehow, you are not a living mob. This should never happen. Report this bug.")
		return

	var/mob/living/carbon/human/target = cast_on

	if(!owner.mind)
		to_chat(owner, "Somehow, you are mindless. This should never happen. Report this bug.")
		return

	if(!owner.mind.isholy)
		to_chat(owner, "Somehow, you are not holy enough to use this ability. This should never happen. Report this bug.")
		return

	INVOKE_ASYNC(src, PROC_REF(bless), target)


/datum/action/cooldown/spell/pointed/bless/proc/bless(mob/living/carbon/human/target)
	if(tgui_alert(target, "[owner] wants to bless you, in the name of [owner.p_their()] religion. Accept?", "Accept Blessing?", list("Yes", "No")) == "Yes") // prevents forced conversions
		owner.visible_message("[owner] starts blessing [target] in the name of [SSticker.Bible_deity_name].", span_notice("You start blessing [target] in the name of [SSticker.Bible_deity_name]."))
		if(do_after(owner, 15 SECONDS, target))
			owner.visible_message("[owner] has blessed [target] in the name of [SSticker.Bible_deity_name].", span_notice("You have blessed [target] in the name of [SSticker.Bible_deity_name]."))
			if(!target.mind.isblessed)
				target.mind.isblessed = TRUE
				owner.mind.num_blessed++
				ADD_TRAIT(target, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)
