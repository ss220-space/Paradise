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
	var/desc = "Гражданский модульный экзо-костюм, разработанный корпорацией \"Киберсан\". Не имеет никаких особенностей."
	/// Extended description on description_info
	var/extended_desc = "Третье поколение модульных гражданских костюмов, созданных корпорацией \"Киберсан\". \
		Данный тип костюмов является самым популярным среди гражданских лиц по всей галактике. Совместимые со всеми известными видами, \
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
		"standard" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
		part.name = "[name] [part.name]"
		part.desc = "[part.desc] </p> [desc]"
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
		part_datum.unsealed_message = category[UNSEALED_MESSAGE] || "No unseal message set! Tell a coder!"
		part_datum.sealed_message = category[SEALED_MESSAGE] || "No seal message set! Tell a coder!"
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

/datum/armor/mod_theme
	melee = 25
	bullet = 15
	laser = 15
	energy = 15
	bomb = 0
	bio = 80
	rad = 25
	fire = 33
	acid = 33

/datum/mod_theme/civilian
	name = "гражданской модели"
	desc = "Лёгкий гражданский МЭК, предостовляющий невероятную свободу движений, но не обеспечивает какой-либо защиты от давления."
	extended_desc = "Экспериментальная разработка компании Nakamura Engineering, предназначенная для потребителей, путешествующих по планете. \
					Эта модель жертвует защитой от биологических и химических угроз, а также космического вакуума в обмен на \
					значительно улучшенную мобильность. Благодаря уменьшенному профилю он также обладает меньшими возможностями для модификации по сравнению с \
					основными моделями."
	default_skin = "civilian"
	armor_type = /datum/armor/mod_theme_civilian
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_deployed = 0
	variants = list(
		"civilian" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"standard" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 25
	fire = 33
	acid = 33

/datum/mod_theme/engineering
	name = "инженерной модели"
	desc = "Стандартный инженерный костюм, обладающий повышенной защитой от огня и радиации. Нестареющая классика от \"Киберсан\"."
	extended_desc = "Один из самых известных костюмов от \"Киберсан\", сразу же после гражданской модели. Прямой потомок \
		морально устаревших ИКС-ов, данный модульный костюм обладает огромным множеством функций, превосходя своих родителей практически во всём. \
		Модульный дизайн костюма, изоляционная внутрення прокладка и бронированное внешнее покрытие позволяет пользователю работать в самых \
		неблагоприятных условиях, не переживая за своё здоровье. Однако сам костюм недалеко ушел от гражданской версии и его модификация, как и \
		боевые возможности сильно ограничены."
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
		"engineering" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 80
	fire = 70
	acid = 10

/datum/mod_theme/atmospheric
	name = "модели \"Атмосфера\""
	desc = "Модифицированный инженерный костюм, производимый корпорацией \"Киберсан\" и обладающий огромной защитой от высоких температур."
	extended_desc = "Данный костюм, выпущенный на рынок \"Киберсан\" является прямой модификацией инженерного костюма. \
		Данная модель была усовершенствована с помощью новейших жаропрочных сплавов, продвинутых радиаторов и теплоотводов. \
		Помимо прочего, костюм обладает повышенной защитой от коррозийных газов и жидкостей, что очень важно при работе \
		с кристаллом суперматерии. Самым главным недостатком данной модели является посредственная защита от радиоактивного загрязнения и \
		никчемные боевые возможности, сопоставимые с гражданской версией костюма."
	default_skin = "atmospheric"
	armor_type = /datum/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	siemens_coefficient = 0
	slowdown_deployed = 0.75
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe/,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer
	)
	variants = list(
		"atmospheric" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 15
	fire = 100
	acid = 100

/datum/mod_theme/advanced
	name = "продвинутой модели"
	desc = "Продвинутая версия классического костюма корпорации \"Киберсан\", являющаяся лучшим на рынке индустриальным костюмом."
	extended_desc = "Флагман в индустриальной линейке костюмов от \"Киберсан\", новейший продукт на рынке. \
		Совмещая все особенности и преимущества стандартных инженерных и атмосферных костюмов, он обладает очень мощной защитой от взрывов, \
		сравнимой с некоторыми специальными сапёрными костюмами. Костюм покрыт особенной белой краской, состав которой является корпоративным секретом. \
		Краска, помимо того, что обладает одним из лучших антикоррозийных эффектов на рынке, еще и \"выглядит чертовски хорошо.\" В конструкцию костюма встроены \
		магнитные ботинки, созданные с применением самых передовых технологий. Впрочем, как и всё в этом костюме."
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
		/obj/item/gun

	)
	variants = list(
		"advanced" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDENAME,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/mining
	name = "шахтёрской модели"
	desc = "Модульный костюм, разработанный корпорацией Нанотрейзен, имеющий встроенные модули пепельной брони и превращения в сферу."
	extended_desc = "Продвинутый костюм, созданный Нанотрейзен на основе ранних наработок \"Киберсан\". \
		Хотя первые линейки моделей создавались для астероидной добычи и имели повышенную защиту от взрывов, новые версии \
		костюма, значительно доработанные по отзывам от шахтерских команд, потеряли возможность для выхода в открытый космос. \
		Продвинутый визор, установленный в плечо костюма, обладает мощной камерой, охватывающей всё \
		пространство вокруг пользователя. Часть бронеплит с костюма были заменены менее прочными облегчёнными сплавами, \
		более приспособленными для защиты от опасной внешней среды, чем от агрессивной фауны. Вместо стандартной брони \
		костюм использует продвинутые аттракторы для сбора частиц пепла из воздуха и равномерного распределения их по поверхности костюма. \
		Спресованные пепельные слои предоставляют невероятно прочную защиту, несмотря на то что распадаются после первого же удара. \
		Все модификации костюма показали себя крайне энергозатратными, отчего новые экземпляры поступают в комплекте с продвинутой версией ядра, \
		которое пользователь может подзаряжать на ходу, используя листы плазмы или плазменную руду. Чтобы снизить затраты на производство, \
		инженерам пришлось отказаться от высокой модульности, вместо этого сделав акцент на надёжности и простоте в эксплуатации. \
		Из-за этого костюм значительно ограничен в возможностях модификации и улучшения."
	default_skin = "mining"
	armor_type = /datum/armor/mod_theme_mining
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
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
		"mining" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"asteroid" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDENAME,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 50
	fire = 50
	acid = 50


/datum/mod_theme/loader
	name = "грузовой модели"
	desc = "Грузовой экзоскелет, разработанный корпорацией \"Вооружения Скарборо\" для более быстрой сортировки и транспортировки вооружения."
	extended_desc = "Данный модульный экзо-костюм значительно отличается от стандартных костюмов на рынке. Он представляет из себя \
		гидравлический титановый экзоскелет, который используется по всей галактике военными грузчиками и доставщиками боеприпасов к передовой. \
		Костюм не обладает какой бы то ни было защитой от космоса, однако этот недостаток с лихвой покрывается мощностью и простотой в использовании. \
		Его главной особенностью можно назвать две руки-манипулятора, синхронизированные с нервной системой носителя, \
		что позволяет использовать дополнительные руки без каких либо задержек. Продвинутая гидравлическая система усиливает пользователя, \
		позволяя ему поднимать тяжести весом в несколько тонн без видимых усилий. Дополнительные гидравлические моторы повышают мобильность \
		давая носителю возможность передвигаться быстрее и на более длинные расстояния. Костюм не обладает никакой защитой, \
		однако сама компоновка экзоскелета позволяет сохранить наиболее ценные детали в случае смерти пользователя. \
		Многие говорят, что погрузка и разгрузка ящиков — одна из самых тяжёлых и скучных работ в галактике. С данным костюмом \
		это утверждение становится не более чем завистливой шуткой."
	default_skin = "loader"
	armor_type = /datum/armor/mod_theme_loader
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_deployed = 0
	allowed_suit_storage = list()
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	variants = list(
		"loader" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEHAIR,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
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
	rad = 0
	fire = 25
	acid = 25

/datum/mod_theme/medical
	name = "медицинской модели"
	desc = "Легковесный модульный костюм, разработанный корпорацией \"Вей-мед\". Гораздо мобильнее, чем другие версии."
	extended_desc = "Модульный костюм, созданный корпорацией \"Вей-мед\" в сотрудничестве с \"Кибернетикой Бишопа\". \
		Полностью замкнутая система дыхания и фильтрации воздуха позволила изолировать пользователя от любого возможного \
		биологического загрязнения внешней среды. \
		Главным преимуществом костюма является его повышенная, по сравнению с другими моделями, скорость, достигаемая \
		за счёт улучшенных сервоприводов и рессоров. Хотя у костюма практически отсутствует какое бы то ни было бронирование, \
		он обладает полной защитой от любых видов коррозийных кислот. Костюм слегка энергозатратнее, чем гражданские модели и \
		не способен ничего противопоставить в случае, если защитное стекло заляпают пальцами."
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
		"medical" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"corpsman" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 0
	fire = 75
	acid = 100

/datum/mod_theme/rescue
	name = "модели \"Спасатель\""
	desc = "Продвинутая версия медицинского костюма, созданная для работы в опасной и загрязнённой среде."
	extended_desc = "Значительно доработанная версия стандартного медицинского модульного экзо-костюма, \
		созданного корпорацией \"Вей-мед\" в сотрудничестве с \"Кибернетикой Бишопа\". Продвинутые сервоприводы \
		теперь установлены по всему костюму, отчего носитель способен быстро поднимать \
		и перемещать даже самых тучных членов экипажа в безопасное место, при этом гарантируя пользователю полную защитой от \
		высоких температур. Костюм значительно энергозатратнее, чем гражданские модели и не способен \
		ничего противопоставить в случае, если защитное стекло заляпают пальцами."
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
		"rescue" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 50
	fire = 100
	acid = 100

/datum/mod_theme/research
	name = "модели \"Учёный\""
	desc = "Массивный сапёрный костюм, производимый \"Оружейной Ауссек\". Переоборудован для исследовательской работы. Ужасно громоздкий."
	extended_desc = "Сапёрный костюм, созданный частной военной корпорацией \"Оружейная Ауссек\". Изначально \
		создававшийся для работы со взрывчаткой, костюм, вместе с лицензией на массовое производство, был приобретен \
		\"Нанотрейзен\" и переоборудован для исследовательской работы с токсинными бомбами. Ужасающе громоздкий, костюм \
		использует многослойную пластитановую обшивку, совмещенную с экспериментальными сплавами, поглощающими кинетические \
		волны энергии. Хотя костюм и способен пережить прямое попадание из артиллерии или ракеты, вся эта защита нужна в первую \
		очередь для того, чтобы пользователь не разлетелся на ошмётки. Выживание находящегося внутри костюма человека никогда не гарантировалось. \
		Внутри костюма установлена сканирующая матрица, позволяющая определять содержимое контейнеров на расстоянии."
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
		/obj/item/gun
	)
	variants = list(
		"research" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_research
	melee = 40
	bullet = 40
	laser = 15
	energy = 15
	bomb = 10
	bio = 80
	rad = 75
	fire = 75
	acid = 100

/datum/mod_theme/security
	name = "службы безопасности" //"это шлем МЭК службы безопасности"
	desc = "Боевой костюм для силовых структур, жертвующий грузоподъёмностью в пользу скорости. Разработан корпорацией \"Стальная Гвардия\"."
	extended_desc = "Классическое решение от \"Стальной Гвардии\" для острых ситуаций, требующих быстрого силового реагирования. \
		Обшивка этих костюмов способна выдержать прямое воздействие огня и коррозийных сред, а сеточная композитная структура материала \
		превосходно амортизирует удары и обеспечивает защиту от переломов и повреждений. \
		Ноги костюма снабжены износостойчивыми приводами, позволяющими переносить большие веса. \
		Несмотря на все плюсы, системы костюма технологически устарели на несколько лет, \
		в связи с чем возможности по модификации ограничены."
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
		"security" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 0
	fire = 60
	acid = 100

/datum/mod_theme/safeguard_mk_one
	name = "модели \"Защитник-1\""
	desc = "Старая версия боевого костюма от \"Стальной Гвардии\", предоставляющая большую скорость и серьёзную защиту от огня."
	extended_desc = "Продвинутый боевой костюм от \"Стальной Гвардии\", их прошлая наиболее популярная модель. \
		Менее надёжный и более дорогой в производстве, чем современные модели, однако обладает повышенными защитными показателями. \
		В этом варианте костюма полностью отказались от стандартного визора из армированного стекла, заменив его \
		ударо- и взрывостойким визором, передающим носителю картинку через маленькую камеру на левой стороне. \
		Бронирование костюма было значительно усилено, особенно в области плеч, создавая носителю внушительный образ. \
		Костюм оснащён улучшенной изоляцией от коррозийных сред и укреплённой защитой на стыках. По бокам расположены радиаторы \
		для отвода тепла из модулей системы. Массовое производство было прекращено в пользу других моделей."
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
		"safeguard-ward" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 20
	fire = 70
	acid = 100

/datum/mod_theme/safeguard_mk_two
	name = "модели \"Защитник-2\""
	desc = "Усовершенствованный боевой костюм корпорации \"Стальная Гвардия\", предоставляющий более высокую скорость и защиту, чем стандартные модели."
	extended_desc = "Усовершенствованный боевой костюм корпорации \"Стальная Гвардия\", и их самая последняя модель. \
		Воплощает в себе все преимущества прошлых моделей, а благодаря использованию в обшивке новейших композитных наноматериалов \
		сочетает лёгкий вес, обеспечивающий более высокую скорость носителя, с продвинутым бронированием. \
		Обладает большей грузоподъёмностью и улучшенной версией джетпака, а также расширенными возможностями для модификации."
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
		"safeguard" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 30
	fire = 80
	acid = 100

/datum/mod_theme/security_medical
	name = "модели \"Военный врач\""
	desc = "Совместный проект тяжёлого костюма корпораций \"Вей-мед\" и \"Стальная Гвардия\", предназначенный для спасения и оказания помощи даже посреди поля боя."
	extended_desc = "Совместный проект двух специализирующихся на противоположных вещах корпораций стал неожиданностью даже для них самих. \
		Однако рынок диктует свои условия, и в итоге на свет появился костюм, изначально предназначенный для парамедиков силовых структур, \
		спасающих людей под вражеским огнём, в условиях разгерметизации, пожаров и биологических заражений. Прототипы хорошо себя зарекомендовали, \
		поэтому вскоре развернулось массовое производство. Предоставляет баланс между мобильностью, грузоподъёмностью и защитой, \
		однако вряд ли остановит крупнокалиберную пулю. Нагрудная пластина украшена знакомым любому красным крестом."
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
		"security-med" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 50
	fire = 70
	acid = 100

/datum/mod_theme/magnate
	name = "модели \"Магнат\""
	desc = "Роскошный, крайне защищённый костюм класса \"Магнат\" для капитанских должностей Нанотрейзен. Устойчив к электричеству, огню, кислоте и воплям ассистентов о помощи. Обеспечивает высокую скорость и грузоподъёмность."
	extended_desc = "Говорят, что поддержание этого костюма активным стоит сорок тысяч кредитов... в секунду. \
		Этот шикарный костюм класса \"Магнат\" разработан для обеспечения защиты, комфорта и роскоши капитанов Нанотрейзен. \
		Интерфейс позволяет настроить поступающий через фильтры воздух на подачу пяти сотен разных ароматов \
		краснокнижных видов цветов прямиком в шлем. В рукав костюма установлены изготовленные на заказ часы \"Тролекс\" \
		с запонками из армированного углеволокна. Бог ты мой, на них даже есть ручная гранитная отделка! \
		Кропотливо нанёсенная в два слоя ручным таярским трудом краска предоставляет защиту от электрического шока, огня и сильнейших кислот. \
		Бортовые системы задействуют мета-позитронное обучение и блюспейс обработку данных, открывая простор для широкого спектра модификаций, \
		а для движения задействованы только самые лучшие приводы. Внешнее сходство со шлемом \"Мародёров Горлекса\" является чистейшим <b>\"совпадением\" </b>."
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
		"magnate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 50
	fire = 100
	acid = 100

/datum/mod_theme/praetorian
	name = "модели \"Преторианец\""
	desc = "Прототип костюма класса \"Магнат\", предназначенный для станционного офицера \"Синий Щит\". Обладает исключительной защитой, идеально подходящей для почётной охраны."
	extended_desc = "Прототип костюма класса \"Магнат\", предназначенный для станционных офицеров \"Синий Щит\". \
		Может похвастаться по большей части схожим с его преемником уровнем защиты, уступая лишь по вместимости модулей модификации. \
		\"Магнат\" обязан прототипу большей частью защиты, но ни каплей комфорта! Визор излучает голубое свечение для сокрытия \
		лица носителя, добавляя ему внушения. По сравнению с элегантным и роскошным дизайном преемника, этот костюм \
		абсолютно никак не скрывает свое истинное предназначение — укреплённые бронепластины наслаиваются поверх \
		изолированной внутренней обшивки, гарантируя носителю защиту от коррозийных сред, взрывных воздействий, огня, электрического \
		шока и презрения со стороны остального экипажа."
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
		/obj/item/kitchen/knife/combat
	)
	variants = list(
		"praetorian" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 45
	fire = 80
	acid = 100

/datum/mod_theme/cosmohonk
	name = "клоунской модели"
	desc = "Костюм изготовленный самой Хонкомамой Инкорпорейтед. Предоставляет защиту от окружающей среды с низким уровнем юмора. Девяносто девять процентов усилий ушло на повышение энергоэффективности."
	extended_desc = "Космический хонк-костюм был изначально разработан для межзвёздных комедий в среде с низким содержанием шуток. \
		В обшивке костюма использована вольфрамовая нанополимерная нить, укреплённая электро-керамической оболочкой \
		с примесями хрома, под дермантиновый подпространственный сплав нанесён слой циркониево-борной краски. \
		Несмотря на вызывающе очевидное наличие оптико-электронных педалей вакуумного привода, эта конкретная модель \
		не содержит двойные марганцевые очистители конденсаторов, упаси Хонкоматерь. \
		Вы точно знаете одно — этот костюм мистически энергоэффективен и слишком цветастый, чтобы мим захотел его красть."
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
		"cosmohonk" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 0
	fire = 75
	acid = 50

/datum/mod_theme/syndicate
	name = "синдиката" //Это шлем МЭК синдиката
	desc = "Костюм, разработанный \"Мародёрами Горлекса\". Один только внешний вид считается нелегальным у большей части разумных рас галактического сообщества."
	extended_desc = "Продвинутый боевой костюм, ставший воплощением многих инновационных решений. Создан на пике современных технологий. \
		Исполнен в легко узнаваемой кроваво-красной палитре, которая теперь является визитной карточкой многих наёмников. \
		Внешняя конструкция представляет собой обтекаемую многослойную структуру из пластали и композитной керамики, в то время \
		как подкладка выполнена из кевлара, прошитого дюратканевой нитью. Это сочетание обеспечивает достойную защиту носителя в тех местах, \
		где недостаточно покрытия обычных бронепластин. Дополнительно в костюм встроен нелегальный модуль абляционного щита, \
		гарантирующий сопротивление большинству используемых видов энергетического оружия. \
		На нём приклеена маленькая бирка: \"Торговая марка принадлежит \"Мародёрам Горлекса\", создано при сотрудничестве с \"Киберсан\". \
		Все права защищены, нарушение целостности внутренней системы костюма повлечёт аннулирование вашей гарантии.\""
	default_skin = "syndicate"
	armor_type = /datum/armor/mod_theme_syndicate

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0.5 //This is EVA mode slowdown. In combat mode, no slowdown.
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
		"syndicate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"honkerative" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 50
	acid = 100

/datum/mod_theme/elite
	name = "элиты синдиката"
	desc = "Элитный боевой костюм, модернизированный корпорацией \"Киберсан\". Предоставляет превосходную защиту от всех видов угроз."
	extended_desc = "Развитие концепции хорошо зарекомендовавшего себя кроваво-красного костюма. \
		Имеет более громоздкую конструкцию и исполнен в матово-чёрной палитре. \
		Создавался для высокопоставленных офицеров Синдиката и элитных ударных отрядов, потому обладает исключительными показателями \
		и такой же ценой производства. Пулевая защита усовершенствована за счёт дополнительного слоя бронепластин, \
		сочетающих кевлар и керамику. Новейшие сплавы позволили облегчить вес костюма, гарантируя лучшую, \
		по сравнению с предшественником, защиту, при той же скорости и мобильности. \
		На нём приклеена маленькая бирка: \"Торговая марка принадлежит \"Мародёрам Горлекса\", создано при сотрудничестве с \"Киберсан\". \
		Все права защищены, нарушение целостности внутренней системы костюма повлечёт аннулирование вашей жизни.\""
	default_skin = "elite"
	armor_type = /datum/armor/mod_theme_elite
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0.5 //This is EVA mode slowdown. In combat mode, no slowdown.
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
		"elite" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/prototype
	name = "экспериментальной модели"
	desc = "Прототип модульного экзо-костюма, питаемый обычным компактным электрогенератором. Хоть он вполне комфортный и обладает большой вместимостью под модули, он остаётся крайне громоздким и энергозатратным."
	extended_desc = "Это прототип силового экзоскелета, дизайн, устаревший уже на сотни лет. Считается самой первой версией модульного экзо-костюма, \
		который смог безопасно надеть и использовать человек. Этот доисторический реликт на удивление всё ещё функционирует, \
		хотя ему и не достаёт множества современных технологических решений и удобств, уже ставших привычными по костюмам \"Киберсан\". \
		Прежде всего, в конструкции отсутствует мио-электрический слой, а сервоприводы имеют примитивную компоновку, несбалансированно \
		распределяя вес костюма по телу носителя, делая любые попытки движения в нём тяжёлыми и неуклюжими. \
		Нескрываемые внутренние индикаторы визора используют практически нечитаемый токсично-бирюзовый цвет, затрудняя видимость носителя \
		на дальние расстояния. Ну, хотя бы выдвигающийся шлем выглядит действительно круто."
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
		"prototype" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 50
	fire = 100
	acid = 100

/datum/mod_theme/responsory
	name = "отряда быстрого реагирования"
	desc = "Подвижный и лёгкий костюм от \"Нанотрейзен\", внутренняя разработка для собственных отрядов быстрого реагирования."
	extended_desc = "Модернизированный костюм фирменного дизайна \"Нанотрейзен\", эту изящную чёрную броню носят только \
		бойцы отрядов быстрого реагирования. Хоть в обтекаемом дизайне этого костюма и пожертвовали защитой, \
		полностью отказавшись от керамических бронеплит и абляционных модулей, костюм гарантирует носителю полную защиту от \
		губительного воздействия космоса, при этом нисколько не стесняя его скорость и подвижность. \
		Нося его, вы ощущаете безграничное почтение к темноте."
	default_skin = "responsory"
	armor_type = /datum/armor/mod_theme_responsory

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
		"responsory" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"inquisitory" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/gamma_responsory
	name = "военного подразделения ОБР"
	desc = "Усовершенствованный костюм от \"Нанотрейзен\", продвинутый вариант для отрядов быстрого реагирования уровня \"ГАММА\"."
	extended_desc = "Многократно улучшенный вариант обычного костюма для отрядов быстрого реагирования. \
		В этой версии применены последние разработки в области полимерных наносплавов и несколько ещё даже не запатентованных технологий, \
		вершина инженерной мысли Нанотрейзен. Или они хотят чтобы вы в это верили. Лёгкая обтекаемая форма предшественника получила \
		усиленную защиту от всех видов воздействий и повышенную вместимость модулей. Сочетание исключительной мобильности и бронирования \
		ставит этот костюм на один уровень с передовыми разработками \"Киберсан\" и \"Мародёров Горлекса\". Ходят слухи, что \
		за дизайн элитного боевого костюма Синдиката и этой версии ответственны одни и те же инженеры, но подтверждений этому нет. \
		На нём приклеена маленькая бирка: \"Торговая марка принадлежит \"Нанотрейзен\". Все права защищены.\""
	default_skin = "responsory"
	armor_type = /datum/armor/mod_theme_gamma_responsory
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
		"elite ERT" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = COLLAR_LAYER,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		)
	)


