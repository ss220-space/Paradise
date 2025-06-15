/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/card
	name = "card"
	desc = "A card."
	gender = MALE
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY
	pickup_sound = 'sound/items/handling/card_pickup.ogg'
	drop_sound = 'sound/items/handling/card_drop.ogg'
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/card/data
	name = "data card"
	desc = "A disk containing data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"


/obj/item/card/data/clown
	name = "coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */

/obj/item/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=1"

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=3"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION


/obj/item/card/emag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/card/emag/afterattack(atom/target, mob/user, proximity, params)
	var/atom/A = target
	if(!proximity)
		return
	A.emag_act(user)

/obj/item/card/cmag
	desc = "Это карта, покрытая жидкостью из электромагнитного бананиума."
	name = "jestographic sequencer"
	ru_names = list(
		NOMINATIVE = "шутографический считыватель",
		GENITIVE = "шутографического считывателя",
		DATIVE = "шутографическому считывателю",
		ACCUSATIVE = "шутографический считыватель",
		INSTRUMENTAL = "шутографическим считывателем",
		PREPOSITIONAL = "шутографическом считывателе"
	)
	icon_state = "cmag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	item_flags = NOBLUDGEON|NO_MAT_REDEMPTION


/obj/item/card/cmag/ComponentInitialize()
	AddComponent(/datum/component/slippery, 4 SECONDS, lube_flags = (SLIDE|SLIP_WHEN_LYING))


/obj/item/card/cmag/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, cmag_act), user)


/obj/item/card/id
	name = "identification card"
	desc = "Карта, используемая для удостоверения личности и определения доступа владельца на станции."
	ru_names = list(
            NOMINATIVE = "идентификационная карта",
            GENITIVE = "идентификационной карты",
            DATIVE = "идентификационной карте",
            ACCUSATIVE = "идентификационную карту",
            INSTRUMENTAL = "идентификационной картой",
            PREPOSITIONAL = "идентификационной карте"
        )
	icon_state = "id"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/id_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/id_righthand.dmi'
	/// For redeeming at mining equipment lockers
	var/mining_points = 0
	/// Total mining points for the Shift.
	var/total_mining_points = 0
	var/list/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = ITEM_SLOT_ID
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/untrackable // Can not be tracked by AI's

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/owner_uid
	var/owner_ckey
	var/lastlog
	var/dorm = 0			// determines if this ID has claimed a dorm already

	var/sex
	var/age
	var/photo
	var/dat
	var/stamped = 0
	var/registered = FALSE

	/// RoboQuest shit
	var/datum/roboquest/robo_bounty
	var/bounty_penalty

	var/obj/item/card/id/guest/guest_pass = null // Guest pass attached to the ID

/obj/item/card/id/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FREEZE_LINKED_ACCOUNT, PROC_REF(freeze_linked_account))
	spawn(30)
		if(ishuman(loc) && blood_type == "\[UNSET\]")
			var/mob/living/carbon/human/H = loc
			SetOwnerInfo(H)

/obj/item/card/id/Destroy()
	UnregisterSignal(src, COMSIG_FREEZE_LINKED_ACCOUNT)
	. = ..()

/obj/item/card/id/proc/freeze_linked_account(datum/source)
	SIGNAL_HANDLER
	var/datum/money_account/acc = get_money_account(associated_account_number)
	acc.suspended = TRUE

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		show(usr)
	else
		. += to_chat(user, span_warning("Слишком далеко чтобы разглядеть"))
	if(guest_pass)
		. += to_chat(user, span_notice("К этой ID-карте прикреплён гостевой пропуск"))
		if(world.time < guest_pass.expiration_time)
			. += to_chat(user, span_notice("Срок действия истекает в [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)]"))
		else
			. += to_chat(user, span_warning("Срок действия истекает в [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)]"))
		. += to_chat(user, span_notice("Даёт доступ к следующим местам:"))
		for(var/A in guest_pass.temp_access)
			. += to_chat(user, span_notice("[get_access_desc(A)]."))
		. += to_chat(user, span_notice("Причина создания: [guest_pass.reason]."))

/obj/item/card/id/proc/show(mob/user as mob)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/datum/browser/popup = new(user, "idcard", name, 600, 400)
	popup.set_content(dat)
	popup.open()

/obj/item/card/id/attack_self(mob/user as mob)
	name = "[src.registered_name] ID-карта ([src.assignment])"
	user.visible_message("[user] показывает вам: [bicon(src)] [src.name]. Должность: [src.assignment]",\
		"Вы показываете свою ID-карту: [bicon(src)] [src.name]. Должность: [src.assignment]")
	if(mining_points)
		to_chat(user, "На этой карте загружено <b>[mining_points] очков добычи</b>. Эта карта заработала <b>[total_mining_points] очков добычи</b> за смену!")
	src.add_fingerprint(user)
	return

