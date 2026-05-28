/*
/datum/station_trait/announcement_intern_ru
	name = "Программа стажировки ЦК"
	weight = 1
	show_in_report = TRUE
	report_message = "В связи с сокращением бюджета Отдела Коммуникаций ЦК, роль диспетчера на текущую смену выполняет стажёр. Просим проявить понимание."
	blacklist = list(/datum/station_trait/announcement_medbot, /datum/station_trait/announcement_intern) //datum/station_trait/birthday)

/datum/station_trait/announcement_intern_ru/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern_ru

*/

/datum/station_trait/announcement_intern
	name = "Временная замена оператора системы оповещений"
	weight = 1
	show_in_report = TRUE
	report_message = "Локальный узел связи неисправен. Маршрутизация сообщений перенаправлена через оператора из дальнего сектора. Возможен специфический акцент."
	blacklist = list(/datum/station_trait/announcement_medbot) //datum/station_trait/birthday)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Автоматизация системы оповещений"
	weight = 1
	show_in_report = TRUE
	report_message = "Штатный диспетчер связи находится на больничном. Система оповещений переведена под контроль медицинского бота для снижения уровня стресса экипажа."
	blacklist = list(/datum/station_trait/announcement_intern) //datum/station_trait/birthday)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/bananium_shipment
	name = "Поставка бананиума"
	report_message = "Отдел Снабжения ЦК получил посылку, содержащую нестабильные изотопы бананиума. К грузу приложена записка: \"С любовью, Мама\"."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_LOW
	weight = 5
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/mimanium_shipment
	name = "Поставка транквилита"
	report_message = "..."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_LOW
	weight = 5
	trait_to_give = STATION_TRAIT_MIMANIUM_SHIPMENTS

/datum/station_trait/unique_ai
	name = "Экспериментальный свод законов ИИ"
	report_message = "В ядро станционного ИИ был загружен экспериментальный набор директив. Любые попытки изменения законов строго запрещены и расцениваются как саботаж."
	show_in_report = TRUE
	trait_flags = parent_type::trait_flags | STATION_TRAIT_REQUIRES_AI
	weight = 5
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/glitched_pdas
	name = "Дефектные КПК"
	report_message = "КПК, выданные этой смене, имеют заводской брак видеочипа. Ожидаются визуальные глитчи интерфейса. На функционал устройств это не влияет."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	weight = 5
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/classic_assistants
	name = "Устаревшая рабочая форма"
	report_message = "На складе униформы закончились современные модели комбинезонов. На время текущей смены ассистентам будет выдана форма образца 2540 года из резервов."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	weight = 5
	trait_to_give = STATION_TRAIT_CLASSIC_ASSISTANTS

/datum/station_trait/birthday
	name = "День рождения сотрудника"
	report_message = "Отдел Кадров ЦК сообщает: один из членов экипажа, \[Имя сотрудника\], празднует день рождения."
	show_in_report = TRUE
	cost = STATION_TRAIT_COST_MINIMAL
	weight = 2
	trait_to_give = STATION_TRAIT_BIRTHDAY
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_medbot)
	///Variable that stores a reference to the person selected to have their birthday celebrated.
	var/mob/living/carbon/human/birthday_person
	///Variable that holds the real name of the birthday person once selected, just incase the birthday person's real_name changes.
	var/birthday_person_name = ""
	///Variable that admins can override with a player's ckey in order to set them as the birthday person when the round starts.
	var/birthday_override_ckey

/datum/station_trait/birthday/New()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_JOB_AFTER_SPAWN), PROC_REF(on_job_after_spawn))

/datum/station_trait/birthday/revert()
	for(var/obj/effect/landmark/start/hangover/party_spot in GLOB.start_landmarks_list)
		QDEL_LIST(party_spot.party_debris)
	return ..()

/datum/station_trait/birthday/on_round_start()
	. = ..()
	if(birthday_override_ckey && !check_valid_override())
		message_admins("Attempted to make [birthday_override_ckey] the birthday person but they are not a valid station role. A random birthday person has be selected instead.")

	if(birthday_person)
		addtimer(CALLBACK(src, PROC_REF(announce_birthday)), 120 SECONDS)
		return

	var/list/birthday_options = list()
	for(var/mob/living/carbon/human/human in GLOB.alive_player_list)
		if(isnull(human.mind?.special_role)) //probably only station roundstart roles, i hope
			birthday_options += human

	if(!length(birthday_options))
		return

	birthday_person = pick(birthday_options)
	birthday_person_name = birthday_person.real_name
	addtimer(CALLBACK(src, PROC_REF(announce_birthday)), 120 SECONDS)

