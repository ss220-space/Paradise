/obj/item/implant/suppression
	name = "suppression bio-chip"
	desc = "Подавляет навыки боевых искусств, сохраняя при этом их ограничения."
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_state = "implant-nanotrasen"
	implant_data = /datum/implant_fluff/suppression
	allow_multiple = FALSE

/obj/item/implant/suppression/implant(mob/living/target, mob/user, force = FALSE)
	. = ..()
	if(.)
		ADD_TRAIT(target, TRAIT_MARTIAL_ARTS_SUPPRESSED, UNIQUE_TRAIT_SOURCE(src))
		to_chat(target, span_warning("Ваши навыки боевых искусств кажутся... подавленными."))

/obj/item/implant/suppression/removed(mob/living/target)
	. = ..()
	if(.)
		REMOVE_TRAIT(target, TRAIT_MARTIAL_ARTS_SUPPRESSED, UNIQUE_TRAIT_SOURCE(src))
		to_chat(target, span_notice("Ваши навыки боевых искусств возвращаются в норму."))

/obj/item/implanter/suppression
	name = "bio-chip implanter (suppression)"
	imp = /obj/item/implant/suppression

/obj/item/implantcase/suppression
	name = "bio-chip case - 'Suppression'"
	desc = "A glass case containing a suppression bio-chip."
	imp = /obj/item/implant/suppression
