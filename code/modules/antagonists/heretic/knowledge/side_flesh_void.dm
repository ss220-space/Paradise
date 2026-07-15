/datum/heretic_knowledge/void_cloak
	drafting_tier = 1
	name = "Плащ Пустоты"
	desc = "Позволяет преобразовать осколок стекла, простыню и любой предмет верхней одежды чтобы создать \
			Плащ Пустоты. Пока капюшон опущен, плащ служит источником фокуса. \
			Он также обеспечивает хорошую броню и \
			имеет карманы, в которые можно положить один из ваших клинков или различные ритуальные \
			принадлежности (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова — хранительница вещей не вполне практичных, но по крайней мере теоретичных. \
				На удивление, многие вещи являются таковыми."

	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "void_cloak"


/datum/heretic_knowledge/spell/cleave
	drafting_tier = 4
	name = "Кровавое Рассечение" // Crimson Cleave
	desc = "Даёт вам \"Кровавое рассечение\", направленное заклинание, вытягивающее здоровье \
			в небольшой области вокруг цели. При применении очищает все ваши раны."
	gain_text = "Сначала я не понимал, как использовать эти орудия войны, но священник \
				велел мне научиться. Скоро, сказал он, я овладею ими в совершенстве."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "blood_siphon"
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 2