/obj/item/card/id/proc/UpdateName()
	name = "[src.registered_name] ID-карта ([src.assignment])"

/obj/item/card/id/proc/SetOwnerInfo(var/mob/living/carbon/human/H)
	if(!H || !H.dna)
		return

	sex = capitalize(H.gender)
	age = H.age
	blood_type = H.dna.blood_type
	dna_hash = H.dna.unique_enzymes
	fingerprint_hash = md5(H.dna.uni_identity)

	RebuildHTML()

/obj/item/card/id/proc/RebuildHTML()
	var/photo_front = "'data:image/png;base64,[icon2base64(icon(photo, dir = SOUTH))]'"
	var/photo_side = "'data:image/png;base64,[icon2base64(icon(photo, dir = WEST))]'"

	dat = {"<table><tr><td>
	Имя: [registered_name]</a><br>
	Пол: [sex]</a><br>
	Возраст: [age]</a><br>
	Должность: [assignment]</a><br>
	Хэш отпечатков пальцев: [fingerprint_hash]</a><br>
	Группа крови: [blood_type]<br>
	Хэш ДНК: [dna_hash]<br><br>
	<td align = center valign = top>Фото:<br><img src=[photo_front] height=80 width=80 border=4>
	<img src=[photo_side] height=80 width=80 border=4></td></tr></table>"}

/obj/item/card/id/GetAccess()
	if(!guest_pass)
		return access
	return access | guest_pass.GetAccess()

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/proc/getRankAndAssignment()
	var/jobnamedata = ""
	if(rank)
		jobnamedata += rank
	if(rank != assignment)
		jobnamedata += " (" + assignment + ")"
	return jobnamedata

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

/obj/item/card/id/proc/getPlayerCkey()
	var/mob/living/carbon/human/H = getPlayer()
	if(istype(H))
		return H.ckey

/obj/item/card/id/proc/is_untrackable()
	return untrackable

/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname] ID-карта"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name] ID-карта"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/id_decal))
		add_fingerprint(user)
		var/obj/item/id_decal/decal = I
		if(!user.drop_transfer_item_to_loc(decal, src))
			return ..()
		to_chat(user, span_notice("Вы наклеили [decal] на [src]."))
		if(decal.override_name)
			name = decal.decal_name
		desc = decal.decal_desc
		icon_state = decal.decal_icon_state	// LATER .\_/.
		item_state = decal.decal_item_state
		qdel(decal)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stamp))
		add_fingerprint(user)
		if(stamped)
			to_chat(user, span_warning("На этой ID-карте уже стоит печать."))
			return ATTACK_CHAIN_PROCEED
		dat += "<img src=large_[I.icon_state].png>"
		stamped = TRUE
		to_chat(user, span_notice("Вы поставили печать на ID-карту!"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/card/id/guest))
		add_fingerprint(user)
		if(istype(src, /obj/item/card/id/guest))
			to_chat(user, span_warning("Применение одной гостевой карты к другой ничего не дает."))
			return ATTACK_CHAIN_PROCEED
		if(guest_pass)
			to_chat(user, span_warning("К этой ID-карте уже прикреплён какой-то гостевой пропуск."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/card/id/guest/guest_id = I
		if(world.time > guest_id.expiration_time)
			to_chat(user, span_warning("Срок действия гостевой карты истек."))
			return ATTACK_CHAIN_PROCEED
		if(guest_id.registered_name != registered_name && guest_id.registered_name != "NOT SPECIFIED")
			to_chat(user, span_warning("Гостевой пропуск не может быть прикреплён к этой ID-карте."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(guest_id, src))
			return ..()
		guest_pass = guest_id
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/card/id/verb/remove_guest_pass()
	set name = "Remove Guest Pass"
	set category = "Object"
	set src in range(0)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(guest_pass)
		to_chat(usr, span_notice("Вы удалили гостевую карту, связанную с этой ID-картой."))
		guest_pass.forceMove(get_turf(src))
		guest_pass = null
	else
		to_chat(usr, span_warning(">К этой ID-карте уже прикреплён какой-то гостевой пропуск."))

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
	UpdateName()
	RebuildHTML()
	..()

/obj/item/card/id/silver
	name = "identification card"
	desc = "Серебряная карта, символизирующая честь и преданность."
	icon_state = "silver"
	item_state = "silver-id"

/obj/item/card/id/gold
	name = "identification card"
	desc = "Золотая карта, символизирующая силу и мощь."
	icon_state = "gold"
	item_state = "gold-id"

/obj/item/card/id/syndicate
	name = "agent card"
	var/list/initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	origin_tech = "syndicate=1"
	var/mob/living/carbon/human/registered_user = null
	untrackable = 1
	var/anyone = FALSE //Can anyone forge the ID or just syndicate?
	var/list/save_slots = list()
	var/num_of_save_slots = 3
	var/list/appearances = list(
							"data",
							"id",
							"gold",
							"silver",
							"centcom",
							"centcom_old",
							"security",
							"medical",
							"HoS",
							"research",
							"cargo",
							"engineering",
							"CMO",
							"RD",
							"CE",
							"clown",
							"mime",
							"rainbow",
							"prisoner",
							"commander",
							"syndie",
							"syndierd",
							"syndiebotany",
							"syndiecargo",
							"syndiernd",
							"syndieengineer",
							"syndiechef",
							"syndiemedical",
							"deathsquad",
							"ERT_leader",
							"ERT_security",
							"ERT_engineering",
							"ERT_medical",
							"ERT_janitorial",
							"mining_medic",
						)

/obj/item/card/id/syndicate/anyone
	anyone = TRUE

/obj/item/card/id/syndicate/Initialize(mapload)
	access = initial_access.Copy()
	. = ..()
	save_slots.len = num_of_save_slots
	for(var/i = 1 to num_of_save_slots)
		save_slots[i] = list()


/obj/item/card/id/syndicate/vox
	name = "agent card"
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_VOX, ACCESS_EXTERNAL_AIRLOCKS)

// Added all syndicate 'Taipan' access to the admin officer
/obj/item/card/id/syndicate/command
	initial_access = list(	ACCESS_MAINT_TUNNELS,
							ACCESS_SYNDICATE,
							ACCESS_SYNDICATE_LEADER,
							ACCESS_SYNDICATE_COMMAND,
							ACCESS_SYNDICATE_COMMS_OFFICER,
							ACCESS_SYNDICATE_RESEARCH_DIRECTOR,
							ACCESS_EXTERNAL_AIRLOCKS,
							ACCESS_SYNDICATE_SCIENTIST,
							ACCESS_SYNDICATE_CARGO,
							ACCESS_SYNDICATE_KITCHEN,
							ACCESS_SYNDICATE_MEDICAL,
							ACCESS_SYNDICATE_BOTANY,
							ACCESS_SYNDICATE_ENGINE)
	icon_state = "commander"
	item_state = "syndieofficer-id"

//Syndicate 'Taipan' access cards

/obj/item/card/id/syndicate/scientist
	icon_state = "syndiernd"
	item_state = "syndiernd-id"
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_SCIENTIST, ACCESS_SYNDICATE_MEDICAL)
	rank = "Syndicate Scientist"

/obj/item/card/id/syndicate/cargo
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_CARGO)
	icon_state = "syndiecargo"
	item_state = "syndiecargo-id"
	rank = "Syndicate Cargo Technician"

