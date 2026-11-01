/obj/item/clothing/under/miscellaneous
	icon = 'icons/clothing/uniforms/misc.dmi'

/obj/item/clothing/under/miscellaneous/pj/red
	name = "red pj's"
	desc = "Одежда для сна."
	icon_state = "red_pyjamas"
	item_color = "red_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/miscellaneous/pj/red/get_ru_names()
	return alist(
		NOMINATIVE = "красная пижама",
		GENITIVE = "красной пижамы",
		DATIVE = "красной пижаме",
		ACCUSATIVE = "красную пижаму",
		INSTRUMENTAL = "красной пижамой",
		PREPOSITIONAL = "красной пижаме",
	)

/obj/item/clothing/under/miscellaneous/pj/blue
	name = "blue pj's"
	desc = "Одежда для сна."
	icon_state = "blue_pyjamas"
	item_color = "blue_pyjamas"
	item_state = "w_suit"

/obj/item/clothing/under/miscellaneous/pj/blue/get_ru_names()
	return alist(
		NOMINATIVE = "синяя пижама",
		GENITIVE = "синей пижамы",
		DATIVE = "синей пижаме",
		ACCUSATIVE = "синюю пижаму",
		INSTRUMENTAL = "синей пижамой",
		PREPOSITIONAL = "синей пижаме",
	)

/obj/item/clothing/under/miscellaneous/patriotsuit
	name = "Patriotic Suit"
	desc = "Патриот слушает..."
	icon_state = "ek"
	item_state = "ek"
	item_color = "ek"

/obj/item/clothing/under/miscellaneous/patriotsuit/get_ru_names()
	return alist(
		NOMINATIVE = "костюм патриота",
		GENITIVE = "костюма патриота",
		DATIVE = "костюму патриота",
		ACCUSATIVE = "костюм патриота",
		INSTRUMENTAL = "костюмом патриота",
		PREPOSITIONAL = "костюме патриота",
	)

/obj/item/clothing/under/miscellaneous/scratch
	name = "white suit"
	desc = "Белый костюм, подходящий для замечательного хозяина."
	icon_state = "scratch"
	item_state = "scratch"
	item_color = "scratch"

/obj/item/clothing/under/miscellaneous/scratch/get_ru_names()
	return alist(
		NOMINATIVE = "белый костюм",
		GENITIVE = "белого костюма",
		DATIVE = "белому костюму",
		ACCUSATIVE = "белый костюм",
		INSTRUMENTAL = "белым костюмом",
		PREPOSITIONAL = "белом костюме",
	)

/obj/item/clothing/under/miscellaneous/waiter
	name = "waiter's outfit"
	desc = "Очень элегантная униформа с специальным отсеком для чаевых."
	icon_state = "waiter"
	item_state = "waiter"
	item_color = "waiter"

/obj/item/clothing/under/miscellaneous/waiter/get_ru_names()
	return alist(
		NOMINATIVE = "костюм официанта",
		GENITIVE = "костюма официанта",
		DATIVE = "костюму официанта",
		ACCUSATIVE = "костюм официанта",
		INSTRUMENTAL = "костюмом официанта",
		PREPOSITIONAL = "костюме официанта",
	)

/obj/item/clothing/under/miscellaneous/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Доставочка!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"

/obj/item/clothing/under/miscellaneous/mailman/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон почтальона",
		GENITIVE = "комбинезона почтальона",
		DATIVE = "комбинезону почтальона",
		ACCUSATIVE = "комбинезон почтальона",
		INSTRUMENTAL = "комбинезоном почтальона",
		PREPOSITIONAL = "комбинезоне почтальона",
	)

/obj/item/clothing/under/miscellaneous/mailman/skirt
	name = "mailman's jumpskirt"
	icon_state = "mail_skirt"
	item_color = "mail_skirt"

/obj/item/clothing/under/miscellaneous/mailman/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "юбка почтальона",
		GENITIVE = "юбки почтальона",
		DATIVE = "юбке почтальона",
		ACCUSATIVE = "юбку почтальона",
		INSTRUMENTAL = "юбкой почтальона",
		PREPOSITIONAL = "юбке почтальона",
	)

