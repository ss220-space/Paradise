//Parent to shields and blades because muh copypasted code.
/datum/action/changeling/weapon
	abstract_type = /datum/action/changeling/weapon
	name = "Organic Weapon"
	desc = "Напишите баг-репорт, если вы увидели это"
	helptext = "Это точно был Зюзя!"
	req_human = TRUE
	var/silent = FALSE
	var/weapon_type
	var/weapon_check_type
	var/weapon_name_simple
	var/recharge_slowdown = 0

/datum/action/changeling/weapon/try_to_sting(mob/user, mob/target)
	if(istype(user.get_active_hand(), weapon_check_type) || istype(user.get_inactive_hand(), weapon_check_type))
		retract(user, any_hand = TRUE)
		return
	..(user, target)

/datum/action/changeling/weapon/sting_action(mob/user)
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	if(!user.can_unEquip(user.get_active_hand(), silent = TRUE))
		user.balloon_alert(user, "[weapon_name_simple] не трансформировать")
		return FALSE

	var/obj/item/weapon = new weapon_type(user, silent, src)
	user.put_in_hands(weapon)
	cling.chem_recharge_slowdown += recharge_slowdown

	user.visible_message(
		span_warning("[user] с ужасным хрустом превращает руку в [weapon_name_simple]!"),
		span_notice("Мы трансформируем руку в [weapon_name_simple]."),
		span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
	)

	RegisterSignal(user, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(retract), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), override = TRUE)
	playsound(owner.loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

	return weapon

/datum/action/changeling/weapon/proc/retract(mob/user, any_hand = FALSE)
	SIGNAL_HANDLER

	if(!ischangeling(user))
		return

	if(!any_hand && !istype(user.get_active_hand(), weapon_check_type))
		return

	var/done = FALSE
	if(istype(user.get_active_hand(), weapon_check_type))
		qdel(user.get_active_hand())
		done = TRUE

	if(istype(user.get_inactive_hand(), weapon_check_type))
		qdel(user.get_inactive_hand())
		done = TRUE

	if(done)
		. = COMPONENT_CANCEL_DROP
		cling.chem_recharge_slowdown -= recharge_slowdown
		if(!silent)
			playsound(owner.loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
			user.visible_message(
				span_warning("[user] с ужасным хрустом превращает [weapon_name_simple] в обычную руку!"),
				span_notice("Мы трансформируем [weapon_name_simple] в руку."),
				span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
			)

//Parent to space suits and armor.
/datum/action/changeling/suit
	name = "Organic Suit"
	desc = "Напишите баг-репорт, если вы увидели это"
	helptext = "Это точно был Зюзя!"
	req_human = TRUE
	var/helmet_type = /obj/item
	var/suit_type = /obj/item
	var/suit_name_simple = "    "
	var/helmet_name_simple = "     "
	var/recharge_slowdown = 0

/datum/action/changeling/suit/try_to_sting(mob/living/carbon/human/user, mob/target)
	if(!istype(user))
		return FALSE

	if(istype(user.wear_suit, suit_type) || istype(user.head, helmet_type))
		user.visible_message(
			span_warning("[user] трансформирует [suit_name_simple] в кожу!"),
			span_warning("Мы трансформируем [suit_name_simple]."),
			span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
		)
		playsound(owner.loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
		qdel(user.wear_suit)
		qdel(user.head)
		user.update_worn_oversuit()
		user.update_worn_head()
		user.update_hair()
		user.update_fhair()

		cling.chem_recharge_slowdown -= recharge_slowdown
		return FALSE
	..(user, target)

/datum/action/changeling/suit/sting_action(mob/living/carbon/human/user)
	if(!user.can_unEquip(user.wear_suit))
		user.balloon_alert(user, "[suit_name_simple] не трансформировать")
		return FALSE

	if(!user.can_unEquip(user.head))
		user.balloon_alert(user, "[helmet_name_simple] не трансформировать")
		return FALSE

	user.drop_item_ground(user.head)
	user.drop_item_ground(user.wear_suit)

	user.equip_to_slot_or_del(new suit_type(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new helmet_type(user), ITEM_SLOT_HEAD)

	cling.chem_recharge_slowdown += recharge_slowdown
	return TRUE

/***************************************\
|***************ARM BLADE***************|
\***************************************/

/datum/action/changeling/weapon/arm_blade
	name = "Рука-клинок"
	desc = "Мы трансформируем свою руку в опасный клинок."
	helptext = "Вернуть руку можно той же способностью, что и вызван клинок. Снижает производство химикатов на 0,25."
	dna_cost = 2
	recharge_slowdown = 0.25
	button_icon_state = "armblade"
	power_type = CHANGELING_PURCHASABLE_POWER
	weapon_type = /obj/item/melee/changeling/arm_blade
	weapon_check_type = /obj/item/melee/changeling
	weapon_name_simple = "клинок из кости"

/obj/item/melee/changeling/arm_blade
	name = "arm blade"
	desc = "Уродливый клинок из костей и плоти, что режет людей, как масло."
	icon_state = "arm_blade"
	item_state = "arm_blade"
	item_flags = ABSTRACT|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	sharp = TRUE
	force = 45
	armour_penetration = -15
	block_chance = 75
	block_type = MELEE_ATTACKS
	hitsound = 'sound/weapons/armblade.ogg'
	throw_range = 0
	throw_speed = 0
	gender = FEMALE
	var/datum/action/changeling/weapon/parent_action

/obj/item/melee/changeling/arm_blade/get_ru_names()
	return list(
		NOMINATIVE = "рука-клинок",
		GENITIVE = "руки-клинка",
		DATIVE = "руке-клинку",
		ACCUSATIVE = "руку-клинок",
		INSTRUMENTAL = "рукой-клинком",
		PREPOSITIONAL = "руке-клинке",
	)

/obj/item/melee/changeling/arm_blade/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action

/obj/item/melee/changeling/arm_blade/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		swing_sound = SFX_BLADE_SWING_LIGHT \
	)

/obj/item/melee/changeling/arm_blade/Destroy()
	. = ..()

	if(!parent_action)
		return

	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
	parent_action = null

/obj/item/melee/changeling/arm_blade/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()

	if(!proximity_flag)
		return

	if(is_airlock(target))
		var/obj/machinery/door/airlock/airlock = target

		if(!airlock.requiresID() || airlock.allowed(user)) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message.
			return

		if(airlock.locked)
			balloon_alert(user, "болты мешают открыть!")
			return

		if(airlock.arePowerSystemsOn())
			user.balloon_alert_to_viewers("раздвигает шлюз клинком!", "открываем шлюз")
			playsound(airlock, 'sound/machines/airlock_alien_prying.ogg', 150, TRUE)
			if(!do_after(user, 3 SECONDS, airlock))
				return

		airlock.open(2)

	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		var/obj/item/organ/external/organ = human.get_organ(user.zone_selected)
		if(organ && organ.brute_dam >= organ.max_damage)
			organ.droplimb()

/***************************************\
|**************FLESHY MAUL**************|
\***************************************/

/datum/action/changeling/weapon/fleshy_maul
	name = "Молот плоти"
	desc = "Мы трансформируем свою руку в огромный молот."
	helptext = "Вернуть руку можно той же способностью, что и вызван молот. Снижает производство химикатов на 0,25."
	dna_cost = 2
	recharge_slowdown = 0.25
	button_icon_state = "flesh_maul"
	power_type = CHANGELING_PURCHASABLE_POWER
	weapon_type = /obj/item/melee/changeling/fleshy_maul
	weapon_check_type = /obj/item/melee/changeling
	weapon_name_simple = "молот плоти"

/obj/item/melee/changeling/fleshy_maul
	name = "fleshy maul"
	desc = "Огромный молот из костей и плоти, что давит кости в пыль."
	icon_state = "flesh_maul"
	item_state = "flesh_maul"
	item_flags = ABSTRACT|DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 40
	armour_penetration = 40
	hitsound = SFX_SWING_HIT
	throw_range = 0
	throw_speed = 0
	gender = MALE
	var/datum/action/changeling/weapon/parent_action

/obj/item/melee/changeling/fleshy_maul/get_ru_names()
	return list(
		NOMINATIVE = "молот из плоти",
		GENITIVE = "молота из плоти",
		DATIVE = "молоту из плоти",
		ACCUSATIVE = "молот из плоти",
		INSTRUMENTAL = "молотом из плоти",
		PREPOSITIONAL = "молоте из плоти",
	)

/obj/item/melee/changeling/fleshy_maul/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action

/obj/item/melee/changeling/fleshy_maul/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = 180, \
		swing_speed_mod = 2, \
		afterswing_slowdown = 0.3, \
		no_multi_hit = TRUE, \
		swing_sound = SFX_BLUNT_SWING_HEAVY, \
	)

/obj/item/melee/changeling/fleshy_maul/Destroy()
	. = ..()

	if(!parent_action)
		return

	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
	parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
	parent_action = null

/obj/item/melee/changeling/fleshy_maul/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()

	if(!proximity_flag)
		return

	if(isstructure(target))
		var/obj/structure/structure = target
		if(!QDELETED(structure))
			structure.attack_generic(user, 80, BRUTE, MELEE, 0)

	else if(iswallturf(target))
		var/turf/simulated/wall/wall = target
		user.do_attack_animation(wall)
		user.changeNext_move(attack_speed)
		wall.take_damage(50)
		playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)

	else if(ishuman(target))
		var/mob/living/carbon/human/human = target
		var/obj/item/organ/external/organ = human.get_organ(user.zone_selected)
		organ.fracture()
		if(isliving(target))
			human.Knockdown(4 SECONDS)


/***************************************\
|***********COMBAT TENTACLES*************|
\***************************************/

/datum/action/changeling/weapon/tentacle
	name = "Мясное щупальце"
	desc = "Мы трансформируем руку в мясное щупальце. Требует 10 химикатов."
	helptext = "Можно один раз запустить щупальце. Эффект будет зависить от интента."
	button_icon_state = "tentacle"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 10
	weapon_type = /obj/item/gun/magic/tentacle
	weapon_check_type = /obj/item/gun/magic/tentacle
	weapon_name_simple = "мясное щупальце"
	silent = TRUE

/obj/item/gun/magic/tentacle
	name = "tentacle"
	desc = "Мясистое щупальце, что может хватать людей или предметы."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "tentacle"
	item_state = "tentacle"
	item_flags = ABSTRACT|NOBLUDGEON|DROPDEL
	slot_flags = NONE
	ammo_type = /obj/item/ammo_casing/magic/tentacle
	fire_sound = 'sound/effects/splat.ogg'
	force = 0
	max_charges = 1
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/datum/action/changeling/weapon/parent_action

/obj/item/gun/magic/tentacle/Initialize(mapload, silent, new_parent_action)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	parent_action = new_parent_action
	if(ismob(loc))
		if(!silent)
			loc.visible_message(
				span_warning("[loc.name] с ужасным хрустом превращает руку в мясное щупальце!"),
				span_notice("Мы трансформируем руку в мясное щупальце."),
				span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
			)
			playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)
		else
			to_chat(loc, span_notice("Мы готовы вытянуть щупальце."))

