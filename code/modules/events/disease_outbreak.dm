/datum/event/disease_outbreak
	announceWhen = 150
	/// The type of virus that patient zero will be infected with.
	var/datum/disease/virus/D
	/// The initial target of the disease.
	var/mob/living/carbon/human/patient_zero

/datum/event/disease_outbreak/setup()
	announceWhen = rand(150, 300)
	var/virus_type = pick(
		5; /datum/disease/virus/advance,
		1; /datum/disease/virus/anxiety,
		1; /datum/disease/virus/beesease,
		1; /datum/disease/virus/brainrot,
		1; /datum/disease/virus/cold,
		1; /datum/disease/virus/flu,
		1; /datum/disease/virus/fluspanish,
		1; /datum/disease/virus/fake_gbs,
		1; /datum/disease/virus/loyalty,
		1; /datum/disease/virus/lycan,
		1; /datum/disease/virus/magnitis,
		1; /datum/disease/virus/pierrot_throat,
		1; /datum/disease/virus/pierrot_throat/advanced,
		1; /datum/disease/virus/tuberculosis,
		1; /datum/disease/virus/wizarditis,
		2; /datum/disease/virus/babylonian_fever
	)
	if(virus_type == /datum/disease/virus/advance)
		//creates only contagious viruses, that are always visible in Pandemic
		D = CreateRandomVirus(count_of_symptoms = rand(4, 6), resistance = rand(0,11), stealth = pick(0,0,1,1,2),
							stage_rate = rand(-11,5), transmittable = rand(5,9), severity = rand(0,5))
	else
		D = new virus_type()

/datum/event/disease_outbreak/announce()
	GLOB.event_announcement.Announce("Вспышка вирусной угрозы 7-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать ее распространение.", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", new_sound = 'sound/AI/outbreak7.ogg')

/datum/event/disease_outbreak/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		var/turf/T = get_turf(H)
		if(!T)
			continue
		if(!is_station_level(T.z))
			continue

		if(istype(D, /datum/disease/virus/advance))
			var/datum/disease/virus/advance/old_virus = locate() in H.diseases
			if(old_virus)
				old_virus.cure(need_immunity = FALSE)
		if(!D.Contract(H, is_carrier = TRUE))
			continue
		patient_zero = H

		for(var/mob/M in GLOB.dead_mob_list)
			to_chat(M, "<span class='deadsay'><b>[patient_zero]</b> был(а) заражён(а) <b>[D.name]</b> ([ghost_follow_link(patient_zero, M)])</span>")

		break