/obj/item/clothing/under/miscellaneous/space
	name = "NASA jumpsuit"
	desc = "Имеет логотип \"NASA\" и создан из космостойких материалов."
	icon_state = "jumpsuit"
	item_state = "bl_suit"
	item_color = "black"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/under/miscellaneous/space/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон \"NASA\"",
		GENITIVE = "комбинезона \"NASA\"",
		DATIVE = "комбинезону \"NASA\"",
		ACCUSATIVE = "комбинезон \"NASA\"",
		INSTRUMENTAL = "комбинезоном \"NASA\"",
		PREPOSITIONAL = "комбинезоне \"NASA\"",
	)

/obj/item/clothing/under/miscellaneous/space/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/under/color/black/temp_item = new(null)
	icon = temp_item.icon
	onmob_sheets = temp_item.onmob_sheets
	sprite_sheets = temp_item.sprite_sheets
	qdel(temp_item)

/obj/item/clothing/under/miscellaneous/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(MELEE = 100, BULLET = 100, LASER = 100,ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/under/miscellaneous/acj/get_ru_names()
	return alist(
		NOMINATIVE = "кибернетический комбинезон админа",
		GENITIVE = "кибернетического комбинезона админа",
		DATIVE = "кибернетическому комбинезону админа",
		ACCUSATIVE = "кибернетический комбинезон админа",
		INSTRUMENTAL = "кибернетическим комбинезоном админа",
		PREPOSITIONAL = "кибернетическом комбинезоне админа",
	)

/obj/item/clothing/under/miscellaneous/johnny
	name = "johnny~~ jumpsuit"
	desc = "Джонни~~"
	icon_state = "johnny"
	item_color = "johnny"

/obj/item/clothing/under/miscellaneous/johnny/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон Джонни~~",
		GENITIVE = "комбинезона Джонни~~",
		DATIVE = "комбинезону Джонни~~",
		ACCUSATIVE = "комбинезон Джонни~~",
		INSTRUMENTAL = "комбинезоном Джонни~~",
		PREPOSITIONAL = "комбинезоне Джонни~~",
	)

/obj/item/clothing/under/miscellaneous/blackskirt
	name = "black skirt"
	desc = "Чёрная юбка. Она шикарна!"
	icon_state = "blackskirt"
	item_color = "blackskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/miscellaneous/blackskirt/get_ru_names()
	return alist(
		NOMINATIVE = "чёрная юбка",
		GENITIVE = "чёрной юбки",
		DATIVE = "чёрной юбке",
		ACCUSATIVE = "чёрную юбку",
		INSTRUMENTAL = "чёрной юбкой",
		PREPOSITIONAL = "чёрной юбке",
	)

/obj/item/clothing/under/miscellaneous/overalls
	name = "laborer's overalls"
	desc = "Набор прочной рабочей одежды, чтобы выполнить всю работу."
	icon_state = "overalls"
	item_state = "lb_suit"
	item_color = "overalls"

/obj/item/clothing/under/miscellaneous/overalls/get_ru_names()
	return alist(
		NOMINATIVE = "рабочий комбинезон",
		GENITIVE = "рабочего комбинезона",
		DATIVE = "рабочему комбинезону",
		ACCUSATIVE = "рабочий комбинезон",
		INSTRUMENTAL = "рабочим комбинезоном",
		PREPOSITIONAL = "рабочем комбинезоне",
	)

/obj/item/clothing/under/miscellaneous/redcoat
	name = "redcoat uniform"
	desc = "Выглядит старомодно."
	icon_state = "redcoat"
	item_state = "redcoat"
	item_color = "redcoat"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/miscellaneous/redcoat/get_ru_names()
	return alist(
		NOMINATIVE = "красный мундир",
		GENITIVE = "красного мундира",
		DATIVE = "красному мундиру",
		ACCUSATIVE = "красный мундир",
		INSTRUMENTAL = "красным мундиром",
		PREPOSITIONAL = "красном мундире",
	)

/obj/item/clothing/under/miscellaneous/ash_walker
	name = "ash-walker uniform"
	desc = "Простая, но надежная одежда из ткани, пропитанная пеплом. Швы украшены символами племени, а потертые края выглядят так, будто они видели не одно извержение вулкана."
	icon_state = "ash"
	item_state = "ash"
	item_color = "ash"
	has_sensor = FALSE