/obj/item/gun/magic/tentacle/Destroy()
	if(parent_action)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_action.UnregisterSignal(parent_action.owner, COMSIG_MOB_WEAPON_APPEARS)
		parent_action = null
		playsound(loc, 'sound/effects/bone_break_2.ogg', 100, TRUE)
	return ..()

/obj/item/gun/magic/tentacle/shoot_with_empty_chamber(mob/living/user as mob|obj)
	balloon_alert(user, "щупальце не готово")

/obj/item/gun/magic/tentacle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] обвивает свою шею мясным щупальцем! Похоже, он[GEND_A_O_I(user)] пыта[PLUR_ET_YUT(user)]ся покончить жизнь самоубийством!"))
	return OXYLOSS

/***************************************\
|****************SHIELD*****************|
\***************************************/

/datum/action/changeling/weapon/shield
	name = "Костяной щит"
	desc = "Мы трансформируем свою руку в твёрдый щит."
	helptext = "Снижает производство химикатов на 0,25."
	button_icon_state = "organic_shield"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	recharge_slowdown = 0.25
	weapon_type = /obj/item/shield/changeling
	weapon_check_type = /obj/item/shield/changeling
	weapon_name_simple = "костяной щит"

/datum/action/changeling/weapon/shield/sting_action(mob/user)
	var/obj/item/shield/changeling/shield = ..(user)
	if(!shield)
		return FALSE

	shield.remaining_uses = round(cling.absorbed_count * 3)
	return TRUE

