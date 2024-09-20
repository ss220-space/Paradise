/datum/keybinding/human
	category = KB_CATEGORY_HUMAN


/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)


/datum/keybinding/human/toggle_holster
	name = "Использовать кобуру"
	keys = list("H")


/datum/keybinding/human/toggle_holster/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/carbon/human/human_mob = user.mob
	if(!human_mob.w_uniform)
		return TRUE
	var/obj/item/clothing/accessory/holster/holster = locate() in human_mob.w_uniform
	holster?.holster_verb()
	return TRUE

