/obj/item/implanter/cling_hivemind
	name = "bio-chip implanter (Hivemind)"
	desc = "На боку едва заметная гравировка \"Tiger Cooperative\"."
	imp = /obj/item/implant/borer

/obj/item/implant/cling_hivemind
	name = "Hivemind Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;bluespace=5;syndicate=2"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/cling_hivemind

/obj/item/implant/cling_hivemind/implant(mob/living/carbon/human/target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	target.add_language(LANGUAGE_HIVE_CHANGELING)
	target.add_language(LANGUAGE_HIVE_EVENTLING)
	return ..()

/obj/item/implant/cling_hivemind/removed(mob/living/carbon/human/source)
	imp_in.remove_language(LANGUAGE_HIVE_CHANGELING)
	imp_in.remove_language(LANGUAGE_HIVE_EVENTLING)
	return ..()
