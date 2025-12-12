/obj/item/screwdriver
	name = "screwdriver"
	desc = "Инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "screwdriver"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	drop_sound = 'sound/items/handling/drop/screwdriver_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/screwdriver_pickup.ogg'
	materials = list(MAT_METAL=75)
	attack_verb = list("уколол", "тыкнул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/screwdriver.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_SCREWDRIVER
	toolbox_radial_menu_compatibility = TRUE
	/// If the screwdriver uses random coloring
	var/random_color = TRUE

/obj/item/screwdriver/get_ru_names()
	return list(
		NOMINATIVE = "отвёртка",
		GENITIVE = "отвёртки",
		DATIVE = "отвёртке",
		ACCUSATIVE = "отвёртку",
		INSTRUMENTAL = "отвёрткой",
		PREPOSITIONAL = "отвёртке"
	)

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] вонза[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] себе в [pick("висок", "сердце")]! Это похоже на попытку самоубийства!"))
	return BRUTELOSS

/obj/item/screwdriver/Initialize(mapload, param_color = null)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("red","blue","pink","brown","green","cyan","yellow")
		icon_state = "screwdriver_[param_color]"

	if(prob(75))
		pixel_y = rand(0, 16)

	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/screwdriver/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent == INTENT_HELP)
		return ..()
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		target = user
	return eyestab(target, user)

/obj/item/screwdriver/nuke
	desc = "Инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой. \
			Оснащена ультратонким наконечником."
	icon_state = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE

/obj/item/screwdriver/nuke/get_ru_names()
	return list(
		NOMINATIVE = "ультратонкая отвёртка",
		GENITIVE = "ультратонкой отвёртки",
		DATIVE = "ультратонкой отвёртке",
		ACCUSATIVE = "ультратонкую отвёртку",
		INSTRUMENTAL = "ультратонкой отвёрткой",
		PREPOSITIONAL = "ультратонкой отвёртке"
	)

/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "Инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой. \
			Ручка на ощупь ледяная."
	icon_state = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/screwdriver/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунная отвёртка",
		GENITIVE = "латунной отвёртки",
		DATIVE = "латунной отвёртке",
		ACCUSATIVE = "латунную отвёртку",
		INSTRUMENTAL = "латунной отвёрткой",
		PREPOSITIONAL = "латунной отвёртке"
	)

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "Инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой. \
			Кажется, будто бы её наконечник крутится сам по себе."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	belt_icon = "alien_screwdriver"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE
	w_class = WEIGHT_CLASS_TINY

/obj/item/screwdriver/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродная отвёртка",
		GENITIVE = "чужеродной отвёртки",
		DATIVE = "чужеродной отвёртке",
		ACCUSATIVE = "чужеродную отвёртку",
		INSTRUMENTAL = "чужеродной отвёрткой",
		PREPOSITIONAL = "чужеродной отвёртке"
	)

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "Гидравлический инструмент, предназначенный для завинчивания и отвинчивания изделий с резьбой. \
			Специализированная версия для установки в роботизированные системы."
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5

/obj/item/screwdriver/cyborg/get_ru_names()
	return list(
		NOMINATIVE = "электрическая отвёртка",
		GENITIVE = "электрической отвёртки",
		DATIVE = "электрической отвёртке",
		ACCUSATIVE = "электрическую отвёртку",
		INSTRUMENTAL = "электрической отвёрткой",
		PREPOSITIONAL = "электрической отвёртке"
	)

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "Электрическая инструмент, используемый для завинчивания объектов с резьбой \
			и закручивания болтов и гаек."
	icon_state = "drill_screw"
	item_state = "drill"
	belt_icon = "hand_drill"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" // done for balance reasons, making them high value for research, but harder to get
	force = 8
	throwforce = 8
	throw_speed = 2
	throw_range = 3// it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("продырявил", "уколол", "огрел")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.25
	random_color = FALSE
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/screwdriver/power/get_ru_names()
	return list(
		NOMINATIVE = "ручная дрель",
		GENITIVE = "ручной дрели",
		DATIVE = "ручной дрели",
		ACCUSATIVE = "ручную дрель",
		INSTRUMENTAL = "ручной дрелью",
		PREPOSITIONAL = "ручной дрели"
	)

/obj/item/crowbar/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>винтовая</b> бита.")

/obj/item/screwdriver/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power
	balloon_alert(user, "установлена гаечная бита")
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/screwdriver/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] приставля[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] к своему виску. Это похоже на попытку самоубийства!"))
	return BRUTELOSS
