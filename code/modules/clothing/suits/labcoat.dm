/obj/item/clothing/suit/storage/labcoat
	name = "labcoat"
	desc = "Стерильный белый халат. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат",
		GENITIVE = "лабораторного халата",
		DATIVE = "лабораторному халату",
		ACCUSATIVE = "лабораторный халат",
		INSTRUMENTAL = "лабораторным халатом",
		PREPOSITIONAL = "лабораторном халате"
	)
	icon_state = "labcoat_open"
	item_state = "labcoat_open"
	ignore_suitadjust = FALSE
	permeability_coefficient = 0.5
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/analyzer,/obj/item/stack/medical,/obj/item/dnainjector,/obj/item/reagent_containers/dropper,/obj/item/reagent_containers/syringe,/obj/item/reagent_containers/hypospray,/obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/food/pill,/obj/item/storage/pill_bottle,/obj/item/paper,/obj/item/rad_laser)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 50, "acid" = 50)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/labcoat/cmo
	name = "chief medical officer's labcoat"
	desc = "Стерильный лабораторный халат. Окрашен в синие цвета."
	ru_names = list(
		NOMINATIVE = "лабораторный халат главного врача",
		GENITIVE = "лабораторного халата главного врача",
		DATIVE = "лабораторному халату главного врача",
		ACCUSATIVE = "лабораторный халат главного врача",
		INSTRUMENTAL = "лабораторным халатом главного врача",
		PREPOSITIONAL = "лабораторном халате главного врача"
	)
	icon_state = "labcoat_cmo_open"
	item_state = "labcoat_cmo_open"

/obj/item/clothing/suit/storage/labcoat/mad
	name = "mad scientist's labcoat"
	desc = "Ношение этого халата побуждает в вас желание врезать кому-нибудь по башке и выбросить его тело в космос."
	ru_names = list(
		NOMINATIVE = "лабораторный халат безумного учёного",
		GENITIVE = "лабораторного халата безумного учёного",
		DATIVE = "лабораторному халату безумного учёного",
		ACCUSATIVE = "лабораторный халат безумного учёного",
		INSTRUMENTAL = "лабораторным халатом безумного учёного",
		PREPOSITIONAL = "лабораторном халате безумного учёного"
	)
	icon_state = "labcoat_green_open"
	item_state = "labcoat_green_open"

/obj/item/clothing/suit/storage/labcoat/genetics
	name = "geneticist labcoat"
	desc = "Стерильный белый халат с голубыми нашивками на плечах. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат генетика",
		GENITIVE = "лабораторного халата генетика",
		DATIVE = "лабораторному халату генетика",
		ACCUSATIVE = "лабораторный халат генетика",
		INSTRUMENTAL = "лабораторным халатом генетика",
		PREPOSITIONAL = "лабораторном халате генетика"
	)
	icon_state = "labcoat_gen_open"
	item_state = "labcoat_gen_open"

/obj/item/clothing/suit/storage/labcoat/chemist
	name = "chemist labcoat"
	desc = "Стерильный белый халат с оранжевыми нашивками на плечах. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат химика",
		GENITIVE = "лабораторного халата химика",
		DATIVE = "лабораторному халату химика",
		ACCUSATIVE = "лабораторный халат химика",
		INSTRUMENTAL = "лабораторным халатом химика",
		PREPOSITIONAL = "лабораторном халате химика"
	)
	icon_state = "labcoat_chem_open"
	item_state = "labcoat_chem_open"

/obj/item/clothing/suit/storage/labcoat/virologist
	name = "virologist labcoat"
	desc = "Стерильный белый халат с зелёными нашивками на плечах. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат вирусолога",
		GENITIVE = "лабораторного халата вирусолога",
		DATIVE = "лабораторному халату вирусолога",
		ACCUSATIVE = "лабораторный халат вирусолога",
		INSTRUMENTAL = "лабораторным халатом вирусолога",
		PREPOSITIONAL = "лабораторном халате вирусолога"
	)
	icon_state = "labcoat_vir_open"

/obj/item/clothing/suit/storage/labcoat/science
	name = "scientist labcoat"
	desc = "Стерильный белый халат с фиолетовыми нашивками на плечах. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат учёного",
		GENITIVE = "лабораторного халата учёного",
		DATIVE = "лабораторному халату учёного",
		ACCUSATIVE = "лабораторный халат учёного",
		INSTRUMENTAL = "лабораторным халатом учёного",
		PREPOSITIONAL = "лабораторном халате учёного"
	)
	icon_state = "labcoat_tox_open"
	item_state = "labcoat_tox_open"

/obj/item/clothing/suit/storage/labcoat/mortician
	name = "coroner labcoat"
	desc = "Стерильный белый халат с чёрными нашивками на плечах. Защищает тело и одежду от попадания на неё опасных реагентов."
	ru_names = list(
		NOMINATIVE = "лабораторный халат патологоанатома",
		GENITIVE = "лабораторного халата патологоанатома",
		DATIVE = "лабораторному халату патологоанатома",
		ACCUSATIVE = "лабораторный халат патологоанатома",
		INSTRUMENTAL = "лабораторным халатом патологоанатома",
		PREPOSITIONAL = "лабораторном халате патологоанатома"
	)
	icon_state = "labcoat_mort_open"
	item_state = "labcoat_mort_open"

/obj/item/clothing/suit/storage/labcoat/emt
	name = "EMT labcoat"
	desc = "Удобный халат, окрашенный в тёмные цвета. Создан специально для парамедиков."
	ru_names = list(
		NOMINATIVE = "лабораторный халат парамедика",
		GENITIVE = "лабораторного халата парамедика",
		DATIVE = "лабораторному халату парамедика",
		ACCUSATIVE = "лабораторный халат парамедика",
		INSTRUMENTAL = "лабораторным халатом парамедика",
		PREPOSITIONAL = "лабораторном халате парамедика"
	)
	icon_state = "labcoat_emt_open"
	item_state = "labcoat_emt_open"

/obj/item/clothing/suit/storage/labcoat/mining_medic
	name = "mining medic's labcoat"
	desc = "Стерильный белый халат с коричневыми нашивками на плечах. От него исходит тонкий запах пепла."
	ru_names = list(
		NOMINATIVE = "лабораторный халат шахтёрского врача",
		GENITIVE = "лабораторного халата шахтёрского врача",
		DATIVE = "лабораторному халату шахтёрского врача",
		ACCUSATIVE = "лабораторный халат шахтёрского врача",
		INSTRUMENTAL = "лабораторным халатом шахтёрского врача",
		PREPOSITIONAL = "лабораторном халате шахтёрского врача"
	)
	icon_state = "mining_labcoat_open"
	item_state = "mining_labcoat_open"
