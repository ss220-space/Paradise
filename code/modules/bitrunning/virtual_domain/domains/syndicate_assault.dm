/datum/lazy_template/virtual_domain/syndicate_assault
	name = "Штурм Синдиката"
	announce_to_ghosts = TRUE
	cost = BITRUNNER_COST_MEDIUM
	desc = "Взять вражеский корабль на абордаж и вернуть украденный груз."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plushie/nukeplushie = 1)
	help_text = "Оперативники Синдиката вынесли со станции ценный груз и уходят на своём корабле. Проникните на борт и заберите ящик обратно. Осторожно: они вооружены до зубов."
	is_modular = TRUE
	key = LAZY_TEMPLATE_KEY_BITRUNNING_SYNDICATE_ASSAULT
	map_name = "syndicate_assault"
	mob_modules = list(/datum/modular_mob_segment/syndicate_team)
	reward_points = BITRUNNER_REWARD_MEDIUM