/datum/station_trait/birthday/proc/check_valid_override()
	var/mob/living/carbon/human/birthday_override_mob = get_mob_by_ckey(birthday_override_ckey)

	if(isnull(birthday_override_mob))
		return FALSE

	if(isnull(birthday_override_mob.mind?.special_role))
		birthday_person = birthday_override_mob
		birthday_person_name = birthday_person.real_name
		return TRUE

	return FALSE

/datum/station_trait/birthday/proc/announce_birthday()
	GLOB.minor_announcement.announce(
		message = "С днём рождения, [birthday_person ? birthday_person_name : "\[имя сотрудника\]"]! Корпорация \"Нанотрейзен\" желает вам продуктивного нового года жизни!",
		new_title = ANNOUNCE_PRIORITY_RU,
		new_sound = SSstation.announcer.get_rand_report_sound(),
	)
	if(!birthday_person)
		return

	playsound(birthday_person, 'sound/items/bikehorn.ogg', 50)
	birthday_person = null

/datum/station_trait/birthday/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned_mob)
	SIGNAL_HANDLER

	var/obj/item/hat = pick_weight_classic(list(
		/obj/item/clothing/head/cakehat = 1,
		/obj/item/clothing/head/shapka_pepega = 2,
		/obj/item/clothing/head/carp_hat = 4,
		/obj/item/trash/fried_vox = 4,
		/obj/item/clothing/head/geranium_crown = 6, // more like for wedding, but who cares
		/obj/item/clothing/head/lily_crown = 6,
		/obj/item/clothing/head/poppy_crown = 6,
		/obj/item/clothing/head/sunflower_crown = 6,
		/obj/item/clothing/head/flower_crown = 6,
	))
	hat = new hat(spawned_mob)
	if(!spawned_mob.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE))
		spawned_mob.equip_to_slot_if_possible(hat, ITEM_SLOT_BACKPACK, disable_warning = TRUE)

	var/obj/item/toy = pick_weight_classic(list(
		/obj/item/toy/syndicateballoon = 3,
		/obj/item/toy/syndicateballoon/contractor = 3,
		/obj/item/toy/carpplushie/void = 1,
		/obj/item/toy/foamblade = 1,
	))
	toy = new toy(spawned_mob)
	if(istype(toy, /obj/item/toy/syndicateballoon))
		spawned_mob.equip_to_slot_if_possible(toy, ITEM_SLOT_HAND_LEFT, disable_warning = TRUE) //Balloons do not fit inside of backpacks.
	else
		spawned_mob.equip_to_slot_if_possible(toy, ITEM_SLOT_BACK, disable_warning = TRUE)

	if(!birthday_person_name)
		return

	//Anyone who joins after the annoucement gets one of these.
	var/obj/item/birthday_invite/birthday_invite = new(spawned_mob)
	birthday_invite.setup_card(birthday_person_name)
	if(!spawned_mob.equip_to_slot_if_possible(birthday_invite, ITEM_SLOT_HANDS, disable_warning = TRUE))
		spawned_mob.equip_to_slot_if_possible(birthday_invite, ITEM_SLOT_BACKPACK, disable_warning = TRUE)

/obj/item/birthday_invite
	name = "birthday invitation"
	desc = "Небольшая карточка, на которой сказано, что у кого-то сегодня день рождения."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/birthday_invite/get_ru_names()
	return list(
		NOMINATIVE = "приглашение на день рождения",
		GENITIVE = "приглашения на день рождения",
		DATIVE = "приглашению на день рождения",
		ACCUSATIVE = "приглашение на день рождения",
		INSTRUMENTAL = "приглашением на день рождения",
		PREPOSITIONAL = "приглашении на день рождения",
	)

/obj/item/birthday_invite/proc/setup_card(birthday_name)
	desc = "Небольшая карточка с надписью: \"[birthday_name] сегодня празднует/ют свой день рождения!\""
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "slip"

/// No tesla beacon, but there are spare singulogen in the storage
/datum/station_trait/forced_teg
	name = "Зелёная энергия"
	report_message = "В рамках инициативы по энергоэффективности, вместо стандартного двигателя объект оборудован термо-электрическим генератором. Удачи в настройке."
	show_in_report = TRUE
	weight = 3
	trait_to_give = STATION_TRAIT_GREEN_ENERGY
