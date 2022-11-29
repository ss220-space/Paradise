

/mob/living/simple_animal
	var/obj/item/clothing/head/inventory_head	//шапка
	var/obj/item/clothing/mask/inventory_mask	//маски (сигареты)
	var/obj/item/clothing/inventory_back		//костюмы (на корги можно надеть броню, космокостюм)
	var/obj/item/clothing/accessory/petcollar/inventory_collar = null

	var/collar_type //if the mob has collar sprites, define them.

	//Что может и не может носить
	var/can_collar = FALSE
	var/can_mask = FALSE
	var/can_head = TRUE 	//!!!!!!!!!!УСТАНОВИТЬ НА FALSE НЕ ЗАБЫТЬ
	var/can_back = FALSE

	//Если животное носит FASHION одежду. Может ли оно носить и уже ли носит
	var/can_wear_fashion_head = FALSE
	var/can_wear_fashion_mask = FALSE
	var/can_wear_fashion_back = FALSE

	var/is_wear_fashion_head = FALSE
	var/is_wear_fashion_mask = FALSE
	var/is_wear_fashion_back = FALSE

	var/list/blacklisted_hats = list( //Запрещенные шляпы на ношение для больших голов
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/snowman,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bomb_hood,
		/obj/item/clothing/head/blob,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/corgi,
		/obj/item/clothing/head/cueball,
		/obj/item/clothing/head/hardhat/pumpkinhead,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/papersack,
		/obj/item/clothing/head/human_head
	)

	var/canWearBlacklistedHats = TRUE //= FALSE !!!!!!!

/mob/living/simple_animal/pet/dog/corgi
	isFashion = TRUE

	can_wear_fashion_head = TRUE
	can_wear_fashion_back = TRUE

/mob/living/simple_animal/pet/dog/corgi/puppy
	isFashion = FALSE

	can_wear_fashion_head = FALSE
	can_wear_fashion_back = FALSE

/mob/living/simple_animal/pet/dog/corgi/Lisa
	isFashion = FALSE

	can_wear_fashion_head = FALSE
	can_wear_fashion_back = FALSE

/mob/living/simple_animal/pet/dog/security
	isFashion = TRUE

	can_wear_fashion_head = TRUE
	can_wear_fashion_mask = TRUE

/mob/living/simple_animal/pet/dog/security/ranger //Почему-то у него была шапка отключена? У него уже встроенная?
	isFashion = TRUE

	can_wear_fashion_mask = TRUE

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge
	isFashion = TRUE
	//can_head = FALSE
	can_wear_fashion_head = TRUE

/mob/living/simple_animal/bot
	//inventory_head = new /obj/item/clothing/head/hopcap //!!!!!!!!!!!!!!!!!
	hat_offset_y = -15
	isCentered = TRUE
	can_head = TRUE
	canWearBlacklistedHats = TRUE

/mob/living/simple_animal/show_inv(mob/user as mob)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	if (can_head || can_wear_fashion_head)
		dat += "<br><B>Head:</B> <A href='?src=[UID()];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'><font color=grey>Empty</font>"]</A>"
	if (can_mask || can_wear_fashion_mask)
		dat += "<br><B>Mask:</B> <A href='?src=[UID()];[inventory_mask ? "remove_inv=mask'>[inventory_mask]" : "add_inv=mask'><font color=grey>Empty</font>"]</A>"
	if (can_back || can_wear_fashion_back)
		dat += "<br><B>Back:</B> <A href='?src=[UID()];[inventory_back ? "remove_inv=back'>[inventory_back]" : "add_inv=back'><font color=grey>Empty</font>"]</A>"
	if (can_collar)
		dat += "<br><B>Collar:</B><A href='?src=[UID()];item=[slot_collar]'>[(inventory_collar && !(inventory_collar.flags & ABSTRACT)) ? inventory_collar : "<font color=grey>Empty</font>"]</A>"
	dat += "<br><A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>"

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
		place_on_head(user.get_active_hand(), user)
		return

	. = ..()

/mob/living/simple_animal/attack_hand(mob/user)
	if(ishuman(user) && (user.a_intent == INTENT_GRAB) && inventory_head)
		remove_from_head(user)
		return TRUE

	. = ..()

