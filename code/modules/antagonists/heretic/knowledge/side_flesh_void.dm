/datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/flesh
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/void

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/void_cloak
	tier2 = /datum/heretic_knowledge/spell/blood_siphon
	tier3 = list(/datum/heretic_knowledge/spell/void_prison, /datum/heretic_knowledge/spell/cleave)

// Sidepaths for knowledge between Flesh and Void.

/datum/heretic_knowledge/void_cloak
	name = "Плащ Пустоты"
	desc = "Позволяет преобразовать осколок стекла, простыню и любой предмет верхней одежды чтобы создать \
			Плащ Пустоты. Пока капюшон опущен, плащ позволяет колдовать без амулета. \
			Он также обеспечивает хорошую броню и \
			имеет карманы, в которые можно положить один из ваших клинков или различные ритуальные \
			принадлежности (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова — хранительница того, что на практике не совсем так, но теоретически таковым является. \
				И многие вещи таковыми являются." // Wtf. In English its also too strange.

	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/armor.dmi'
	research_tree_icon_state = "void_cloak"


/datum/heretic_knowledge/spell/blood_siphon
	name = "Вампиризм"
	desc = "Дарует вам «Вампиризм» — заклинание, высасывающее кровь и здоровье жертвы и передающее их вам. \
			Также есть шанс передать раны от вас жертве."
	gain_text = "«Все мы разные, но кровь у всех идет одинаково». Так мне сказал маршал."

	spell_to_add = /obj/effect/proc_holder/spell/pointed/blood_siphon
	cost = 1


/datum/heretic_knowledge/spell/void_prison
	name = "Пустотная Тюрьма"
	desc = "Даёт вам «Пустотную Тюрьму» — заклинание, заключающее вашу жертву в шар, \
			лишая её возможности что-либо делать или говорить."
	gain_text = "At first, I see myself, waltzing along a snow-laden street. \
		I try to yell, grab hold of this fool and tell them to run. \
		But the only welts made are on my own beating fist. \
		My smiling face turns to regard me, reflecting back in glassy eyes the empty path I have been lead down."

	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_prison
	cost = 1


/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an area-of-effect targeted spell \
		that causes heavy bleeding and blood loss to anyone afflicted."
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
		told me to use them regardless. Soon, he said, I would know them well."

	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1


