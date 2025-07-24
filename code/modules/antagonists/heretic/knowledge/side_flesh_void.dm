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
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "blood_siphon"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/blood_siphon
	cost = 1


/datum/heretic_knowledge/spell/void_prison
	name = "Пустотная Тюрьма"
	desc = "Даёт вам «Пустотную Тюрьму» — заклинание, заключающее вашу жертву в шар, \
			лишая её возможности что-либо делать или говорить."
	gain_text = "Я вижу себя, вальсирующего по заснеженной улице. \
				Я пытаюсь кричать, пытаюсь схватить этого дурака, пытаюсь сказать ему, чтобы он бежал. \
				Моё улыбающееся лицо поворачивается ко мне, отражая в остекленевших глазах пустоту - путь по которому я шел."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "voidball"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_prison
	cost = 1


/datum/heretic_knowledge/spell/cleave
	name = "Расчленение"
	desc = "Даёт вам «Рассечение» — заклинание, действующее по области, \
			вызывающее внутреннее кровотечение и кровопотерю у любого, кого оно затронуло."
	gain_text = "Сначала я не понимал, как использовать эти орудия войны, но священник \
				велел мне научиться. Скоро, сказал он, я овладею ими в совершенстве."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "cleave"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1