/mob/living/simple_animal/Topic(href, href_list)
	if(!(iscarbon(usr) || isrobot(usr)) || usr.incapacitated() || !Adjacent(usr)) // || !can_head) !!!!!!!!!!!!!!!!
		usr << browse(null, "window=mob[UID()]")
		usr.unset_machine()
		return

	//Removing from inventory
	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				remove_from_head(usr)
			if("back")
				remove_from_back(usr)
			if("mask")
				remove_from_mask(usr)
			if("collar")
				remove_from_collar(usr)

		show_inv(usr)

	//Adding things to inventory
	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]

		switch(add_to)
			if("collar")
				add_collar(usr.get_active_hand(), usr)
			if("head")
				place_on_head(usr.get_active_hand(), usr)
			if("back")
				place_on_back(usr.get_active_hand(), usr)
			if("mask")
				place_on_mask(usr.get_active_hand(), usr)

		show_inv(usr)
	else
		return ..()





/mob/living/simple_animal/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
		item_to_add.afterattack(src,user,1)
		return 1

	if(!item_to_add)
		user.visible_message("<span class='notice'>[user.name] похлопывает по [src.name].</span>", "<span class='notice'>Вы положили руку на [src.name].</span>")
		if(flags_2 & HOLOGRAM_2)
			return 0
		return 0

	if(!istype(item_to_add, /obj/item/clothing/head/))
		to_chat(user, "<span class='warning'>[item_to_add.name] нельзя надеть на [src.name]! Это не шляпа.</span>")
		wrong_item(item_to_add, user)
		return 0

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>Нельзя надеть больше одного головного убора на [src.name]!</span>")
			wrong_item(item_to_add, user)
		return 0

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>[item_to_add.name] застрял в ваших руках, вы не можете его надеть на голову [src.name]!</span>")
		return 0

	place_on_head_fashion(item_to_add, user)
	return 1

///Текста, фешины для голов
/mob/living/simple_animal/proc/place_on_head_fashion(obj/item/item_to_add, mob/user)
	if(!can_head)
		to_chat(user, "<span class='warning'>[item_to_add.name] нельзя надеть на [src.name]! Головные уборы слетают.</span>")
		wrong_item(item_to_add, user)
		return 0

	if (!canWearBlacklistedHats && is_type_in_list(item_to_add, blacklisted_hats))
		to_chat(user, "<span class='warning'>[item_to_add.name] не помещается на голову [src.name]!</span>")
		wrong_item(item_to_add, user)
		return 0

	if(health <= 0)
		to_chat(user, "<span class='notice'>Взгляд [real_name] пуст и безжизненнен, когда вы нацепляете [item_to_add.name] на [genderize_ru(src.gender,"его","её","этого","их")] голову.</span>")
	else if(user)
		user.visible_message("<span class='notice'>[user.name] надевает [item_to_add.name] на голову [real_name].</span>",
			"<span class='notice'>Вы надеваете [item_to_add.name] на голову [real_name].</span>",
			"<span class='italics'>Вы слышите как что-то нацепили.</span>")
	item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()

	//Если каска инженера, то даем свет
	if(istype(item_to_add, /obj/item/clothing/head/hardhat))
		set_light(4)

	return 1

/mob/living/simple_animal/proc/place_on_mask(obj/item/item_to_add, mob/user)
	if(inventory_mask)
		to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
		return
	else
		if(!item_to_add)
			usr.visible_message("<span class='notice'>[usr] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s face for a moment.</span>")
			return

		if(!usr.unEquip(item_to_add))
			to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s face!</span>")
			return

		if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
			item_to_add.afterattack(src,usr,1)
			return

		if(!place_on_mask_fashion(item_to_add, user))
			to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s face, but it falls off!</span>")
			wrong_item(item_to_add, user)
			return

		item_to_add.forceMove(src)
		inventory_mask = item_to_add
		update_fluff()
		regenerate_icons()

///Проверка на fashion объекты
/mob/living/simple_animal/proc/place_on_mask_fashion(obj/item/item_to_add, mob/user)
	return 0