/obj/item/card/id/syndicate/kitchen
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_KITCHEN, ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndiechef"
	item_state = "syndiechef-id"
	rank = "Syndicate Chef"

/obj/item/card/id/syndicate/engineer
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_ENGINE)
	icon_state = "syndieengineer"
	item_state = "syndieengineer-id"
	rank = "Syndicate Atmos Engineer"

/obj/item/card/id/syndicate/medic
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_MEDICAL)
	icon_state = "syndiemedical"
	item_state = "syndiemedical-id"
	rank = "Syndicate Medic"

/obj/item/card/id/syndicate/botanist
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndiebotany"
	item_state = "syndiebotany-id"
	rank = "Syndicate Botanist"

/obj/item/card/id/syndicate/comms_officer
	initial_access = list(	ACCESS_MAINT_TUNNELS,
							ACCESS_SYNDICATE,
							ACCESS_SYNDICATE_COMMS_OFFICER,
							ACCESS_EXTERNAL_AIRLOCKS,
							ACCESS_SYNDICATE_SCIENTIST,
							ACCESS_SYNDICATE_CARGO,
							ACCESS_SYNDICATE_KITCHEN,
							ACCESS_SYNDICATE_ENGINE,
							ACCESS_SYNDICATE_MEDICAL,
							ACCESS_SYNDICATE_BOTANY,
							ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
	icon_state = "commander"
	item_state = "syndieofficer-id"
	rank = "Syndicate Comms Officer"

/obj/item/card/id/syndicate/research_director
	initial_access = list(	ACCESS_MAINT_TUNNELS,
							ACCESS_SYNDICATE,
							ACCESS_EXTERNAL_AIRLOCKS,
							ACCESS_SYNDICATE_SCIENTIST,
							ACCESS_SYNDICATE_CARGO,
							ACCESS_SYNDICATE_KITCHEN,
							ACCESS_SYNDICATE_ENGINE,
							ACCESS_SYNDICATE_MEDICAL,
							ACCESS_SYNDICATE_BOTANY,
							ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
	icon_state = "syndierd"
	item_state = "syndierd-id"
	rank = "Syndicate Research Director"

/obj/item/card/id/syndicate/afterattack(obj/item/O, mob/user, proximity, params)
	if(!proximity || !istype(O))
		return
	if(O.GetID())
		var/obj/item/card/id/I = O.GetID()
		if(isliving(user) && user.mind)
			if(user.mind.special_role || anyone)
				to_chat(usr, span_notice("Микросканеры карты активируются, когда вы проводите её над [I], копируя доступ."))
				src.access |= I.access //Don't copy access if user isn't an antag -- to prevent metagaming

/obj/item/card/id/syndicate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!registered_user)
		return
	. = TRUE
	switch(action)
		if("delete_info")
			var/response = tgui_alert(registered_user, "Вы уверены, что хотите удалить всю информацию, сохраненную на карте?", "Удалить информацию с карты", list("Нет", "Да"))
			if(response == "Да")
				name = initial(name)
				registered_name = initial(registered_name)
				icon_state = initial(icon_state)
				sex = initial(sex)
				age = initial(age)
				assignment = initial(assignment)
				associated_account_number = initial(associated_account_number)
				blood_type = initial(blood_type)
				dna_hash = initial(dna_hash)
				fingerprint_hash = initial(fingerprint_hash)
				photo = null
				registered_user = null
		if("save_slot")
			save_slot(params["slot"])
			to_chat(registered_user, span_notice("Вы успешно сохранили данные карты в слот [params["slot"]]."))
		if("load_slot")
			load_slot(params["slot"])
			UpdateName()
			registered_user.sec_hud_set_ID()
			to_chat(registered_user, span_notice("Вы успешно загрузили данные карты из слота [params["slot"]]."))
		if("clear_slot")
			clear_slot(params["slot"])
			to_chat(registered_user, span_notice("Вы успешно очистили слот [params["slot"]]."))
		if("clear_access")
			var/response = tgui_alert(registered_user, "Вы уверены, что хотите сбросить доступ, сохраненный на карте?", "Сброс доступа", list("Нет", "Да"))
			if(response == "Да")
				access = initial_access.Copy() // Initial() doesn't work on lists
				to_chat(registered_user, span_notice("Доступ карты сброшен."))
		if("change_ai_tracking")
			untrackable = !untrackable
			to_chat(registered_user, span_notice("Эта ID-карта теперь [untrackable ? "неотслеживаемая" : "отслеживаемая"] ИИ."))
		if("change_name")
			var/new_name = reject_bad_name(tgui_input_text(registered_user, "Какое имя вы хотите использовать на этой карте?", "Имя агентской карты", ishuman(registered_user) ? registered_user.real_name : registered_user.name), TRUE)
			if(!Adjacent(registered_user) || isnull(new_name))
				return
			registered_name = new_name
			UpdateName()
			to_chat(registered_user, span_notice("Имя изменено на [new_name]."))
		if("change_photo")
			if(!Adjacent(registered_user))
				return
			var/job_clothes = null
			if(assignment)
				job_clothes = assignment
			var/icon/newphoto = get_id_photo(registered_user, job_clothes)
			if(!newphoto)
				return
			photo = newphoto
			to_chat(registered_user, span_notice("Фото изменено. Выберите другую профессию и сделайте новое фото, если хотите сменить одежду."))
		if("change_appearance")
			var/choice = tgui_input_list(registered_user, "Выберите внешний вид для этой карты.", "Внешний вид агентской карты", appearances)
			if(!Adjacent(registered_user))
				return
			if(!choice)
				return
			icon_state = choice
			switch(choice)
				if("silver")
					desc = "Серебряная карта, символизирующая честь и преданность."
				if("gold")
					desc = "Золотая карта, символизирующая силу и мощь."
				if("clown")
					desc = "Взгляд на эту карту вызывает у вас глубокий страх."
				if("mime")
					desc = "..."
				if("prisoner")
					desc = "Вы не свободны. Вы - просто номер."
				if("centcom")
					desc = "ID-карта Центрального Командования."
				else
					desc = "Карта, используемая для удостоверения личности и определения доступа владельца на станции."
			to_chat(usr, span_notice("Внешний вид изменен на [choice]."))
		if("change_appearance_new")
			var/choice = params["new_appearance"]
			icon_state = choice
			to_chat(usr, span_notice("Внешний вид изменен на [choice]."))
		if("change_sex")
			var/new_sex = tgui_input_text(registered_user,"Какой пол вы хотите указать на этой карте?", "Пол агентской карты", ishuman(registered_user) ? capitalize(registered_user.gender) : "Мужской")
			if(!Adjacent(registered_user) || isnull(new_sex))
				return
			sex = new_sex
			to_chat(registered_user, span_notice("Пол изменен на [new_sex]."))
		if("change_age")
			var/default = "21"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				default = H.age
			var/new_age = tgui_input_number(registered_user, "Какой возраст вы хотите указать на этой карте?", "Возраст агентской карты", default, 300, 17)
			if(!Adjacent(registered_user) || isnull(new_age))
				return
			age = new_age
			to_chat(registered_user, span_notice("Возраст изменен на [new_age]."))
		if("change_occupation")
			var/list/departments =list(
				"Civilian",
				"Engineering",
				"Medical",
				"Science",
				"Security",
				"Support",
				"Command",
				"Special",
				"Custom",
			)

			var/department = tgui_input_list(registered_user, "Какую должность вы хотите указать на этой карте?\nВыберите отдел или укажите название должности.\nИзменение профессии не даст и не уберет уровни доступа.", "Профессия агентской карты", departments)
			var/new_job = JOB_TITLE_CIVILIAN
			var/new_rank = JOB_TITLE_CIVILIAN

			if(department == "Custom")
				new_job = tgui_input_text(registered_user, "Выберите индивидуальное название должности:", "Профессия агентской карты", "Assistant")
				var/department_icon = tgui_input_list(registered_user, "Какую профессию вы хотите указать на этой карте (для SecHUDs)?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты", departments)
				switch(department_icon)
					if("Engineering")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.engineering_positions
					if("Medical")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.medical_positions
					if("Science")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.science_positions
					if("Security")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.security_positions
					if("Support")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.support_positions
					if("Command")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.command_positions
					if("Special")
						new_rank = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs() + get_all_special_jobs())
					if("Custom")
						new_rank = null
			else if(department != "Civilian")
				switch(department)
					if("Engineering")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.engineering_positions
					if("Medical")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.medical_positions
					if("Science")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.science_positions
					if("Security")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.security_positions
					if("Support")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.support_positions
					if("Command")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in GLOB.command_positions
					if("Special")
						new_job = input(registered_user, "Какую должность вы хотели бы видеть на этой карте?\nИзменение профессии не даст и не уберет уровни доступа.","Профессия агентской карты") in (get_all_solgov_jobs() + get_all_soviet_jobs() + get_all_centcom_jobs() + get_all_special_jobs())
				new_rank = new_job

			if(!Adjacent(registered_user) || isnull(new_job))
				return
			assignment = new_job
			rank = new_rank
			to_chat(registered_user, span_notice("Должность изменена на [new_job].<"))
			UpdateName()
			registered_user.sec_hud_set_ID()
		if("change_money_account")
			var/new_account = tgui_input_number(registered_user, "Какой номер аккаунта вы хотите привязать к этой картой?", "Номер акканта агентской карты", 12345, 9999999)
			if(!Adjacent(registered_user) || !isnull(new_account))
				return
			associated_account_number = new_account
			to_chat(registered_user, span_notice("Привязанный номер аккаунта изменен на [new_account]."))
		if("change_blood_type")
			var/default = "\[UNSET\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = H.dna.blood_type

			var/new_blood_type = tgui_input_text(registered_user, "Какую группу крови вы хотите указать на этой карте?", "Группа крови агентской карты", default)
			if(!Adjacent(registered_user) || !new_blood_type)
				return
			blood_type = new_blood_type
			to_chat(registered_user, span_notice("Группа крови изменена на [new_blood_type]."))
		if("change_dna_hash")
			var/default = "\[UNSET\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = H.dna.unique_enzymes

			var/new_dna_hash = tgui_input_text(registered_user, "Какой хэш ДНК вы хотите указать на этой карте?", "Хэш ДНК агентской карты", default)
			if(!Adjacent(registered_user) || !new_dna_hash)
				return
			dna_hash = new_dna_hash
			to_chat(registered_user, span_notice("Хэш ДНК изменён на [new_dna_hash]."))
		if("change_fingerprints")
			var/default = "\[UNSET\]"
			if(ishuman(registered_user))
				var/mob/living/carbon/human/H = registered_user
				if(H.dna)
					default = md5(H.dna.uni_identity)

			var/new_fingerprint_hash = tgui_input_text(registered_user, "Какой хэш отпечатков пальцев вы хотите указать на этой карте?", "Хэш отпечатков пальцев агентской карты", default)
			if(!Adjacent(registered_user) || !new_fingerprint_hash)
				return
			fingerprint_hash = new_fingerprint_hash
			to_chat(registered_user, span_notice("Хэш отпечатков пальцев изменён на [new_fingerprint_hash]."))
	RebuildHTML()

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["sex"] = sex
	data["age"] = age
	data["assignment"] = assignment
	data["associated_account_number"] = associated_account_number
	data["blood_type"] = blood_type
	data["dna_hash"] = dna_hash
	data["fingerprint_hash"] = fingerprint_hash
	data["photo"] = photo
	data["ai_tracking"] = untrackable
	var/list/saved_info = list()
	for(var/I = 1 to length(save_slots))
		var/list/editing_list = save_slots[I]
		saved_info.Add(list(list("id" = I, "registered_name" = editing_list["registered_name"], "assignment" = editing_list["assignment"])))
	data["saved_info"] = saved_info
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	data["id_icon"] = icon
	data["appearances"] = appearances
	return data

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AgentCard", name)
		ui.open()

