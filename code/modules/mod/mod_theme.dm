/// Global proc that sets up all MOD themes as singletons in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme

/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD. Used in parts name. Looks something like "нагрудник модульного костюма [name] модели"
	var/name = "базовой"
	/// Description added to the MOD.
	var/desc = "Гражданский модульный костюм, разработанный корпорацией \"Индустрия Киберсан\". Не имеет никаких особенностей."
	/// Extended description on description_info
	var/extended_desc = "Третье поколение модульных гражданских костюмов, созданных корпорацией \"Индустрия Киберсан\". \
		Данный тип костюмов является самым популярным среди гражданских лиц по всей галактике. Совместимые со всеми известными видами, \
		эти костюмы имеют замкнутую систему дыхания, пригодны для использования в космосе, защищают от возгораний и химических угроз \
		и предоставляют биологическую защиту от всего, начиная с простым кашлем и заканчивая современным биооружием. Однако данный костюм \
		практически невозможно использовать в бою из-за крайне посредственного бронепокрытия и пневматических актуаторов прошлого поколения."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = ITEM_SLOT_BACK
	/// Armor shared across the MOD parts.
	var/obj/item/mod/armor/armor_type_1 = /obj/item/mod/armor/mod_theme
	/// the actual armor object placed in a datum as I am tired and I just want this to work
	/// var/obj/item/mod/armor/armor_type_2 = null
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
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Allowed items in the chestplate's suit storage.
	var/list/allowed_suit_storage = list()
	/// List of skins with their appropriate clothing flags.
	var/list/skins = list(
		"standard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"civilian" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
				SEALED_INVISIBILITY = HIDEHAIR,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/mod_theme/standard //We don't want the civilian skin to apply to all modsuits, that causes issues.
	name = "гражданской модели"


/datum/mod_theme/New()
	. = ..()
	armor_type_1 = new armor_type_1()

/obj/item/mod/armor/mod_theme
	armor = list(MELEE = 25, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 0, BIO = 80, RAD = 25, FIRE = 33, ACID = 33)

/datum/mod_theme/engineering
	name = "инженерной"
	desc = "Стандартный инженерный костюм, обладающий повышенной защитой от огня и радиации. Неумирающая классика от \"Киберсан\"."
	extended_desc = "Один из самых известных костюмов от \"Индустрии Киберсан\", сразу же после гражданской модели. Прямой потомок \
		морально устаревших ИКС-ов, данный модульный костюм обладает огромным множеством функций, превосходя своих родителей практически во всём. \
		Модульный дизайн костюма, изоляционная внутрення прокладка и бронированное внешнее покрытие позволяет пользователю работать в самых \
		неблагоприятных условиях, не переживая за своё здоровье. Однако сам костюм недалеко ушел от гражданской версии и его модификация, как и \
		боевые возможности сильно ограничены."
	default_skin = "engineering"
	armor_type_1 = /obj/item/mod/armor/mod_theme_engineering
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1.5
	slowdown_active = 0.75
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe,
	)
	skins = list(
		"engineering" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_engineering
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 40, BIO = 80, RAD = 80, FIRE = 70, ACID = 100)

/datum/mod_theme/atmospheric
	name = "атмосферной"
	desc = "Модифицированный инженерный костюм, производимый корпорацией \"Индустрия Киберсан\" и обладающий огромной защитой от высоких температур."
	extended_desc = "Данный костюм, выпущенный на рынок \"Индустрией Киберсан\" является прямой модификацией инженерного костюма. \
		Данная модель была усовершенствована с помощью новейших жаропрочных сплавов, продвинутых радиаторов и теплоотводов. \
		Помимо прочего, костюм обладает повышенной защитой от коррозийных газов и жидкостей, что очень важно при работе \
		с кристаллом суперматерии. Самым главным недостатком данной модели является посредственная защита от радиоактивного загрязнения и \
		посредственные боевые возможности, сопоставимые с гражданской версией костюма."
	default_skin = "atmospheric"
	armor_type_1 = /obj/item/mod/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	siemens_coefficient = 0
	slowdown_inactive = 1.5
	slowdown_active = 0.75
	allowed_suit_storage = list(
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe/,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer
	)
	skins = list(
		"atmospheric" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDENAME|HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_atmospheric
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 80, RAD = 15, FIRE = 100, ACID = 100)

/datum/mod_theme/advanced
	name "усовершенствованной"
	desc = "Продвинутая версия классического костюма корпорации \"Индустрия Киберсан\", являющаяся лучшим на рынке индустриальным костюмом."
	extended_desc = "Флагман среди индустриальной линейки костюмов от \"Индустрии Киберсан\", при этом этосамый новый продукт на рынке. \
		Совмещая все особенности и преимущества стандартных инженерных и атмосферных костюмов, костюм обладает очень мощной защитой от взрывов, \
		сравнимой с некоторыми сапёрными костюмами. Внешне костюм покрыт особенной белой краской, состав которой является корпоративным секретом. \
		Краска, помимо того, что обладает одним из лучших антикоррозийных эффектов на рынке, еще и \"выглядит чертовски хорошо.\" В костюме по умолчанию \
		встроены магнитные ботинки, использующие одни из лучших технологий на рынке. Впрочем, как и всё в этом костюме."
	default_skin = "advanced"
	armor_type_1 = /obj/item/mod/armor/mod_theme_advanced
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.45
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/rcd,
		/obj/item/twohanded/fireaxe,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/rpd,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/gun

	)
	skins = list(
		"advanced" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME,
				SEALED_INVISIBILITY = HIDEMASK|HIDEGLASSES|HIDEHAIR|HIDENAME,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT|HIDETAIL,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_advanced
	armor = list(MELEE = 45, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 60, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)

/datum/mod_theme/mining
	name = "шахтёрской"
	desc = ""