/mob/living/simple_animal/proc/place_on_back(obj/item/item_to_add, mob/user)
	if(inventory_back)
		to_chat(usr, "<span class='warning'>It's already wearing something!</span>")
		return
	else
		if(!item_to_add)
			usr.visible_message("<span class='notice'>[usr] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s back for a moment.</span>")
			return

		if(!usr.unEquip(item_to_add))
			to_chat(usr, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s back!</span>")
			return

		if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
			item_to_add.afterattack(src,usr,1)
			return

		//The objects that mobs can wear on their backs.
		if(!place_on_back_fashion(item_to_add, user))
			to_chat(usr, "<span class='warning'>You set [item_to_add] on [src]'s back, but it falls off!</span>")
			wrong_item(item_to_add, user)
			return

		item_to_add.forceMove(src)
		inventory_back = item_to_add
		update_fluff()
		regenerate_icons()

/mob/living/simple_animal/proc/place_on_back_fashion(obj/item/item_to_add, mob/user)
	return 0

/mob/living/simple_animal/proc/add_collar(obj/item/clothing/accessory/petcollar/P, mob/user)
	if(!istype(P) || QDELETED(P) || inventory_collar)
		return
	if(user && !user.unEquip(P))
		return
	P.forceMove(src)
	P.equipped(src)
	inventory_collar = P
	regenerate_icons()
	if(user)
		to_chat(user, "<span class='notice'>You put [P] around [src]'s neck.</span>")
	if(P.tagname && !unique_pet)
		name = P.tagname
		real_name = P.tagname
	update_fluff()

//Анимация прокручивания моба при нацеплении неправильного предмета
/mob/living/simple_animal/proc/wrong_item(obj/item/item_to_add, mob/user)
	//unEquip(user.get_active_hand())
	user.drop_item()
	item_to_add.forceMove(drop_location())
	if(prob(25))
		step_rand(item_to_add)
	for(var/i in list(1,2,4,8,4,8,4,dir))
		setDir(i)
		sleep(1)

/mob/living/simple_animal/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(inventory_head.flags & NODROP)
			to_chat(user, "<span class='warning'>[inventory_head.name] застрял на голове [src.name]! Его невозможно снять!</span>")
			return 1

		to_chat(user, "<span class='warning'>Вы сняли [inventory_head.name] с головы [src.name].</span>")
		user.put_in_hands(inventory_head)

		inventory_head = null
		hat_icon_state = null
		hat_alpha = null
		hat_color = null
		animated_fashion = FALSE

		update_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>У [src.name] нет головного убора!</span>")
		return 0

	return 1

/mob/living/simple_animal/proc/remove_from_back(mob/user)
	if(inventory_back)
		if(inventory_back.flags & NODROP)
			to_chat(usr, "<span class='warning'>\The [inventory_head] is stuck too hard to [src] for you to remove!</span>")
			return
		usr.put_in_hands(inventory_back)
		inventory_back = null
		animated_fashion = FALSE
		update_fluff()
		regenerate_icons()
	else
		to_chat(usr, "<span class='danger'>There is nothing to remove from its back.</span>")
		return

/mob/living/simple_animal/proc/remove_from_mask(mob/user)
	if(inventory_mask)
		if(inventory_mask.flags & NODROP)
			to_chat(usr, "<span class='warning'>\The [inventory_head] is stuck too hard to [src] for you to remove!</span>")
			return
		usr.put_in_hands(inventory_mask)
		inventory_mask = null
		animated_fashion = FALSE
		update_fluff()
		regenerate_icons()
	else
		to_chat(usr, "<span class='danger'>There is nothing to remove from its mask.</span>")
		return

/mob/living/simple_animal/proc/remove_from_collar(mob/user)
	if(inventory_collar)
		var/the_collar = inventory_collar
		unEquip(inventory_collar)
		usr.put_in_hands(the_collar)
		inventory_collar = null
		update_fluff()
		regenerate_icons()

///Имена, эмоции и описания
/mob/living/simple_animal/proc/update_fluff()
	return 0

/mob/living/simple_animal/StartResting(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()

/mob/living/simple_animal/StopResting(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living
		if(collar_type)
			collar_type = "[initial(collar_type)]"
			regenerate_icons()

/mob/living/simple_animal/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_collar)
			return inventory_collar
	. = ..()

/mob/living/simple_animal/can_equip(obj/item/I, slot, disable_warning = 0)
	// . = ..() // Do not call parent. We do not want animals using their hand slots.
	switch(slot)
		if(slot_collar)
			if(inventory_collar)
				return FALSE
			if(!can_collar)
				return FALSE
			if(!istype(I, /obj/item/clothing/accessory/petcollar))
				return FALSE
			return TRUE

/mob/living/simple_animal/equip_to_slot(obj/item/W, slot)
	if(!istype(W))
		return FALSE

	if(!slot)
		return FALSE

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(slot_collar)
			add_collar(W)

/mob/living/simple_animal/unEquip(obj/item/I, force)
	. = ..()
	if(!. || !I)
		return

	var/is_need_regen = FALSE

	//switch(I) не работает, он запрашивает constant expression
	if(I == inventory_collar)
		inventory_collar = null
		is_need_regen = TRUE
	if(I == inventory_head)
		inventory_head = null
		is_need_regen = TRUE
	if(I == inventory_mask)
		inventory_mask = null
		is_need_regen = TRUE
	if(I == inventory_back)
		inventory_back = null
		is_need_regen = TRUE

	if(is_need_regen)
		regenerate_icons()

/mob/living/simple_animal/get_access()
	. = ..()
	if(inventory_collar)
		. |= inventory_collar.GetAccess()

//Моб получает броню от надетой одежды
/mob/living/simple_animal/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == "head")
			if(inventory_head)
				armorval = inventory_head.armor.getRating(type)
		else
			if(inventory_back)
				armorval = inventory_back.armor.getRating(type)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor.getRating(type)
		if(inventory_back)
			armorval += inventory_back.armor.getRating(type)
	return armorval * 0.5

//прок по местоположению, вызываемый при Destroy()
/mob/living/simple_animal/handle_atom_del(atom/A)
	var/is_need_regen = FALSE

	//switch(I) не работает, он запрашивает constant expression
	if(A == inventory_collar)
		inventory_collar = null
		is_need_regen = TRUE
	if(A == inventory_head)
		inventory_head = null
		is_need_regen = TRUE
	if(A == inventory_mask)
		inventory_mask = null
		is_need_regen = TRUE
	if(A == inventory_back)
		inventory_back = null
		is_need_regen = TRUE

	if(is_need_regen)
		regenerate_icons()

	return ..()

//proc для Destroy(), очищающий элементы инвентаря
/mob/living/simple_animal/proc/destroy_inventory()
	QDEL_NULL(inventory_collar)
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_mask)
	QDEL_NULL(inventory_back)

