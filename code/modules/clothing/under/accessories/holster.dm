/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "Кобура для оружия."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	icon_state = "holster"
	slot = ACCESSORY_SLOT_UTILITY
	pickup_sound = 'sound/items/handling/backpack_pickup.ogg'
	equip_sound = 'sound/items/handling/backpack_equip.ogg'
	drop_sound = 'sound/items/handling/backpack_drop.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/accessory/holster)
	var/holster_allow = /obj/item/gun
	var/list/holstered = list()
	var/max_content = 1
	var/sound_holster = 'sound/weapons/gun_interactions/1holster.ogg'
	var/sound_unholster = 'sound/weapons/gun_interactions/1unholster.ogg'

/obj/item/clothing/accessory/holster/Destroy()
	for(var/obj/item/I in holstered)
		if(I.loc == src)
			holstered -= I
			QDEL_NULL(I)
	return ..()

/obj/item/clothing/accessory/holster/proc/can_holster(obj/item/I)
	if(!istype(I, holster_allow))
		return FALSE
	var/obj/item/gun/G = I
	if(istype(G) && (!G.can_holster || G.w_class > WEIGHT_CLASS_NORMAL))
		return FALSE
	return TRUE


/obj/item/clothing/accessory/holster/attack_self(mob/user = usr)
	. = ..()
	if(.)
		return .
	var/holsteritem = user.get_active_hand()
	if(istype(holsteritem, /obj/item/clothing/accessory/holster))
		unholster(user)
	else if(holsteritem)
		holster(holsteritem, user)
	else
		unholster(user)


/obj/item/clothing/accessory/holster/proc/holster(obj/item/I, mob/user)
	if(istype(I, /obj/item/clothing/accessory/holster))
		balloon_alert(user, ("не помещается!"))
		return FALSE

	if(holstered.len >= max_content)
		balloon_alert(user, ("уже есть оружие"))
		return FALSE

	if(!can_holster(I))
		balloon_alert(user, ("не подходит!"))
		return FALSE

	if(I.loc == user && !user.can_unEquip(I))
		balloon_alert(user, ("не получается!"))
		return FALSE

	. = TRUE
	holstered += I
	if(I.loc == user)
		user.temporarily_remove_item_from_inventory(I)
	I.forceMove(src)
	I.add_fingerprint(user)
	user.visible_message(span_notice("[user] убрал[genderize_ru(user.gender, "", "а", "о", "и")] [I] в кобуру."), span_notice("Вы убрали [I] в кобуру."))
	playsound(user.loc, sound_holster, 50, 1)

/obj/item/clothing/accessory/holster/proc/unholster(mob/user)
	if(!holstered.len)
		balloon_alert(user, ("пусто"))
		return

	var/obj/item/next_item = holstered[holstered.len]

	if(user.stat || HAS_TRAIT(user, TRAIT_INCAPACITATED))
		balloon_alert(user, ("не получается!"))
		return

	if(istype(user.get_active_hand(), /obj) && istype(user.get_inactive_hand(), /obj))
		balloon_alert(user, ("в руке уже что-то есть!"))
	else
		user.put_in_hands(next_item)
		next_item.add_fingerprint(user)
		holstered -= next_item
		unholster_message(user, next_item)
		playsound(user.loc, sound_unholster, 50, 1)