/obj/item/card/id/syndicate/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!registered_user)
		registered_user = user
	if(!anyone)
		if(user != registered_user)
			return ..()
	switch(tgui_alert(user, "Вы хотите показать [src.declent_ru("ACCUSATIVE")] или редактировать её?", "Выбор", list("Показать", "Редактировать")))

		if("Показать")
			return ..()
		if("Редактировать")
			ui_interact(user)
			return

/obj/item/card/id/syndicate/proc/save_slot(number)
	number = text2num(number)
	var/list/editing_list = list()
	editing_list["registered_name"] = registered_name
	editing_list["sex"] = sex
	editing_list["age"] = age
	editing_list["rank"] = rank
	editing_list["assignment"] = assignment
	editing_list["associated_account_number"] = associated_account_number
	editing_list["blood_type"] = blood_type
	editing_list["dna_hash"] = dna_hash
	editing_list["fingerprint_hash"] = fingerprint_hash
	editing_list["photo"] = photo
	editing_list["ai_tracking"] = untrackable
	editing_list["icon_state"] = icon_state
	save_slots[number] = editing_list

/obj/item/card/id/syndicate/proc/load_slot(number)
	number = text2num(number)
	var/list/editing_list = save_slots[number]
	registered_name = editing_list["registered_name"]
	sex = editing_list["sex"]
	age = editing_list["age"]
	rank = editing_list["rank"]
	assignment = editing_list["assignment"]
	associated_account_number = editing_list["associated_account_number"]
	blood_type = editing_list["blood_type"]
	dna_hash = editing_list["dna_hash"]
	fingerprint_hash = editing_list["fingerprint_hash"]
	photo = editing_list["photo"]
	untrackable = editing_list["ai_tracking"]
	icon_state = editing_list["icon_state"]

