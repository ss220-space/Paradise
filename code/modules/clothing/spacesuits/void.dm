//Voidsuits

/obj/item/clothing/head/helmet/space/nasavoid
	name = "CAGI 10 helmet"
	desc = "Панорамный гермошлем скафандра ЦАГИ 10. Обеспечивает надёжную герметизацию и широкий обзор. Разработан NASA."
	icon_state = "void_red"
	item_state = "void_red_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 30, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/head/helmet/space/nasavoid/get_ru_names()
	return list(
		NOMINATIVE = "гермошлем ЦАГИ 10",
		GENITIVE = "гермошлема ЦАГИ 10",
		DATIVE = "гермошлему ЦАГИ 10",
		ACCUSATIVE = "гермошлем ЦАГИ 10",
		INSTRUMENTAL = "гермошлемом ЦАГИ 10",
		PREPOSITIONAL = "гермошлеме ЦАГИ 10"
	)

/obj/item/clothing/suit/space/nasavoid
	name = "CAGI 10 spacesuit"
	desc = "Классический гермоскафандр ЦАГИ 10. Обеспечивает надёжную герметизацию и базовую защиту в агрессивных средах. Разработан NASA."
	icon_state = "void_red"
	item_state = "void_red"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 30, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool, /obj/item/radio)
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/head.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/head.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/head.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/head.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi')

/obj/item/clothing/suit/space/nasavoid/get_ru_names()
	return list(
		NOMINATIVE = "скафандр ЦАГИ 10",
		GENITIVE = "скафандра ЦАГИ 10",
		DATIVE = "скафандру ЦАГИ 10",
		ACCUSATIVE = "скафандр ЦАГИ 10",
		INSTRUMENTAL = "скафандром ЦАГИ 10",
		PREPOSITIONAL = "скафандре ЦАГИ 10"
	)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "NASA engineering helmet"
	desc = "Панорамный гермошлем промышленного скафандра на базе ЦАГИ 10. Визор оснащен системой активного затемнения для защиты от сварочной дуги. Разработан NASA."
	icon_state = "void_red"
	item_state = "void_red_helmet"
	flash_protect = FLASH_PROTECTION_FLASH
	flash_protect = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 50, BOMB = 75, BIO = 100, RAD = 90, FIRE = 100, ACID = 75)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	heat_protection = HEAD
	resistance_flags = FIRE_PROOF
	item_state = "void_red_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/old/get_ru_names()
	return list(
		NOMINATIVE = "промышленный гермошлем NASA",
		GENITIVE = "промышленного гермошлема NASA",
		DATIVE = "промышленному гермошлему NASA",
		ACCUSATIVE = "промышленный гермошлем NASA",
		INSTRUMENTAL = "промышленным гермошлемом NASA",
		PREPOSITIONAL = "промышленном гермошлеме NASA"
	)

/obj/item/clothing/suit/space/nasavoid/old
	name = "NASA engineering spacesuit"
	desc = "Серийный промышленный гермоскафандр для внекорабельной деятельности и работы в экстремальных условиях внутри реактора. Обладает выдающейся термической и радиационной защитой. Разработан NASA."
	icon_state = "void_red"
	item_state = "void_red"
	slowdown = 4
	allowed = list(/obj/item/storage/toolbox, /obj/item/t_scanner, /obj/item/rcd, /obj/item/crowbar, /obj/item/screwdriver, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/wrench, /obj/item/multitool, /obj/item/analyzer, /obj/item/pipe_painter, /obj/item/rpd, /obj/item/storage/part_replacer, /obj/item/storage/bag/construction, /obj/item/storage/bag/sheetsnatcher, /obj/item/extinguisher, /obj/item/stack/cable_coil)
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 50, BOMB = 75, BIO = 100, RAD = 90, FIRE = 100, ACID = 75)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF
	item_state = "void_red"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/old/get_ru_names()
	return list(
		NOMINATIVE = "промышленный гермоскафандр NASA",
		GENITIVE = "промышленного гермоскафандра NASA",
		DATIVE = "промышленному гермоскафандру NASA",
		ACCUSATIVE = "промышленный гермоскафандр NASA",
		INSTRUMENTAL = "промышленным гермоскафандром NASA",
		PREPOSITIONAL = "промышленном гермоскафандре NASA"
	)

