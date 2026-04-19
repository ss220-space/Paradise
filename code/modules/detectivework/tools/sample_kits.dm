/obj/item/forensics
	icon = 'icons/obj/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/sample
	name = "forensic sample"
	icon = 'icons/obj/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/evidence = list()

/obj/item/sample/New(newloc, atom/supplied)
	..(newloc)
	if(supplied)
		copy_evidence(supplied)
		name = "[initial(name)] (\the [supplied])"

/obj/item/sample/print/New(newloc, atom/supplied)
	..(newloc, supplied)
	if(evidence && length(evidence))
		icon_state = "fingerprint1"

/obj/item/sample/proc/copy_evidence(atom/supplied)
	if(supplied.time_of_touch && length(supplied.time_of_touch))
		evidence = supplied.time_of_touch.Copy()
		supplied.suit_fibers.Cut()
		supplied.time_of_touch.Cut()

/obj/item/sample/proc/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied.evidence || !length(supplied.evidence))
		return 0
	evidence |= supplied.evidence
	name = ("[initial(name)] (combined)")
	to_chat(user, span_notice("You transfer the contents of \the [supplied] into \the [src]."))
	return 1

/obj/item/sample/print/merge_evidence(obj/item/sample/supplied, mob/user)
	if(!supplied.evidence || !length(supplied.evidence))
		return 0
	for(var/print in supplied.evidence)
		if(evidence[print])
			evidence[print] = stringmerge(evidence[print],supplied.evidence[print])
		else
			evidence[print] = supplied.evidence[print]
	name = ("[initial(name)] (combined)")
	to_chat(user, span_notice("You overlay \the [src] and \the [supplied], combining the print records."))
	return 1

/obj/item/sample/attackby(obj/item/I, mob/user, params)
	if(I.type == type)
		if(!user.can_unEquip(I) || !merge_evidence(I, user))
			return ..()
		user.drop_transfer_item_to_loc(I, src)
		add_fingerprint(user)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/sample/fibers
	name = "fiber bag"
	desc = "Used to hold fiber evidence for the detective."
	icon_state = "fiberbag"

/obj/item/sample/print
	name = "fingerprint card"
	desc = "Records a set of fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	item_state = "paper"

/obj/item/sample/print/attack_self(mob/user)
	if(evidence && length(evidence))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.gloves)
		to_chat(user, span_warning("Take \the [H.gloves] off first."))
		return

	to_chat(user, span_notice("You firmly press your fingertips onto the card."))
	var/fullprint = H.get_full_print()
	evidence[fullprint] = fullprint
	name = ("[initial(name)] (\the [H])")
	icon_state = "fingerprint1"

/obj/item/sample/print/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(length(evidence))
		return .

	if(target.gloves)
		to_chat(user, span_warning("[target] is wearing gloves."))
		return .

	if(user != target && target.a_intent != INTENT_HELP && target.body_position != LYING_DOWN)
		user.visible_message(span_danger("[user] tries to take prints from [target], but they move away."))
		return .

	if(user.zone_selected != BODY_ZONE_PRECISE_L_HAND || user.zone_selected != BODY_ZONE_PRECISE_R_HAND)
		to_chat(user, span_warning("You need to select a hand to take prints from."))
		return .

	if(!target.get_organ(user.zone_selected))
		to_chat(user, span_warning("This hand is absent."))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	user.visible_message(
		span_notice("[user] takes a copy of [target]'s fingerprints."),
		span_notice("You take a copy of [target]'s fingerprints."),
	)
	var/fullprint = target.get_full_print()
	evidence[fullprint] = fullprint
	copy_evidence(src)
	name = "[initial(name)] ([target])"
	icon_state = "fingerprint1"

/obj/item/sample/print/copy_evidence(atom/supplied)
	if(supplied.fingerprints_time && length(supplied.fingerprints_time))
		evidence = supplied.fingerprints_time.Copy()
		supplied.fingerprints.Cut()
		supplied.fingerprints_time.Cut()

/obj/item/forensics/sample_kit
	name = "fiber collection kit"
	desc = "A magnifying glass and tweezers. Used to lift suit fibers."
	icon_state = "m_glass"
	w_class = WEIGHT_CLASS_SMALL
	var/evidence_type = "fiber"
	var/evidence_path = /obj/item/sample/fibers

/obj/item/forensics/sample_kit/proc/can_take_sample(mob/user, atom/supplied)
	return (supplied.suit_fibers && length(supplied.suit_fibers))

/obj/item/forensics/sample_kit/proc/take_sample(mob/user, atom/supplied)
	var/obj/item/sample/S = new evidence_path(get_turf(user), supplied)
	to_chat(user, span_notice("You transfer [length(S.evidence)] [length(S.evidence) > 1 ? "[evidence_type]s" : "[evidence_type]"] to \the [S]."))

/obj/item/forensics/sample_kit/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(can_take_sample(user, target))
		take_sample(user, target)
		return TRUE
	else
		to_chat(user, span_warning("You are unable to locate any [evidence_type]s on \the [target]."))
		return ..()

/obj/item/forensics/sample_kit/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	. = ..()
	if(!.)
		return FALSE

	if(is_screen_atom(over_object))
		return FALSE

	if(loc != user || !ishuman(user))
		return FALSE

	afterattack(over_object, user, TRUE, params)
	return TRUE

/obj/item/forensics/sample_kit/powder
	name = "fingerprint powder"
	desc = "A jar containing aluminum powder and a specialized brush."
	icon_state = "dust"
	evidence_type = "fingerprint"
	evidence_path = /obj/item/sample/print

/obj/item/forensics/sample_kit/powder/can_take_sample(mob/user, atom/supplied)
	return (supplied.fingerprints && length(supplied.fingerprints))