/obj/item/card/id/syndicate/proc/clear_slot(number)
	number = text2num(number)
	save_slots[number] = list()

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "ID-карта Синдиката."
	ru_names = list(
    NOMINATIVE = "ID-карта Синдиката",
    GENITIVE = "ID-карты Синдиката",
    DATIVE = "ID-карте Синдиката",
    ACCUSATIVE = "ID-карту Синдиката",
    INSTRUMENTAL = "ID-картой Синдиката",
    PREPOSITIONAL = "ID-карте Синдиката"
)
	registered_name = "Syndicate"
	icon_state = "syndie"
	item_state = "syndieofficer-id"
	assignment = "Syndicate Overlord"
	untrackable = 1
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "Запасная ID-карта капитана."
	ru_names = list(
    NOMINATIVE = "запасная ID-карта капитана",
    GENITIVE = "запасной ID-карты капитана",
    DATIVE = "запасной ID-карте капитана",
    ACCUSATIVE = "запасную ID-карту капитана",
    INSTRUMENTAL = "запасной ID-картой капитана",
    PREPOSITIONAL = "запасной ID-карте капитана"
)
	icon_state = "gold"
	item_state = "gold-id"
	registered_name = "Captain"
	assignment = JOB_TITLE_CAPTAIN

/obj/item/card/id/captains_spare/Initialize(mapload)
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/card/id/admin
	name = "admin ID card"
	icon_state = "admin"
	item_state = "gold-id"
	registered_name = "Admin"
	assignment = "Testing Shit"
	untrackable = 1

