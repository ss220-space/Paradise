/obj/item/crowbar
	name = "crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов."
	gender = FEMALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "crowbar"
	belt_icon = "pocket_crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 10
	materials = list(MAT_METAL=50)
	drop_sound = 'sound/items/handling/drop/crowbar_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/crowbar_pickup.ogg'
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("атаковал", "ударил", "огрел")
	toolbox_radial_menu_compatibility = TRUE

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/get_ru_names()
	return list(
		NOMINATIVE = "монтировка",
		GENITIVE = "монтировки",
		DATIVE = "монтировке",
		ACCUSATIVE = "монтировку",
		INSTRUMENTAL = "монтировкой",
		PREPOSITIONAL = "монтировке"
	)

/obj/item/crowbar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/crowbar/small
	name = "miniature titanium crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов. \
			Уменьшенная версия из титана."
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 7.5
	materials = list(MAT_TITANIUM = 250)
	icon_state = "crowbar_titanium"
	item_state = "crowbar_titanium"
	origin_tech = "materials=2"
	toolspeed = 3

/obj/item/crowbar/small/get_ru_names()
	return list(
		NOMINATIVE = "титановая мини-монтировка",
		GENITIVE = "титановой мини-монтировки",
		DATIVE = "титановой мини-монтировке",
		ACCUSATIVE = "титановую мини-монтировку",
		INSTRUMENTAL = "титановой мини-монтировкой",
		PREPOSITIONAL = "титановой мини-монтировке"
	)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"

/obj/item/crowbar/red/sec
	icon_state = "crowbar_sec"
	item_state = "crowbar_sec"

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов. \
			Слегка тёплая на ощупь."
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/crowbar/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунная монтировка",
		GENITIVE = "латунной монтировки",
		DATIVE = "латунной монтировке",
		ACCUSATIVE = "латунную монтировку",
		INSTRUMENTAL = "латунной монтировкой",
		PREPOSITIONAL = "латунной монтировке"
	)

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов. \
			Кажется, что она движется сама, без усилий со стороны пользователя."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	item_state = "crowbar_alien"
	belt_icon = "alien_crowbar"
	toolspeed = 0.1
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/crowbar/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродная монтировка",
		GENITIVE = "чужеродной монтировки",
		DATIVE = "чужеродной монтировке",
		ACCUSATIVE = "чужеродную монтировку",
		INSTRUMENTAL = "чужеродной монтировкой",
		PREPOSITIONAL = "чужеродной монтировке"
	)

/obj/item/crowbar/large
	name = "large crowbar"
	desc = "Инструмент, предназначенный для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов. \
			Увеличенная версия, создающая большее давление."
	force = 15
	throwforce = 18
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/large/get_ru_names()
	return list(
		NOMINATIVE = "большая монтировка",
		GENITIVE = "большой монтировки",
		DATIVE = "большой монтировке",
		ACCUSATIVE = "большую монтировку",
		INSTRUMENTAL = "большой монтировкой",
		PREPOSITIONAL = "большой монтировке"
	)

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "Гидравлический инструмент, являющийся модифицированной версией монтировки. Предназначен для использования в качестве рычага. \
			Пригоден для широкого спектра задач: от поддевания напольных плит до вскрытия обесточенных шлюзов. \
			Специализированная версия для установки в роботизированные системы."
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.5

/obj/item/crowbar/cyborg/get_ru_names()
	return list(
		NOMINATIVE = "гидравлическая монтировка",
		GENITIVE = "гидравлической монтировки",
		DATIVE = "гидравлической монтировке",
		ACCUSATIVE = "гидравлическую монтировку",
		INSTRUMENTAL = "гидравлической монтировкой",
		PREPOSITIONAL = "гидравлической монтировке"
	)

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "Гидравлический инструмент, предназначенный для использования в качестве рычага или для перерезания материалов. \
			Изначально использовался для спасательных работ, откуда и получил своё название, \
			но в дальнейшем получил развитие в качестве инженерного инструмента."
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	belt_icon = "jaws_of_life"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.25
	/// Time required to open powered airlocks
	var/airlock_open_time = 100

/obj/item/crowbar/power/get_ru_names()
	return list(
		NOMINATIVE = "челюсти жизни",
		GENITIVE = "челюстей жизни",
		DATIVE = "челюстям жизни",
		ACCUSATIVE = "челюсти жизни",
		INSTRUMENTAL = "челюстями жизни",
		PREPOSITIONAL = "челюстях жизни",
	)

/obj/item/crowbar/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>поддевающая</b> насадка.")

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, TRUE)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power
	balloon_alert(user, "установлена перерезающая насадка")
	qdel(src)
	user.put_in_active_hand(cutjaws)

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] помеща[PLUR_ET_YUT(user)] свою голову между лезвиями [declent_ru(GENITIVE)]. Это похоже на попытку самоубийства!"))
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, TRUE, -1)
	return BRUTELOSS