/obj/item/clothing/under/miscellaneous/ash_walker/get_ru_names()
	return alist(
		NOMINATIVE = "одеяние пеплоходца",
		GENITIVE = "одеяния пеплоходца",
		DATIVE = "одеянию пеплоходца",
		ACCUSATIVE = "одеяние пеплоходца",
		INSTRUMENTAL = "одеянием пеплоходца",
		PREPOSITIONAL = "одеянии пеплоходца",
	)

/obj/item/clothing/under/miscellaneous/ash_walker_shaman
	name = "shaman tribal rags"
	desc = "Пропитанные пеплом лохмотья с Лазиса, с костяными украшениями, усыпанными грубыми самоцветами на шее. Кажется, это одеяние предназначено для шамана племени."
	icon_state = "shamanrags"
	item_state = "shamanrags"
	item_color = "shamanrags"
	has_sensor = FALSE
	species_restricted = list(SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID)

/obj/item/clothing/under/miscellaneous/ash_walker_shaman/get_ru_names()
	return alist(
		NOMINATIVE = "лохмотья шамана",
		GENITIVE = "лохмотьев шамана",
		DATIVE = "лохмотьям шамана",
		ACCUSATIVE = "лохмотья шамана",
		INSTRUMENTAL = "лохмотьями шамана",
		PREPOSITIONAL = "лохмотьях шамана",
	)

/obj/item/clothing/under/miscellaneous/flappers
	name = "flappers"
	desc = "Ничто не сравнится с ревущими двадцатыми, когда ночь напролёт пляшешь на танцполе."
	icon_state = "flapper"
	item_state = "flapper"
	item_color = "flapper"

/obj/item/clothing/under/miscellaneous/flappers/get_ru_names()
	return alist(
		NOMINATIVE = "флэпперсы",
		GENITIVE = "флэпперсов",
		DATIVE = "флэпперсам",
		ACCUSATIVE = "флэпперсы",
		INSTRUMENTAL = "флэпперсами",
		PREPOSITIONAL = "флэпперсах",
	)

/obj/item/clothing/under/miscellaneous/bane
	name = "Bane Harness"
	desc = "Надень эту упряжь, чтобы стать проклятием станции"
	icon_state = "bane"
	item_state = "bane"
	item_color = "bane"

/obj/item/clothing/under/miscellaneous/bane/get_ru_names()
	return alist(
		NOMINATIVE = "упряжь Бэйна",
		GENITIVE = "упряжи Бэйна",
		DATIVE = "упряже Бэйна",
		ACCUSATIVE = "упряжу Бэйна",
		INSTRUMENTAL = "упряжой Бэйна",
		PREPOSITIONAL = "упряже Бэйна",
	)

/obj/item/clothing/under/miscellaneous/rebeloutfit
	name = "Rebel Outfit"
	desc = "Сделано в Сиэтле, 2216."
	icon_state = "colin_earle"
	item_state = "colin_earle"
	item_color = "colin_earle"

/obj/item/clothing/under/miscellaneous/rebeloutfit/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон сопротивления",
		GENITIVE = "комбинезона сопротивления",
		DATIVE = "комбинезону сопротивления",
		ACCUSATIVE = "комбинезон сопротивления",
		INSTRUMENTAL = "комбинезоном сопротивления",
		PREPOSITIONAL = "комбинезоне сопротивления",
	)

/obj/item/clothing/under/miscellaneous/rockso
	name = "Rockso Costume"
	desc = "Я НЮХАЮ КОКАИН!"
	icon_state = "rocksouniform"
	item_color = "rocksouniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/uniform.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/uniform.dmi',
	)

/obj/item/clothing/under/miscellaneous/rockso/get_ru_names()
	return alist(
		NOMINATIVE = "костюм Роксо",
		GENITIVE = "костюма Роксо",
		DATIVE = "костюму Роксо",
		ACCUSATIVE = "костюм Роксо",
		INSTRUMENTAL = "костюмом Роксо",
		PREPOSITIONAL = "костюме Роксо",
	)

/obj/item/clothing/under/miscellaneous/assistantformal
	name = "assistant's formal uniform"
	desc = "Парадная одежда ассистента. Зачем ассистенту нужен деловой вид, никто не знает."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	item_color = "assistant_formal"

