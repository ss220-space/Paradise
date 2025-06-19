/obj/item/paper/fluff/henderson_report
	name = "Важное уведомление – Миссис Хендерсон"
	info = "Ничего интересного."

/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "Медицинское устройство, предназначеное для стабилизации пациентов. Эта, кажется, сломана, а человек внутри находится в коме."
	ru_names = list(
		NOMINATIVE = "слипер",
		GENITIVE = "слипера",
		DATIVE = "слиперу",
		ACCUSATIVE = "слипер",
		INSTRUMENTAL = "слипером",
		PREPOSITIONAL = "слипере"
	)
	mob_name = "a translocated vet"
	description = "Вы – интерн, работающий в ветеринарной клинике, который внезапно оказался на Лаваленде. Удачи."
	flavour_text = "Всё произошло так быстро: вы залечивали царапину от кошки в слипере, а когда очнулись, клиника опустела. \
	Где все? Что случилось? Вы чувствуете запах дыма и понимаете, что нужно найти кого-то, кто объяснит, что происходит."
	assignedrole = "Translocated Vet"
	random = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	outfit = /datum/outfit/job/doctor/alive/lavaland

/datum/outfit/job/doctor/alive/lavaland
	name = "Medical Doctor"
	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/doctor/alive/lavaland/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()
