/* Weapon toys
 *	Contains:
 *		Toy swords
 *		Foam Armblade
 *		Toy/fake flash
 *		Rubber Chainsaw
 *		Rubber Toolbox
 *		Russian roulette
 */

// MARK: Toy swords
/obj/item/toy/sword
	name = "toy sword"
	desc = "Дешевая пластиковая копия энергетического меча. Реалистичные звуки! Для детей от 8 лет и старше."
	icon = 'icons/obj/items.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = FALSE
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "ударил")
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/obj/item/toy/sword/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечный меч",
		GENITIVE = "игрушечного меча",
		DATIVE = "игрушечному мечу",
		ACCUSATIVE = "игрушечного меча",
		INSTRUMENTAL = "игрушечным мечом",
		PREPOSITIONAL = "игрушечном мече",
	)

/obj/item/toy/sword/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/toy/sword/proc/update_sword_state()
	if(active)
		icon_state = "swordblue"
		item_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		icon_state = "sword0"
		item_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL

	update_icon()

/obj/item/toy/sword/attack_self(mob/user)
	active = !active

	if(active)
		to_chat(user, span_notice("Вы выдвигаете пластиковое лезвие лёгким движением руки."))
		playsound(user, 'sound/weapons/saberon.ogg', 20, TRUE)
	else
		to_chat(user, span_notice("Вы задвигаете пластиковое лезвие обратно в рукоять."))
		playsound(user, 'sound/weapons/saberoff.ogg', 20, TRUE)

	update_sword_state()
	add_fingerprint(user)

/obj/item/toy/sword/attackby(obj/item/item, mob/living/user, params)
	if(!istype(item, /obj/item/toy/sword))
		return ..()

	add_fingerprint(user)

	if(item == src)
		to_chat(user, span_warning("Вы пытаетесь прикрепить конец пластикового меча... к самому себе. Вы не очень умный, да?"))
		user.apply_damage(10, BRAIN)
		return ATTACK_CHAIN_PROCEED

	if(loc == user && !user.can_unEquip(src))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(item, src))
		return ATTACK_CHAIN_PROCEED

	to_chat(user, span_notice("Вы соединяете два пластиковых меча, создавая двулезвийную игрушку! Выглядит по-дурацки круто!"))
	var/obj/item/twohanded/dualsaber/toy/toy_saber = new(drop_location())
	user.temporarily_remove_item_from_inventory(src)
	user.put_in_hands(toy_saber, ignore_anim = FALSE)
	qdel(item)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL

// MARK: Subtype of Double-Bladed Energy Swords
/obj/item/twohanded/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "Дешевая пластиковая копия ДВУХ энергетических мечей. Вдвойне веселее!"
	force = 0
	throwforce = 0
	throw_speed = 3
	force_unwielded = 0
	force_wielded = 0
	origin_tech = null
	attack_verb = list("атаковал", "ударил")
	light_range = 0
	sharp_when_wielded = FALSE // It's a toy
	needs_permit = FALSE

/obj/item/twohanded/dualsaber/toy/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечный двойной меч",
		GENITIVE = "игрушечного двойного меча",
		DATIVE = "игрушечному двойному мечу",
		ACCUSATIVE = "игрушечный двойной меч",
		INSTRUMENTAL = "игрушечным двойным мечом",
		PREPOSITIONAL = "игрушечном двойном мече",
	)

/obj/item/twohanded/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	return HIT_RESULT_FAILED

/obj/item/toy/katana
	name = "replica katana"
	desc = "Неоправданно слабая в настольных играх."
	icon = 'icons/obj/items.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	attack_verb = list("атаковал", "полоснул", "уколол")
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/obj/item/toy/katana/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечная катана",
		GENITIVE = "игрушечной катаны",
		DATIVE = "игрушечной катане",
		ACCUSATIVE = "игрушечную катану",
		INSTRUMENTAL = "игрушечной катаной",
		PREPOSITIONAL = "игрушечной катане",
	)

/obj/item/toy/katana/suicide_act(mob/user)
	var/dmsg = pick("[user] пыта[PLUR_ET_YUT(user)]ся воткнуть [declent_ru(ACCUSATIVE)] себе в живот, но он ломается! Выглядит так, будто [GEND_HE_SHE(user)] умр[PLUR_YOT_UT(user)] от стыда.",
					"[user] пыта[PLUR_ET_YUT(user)]ся воткнуть [declent_ru(ACCUSATIVE)] себе в живот, но он гнётся и ломается пополам! Выглядит так, будто [GEND_HE_SHE(user)] умр[PLUR_YOT_UT(user)] от стыда.",
					"[user] пыта[PLUR_ET_YUT(user)]ся перерезать себе горло, но тупое пластиковое лезвие приводит к тому, что [GEND_HE_SHE(user)] поскальзыва[PLUR_ET_YUT(user)]ся и лома[PLUR_ET_YUT(user)] шею с громким хрустом!")
	user.visible_message(span_suicide("[dmsg] Похоже, [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся покончить с собой."))
	return BRUTELOSS

// MARK: Foam Armblade
/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "На нём написано: \"Фанат мистера Сигма номер один\"."
	icon_state = "foamblade"
	item_state = "arm_blade"
	attack_verb = list("уколол", "поглотил", "пронзил")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/obj/item/toy/foamblade/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечный армблейд",
		GENITIVE = "игрушечного армблейда",
		DATIVE = "игрушечному армблейду",
		ACCUSATIVE = "игрушечный армблейд",
		INSTRUMENTAL = "игрушечным армблейдом",
		PREPOSITIONAL = "игрушечном армблейде",
	)