/obj/item/clothing/under/miscellaneous/assistantformal/get_ru_names()
	return alist(
		NOMINATIVE = "парадная униформа ассистента",
		GENITIVE = "парадной униформы ассистента",
		DATIVE = "парадной униформе ассистента",
		ACCUSATIVE = "парадную униформу ассистента",
		INSTRUMENTAL = "парадной униформой ассистента",
		PREPOSITIONAL = "парадной униформе ассистента",
	)

/obj/item/clothing/under/miscellaneous/cursedclown
	name = "cursed clown suit"
	desc = "It wasn't already?"
	icon = 'icons/goonstation/objects/clothing/uniform.dmi'
	icon_state = "cursedclown"
	item_state = "cclown_uniform"
	item_color = "cursedclown"
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_INNER_STRING = 'icons/goonstation/mob/clothing/uniform.dmi',
	)
	lefthand_file = 'icons/goonstation/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/clothing_righthand.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	has_sensor = 0 // HUNKE

/obj/item/clothing/under/miscellaneous/cursedclown/get_ru_names()
	return alist(
		NOMINATIVE = "проклятая одежда клоуна",
		GENITIVE = "проклятой одежды клоуна",
		DATIVE = "проклятой одежде клоуна",
		ACCUSATIVE = "проклятую одежду клоуна",
		INSTRUMENTAL = "проклятой одеждой клоуна",
		PREPOSITIONAL = "проклятой одежде клоуна",
	)

/obj/item/clothing/under/miscellaneous/cursedclown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/under/miscellaneous/medigown
	name = "medical gown"
	desc = "Халат, предназначенный для использования медицинским персоналом. \
			Изготовлен из лёгкой ткани с минимальной защитой от биологических загрязнений. \
			Застёжки на спине слабые и не застёгиваются должным образом, \
			что делает этот халат не самым популярным выбором среди остальной униформы."
	icon_state = "medicalgown"
	item_state = "medicalgown"
	item_color = "medicalgown"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/miscellaneous/medigown/get_ru_names()
	return alist(
		NOMINATIVE = "медицинский халат",
		GENITIVE = "медицинского халата",
		DATIVE = "медицинскому халату",
		ACCUSATIVE = "медицинский халат",
		INSTRUMENTAL = "медицинским халатом",
		PREPOSITIONAL = "медицинском халате",
	)

/obj/item/clothing/under/miscellaneous/burial
	name = "burial garments"
	desc = "Традиционная погребальная одежда с раннего 22-го века."
	icon_state = "burial"
	item_state = "burial"
	item_color = "burial"

/obj/item/clothing/under/miscellaneous/burial/get_ru_names()
	return alist(
		NOMINATIVE = "погребальная одежда",
		GENITIVE = "погребальной одежды",
		DATIVE = "погребальной одежде",
		ACCUSATIVE = "погребальную одежду",
		INSTRUMENTAL = "погребальной одеждой",
		PREPOSITIONAL = "погребальной одежде",
	)

/obj/item/clothing/under/miscellaneous/redhawaiianshirt
	name = "red hawaiian shirt"
	desc = "Цветочная рубашка — подходящий наряд для большинства курортов."
	icon_state = "hawaiianred"
	item_state = "hawaiianred"
	item_color = "hawaiianred"

/obj/item/clothing/under/miscellaneous/redhawaiianshirt/get_ru_names()
	return alist(
		NOMINATIVE = "красная гавайская рубашка",
		GENITIVE = "красной гавайской рубашки",
		DATIVE = "красной гавайской рубашке",
		ACCUSATIVE = "красную гавайскую рубашку",
		INSTRUMENTAL = "красной гавайской рубашкой",
		PREPOSITIONAL = "красной гавайской рубашке",
	)

/obj/item/clothing/under/miscellaneous/pinkhawaiianshirt
	name = "pink hawaiian shirt"
	desc = "Розовая цветочная рубашка — подходящий наряд для большинства курортов."
	icon_state = "hawaiianpink"
	item_state = "hawaiianpink"
	item_color = "hawaiianpink"

