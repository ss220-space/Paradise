/datum/heretic_knowledge/dream_catcher
	drafting_tier = 3
	is_shop_only = TRUE
	name = "Ловец Снов"
	desc = "Позволяет создать \"Dream Catcher\".<br>\
			Надетый обруч работает в двух режимах.<br>\
			В режиме охоты он ждёт, пока вы уснёте, и переносит вас в тело любого спящего \
			на этом уровне — на две минуты его хозяин остаётся заперт за собственными глазами.<br>\
			В режиме вызова вы выбираете любого разумного поблизости: оба тела засыпают, а вы \
			встречаетесь во сне, где выживает только один."
	transmute_text = "Преобразуйте любой головной убор, две зажжённые свечи, глаза и простыню."
	gain_text = "Спящий не защищён ничем, кроме собственной уверенности, что спит один. \
				Кодекс называет это самой дешёвой из всех дверей."
	required_atoms = list(
		/obj/item/clothing/head = 1,
		/obj/item/organ/internal/eyes = 1,
		/obj/item/bedsheet = 1,
		/obj/item/candle = 2,
	)
	result_atoms = list(/obj/item/clothing/head/dream_catcher)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/hats.dmi'
	research_tree_icon_state = "dream_catcher_node"


/datum/heretic_knowledge/dream_catcher/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle
