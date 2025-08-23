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
	name = "усовершенствованной"
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
		/obj/item/melee/baton/telescopic,
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
	desc = "Модульный костюм, разработанный корпорацией Нанотрейзен, имеющий встроенные модули пепельной брони и превращения в сферу."
	extended_desc = "Продвинутый костюм, разработанный Нанотрейзен, основанный на ранних разработках \"Киберсан\" \
		Хотя более ранние модели создавались для астероидной добычи и имели повышенную защиту от взрывов, новые версии \
		костюма, значительно доработанные самими шахтерскими командами с использованием нестандартных технологий, потеряли \
		возможность для выхода в открытый космос. Продвинутый визор, установленный в плечо костюма, обладает мощной камерой, \
		охватывающей всё пространство вокруг пользователя. Часть бронеплит с костюма были заменены на гораздо менее прочные сплавы, \
		которые больше приспособлены для защиты от опасной внешней среды, чем от агрессивной фауны планеты. Вместо стандартной брони, \
		костюм использует продвинутые аттракторы для сбора частиц пепла из воздуха и равномерного распределения их по поверхности костюма. \
		Подобные дополнительные пепельные слои брони невероятно крепкие, хотя и распадаются после первого же удара. Все модификации \
		костюма показали себя невероятно энергозатратными, от чего все новые костюмы идут в комплексте с продвинутой версией ядра, \
		которое пользователи могут подзаряжать на ходу, листы плазмы или плазменной руды. К сожалению, все системы костюма работают \
		на износ, от чего у пользователя будут серьезные ограничения в сфере модификаций и улучшений костюма."
	default_skin = "mining"
	armor_type_1 = /obj/item/mod/armor/mod_theme_mining
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 1.5
	slowdown_active = 0.5
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
	skins = list(
		"mining" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE,

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
		"asteroid" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE,
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

/obj/item/mod/armor/mod_theme_mining
	armor = list(MELEE = 40, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 50, BIO = 80, RAD = 50, FIRE = 50, ACID = 50)

/datum/mod_theme/loader
	name = "погрузочной"
	desc = "Грузовой экзоскелет, разработанный корпорацией \"Вооружения Скарборо\" для более быстрой сортировки и транспортировки вооружения."
	extended_desc = "Данный модульный костюм значительно отличается от стандартных костюмов на рынке. Костюм представляет из себя \
		гидравлический титановый экзоскелет, который используется военными грузчиками и доставщиками боеприпасов к передовой по всей галактике. \
		Костюм не обладает хоть какой бы то ни было защитой от космоса, однако этот недостаток с лихвой покрывается мощностью и удобностью костюма. \
		Главной особенностью костюма можно назвать две руки-манипулятора, синхронизированные с нервной системой носителя, от чего \
		дополнительные руки способны исполнять действия без каких либо задержек. Продвинутая гидравлическая система усиливает носителя, \
		позволя ему поднимать тяжести весом в несколько тонн без видимых усилий. Дополнительные гидравлические моторы, установленные на \
		ногах пользователя значительно повышают мобильность, позволяя ему передвигаться быстрее и на более длительные расстояния. Нельзя \
		сказать, что этот костюм хоть как-то защищен, однако сама компоновка костюма позволяет сохранить наиболее ценные части костюма в случае \
		смерти пользователя. Многие люди говорят, что разгрузка и загрузка ящиков это одна из самых скучных работ в галактике. С данным костюмом \
		это утверждение становится не более чем неуместной шуткой."
	default_skin = "loader"
	armor_type_1 = /obj/item/mod/armor/mod_theme_loader
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list()
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	skins = list(
		"loader" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEHAIR,
				SEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
			),
			GAUNTLETS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/obj/item/mod/armor/mod_theme_loader
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 80, RAD = 0, FIRE = 25, ACID = 25)

