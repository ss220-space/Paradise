/datum/keybinding/human
	category = KB_CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/human/toggle_holster
	name = "Использовать кобуру"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	if(!M.w_uniform)
		return
	var/obj/item/clothing/accessory/holster/H = locate() in M.w_uniform
	H?.holster_verb()

/datum/keybinding/human/change_attack
	name = "Выбор безоружной атаки"
	keys = list("Y")

/datum/keybinding/human/change_attack/down(client/C)
	. = ..()

	var/mob/living/carbon/human/H = C.mob
	if(!H?.dna?.species?.available_attacks)
		return

	var/list/params = list()
	for(var/key in H.dna.species.available_attacks)
		var/datum/unarmed_attack/attack = H.dna.species.available_attacks[key]
		params[key] = image(icon = 'icons/mob/actions/actions.dmi', icon_state = attack.icon_state)

	var/choice = show_radial_menu(H, H, params, radius = 40)

	H.dna.species.choosen_attack = H.dna.species.available_attacks[choice]
