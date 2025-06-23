
/obj/structure/closet/secure_closet/syndicate/depot
	name = "depot supply closet"
	ru_names = list(
		NOMINATIVE = "защищённый шкафчик",
		GENITIVE = "защищённого шкафчика",
		DATIVE = "защищённому шкафчику",
		ACCUSATIVE = "защищённый шкафчик",
		INSTRUMENTAL = "защищённым шкафчиком",
		PREPOSITIONAL = "защищённом шкафчике"
	)
	locked = 0
	anchored = TRUE
	req_access = list()
	max_integrity = 250
	icon_state = "secure"
	var/is_armory = FALSE
	var/ignore_use = FALSE

/obj/structure/closet/secure_closet/syndicate/depot/emag_act()
	. = ..()
	loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/open()
	. = ..()
	if(opened)
		loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/dump_contents()
	loot_pickup()
	. = ..()

/obj/structure/closet/secure_closet/syndicate/depot/proc/loot_pickup()
	if(!ignore_use)
		var/area/syndicate_depot/core/depotarea = get_area(src)
		if(istype(depotarea))
			depotarea.locker_looted()
			if(is_armory)
				depotarea.armory_locker_looted()

/obj/structure/closet/secure_closet/syndicate/depot/attack_animal(mob/user)
	if(isanimal(user) && ("syndicate" in user.faction))
		user.balloon_alert(user, "неподходящая цель!")
		to_chat(user, span_warning("Вы не должны наносить ущерб [declent_ru(ACCUSATIVE)]!"))
		return
	return ..()


/obj/structure/closet/secure_closet/syndicate/depot/attackby(obj/item/I, mob/user, params)
	if(opened)
		return ..()

	if(istype(I, /obj/item/rcs))
		add_fingerprint(user)
		user.balloon_alert(user, "невозможно!")
		to_chat(user, span_warning("Помехи в блюспейс-пространстве не дают зафиксировать [I.declent_ru(ACCUSATIVE)] на [declent_ru(PREPOSITIONAL)]!"))
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/structure/closet/secure_closet/syndicate/depot/emp_act(severity)
	return

/obj/structure/closet/secure_closet/syndicate/depot/togglelock(mob/user)
	. = ..()
	if(!locked)
		loot_pickup()

/obj/structure/closet/secure_closet/syndicate/depot/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		ignore_use = TRUE
		toggle(user)
		ignore_use = FALSE

/obj/structure/closet/secure_closet/syndicate/depot/armory
	req_access = list(ACCESS_SYNDICATE)
	is_armory = TRUE
