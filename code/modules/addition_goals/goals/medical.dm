// Medical shuttel addition goal

////////////////////////////////////////
// MARK:	Goal datum
////////////////////////////////////////

/datum/addition_goal/medical_patients
	id = "medical"
	name = "Медицинский шаттл с пациентами"
	var/patiens_count
	var/list/patients = list()
	var/obj/effect/mob_spawn/human/spawner


/datum/addition_goal/medical_patients/setup()
	patiens_count = rand(3, 5)
	name += " ([patiens_count])"


/datum/addition_goal/medical_patients/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("medical patients addition goal: id=[id] begin spawn shuttle contain patiens=[patiens_count].")
	spawner = new /obj/effect/mob_spawn/human/addition_goal/medical_patients(shuttle_turfs[1])
	for(var/i = 0; i < patiens_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		create_patient_at(random_turf)
	qdel(spawner)
	return TRUE

/datum/addition_goal/medical_patients/proc/create_patient_at(turf/location)
	spawner.loc = location
	var/mob/living/patient = spawner.create()
	patients += patient
	var/obj/structure/bed/bed = new /obj/structure/bed(location)
	addtimer(CALLBACK(bed, TYPE_PROC_REF(/atom/movable/, buckle_mob), patient, TRUE, FALSE), 1)
	randomize_patient_diseases(patient)
	switch_ai_to_angry_mode(patient)

/datum/addition_goal/medical_patients/proc/randomize_patient_diseases(mob/living/patient)
	patient.adjustBruteLoss(rand(20, 50))
	if(prob(30))
		patient.adjustFireLoss(rand(20, 50))
	if(prob(10))
		patient.adjustCloneLoss(rand(5, 25))
	if(prob(10))
		patient.adjustToxLoss(rand(15, 10))

/datum/addition_goal/medical_patients/proc/switch_ai_to_angry_mode(mob/living/patient)
	patient.ai_controller = /datum/ai_controller/monkey/angry
	patient.InitializeAIController()


/datum/addition_goal/medical_patients/format_accept_report(mob/user)
	var/text = {"<b>Запрос медицинской помощи</b><br>
		К вам отправлено [patiens_count] больных с соседней психбольницы.<br>
		Необходимо полностью вылечить пациентов. Будьте осторожны, пациенты буйные.
		Список пациентов:<br>"}
	var/number = 1
	for(var/mob/living/patient as anything in patients)
		text += "<br>[number]. [patient.real_name]."
		number++
	return text


/datum/addition_goal/medical_patients/check_completion(list/turf/shuttle_turfs)
	var/full_healed_patients = 0
	for(var/mob/living/patient in patients)
		if(patient && patient.loc)
			if(patient.health >= 100 && patient.stat == CONSCIOUS)
				full_healed_patients++
	var/progress = full_healed_patients / patiens_count * 100
	message_admins("medical patients addition goal: check completition full heal [full_healed_patients] of [patiens_count] progress=[progress].")
	return progress



////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/medical_patients
	death = FALSE
	mob_type = /mob/living/carbon/human/monkeybrain
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/straight_jacket
