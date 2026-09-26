///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10 ед. молока"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("milk" = 10)
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/cream
	name = "10 ед. сливок"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("cream" = 10)
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/sodiumchloride
	name = "10 ед. соли"
	id = "sodiumchloride"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("sodiumchloride" = 10)
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/black_pepper
	name = "10 ед. чёрного перца"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	make_reagents = list("blackpepper" = 10)
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/milk_carton
	name = "Упаковка молока"
	id = "milk_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/food/condiment/milk
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/cream_carton
	name = "Упаковка сливок"
	id = "cream_carton"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/food/drinks/bottle/cream
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/salt_shaker
	name = "Солонка"
	id = "salt_shaker"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/food/condiment/saltshaker
	make_reagents = list()
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)

/datum/design/pepper_mill
	name = "Перечница"
	id = "pepper_mill"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/food/condiment/peppermill
	make_reagents = list()
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_FOOD)
/datum/design/monkey_cube
	name = "Куб шимпанзе"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CUBES)

/datum/design/farwa_cube
	name = "Куб фарвы"
	id = "fcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/farwacube
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CUBES)

/datum/design/wolpin_cube
	name = "Куб вульпина"
	id = "wcube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/wolpincube
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CUBES)

/datum/design/stok_cube
	name = "Куб стока"
	id = "scube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/stokcube
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CUBES)

/datum/design/neaera_cube
	name = "Куб неары"
	id = "ncube"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CUBES)

/datum/design/ez_nut
	name = "E-Z-Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 10)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/ez
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/l4z_nut
	name = "Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 20)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/l4z
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/rh_nut
	name = "Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 25)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/rh
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/weed_killer
	name = "Weed Killer"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/killer/weedkiller
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/pest_spray
	name = "Pest Killer"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/killer/pestkiller
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/botany_bottle
	name = "Пустая канистра"
	id = "botany_jug"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 5)
	build_path = /obj/item/reagent_containers/glass/bottle/nutrient/empty
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_CHEMICALS)

/datum/design/cloth
	name = "Ткань"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/sheet/cloth
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_ORGANIC)

/datum/design/cardboard
	name = "Картон"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/sheet/cardboard
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_ORGANIC)

/datum/design/leather
	name = "Кожа"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/sheet/leather
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_ORGANIC)

/datum/design/wrapper
	name = "Обёрточная бумага"
	id = "wrapper"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/stack/packageWrap
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_ORGANIC)

/datum/design/rollingpapers
	name = "Бумага для самокруток"
	id = "rolling_paper_pack"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 50)
	build_path = /obj/item/storage/fancy/rollingpapers
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_ORGANIC)

/datum/design/rice_hat
	name = "Рисовая шляпа"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/clothing/head/rice_hat
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/hydrobelt
	name = "Пояс ботаника"
	id = "hydrobelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/botany
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/secbelt
	name = "Пояс охраны"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/security
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/medbelt
	name = "Пояс медика"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/medical
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/surbelt
	name = "Пояс хирурга"
	id = "surbel"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/medical/surgery
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/janibelt
	name = "Пояс уборщика"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 300)
	build_path = /obj/item/storage/belt/janitor
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/s_holster
	name = "Наплечная кобура"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/clothing/accessory/holster
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/k_holster
	name = "Кобура для ножа"
	id = "k_holster"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 400)
	build_path = /obj/item/clothing/accessory/holster/knives
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/webbing
	name = "Разгрузка"
	id = "webbing"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 500)
	build_path = /obj/item/clothing/accessory/storage/webbing
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/brown_vest
	name = "Коричневая разгрузка"
	id = "brown_vest"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 800)
	build_path = /obj/item/clothing/accessory/storage/brown_vest
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)

/datum/design/black_vest
	name = "Чёрная разгрузка"
	id = "black_vest"
	build_type = BIOGENERATOR
	materials = list(MAT_BIOMASS = 800)
	build_path = /obj/item/clothing/accessory/storage/black_vest
	category = list(PRINTER_CATEGORY_INITIAL, BIOGEN_LEATHER_CLOTH)
