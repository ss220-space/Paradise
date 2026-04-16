/// Global proc that sets up all MOD themes as singletons in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme

/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD. Used in parts name. Looks something like "нагрудник МЭК [name]"
	var/name = "базовой модели"
	/// Description added to the MOD.
	var/desc = "Гражданский модульный экзо-костюм, разработанный корпорацией \"Киберсан Индастриз\". Не имеет никаких особенностей."
	/// Extended description on examine_more()
	var/extended_desc = "Третье поколение модульных гражданских костюмов, созданных корпорацией \"Киберсан Индастриз\". \
		Данный тип костюмов является самым популярным среди гражданских лиц по всей Галактике. Совместимые со всеми известными видами, \
		эти костюмы имеют замкнутую систему дыхания, пригодны для использования в космосе, защищают от возгораний и химических угроз \
		и предоставляют биологическую защиту от всего, начиная с простого кашля и заканчивая современным биооружием. Однако данный костюм \
		практически невозможно использовать в бою из-за крайне посредственного бронепокрытия и пневматических актуаторов прошлого поколения."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = ITEM_SLOT_BACK
	/// Armor shared across the MOD parts.
	var/datum/armor/armor_type = /datum/armor/mod_theme
	/// Resistance flags shared across the MOD parts.
	var/resistance_flags = NONE
	/// Atom flags shared across the MOD parts.
	var/atom_flags = NONE
	/// Max heat protection shared across the MOD parts.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD parts.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Siemens shared across the MOD parts.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when all of its pieces are deployed.
	var/slowdown_deployed = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Allowed items in the chestplate's suit storage.
	var/list/allowed_suit_storage = list()
	/// List of variants with their appropriate clothing flags.
	var/list/variants = list(
		MOD_VARIANT_STANDART = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

#ifdef UNIT_TESTS
/datum/mod_theme/New()
	var/list/skin_parts = list()
	for(var/variant in variants)
		skin_parts += list(assoc_to_keys(variants[variant]))
	for(var/skin in skin_parts)
		for(var/compared_skin in skin_parts)
			if(skin ~! compared_skin)
				stack_trace("[type] variants [skin] and [compared_skin] aren't made of the same parts.")
		skin_parts -= skin
#endif

/// Create parts of the suit and modify them using the theme's variables.
/datum/mod_theme/proc/set_up_parts(obj/item/mod/control/mod, skin)
	var/list/parts = list(mod)
	mod.slot_flags = slot_flags
	mod.extended_desc = extended_desc
	mod.slowdown_deployed = slowdown_deployed
	mod.activation_step_time = activation_step_time
	mod.complexity_max = complexity_max
	mod.ui_theme = ui_theme
	mod.charge_drain = charge_drain
	var/datum/mod_part/control_part_datum = new()
	control_part_datum.set_item(mod)
	mod.mod_parts["[mod.slot_flags]"] = control_part_datum
	for(var/path in variants[default_skin])
		if(!ispath(path))
			continue
		var/obj/item/mod_part = new path(mod)
		if(mod_part.slot_flags == ITEM_SLOT_CLOTH_OUTER && isclothing(mod_part))
			var/obj/item/clothing/chestplate = mod_part
			chestplate.allowed |= allowed_suit_storage
		var/datum/mod_part/part_datum = new()
		part_datum.set_item(mod_part)
		mod.mod_parts["[mod_part.slot_flags]"] = part_datum
		parts += mod_part

	for(var/obj/item/part as anything in parts)
		part.name = "[part.name] [name]"
		if(!part.ru_names)
			part.ru_names = part.get_ru_names_cached()
		part.ru_names = list(
			NOMINATIVE = part.ru_names[NOMINATIVE] + " [name]",
			GENITIVE = part.ru_names[GENITIVE] + " [name]",
			DATIVE = part.ru_names[DATIVE] + " [name]",
			ACCUSATIVE = part.ru_names[ACCUSATIVE] + " [name]",
			INSTRUMENTAL = part.ru_names[INSTRUMENTAL] + " [name]",
			PREPOSITIONAL = part.ru_names[PREPOSITIONAL] + " [name]"
			)
		part.desc = "[part.desc] </p><i>[desc]</i>"
		part.set_armor(armor_type)
		part.resistance_flags = resistance_flags
		part.flags |= atom_flags //flags like initialization or admin spawning are here, so we cant set, have to add
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.max_heat_protection_temperature = max_heat_protection_temperature
		part.min_cold_protection_temperature = min_cold_protection_temperature
		part.siemens_coefficient = siemens_coefficient

	set_skin(mod, skin || default_skin)

/datum/mod_theme/proc/set_skin(obj/item/mod/control/mod, skin)
	mod.skin = skin
	var/list/used_skin = variants[skin]
	var/list/parts = mod.get_parts()
	for(var/obj/item/clothing/part as anything in parts)
		var/list/category = used_skin[part.type]
		var/datum/mod_part/part_datum = mod.get_part_datum(part)
		part_datum.unsealed_layer = category[UNSEALED_LAYER]
		//part_datum.sealed_layer = category[SEALED_LAYER]
		part_datum.unsealed_message = category[UNSEALED_MESSAGE] || "Сообщение об активации элемента не задано! Сообщите о баге!"
		part_datum.sealed_message = category[SEALED_MESSAGE] || "Сообщение о дезактивации элемента не задано! Сообщите о баге!"
		part_datum.can_overslot = category[CAN_OVERSLOT] || FALSE
		part.clothing_flags = category[UNSEALED_CLOTHING] || NONE
		part.visor_flags = category[SEALED_CLOTHING] || NONE
		part.flags_inv = category[UNSEALED_INVISIBILITY] || NONE
		part.visor_flags_inv = category[SEALED_INVISIBILITY] || NONE
		part.flags_cover = category[UNSEALED_COVER] || NONE
		part.visor_flags_cover = category[SEALED_COVER] || NONE
		if(mod.get_part_datum(part).sealed)
			part.clothing_flags |= part.visor_flags
			part.flags_inv |= part.visor_flags_inv
			part.flags_cover |= part.visor_flags_cover
		// 	part.alternate_worn_layer = part_datum.sealed_layer
		// else
		// 	part.alternate_worn_layer = part_datum.unsealed_layer
		if(!part_datum.can_overslot && part_datum.overslotting)
			var/obj/item/overslot = part_datum.overslotting
			overslot.forceMove(mod.drop_location())
	for(var/obj/item/part as anything in parts + mod)
		part.icon = used_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
		part.onmob_sheets = used_skin[MOD_WORN_ICON_OVERRIDE] || list(slot_bitfield_to_slot_string(part.slot_flags) = 'icons/mob/clothing/modsuit/mod_clothing.dmi')
		part.icon_state = "[skin]-[part.base_icon_state][mod.get_part_datum(part).sealed ? "-sealed" : ""]"
		mod.wearer?.update_clothing(part.slot_flags)
	mod.wearer?.refresh_obscured()

///Simplified proc, that only changes visuals
/datum/mod_theme/proc/set_only_visual_skin(obj/item/mod/control/mod, skin)
	mod.skin = skin
	var/list/parts = mod.get_parts()
	for(var/obj/item/part as anything in parts + mod)
		part.icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
		part.onmob_sheets = list(slot_bitfield_to_slot_string(part.slot_flags) = 'icons/mob/clothing/modsuit/mod_clothing.dmi')

		part.icon_state = "[skin]-[part.base_icon_state][mod.get_part_datum(part).sealed ? "-sealed" : ""]"
		mod.wearer?.update_clothing(part.slot_flags)
	mod.wearer?.refresh_obscured()

/datum/armor/mod_theme
	melee = 25
	bullet = 15
	laser = 15
	energy = 15
	bomb = 0
	bio = 80
	fire = 33
	acid = 33

/datum/mod_theme/civilian
	name = "модели \"Путник\""
	desc = "Лёгкий гражданский МЭК от \"Накамура Инженеринг\". \
			Обеспечивает защиту от вакуума и высокую подвижность, но не устойчив к химическим или биологическим агентам."
	extended_desc = "Разработка компании \"Накамура Инженеринг\", предназначенная для путешествий по безопасным мирам. \
		Модель \"Путник\" оснащена системой герметизации, достаточной для пребывания в вакууме, \
		однако не включает фильтрацию от токсинов, спор или химических паров. Костюм сознательно отказывается от тяжёлой брони и расширенной модульности \
		ради минимального веса, бесшумной работы и максимальной манёвренности. Благодаря уменьшенному профилю совместимость с промышленными и боевыми модулями ограничена. \
		Использование в зонах с агрессивной средой не рекомендуется."
	default_skin = "civilian"
	armor_type = /datum/armor/mod_theme_civilian
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0
	variants = list(
		"civilian" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		MOD_VARIANT_STANDART = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_civilian
	melee = 25
	bullet = 15
	laser = 15
	energy = 15
	bomb = 0
	bio = 80
	acid = 33

/datum/mod_theme/engineering
	name = "модели \"Искра\""
	desc = "Стандартный инженерный МЭК с повышенной термической и радиационной защитой. Нестареющая классика от \"Киберсан Индастриз\"."
	extended_desc = "Один из самых известных модульных костюмов от \"Киберсан Индастриз\", призванный заменить устаревшие ИКС-ы. \
		Модель \"Искра\" сохраняет модульную архитектуру гражданской платформы, но дополняет её изоляционной внутренней прокладкой, \
		бронированным внешним покрытием и системами фильтрации, позволяющими работать в условиях повышенной температуры, \
		радиационного фона и экстремального давления. Несмотря на расширенный функционал, архитектура костюма ограничивает его модификацию \
		и боевые возможности. Широко полюбился инженерами по всей Галактике благодаря своей надёжности и простоте обслуживания."
	default_skin = "engineering"
	armor_type = /datum/armor/mod_theme_engineering
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 1
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe,
	)
	variants = list(
		MOD_VARIANT_ENGINEERING = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_engineering
	melee = 30
	bullet = 15
	laser = 15
	energy = 15
	bomb = 40
	bio = 80
	fire = 70
	acid = 10

/datum/mod_theme/atmospheric
	name = "модели \"Пламень\""
	desc = "Специализированный инженерный костюм для атмосферных работ производства \"Киберсан Индастриз\". Обладает усиленной термической и \
			коррозийной защитой, но хуже противостоит радиационному загрязнению."
	extended_desc = "Модификация стандартного инженерного костюма, разработанная \"Киберсан Индастриз\" для инженерных и энергетических работ. \
		Модель \"Пламень\" использует композитные жаропрочные сплавы, активные радиаторы и замкнутый охлаждающий контур, обеспечивая устойчивость \
		к экстремальным температурам и агрессивным газам, включая плазменные и кислотные пары. Внутренняя система фильтрации защищает оператора \
		от химических угроз, характерных при работе с Суперматерией. В то же время, из-за акцента на термостойкость, костюм получил минимальную \
		радиационную защиту и ограниченные боевые возможности — его архитектура ближе к гражданским моделям."
	default_skin = "atmospheric"
	armor_type = /datum/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	siemens_coefficient = 0
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe/,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer,
	)
	variants = list(
		MOD_VARIANT_ATMOSPHERIC = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_atmospheric
	melee = 30
	bullet = 15
	laser = 15
	energy = 15
	bomb = 15
	bio = 80
	fire = 100
	acid = 100

/datum/mod_theme/advanced
	name = "модели \"Авангард\""
	desc = "Продвинутая версия классического костюма корпорации \"Киберсан Индастриз\" с усиленной взрыво-, термо- и химической защитой. \
			Флагманская модель, являющаяся лучшей из доступных на рынке."
	extended_desc = "Последняя модель в индустриальной линейке \"Киберсан Индастриз\", объединяющая усиленную конструкцию атмосферного костюма с \
		расширенной модульностью инженерной платформы. Корпус покрыт запатентованным композитным полимером белого цвета, обладающим рекордной \
		устойчивостью к коррозии, радиационному излучению и механическим воздействиям. Встроенные магнитные ботинки нового поколения обеспечивают \
		стабильное сцепление даже при работе в условиях нулевой гравитации или сильной вибрации. Несмотря на выдающиеся характеристики, \
		костюм сохраняет умеренный энергопрофиль и широкую совместимость с модулями разных типов. В связи с высокой стоимостью \
		и сложностью производства модель ещё не получила широкого распространения, однако уже успела зарекомендовать себя как \
		новый стандарт модульных костюмов. Крупные корпорации, такие как \"Нанотрейзен\", \"Синдикат\" и \"Эйнштейн Системс\", \
		объявили о планах закупки ограниченных партий \"Авангардов\"."
	default_skin = "advanced"
	armor_type = /datum/armor/mod_theme_advanced
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	siemens_coefficient = 0
	slowdown_deployed = 0.45
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced/elite)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe,
		/obj/item/melee/baton/telescopic,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/gun,

	)
	variants = list(
		MOD_VARIANT_ADVANCED = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDENAME|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_advanced
	melee = 45
	bullet = 20
	laser = 20
	energy = 20
	bomb = 60
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/mining
	name = "модели \"Первопроходец\""
	desc = "Модульный костюм, разработанный \"Нанотрейзен\". Специализированная для горнодобывающих работ модель, \
			имеющая встроенные модули пепельной брони, превращения в сферу и оснащённая ядром плазменного типа питания."
	extended_desc = "Разработка корпорации \"Нанотрейзен\", созданная на основе ранних индустриальных платформ \"Киберсан Индастриз\" с учётом \
		обратной связи от полевых шахтёрских бригад. Модель \"Первопроходец\" оптимизирована для работы в астероидных шахтах и зонах с высоким уровнем \
		термальных и взрывных рисков. Вместо традиционной брони использует аттракторы частиц пепла, формирующие временный абляционный слой, \
		способный выдержать кратковременное экстремальное воздействие, но быстро разрушающийся при физическом контакте. Ключевая особенность — \
		режим сферической трансформации: каркас костюма может реконфигурироваться в гиростабилизированную сферу, позволяя оператору развивать \
		высокую скорость при перемещении по узким штольням или завалам. В этом режиме доступен запуск шахтёрских термобарических зарядов для \
		дистанционной расчистки препятствий. Визорная система, интегрированная в плечевой узел, обеспечивает 360-градусный обзор \
		вокруг пользователя. Для компенсации высокого энергопотребления активных систем костюм оснащён модифицированным плазменным ядром,\
		допускающим подзарядку от листов плазмы или руды в полевых условиях. В целях повышения надёжности и снижения \
		себестоимости модульность платформы была ограничена, сфокусировавшись на простоте обслуживания и устойчивости к экстремальным условиям. \
		Из-за отсутствия герметизации костюм не предназначен для эксплуатации в вакууме, что делает его узкоспециализированным, но незаменимым в глубинных шахтах."
	default_skin = "mining"
	armor_type = /datum/armor/mod_theme_mining
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_deployed = 0.5
	allowed_suit_storage = list(
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/pickaxe,
		/obj/item/twohanded/kinetic_crusher,
		/obj/item/stack/ore/plasma,
		/obj/item/storage/bag/ore,
		/obj/item/gun/energy/kinetic_accelerator,
	)
	inbuilt_modules = list(/obj/item/mod/module/ash_accretion, /obj/item/mod/module/sphere_transform)
	variants = list(
		MOD_VARIANT_MINING = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		MOD_VARIANT_ASTEROID = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDENAME|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_mining
	melee = 40
	bullet = 15
	laser = 15
	energy = 15
	bomb = 50
	bio = 80
	fire = 50
	acid = 50

/datum/mod_theme/loader
	name = "модели \"Геракл\""
	desc = "Грузовой модульный костюм для военной логистики, произведённый концерном \"Скарборо\". \
			Обеспечивает подъём грузов массой в несколько тонн, но не имеет какой-либо герметизации и почти лишён бронеэлементов."
	extended_desc = "Специализированный модульный экзокостюм от концерна \"Скарборо\", предназначенный для высокоскоростной погрузки, разгрузки \
		и транспортировки боеприпасов и тяжёлого снаряжения. Изначально произведённый для военной логистики, со временем костюм \
		зарекомендовал себя как эффективное и относительно доступное снаряжение для грузовых работ. \
		Каркас выполнен из титанового сплава с распределённой гидравлической системой, многократно усиливающей грузоподъёмность оператора. \
		Две дополнительные манипуляторные руки синхронизируются с нервной системой пользователя, \
		обеспечивая минимальную задержку и полный тактильный фидбэк. Встроенные гидромоторы в ногах повышают мобильность \
		оператора, что критично для обеспечения логистики. Костюм не обеспечивает защиты от вакуума, огня или оружия, \
		однако его модульная архитектура предусматривает автоматическую изоляцию и сохранение ключевых компонентов костюма \
		в случае гибели оператора — для последующего восстановления и повторного использования."
	default_skin = "loader"
	armor_type = /datum/armor/mod_theme_loader
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/clothing/mask/cigarette,
		/obj/item/lighter,
		/obj/item/rcs,
		/obj/item/stack/packageWrap,
		/obj/item/stack/wrapping_paper,
		/obj/item/destTagger,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/stamp,
		/obj/item/gun/projectile/shotgun,
	)
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	variants = list(
		MOD_VARIANT_LOADER = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEHAIR,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_loader
	melee = 30
	bullet = 15
	laser = 15
	energy = 15
	bomb = 10
	bio = 80
	fire = 25
	acid = 25

/datum/mod_theme/medical
	name = "модели \"Пульс\""
	desc = "Лёгкий медицинский МЭК, разработанный компаниями \"Вита-пром\" и \"Кибернетика Бишопа\". Оснащён полной биологической \
			и химической изоляцией и относительной легковесностью, но не имеет бронезащиты."
	extended_desc = "Модульный костюм медицинской специализации, ориентированный на работу в зонах биологического \
		заражения, химических утечек и эпидемий. Совместная разработка компаний \"Вита-пром\" и \"Кибернетика Бишопа\". \
		Модель \"Пульс\" оснащена замкнутой системой дыхания и многоступенчатой фильтрацией, \
		гарантирующей полную изоляцию от патогенов и коррозионных агентов. Повышенная скорость передвижения \
		достигается за счёт облегчённого композитного каркаса, улучшенных сервоприводов и амортизирующих рессор в ногах. Несмотря на отсутствие \
		бронирования, костюм устойчив к химическому воздействию и совместим с широким спектром медицинских модулей. Энергопотребление \
		незначительно превышает гражданские аналоги. Костюмы \"Пульс\" активно используются медицинским персоналом по всей Галактике."
	default_skin = "medical"
	armor_type = /datum/armor/mod_theme_medical
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_deployed = 0.45
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
	)
	variants = list(
		MOD_VARIANT_MEDICAL = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		MOD_VARIANT_CORPSMAN = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_medical
	melee = 20
	bullet = 15
	laser = 15
	energy = 15
	bomb = 10
	bio = 10
	fire = 75
	acid = 100

/datum/mod_theme/rescue
	name = "модели \"Валькирия\""
	desc = "Продвинутая версия медицинского костюма с усиленными сервоприводами и повышенной термозащитой. \
			Разработан компаниями \"Вита-пром\" и \"Кибернетика Бишопа\". \
			Предназначен для эвакуации пострадавших в условиях высокой температуры и заражения среды."
	extended_desc = "Эволюция медицинской платформы \"Вита-пром\", разработанная совместно с \"Кибернетикой Бишопа\" для работы в экстремальных условиях. \
		Модель \"Валькирия\" оснащена распределённой системой сервоприводов по всему каркасу, позволяющей оператору быстро поднимать и транспортировать \
		пациентов. Внешний слой выполнен из термостойкого композита, обеспечивающего защиту от экстремальных температур, \
		а также от биологических и химических агентов. Замкнутая система жизнеобеспечения гарантирует изоляцию пользователя в зонах полного загрязнения. \
		Энергопотребление значительно превышает гражданские аналоги, что требует регулярной подзарядки. \
		\"Валькирия\" штатно используются членами аварийно-спасательных отрядов."
	default_skin = "rescue"
	armor_type = /datum/armor/mod_theme_rescue
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_deployed = 0.25
	inbuilt_modules = list()
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/melee/baton/telescopic,
	)
	variants = list(
		MOD_VARIANT_RESCUE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_rescue
	melee = 30
	bullet = 30
	laser = 15
	energy = 15
	bomb = 10
	bio = 10
	fire = 100
	acid = 100

/datum/mod_theme/research
	name = "модели \"Бастион\""
	desc = "Массивный сапёрный костюм, произведённый \"Оружейной Ауссек\" и лицензированно модифицированный \"Нанотрейзен\". \
			Специализированная модель, переоборудованная \"Нанотрейзен\" для исследовательской работы. Тяжёлый и громоздкий, \
			но хорошо защищающий от взрывов и ударов."
	extended_desc = "Изначально разработан компаний \"Оружейная Ауссек\" как сапёрный костюм для работы с боеприпасами высокого риска. После приобретения лицензии \
		корпорацией \"Нанотрейзен\" модель была перепрофилирована для исследований в условиях экстремальной опасности, в первую очередь работу с токсинными бомбами. \
		Многослойная обшивка из пластитана и экспериментальных кинетико-поглощающих сплавов способна выдержать \
		прямое попадание артиллерийского снаряда или реактивной ракеты, предотвращая разрушение корпуса костюма. Однако внутренние перегрузки \
		всё ещё остаются смертельно опасными для оператора. Встроенный сканирующий модуль позволяет дистанционно анализировать содержимое контейнеров \
		и идентифицировать их содержимое на расстоянии. Из-за большой массы и ограниченной подвижности костюм применяется \
		исключительно в стационарных лабораториях и научных полигонах. Печально известен среди научных сотрудников под прозвищем \
		\"Гроб с гарантией\"."
	default_skin = "research"
	armor_type = /datum/armor/mod_theme_research
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_deployed = 1
	ui_theme = "changeling"
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/hand_tele,
		/obj/item/storage/bag/bio,
		/obj/item/melee/baton/telescopic,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_RESEARCH = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_research
	melee = 40
	bullet = 40
	laser = 15
	energy = 15
	bomb = 100
	bio = 80
	fire = 75
	acid = 100

/datum/mod_theme/security
	name = "модели \"Страж\""
	desc = "Лёгкий тактический МЭК для сил быстрого реагирования, произведённый компанией \"Стальная Гвардия\". Жертвует грузоподъёмностью ради высокой скорости и манёвренности."
	extended_desc = "Стандартный тактический костюм от \"Стальной Гвардии\", предназначенный для использования в боевых условиях. \
		Внешняя обшивка устойчива к открытому огню, коррозионным агентам и кинетическим воздействиям, а сетчатая композитная структура обеспечивает \
		защиту от механических и баллистических повреждений. Приводы в ногах оптимизированы для \
		динамичного перемещения: бега, прыжков и резких смен траектории под нагрузкой. Несмотря на высокую надёжность, архитектура костюма \
		устарела на десятилетие, что ограничивает возможности по модификации. \
		Штатно применяется охранными структурами \"Нанотрейзен\", государственными правовыми службами и частными военными силами."
	default_skin = "security"
	armor_type = /datum/armor/mod_theme_security
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0.45
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_SECURITY = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_security
	melee = 35
	bullet = 30
	laser = 35
	energy = 15
	bomb = 25
	bio = 60
	fire = 60
	acid = 100

/datum/mod_theme/brig_pilot
	name = "модели \"Сокол\""
	desc = "Лёгкий тактический МЭК от \"Стальной Гвардии\" для пилотов космических кораблей. Обеспечивает высокую мобильность и сверхбыструю активацию, \
			жертвую грузоподъёмностью и бронированием."
	extended_desc = "Специализированный тактический костюм для авиационного персонала, разработанный \"Стальной Гвардией\" с учётом экстремальных условий космического полёта. \
		Модель \"Сокол\" выполнена из облегчённых композитных сплавов и синтетической кожи, что снижает общую массу костюма без критической потери защитных свойств. \
		Визорная система стилизована под старинные шлемы лётчиков Земли и интегрирует тактический дисплей, отображающий данные в реальном времени. \
		Костюм обеспечивает полную герметизацию и активируется за считанные секунды — что критически важно в случае возможной разгерметизации кабины. \
		Хотя показатели бронезащиты костюма значительно ниже, чем у боевых аналогов, они является достаточными для защиты пользователя от осколков, вторичных поражающих факторов \
		и кратковременного пребывания в вакууме. Благодаря балансу скорости, надёжности и компактности, \"Сокол\" снискал популярность у пилотов по всей Галактике."
	default_skin = "brigpilot"
	armor_type = /datum/armor/mod_theme_brig_pilot
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_deployed = 0.25
	inbuilt_modules = list(/obj/item/mod/module/activation_upgrade/advanced)
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_BRIGPILOT = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_brig_pilot
	melee = 25
	bullet = 20
	laser = 25
	energy = 15
	bomb = 25
	bio = 60
	fire = 60
	acid = 80

/datum/mod_theme/safeguard_mk_one
	name = "модели \"Защитник\""
	desc = "Элитный боевой МЭК от \"Стальной Гвардии\" предыдущего поколения. Обеспечивает исключительную защиту от огня, \
		взрывов и коррозии за счёт усиленной брони и герметизации."
	extended_desc = "Легендарная модель от \"Стальной Гвардии\", некогда бывшая стандартом для элитных подразделений. Несмотря на высокую себестоимость \
		и снятие с массового производства, \"Защитник\" остаётся эталоном боевого МЭК. Внешний слой усилен в критических зонах, особенно в области \
		плеч, что придаёт оператору внушительный профиль и дополнительную устойчивость к осколочным поражениям. \
		Все стыки герметизированы укреплёнными уплотнителями, а встроенные боковые радиаторы обеспечивают отвод тепла от активных модулей. \
		Не смотря на то, что модель \"Защитник\" активно заменяется в пользу более современных моделей, данный костюм всё ещё используется \
		охранными и военными структурами по всей Галактике."
	default_skin = "safeguard-ward"
	armor_type = /datum/armor/mod_theme_safeguard_one
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_deployed = 0.3
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_SAFEGUARD_WARDEN = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_safeguard_one
	melee = 35
	bullet = 35
	laser = 40
	energy = 25
	bomb = 30
	bio = 70
	fire = 70
	acid = 100

/datum/mod_theme/safeguard_mk_two
	name = "модели \"Защитник-М\""
	desc = "Флагманский боевой МЭК от \"Стальной Гвардии\", прямой наследник легендарной модели \"Защитник\". \
			Сочетает лёгкий вес, высокую скорость, усиленное бронирование и расширенную модульность."
	extended_desc = "Новейшая разработка \"Стальной Гвардии\", представляющая собой следующую ступень в серии костюмов \"Защитник\". \
		Модель \"Защитник-М\" использует многослойные композитные наноматериалы, обеспечивающие уровень защиты, \
		сопоставимый с предыдущими поколениями, при значительно меньшей массе. Это позволяет оператору развивать \
		высокую скорость передвижения, а встроенный улучшенный джетпак даёт кратковременную возможность манёвра в трёхмерном \
		пространстве. Грузоподъёмность увеличена по сравнению с предыдущей моделью, а архитектура костюма поддерживает расширенный \
		набор модулей. \"Защитник-М\" задумывался как универсальная платформа для элитных подразделений, где важны \
		одновременно мобильность, выживаемость и адаптивность. Данная модель попала на рынок не так давно \
		и в данный момент активно тестируется элитными охранными подразделениями."
	default_skin = "safeguard"
	armor_type = /datum/armor/mod_theme_safeguard_two
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_deployed = 0.25
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_SAFEGUARD = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_safeguard_two
	melee = 45
	bullet = 40
	laser = 45
	energy = 30
	bomb = 70
	bio = 90
	fire = 80
	acid = 100

/datum/mod_theme/security_medical
	name = "модели \"Клятва\""
	desc = "Тактико-медицинский МЭК совместной разработки корпораций \"Вита-пром\" и \"Стальная Гвардия\". Предназначен для эвакуации и оказания помощи на поле боя."
	extended_desc = "Результат неожиданного партнёрства между \"Вита-пром\" и \"Стальной Гвардией\". \
		Модель \"Клятва\" создана для парамедиков сил быстрого реагирования, работающих в зонах боевых действий. \
		Костюм обеспечивает сбалансированную защиту от механических, термических и химических угроз, сохраняя достаточную \
		мобильность и грузоподъёмность для транспортировки пострадавших. Хотя броня уступает другим боевым моделям по параметрам баллистической защиты, \
		она способна защитить пользователя от пуль промежуточных калибров и осколков. На грудной пластине нанесён символ красного креста, \
		зарегистрированный за \"Межгалактическим комитетом Красного Креста\", обеспечивающий визуальную идентификацию \
		медицинского персонала в условиях активного боя. После успешных полевых испытаний костюм был запущен в серийное производство \
		и на текущий момент активно поставляется в элитные медотряды боевых подразделений по всей Галактике."
	default_skin = "security-med"
	armor_type = /datum/armor/mod_theme_secmed
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_deployed = 0.4
	ui_theme = "security"
	allowed_suit_storage = list(
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/flash,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
	)
	variants = list(
		MOD_VARIANT_BRIGMED = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_secmed
	melee = 20
	bullet = 20
	laser = 20
	energy = 20
	bomb = 30
	bio = 100
	fire = 70
	acid = 100

/datum/mod_theme/magnate
	name = "модели \"Магнат\""
	desc = "Элитный капитанский МЭК от \"Нанотрейзен\", созданный на основе \"Преторианца\". \
			Сочетает превосходную защиту, расширенную модульность и невероятный уровень комфорта."
	extended_desc = "Флагманская модель линейки исполнительных костюмов \"Нанотрейзен\", разработанная исключительно для лиц, занимающих должности капитанского \
		звена. Является прямым наследником экспериментальной модели \"Преторианец\". Корпус покрыт двухслойным композитным лаком ручной работы, \
		обеспечивающим устойчивость к электрическим разрядам, открытому пламени и концентрированным кислотам. \
		Встроенные приводы премиум-класса гарантируют высокую скорость и грузоподъёмность, \
		а архитектура на базе мета-позитронного обучения и блюспейс-обработки данных поддерживает полный спектр тактических и административных модулей. \
		Система жизнеобеспечения включает опциональный ароматический фильтр с доступом к библиотеке из 500 запахов редких внеземных цветов, \
		внесённых в Галактическую Красную Книгу. В левый рукав интегрированы наручные часы \"Тролекс\" с корпусом из армированного углеволокна \
		и декоративной отделкой из полированного гранита. Акустическая изоляция эффективно подавляет внешние помехи, включая несанкционированные \
		голосовые обращения младшего персонала. Внешнее сходство с костюмами \"Мародёров Горлекса\" является <i><b>чистейшим совпадением</i></b>, \
		как заявляют официальные сводки \"Нанотрейзен\"."
	default_skin = "magnate"
	armor_type = /datum/armor/mod_theme_magnate
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|ACID_PROOF // Theft targets should be hard to destroy
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_deployed = 0.25
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_MAGNATE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)
/datum/armor/mod_theme_magnate
	melee = 50
	bullet = 50
	laser = 50
	energy = 15
	bomb = 15
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/praetorian
	name = "модели \"Преторианец\""
	desc = "Прототип костюма класса \"Магнат\", разработанный \"Нанонтрейзен\" специально для элитного подразделения \"Синий Щит\". \
			Обеспечивает максимальную защиту при минимальной модульности."
	extended_desc = "Тактический прототип, послуживший основой для линейки \"Магнат\". Создан для подразделения \"Синий Щит\" как костюм почётной и боевой охраны \
		высокопоставленных лиц. Как и его роскошный преемник, \"Преторианец\" делает акцент на выживаемость: многослойные бронепластины \
		установлены поверх герметичной внутренней обшивки, обеспечивая устойчивость к огню, коррозионным агентам, электрическим разрядам и взрывным волнам. \
		Модульность ограничена базовым набором тактических интерфейсов, что снижает гибкость, но повышает надёжность в экстремальных условиях. Визорная система \
		оснащена активной маскировкой — постоянное голубое свечение скрывает черты лица оператора, обеспечивая необходимый уровень конфиденциальности. \
		Дизайн сознательно лишён элементов комфорта и эстетики, подчёркивая исключительно функциональную природу костюма. Будучи прототипом, \
		модель не попала в массовое производство, но несмотря на это, ограниченные партии были переданы подразделению \"Синий Щит\", \
		специализирующемся на корпоративной охране высокопоставленных лиц \"Нанотрейзен\"."
	default_skin = "praetorian"
	armor_type = /datum/armor/praetorian
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0.25
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/flashlight,
		/obj/item/melee/baton/telescopic,
		/obj/item/kitchen/knife/combat,
	)
	variants = list(
		MOD_VARIANT_PRAETORIAN = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/praetorian
	melee = 45
	bullet = 45
	laser = 35
	energy = 25
	bomb = 45
	bio = 70
	fire = 80
	acid = 100

/datum/mod_theme/cosmohonk
	name = "модели \"Гогот\""
	desc = "Экспериментальный МЭК от компании \"Биб-Ко\", разработанный для выживания в средах с критически низким уровнем юмора. Отличается рекордной энергоэффективностью и яркой расцветкой."
	extended_desc = "Космический хонк-костюм \"Гогот\" создан лучшими инженерами \"Биб-Ко\" для обеспечения безопасности комиков \
		в средах с низким содержанием юмора. Корпус выполнен из вольфрамовой нанополимерной нити, армированной \
		электро-керамической оболочкой с хромовыми включениями. Поверх нанесён дермантиноподобный подпространственный сплав, покрытый \
		циркониево-борной краской в фирменной палитре \"Биб-Ко\". Несмотря на наличие оптико-электронных педалей вакуумного привода, \
		модель сознательно лишена двойных марганцевых очистителей конденсаторов. Энергосистема костюма \
		работает на принципах мистической резонансной оптимизации, что делает его самым энергоэффективным МЭК в своём ценовом диапазоне. Яркая расцветка \
		не только поднимает мораль, но и снижает вероятность кражи мимами на 99.8%, по заявлению производителя."
	default_skin = "cosmohonk"
	armor_type = /datum/armor/mod_theme_cosmohonk
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.25
	slowdown_deployed = 1.25
	allowed_suit_storage = list(
		/obj/item/bikehorn,
		/obj/item/grown/bananapeel,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/instrument,
	)
	variants = list(
		MOD_VARIANT_COSMOHONK = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_cosmohonk
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 5
	bio = 100
	fire = 75
	acid = 50

/datum/mod_theme/syndicate
	name = "модели \"Палач\""
	desc = "Боевой МЭК от \"Мародёров Горлекса\". Данная модель признана нелегальной во многих юрисдикциях Галактического сообщества. \
			Пользуется большой популярностью у наёмников и частных военных подрядчиков, в частности у \"Синдиката\"."
	extended_desc = "Элитный тактический костюм, разработанный \"Мародёрами Горлекса\" при технической поддержке \"Киберсан Индастриз\". \
		Модель \"Палач\" выполнена в фирменной кроваво-красной палитре, являющейся визитной карточкой многих наёмников. \
		Многослойная броня сочетает пласталь и композитную керамику, в то время как подкладка выполнена из кевлара, прошитого дюратканевой нитью, \
		обеспечивая защиту даже в зонах недостаточного покрытия бронепластин. Ключевая особенность — встроенный противолазерный энергощит, \
		эффективный против большинства типов энергетического оружия и не имеющий гражданской сертификации. \
		Одно только наличие этого МЭК является нелегальным во многих частях Галактики, что только поддчёркивает печальную славу данной модели. \
		На внутренней поверхности шлема нанесена маркировка: \"Торговая марка принадлежит компании \"Мародёры Горлекса\", создано при \
		сотрудничестве с \"Киберсан Индастриз\". Все права защищены. Вмешательство в работу внутренних систем повлечёт аннулирование гарантии.\""
	default_skin = "syndicate"
	armor_type = /datum/armor/mod_theme_syndicate
	inbuilt_modules = list(/obj/item/mod/module/welding/syndie)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_SYNDICATE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		MOD_VARIANT_HONKERATIVE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_syndicate
	melee = 45
	bullet = 50
	laser = 40
	energy = 30
	bomb = 50
	bio = 100
	fire = 50
	acid = 100

/datum/mod_theme/elite
	name = "модели \"Каратель\""
	desc = "Элитный боевой МЭК от \"Мародёров Горлекса\" и \"Киберсан Индастриз\", дальнейшее развитие модели \"Палач\". \
			Обеспечивает максимальную защиту в боевых условиях при сохранении тактической мобильности."
	extended_desc = "Прямой преемник боевого костюма \"Палач\", разработанный \"Мародёрами Горлекса\" при технической поддержке \"Киберсан Индастриз\" \
		для высшего командного состава и элитных боевых групп \"Синдиката\". Модель \"Каратель\" выполнена в матово-чёрной палитре, снижающей визуальную и ИК-заметность. \
		Бронирование усилено дополнительным слоем композитных плит на основе керамики и кевлара, что повышает стойкость к бронебойным и термическим угрозам. \
		Несмотря на улучшение защитных показателей, применение облегчённых сплавов нового поколения позволило сохранить скорость и манёвренность на уровне предшественника. \
		На внутренней поверхности шлема нанесена маркировка: \"Торговая марка принадлежит компании \"Мародёры Горлекса\", создано при \
		сотрудничестве с \"Киберсан Индастриз\". Все права защищены. Вмешательство в работу внутренних систем повлечёт аннулирование гарантии.\""
	default_skin = "elite"
	armor_type = /datum/armor/mod_theme_elite
	inbuilt_modules = list(/obj/item/mod/module/welding/syndie)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_ELITE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_elite
	melee = 70
	bullet = 70
	laser = 50
	energy = 35
	bomb = 75
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/contractor
	name = "модели \"Специалист\""
	desc = "Элитный боевой МЭК от \"Мародёров Горлекса\", созданный при поддержке \"Киберсан Индастриз\". \
			Разработан для использования специализированными наёмниками \"Синдиката\"."
	extended_desc = "Редкое отклонение от традиционной кроваво-красной палитры \"Синдиката\". Модель \"Специалист\" создана для независимых контрактников, \
		выполняющих высокорисковые операции. Корпус выполнен из обтекаемых слоёв формованного пластитаниума и композитной керамики, \
		а внутренний подшлемник — из гибридной ткани на основе кевлара и дюраткани, обеспечивающей защиту в зонах минимального бронирования. \
		Ключевые особенности: встроенный хамелеон-модуль с функцией оптической маскировки и противолазерный энергощит, \
		эффективный против большинства видов энергетического оружия. Данная модель признана незаконной в большинстве юрисдикций Галактики, \
		что только подчёркивает её уникальный статус. \
		На внутренней поверхности шлема нанесена маркировка: \"Торговая марка принадлежит компании \"Мародёры Горлекса\", создано при \
		сотрудничестве с \"Киберсан Индастриз\". Все права защищены. Вмешательство в работу внутренних систем повлечёт аннулирование гарантии.\""
	default_skin = "contractor"
	armor_type = /datum/armor/mod_theme_contractor
	inbuilt_modules = list(/obj/item/mod/module/welding/syndie)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 3
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/active_chameleon/elite)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_CONTRACTOR = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_contractor
	melee = 45
	bullet = 50
	laser = 40
	energy = 30
	bomb = 50
	bio = 100
	fire = 50
	acid = 100

/datum/mod_theme/prototype
	name = "модели \"Прототип-478\""
	desc = "Ранний прототип модульного экзокостюма, питаемый стандартным компактным электрогенератором. Обладает высокой модульностью и комфортом, \
			но отличается малой мобильностю и энергозатратностью."
	extended_desc = "Первая в истории модель модульного экзоскелета, признанная безопасной для длительного использования человеком. \
		Несмотря на возраст, исчисляемый десятками, если не сотнями лет, \"Прототип-478\" сохраняет работоспособность благодаря простоте конструкции и избыточности систем. \
		Костюм не оснащён мио-электрическим интерфейсом, а его сервоприводы имеют архаичную компоновку, что приводит к несбалансированному распределению \
		веса и значительному снижению подвижности оператора. Визорная система использует устаревшие индикаторы с токсично-бирюзовым свечением, \
		снижающим дальность эффективного обзора. Выдвигающийся шлем, несмотря на примитивную механику, демонстрирует ранние попытки интеграции \
		динамической защиты и обладает достаточно уникальным дизайном. Множество технологических решений, принятых при создании костюма, \
		явно прослеживаются у современных моделей МЭК."
	default_skin = "prototype"
	armor_type = /datum/armor/mod_theme_prototype
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_deployed = 0.95
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/rpd,
		/obj/item/rcd,
	)
	variants = list(
		MOD_VARIANT_PROTOTYPE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_prototype
	melee = 20
	bullet = 5
	laser = 10
	energy = 10
	bomb = 50
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/responsory
	name = "модели \"Рывок\""
	desc = "Лёгкий тактический МЭК от \"Нанотрейзен\", разработанный для внутренних отрядов быстрого реагирования уровня \"Альфа\". Обеспечивает полную герметизацию и максимальную подвижность."
	extended_desc = "Специализированный костюм для элитных подразделений \"Нанотрейзен\", предназначенных для мгновенного вмешательства в кризисные ситуации. \
		Модель \"Рывок\" выполнена в фирменной матово-чёрной гамме с обтекаемым профилем, минимизирующим аэродинамическое сопротивление \
		и визуальную заметность. В целях снижения массы полностью отказались от керамических бронеплит и абляционных энергощитов, \
		сфокусировавшись на герметичности, скорости и манёвренности. Костюм обеспечивает полную защиту от вакуума, радиации и агрессивных сред, \
		позволяя работать в ширком спектре ситуаций. Несмотря на относительно слабое бронирование, тактическая эффективность \"Рывка\" \
		компенсируется за счёт внезапности и скорости развёртывания. Штатно используется бойцами ОБР уровня \"Альфа\"."
	default_skin = "responsory"
	armor_type = /datum/armor/mod_theme_responsory
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_RESPONSORY = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_responsory
	melee = 40
	bullet = 25
	laser = 30
	energy = 20
	bomb = 25
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/gamma_responsory
	name = "модели \"Паладин\""
	desc = "Элитный тактический МЭК от \"Нанотрейзен\" для отрядов быстрого реагирования уровня \"Гамма\". Сочетает высокую мобильность с усиленной многоспектральной защитой."
	extended_desc = "Прямой преемник модели \"Рывок\", разработанный \"Нанотрейзен\" для подразделений ОБР уровня \"Гамма\". \
		Модель \"Паладин\" интегрирует передовые полимерные наносплавы и экспериментальные технологии, часть из которых находится \
		на стадии патентования. Внешний обтекаемый профиль сохранён, но усилен композитной бронёй, обеспечивающей защиту от термических, \
		кинетических, химических и энергетических угроз. Архитектура костюма поддерживает расширенный набор тактических модулей, \
		что делает его сопоставимым с флагманскими разработками \"Киберсан Индастриз\" и \"Мародёров Горлекса\". \
		Некоторые источники сообщают о подозрительной схожести этой модели с боевыми костюмами \"Синдиката\", в частности \"Каратель\", \
		но официальные представители \"Нанотрейзен\" не дают комментариев на этот счёт. \
		На внутренней поверхности шлема нанесена маркировка: \"Торговая марка принадлежит компании \"Нанотрейзен\". \
		Все права защищены.\""
	default_skin = "inquisitory"
	armor_type = /datum/armor/mod_theme_gamma_responsory
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_INQUISITORY = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHEADSETS,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_gamma_responsory
	melee = 50
	bullet = 45
	laser = 50
	energy = 40
	bomb = 55
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/apocryphal
	name = "модели \"Харон\""
	desc = "Засекреченный высокотехнологичный боевой МЭК совместной разработки \"Нанотрейзен\" и \"Стальной Гвардии\", \
			используемый специальным подразделением \"Нанотрейзен\"."
	extended_desc = "Модель \"Харон\" предназначена исключительно для сценариев крайней необходимости. \
		Одно только знание о факте существования этого костюма является причиной для вашей незамедлительной ликвидации. \
		Многослойная броня является симбиотом лучших технологий бронезащиты \"Нанотрейзен\" и \"Стальной Гвардии\", \
		обеспечивая полную устойчивость к экстремальной температуре, загрязнёнными средам, взрывным волнам и прямым попаданиям тяжёлого вооружения. \
		Встроенные сенсорные массивы предоставляют оператору полную тактическую картину в любых условиях. \
		Данная модель проектировалась для выполнения задач, которые можно кратко охарактеризовать как \"Путь в один конец\"."
	default_skin = "apocryphal"
	armor_type = /datum/armor/mod_theme_apocryphal
	resistance_flags = FIRE_PROOF|ACID_PROOF
	ui_theme = "malfunction"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_APOCRYPHAL = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_apocryphal
	melee = 90
	bullet = 90
	laser = 90
	energy = 90
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/corporate
	name = "модели \"Директор\""
	desc = "Флагманский представительский МЭК от \"Нанотрейзен\" для высокоранговых офицеров центрального командования. \
			Сочетает абсолютную защиту, эксклюзивный комфорт и символический статус неприкосновенности."
	extended_desc = "Передовой корпоративный костюм, разработанный для членов высшего управляющего состава \"Нанотрейзен\". \
		Одни только ботинки этого костюма стоят как 10 \"Магнатов\". Модель \"Директор\" не просто защищает — она подчёркивает \
		исключительный статус носителя. Внешний слой покрыт ручной полировкой из изотопически чистого циркония, \
		придающей костюму глубокий чёрный блеск, не тускнеющий даже в плазменной среде. \
		Интерьер обтянут передовым нановолокном, поддерживающим микроклимат с регулируемой температурой, влажностью и ароматическим фоном. \
		Встроенные сервоприводы премиум-класса полностью нивелируют ощущение массы, обеспечивая оператору ощущение невесомости. \
		Каждый экземпляр изготавливается вручную и проходит личную калибровку под биометрию владельца. \
		Согласно внутреннему уставу \"Нанотрейзен\", любое физическое воздействие на костюм, включая царапины на внешнем покрытии, квалифицируется как \
		\"Акт агрессии против Корпорации\" и служит достаточным основанием для применения <b>крайних</b> мер. \
		Упоминание внешнего сходства костюма с дизайнами других производителей расценивается как нарушение интеллектуальной собственности \"Нанотрейзен\"."
	default_skin = "corporate"
	armor_type = /datum/armor/mod_theme_corporate
	resistance_flags = FIRE_PROOF|ACID_PROOF

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/melee/baton,
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_CORPORATE = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR|HIDEHEADSETS,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)


/datum/armor/mod_theme_corporate
	melee = 200
	bullet = 200
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/debug
	name = "для тестирования"
	desc = "Вызывает приступы ностальгии у кодеров ТГ."
	extended_desc = "Продвинутый костюм, использующий двойные ионные двигатели  и позволяющий пользователю летать. \
		Внутри находится продвинутый самозарядный конденсатор, позволя- \
		Погодите, это же просто скин для дебаг-костюма! Вот блядь..."
	default_skin = "debug"
	armor_type = /datum/armor/mod_theme_debug
	resistance_flags = FIRE_PROOF|ACID_PROOF

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = 50
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_DEBUG = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHEADSETS,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_debug
	melee = 200
	bullet = 200
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/administrative // Absolute cinema
	name = "модели \"Админисратор\""
	desc = "Сверх крутой и мега-продвинутый костюм, сделанный из... да кому не плевать."
	extended_desc = "Ну че, опять придумал \"охуенный\" и очень осмысленный ивент, где ты прилетаешь на станцию в лучшей броне \
		с перекрученными цифрами, ходишь туда сюда как еблан всех убивая или что-то в таком духе? Не забудь шаттл отозвать, \
		когда половина станции в гостах сидит, и отменить все ивентовые события, администратор хуев."
	default_skin = "debug"
	armor_type = /datum/armor/mod_theme_administrative
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = 1000
	charge_drain = DEFAULT_CHARGE_DRAIN * 0
	siemens_coefficient = 0
	slowdown_deployed = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	variants = list(
		MOD_VARIANT_DEBUG = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHEADSETS,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_administrative
	melee = 200
	bullet = 200
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