/obj/item/clothing/head/helmet/space/nasavoid/green
	name = "SC CAGI 9 Helmet"
	desc = "Штурмовой гермошлем для боевого скафандра. Представляет собой титановую сферу с многослойным баллистическим остеклением. Герметичный шарнирный подголовник усилен композитом. Произведён ТСФ."
	icon_state = "void_green"
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 15, FIRE = 30, ACID = 15)
	item_state = "void_green_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/green/get_ru_names()
	return list(
		NOMINATIVE = "штурмовой гермошлем ЦАГИ 9",
		GENITIVE = "штурмового гермошлема ЦАГИ 9",
		DATIVE = "штурмовому гермошлему ЦАГИ 9",
		ACCUSATIVE = "штурмовой гермошлем ЦАГИ 9",
		INSTRUMENTAL = "штурмовым гермошлемом ЦАГИ 9",
		PREPOSITIONAL = "штурмовом гермошлеме ЦАГИ 9"
	)

/obj/item/clothing/suit/space/nasavoid/green
	name = "SC CAGI 9 spacesuit"
	desc = "Тяжелобронированный штурмовой гермокостюм с интегрированными титановыми сегментами. Шарнирные узлы усилены композитными вставками. Произведён ТСФ."
	icon_state = "void_green"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/shield, /obj/item/grenade)
	armor = list(MELEE = 40, BULLET = 60, LASER = 40, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 15, FIRE = 30, ACID = 15)
	slowdown = 4
	item_state = "void_green"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/green/get_ru_names()
	return list(
		NOMINATIVE = "штурмовой скафандр ЦАГИ 9",
		GENITIVE = "штурмового скафандра ЦАГИ 9",
		DATIVE = "штурмовому скафандру ЦАГИ 9",
		ACCUSATIVE = "штурмовой скафандр ЦАГИ 9",
		INSTRUMENTAL = "штурмовым скафандром ЦАГИ 9",
		PREPOSITIONAL = "штурмовом скафандре ЦАГИ 9"
	)

//Nasa vip

/obj/item/clothing/head/helmet/space/nasavoid/ntblue
	name = "NASA helmet for VIPs"
	desc = "Стандартный шлем \"премиум\" класса для командного состава и важных персон. Сочетает корпоративный стиль с практичностью и удобством. Легкий, не нагружает шею. Разработан NASA."
	icon_state = "void_ntblue"
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 100, RAD = 50, FIRE = 50, ACID = 50)
	item_state = "void_ntblue_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/ntblue/get_ru_names()
	return list(
		NOMINATIVE = "корпоративный гермошлем NASA",
		GENITIVE = "корпоративного гермошлема NASA",
		DATIVE = "корпоративному гермошлему NASA",
		ACCUSATIVE = "корпоративный гермошлем NASA",
		INSTRUMENTAL = "корпоративным гермошлемом NASA",
		PREPOSITIONAL = "корпоративном гермошлеме NASA"
	)

