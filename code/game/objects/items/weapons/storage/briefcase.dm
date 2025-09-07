/obj/item/storage/briefcase
	name = "briefcase"
	desc = "Он сделан из НАСТОЯЩЕЙ искусственной кожи и всё ещё с ценником. Его владелец, должно быть, настоящий профессионал."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	use_sound = 'sound/effects/briefcase.ogg'
	force = 8
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("ударил", "огрел")
	resistance_flags = FLAMMABLE
	max_integrity = 150

/obj/item/storage/briefcase/sniperbundle
	desc = "На его этикетке написано \"настоящая закаленная кожа капитана\", но подозрительно отсутствуют другие метки или бренды. Пахнет как L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/populate_contents()
	new /obj/item/gun/projectile/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/accessory/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/gun_module/muzzle/suppressor/heavy(src)
	new /obj/item/gun_module/rail/scope/x8(src)

/obj/item/storage/briefcase/false_bottomed
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 10

	var/busy_hunting = FALSE
	var/bottom_open = FALSE //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		QDEL_NULL(stored_item)
	return ..()

/obj/item/storage/briefcase/false_bottomed/afterattack(atom/A, mob/user, flag, params)
	..()
	if(stored_item && isgun(stored_item) && !Adjacent(A))
		var/obj/item/gun/stored_gun = stored_item
		stored_gun.afterattack(A, user, flag, params)


/obj/item/storage/briefcase/false_bottomed/attackby(obj/item/I, mob/user, params)
	if(bottom_open)
		add_fingerprint(user)
		if(stored_item)
			to_chat(user, span_warning("В потайном дне уже что-то лежит!"))
			return ATTACK_CHAIN_PROCEED
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] слишком большой для потайного дна!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		stored_item = I
		max_w_class = WEIGHT_CLASS_NORMAL - stored_item.w_class
		I.move_to_null_space() //null space here we go - to stop it showing up in the briefcase
		to_chat(user, span_notice("Вы помещаете [I.declent_ru(ACCUSATIVE)] в потайное отделение кейса."))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/storage/briefcase/false_bottomed/screwdriver_act(mob/user, obj/item/I)
	if(!bottom_open && busy_hunting)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!bottom_open)
		to_chat(user, "Вы начинаете ощупывать край [declent_ru(GENITIVE)]...")
		busy_hunting = TRUE
		if(do_after(user, 2 SECONDS, src))
			if(user)
				to_chat(user, "Вы поддеваете и открываете потайное дно!")
			bottom_open = TRUE
		busy_hunting = FALSE
	else
		to_chat(user, "Вы защёлкиваете потайное дно с характерным щелчком[stored_item ? ", и [stored_item] остаётся внутри." : "."]")
		bottom_open = FALSE

/obj/item/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "Вы достаёте [stored_item.declent_ru(NOMINATIVE)] из потайного отделения [declent_ru(GENITIVE)].")
		stored_item = null
		max_w_class = initial(max_w_class)
	else
		return ..()

/obj/item/case_with_bipki
	name = "bipki case"
	desc = "Легендарный чемодан с бипками! Стоп, а что такое бипки?"
	icon = 'icons/obj/beebki.dmi'
	icon_state = "briefcase_bipki"
	item_state = "briefcase"
	force = 8
	attack_verb = list("ударил", "огрел")
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_BULKY
	var/opened = FALSE

/obj/item/case_with_bipki/get_ru_names()
	return list(
		NOMINATIVE = "чемодан с бипками",
		GENITIVE = "чемодана с бипками",
		DATIVE = "чемодану с бипками",
		ACCUSATIVE = "чемодан с бипками",
		INSTRUMENTAL = "чемоданом с бипками",
		PREPOSITIONAL = "чемодане с бипками"
	)

/obj/item/case_with_bipki/attack_self(mob/user)
	. = ..()
	opened = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_warning("Вы видите бипки."))
	sleep(3 SECONDS)
	user.drop_item_ground(src, force = TRUE)
	user.dust()
	sleep(4 SECONDS)
	opened = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/case_with_bipki/update_icon_state()
	icon_state = "briefcase_bipki[opened ? "_o" : ""]"

/obj/item/case_with_bipki/examine(mob/user)
	. = ..()
	if(opened)
		. += span_warning("Яркий свет не позволяет вам увидеть содержимое кейса.")
