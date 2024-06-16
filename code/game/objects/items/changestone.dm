/obj/item/changestone
	name = "An uncut ruby"
	desc = "The ruby shines and catches the light, despite being uncut"
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "changerock"
	var/used = FALSE

/obj/item/changestone/attack_hand(var/mob/user as mob)
	if(!ishuman(user))
		to_chat(usr, span_warning("You cannot handle with [src]"))
		return ..()

	if(used)
		to_chat(usr, span_warning("[src] has already been used"))
		return ..()

	var/mob/living/carbon/human/H = user

	if(H.gloves)
		to_chat(usr, span_warning("Your [H.gloves] have blocked [src] power"))
		return ..()

	if(H.gender == FEMALE)
		H.change_gender(MALE)
	else
		H.change_gender(FEMALE)

	used = TRUE
	H.set_species(get_random_species())
	H.dna.ready_dna(H)
	H.update_body()
	to_chat(usr, span_danger("The power of [src] has affected you!"))
	to_chat(usr, span_notice("You are now [H.dna.species]!"))
	desc += ". That one looks used"
	..()