/obj/item/card/id/admin/Initialize(mapload)
	access = get_absolutely_all_accesses()
	. = ..()

/obj/item/card/id/centcom
	name = "central command ID card"
	desc = "ID-карта Центрального Командования."
	icon_state = "centcom"
	item_state = "centcomm-id"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/card/id/centcom/Initialize(mapload)
	access = get_all_centcom_access()
	. = ..()

/obj/item/card/id/nanotrasen
	name = "nanotrasen ID card"
	icon_state = "nanotrasen"
	item_state = "nt-id"

/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "Вы не свободны. Вы - просто номер."
	icon_state = "prisoner"
	item_state = "orange-id"
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0

/obj/item/card/id/prisoner/attack_self(mob/user as mob)
	to_chat(usr, "Вы добыли [points] очков из необходимых [goal] для освобождения.")

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"

/obj/item/card/id/prisoner/random

/obj/item/card/id/prisoner/random/Initialize(mapload)
	. = ..()
	var/random_number = "#[rand(0, 99)]-[rand(0, 999)]"
	name = "Prisoner [random_number]"
	registered_name = name

/obj/item/card/id/salvage_captain
	name = "Captain's ID"
	registered_name = "Captain"
	icon_state = "centcom"
	desc = "Finders, keepers."
	access = list(ACCESS_SALVAGE_CAPTAIN)

