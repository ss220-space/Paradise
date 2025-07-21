//Screwdriver
/obj/item/screwdriver
	name = "screwdriver"
	desc = "Инструмент для откручивания и прикручивания различных предметов. Плохо сочетается с глазными яблоками."
	ru_names = list(
	    NOMINATIVE = "отвёртка",
		GENITIVE = "отвёртки",
		DATIVE = "отвёртку",
		ACCUSATIVE = "отвёртка",
		INSTRUMENTAL = "отвёрткой",
		PREPOSITIONAL = "отвёртке"
	)
	gender = FEMALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "screwdriver"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound =  'sound/items/handling/screwdriver_pickup.ogg'
	materials = list(MAT_METAL=75)
	attack_verb = list("уколол", "тыкнул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = 'sound/items/screwdriver.ogg'
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_SCREWDRIVER
	var/random_color = TRUE //if the screwdriver uses random coloring

/obj/item/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator/robo)

/obj/item/screwdriver/nuke
	name = "screwdriver"
	desc = "Отвёртка с ультратонким наконечником."
	ru_names = list(
	    NOMINATIVE = "отвёртка",
		GENITIVE = "отвёртки",
		DATIVE = "отвёртку",
		ACCUSATIVE = "отвёртка",
		INSTRUMENTAL = "отвёрткой",
		PREPOSITIONAL = "отвёртке"
	)
	gender = FEMALE
	icon_state = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE

/obj/item/screwdriver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] кол[pluralize_ru(user.gender,"ит","ют")] [declent_ru(INSTRUMENTAL)] себе в висок! Похоже на то, что [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся совершить самоубийство!"))
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


/obj/item/screwdriver/brass
	name = "brass screwdriver"
	desc = "Отвертка из латуни. Ручка кажется ледяной."
	ru_names = list(
	    NOMINATIVE = "латунная отвёртка",
		GENITIVE = "латунной отвёртки",
		DATIVE = "латунную отвёртку",
		ACCUSATIVE = "латунная отвёртка",
		INSTRUMENTAL = "латунной отвёрткой",
		PREPOSITIONAL = "латунной отвёртке"
	)
	gender = FEMALE
	icon_state = "screwdriver_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "Ультразвуковая отвёртка."
	ru_names = list(
	    NOMINATIVE = "инопланетная отвёртка",
		GENITIVE = "инопланетной отвёртки",
		DATIVE = "инопланетную отвёртку",
		ACCUSATIVE = "инопланетная отвёртка",
		INSTRUMENTAL = "инопланетной отвёрткой",
		PREPOSITIONAL = "инопланетной отвёртке"
	)
	gender = FEMALE
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	belt_icon = "alien_screwdriver"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "Простая ручная дрель с крестовой битой."
	ru_names = list(
	    NOMINATIVE = "ручная дрель",
		GENITIVE = "ручной дрели",
		DATIVE = "ручной дрели",
		ACCUSATIVE = "ручную дрель",
		INSTRUMENTAL = "ручной дрелью",
		PREPOSITIONAL = "ручной дрели"
	)
	gender = FEMALE
	icon_state = "drill_screw"
	item_state = "drill"
	belt_icon = "hand_drill"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("продырявил", "уколол", "огрел")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.25
	random_color = FALSE

/obj/item/screwdriver/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/screwdriver/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] кол[pluralize_ru(user.gender,"ит","ют")] [declent_ru(INSTRUMENTAL)] себе в висок! Похоже на то, что [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся совершить самоубийство!"))
	return BRUTELOSS

/obj/item/screwdriver/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/wrench/power/b_drill = new /obj/item/wrench/power
	balloon_alert(user, "Вы присоединяете головку болтового сверла к [declent_ru(GENITIVE)]."
	qdel(src)
	user.put_in_active_hand(b_drill)

/obj/item/screwdriver/cyborg
	name = "powered screwdriver"
	desc = "Электрическая отвёртка, разработанная для точного и быстрого использования"
	ru_names = list(
	    NOMINATIVE = "электрическая отвёртка",
		GENITIVE = "электрической отвёртки",
		DATIVE = "электрическую отвёртку",
		ACCUSATIVE = "электрическая отвёртка",
		INSTRUMENTAL = "электрической отвёрткой",
		PREPOSITIONAL = "электрической отвёртке"
	)
	gender = FEMALE
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5

	)
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5
