/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "Водолазка с цифровым камуфляжным принтом и брюки карго, которые выглядят слегка подозрительно."
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	has_sensor = 0
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 40)
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "тактическая водолазка",
		GENITIVE = "тактической водолазки",
		DATIVE = "тактической водолазке",
		ACCUSATIVE = "тактическую водолазку",
		INSTRUMENTAL = "тактической водолазкой",
		PREPOSITIONAL = "тактической водолазке"
	)

/obj/item/clothing/under/syndicate/combat
	name = "combat turtleneck"

/obj/item/clothing/under/syndicate/combat/get_ru_names()
	return list(
		NOMINATIVE = "боевая водолазка",
		GENITIVE = "боевой водолазки",
		DATIVE = "боевой водолазке",
		ACCUSATIVE = "боевую водолазку",
		INSTRUMENTAL = "боевой водолазкой",
		PREPOSITIONAL = "боевой водолазке"
	)

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Увидев это, хочется приобрести карабин СКС, уйти в лес и \"оперировать\""
	icon_state = "tactifool"
	item_state = "bl_suit"
	item_color = "tactifool"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 40)

/obj/item/clothing/under/syndicate/tacticool/get_ru_names()
	return list(
		NOMINATIVE = "тактикульная водолазка",
		GENITIVE = "тактикульной водолазки",
		DATIVE = "тактикульной водолазке",
		ACCUSATIVE = "тактикульную водолазку",
		INSTRUMENTAL = "тактикульной водолазкой",
		PREPOSITIONAL = "тактикульной водолазке"
	)

/obj/item/clothing/under/syndicate/tacticool/skirt
	name = "tacticool skirt"
	desc = "Увидев это, хочется приобрести карабин СКС, уйти в лес и \"оперировать\""
	icon_state = "tactifoolf"
	item_state = "bl_suit"
	item_color = "tactifoolf"

/obj/item/clothing/under/syndicate/tacticool/skirt/get_ru_names()
	return list(
		NOMINATIVE = "тактикульная юбка",
		GENITIVE = "тактикульной юбки",
		DATIVE = "тактикульной юбке",
		ACCUSATIVE = "тактикульную юбку",
		INSTRUMENTAL = "тактикульной юбкой",
		PREPOSITIONAL = "тактикульной юбке"
	)

/obj/item/clothing/under/syndicate/sniper
	name = "Tactical turtleneck suit"
	desc = "Тактическая водолазка с двойным швом, замаскированная под гражданский шелковый костюм. Предназначена для самых требовательных оперативников. Воротник очень острый."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/syndicate/sniper/get_ru_names()
	return list(
		NOMINATIVE = "тактический формальный костюм",
		GENITIVE = "тактического формального костюма",
		DATIVE = "тактическому формальному костюму",
		ACCUSATIVE = "тактический формальный костюм",
		INSTRUMENTAL = "тактическим формальным костюмом",
		PREPOSITIONAL = "тактическом формальном костюме"
	)

/obj/item/clothing/under/syndicate/sniper_civ
	name = "Executive tacticool suit"
	desc = "Модель тактической водолазки предназначена для ведения переговоров, а не для участия в боевых действиях."
	icon_state = "black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/syndicate/sniper_civ/get_ru_names()
	return list(
		NOMINATIVE = "тактикульный формальный костюм",
		GENITIVE = "тактикульного формального костюма",
		DATIVE = "тактикульному формальному костюму",
		ACCUSATIVE = "тактикульный формальный костюм",
		INSTRUMENTAL = "тактикульным формальным костюмом",
		PREPOSITIONAL = "тактикульном формальном костюме"
	)

/obj/item/clothing/under/syndicate/blackops
	name = "Black ops coverall"
	desc = "Прочный комбинезон, созданный для тайных операций в тылу врага. Благодаря кевларовым вставкам, он обеспечивает лёгкую защиту."
	icon_state = "blackops"
	item_state = "blackops"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15,ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 10, ACID = 0)

/obj/item/clothing/under/syndicate/blackops/get_ru_names()
	return list(
		NOMINATIVE = "комбинезон для спецопераций",
		GENITIVE = "комбинезона для спецопераций",
		DATIVE = "комбинезону для спецопераций",
		ACCUSATIVE = "комбинезон для спецопераций",
		INSTRUMENTAL = "комбинезоном для спецопераций",
		PREPOSITIONAL = "комбинезоне для спецопераций"
	)

/obj/item/clothing/under/syndicate/blackops_civ
	name = "Black ops coverall"
	desc = "Стильный комбинезон, но из дешёвого материала. Не предназначен для активного использования в бою."
	icon_state = "blackops"
	item_state = "blackops"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/under/syndicate/blackops_civ/get_ru_names()
	return list(
		NOMINATIVE = "тактикульный комбинезон для спецопераций",
		GENITIVE = "тактикульного комбинезона для спецопераций",
		DATIVE = "тактикульному комбинезону для спецопераций",
		ACCUSATIVE = "тактикульный комбинезон для спецопераций",
		INSTRUMENTAL = "тактикульным комбинезоном для спецопераций",
		PREPOSITIONAL = "тактикульном комбинезоне для спецопераций"
	)

/obj/item/clothing/under/plasmaman/syndie
	name = "tacticool envirosuit"
	desc = "Зловещий на вид защитный костюм для самых костлявых оперативников."
	icon_state = "syndie_envirosuit"
	item_color = "syndie_envirosuit"
	has_sensor = 0
	resistance_flags = FIRE_PROOF

/obj/item/clothing/under/plasmaman/syndie/get_ru_names()
	return list(
		NOMINATIVE = "тактический защитный костюм плазмолюда",
		GENITIVE = "тактического защитного костюма плазмолюда",
		DATIVE = "тактическому защитному костюму плазмолюда",
		ACCUSATIVE = "тактический защитный костюм плазмолюда",
		INSTRUMENTAL = "тактическим защитным костюмом плазмолюда",
		PREPOSITIONAL = "тактическом защитном костюме плазмолюда"
	)
