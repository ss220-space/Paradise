/obj/item/paper/fluff/henderson_report
	name = "Важное уведомление — Миссис Хендерсон"
	info = "Ничего интересного."

/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "Медицинское устройство, предназначеное для стабилизации пациентов. Эта, кажется, сломана, а человек внутри находится в коме."
	mob_name = "a translocated vet"
	description = "Вы — интерн, работающий в ветеринарной клинике, который внезапно оказался на Лаваленде. Удачи."
	flavour_text = "Всё произошло так быстро: вы залечивали царапину от кошки в слипере, а когда очнулись, клиника опустела.\n\
	Где все? Что случилось? Вы чувствуете запах дыма и понимаете, что нужно найти кого-то, кто объяснит, что происходит."
	assignedrole = "Translocated Vet"
	random = FALSE
	allow_species_pick = TRUE
	allow_prefs_prompt = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	outfit = /datum/outfit/job/doctor/alive/lavaland

/obj/effect/mob_spawn/human/doctor/alive/lavaland/get_ru_names()
	return list(
		NOMINATIVE = "слипер",
		GENITIVE = "слипера",
		DATIVE = "слиперу",
		ACCUSATIVE = "слипер",
		INSTRUMENTAL = "слипером",
		PREPOSITIONAL = "слипере"
	)

/datum/outfit/job/doctor/alive/lavaland

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

/obj/effect/mob_spawn/human/doctor/alive/lavaland/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	return ..()
