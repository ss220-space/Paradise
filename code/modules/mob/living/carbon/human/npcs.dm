/obj/item/clothing/under/punpun
	name = "fancy uniform"
	desc = "It looks like it was tailored for a monkey."
	icon_state = "punpun"
	item_color = "punpun"
	species_restricted = list(SPECIES_MONKEY)
	species_exception = list(/datum/species/monkey)

/mob/living/carbon/human/lesser/monkey/punpun/Initialize(mapload)
	. = ..()
	name = "Pun Pun"
	real_name = name
	equip_to_slot_if_possible(new /obj/item/clothing/under/punpun(src), SLOT_HUD_JUMPSUIT)
	tts_seed = "Chen"

/mob/living/carbon/human/lesser/monkey/teeny/Initialize(mapload)
	. = ..()
	name = "Mr. Teeny"
	real_name = name
	resize = 0.8
	update_transform()
	tts_seed = "Chen"
