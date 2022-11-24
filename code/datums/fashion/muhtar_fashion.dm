/datum/fashion/muhtar_fashion/apply(mob/living/simple_animal/pet/dog/D)
	..()

/datum/fashion/muhtar_fashion/head
	icon_file = 'icons/mob/muhtar_accessories.dmi'

/datum/fashion/muhtar_fashion/mask
	icon_file = 'icons/mob/muhtar_accessories.dmi'

/datum/fashion/muhtar_fashion/head/detective
	name = "Детектив REAL_NAME"
	desc = "NAME sees through your lies..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")

/datum/fashion/muhtar_fashion/mask/cigar
	obj_icon_state = "cigar"
	is_animated_fashion = TRUE

/datum/fashion/muhtar_fashion/head/beret
	name = "Лейтенант REAL_NAME"
	obj_icon_state = "beret"