// MARK: Toy/fake flash
/obj/item/toy/flash
	name = "toy flash"
	desc = "ЗА РЕВОЛЮЦИЮ! — Ой, подождите, это же просто игрушка."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/flash/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечный флешер",
		GENITIVE = "игрушечного флешера",
		DATIVE = "игрушечному флешеру",
		ACCUSATIVE = "игрушечный флешер",
		INSTRUMENTAL = "игрушечным флешером",
		PREPOSITIONAL = "игрушечном флешере",
	)

/obj/item/toy/flash/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	playsound(loc, 'sound/weapons/flash.ogg', 100, TRUE)
	flick("[initial(icon_state)]2", src)
	user.visible_message(span_disarm("[user] ослепля[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] вспышкой флешера!"))
	return ATTACK_CHAIN_PROCEED_SUCCESS

// MARK: Rubber Chainsaw
/obj/item/twohanded/toy/chainsaw
	name = "Toy Chainsaw"
	desc = "Игрушечная бензопила с резиновым лезвием. Для детей от 8 лет и старше."
	icon_state = "chainsaw0"
	throw_speed = 4
	throw_range = 20
	wieldsound = 'sound/weapons/chainsaw_start.ogg'
	attack_verb = list("пропилил", "порезал", "покромсал", "рубанул")

/obj/item/twohanded/toy/chainsaw/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечная бензопила",
		GENITIVE = "игрушечной бензопилы",
		DATIVE = "игрушечной бензопиле",
		ACCUSATIVE = "игрушечную бензопилу",
		INSTRUMENTAL = "игрушечной бензопилой",
		PREPOSITIONAL = "игрушечной бензопиле",
	)

/obj/item/twohanded/toy/chainsaw/update_icon_state()
	icon_state = "chainsaw[HAS_TRAIT(src, TRAIT_WIELDED)]"

// MARK: Rubber Toolbox
/obj/item/toy/toolbox
	name = "Rubber Toolbox"
	desc = "Практикуйте свой робаст!"
	icon_state = "rubber_toolbox"
	damtype = STAMINA
	force = 10
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("заробастил")
	hitsound = 'sound/items/squeaktoy.ogg'

/obj/item/toy/toolbox/get_ru_names()
	return alist(
		NOMINATIVE = "резиновый тулбокс",
		GENITIVE = "резинового тулбокса",
		DATIVE = "резиновому тулбоксу",
		ACCUSATIVE = "резиновый тулбокс",
		INSTRUMENTAL = "резиновым тулбоксом",
		PREPOSITIONAL = "резиновом тулбоксе",
	)

// MARK: Russian roulette
/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "For fun and games!"
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "detective_gold"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	hitsound = SFX_SWING_HIT
	flags =  CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	throwforce = 5
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	attack_verb = list("ударил")
	var/bullets_left = 0
	var/max_shots = 6

/obj/item/toy/russian_revolver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] быстро заряжает шесть патронов в барабан [declent_ru(GENITIVE)], приставляет к виску и нажимает на курок! Похоже, [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся покончить с собой."))
	playsound(loc, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/russian_revolver/Initialize(mapload)
	. = ..()
	spin_cylinder()

/obj/item/toy/russian_revolver/attack_self(mob/user)
	if(!bullets_left)
		user.visible_message(span_warning("[user] заряжает патрон в барабан [declent_ru(GENITIVE)] и крутит его."))
		spin_cylinder()
	else
		user.visible_message(span_warning("[user] крутит барабан [declent_ru(GENITIVE)]!"))
		spin_cylinder()

/obj/item/toy/russian_revolver/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/toy/russian_revolver/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(proximity_flag)
		if(target in user.contents)
			return
		if(!ismob(target))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	shoot_gun(user)

/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/russian_revolver/proc/post_shot(mob/user)
	return

/obj/item/toy/russian_revolver/proc/shoot_gun(mob/living/carbon/human/user)
	if(bullets_left <= 0)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] нужно перезарядить."))
		return FALSE

	if(bullets_left > 1)
		bullets_left--
		user.visible_message(span_danger("*клик*"))
		playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
		return FALSE

	bullets_left = 0
	var/zone = BODY_ZONE_HEAD
	if(!(user.get_organ(zone))) // If they somehow don't have a head.
		zone = BODY_ZONE_CHEST
	playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
	user.visible_message(span_danger("[src] goes off!"))
	post_shot(user)
	user.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Self-inflicted gunshot wound to the [zone].")
	user.bleed(BLOOD_VOLUME_NORMAL)
	user.death() // Just in case
	return TRUE

/obj/item/toy/russian_revolver/trick_revolver
	name = ".357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	max_shots = 1
	var/fake_bullets = 0

/obj/item/toy/russian_revolver/trick_revolver/Initialize(mapload)
	. = ..()
	fake_bullets = rand(2, 7)

/obj/item/toy/russian_revolver/trick_revolver/examine(mob/user) //Sneaky sneaky
	. = ..()
	. += span_notice("В запасе ещё [fake_bullets] патрон[DECL_CREDIT(fake_bullets)].")
	. += span_notice("[fake_bullets] из них боевые.")

/obj/item/toy/russian_revolver/trick_revolver/post_shot(user)
	to_chat(user, span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] действительно выглядел довольно сомнительно!"))
	SEND_SOUND(user, sound('sound/misc/sadtrombone.ogg')) //HONK
