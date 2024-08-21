/datum/strippable_item/borg_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/borg_head/get_item(atom/source)
	var/mob/living/silicon/borg_source = source
	if(!istype(borg_source))
		return

	return borg_source.inventory_head

/datum/strippable_item/borg_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/silicon/borg_source = source
	if(!istype(borg_source))
		return

	borg_source.place_on_head(equipping, user)

/datum/strippable_item/borg_head/finish_unequip(atom/source, mob/user)
	var/mob/living/silicon/borg_source = source
	if(!istype(borg_source))
		return

	borg_source.remove_from_head(user)

/mob/living/silicon
	var/obj/item/inventory_head
	var/list/strippable_inventory_slots = list()

	var/hat_offset_y = -3
	var/isCentered = FALSE //центрирован ли синтетик. Если нет, то шляпа будет растянута

	var/list/blacklisted_hats = list( //Запрещенные шляпы на ношение для боргов с большими головами
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
		/obj/item/clothing/head/human_head,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/hardhat/reindeer,
		/obj/item/clothing/head/cardborg
	)

	var/hat_icon_file
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/canBeHatted = FALSE
	var/canWearBlacklistedHats = FALSE

/mob/living/silicon/robot/drone
	hat_offset_y = -15
	isCentered = TRUE
	canBeHatted = TRUE
	canWearBlacklistedHats = TRUE

/mob/living/silicon/robot/cogscarab
	hat_offset_y = -15
	isCentered = TRUE
	canBeHatted = TRUE

/mob/living/silicon/ai
	hat_offset_y = 3
	isCentered = TRUE
	canBeHatted = TRUE

/mob/living/silicon/robot/proc/robot_module_hat_offset(var/module)
	switch(module)
		//хуманоидные броботы с шляпами
		if("Engineering", "Miner_old", "JanBot2", "Medbot", "engineerrobot", "maximillion", "secborg", "Hydrobot")
			canBeHatted = FALSE
			hat_offset_y = -1
		if("Noble-CLN", "Noble-SRV", "Noble-DIG", "Noble-MED", "Noble-SEC", "Noble-ENG", "Noble-STD") //Высотой: 32 пикселя
			canBeHatted = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = 4
		if("droid-medical") //Высотой: 32 пикселя
			canBeHatted = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = 4
		if("droid-miner", "mk2", "mk3") //Высотой: 32 большая голова, шарообразные
			canBeHatted = TRUE
			isCentered = TRUE
			hat_offset_y = 3
		if("bloodhound", "nano_bloodhound", "syndie_bloodhound", "ertgamma")//Высотой: 31
			canBeHatted = TRUE
			hat_offset_y = 1
		if("Cricket-SEC", "Cricket-MEDI", "Cricket-JANI", "Cricket-ENGI", "Cricket-MINE", "Cricket-SERV") //Высотой: 31
			canBeHatted = TRUE
			hat_offset_y = 2
		if("droidcombat-shield", "droidcombat") //Высотой: 31
			canBeHatted = TRUE
			hat_alpha = 255
			hat_offset_y = 2
		if("droidcombat-roll")
			canBeHatted = TRUE
			hat_alpha = 0
			hat_offset_y = 2
		if("syndi-medi", "surgeon", "chiefbot", "toiletbot") //Высотой: 30
			canBeHatted = TRUE
			isCentered = TRUE
			hat_offset_y = 1
		if("Security", "janitorrobot", "medicalrobot") //Высотой: 29
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -1
		if("Brobot", "Service", "robot+o+c", "robot_old", "securityrobot",	//Высотой: 28
			"rowtree-engineering", "rowtree-lucy", "rowtree-medical", "rowtree-security") //Бабоботы
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -1
		if("Miner", "lavaland")	//Высотой: 27
			canBeHatted = TRUE
			hat_offset_y = -1
		if("robot", "Standard", "Standard-Secy", "Standard-Medi", "Standard-Engi",
			"Standard-Jani", "Standard-Serv", "Standard-Mine", "xenoborg-state-a") //Высотой: 26
			canBeHatted = TRUE
			hat_offset_y = -3
		if("droid")	//Высотой: 25
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -3
		if("landmate", "chiefmate", "syndi-engi") //Высотой: 24 пикселя макушка
			canBeHatted = TRUE
			hat_offset_y = -3
		if("mopgearrex") //Высотой: 22
			canBeHatted = TRUE
			hat_offset_y = -6

	if(inventory_head)
		if (!canBeHatted)
			remove_from_head(usr)
			return
		if (!canWearBlacklistedHats && is_type_in_list(inventory_head, blacklisted_hats))
			remove_from_head(usr)
			return


/mob/living/silicon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
		add_fingerprint(user)
		if(place_on_head(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()


/mob/living/silicon/proc/get_hat_overlay()
	if(hat_icon_file && hat_icon_state)
		var/image/borgI = image(hat_icon_file, hat_icon_state)
		borgI.alpha = hat_alpha
		borgI.color = hat_color
		borgI.pixel_y = hat_offset_y
		if (!isCentered)
			borgI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
		return borgI


/mob/living/silicon/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(!item_to_add)
		if(user)
			user.visible_message(
				span_notice("[user] похлопывает по голове [declent_ru(GENITIVE)]."),
				span_notice("Вы положили руку на голову [declent_ru(DATIVE)]."),
			)
		if(flags & HOLOGRAM)
			return FALSE
		return FALSE

	if(!istype(item_to_add, /obj/item/clothing/head))
		if(user)
			to_chat(user, span_warning("Предмет нельзя надеть на голову [declent_ru(DATIVE)]!"))
		return FALSE

	if(!canBeHatted)
		if(user)
			to_chat(user, span_warning("Предмет нельзя надеть на голову [declent_ru(DATIVE)]! Похоже у него уже есть встроенный головной убор."))
		return FALSE

	if(inventory_head)
		if(user)
			to_chat(user, span_warning("Нельзя надеть больше одного головного убора!"))
		return FALSE

	if(user && item_to_add.loc == user && !user.drop_transfer_item_to_loc(item_to_add, src))
		return FALSE

	if(!canWearBlacklistedHats && is_type_in_list(item_to_add, blacklisted_hats))
		if(user)
			to_chat(user, span_warning("Предмет не подходит для [declent_ru(GENITIVE)]!"))
		return FALSE

	if(user)
		user.visible_message(
			span_notice("[user] надевает головной убор на голову [declent_ru(DATIVE)]."),
			span_notice("Вы надеваете головной убор на голову [declent_ru(DATIVE)]."),
			span_italics("Вы слышите как что-то нацепили."),
		)
	if(item_to_add.loc != src)
		item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()
	return TRUE


/mob/living/silicon/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(HAS_TRAIT(inventory_head, TRAIT_NODROP))
			to_chat(user, "<span class='warning'>[inventory_head.name] застрял на голове [src]! Его невозможно снять!</span>")
			return TRUE

		to_chat(user, "<span class='warning'>Вы сняли [inventory_head.name] с головы [src].</span>")
		user.put_in_hands(inventory_head)

		null_hat()

		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>На голове [src] нет головного убора!</span>")
		return FALSE

	return TRUE


/mob/living/silicon/proc/drop_hat(drop_on_turf = FALSE)
	if(inventory_head)
		if(drop_on_turf)
			transfer_item_to_loc(inventory_head, get_turf(src))
		else
			drop_item_ground(inventory_head)
		null_hat()
		regenerate_icons()


/mob/living/silicon/proc/null_hat()
	inventory_head = null
	hat_icon_file = null
	hat_icon_state = null
	hat_alpha = null
	hat_color = null

