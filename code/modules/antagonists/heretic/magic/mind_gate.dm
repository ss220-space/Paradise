/obj/effect/proc_holder/spell/pointed/mind_gate
	name = "Mind Gate"
	desc = "Deals you 20 brain damage and the target suffers a hallucination, \
			is left confused for 10 seconds, and suffers oxygen loss and brain damage."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mind_gate"

	sound = 'sound/effects/magic/curse.ogg'
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 20 SECONDS

	invocation = "Op'n y'r m'd."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to open your mind..."


/obj/effect/proc_holder/spell/pointed/mind_gate/can_cast(feedback = TRUE)
	return ..() && isliving(action.owner)


/obj/effect/proc_holder/spell/pointed/mind_gate/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/mind_gate/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Your mind feels closed."))
		to_chat(action.owner, span_warning("Their mind doesn't swing open, but neither does yours."))
		return FALSE

	cast_on.Confused(10 SECONDS)
	cast_on.adjustOxyLoss(30)
	cast_on.Hallucinate(60 SECONDS)
	cast_on.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate")
	cast_on.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 30)

	var/mob/living/living_owner = action.owner
	living_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 20, 140)
