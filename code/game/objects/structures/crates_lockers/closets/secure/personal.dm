/obj/structure/closet/secure_closet/personal
	name = "personal closet"
	desc = "Защищённый металлический шкафчик, предназначенный для хранения различных предметов. \
			Оснащён электронным замком. Первое использование ID-карты авторизует владельца."
	ru_names = list(
		NOMINATIVE = "личный шкафчик",
		GENITIVE = "личного шкафчика",
		DATIVE = "личному шкафчику",
		ACCUSATIVE = "личный шкафчик",
		INSTRUMENTAL = "личным шкафчиком",
		PREPOSITIONAL = "личном шкафчике"
	)
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/duffel(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel_norm(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"
	ru_names = list(
		NOMINATIVE = "личный шкафчик пациента",
		GENITIVE = "личного шкафчика пациента",
		DATIVE = "личному шкафчику пациента",
		ACCUSATIVE = "личный шкафчик пациента",
		INSTRUMENTAL = "личным шкафчиком пациента",
		PREPOSITIONAL = "личном шкафчике пациента"
	)

/obj/structure/closet/secure_closet/personal/patient/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/secure_closet/personal/mining
	name = "personal miner's locker"
	ru_names = list(
		NOMINATIVE = "личный шкафчик Шахтёра",
		GENITIVE = "личного шкафчика Шахтёра",
		DATIVE = "личному шкафчику Шахтёра",
		ACCUSATIVE = "личный шкафчик Шахтёра",
		INSTRUMENTAL = "личным шкафчиком Шахтёра",
		PREPOSITIONAL = "личном шкафчике Шахтёра"
	)
	icon_state = "mine_pers"

/obj/structure/closet/secure_closet/personal/mining/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/personal/cabinet
	name = "personal cabinet"
	desc = "Деревянный шкаф, оборудованный электронным замком. Первое использование ID-карты авторизует владельца. \
			Такие всегда будут в моде."
	ru_names = list(
		NOMINATIVE = "личный шкаф",
		GENITIVE = "личного шкафа",
		DATIVE = "личному шкафу",
		ACCUSATIVE = "личный шкаф",
		INSTRUMENTAL = "личным шкафом",
		PREPOSITIONAL = "личном шкафе"
	)
	icon_state = "cabinet"
	overlay_sparking = "c_sparking"
	overlay_locked = "c_locked"
	overlay_locker = "c_locker"
	overlay_unlocked = "c_unlocked"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50


/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet(src)
	new /obj/item/radio/headset(src)


/obj/structure/closet/secure_closet/personal/examine(mob/user)
	. = ..()
	if(registered_name)
		. += span_boldnotice("Авторизованный владелец – [registered_name].")

/obj/structure/closet/secure_closet/personal/attackby(obj/item/I, mob/user, params)
	if(opened)
		return ..()

	var/obj/item/card/id/id = I.GetID()
	if(id)
		add_fingerprint(user)
		if(broken)
			user.balloon_alert("сломано!")
			return ATTACK_CHAIN_PROCEED
		if(!id.registered_name)
			user.balloon_alert("ID-карт без имени!")
			return ATTACK_CHAIN_PROCEED
		if(src == user.loc)
			user.balloon_alert(user, "изнутри не достать!")
			return ATTACK_CHAIN_PROCEED
		//they can open all lockers, or nobody owns this, or they own this locker
		if(!allowed(user) && registered_name && registered_name != id.registered_name)
			user.balloon_alert(user, "отказано в доступе!")
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		if(locked)
			if(!registered_name)
				registered_name = id.registered_name
		else
			registered_name = null
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

