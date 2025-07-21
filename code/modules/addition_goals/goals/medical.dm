// Medical shuttel addition goal

#define AGS_DIFFICULTY_EASY 1
#define AGS_DIFFICULTY_NORMAL 2
#define AGS_DIFFICULTY_HARD 3

#define AGS_MIN_CREDITS_PER_PATIEN 1000
#define AGS_MAX_CREDITS_PER_PATIEN 5000
#define AGS_MIN_CARGOPOINTS_PER_PATIEN 5
#define AGS_MAX_CARGOPOINTS_PER_PATIEN 15

////////////////////////////////////////
// MARK:	Goal datum
////////////////////////////////////////

/datum/addition_goal/medical_patients
	id = "medical"
	var/patiens_count
	var/list/patients = list()
	var/obj/effect/mob_spawn/human/spawner


/datum/addition_goal/medical_patients/setup()
	request_number = "[rand(100, 999)]"
	switch(rand(1, 3))
		if(AGS_DIFFICULTY_EASY)
			name = "Запрос малой медицинской помощи №[request_number]"
			patiens_count = rand(3, 4)
		if(AGS_DIFFICULTY_NORMAL)
			name = "Запрос медицинской помощи №[request_number]"
			patiens_count = rand(5, 10)
		if(AGS_DIFFICULTY_HARD)
			name = "Запрос большой медицинской помощи №[request_number]"
			patiens_count = rand(12, 15)
	description = "[name]. На станцию прибудет шаттл с [patiens_count] пациентами для проведения медицинских услуг."

/datum/addition_goal/medical_patients/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("medical patients addition goal: id=[id] begin spawn shuttle contain patiens=[patiens_count].")
	spawner = new /obj/effect/mob_spawn/human/addition_goal/medical_patients(shuttle_turfs[1])
	reward_credits = 0
	reward_cargopoints = 0
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
	var/reward_progress = 0
	patient.adjustBruteLoss(rand(20, 50))
	if(prob(30))
		patient.adjustFireLoss(rand(20, 50))
	if(prob(10))
		patient.adjustCloneLoss(rand(5, 25))
	if(prob(10))
		patient.adjustToxLoss(rand(15, 10))
	reward_credits += AGS_MIN_CREDITS_PER_PATIEN + round(reward_progress * (AGS_MAX_CREDITS_PER_PATIEN - AGS_MIN_CREDITS_PER_PATIEN))
	reward_cargopoints += AGS_MIN_CARGOPOINTS_PER_PATIEN + round(reward_progress * (AGS_MAX_CARGOPOINTS_PER_PATIEN - AGS_MIN_CARGOPOINTS_PER_PATIEN))

/datum/addition_goal/medical_patients/proc/switch_ai_to_angry_mode(mob/living/patient)
	patient.ai_controller = /datum/ai_controller/monkey/angry
	patient.InitializeAIController()


/datum/addition_goal/medical_patients/format_accept_report(mob/user)
	var/text = {"К вам отправлено [patiens_count] больных с соседней психбольницы.<br>
		Необходимо полностью вылечить пациентов. Будьте осторожны, пациенты буйные.
		Список пациентов:<br>"}
	var/number = 1
	for(var/mob/living/patient as anything in patients)
		text += "<br>[number]. [patient.real_name]."
		number++
	return text


/datum/addition_goal/medical_patients/complete_goal(datum/controller/subsystem/addition_goals/system)
	var/shuttle_turfs = system.get_shuttle_turfs()
	var/full_healed_patients = 0
	var/report_text = ""
	var/number = 1
	for(var/mob/living/patient in patients)
		report_text += "[number]. [patient.name]: "
		number++
		if(!patient.loc)
			report_text += "тело уничтожено.<br>"
			continue
		if(!contains_in_shuttle(shuttle_turfs, patient))
			report_text += "пацент не возвращен.<br>"
			continue
		if(patient.health >= 100 && patient.stat == CONSCIOUS)
			full_healed_patients++
			report_text += "вылечен.<br>"
			continue
		report_text += "не вылечен.<br>"
	var/progress = full_healed_patients / patiens_count * 100
	report_text += "<b>Общий прогресс запроса</b>: [progress]%<br>"
	report_text += "<b>Ваша награда</b>:<br>"
	reward_credits = reward_credits * (progress / 100)
	reward_cargopoints = reward_credits * (progress / 100)
	var/reward_number = 1
	if(reward_credits > 0)
		report_text += "[reward_number]. [reward_credits] кредитов на счет станции.<br>"
		reward_number++
	if(reward_cargopoints > 0)
		report_text += "[reward_number]. [reward_cargopoints] очков поставки в карго.<br>"
	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет о медицинской помощи №[request_number]", report_text, "Официальный документ заверенный печатью Центрального Командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)
	message_admins("medical patients addition goal: check completition full heal [full_healed_patients] of [patiens_count] progress=[progress].")



////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/medical_patients
	death = FALSE
	mob_type = /mob/living/carbon/human/monkeybrain
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/straight_jacket
