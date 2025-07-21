/obj/item/crowbar
	name = "pocket crowbar"
	desc = "Небольшой металлический ломик. Предназначен для использования в качестве рычага."
	ru_names = list(
	    NOMINATIVE = "карманный лом",
		GENITIVE = "карманного лома",
		DATIVE = "карманному лому",
		ACCUSATIVE = "карманный лом",
		INSTRUMENTAL = "карманным ломом",
		PREPOSITIONAL = "карманном ломе"
    )
    gender = MALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	item_state = "crowbar"
	belt_icon = "pocket_crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("атаковал", "ударил", "огрел")
	toolspeed = 1

	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"

/obj/item/crowbar/red/sec
	icon_state = "crowbar_sec"
	item_state = "crowbar_sec"

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "Латунный лом. Предназначен для использования в качестве рычага. Слегка тёплый на ощупь."
	ru_names = list(
	    NOMINATIVE = "латунный лом",
		GENITIVE = "латунного лома",
		DATIVE = "латунному лому",
		ACCUSATIVE = "латунный лом",
		INSTRUMENTAL = "латунным ломом",
		PREPOSITIONAL = "латунном ломе"
	)
	gender = MALE
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "Инопланетный лом. Предназначен для использования в качестве рычага. Кажется, что он поднимается сам по себе, без каких-либо усилий."
	ru_names = list(
	    NOMINATIVE = "инопланетный лом",
		GENITIVE = "инопланетного лома",
		DATIVE = "инопланетному лому",
		ACCUSATIVE = "инопланетный лом",
		INSTRUMENTAL = "инопланетным ломом",
		PREPOSITIONAL = "инопланетном ломе"
    )
	gender = MALE
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	item_state = "crowbar_alien"
	belt_icon = "alien_crowbar"
	toolspeed = 0.1
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/crowbar/large
	name = "crowbar"
	desc = "Это большой лом. Предназначен для использования в качестве рычага. Такой в карман не положить."
	ru_names = list(
	    NOMINATIVE = "большой лом",
		GENITIVE = "большого лома",
		DATIVE = "большому лому",
		ACCUSATIVE = "большой лом",
		INSTRUMENTAL = "большим ломом",
		PREPOSITIONAL = "большом ломе"
	)
	gender = MALE
	force = 20
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "Гидравлический подъемник, компактный, но мощный. Предназначен для использования в качестве рычага. Аналог лома для строительных киборгов."
	ru_names = list(
	    NOMINATIVE = "гидравлический лом",
		GENITIVE = "гидравлического лома",
		DATIVE = "гидравлическому лому",
		ACCUSATIVE = "гидравлический лом",
		INSTRUMENTAL = "гидравлическим ломом",
		PREPOSITIONAL = "гидравлическом ломе"
	)
	gender = MALE
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.5

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "Набор челюстей жизни, магия науки сумела втиснуть его в устройство, достаточно маленькое, чтобы поместиться на поясе для инструментов. Он оснащён выдвигающейся головкой."
	ru_names = list(
	    NOMINATIVE = "челюсти жизни",
		GENITIVE = "челюстей жизни",
		DATIVE = "челюстям жизни",
		ACCUSATIVE = "челюсти жизни",
		INSTRUMENTAL = "челюстями жизни",
		PREPOSITIONAL = "челюстях жизни"
	)
	gender = PLURAL
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	belt_icon = "jaws_of_life"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	toolspeed = 0.25
	var/airlock_open_time = 100 // Time required to open powered airlocks

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] помеща[pluralize_ru(user.gender, "ет", "ют")] свою голову между лезвиями [declent_ru(GENITIVE)]. Похоже, [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender,"ет", "ют")]ся использовать [declent_ru(ACCUSATIVE)] для самоубийства!"))
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power
	balloon_alert("Вы присоединяете режущую головку к [declent_ru(GENITIVE)].")
	qdel(src)
	user.put_in_active_hand(cutjaws)

	qdel(src)
	user.put_in_active_hand(cutjaws)
