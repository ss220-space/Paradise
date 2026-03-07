#define DATA_NOT_SPECIFIED "НЕ ЗАДАНО"

/**
 * ID-card base object
 */

/obj/item/card
	name = "card"
	desc = "Пластиковая карточка."
	gender = FEMALE
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY
	drop_sound = 'sound/items/handling/drop/card_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/card_pickup.ogg'
	lefthand_file = 'icons/mob/inhands/id_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/id_righthand.dmi'
	var/associated_account_number = 0
	var/list/files = list()

/obj/item/card/id
	name = "identification card"
	desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	icon_state = "id"
	item_state = "card-id"
	slot_flags = ITEM_SLOT_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// For redeeming at mining equipment lockers
	var/mining_points = 0
	/// Total mining points earned on the current Shift.
	var/total_mining_points = 0
	var/list/access = list()
	var/law_level = LAW_LEVEL_BASE
	/// The name, registered on the card
	var/registered_name = UNKNOWN_NAME_RUS
	var/untrackable // Can not be tracked by AI's

	var/blood_type = "\[НЕ ЗАДАНО\]"
	var/dna_hash = "\[НЕ ЗАДАНО\]"
	var/fingerprint_hash = "\[НЕ ЗАДАНО\]"

	/// The name of the assigned job by default, but can be changed freely
	var/assignment = null
	/// The actual name of the job. Shouldn't be changed
	var/rank = null
	var/owner_uid
	var/owner_ckey
	var/lastlog
	/// Determines if this ID claims a dorm or not
	var/dorm = 0

	var/sex
	var/age
	var/photo
	var/dat
	var/stamped = 0
	var/registered = FALSE

	/// RoboQuest shit
	var/datum/roboquest/robo_bounty
	var/bounty_penalty

	/// Guest pass attached to the ID
	var/obj/item/card/id/guest/guest_pass = null

/obj/item/card/id/get_ru_names()
	return list(
		NOMINATIVE = "ID-карта",
		GENITIVE = "ID-карты",
		DATIVE = "ID-карте",
		ACCUSATIVE = "ID-карту",
		INSTRUMENTAL = "ID-картой",
		PREPOSITIONAL = "ID-карте",
	)

/obj/item/card/id/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FREEZE_LINKED_ACCOUNT, PROC_REF(freeze_linked_account))
	addtimer(CALLBACK(src, PROC_REF(set_info)), 3 SECONDS)

/obj/item/card/id/Destroy()
	UnregisterSignal(src, COMSIG_FREEZE_LINKED_ACCOUNT)
	. = ..()

/obj/item/card/id/proc/set_info()
	if(ishuman(loc) && blood_type == "\[[DATA_NOT_SPECIFIED]\]")
		var/mob/living/carbon/human/human = loc
		SetOwnerInfo(human)

/obj/item/card/id/proc/freeze_linked_account(datum/source)
	SIGNAL_HANDLER

	var/datum/money_account/acc = get_money_account(associated_account_number)

	if(!acc)
		return

	acc.suspended = TRUE

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		show(usr)
	else
		. += span_warning("Слишком далеко.")
	if(guest_pass)
		. += span_notice("К карте прикреплён гостевой пропуск.")
		if(world.time < guest_pass.expiration_time)
			. += span_notice("Он истекает в [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)].")
		else
			. += span_warning("Истёк [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)].")
		. += span_notice("Даёт следующий доступ:")
		for(var/A in guest_pass.temp_access)
			. += span_notice("[get_access_desc(A)].")
		. += span_notice("Причина выдачи: [guest_pass.reason].")
	if(mining_points)
		. += span_notice("Шахтёрских очков на аккаунте: <b>[mining_points]</b>. Всего заработано за смену: <b>[total_mining_points]</b>смену.")