/obj/item/shield/changeling
	name = "shield-like mass"
	desc = "Щит из плотной костяной ткани. На нём можно разглядеть скрюченные в безумном узоре пальцы."
	item_flags = DROPDEL
	icon_state = "ling_shield"
	var/remaining_uses //Set by the changeling ability.

/obj/item/shield/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(
			span_warning("[loc.name] с ужасным хрустом превращает руку в костянной щит!"),
			span_notice("Мы трансформируем руку в костянной щит."),
			span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
		)
		playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

/***************************************\
|*********SPACE SUIT + HELMET***********|
\***************************************/

/datum/action/changeling/suit/organic_space_suit
	name = "Органический скафандр"
	desc = "Мы отращиваем органический скафандр, что защищает от космоса."
	helptext = "Снижает производство химикатов на 0,25."
	button_icon_state = "organic_suit"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	recharge_slowdown = 0.25
	suit_type = /obj/item/clothing/suit/space/changeling
	helmet_type = /obj/item/clothing/head/helmet/space/changeling
	suit_name_simple = "органический скафандр"
	helmet_name_simple = "органический шлем"

/obj/item/clothing/suit/space/changeling
	name = "flesh mass"
	desc = "Огромная масса плоти, предоставляющая сносную защиту от давления и температуры."
	icon_state = "lingspacesuit"
	clothing_flags = STOPSPRESSUREDAMAGE
	flags_inv = HIDETAIL
	item_flags = DROPDEL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 90, ACID = 90) //No armor at all
	species_restricted = null
	faction_restricted = null
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
	)