/datum/mod_theme/medical
	name = "медицинской"
	desc = "Легковесный модульный костюм, разработанный корпорацией \"Вей-мед\". Гораздо мобильнее, чем другие версии."
	extended_desc = "Модульный костюм, созданный корпорацией \"Вей-мед\" в сотрудничестве с \"Кибернетикой Бишопа\". \
		Продвинутые технологии позволили изолировать пользователя от любого типа биологического загрязнения во внешней \
		среде. Главным преимуществом костюма является его повышенная, по сравнению с другими моделями, скорость, получаемая \
		благодаря улучшенным сервоприводам и актуаторам. Хотя у костюма практически отсутствует какое бы то ни было бронирование, \
		костюм обладает полной защитой от любых видов коррозийных кислот. Костюм слегка энергозатратнее, чем гражданские модели и \
		неспособен ничего противопоставить в случае, если защитное стекло заляпают пальцами."
	default_skin = "medical"
	armor_type_1 = /obj/item/mod/armor/mod_theme_medical
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 1
	slowdown_active = 0.45
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
	skins = list(
		"medical" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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
		"corpsman" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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

/obj/item/mod/armor/mod_theme_medical
	armor = list(MELEE = 20, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 0, FIRE = 75, ACID = 100)

/datum/mod_theme/rescue
	name = "спасательной"
	desc = "Продвинутая версия медицинского костюма, созданная для работы в опасной и загрязненной среде."
	extended_desc = "Улучшенная, значительно доработанная версия стандартного медицинского модульного костюма, \
		созданного корпорацией \"Вей-мед\" в сотрудничестве с \"Кибернетикой Бишопа\". Продвинутые ножные сервоприводы \
		теперь установлены по всему костюму, от чего парамедик при использовании данного костюма способен быстро поднимать \
		и перемещать даже самых тучных членов экипажа в безопасность, при этом костюм обладает полной защитой от \
		высоких температур. Костюм значительно энергозатратнее, чем гражданские модели и неспособен \
		ничего противопоставить в случае, если защитное стекло заляпают пальцами."
	default_skin = "rescue"
	armor_type_1 = /obj/item/mod/armor/mod_theme_rescue
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
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
	skins = list(
		"rescue" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = COLLAR_LAYER,

				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
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

/obj/item/mod/armor/mod_theme_rescue
	armor = list(MELEE = 30, BULLET = 30, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 100, RAD = 50, FIRE = 100, ACID = 100)

/datum/mod_theme/research
	name = "исследовательской"
	desc = "Массивный сапёрный костюм, производимый \"Оружейной Ауссек\". Переоборудован для исследовательской работы. Ужасно громоздкий."
	extended_desc = "Сапёрный костюм, созданный частной военной корпорацией \"Оружейная Ауссек\". Изначально \
		создававшийся для работы со взрывчаткой, костюм, вместе с лицензией на массовое производство, был приобретен \
		НаноТрейзен и переоборудован для исследовательской работы с токсинными бомбами. Ужасающе громоздкий, костюм \
		использует многослойную пластитановую обшивку, совмещенную с экспериментальными сплавами, поглощающими кинетические \
		волны энергии. Хотя костюм и способен пережить прямое попадание из артиллерии или ракеты, вся эта защита нужна в первую \
		очередь для того, чтобы пользователь не разлетелся на ошметки. Само выживание внутри костюма никогда не гарантировалось. \
		Внутри костюма установлена сканирующая матрица, позволяющая определять содержимое контейнеров на расстоянии."
	default_skin = "research"
	armor_type_1 = /obj/item/mod/armor/mod_theme_research
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 1.75
	slowdown_active = 1
	ui_theme = "changeling"
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/hand_tele,
		/obj/item/storage/bag/bio,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/gun
	)
	skins = list(
		"research" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDENAME|HIDEMASK|HIDEGLASSES,
				SEALED_INVISIBILITY = HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES,
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

/obj/item/mod/armor/mod_theme_research
	armor = list(MELEE = 40, BULLET = 40, LASER = 15, ENERGY = 15, BOMB = 100, BIO = 80, RAD = 75, FIRE = 75, ACID = 100)