/obj/item/card/id/medical
	name = "Medical ID"
	registered_name = "Medic"
	icon_state = "medical"
	item_state = "medical-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/medical/intern
	name = "Intern ID"
	registered_name = "Intern"
	icon_state = "intern"
	item_state = "intern-id"

/obj/item/card/id/security
	name = "Security ID"
	registered_name = "Officer"
	icon_state = "security"
	item_state = "security-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/security/cadet
	name = "Cadet ID"
	registered_name = "Cadet"
	icon_state = "cadet"
	item_state = "cadet-id"

/obj/item/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	item_state = "research-id"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/research/student
	name = "Student ID"
	registered_name = "Student"
	icon_state = "student"
	item_state = "student-id"

/obj/item/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	item_state = "cargo-id"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/engineering
	name = "Engineering ID"
	registered_name = "Engineer"
	icon_state = "engineering"
	item_state = "engineer-id"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)

/obj/item/card/id/engineering/trainee
	name = "Trainee ID"
	registered_name = "Trainee"
	icon_state = "trainee"
	item_state = "trainee-id"

/obj/item/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	item_state = "hos-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
			            ACCESS_FORENSICS_LOCKERS, ACCESS_PILOT, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
			            ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
			            ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_WEAPONS)

/obj/item/card/id/cmo
	name = "Chief Medical Officer ID"
	registered_name = "CMO"
	icon_state = "CMO"
	item_state = "cmo-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/rd
	name = "Research Director ID"
	registered_name = "RD"
	icon_state = "RD"
	item_state = "rd-id"
	access = list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
			            ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
			            ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
			            ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_GATEWAY, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	item_state = "ce-id"
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MECHANIC, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/clown
	name = "Pink ID"
	registered_name = "HONK!"
	icon_state = "clown"
	item_state = "clown-id"
	desc = "Взгляд на эту карту вызывает у вас глубокий страх."
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/mime
	name = "Black and White ID"
	registered_name = "..."
	icon_state = "mime"
	item_state = "mime-id"
	desc = "..."
	access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/qm
	name = "Quartmaster ID"
	registered_name = "QM"
	icon_state = "qm"
	item_state = "qm-id"
	desc = "Glory to cargonia!"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/genetics
	name = "Genetics ID"
	registered_name = "Genetics"
	icon_state = "genetics"
	item_state = "genetics-id"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/warden
	name = "Warden ID"
	registered_name = "Warden"
	icon_state = "warden"
	item_state = "warden-id"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/iaa
	name = "IAA ID"
	registered_name = "IAA"
	icon_state = "IAA"
	item_state = "iaa-id"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)

/obj/item/card/id/punpun
	name = "Pun Pun ID"
	registered_name = "Пун Пун"
	icon_state = "id"
	item_state = "card-id"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/mining_medic
	name = "Mining Medic ID"
	registered_name = "Mining Medic"
	icon_state = "mining_medic"
	item_state = "mining_medic-id"
	access = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

/obj/item/card/id/rainbow
	name = "Rainbow ID"
	icon_state = "rainbow"
	item_state = "clown-id"

/obj/item/card/id/thunderdome/red
	name = "Thunderdome Red ID"
	registered_name = "Red Team Fighter"
	assignment = "Red Team Fighter"
	icon_state = "TDred"
	desc = "This ID card is given to those who fought inside the thunderdome for the Red Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/card/id/thunderdome/green
	name = "Thunderdome Green ID"
	registered_name = "Green Team Fighter"
	assignment = "Green Team Fighter"
	icon_state = "TDgreen"
	desc = "This ID card is given to those who fought inside the thunderdome for the Green Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of Nanotrasen. It sparkles blue."
	icon_state = "lifetimeid"

/obj/item/card/id/ert
	name = "ERT ID"
	icon_state = "ERT_empty"
	item_state = "ert-id"

/obj/item/card/id/ert/commander
	icon_state = "ERT_leader"

/obj/item/card/id/ert/security
	icon_state = "ERT_security"

/obj/item/card/id/ert/engineering
	icon_state = "ERT_engineering"

/obj/item/card/id/ert/medic
	icon_state = "ERT_medical"

/obj/item/card/id/ert/registration
	name = "EDDITABLE ERT ID"
	icon_state = "ERT_empty"
	item_state = "ert-id"
	var/membership
	access = list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL, ACCESS_CENT_SECURITY, ACCESS_CENT_STORAGE, ACCESS_CENT_SPECOPS, ACCESS_SALVAGE_CAPTAIN)