/obj/item/clothing/suit/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(
			span_warning("Плоть [loc.name] быстро раздувается и образует органический скафандр!"),
			span_notice("Мы раздуваем плоть, чтобы создать органический скафандр."),
			span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
		)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/changeling/process()
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		user.reagents.add_reagent("perfluorodecalin", REAGENTS_METABOLISM)

/obj/item/clothing/head/helmet/space/changeling
	name = "flesh mass"
	desc = "Масса плоти, предоставляющая сносную защиту от давления и температуры, с стекловидным хитиновым покрытием спереди."
	icon_state = "lingspacehelmet"
	clothing_flags = STOPSPRESSUREDAMAGE
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDEHAIR
	item_flags = DROPDEL
	armor = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 90, ACID = 90)
	species_restricted = null
	faction_restricted = null
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
	)

/obj/item/clothing/head/helmet/space/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

/***************************************\
|*****************ARMOR*****************|
\***************************************/

/datum/action/changeling/suit/armor
	name = "Хитиновая броня"
	desc = "Мы трансформируем нашу кожу в прочный хитин, что отлично защищает."
	helptext = "Снижает производство химикатов на 0,5."
	dna_cost = 2
	recharge_slowdown = 0.5
	button_icon_state = "chitinous_armor"
	power_type = CHANGELING_PURCHASABLE_POWER
	suit_type = /obj/item/clothing/suit/armor/changeling
	helmet_type = /obj/item/clothing/head/helmet/changeling
	suit_name_simple = "хитиновоя броня"
	helmet_name_simple = "хитиновый шлем"

/obj/item/clothing/suit/armor/changeling
	name = "chitinous mass"
	desc = "Твёрдое  покрытие из чёрного хитина."
	icon_state = "lingarmor"
	item_flags = DROPDEL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 40, BULLET = 40, LASER = 20, ENERGY = 30, BOMB = 30, BIO = 0, FIRE = 90, ACID = 90)
	flags_inv = HIDEJUMPSUIT
	cold_protection = 0
	heat_protection = 0
	species_restricted = null
	faction_restricted = null
	hide_tail_by_species = list(SPECIES_VULPKANIN, SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID)
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
	)

/obj/item/clothing/suit/armor/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)
	if(ismob(loc))
		loc.visible_message(
			span_warning("Плоть [loc.name] быстро темнеет и образует хитиновое покрытие!"),
			span_notice("Мы трансформируем плоть, чтобы создать хитиновую броню."),
			span_warning("Вы слышите ужасный хруст и хлюпание органики!"),
		)
		playsound(loc, 'sound/effects/bone_break_1.ogg', 100, TRUE)

/obj/item/clothing/head/helmet/changeling
	name = "chitinous mass"
	desc = "Твёрдое  покрытие из чёрного хитина с прозрачной оболочкой спереди."
	icon_state = "lingarmorhelmet"
	flags_inv = HIDEHEADSETS|HIDEHAIR
	item_flags = DROPDEL
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 20, BOMB = 10, BIO = 4, FIRE = 90, ACID = 90)
	species_restricted = null
	faction_restricted = null

/obj/item/clothing/head/helmet/changeling/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CHANGELING_TRAIT)

