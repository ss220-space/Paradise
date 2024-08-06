/obj/item/laser_eyes_injector
	name = "laser eyes injector"
	desc = "Инжектор позволяющий вам стрелять лазерами из глаз после исспользования."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnainjector"
	var/used = FALSE

/obj/item/laser_eyes_injector/update_icon_state()
	icon_state = "dnaupgrader[used ? "0" : ""]"

/obj/item/laser_eyes_injector/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)

/obj/item/laser_eyes_injector/attack(mob/M, mob/user)
	if(used)
		to_chat(user, "<span class='warning'>Этот инжектор уже использован!</span>")
		return FALSE
	if(!M.dna) //You know what would be nice? If the mob you're injecting has DNA, and so doesn't cause runtimes.
		return FALSE
	if(ishuman(M)) // Would've done this via species instead of type, but the basic mob doesn't have a species, go figure.
		var/mob/living/carbon/human/H = M
		if(NO_DNA in H.dna.species.species_traits)
			return FALSE
	else
		return FALSE
	if(!used)
		ADD_TRAIT(M, TRAIT_LASEREYES, "laser_eyes_injector")
		to_chat(M, "<span class='warning'>Вы чувствуете легкое жжение в глазах.</span>")
		used = TRUE
		icon_state = "dnainjector0"
	else
		to_chat(user, span_notice("Этот инжектор уже исспользован."))
