///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10 единиц молока"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	make_reagents = list("milk" = 10)
	category = list("initial","Еда")

/datum/design/cream
	name = "10 единиц крема"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 30)
	make_reagents = list("cream" = 10)
	category = list("initial","Еда")

/datum/design/milk_carton
	name = "Упаковка молока"
	id = "milk_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 100)
	build_path = /obj/item/reagent_containers/food/condiment/milk
	category = list("initial","Еда")

/datum/design/cream_carton
	name = "Упаковка сливок"
	id = "cream_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/reagent_containers/food/drinks/bottle/cream
	category = list("initial","Еда")

/datum/design/black_pepper
	name = "10 единиц перца"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("blackpepper" = 10)
	category = list("initial","Еда")

/datum/design/pepper_mill
	name = "Мельница для перца"
	id = "pepper_mill"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/food/condiment/peppermill
	make_reagents = list()
	category = list("initial","Еда")

/datum/design/monkey_cube
	name = "Обезьяний куб"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube
	category = list("initial", "Еда")

/datum/design/ez_nut
	name = "И-ЗИ-Нутриент"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 10)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/ez
	category = list("initial","Ботанические химикаты")

/datum/design/l4z_nut
	name = "Лефт-Фо-Зед"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/l4z
	category = list("initial","Ботанические химикаты")

/datum/design/rh_nut
	name = "Робаст-Харвест"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/rh
	category = list("initial","Ботанические химикаты")

/datum/design/weed_killer
	name = "Атразин"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/killer/weedkiller
	category = list("initial","Ботанические химикаты")

/datum/design/pest_spray
	name = "Пестициды"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/killer/pestkiller
	category = list("initial","Ботанические химикаты")

/datum/design/botany_bottle
	name = "Пустая канистра"
	id = "botany_jug"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 5)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/empty
	category = list("initial", "Ботанические химикаты")

/datum/design/cloth
	name = "Рулон ткани"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/sheet/cloth
	category = list("initial", "Органические материалы")

/datum/design/cardboard
	name = "Лист картона"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	build_path = /obj/item/stack/sheet/cardboard
	category = list("initial", "Органические материалы")

/datum/design/leather
	name = "Кожа"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 150)
	build_path = /obj/item/stack/sheet/leather
	category = list("initial", "Органические материалы")

/datum/design/hydrobelt
	name = "Ботанический пояс"
	id = "hydrobelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/botany
	category = list("initial","Кожа и ткань")

/datum/design/secbelt
	name = "Охранный пояс"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/security
	category = list("initial","Кожа и ткань")

/datum/design/medbelt
	name = "Медицинский пояс"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/medical
	category = list("initial","Кожа и ткань")

/datum/design/surbelt
	name = "Хирургический пояс"
	id = "surbel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/medical/surgery
	category = list("initial","Кожа и ткань")

/datum/design/janibelt
	name = "Уборочный пояс"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/janitor
	category = list("initial","Кожа и ткань")

/datum/design/s_holster
	name = "Плечевая кобура"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/clothing/accessory/holster
	category = list("initial","Кожа и ткань")

/datum/design/k_holster
	name = "Ножевая кобура"
	id = "k_holster"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/clothing/accessory/holster/knives
	category = list("initial","Кожа и ткань")

/datum/design/webbing
	name = "Разгрузка"
	id = "webbing"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/clothing/accessory/storage/webbing
	category = list("initial","Кожа и ткань")

/datum/design/brown_vest
	name = "Черный жилет"
	id = "brown_vest"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 800)
	build_path = /obj/item/clothing/accessory/storage/brown_vest
	category = list("initial","Кожа и ткань")

/datum/design/black_vest
	name = "Коричневый жилет"
	id = "black_vest"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 800)
	build_path = /obj/item/clothing/accessory/storage/black_vest
	category = list("initial","Кожа и ткань")

/datum/design/rice_hat
	name = "Рисовая шляпа"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/clothing/head/rice_hat
	category = list("initial","Кожа и ткань")

/datum/design/rollingpapers
	name = "Упаковка рулонной бумаги"
	id = "rolling_paper_pack"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/storage/fancy/rollingpapers
	category = list("initial","Органические материалы")