/obj/item/clothing/accessory/holster/proc/unholster_message(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		usr.visible_message(span_warning("[user] достал[genderize_ru(user.gender, "", "а", "о", "и")] [I], готовясь стрелять!"),
							span_warning("Вы достали [I] и готовы стрелять!"))
	else
		user.visible_message(span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [I], направив ствол вниз."),
							span_notice("Вы достали [I], направив ствол вниз."))

/obj/item/clothing/accessory/holster/attack_hand(mob/user)
	if(has_suit)	//if we are part of a suit
		if(holstered)
			unholster(user)
		return

	..(user)


/obj/item/clothing/accessory/holster/attackby(obj/item/I, mob/user, params)
	if(holster(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/clothing/accessory/holster/emp_act(severity)
	for(var/obj/item/I in holstered)
		I.emp_act(severity)
	..()

/obj/item/clothing/accessory/holster/examine(mob/user)
	. = ..(user)
	if(holstered.len)
		for(var/obj/item/I in holstered)
			. += span_notice("[I] находится в этой кобуре.")
	else
		. += span_notice("Кобура пуста.")


/obj/item/clothing/accessory/holster/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(.)
		has_suit.verbs += /obj/item/clothing/accessory/holster/verb/holster_verb


/obj/item/clothing/accessory/holster/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		old_suit.verbs -= /obj/item/clothing/accessory/holster/verb/holster_verb


//For the holster hotkey
/obj/item/clothing/accessory/holster/verb/holster_verb()
	set name = "Кобура"
	set category = STATPANEL_OBJECT
	set src in usr

	if(!isliving(usr) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	var/obj/item/clothing/accessory/holster/holster
	if(istype(src, /obj/item/clothing/accessory/holster))
		holster = src
	else if(istype(src, /obj/item/clothing/under))
		var/obj/item/clothing/under/uniform = src
		if(LAZYLEN(uniform.accessories))
			holster = locate() in uniform.accessories

	if(!holster)
		return

	holster.attack_self(usr)


/obj/item/clothing/accessory/holster/armpit
	name = "shoulder holster"
	desc = "Кобура для оружия. Идеально подходит для скрытого ношения."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	holster_allow = /obj/item/gun/projectile

/obj/item/clothing/accessory/holster/waist
	name = "shoulder holster"
	desc = "Кобура для оружия. Сделана из дорогой кожи."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)

/obj/item/clothing/accessory/holster/leg
	name = "leg holster"
	desc = "Кобура для оружия. Для настоящих шпионов."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	icon_state = "leg_holster"

/obj/item/clothing/accessory/holster/leg/black
	name = "black leg holster"
	desc = "Чёрная кобура для оружия. Для настоящих шпионов."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	icon_state = "leg_holster_black"

/obj/item/clothing/accessory/holster/belt
	name = "belt holster"
	desc = "Кобура для оружия. Напоминает сотрудникам службы безопасности и старых временах."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	icon_state = "belt_holster"

/obj/item/clothing/accessory/holster/belt/black
	name = "black belt holster"
	desc = "Чёрная кобура для оружия. Напоминает сотрудникам службы безопасности и старых временах."
	ru_names = list(
		NOMINATIVE = "кобура для оружия",
		GENITIVE = "кобуры для оружия",
		DATIVE = "кобуре для оружия",
		ACCUSATIVE = "кобуру для оружия",
		INSTRUMENTAL = "кобурой для оружия",
		PREPOSITIONAL = "кобуре для оружия"
	)
	icon_state = "belt_holster_black"

/obj/item/clothing/accessory/holster/knives
	name = "knife holster"
	desc = "Множестно ремней, соединенных в одну кобуру. Имеет 7 специальных слотов для хранения ножей."
	ru_names = list(
		NOMINATIVE = "кобура для ножей",
		GENITIVE = "кобуры для ножей",
		DATIVE = "кобуре для ножей",
		ACCUSATIVE = "кобуру для ножей",
		INSTRUMENTAL = "кобурой для ножей",
		PREPOSITIONAL = "кобуре для ножей"
	)
	icon_state = "holsterknife"
	holster_allow = list(
		/obj/item/kitchen/knife,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/combat/survival,
		/obj/item/kitchen/knife/combat/survival/bone,
		/obj/item/kitchen/knife/combat/throwing,
		/obj/item/kitchen/knife/carrotshiv,
		/obj/item/kitchen/knife/glassshiv,
		/obj/item/kitchen/knife/glassshiv/plasma
	)
	max_content = 7
	sound_holster = 'sound/weapons/knife_holster/knife_holster.ogg'
	sound_unholster = 'sound/weapons/knife_holster/knife_unholster.ogg'


/obj/item/clothing/accessory/holster/knives/unholster_message(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		user.visible_message(span_warning("[user] достал[genderize_ru(user.gender, "", "а", "о", "и")] [I], готовясь метнуть!"),
			span_warning("Вы достали [I]. Осталось [holstered.len] ножей."))
	else
		user.visible_message(span_notice("[user] достал[genderize_ru(user.gender, "", "а", "о", "и")] [I] ."),
			span_notice("Вы достали [I]. Осталось [holstered.len] ножей."))

/obj/item/clothing/accessory/holster/knives/can_holster(obj/item/I)
	return is_type_in_list(I, holster_allow, FALSE)

/obj/item/clothing/accessory/holster/knives/attached_examine(mob/user)
	return span_notice("\A [src] with [holstered.len] knives attached to it.")