/obj/item/clothing/under/miscellaneous/pinkhawaiianshirt/get_ru_names()
	return alist(
		NOMINATIVE = "розовая гавайская рубашка",
		GENITIVE = "розовой гавайской рубашки",
		DATIVE = "розовой гавайской рубашке",
		ACCUSATIVE = "розовую гавайскую рубашку",
		INSTRUMENTAL = "розовой гавайской рубашкой",
		PREPOSITIONAL = "розовой гавайской рубашке",
	)

/obj/item/clothing/under/miscellaneous/orangehawaiianshirt
	name = "orange hawaiian shirt"
	desc = "Оранжевая цветочная рубашка — подходящий наряд для большинства курортов."
	icon_state = "hawaiianorange"
	item_state = "hawaiianorange"
	item_color = "hawaiianorange"

/obj/item/clothing/under/miscellaneous/orangehawaiianshirt/get_ru_names()
	return alist(
		NOMINATIVE = "оранжевая гавайская рубашка",
		GENITIVE = "оранжевой гавайской рубашки",
		DATIVE = "оранжевой гавайской рубашке",
		ACCUSATIVE = "оранжевую гавайскую рубашку",
		INSTRUMENTAL = "оранжевой гавайской рубашкой",
		PREPOSITIONAL = "оранжевой гавайской рубашке",
	)

/obj/item/clothing/under/miscellaneous/bluehawaiianshirt
	name = "blue hawaiian shirt"
	desc = "Синяя цветочная рубашка — подходящий наряд для большинства курортов."
	icon_state = "hawaiianblue"
	item_state = "hawaiianblue"
	item_color = "hawaiianblue"

/obj/item/clothing/under/miscellaneous/bluehawaiianshirt/get_ru_names()
	return alist(
		NOMINATIVE = "синяя гавайская рубашка",
		GENITIVE = "синей гавайской рубашки",
		DATIVE = "синей гавайской рубашке",
		ACCUSATIVE = "синюю гавайскую рубашку",
		INSTRUMENTAL = "синей гавайской рубашкой",
		PREPOSITIONAL = "синей гавайской рубашке",
	)

/obj/item/clothing/under/miscellaneous/durathread
	name = "durathread jumpsuit"
	desc = "Комбинезон из дюраткани. Его усиленные волокна защищают от повреждений."
	icon_state = "durathread"
	item_state = "durathread"
	item_color = "durathread"
	armor = list(melee = 10, bullet = 0, laser = 10, energy = 0, bomb = 5, bio = 0, fire = 0, acid = 0)

/obj/item/clothing/under/miscellaneous/durathread/get_ru_names()
	return alist(
		NOMINATIVE = "дюратканевый комбинезон",
		GENITIVE = "дюратканевого комбинезона",
		DATIVE = "дюратканевому комбинезона",
		ACCUSATIVE = "дюратканевый комбинезон",
		INSTRUMENTAL = "дюратканевым комбинезоном",
		PREPOSITIONAL = "дюратканевом комбинезоне",
	)

/obj/item/clothing/under/miscellaneous/cuban_suit
	name = "rhumba outfit"
	desc = "Атласная рубашка и брюки с завышенной талией, которые носят танцоры в стиле румбы. Пахнет странно... серой?"
	icon_state = "cuban_suit"
	item_state = "cuban_suit"
	item_color = "cuban_suit"

/obj/item/clothing/under/miscellaneous/cuban_suit/get_ru_names()
	return alist(
		NOMINATIVE = "наряд для румбы",
		GENITIVE = "наряда для румбы",
		DATIVE = "наряду для румбы",
		ACCUSATIVE = "наряд для румбы",
		INSTRUMENTAL = "нарядом для румбы",
		PREPOSITIONAL = "наряде для румбы",
	)

/obj/item/clothing/under/miscellaneous/tourist_suit
	name = "tourist outfit"
	desc = "Голубая рубашка с коричневыми шортами. Почему-то настораживает."
	icon_state = "tourist"
	icon_state = "tourist"
	item_color = "tourist"

/obj/item/clothing/under/miscellaneous/tourist_suit/get_ru_names()
	return alist(
		NOMINATIVE = "наряд туриста",
		GENITIVE = "наряда туриста",
		DATIVE = "наряду туриста",
		ACCUSATIVE = "наряд туриста",
		INSTRUMENTAL = "нарядом туриста",
		PREPOSITIONAL = "наряде туриста",
	)

