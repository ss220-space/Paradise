/obj/item/implant/traitor
	name = "Mindslave Bio-chip"
	desc = "Divide and Conquer"
	implant_state = "implant-syndicate"
	origin_tech = "programming=5;biotech=5;syndicate=8"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/traitor
	/// The UID of the mindslave's `mind`. Stored to solve GC race conditions and ensure we can remove their mindslave status even when they're deleted or gibbed.
	var/mindslave_UID


/obj/item/implant/traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user, force = FALSE)
	// Check `implanted` here so you can't just keep taking it out and putting it back into other people.
	if(implanted == BIOCHIP_USED || !ishuman(mindslave_target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	// If the target is catatonic or doesn't have a mind, don't let them use it
	if(!mindslave_target.mind)
		to_chat(user, span_warning("<i>This person doesn't have a mind for you to slave!</i>"))
		return FALSE

	// Fails if they're already a mindslave of someone, or if they're mindshielded.
	if(ismindslave(mindslave_target) || ismindshielded(mindslave_target) || isvampirethrall(mindslave_target))
		mindslave_target.visible_message(
			span_warning("[mindslave_target] seems to resist the bio-chip!"),
			span_warning("You feel a strange sensation in your head that quickly dissipates."),
		)
		qdel(src)
		return FALSE

	// Mindslaving yourself.
	if(mindslave_target == user)
		to_chat(user, span_notice("Making yourself loyal to yourself was a great idea! Perhaps even the best idea ever! Actually, you just feel like an idiot."))
		user.adjustBrainLoss(20)
		qdel(src)
		return FALSE

	// Create a new mindslave datum for the target with the user as their master.
	var/datum/antagonist/mindslave/slave_datum = new(user.mind)
	slave_datum.special = TRUE
	mindslave_target.mind.add_antag_datum(slave_datum)
	mindslave_UID = mindslave_target.mind.UID()
	log_admin("[key_name_admin(user)] has mind-slaved [key_name_admin(mindslave_target)].")
	return ..()


/obj/item/implant/traitor/removed(mob/target)
	. = ..()
	var/datum/mind/the_slave = locateUID(mindslave_UID)
	the_slave?.remove_antag_datum(/datum/antagonist/mindslave)


/obj/item/implanter/traitor
	name = "bio-chip implanter (Mindslave)"
	imp = /obj/item/implant/traitor


/obj/item/implantcase/traitor
	name = "bio-chip case - 'Mindslave'"
	desc = "A glass case containing a mindslave bio-chip."
	imp = /obj/item/implant/traitor

