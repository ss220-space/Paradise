/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	desc = "Это защищённый шкафчик для персонала. Первая проведённая ID-карта получает доступ."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/get_ru_names()
    return list(
        NOMINATIVE = "личный шкафчик",
        GENITIVE = "личного шкафчика",
        DATIVE = "личному шкафчику",
        ACCUSATIVE = "личный шкафчик",
        INSTRUMENTAL = "личным шкафчиком",
        PREPOSITIONAL = "личном шкафчике",
    )

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

/obj/structure/closet/secure_closet/personal/patient/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик пациента",
        GENITIVE = "шкафчика пациента",
        DATIVE = "шкафчику пациента",
        ACCUSATIVE = "шкафчик пациента",
        INSTRUMENTAL = "шкафчиком пациента",
        PREPOSITIONAL = "шкафчике пациента",
    )

/obj/structure/closet/secure_closet/personal/patient/populate_contents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/color/white(src)

/obj/structure/closet/secure_closet/personal/mining
	name = "personal miner's locker"
	icon_state = "mine_pers"

/obj/structure/closet/secure_closet/personal/mining/get_ru_names()
    return list(
        NOMINATIVE = "личный шкафчик шахтера",
        GENITIVE = "личного шкафчика шахтера",
        DATIVE = "личному шкафчику шахтера",
        ACCUSATIVE = "личный шкафчик шахтера",
        INSTRUMENTAL = "личным шкафчиком шахтера",
        PREPOSITIONAL = "личном шкафчике шахтера",
    )

/obj/structure/closet/secure_closet/personal/mining/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/personal/cabinet
	name = "personal cabinet"
	desc = "It's a secure cabinet for personnel. The first card swiped gains control."
	desc = "Это защищённый шкаф для персонала. Первая проведённая ID-карта получает доступ."
	icon_state = "cabinet"
	overlay_sparking = "c_sparking"
	overlay_locked = "c_locked"
	overlay_unlocked = "c_unlocked"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25

/obj/structure/closet/secure_closet/personal/cabinet/get_ru_names()
    return list(
        NOMINATIVE = "личный шкаф",
        GENITIVE = "личного шкафа",
        DATIVE = "личному шкафу",
        ACCUSATIVE = "личный шкаф",
        INSTRUMENTAL = "личным шкафом",
        PREPOSITIONAL = "личном шкафе",
    )

/obj/structure/closet/secure_closet/personal/cabinet/populate_contents()
	new /obj/item/storage/backpack/satchel/withwallet(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/personal/update_desc(updates = ALL)
	. = ..()
	desc = registered_name ? "Owned by [registered_name]." : initial(desc)
	desc = registered_name ? "Принадлежит [registered_name]." : initial(desc)

/obj/structure/closet/secure_closet/personal/attackby(obj/item/I, mob/user, params)
	if(opened)
		return ..()

	var/obj/item/card/id/id = I.GetID()
	if(!id)
		return ..()

	add_fingerprint(user)

	if(istype(id, /obj/item/card/id/guest))
		to_chat(user, span_warning("Невозможно открыть временным пропуском."))
		return ATTACK_CHAIN_PROCEED
	if(broken)
		to_chat(user, span_warning("Похоже, замок сломан."))
		return ATTACK_CHAIN_PROCEED
	if(!id.registered_name)
		to_chat(user, span_warning("Невозможно открыть пустой ID-картой."))
		return ATTACK_CHAIN_PROCEED
	if(src == user.loc)
		to_chat(user, span_notice("Вы не можете разблокировать замок изнутри."))
		return ATTACK_CHAIN_PROCEED
	//they can open all lockers, or nobody owns this, or they own this locker
	if(!allowed(user) && registered_name && registered_name != id.registered_name)
		to_chat(user, span_warning("Доступ запрещен."))
		return ATTACK_CHAIN_PROCEED
	locked = !locked
	if(locked)
		if(!registered_name)
			registered_name = id.registered_name
	else
		registered_name = null
	update_appearance(UPDATE_ICON|UPDATE_DESC)

	return ATTACK_CHAIN_PROCEED_SUCCESS
