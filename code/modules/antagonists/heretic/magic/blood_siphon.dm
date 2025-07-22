/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A targeted spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 15 SECONDS

	invocation = "FL'MS O' 'T'RN'TY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6


/obj/effect/proc_holder/spell/pointed/blood_siphon/can_cast(feedback = TRUE)
	return ..() && isliving(action.owner)


/obj/effect/proc_holder/spell/pointed/blood_siphon/valid_target(atom/cast_on)
	return ..() && isliving(cast_on)


/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(action.owner, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		action.owner.balloon_alert(action.owner, "spell blocked!")
		cast_on.visible_message(
			span_danger("The spell bounces off of [cast_on]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[cast_on] turns pale as a red glow envelops [cast_on.p_them()]!"),
		span_danger("You pale as a red glow enevelops you!"),
	)

	var/mob/living/living_owner = action.owner
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!iscarbon(cast_on) || !iscarbon(action.owner))
		return TRUE

	var/mob/living/carbon/human/human_user = action.owner
	for(var/obj/item/organ/external/bodypart as anything in human_user.bodyparts)
		if(prob(50))
			bodypart.stop_internal_bleeding()

		if(prob(50))
			bodypart.mend_fracture()

	return TRUE
