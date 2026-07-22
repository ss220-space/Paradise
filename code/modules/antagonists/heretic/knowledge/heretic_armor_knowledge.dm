/datum/heretic_knowledge/armor
	abstract_type = /datum/heretic_knowledge/armor
	name = "Ритуал Оружейника"
	desc = "Позволяет преобразовать стол и противогаз в \"Потустороннюю броню\". \
			\"Потусторонняя броня\" обеспечивает отличную защиту, а при надетом капюшоне \
			служит источником фокуса."
	gain_text = "Ржавые Холмы щедро встретили Кузнеца. И Кузнец ответил им взаимностью."

	required_atoms = list(
		/obj/structure/table = 1,
		/obj/item/clothing/mask/gas = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "eldritch_armor"
	research_tree_icon_frame = 12


/datum/heretic_knowledge/armor/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	our_heretic?.set_passive_level(2)
	our_heretic?.gain_knowledge(/datum/heretic_knowledge/knowledge_ritual)
