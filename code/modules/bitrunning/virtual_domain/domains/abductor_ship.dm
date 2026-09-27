/datum/lazy_template/virtual_domain/abductor_ship
	name = "Корабль абдукторов"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Возьмите на абордаж корабль абдукторов и заберите всё, что плохо лежит."
	difficulty = BITRUNNER_DIFFICULTY_MEDIUM
	completion_loot = list(/obj/item/toy/plushie/greyplushie = 1)
	forced_outfit = /datum/outfit/virtual_domain_bitductor
	help_text = "Материнский корабль абдукторов по незнанию залетел во враждебные края. Сейчас они собирают снаряжение и добычу, включая ящик, чтобы убраться отсюда. Осторожнее: их оружие славится не просто так."
	is_modular = TRUE
	key = LAZY_TEMPLATE_KEY_BITRUNNING_ABDUCTOR_SHIP
	map_name = "abductor_ship"
	mob_modules = list(/datum/modular_mob_segment/abductor_agents)
	reward_points = BITRUNNER_REWARD_MEDIUM

/datum/outfit/virtual_domain_bitductor
	name = "Bitrunning Abductor"
	uniform = /obj/item/clothing/under/color/grey
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/jackboots
