/obj/item/implant/mindshield
	name = "mindshield bio-chip"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	implant_state = "implant-nanotrasen"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/mindshield


/obj/item/implant/mindshield/implant(mob/living/target, mob/user, force = FALSE)
	. = ..()
	if(!.)
		return .

	if(is_shadow_or_thrall(target))
		target.visible_message(
			span_warning("[target] seems to resist the implant!"),
			span_warning("You feel the corporate tendrils of Nanotrasen try to invade your mind!"),
		)
		removed(target, silent = TRUE)
		qdel(src)

	else if(is_cultist(target) || is_head_revolutionary(target))
		to_chat(target, span_warning("You feel the corporate tendrils of Nanotrasen try to invade your mind!"))

	else if(is_revolutionary(target))
		SSticker.mode.remove_revolutionary(target.mind)

	else
		to_chat(target, span_notice("Your mind feels hardened - more resistant to brainwashing."))


/obj/item/implant/mindshield/removed(mob/target, silent = FALSE)
	. = ..()
	if(. && target.stat != DEAD && !silent)
		to_chat(target, span_boldnotice("Your mind softens. You feel susceptible to the effects of brainwashing once more."))


/obj/item/implanter/mindshield
	name = "bio-chip implanter (mindshield)"
	imp = /obj/item/implant/mindshield


/obj/item/implantcase/mindshield
	name = "bio-chip case - 'mindshield'"
	desc = "A glass case containing a mindshield bio-chip."
	imp = /obj/item/implant/mindshield


/**
 * ERT mindshield
 */
/obj/item/implant/mindshield/ert
	name = "ERT-mindshield bio-chip"
	desc = "Stops people messing with your mind and allows to use some high-tech weapons."
	implant_data = /datum/implant_fluff/mindshield/ert


/obj/item/implanter/mindshield/ert
	name = "bio-chip implanter (ERT-mindshield)"
	imp = /obj/item/implant/mindshield/ert


/obj/item/implantcase/mindshield/ert
	name = "bio-chip case - 'ERT-mindshield'"
	desc = "A glass case containing an ERT mindshield bio-chip."
	imp = /obj/item/implant/mindshield/ert