/obj/item/card/id/ert/registration/commander
	icon_state = "ERT_leader"
	membership = "Leader"

/obj/item/card/id/ert/registration/security
	icon_state = "ERT_security"
	membership = "Officer"

/obj/item/card/id/ert/registration/engineering
	icon_state = "ERT_engineering"
	membership = "Engineer"

/obj/item/card/id/ert/registration/medic
	icon_state = "ERT_medical"
	membership = "Medic"

/obj/item/card/id/ert/registration/janitor
	icon_state = "ERT_janitorial"
	membership = "Janitor"

/obj/item/card/id/ert/registration/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = "[pick("Лейтенант", "Капитан", "Майор")] [user.real_name]"
		SetOwnerInfo(user)
		assignment = "Emergency Response Team [membership]"
		RebuildHTML()
		UpdateName()
		registered = TRUE
		to_chat(user, span_notice("Карта теперь привязана к вам."))
	else
		..()

/obj/item/card/id/golem
	name = "Free Golem ID"
	desc = "Карта, используемая для сбора очков добычи и покупки снаряжения. Используйте, чтобы привязать к себе."
	icon_state = "research"
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME) //access to robots/mechs

/obj/item/card/id/golem/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Free Golem"
		RebuildHTML()
		UpdateName()
		desc = "Карта, используемая для сбора очков добычи и покупки снаряжения."
		registered = TRUE
		to_chat(user, span_notice("Карта теперь привязана к вам."))
	else
		..()

// Decals
/obj/item/id_decal
	name = "identification card decal"
	desc = "A nano-cellophane wrap that molds to an ID card to make it look snazzy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	var/decal_name = "identification card"
	var/decal_desc = "Карта, используемая для удостоверения личности и определения доступа владельца на станции."
	var/decal_icon_state = "id"
	var/decal_item_state = "card-id"
	var/override_name = 0

/obj/item/id_decal/gold
	name = "gold ID card decal"
	icon_state = "id_decal_gold"
	desc = "Заставляет вашу ID-карту выглядеть похожей на капитанскую. Можно применить к любой ID-карте."
	decal_desc = "Золотая карта, символизирующая силу и мощь."
	decal_icon_state = "gold"
	decal_item_state = "gold-id"

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Заставляет вашу ID-карту выглядеть похожей на карту главы персонала. Можно применить к любой ID-карте."
	decal_desc = "Серебряная карта, символизирующая честь и преданность."
	decal_icon_state = "silver"
	decal_item_state = "silver-id"

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "У всех крутых ребят ID-карта этого цвета. Можно применить к любой ID-карте."
	decal_desc = "Вы не свободны. Вы - просто номер."
	decal_icon_state = "prisoner"
	decal_item_state = "orange-id"

/obj/item/id_decal/centcom
	name = "centcom ID card decal"
	icon_state = "id_decal_centcom"
	desc = "Престиж, но без доступа. Можно применить к любой ID-карте."
	decal_desc = "An ID straight from Cent. Com."
	decal_icon_state = "centcom"

/obj/item/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	icon_state = "id_decal_emag"
	desc = "Провода, которыми вы можете обмотать свою ID-карту, чтобы она выглядела подозрительно. Можно применить к любой ID-карте."
	decal_name = "cryptographic sequencer"
	decal_desc = "It's a card with a magnetic strip attached to some circuitry."
	decal_icon_state = "emag"
	override_name = 1

/proc/get_station_card_skins()
	return list("data","id","gold","silver","security", "cadet","medical", "intern","research", "student","cargo", "mining_medic","engineering", "trainee","HoS","CMO","RD","CE","clown","mime","rainbow","prisoner")

/proc/get_centcom_card_skins()
	return list("centcom","centcom_old","nanotrasen","ERT_leader","ERT_empty","ERT_security","ERT_engineering","ERT_medical","ERT_janitorial","deathsquad","commander","syndie","TDred","TDgreen")

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Standard"
		if("cargo")
			return "Supply"
		if("HoS")
			return "Head of Security"
		if("CMO")
			return "Chief Medical Officer"
		if("RD")
			return "Research Director"
		if("CE")
			return "Chief Engineer"
		if("centcom_old")
			return "Centcom Old"
		if("ERT_leader")
			return "ERT Leader"
		if("ERT_empty")
			return "ERT Default"
		if("ERT_security")
			return "ERT Security"
		if("ERT_engineering")
			return "ERT Engineering"
		if("ERT_medical")
			return "ERT Medical"
		if("ERT_janitorial")
			return "ERT Janitorial"
		if("syndie")
			return "Syndicate"
		if("TDred")
			return "Thunderdome Red"
		if("TDgreen")
			return "Thunderdome Green"
		if("mining_medic")
			return "Mining Medic"
		else
			return capitalize(skin)
