/obj/item/wrench
	name = "wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов."
	gender = MALE
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "wrench"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	usesound = 'sound/items/ratchet.ogg'
	drop_sound = 'sound/items/handling/drop/wrench_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/wrench_pickup.ogg'
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("ударил", "огрел")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_WRENCH
	toolbox_radial_menu_compatibility = TRUE

/obj/item/wrench/get_ru_names()
	return list(
		NOMINATIVE = "гаечный ключ",
		GENITIVE = "гаечного ключа",
		DATIVE = "гаечному ключу",
		ACCUSATIVE = "гаечный ключ",
		INSTRUMENTAL = "гаечным ключом",
		PREPOSITIONAL = "гаечном ключе"
	)

/obj/item/wrench/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] избива[PLUR_ET_YUT(user)] себя до смерти [declent_ru(INSTRUMENTAL)]! Это похоже на попытку самоубийства!"))
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов. \
			На ощупь слегка тёплый."
	icon_state = "wrench_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wrench/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунный гаечный ключ",
		GENITIVE = "латунного гаечного ключа",
		DATIVE = "латунному гаечному ключу",
		ACCUSATIVE = "латунный гаечный ключ",
		INSTRUMENTAL = "латунным гаечным ключом",
		PREPOSITIONAL = "латунном гаечном ключе"
	)

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов. \
			Заставляет проворачиваться зажатые между губками предметы."
	icon = 'icons/obj/abductor.dmi'
	item_state = "wrench_alien"
	belt_icon = "alien_wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=5;abductor=3"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/wrench/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродный гаечный ключ",
		GENITIVE = "чужеродного гаечного ключа",
		DATIVE = "чужеродному гаечному ключу",
		ACCUSATIVE = "чужеродный гаечный ключ",
		INSTRUMENTAL = "чужеродным гаечным ключом",
		PREPOSITIONAL = "чужеродном гаечном ключе"
	)

/obj/item/wrench/cyborg
	name = "automatic wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов. \
			Специализированная версия для установки в роботизированные системы."
	toolspeed = 0.5

/obj/item/wrench/cyborg/get_ru_names()
	return list(
		NOMINATIVE = "автоматический гаечный ключ",
		GENITIVE = "автоматического гаечного ключа",
		DATIVE = "автоматическому гаечному ключу",
		ACCUSATIVE = "автоматический гаечный ключ",
		INSTRUMENTAL = "автоматическим гаечным ключом",
		PREPOSITIONAL = "автоматическом гаечном ключе"
	)

/obj/item/wrench/power
	name = "hand drill"
	desc = "Электрическая инструмент, используемый для завинчивания объектов с резьбой \
			и закручивания болтов и гаек."
	icon_state = "drill_bolt"
	item_state = "drill"
	belt_icon = "hand_drill"
	usesound = 'sound/items/impactwrench.ogg' // Sourced from freesfx.co.uk
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" // done for balance reasons, making them high value for research, but harder to get
	force = 8 // might or might not be too high, subject to change
	throwforce = 8
	attack_verb = list("продырявил", "уколол")
	toolspeed = 0.25

/obj/item/wrench/power/get_ru_names()
	return list(
		NOMINATIVE = "ручная дрель",
		GENITIVE = "ручной дрели",
		DATIVE = "ручной дрели",
		ACCUSATIVE = "ручную дрель",
		INSTRUMENTAL = "ручной дрелью",
		PREPOSITIONAL = "ручной дрели"
	)

/obj/item/wrench/power/examine(mob/user)
	. = ..()
	. += span_notice("Установлена <b>гаечная</b> бита.")

/obj/item/wrench/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	var/obj/item/screwdriver/power/s_drill = new /obj/item/screwdriver/power
	balloon_alert(user, "установлена винтовая бита")
	qdel(src)
	user.put_in_active_hand(s_drill)

/obj/item/wrench/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] прижима[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] к своей голове! Это похоже на попытку самоубийства!"))
	return BRUTELOSS

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "Инструмент, используемый для закручивания и откручивания гаек и болтов. \
			Что делает его медицинским? Кто знает..."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	origin_tech = "materials=1;engineering=1;biotech=3"

/obj/item/wrench/medical/get_ru_names()
	return list(
		NOMINATIVE = "медицинский гаечный ключ",
		GENITIVE = "медицинского гаечного ключа",
		DATIVE = "медицинскому гаечному ключу",
		ACCUSATIVE = "медицинский гаечный ключ",
		INSTRUMENTAL = "медицинским гаечным ключом",
		PREPOSITIONAL = "медицинском гаечном ключе"
	)

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] мол[PLUR_IT_YAT(user)]ся [declent_ru(DATIVE)], чтобы тот забрал [GEND_HIS_HER(user)] душу. Это похоже на попытку самоубийства!"))

	// Stun stops them from wandering off
	user.Stun(10 SECONDS)
	playsound(loc, 'sound/effects/pray.ogg', 50, TRUE, -1)

	// Let the sound effect finish playing
	sleep(20)

	if(!user)
		return

	for(var/obj/item/wrench in user)
		user.drop_item_ground(wrench)

	var/obj/item/wrench/medical/wrench = new /obj/item/wrench/medical(loc)
	wrench.add_fingerprint(user)
	wrench.desc += " По какой-то причине он напоминает вам [user.declent_ru(ACCUSATIVE)]."

	if(!user)
		return

	user.dust()
	return OBLITERATION