/datum/armor/mod_theme_gamma_responsory
	melee = 50
	bullet = 45
	laser = 50
	energy = 40
	bomb = 55
	bio = 100
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/apocryphal
	name = "засекреченной модели"
	desc = "Высокотехнологичный, не существующий ни в одном документе бронированный костюм, созданный совместными усилиями \"Нанотрейзен\" и \"Стальной Гвардии\"."
	extended_desc = "Громоздкий, словно танк, и легальный только в техническом смысле боевой костюм в зловещей черно-красной расцветке. \
		Будет последним, что вы увидите, потому как этот костюм используется лишь специальным подразделением \"Нанотрейзен\", \
		за знание одного только факта существования которых было ликвидировано множество людей. \
		Плодотворное сотрудничество двух оружейных гигантов привело к созданию этого поистине шедеврального инженерного творения, \
		бросающего вызов всей известной ныне тактике ведения боя. Список использованных в производстве материалов и сплавов \
		невозможно уместить на всей поверхности брони этого костюма. Следствием этого является непревзойденные никем защитные показатели, \
		энергоэффективность и мобильность. Носитель этого костюма может не боясь шагнуть в огонь, взрыв, под шквал пуль или раскалённой плазмы. \
		Бесчисленные датчики и сенсоры отображают на дисплей всю возможную информацию окружения, которая только может понадобиться пользователю."
	default_skin = "apocryphal"
	armor_type = /datum/armor/mod_theme_apocryphal
	resistance_flags = FIRE_PROOF|ACID_PROOF
	ui_theme = "malfunction"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
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
		"apocryphal" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/corporate
	name = "модели \"Корпорат\""
	desc = "Элегантный высокотехнологичный костюм для высокоранговых офицеров центрального командования \"Нанотрейзен\"."
	extended_desc = "Ещё более дорогая версия модели \"Магнат\". Идеально защищён от температур, кислот и ударных воздействий. \
		Впрочем, никто в галактике не рискнул бы применить ударное воздействие к носителю подобного костюма. \
		Продвинутые сервоприводы делают костюм практически невесомым. Попытка даже поцарапать краску этого костюма считается \
		военным преступлением и легальным поводом для казни на месте во всем подконтрольном \"Нанотрейзен\" пространстве. \
		Внешнее сходство со шлемом \"Мародёров Горлекса\" является чистейшим <b>\"совпадением\"</b>.."
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
		"corporate" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/debug
	name = "для тестирования"
	desc = "Вызывает приступы ностальгии у кодеров ТГ."
	extended_desc = "Продвинутый костюм, использующий двойные ионные двигатели  и позволяющий пользователю летать. \
		Внутри находится продвинутый самозарядный конденсатор, позволя- \
		Погодите, это же просто скин для дебаг-костюма. Вот блядь."
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
		"debug" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100

/datum/mod_theme/administrative
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
		"debug" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
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
	rad = 100
	fire = 100
	acid = 100
