/datum/data/pda/utility/flashlight
	name = "Включить фонарик"
	icon = "lightbulb-o"
	/// Is the flashlight function on?
	var/fon = FALSE

/datum/data/pda/utility/flashlight/start()
	fon = !fon
	name = fon ? "Выключить фонарик" : "Включить фонарик"
	pda.update_shortcuts()
	pda.update_icon(UPDATE_OVERLAYS)
	pda.set_light_on(fon)


/datum/data/pda/utility/honk
	name = "Синтезатор гудков"
	icon = "smile-o"
	category = "Клоунские"

	var/last_honk //Also no honk spamming that's bad too

/datum/data/pda/utility/honk/start()
	if(!(last_honk && world.time < last_honk + 20))
		playsound(pda.loc, 'sound/items/bikehorn.ogg', 50, 1)
		last_honk = world.time

/datum/data/pda/utility/toggle_door
	name = "Управление шлюзом"
	icon = "external-link-alt"
	var/remote_door_id = ""

/datum/data/pda/utility/toggle_door/start()
	for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
		if(M.id_tag == remote_door_id)
			if(M.density)
				M.open()
			else
				M.close()

/datum/data/pda/utility/scanmode/medical
	base_name = "медицинский сканер"
	icon = "heart-o"

/datum/data/pda/utility/scanmode/medical/scan_mob(mob/living/M, mob/living/user)
	user.visible_message(
		span_notice("[user] анализиру[pluralize_ru(user.gender, "ет", "ют")] состояние здоровья [M.declent_ru(ACCUSATIVE)]"),
		span_notice("Вы анализируете состояние здоровья [M]")
	)

	healthscan(user, M, 1)

/datum/data/pda/utility/scanmode/dna
	base_name = "сканер ДНК"
	icon = "link"

/datum/data/pda/utility/scanmode/dna/scan_mob(mob/living/C as mob, mob/living/user as mob)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!istype(H.dna, /datum/dna))
			to_chat(user, span_notice("На [H.declent_ru(PREPOSITIONAL)] не найдено отпечатков пальцев."))
			to_chat(user, span_notice("Отпечатки пальцев [H]: [md5(H.dna.uni_identity)]"))
			to_chat(user, span_notice("Отпечатки пальцев [H.declent_ru(PREPOSITIONAL)]: [md5(H.dna.uni_identity)]"))

/datum/data/pda/utility/scanmode/dna/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	scan_blood(A, user)

/datum/data/pda/utility/scanmode/dna/proc/scan_blood(atom/A, mob/user)
	if(!A.blood_DNA)
		to_chat(user, span_notice("На [A.declent_ru(PREPOSITIONAL)] не найдено следов крови."))
		qdel(A.blood_DNA)
	else
		to_chat(user, span_notice("На [A.declent_ru(PREPOSITIONAL)] найдена кровь. Анализ..."))
		spawn(15)
			for(var/blood in A.blood_DNA)
				to_chat(user, span_notice("Группа крови: [A.blood_DNA[blood]]"))
				to_chat(user, span_notice("Хэш ДНК: [blood]"))

/datum/data/pda/utility/scanmode/halogen
	base_name = "счётчик галогенов"
	icon = "exclamation-circle"

/datum/data/pda/utility/scanmode/halogen/scan_mob(mob/living/C as mob, mob/living/user as mob)
	C.visible_message(span_warning("[user] анализирует уровень радиации [C]!"))

	user.show_message(span_notice("Результаты анализа [C]:"))
	if(C.radiation)
		var/rad_level = C.radiation > 0 ? span_danger("[C.radiation]") : "0"
		user.show_message(span_notice("Уровень радиации: [rad_level]"))
	else
		user.show_message(span_notice("Следов радиации не обнаружено."))

/datum/data/pda/utility/scanmode/reagent
	base_name = "сканер реагентов"
	icon = "flask"

/datum/data/pda/utility/scanmode/reagent/scan_atom(atom/A as mob|obj|turf|area, mob/user as mob)
	if(!isnull(A.reagents))
		if(A.reagents.reagent_list.len > 0)
			var/reagents_length = A.reagents.reagent_list.len
			to_chat(user, span_notice("Обнаружен[reagents_length > 1 ? "о" : ""] [reagents_length] химическ[reagents_length > 1 ? "их" : "ий"] реагент[reagents_length > 1 ? "ов" : ""]:"))
			for(var/datum/reagent/R in A.reagents.reagent_list)
				if(R.id != "blood")
					to_chat(user, span_notice("\t [R]"))
				else
					var/blood_type = R.data["blood_type"]
					var/blood_species = R.data["blood_species"]
					to_chat(user, span_notice("\t [R] [blood_type] [blood_species]"))
		else
			to_chat(user, span_notice("Содержание химических реагентов в [A.declent_ru(PREPOSITIONAL)] не обнаружено."))
	else
		to_chat(user, span_notice("Следов реагентов не обнаружено."))

/datum/data/pda/utility/scanmode/gas
	base_name = "газовый сканер"
	icon = "tachometer-alt"

/datum/data/pda/utility/scanmode/gas/scan_atom(atom/A, mob/user)
	atmos_scan(user=user, target=A, silent=FALSE, print=TRUE)
