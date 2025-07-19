/obj/effect/proc_holder/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and knocking down a single target if their sanity is low enough."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/effects/magic/blind.ogg'
	school = SCHOOL_FORBIDDEN
	base_cooldown = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "M'N S'M'LE!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to let them see the true face..."


/obj/effect/proc_holder/spell/pointed/moon_smile/can_cast(feedback = TRUE)
	return ..() && isliving(action.owner)


/obj/effect/proc_holder/spell/pointed/moon_smile/valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)


/obj/effect/proc_holder/spell/pointed/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/moon_smile_duration = 15 SECONDS
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("The moon turns, its smile no longer set on you."))
		to_chat(action.owner, span_warning("The moon does not smile upon them."))
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, span_warning("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!"))
	cast_on.EyeBlind(moon_smile_duration + 1 SECONDS)
	cast_on.EyeBlurry(moon_smile_duration + 2 SECONDS)

	cast_on.adjustOrganLoss(INTERNAL_ORGAN_EARS, 10)
	cast_on.Silence(moon_smile_duration + 1 SECONDS)
	return TRUE
