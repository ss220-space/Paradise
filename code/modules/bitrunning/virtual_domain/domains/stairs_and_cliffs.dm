/datum/lazy_template/virtual_domain/stairs_and_cliffs
	name = "Ледниковый подъём"
	cost = BITRUNNER_COST_LOW
	desc = "Отвесный ледник, который пережили немногие икры. Зато кардио."
	help_text = "Слыхали про «Змейки и лестницы»? Здесь то же самое, только вместо лестниц — лестницы, а вместо змей — обрыв в острые камни или в плазменное озеро."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/clothing/suit/snowman = 2)
	secondary_loot = list(/obj/item/clothing/shoes/winterboots = 2, /obj/item/clothing/head/ushanka = 1)
	forced_outfit = /datum/outfit/virtual_domain_iceclimber
	key = LAZY_TEMPLATE_KEY_BITRUNNING_STAIRS_AND_CLIFFS
	map_name = "stairs_and_cliffs"
	reward_points = BITRUNNER_REWARD_MEDIUM
	domain_flags = DOMAIN_NO_NOHIT_BONUS

/turf/simulated/floor/cliff/snowrock/virtual_domain
	baseturf = /turf/simulated/floor/cliff/snowrock/virtual_domain

/turf/simulated/floor/lava/virtual_domain
	name = "plasma lake"
	baseturf = /turf/simulated/floor/lava/virtual_domain

/turf/simulated/floor/lava/virtual_domain/get_ru_names()
	return alist(
		NOMINATIVE = "плазменное озеро",
		GENITIVE = "плазменного озера",
		DATIVE = "плазменному озеру",
		ACCUSATIVE = "плазменное озеро",
		INSTRUMENTAL = "плазменным озером",
		PREPOSITIONAL = "плазменном озере",
	)

/datum/outfit/virtual_domain_iceclimber
	name = "Ice Climber"
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack/duffel
	shoes = /obj/item/clothing/shoes/winterboots
