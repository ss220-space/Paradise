/obj/item/clothing/under/rank/procedure
	icon = 'icons/obj/clothing/uniforms/procedure.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/rank/procedure/internal
	desc = "The plain, professional attire of a Lawyer. The collar is <i>immaculately</i> starched."
	name = "lawyer uniform"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/procedure/internal/skirt
	name = "lawyer uniform with skirt"
	icon_state = "internalaffairsf"
	item_state = "internalaffairsf"
	item_color = "internalaffairsf"

/obj/item/clothing/under/rank/procedure/lawyer
	name = "Lawyer suit"
	desc = "Slick threads."

/obj/item/clothing/under/rank/procedure/lawyer/black
	name = "black lawyer suit"
	icon_state = "lawyer_black"
	item_state = "lawyer_black"
	item_color = "lawyer_black"

/obj/item/clothing/under/rank/procedure/lawyer/female
	name = "female lawyer suit"
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/rank/procedure/lawyer/red
	name = "red lawyer suit"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"
	item_color = "lawyer_red"

/obj/item/clothing/under/rank/procedure/lawyer/blue
	name = "blue lawyer suit"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"
	item_color = "lawyer_blue"

/obj/item/clothing/under/rank/procedure/lawyer/bluesuit
	name = "Blue Suit"
	desc = "A classy suit and tie"
	icon_state = "bluesuit"
	item_state = "bluesuit"
	item_color = "bluesuit"

/obj/item/clothing/under/rank/procedure/lawyer/purpsuit
	name = "Purple Suit"
	icon_state = "lawyer_purp"
	item_state = "lawyer_purp"
	item_color = "lawyer_purp"

/obj/item/clothing/under/rank/procedure/lawyer/oldman
	name = "Old Man's Suit"
	desc = "A classic suit for the older gentleman with built in back support."
	icon_state = "oldman"
	item_state = "oldman"
	item_color = "oldman"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/rank/procedure/representative
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа имеет обозначение \"ИСН Кибериада\" на левом плече."
	name = "Formal Nanotrasen Representative's Uniform"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/procedure/representative/get_ru_names()
	return alist(
		NOMINATIVE = "парадная униформа Представителя \"Нанотрейзен\"",
		GENITIVE = "парадной униформы Представителя \"Нанотрейзен\"",
		DATIVE = "парадной униформе Представителя \"Нанотрейзен\"",
		ACCUSATIVE = "парадную униформу Представителя \"Нанотрейзен\"",
		INSTRUMENTAL = "парадной униформой Представителя \"Нанотрейзен\"",
		PREPOSITIONAL = "парадной униформе Представителя \"Нанотрейзен\"",
	)

/obj/item/clothing/under/rank/procedure/representative/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_DESC)

/obj/item/clothing/under/rank/procedure/representative/update_desc(updates = ALL)
	. = ..()
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа имеет обозначение \"[station_name()]\" на левом плече."

/obj/item/clothing/under/rank/procedure/magistrate
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа имеет нашивку \"Магистрат\" и имеет обозначение \"ИСН Кибериада\" на левом плече."
	name = "Formal Magistrate's Uniform"
	icon_state = "officer"
	item_state = "g_suit"
	item_color = "officer"
	displays_id = 0

/obj/item/clothing/under/rank/procedure/magistrate/get_ru_names()
	return alist(
		NOMINATIVE = "парадная униформа Магистрата",
		GENITIVE = "парадной униформы Магистрата",
		DATIVE = "парадной униформе Магистрата",
		ACCUSATIVE = "парадную униформу Магистрата",
		INSTRUMENTAL = "парадной униформой Магистрата",
		PREPOSITIONAL = "парадной униформе Магистрата",
	)

/obj/item/clothing/under/rank/procedure/magistrate/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_DESC)

/obj/item/clothing/under/rank/procedure/magistrate/update_desc(updates = ALL)
	. = ..()
	desc = "Золотая отделка на чёрной, как космос, ткани. Эта униформа имеет нашивку \"Магистрат\" и имеет обозначение \"[station_name()]\" на левом плече."


/obj/item/clothing/under/rank/procedure/ntrep
	desc = "A well-ironed dress shirt and matching set of black pants."
	name = "dress shirt"
	icon_state = "internalaffairs"
	item_state = "internalaffairs"
	item_color = "internalaffairs"

/obj/item/clothing/under/rank/procedure/ntrep/skirt
	desc = "Black bottom, white top."
	name = "representative skirt"
	icon_state = "ntrepf"
	item_state = "ntrepf"
	item_color = "ntrepf"

/obj/item/clothing/under/rank/procedure/blueshield
	name = "blueshield's uniform"
	desc = "Короткорукавая чёрная форма в сочетании с серыми штанами карго с цифровым камуфляжем, все из прочного материала. Стандартное снаряжение офицера \"Синий Щит\"."
	icon_state = "blueshield"
	item_state = "bl_suit"
	item_color = "ert_uniform"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/under/rank/procedure/blueshield/get_ru_names()
	return alist(
		NOMINATIVE = "униформа Синего Щита",
		GENITIVE = "униформы Синего Щита",
		DATIVE = "униформе Синего Щита",
		ACCUSATIVE = "униформу Синего Щита",
		INSTRUMENTAL = "униформой Синего Щита",
		PREPOSITIONAL = "униформе Синего Щита",
	)

/obj/item/clothing/under/rank/procedure/blueshield/skirt
	name = "blueshield's skirt"
	desc = "Короткая униформа с юбкой, чёрно-серая, с синими маркировками. Для женственного офицера \"Синий Щит\"."
	icon_state = "blueshieldf"
	item_state = "blueshieldf"
	item_color = "blueshieldf"

/obj/item/clothing/under/rank/procedure/blueshield/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "юбка Синего Щита",
		GENITIVE = "юбки Синего Щита",
		DATIVE = "юбке Синего Щита",
		ACCUSATIVE = "юбку Синего Щита",
		INSTRUMENTAL = "юбкой Синего Щита",
		PREPOSITIONAL = "юбке Синего Щита",
	)
