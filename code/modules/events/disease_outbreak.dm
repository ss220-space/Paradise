/datum/event/disease_outbreak
	announceWhen = 15
	/// The type of disease that patient zero will be infected with.
	var/datum/disease/virus/D
	/// The initial target of the disease.
	var/mob/living/carbon/human/patient_zero

/datum/event/disease_outbreak/setup()
	announceWhen = rand(15, 30)
	var/virus_type = pick(
		5; /datum/disease/virus/advance, \
		1; /datum/disease/virus/anxiety, \
		1; /datum/disease/virus/beesease, \
		1; /datum/disease/virus/brainrot,	\
		1; /datum/disease/virus/fake_gbs,	\
		1; /datum/disease/virus/fluspanish, \
		1; /datum/disease/virus/loyalty, \
		1; /datum/disease/virus/lycan, \
		1; /datum/disease/virus/magnitis, \
		1; /datum/disease/virus/pierrot_throat, \
	)
	if(virus_type == /datum/disease/virus/advance)
		var/datum/disease/virus/advance/A = new
		A.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns + GLOB.verbs)) // random silly name
		A.symptoms = A.GenerateSymptoms(count_of_symptoms = 6)
		A.Refresh()
		A.AssignProperties(list("resistance" = rand(0,11), "stealth" = rand(0,2), "stage_rate" = rand(0,5), "transmittable" = rand(0,5), "severity" = rand(0,10)))
		D = A
	else
		D = new virus_type()

	D.carrier = TRUE

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Вспышка вирусной угрозы 7-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать ее распространение.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", new_sound = 'sound/AI/outbreak7.ogg')
	for(var/p in GLOB.dead_mob_list)
		var/mob/M = p
		to_chat(M, "<span class='deadsay'><b>[patient_zero]</b> был(а) заражён(а) <b>[D.name]</b> ([ghost_follow_link(patient_zero, M)])</span>")

/datum/event/disease_outbreak/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(issmall(H)) //don't infect monkies; that's a waste
			continue
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue

		if(!D.ForceContract(H))
			continue
		patient_zero = H
		break
