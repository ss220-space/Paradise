/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list(SPECIES_MONKEY)

/mob/living/carbon/human/lesser/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot_if_possible(new /obj/item/clothing/under/punpun(src), ITEM_SLOT_CLOTH_INNER)
	tts_seed = "Chen"

/mob/living/carbon/human/lesser/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	update_transform(0.8)
	tts_seed = "Chen"
