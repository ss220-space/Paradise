/datum/lazy_template/virtual_domain/xeno_nest
	name = "Заражение ксеносами"
	cost = BITRUNNER_COST_LOW
	desc = "Сканеры корабля засекли формы жизни неизвестного происхождения. Мирные попытки связаться провалились."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/toy/plushie/rouny = 1)
	help_text = "Вы на голой планете, полной враждебных тварей. Ящик здесь, он не спрятан — просто хорошо охраняется. Ждите сопротивления."
	is_modular = TRUE
	key = LAZY_TEMPLATE_KEY_BITRUNNING_XENO_NEST
	map_name = "xeno_nest"
	mob_modules = list(/datum/modular_mob_segment/xenos)
	reward_points = BITRUNNER_REWARD_LOW
