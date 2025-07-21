/Wrench
/obj/item/wrench
	name = "wrench"
	desc = "Это гаечный ключ, используемый для закручивания и откручивания гаек и болтов. Может быть найден где угодно."
	ru_names = list(
	    NOMINATIVE = "гаечный ключ",
		GENITIVE = "гаечного ключа",
		DATIVE = "гаечному ключу",
		ACCUSATIVE = "гаечный ключ",
		INSTRUMENTAL = "гаечным ключом",
		PREPOSITIONAL = "гаечном ключе"
	)
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
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("ударил", "огрел")
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_WRENCH

/obj/item/wrench/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = force, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] избива[pluralize_ru(user.gender,"ет","ют")] себя до смерти [(INSTRUMENTAL)]! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ется","ются")] совершить самоубийство!"))
	return BRUTELOSS

/obj/item/wrench/cyborg
	name = "automatic wrench"
	desc = "Продвинутый роботизированный гаечный ключ. Можно найти у строительных киборгов."
	ru_names = list(
	    NOMINATIVE = "автоматический ключ",
		GENITIVE = "автоматического ключа",
		DATIVE = "автоматическому ключу",
		ACCUSATIVE = "автоматический ключ",
		INSTRUMENTAL = "автоматическим ключом",
		PREPOSITIONAL = "автоматическом ключе"
	)
	gender = MALE
	toolspeed = 0.5

/obj/item/wrench/brass
	name = "brass wrench"
	desc = "Латунный ключ. Он слегка тёплый на ощупь."
	ru_names = list(
	    NOMINATIVE = "латунный ключ",
		GENITIVE = "латунного ключа",
		DATIVE = "латунному ключу",
		ACCUSATIVE = "латунный ключ",
		INSTRUMENTAL = "латунным ключом",
		PREPOSITIONAL = "латунном ключе"
	)
	gender = MALE
	icon_state = "wrench_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "Поляризованный ключ. Он заставляет все, что находится между губками, поворачиваться."
	ru_names = list(
	    NOMINATIVE = "инопланетный ключ",
		GENITIVE = "инопланетного ключа",
		DATIVE = "инопланетному ключу",
		ACCUSATIVE = "инопланетный ключ",
		INSTRUMENTAL = "инопланетным ключом",
		PREPOSITIONAL = "инопланетном ключе"
	)
	gender = MALE
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	item_state = "wrench_alien"
	belt_icon = "alien_wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=5;abductor=3"

/obj/item/wrench/power
	name = "hand drill"
	desc = "Простая электрическая дрель с болтовой битой."
	ru_names = list(
	    NOMINATIVE = "ручная дрель",
		GENITIVE = "ручной дрели",
		DATIVE = "ручной дрели",
		ACCUSATIVE = "ручную дрель",
		INSTRUMENTAL = "ручной дрелью",
		PREPOSITIONAL = "ручной дрели"
	)
	gender = FEMALE
	icon_state = "drill_bolt"
	item_state = "drill"
	belt_icon = "hand_drill"
	usesound = 'sound/items/impactwrench.ogg' // Sourced from freesfx.co.uk
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	attack_verb = list("продырявил", "уколол")
	toolspeed = 0.25

/obj/item/wrench/power/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg', 50, 1)
	var/obj/item/wirecutters/power/s_drill = new /obj/item/screwdriver/power
	balloon_alert(user, "Вы прикрепляете насадку отвертки к [declent_ru(GENITIVE)].")
	qdel(src)
	user.put_in_active_hand(s_drill)

/obj/item/wrench/power/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] прижима[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)] к голове. Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ется","ются")] использовать [declent_ru(ACCUSATIVE)] для самоубийства!"))
	return BRUTELOSS

/obj/item/wrench/medical
	name = "medical wrench"
	desc = "Медицинский гаечный ключ, имеющий обычное (медицинское?) применение. Может быть найден у вас в руке."
	ru_names = list(
	    NOMINATIVE = "медицинский ключ",
		GENITIVE = "медицинского ключа",
		DATIVE = "медицинскому ключу",
		ACCUSATIVE = "медициеский ключ",
		INSTRUMENTAL = "медицинским ключом",
		PREPOSITIONAL = "медицинском ключе"
	)
	gender = MALE
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	origin_tech = "materials=1;engineering=1;biotech=3"

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] молится [declent_ru(DATIVE)], чтобы он взял [pluralize_ru(user.gender,"его","её")] душу. Похоже, [genderize_ru(user.gender,"он","она","оно","они")] пыта[pluralize_ru(user.gender,"ется","ются")] использовать [declent_ru(ACCUSATIVE)] для самоубийства!"))
	// TODO Make them glow with the power of the M E D I C A L W R E N C H
	// during their ascension

	// Stun stops them from wandering off
	user.Stun(10 SECONDS)
	playsound(loc, 'sound/effects/pray.ogg', 50, 1, -1)

	// Let the sound effect finish playing
	sleep(20)

	if(!user)
		return

	for(var/obj/item/W in user)
		user.drop_item_ground(W)

	var/obj/item/wrench/medical/W = new /obj/item/wrench/medical(loc)
	W.add_fingerprint(user)
	W.desc += " For some reason, it reminds you of [user.name]."

	if(!user)
		return

	user.dust()
	return OBLITERATION


	user.dust()
	return OBLITERATION