/obj/item/clothing/suit/space/nasavoid/ntblue
	name = "NASA spacesuit for VIPs"
	desc = "Стандартный скафандр \"премиум\" класса для командного состава и важных персон. Сочетает корпоративный стиль с практичностью и удобством. Легкий, не сковывает движений. Компактно складывается. Разработан NASA."
	icon_state = "void_ntblue"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/storage/briefcase, /obj/item/pda, /obj/item/paicard, /obj/item/aicard, /obj/item/ai_module, /obj/item/reagent_containers/food/drinks/flask, /obj/item/storage/lockbox, /obj/item/megaphone, /obj/item/folder, /obj/item/card, /obj/item/camera, /obj/item/melee/baton)
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, BIO = 100, RAD = 50, FIRE = 50, ACID = 50)
	item_state = "void_ntblue"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/ntblue/get_ru_names()
	return list(
		NOMINATIVE = "корпоративный скафандр NASA",
		GENITIVE = "корпоративного скафандра NASA",
		DATIVE = "корпоративному скафандру NASA",
		ACCUSATIVE = "корпоративный скафандр NASA",
		INSTRUMENTAL = "корпоративным скафандром NASA",
		PREPOSITIONAL = "корпоративном скафандре NASA"
	)

//Nasa RnD

/obj/item/clothing/head/helmet/space/nasavoid/purple
	name = "NASA RnD helmet"
	desc = "Специализированный шлем исследовательского скафандра для экстремальных условий. Представляет собой модернизированный сапёрный шлем, оптимизированный для космических операций. Разработан NASA."
	icon_state = "void_purple"
	flash_protect = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 95, BIO = 100, RAD = 85, FIRE = 85, ACID = 85)
	item_state = "void_purple_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/purple/get_ru_names()
	return list(
		NOMINATIVE = "исследовательский гермошлем NASA",
		GENITIVE = "исследовательского гермошлема NASA",
		DATIVE = "исследовательскому гермошлему NASA",
		ACCUSATIVE = "исследовательский гермошлем NASA",
		INSTRUMENTAL = "исследовательским гермошлемом NASA",
		PREPOSITIONAL = "исследовательском гермошлеме NASA"
	)

/obj/item/clothing/suit/space/nasavoid/purple
	name = "NASA RnD spacesuit"
	desc = "Специализированный исследовательский скафандр для экстремальных условий. Представляет собой модернизированный сапёрный костюм, оптимизированный для космических операций. Разработан NASA."
	icon_state = "void_purple"
	allowed = list(/obj/item/storage/part_replacer, /obj/item/robot_module, /obj/item/robotanalyzer, /obj/item/storage/toolbox, /obj/item/circuitboard, /obj/item/assembly/signaler, /obj/item/gps)
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 30, BOMB = 95, BIO = 100, RAD = 85, FIRE = 85, ACID = 85)
	slowdown = 2
	item_state = "void_purple"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/purple/get_ru_names()
	return list(
		NOMINATIVE = "исследовательский скафандр NASA",
		GENITIVE = "исследовательского скафандра NASA",
		DATIVE = "исследовательскому скафандру NASA",
		ACCUSATIVE = "исследовательский скафандр NASA",
		INSTRUMENTAL = "исследовательским скафандром NASA",
		PREPOSITIONAL = "исследовательском скафандре NASA"
	)

//Nasa Miner

