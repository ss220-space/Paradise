/obj/item/changestone
	name = "An uncut ruby"
	desc = "The ruby shines and catches the light, despite being uncut."
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "changerock"
	var/used = FALSE

/obj/item/changestone/attack_hand(var/mob/user as mob)
	if(!ishuman(user))
		to_chat(user, span_warning("You cannot handle with [src]."))
		return ..()

	if(used)
		to_chat(user, span_warning("[src] has already been used."))
		return ..()

	var/mob/living/carbon/human/H = user

	if(H.gloves)
		return ..()

	if(H.gender == FEMALE)
		H.change_gender(MALE)
	else
		H.change_gender(FEMALE)

	if(H.set_species(get_random_species()))
		used = TRUE
		to_chat(user, span_danger("The power of the [src] has affected you!"))
		to_chat(user, span_notice("You are now [H.dna.species]!"))
		update_appearance(UPDATE_DESC)
		..()

/obj/item/changestone/update_desc(updates = ALL)
	. = ..()
	desc += " That one looks used."