/obj/item/card/id/proc/show(mob/user as mob)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/datum/browser/popup = new(user, "idcard", DECLENT_RU_CAP(src, NOMINATIVE), 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message(
		span_notice("[user.declent_ru(NOMINATIVE)] показыва[PLUR_ET_YUT(user)] [icon2html(src, viewers(user))] [declent_ru(ACCUSATIVE)]. Указанная должность: [assignment]."),
		span_notice("Вы показываете [icon2html(src, viewers(user))] [declent_ru(ACCUSATIVE)]. Указанная должность: [assignment]."),
	)
	if(mining_points)
		to_chat(user, "Шахтёрских очков на аккаунте: <b>[mining_points]</b>. Всего заработано за смену: <b>[total_mining_points]</b>смену.")
	add_fingerprint(user)
	return

/obj/item/card/id/proc/SetOwnerInfo(mob/living/carbon/human/H)
	if(!H || !H.dna)
		return

	sex = H.gender == MALE ? "Мужской" : "Женский"
	age = H.age
	blood_type = H.dna.blood_type
	dna_hash = H.dna.unique_enzymes
	fingerprint_hash = md5(H.dna.uni_identity)

	RebuildHTML()

/// Rebuilds the HTML content for the ID card.
/obj/item/card/id/proc/RebuildHTML()
	var/photo_front = "'data:image/png;base64,[icon2base64(icon(photo, dir = SOUTH))]'"
	var/photo_side = "'data:image/png;base64,[icon2base64(icon(photo, dir = WEST))]'"

	dat = {"<table><tr><td>
	Имя: [registered_name]</a><br>
	Пол: [sex]</a><br>
	Возраст: [age]</a><br>
	Должность: [assignment]</a><br>
	Отпечатки пальцев: [fingerprint_hash]</a><br>
	Группа крови: [blood_type]<br>
	ДНК-хеш: [dna_hash]<br><br>
	<td align = center valign = top>Фото:<br><img src=[photo_front] height=80 width=80 border=4>
	<img src=[photo_side] height=80 width=80 border=4></td></tr></table>"}

/// Returns the access list for this ID card.
/obj/item/card/id/GetAccess()
	if(!guest_pass)
		return access
	return access | guest_pass.GetAccess()

/// Returns the ID card object itself.
/obj/item/card/id/GetID()
	return src

/// Returns the rank and assignment string for this ID card.
/obj/item/card/id/proc/getRankAndAssignment()
	var/jobnamedata = ""
	if(rank)
		jobnamedata += get_job_title_ru(rank)
	if(rank != get_job_title_ru(assignment))
		jobnamedata += " (" + get_job_title_ru(assignment) + ")"
	return jobnamedata

/// Returns the player mob associated with this ID card.
/obj/item/card/id/proc/getPlayer()
	if(owner_uid)
		var/mob/living/carbon/human/H = locateUID(owner_uid)
		if(istype(H) && H.ckey == owner_ckey)
			return H
		owner_uid = null
	if(owner_ckey)
		for(var/mob/M in GLOB.player_list)
			if(M.ckey && M.ckey == owner_ckey)
				owner_uid = M.UID()
				return M
		owner_ckey = null

/// Returns the ckey of the player mob associated with this ID card.
/obj/item/card/id/proc/getPlayerCkey()
	var/mob/living/carbon/human/H = getPlayer()
	if(istype(H))
		return H.ckey

/// Returns whether this ID card is untrackable by AIs.
/obj/item/card/id/proc/is_untrackable()
	return untrackable

/**
 * Updates the `name` and `ru_names` of the ID card.
 * Takes optional newname and newjob parameters to set custom values.
 */
/obj/item/card/id/proc/update_label(newname, newjob)
	var/list/names = get_ru_names_cached()
	ru_names = names ? names.Copy() : new /list(6)

	if(!newname)
		newname = registered_name
	if(!newjob)
		newjob = assignment

	name = "[newname ? "[newname]`s ID-card" : "identification card"][newjob ? " ([newjob])" : ""]"
	for(var/i = 1; i <= 6; i++)
		ru_names[i] = "[names ? names[i] : initial(name)][newname ? " \"[newname]\"" : ""][newjob ? " ([newjob])" : ""]"

/obj/item/card/id/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/id_decal))
		add_fingerprint(user)
		var/obj/item/id_decal/decal = I
		if(!user.drop_transfer_item_to_loc(decal, src))
			return ..()
		balloon_alert(user, "наклейка приклеена")
		desc = decal.decal_desc
		icon_state = decal.decal_icon_state
		item_state = decal.decal_item_state
		qdel(decal)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stamp))
		add_fingerprint(user)
		if(stamped)
			balloon_alert(user, "печать уже поставлена!")
			return ATTACK_CHAIN_PROCEED
		dat += "<img src=large_[I.icon_state].png>"
		stamped = TRUE
		balloon_alert(user, "печать поставлена")
		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/card/id/guest))
		add_fingerprint(user)
		if(istype(src, /obj/item/card/id/guest))
			balloon_alert(user, "это бессмысленно!")
			return ATTACK_CHAIN_PROCEED
		if(guest_pass)
			balloon_alert(user, "гостевой пропуск уже прикреплён!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/card/id/guest/guest_id = I
		if(world.time > guest_id.expiration_time)
			balloon_alert(user, "гостевой пропуск уже истёк!")
			return ATTACK_CHAIN_PROCEED
		if(guest_id.registered_name != registered_name && guest_id.registered_name != DATA_NOT_SPECIFIED)
			balloon_alert(user, "несовместимая ID-карта!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(guest_id, src))
			return ..()
		guest_pass = guest_id
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/card/id/verb/remove_guest_pass()
	set name = "Убрать гостевой пропуск"
	set category = VERB_CATEGORY_OBJECT
	set src in range(0)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(guest_pass)
		balloon_alert(usr, "гостевой пропуск снят")
		guest_pass.forceMove(get_turf(src))
		guest_pass = null
	else
		balloon_alert(usr, "гостевой пропуск отсутствует!")

/obj/item/card/id/serialize()
	var/list/data = ..()

	data["sex"] = sex
	data["age"] = age
	data["btype"] = blood_type
	data["dna_hash"] = dna_hash
	data["fprint_hash"] = fingerprint_hash
	data["access"] = access
	data["job"] = assignment
	data["rank"] = rank
	data["account"] = associated_account_number
	data["owner"] = registered_name
	data["mining"] = mining_points
	data["total_mining"] = total_mining_points
	return data

/obj/item/card/id/deserialize(list/data)
	sex = data["sex"]
	age = data["age"]
	blood_type = data["btype"]
	dna_hash = data["dna_hash"]
	fingerprint_hash = data["fprint_hash"]
	access = data["access"] // No need for a copy, the list isn't getting touched
	assignment = data["job"]
	rank = data["rank"]
	associated_account_number = data["account"]
	registered_name = data["owner"]
	mining_points = data["mining"]
	total_mining_points = data["total_mining"]
	// We'd need to use icon serialization(b64) to save the photo, and I don't feel like i
	update_label()
	RebuildHTML()
	..()

#undef DATA_NOT_SPECIFIED