/obj/item/clothing/head/helmet/space/nasavoid/yellow
	name = "NASA mining helmet"
	desc = "Прочный гермошлем шахтёрского экзо-скафандра. Конструкция усилена для эксплуатации в агрессивной среде. Разработан NASA."
	icon_state = "void_yellow"
	armor = list(MELEE = 60, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 75, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	item_state = "void_yellow_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/yellow/get_ru_names()
	return list(
		NOMINATIVE = "шахтёрский гермошлем NASA",
		GENITIVE = "шахтёрского гермошлема NASA",
		DATIVE = "шахтёрскому гермошлему NASA",
		ACCUSATIVE = "шахтёрский гермошлем NASA",
		INSTRUMENTAL = "шахтёрским гермошлемом NASA",
		PREPOSITIONAL = "шахтёрском гермошлеме NASA"
	)

/obj/item/clothing/suit/space/nasavoid/yellow
	name = "NASA mining spacesuit"
	desc = "Гибридный скафандр для горнодобывающих работ в космосе. Конструкция усилена для эксплуатации в агрессивной среде и оснащена промышленным экзоскелетом среднего класса. Разработан NASA."
	icon_state = "void_yellow"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe, /obj/item/shovel)
	armor = list(MELEE = 60, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 75, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	slowdown = 4
	item_state = "void_yellow"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/yellow/get_ru_names()
	return list(
		NOMINATIVE = "шахтёрский экзо-скафандр NASA",
		GENITIVE = "шахтёрского экзо-скафандра NASA",
		DATIVE = "шахтёрскому экзо-скафандру NASA",
		ACCUSATIVE = "шахтёрский экзо-скафандр NASA",
		INSTRUMENTAL = "шахтёрским экзо-скафандром NASA",
		PREPOSITIONAL = "шахтёрском экзо-скафандре NASA"
	)

//Nasa Med

/obj/item/clothing/head/helmet/space/nasavoid/ltblue
	name = "NASA medical helmet"
	desc = "Специализированный лёгкий гермошлем для медицинского персонала. Предназначен для защиты от биологического и химического загрязнения. Разработан Фондом Красного Креста и NASA."
	icon_state = "void_light_blue"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 100, RAD = 50, FIRE = 50, ACID = 100)
	item_state = "void_light_blue_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/ltblue/get_ru_names()
	return list(
		NOMINATIVE = "медицинский гермошлем NASA",
		GENITIVE = "медицинского гермошлема NASA",
		DATIVE = "медицинскому гермошлему NASA",
		ACCUSATIVE = "медицинский гермошлем NASA",
		INSTRUMENTAL = "медицинским гермошлемом NASA",
		PREPOSITIONAL = "медицинском гермошлеме NASA"
	)

/obj/item/clothing/suit/space/nasavoid/ltblue
	name = "NASA medical spacesuit"
	desc = "Специализированный лёгкий скафандр для медицинского персонала. Предназначен для защиты от биологического и химического загрязнения. Можно установить дефибриллятор. Разработан Фондом Красного Креста и NASA."
	icon_state = "void_light_blue"
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical,/obj/item/rad_laser)
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 100, RAD = 50, FIRE = 50, ACID = 100)
	item_state = "void_light_blue"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/ltblue/get_ru_names()
	return list(
		NOMINATIVE = "медицинский скафандр NASA",
		GENITIVE = "медицинского скафандра NASA",
		DATIVE = "медицинскому скафандру NASA",
		ACCUSATIVE = "медицинский скафандр NASA",
		INSTRUMENTAL = "медицинским скафандром NASA",
		PREPOSITIONAL = "медицинском скафандре NASA"
	)

//Captian's Suit, like the other captian's suit, but looks better, at the cost of armor

/obj/item/clothing/head/helmet/space/nasavoid/captain
	name = "Captain's Hardsuit Helmet"
	icon_state = "void_captian"
	desc = "Эксклюзивный гермошлем НаноТрейзен для высшего командного состава. Пик корпоративной роскоши и технологий 2450-х. Оборудован активной защитой визора и хвойным ароматизатором. Произведено NASA по заказу НТ."
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 20, BOMB = 75, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	flash_protect = FLASH_PROTECTION_FLASH
	item_state = "void_captian_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/captain/get_ru_names()
	return list(
		NOMINATIVE = "гермошлем Капитана",
		GENITIVE = "гермошлема Капитана",
		DATIVE = "гермошлему Капитана",
		ACCUSATIVE = "гермошлем Капитана",
		INSTRUMENTAL = "гермошлемом Капитана",
		PREPOSITIONAL = "гермошлеме Капитана"
	)

/obj/item/clothing/suit/space/nasavoid/captain
	name = "Captain's Hardsuit"
	desc = "Эксклюзивный скафандр НаноТрейзен для высшего командного состава. Пик корпоративной роскоши и технологий 2450-х. Улучшенная система вентиляции, позолоченные вставки. Не сковывает движений. Произведено NASA по заказу НТ."
	icon_state = "void_captian"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 20, BOMB = 75, BIO = 100, RAD = 75, FIRE = 75, ACID = 75)
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "void_captian"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/captain/get_ru_names()
	return list(
		NOMINATIVE = "скафандр Капитана",
		GENITIVE = "скафандра Капитана",
		DATIVE = "скафандру Капитана",
		ACCUSATIVE = "скафандр Капитана",
		INSTRUMENTAL = "скафандром Капитана",
		PREPOSITIONAL = "скафандре Капитана"
	)