/mob/living/simple_animal/proc/gib_inventory()
	if(inventory_collar)
		inventory_collar = null
		inventory_collar.forceMove(drop_location())
	if(inventory_head)
		inventory_head = null
		inventory_head.forceMove(drop_location())
	if(inventory_mask)
		inventory_mask = null
		inventory_mask.forceMove(drop_location())
	if(inventory_back)
		inventory_back = null
		inventory_back.forceMove(drop_location())

/mob/living/simple_animal/proc/death_inventory()
	if(collar_type)
		collar_type = "[initial(collar_type)]_dead"
		regenerate_icons()

/mob/living/simple_animal/proc/revive_inventory()
	if(collar_type)
		collar_type = "[initial(collar_type)]"
		regenerate_icons()

/mob/living/simple_animal/proc/initialize_inventory()
	var/is_need_regen = FALSE
	if(inventory_collar)
		inventory_collar = new(src)
		is_need_regen = TRUE
	if(inventory_head)
		inventory_head = new(src)
		is_need_regen = TRUE
	if(inventory_mask)
		inventory_mask = new(src)
		is_need_regen = TRUE
	if(inventory_back)
		inventory_back = new(src)
		is_need_regen = TRUE
	if(is_need_regen)
		regenerate_icons()

//Обновление уникальных анимированных фешинов
///mob/living/simple_animal/Life(seconds, times_fired)
//	. = ..()
//	if(animated_fashion)
//		regenerate_icons()
