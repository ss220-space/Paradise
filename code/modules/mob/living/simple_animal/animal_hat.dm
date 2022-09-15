/mob/living/simple_animal
	var/obj/item/inventory_head// = /obj/item/clothing/head/hopcap //!!!!!!!!!!!!!!!!!

	var/hat_offset_y = -8
	var/hat_offset_y_rest = -8
	var/hat_offset_x_rest = 0
	var/hat_offset_y_dead = -16
	var/hat_offset_x_dead = 0
	var/hat_dir_dead = SOUTH //Указываем направление в которое будет смотреть шапка при смерти моба
	var/hat_rotate_dead = FALSE //переворачиваем ли шапку при смерти моба
	var/isCentered = TRUE //центрирован ли моб. Если нет(FALSE), то шляпа будет растянута матрицей

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

	var/hat_icon_file = 'icons/mob/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/canBeHatted = TRUE//= FALSE !!!!!!!!!!
	var/canWearBlacklistedHats = TRUE //= FALSE !!!!!!!

///mob/living/simple_animal/pet/dog/corgi

///mob/living/simple_animal/pet/dog/security

///mob/living/simple_animal/hostile/retaliate/poison/snake/rouge

/mob/living/simple_animal/bot
	//inventory_head = /obj/item/clothing/head/hopcap //!!!!!!!!!!!!!!!!!
	hat_offset_y = -15
	isCentered = TRUE
	canBeHatted = TRUE
	canWearBlacklistedHats = TRUE

/mob/living/simple_animal/attackby(obj/item/W, mob/user, params)	//!!!!!!проверить можно ли будет пиздить предметами
	if(istype(W, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
		place_on_head(user.get_active_hand(), user)
		return

	. = ..()

/mob/living/simple_animal/attack_hand(mob/user)
	if(ishuman(user) && (user.a_intent == INTENT_GRAB) && inventory_head)
		remove_from_head(user)
		return TRUE

	. = ..()


/mob/living/simple_animal/proc/hat_icons()
	if(inventory_head)
		overlays += get_hat_overlay()

/mob/living/simple_animal/Topic(href, href_list)
	if(!(iscarbon(usr) || isrobot(usr)) || usr.incapacitated() || !Adjacent(usr))// || !canBeHatted) !!!!!!!!!!!!!!!!
		usr << browse(null, "window=mob[UID()]")
		usr.unset_machine()
		return

	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				remove_from_head(usr)
		show_inv(usr)

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand(), usr)
		show_inv(usr)

	else
		return ..()

/mob/living/simple_animal/proc/regenerate_hat_icon() //regenerate_icons()
	if(inventory_head)// && !get_regenerate_fashion())
		//message_admins("Тест -1")
		var/image/head_icon

		if(!hat_icon_state)
			hat_icon_state = inventory_head.icon_state
		if(!hat_alpha)
			hat_alpha = inventory_head.alpha
		if(!hat_color)
			hat_color = inventory_head.color

		if(health <= 0)
			head_icon = get_hat_overlay(dir = hat_dir_dead)
			head_icon.pixel_y = -8
			if (hat_rotate_dead)
				head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = get_hat_overlay()

		add_overlay(head_icon)

/mob/living/simple_animal/proc/get_hat_overlay(var/dir)
	if(hat_icon_file && hat_icon_state)
		var/image/animalI = image(hat_icon_file, hat_icon_state)
		animalI.alpha = hat_alpha
		animalI.color = hat_color
		animalI.pixel_y = hat_offset_y
		if (!isCentered)
			animalI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
		return animalI

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
		wrong_hat(item_to_add, user)
		return 0

	if(!canBeHatted)
		to_chat(user, "<span class='warning'>[item_to_add.name] нельзя надеть на [src.name]! Этот головной убор слетает.</span>")
		wrong_hat(item_to_add, user)
		return 0

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>Нельзя надеть больше одного головного убора на [src.name]!</span>")
			wrong_hat(item_to_add, user)
		return 0

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>[item_to_add.name] застрял в ваших руках, вы не можете его надеть на голову [src.name]!</span>")
		return 0

	if (!canWearBlacklistedHats && is_type_in_list(item_to_add, blacklisted_hats))
		to_chat(user, "<span class='warning'>[item_to_add.name] не помещается на голову [src.name]!</span>")
		wrong_hat(item_to_add, user)
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
	if(istype(item_to_add, /obj/item/clothing/head/))
		set_light(4)

	return 1

/mob/living/simple_animal/proc/place_on_head_fashion(obj/item/item_to_add, mob/user)
	return 0

//Анимация прокручивания при нацеплении неправильного головного убора
/mob/living/simple_animal/proc/wrong_hat(obj/item/item_to_add, mob/user)
	//item_to_add.forceMove(drop_location())
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

		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>У [src.name] нет головного убора!</span>")
		return 0

	return 1

///mob/living/simple_animal/Initialize(mapload)
//	. = ..()
//	regenerate_icons()

//Если вдруг кто-то захочет сразу спавнить мобов с шапками
/mob/living/simple_animal/New()
	..()
	regenerate_icons()