//Syndi's suit, on par with a blood red softsuit

/obj/item/clothing/head/helmet/space/nasavoid/syndi
	name = "Blood red infantry helmet"
	icon_state = "void_syndi"
	desc = "Высокомобильный боевой гермошлем неизвестного происхождения. Обеспечивает сбалансированную защиту. Оснащён системой активного шумоподавления и затемнённым визором. Маркировка производителя отсутствует."
	armor = list(MELEE = 50, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 100, RAD = 15, FIRE = 50, ACID = 15)
	item_flags = BANGPROTECT_TOTAL|HEALS_EARS
	flash_protect = FLASH_PROTECTION_FLASH
	item_state = "void_syndi_helmet"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/nasavoid/syndi/get_ru_names()
	return list(
		NOMINATIVE = "кроваво-красный пехотный шлем",
		GENITIVE = "кроваво-красного пехотного шлема",
		DATIVE = "кроваво-красному пехотному шлему",
		ACCUSATIVE = "кроваво-красный пехотный шлем",
		INSTRUMENTAL = "кроваво-красным пехотным шлемом",
		PREPOSITIONAL = "кроваво-красном пехотном шлеме"
	)

/obj/item/clothing/suit/space/nasavoid/syndi
	name = "Blood red infantry spacesuit"
	icon_state = "void_syndi"
	desc = "Высокомобильный боевой гермоскафандр неизвестного происхождения. Обеспечивает сбалансированную защиту. Оснащён сложным экзо-скелетом высокой мобильности. Маркировка производителя отсутствует."
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 50, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 100, RAD = 15, FIRE = 50, ACID = 15)
	item_state = "void_syndi"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/space/nasavoid/syndi/get_ru_names()
	return list(
		NOMINATIVE = "кроваво-красный пехотный скафандр",
		GENITIVE = "кроваво-красного пехотного скафандра",
		DATIVE = "кроваво-красному пехотному скафандру",
		ACCUSATIVE = "кроваво-красный пехотный скафандр",
		INSTRUMENTAL = "кроваво-красным пехотным скафандром",
		PREPOSITIONAL = "кроваво-красном пехотном скафандре"
	)

//random spawner

/obj/effect/nasavoidsuitspawner
	name = "NASA Void Suit Spawner"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "void_red"
	desc = "You shouldn't see this, a spawner for NASA Void Suits."
	var/suits = list("red", "green", "ntblue", "purple", "yellow", "ltblue")

/obj/effect/nasavoidsuitspawner/New()
	. = ..()
	var/obj/item/clothing/head/helmet/space/nasavoid/H
	var/obj/item/clothing/suit/space/nasavoid/S
	switch(pick(suits))
		if("red")
			H = new /obj/item/clothing/head/helmet/space/nasavoid
			S = new /obj/item/clothing/suit/space/nasavoid
		if("green")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/green
			S = new /obj/item/clothing/suit/space/nasavoid/green
		if("ntblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ntblue
			S = new /obj/item/clothing/suit/space/nasavoid/ntblue
		if("purple")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/purple
			S = new /obj/item/clothing/suit/space/nasavoid/purple
		if("yellow")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/yellow
			S = new /obj/item/clothing/suit/space/nasavoid/yellow
		if("ltblue")
			H = new /obj/item/clothing/head/helmet/space/nasavoid/ltblue
			S = new /obj/item/clothing/suit/space/nasavoid/ltblue
	var/turf/T = get_turf(src)
	if(H)
		H.forceMove(T)
	if(S)
		S.forceMove(T)
	qdel(src)
