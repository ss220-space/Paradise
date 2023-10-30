/datum/martial_combo/throwing/remove_embended
	name = "Вытащить нож"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Вытаскивает из противника воткнувшийся предмет. Крайне мучительно для него."

/datum/martial_combo/throwing/remove_embended/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/mob/living/carbon/human/H = target
	if(!istype(H))
		return MARTIAL_COMBO_FAIL

	for(var/obj/item/organ/external/limb in H.bodyparts)
		var/obj/item/I = locate() in limb.embedded_objects
		if(!istype(I) || I.loc != H)
			continue

		var/time_taken = I.embedded_unsafe_removal_time
		user.visible_message(span_warning("[user] attempts to remove [I] from [H]'s [limb.name]."),
							span_notice("You attempt to remove [I] from [H]'s [limb.name]... (It will take [time_taken/10] seconds.)"))

		if(do_after(user, time_taken, needhand = 1, target = H))
			if(!I || !limb || I.loc != H || !(I in limb.embedded_objects))
				return MARTIAL_COMBO_FAIL
			limb.embedded_objects -= I
			limb.receive_damage(I.embedded_unsafe_removal_pain_multiplier * I.w_class)
			I.forceMove(get_turf(H))
			user.put_in_hands(I)
			H.emote("scream")
			user.visible_message(span_notice("[user] successfully rips [I] out of [H]'s [limb.name]!"),
								span_notice("You successfully remove [I] from [H]'s [limb.name]."))
			if(!H.has_embedded_objects())
				H.clear_alert("embeddedobject")
			add_attack_logs(user, target, "Melee attacked with martial-art [MA] :  Remove embended", ATKLOG_ALL)
			return MARTIAL_COMBO_DONE
	return MARTIAL_COMBO_FAIL
