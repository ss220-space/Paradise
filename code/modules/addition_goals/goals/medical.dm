// Medical shuttel addition goal

#define AGS_DIFFICULTY_EASY 1
#define AGS_DIFFICULTY_NORMAL 2
#define AGS_DIFFICULTY_HARD 3

#define AGS_MIN_CREDITS_PER_PATIEN 3000
#define AGS_MAX_CREDITS_PER_PATIEN 5000
#define AGS_MIN_CARGOPOINTS_PER_PATIEN 10
#define AGS_MAX_CARGOPOINTS_PER_PATIEN 20

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
			patiens_count = rand(5, 8)
		if(AGS_DIFFICULTY_HARD)
			name = "Запрос большой медицинской помощи №[request_number]"
			patiens_count = rand(8, 10)
	description = "[name]. На станцию прибудет шаттл с [patiens_count] [declension_ru(patiens_count, "пациентом", "пациентами", "пациентами")] для проведения медицинских услуг."

/datum/addition_goal/medical_patients/spawn_shuttle_contain(list/turf/shuttle_turfs)
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
	if(prob(15)) // 15% chance of free from straight jacket
		free_straight_jacket(patient)
	var/obj/structure/bed/bed = new /obj/structure/bed(location)
	addtimer(CALLBACK(bed, TYPE_PROC_REF(/atom/movable/, buckle_mob), patient, TRUE, FALSE), 1)
	randomize_patient_diseases(patient)
	switch_ai_to_angry_mode(patient)

/datum/addition_goal/medical_patients/proc/free_straight_jacket(mob/living/patient)
	var/obj/item/clothing/jacket = patient.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
	patient.drop_item_ground(jacket, TRUE, TRUE)

/datum/addition_goal/medical_patients/proc/randomize_patient_diseases(mob/living/patient)
	var/reward_progress = 0
	// 100% chance of brute damage
	patient.adjustBruteLoss(rand(30, 50))
	if(prob(50)) //50% chance of burn damage
		patient.adjustFireLoss(rand(25, 50))
	if(prob(10)) // 10% chance of death
		patient.adjustBruteLoss(200)
	if(prob(20)) // 20% chance of clone damage
		patient.adjustCloneLoss(rand(20, 40))
	if(prob(33)) // 33% chance of tox damage
		patient.adjustToxLoss(rand(15, 50))
	if(prob(10)) //10% chance of destroy limb
		var/zone = pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		patient.adjustBruteLoss(100, TRUE, zone, FALSE, TRUE, null, TRUE, TRUE)
	reward_credits += AGS_MIN_CREDITS_PER_PATIEN + round(reward_progress * (AGS_MAX_CREDITS_PER_PATIEN - AGS_MIN_CREDITS_PER_PATIEN))
	reward_cargopoints += AGS_MIN_CARGOPOINTS_PER_PATIEN + round(reward_progress * (AGS_MAX_CARGOPOINTS_PER_PATIEN - AGS_MIN_CARGOPOINTS_PER_PATIEN))

/datum/addition_goal/medical_patients/proc/switch_ai_to_angry_mode(mob/living/patient)
	patient.ai_controller = /datum/ai_controller/monkey/angry
	patient.InitializeAIController()


/datum/addition_goal/medical_patients/format_accept_report(mob/user)
	var/text = {"К вам [declension_ru(patiens_count, "отправлен", "отправлено", "отправлено")] [patiens_count] [declension_ru(patiens_count, "больной", "больных", "больных")] с соседней психбольницы.<br>
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
	reward_cargopoints = reward_cargopoints * (progress / 100)
	var/reward_number = 1
	if(reward_credits > 0)
		report_text += "[reward_number]. [reward_credits] кредитов на счет станции.<br>"
		reward_number++
	if(reward_cargopoints > 0)
		report_text += "[reward_number]. [reward_cargopoints] очков поставки в карго.<br>"
	system.add_reward(reward_credits, reward_cargopoints)
	var/paper_content = system.create_paper_content("Отчет о медицинской помощи №[request_number]", report_text, "Официальный документ заверенный печатью Центрального командования Нанотрейзен")
	system.print_report_on_console("Отчет [name]", paper_content, stamp = TRUE)



////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/medical_patients
	death = FALSE
	mob_type = /mob/living/carbon/human/monkeybrain
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/straight_jacket