/obj/item/clothing/under/miscellaneous/colour/skirt
	name = "dyeable skirt"
	desc = "Юбка, которую можно покрасить в любой цвет!"
	icon_state = "colorize_skirt"
	item_state = "colorize_skirt"
	item_color = "colorize_skirt"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/miscellaneous/colour/skirt/get_ru_names()
	return alist(
		NOMINATIVE = "окрашиваемая юбка",
		GENITIVE = "окрашиваемой юбки",
		DATIVE = "окрашиваемой юбке",
		ACCUSATIVE = "окрашиваемую юбку",
		INSTRUMENTAL = "окрашиваемой юбкой",
		PREPOSITIONAL = "окрашиваемой юбке",
	)

/obj/item/clothing/under/miscellaneous/colour/skirt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)

/obj/item/clothing/under/miscellaneous/satan
	name = "satanic clothes"
	desc = "Костюм, который обычно носят сатанисты."
	over_shoes = TRUE
	icon_state = "satan"
	item_state = "satan"
	item_color = "satan"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/miscellaneous/satan/get_ru_names()
	return alist(
		NOMINATIVE = "сатанинские одеяния",
		GENITIVE = "сатанинских одеяний",
		DATIVE = "сатанинским одеяниям",
		ACCUSATIVE = "сатанинские одеяния",
		INSTRUMENTAL = "сатанинскими одеяниями",
		PREPOSITIONAL = "сатанинских одеяниях",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/masterli
	name = "Master Li clothes"
	desc = "Одеяние великого воина — жаль, что это всего лишь копия. Оригинал хранится в одном из дворцов династии Чанг."
	can_adjust = FALSE
	icon_state = "masterli"
	item_state = "masterli"
	species_restricted = list(SPECIES_HUMAN, SPECIES_MACHINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_TAJARAN, SPECIES_NUCLEATION)

/obj/item/clothing/under/miscellaneous/martialsuit/masterli/get_ru_names()
	return alist(
		NOMINATIVE = "костюм Мастера Ли",
		GENITIVE = "костюма Мастера Ли",
		DATIVE = "костюму Мастера Ли",
		ACCUSATIVE = "костюм Мастера Ли",
		INSTRUMENTAL = "костюмом Мастера Ли",
		PREPOSITIONAL = "костюме Мастера Ли",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/masterdragon
	name = "Gold dragon master clothes"
	desc = "Надевая этот костюм, вы чувствуете прилив социальных кредитов, вкус риса и родство с таярой."
	over_shoes = TRUE
	can_adjust = FALSE
	icon_state = "masterdragon"
	item_state = "masterdragon"
	species_restricted = list(SPECIES_HUMAN, SPECIES_MACHINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_TAJARAN, SPECIES_NUCLEATION)

/obj/item/clothing/under/miscellaneous/martialsuit/masterdragon/get_ru_names()
	return alist(
		NOMINATIVE = "костюм мастера Золотого дракона",
		GENITIVE = "костюма мастера Золотого дракона",
		DATIVE = "костюму мастера Золотого дракона",
		ACCUSATIVE = "костюм мастера Золотого дракона",
		INSTRUMENTAL = "костюмом мастера Золотого дракона",
		PREPOSITIONAL = "костюме мастера Золотого дракона",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/redkunoichi
	name = "Red Kunoichi clothes"
	desc = "Раньше этот костюм был синим, но теперь он приобрёл злодейский вид. Курьер прошёл долгий и кровавый путь, чтобы доставить его."
	over_shoes = TRUE
	can_adjust = FALSE
	icon_state = "redkunoichi"
	item_state = "redkunoichi"
	species_restricted = list(SPECIES_HUMAN, SPECIES_MACHINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_TAJARAN, SPECIES_NUCLEATION)

/obj/item/clothing/under/miscellaneous/martialsuit/redkunoichi/get_ru_names()
	return alist(
		NOMINATIVE = "красный костюм Куноичи",
		GENITIVE = "красного костюма Куноичи",
		DATIVE = "красному костюму Куноичи",
		ACCUSATIVE = "красный костюм Куноичи",
		INSTRUMENTAL = "красным костюмом Куноичи",
		PREPOSITIONAL = "красном костюме Куноичи",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/bluekunoichi
	name = "Blue Kunoichi clothes"
	desc = "Костюм сделан из высококачественных нитей для лучшего контроля чакры! На бирке указано: \"Made in Chang\""
	over_shoes = TRUE
	can_adjust = FALSE
	icon_state = "bluekunoichi"
	item_state = "bluekunoichi"
	species_restricted = list(SPECIES_HUMAN, SPECIES_MACHINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_TAJARAN, SPECIES_NUCLEATION)

/obj/item/clothing/under/miscellaneous/martialsuit/bluekunoichi/get_ru_names()
	return alist(
		NOMINATIVE = "голубой костюм Куноичи",
		GENITIVE = "голубого костюма Куноичи",
		DATIVE = "голубому костюму Куноичи",
		ACCUSATIVE = "голубой костюм Куноичи",
		INSTRUMENTAL = "голубым костюмом Куноичи",
		PREPOSITIONAL = "голубом костюме Куноичи",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/random
	name = "Random martial arts suit"
	icon_state = "masterli"

/obj/item/clothing/under/miscellaneous/martialsuit/random/get_ru_names()
	return alist(
		NOMINATIVE = "случайный костюм боевых искусств",
		GENITIVE = "случайного костюма боевых искусств",
		DATIVE = "случайному костюму боевых искусств",
		ACCUSATIVE = "случайный костюм боевых искусств",
		INSTRUMENTAL = "случайным костюмом боевых искусств",
		PREPOSITIONAL = "случайном костюме боевых искусств",
	)

/obj/item/clothing/under/miscellaneous/martialsuit/random/Initialize(mapload)
	. = ..()
	var/suit = pick(subtypesof(/obj/item/clothing/under/miscellaneous/martialsuit))
	new suit(loc)
	qdel(src)

/obj/item/clothing/under/miscellaneous/chad
	name = "Chad suit"
	desc = "Должно быть абсолютно очевидным — перед вами настоящая легенда."
	over_shoes = TRUE
	can_adjust = FALSE
	icon_state = "chadsuit"
	item_state = "chadsuit"
	species_restricted = list(SPECIES_HUMAN)

/obj/item/clothing/under/miscellaneous/chad/get_ru_names()
	return alist(
		NOMINATIVE = "костюм Гигачада",
		GENITIVE = "костюма Гигачада",
		DATIVE = "костюму Гигачада",
		ACCUSATIVE = "костюм Гигачада",
		INSTRUMENTAL = "костюмом Гигачада",
		PREPOSITIONAL = "костюме Гигачада",
	)

/obj/item/clothing/under/miscellaneous/bandit
	name = "bandit suit"
	desc = "Грубая полосатая ткань и потёртые брюки. Наряд человека, который не боится показать своё прошлое."
	icon_state = "bandit"
	item_state = "bandit"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/bandit/get_ru_names()
	return alist(
		NOMINATIVE = "бандитский костюм",
		GENITIVE = "бандитского костюма",
		DATIVE = "бандитскому костюму",
		ACCUSATIVE = "бандитский костюм",
		INSTRUMENTAL = "бандитским костюмом",
		PREPOSITIONAL = "бандитском костюме",
	)

/obj/item/clothing/under/miscellaneous/goon
	name = "goon suit"
	desc = "Минималистичный тёмный наряд. Одежда для тех, кто предпочитает решать вопросы кулаками, а не словами."
	icon_state = "goon"
	item_state = "goon"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/goon/get_ru_names()
	return alist(
		NOMINATIVE = "костюм громилы",
		GENITIVE = "костюма громилы",
		DATIVE = "костюму громилы",
		ACCUSATIVE = "костюм громилы",
		INSTRUMENTAL = "костюмом громилы",
		PREPOSITIONAL = "костюме громилы",
	)

/obj/item/clothing/under/miscellaneous/gopnik
	name = "gopnik suit"
	desc = "Легкая куртка с объёмным меховым воротником. Одежда, которая одновременно согревает и запугивает."
	icon_state = "gopnik"
	item_state = "gopnik"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/gopnik/get_ru_names()
	return alist(
		NOMINATIVE = "костюм гопника",
		GENITIVE = "костюма гопника",
		DATIVE = "костюму гопника",
		ACCUSATIVE = "костюм гопника",
		INSTRUMENTAL = "костюмом гопника",
		PREPOSITIONAL = "костюме гопника",
	)

/obj/item/clothing/under/miscellaneous/chainsmoker
	name = "chainsmoker suit"
	desc = "Простая выцветшая футболка и штаны. Наряд человека, которому плевать на мнение окружающих — главное, чтобы было комфортно."
	icon_state = "chainsmoker"
	item_state = "chainsmoker"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/chainsmoker/get_ru_names()
	return alist(
		NOMINATIVE = "костюм курильщика",
		GENITIVE = "костюма курильщика",
		DATIVE = "костюму курильщика",
		ACCUSATIVE = "костюм курильщика",
		INSTRUMENTAL = "костюмом курильщика",
		PREPOSITIONAL = "костюме курильщика",
	)

/obj/item/clothing/under/miscellaneous/maleclub
	name = "male club suit"
	desc = "Потёртый синий клубный костюм с жёлтой рубашкой и тёмным галстуком. Пахнет джазом, сигаретным дымом и плохими решениями."
	icon_state = "male_club_outfit"
	item_state = "male_club_outfit"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/maleclub/get_ru_names()
	return alist(
		NOMINATIVE = "мужской клубный костюм",
		GENITIVE = "мужского клубного костюма",
		DATIVE = "мужскому клубному костюму",
		ACCUSATIVE = "мужской клубный костюм",
		INSTRUMENTAL = "мужским клубным костюмом",
		PREPOSITIONAL = "мужском клубном костюме",
	)

/obj/item/clothing/under/miscellaneous/girlclub
	name = "girl club suit"
	desc = "Жёлтый топ и короткие шорты."
	icon_state = "girl_club_outfit"
	item_state = "girl_club_outfit"
	species_restricted = list("exclude", SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_VOX_ARMALIS, "lesser form")

/obj/item/clothing/under/miscellaneous/girlclub/get_ru_names()
	return alist(
		NOMINATIVE = "женский клубный костюм",
		GENITIVE = "женского клубного костюма",
		DATIVE = "женскому клубному костюму",
		ACCUSATIVE = "женский клубный костюм",
		INSTRUMENTAL = "женским клубным костюмом",
		PREPOSITIONAL = "женском клубном костюме",
	)

/*
 Only human clothes
*/
/obj/item/clothing/under/miscellaneous/tchaikowsky
	species_restricted = list(SPECIES_HUMAN)

/obj/item/clothing/under/miscellaneous/tchaikowsky/baseball
	name = "baseball uniform (blue)"
	desc = "Бейсбольная униформа синего цвета. Мерч бейсбольной команды \"Нанотрейзен Лейкерс\"."
	icon_state = "baseball_uniform_blue"
	item_state = "baseball_uniform_blue"

/obj/item/clothing/under/miscellaneous/tchaikowsky/baseball/get_ru_names()
	return alist(
		NOMINATIVE = "синяя бейсбольная униформа",
		GENITIVE = "синей бейсбольной униформы",
		DATIVE = "синей бейсбольной униформе",
		ACCUSATIVE = "синюю бейсбольную униформу",
		INSTRUMENTAL = "синей бейсбольной униформой",
		PREPOSITIONAL = "синей бейсбольной униформе",
	)

/obj/item/clothing/under/miscellaneous/tchaikowsky/baseball/brown
	name = "baseball uniform (brown)"
	desc = "Бейсбольная униформа коричневого цвета. Мерч бейсбольной команды \"Киберсан Индастриз\"."
	icon_state = "baseball_uniform_brown"
	item_state = "baseball_uniform_brown"

/obj/item/clothing/under/miscellaneous/tchaikowsky/baseball/brown/get_ru_names()
	return alist(
		NOMINATIVE = "коричневая бейсбольная униформа",
		GENITIVE = "коричневой бейсбольной униформы",
		DATIVE = "коричневой бейсбольной униформе",
		ACCUSATIVE = "коричневую бейсбольную униформу",
		INSTRUMENTAL = "коричневой бейсбольной униформой",
		PREPOSITIONAL = "коричневой бейсбольной униформе",
	)
