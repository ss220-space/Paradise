/obj/structure/closet/secure_closet/syndicate/depot
	name = "depot supply closet"
	desc = "A red and black lootbox full of things the Head of Security is going to flip their shit over."
	desc = "Красно-черный лутбокс, полный вещей, от которых глава службы безопасности придет в ярость."
	locked = FALSE
	anchored = TRUE
	req_access = list()
	max_integrity = 250
	icon_state = "secure"
	var/is_armory = FALSE
	var/ignore_use = FALSE

/obj/structure/closet/secure_closet/syndicate/depot/get_ru_names()
    return list(
        NOMINATIVE = "складской шкафчик снабжения",
        GENITIVE = "складского шкафчика снабжения",
        DATIVE = "складскому шкафчику снабжения",
        ACCUSATIVE = "складской шкафчик снабжения",
        INSTRUMENTAL = "складским шкафчиком снабжения",
        PREPOSITIONAL = "складском шкафчике снабжения",
    )

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

/obj/structure/closet/secure_closet/syndicate/depot/attack_animal(mob/M)
	if(isanimal(M) && ("syndicate" in M.faction))
		to_chat(M, span_warning("The [src] resists your attack!"))
		to_chat(M, span_warning("[src] сопротивляется вашей атаке!"))
		return
	return ..()

/obj/structure/closet/secure_closet/syndicate/depot/attackby(obj/item/I, mob/user, params)
	if(opened)
		return ..()

	if(istype(I, /obj/item/rcs))
		add_fingerprint(user)
		to_chat(user, span_warning("Bluespace interference prevents [I] from locking onto [src]!"))
		to_chat(user, span_warning("Блюспейс помехи мешают [I] захватить [src]!"))
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
