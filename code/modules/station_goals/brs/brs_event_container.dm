#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Cyborg"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_BOTANIST "Botanist"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

/*
GLOBAL_LIST_INIT(brs_severity_to_string, list(
	BRS_EVENT_MESS 		= "Mess",
	BRS_EVENT_MINOR 	= "Minor",
	BRS_EVENT_MAJOR 	= "Major",
	BRS_EVENT_CRITICAL 	= "Critical"
	))*/

//event_container.dm
//====================BRS GOAL====================
/datum/event_container/brs_mess
	severity = BRS_EVENT_MESS
	available_events = list(
		// Severity level, event name, event type, base weight, role weights, one shot, min weight, max weight. Last two only used if set.
		new /datum/event_meta(BRS_EVENT_MESS, 	"Ничего",				/datum/event/nothing,			150),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Денежная лотерея",		/datum/event/money_lotto, 		5, 		list(ASSIGNMENT_ANY = 1)),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Взлом аккаунта",		/datum/event/money_hacker, 		50, 	list(ASSIGNMENT_ANY = 4)),
		new /datum/event_meta(BRS_EVENT_MESS, 	"Стенной грибок",		/datum/event/wallrot, 			50,		list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_GARDENER = 50)),
		new /datum/event_meta(BRS_EVENT_MESS, "Отходы из вытяжек",		/datum/event/vent_clog,			100),
		new /datum/event_meta(BRS_EVENT_MESS, "Гравитационная аномалия",/datum/event/anomaly/anomaly_grav,		200),
		new /datum/event_meta(BRS_EVENT_MESS, "Массовые галлюцинации",	/datum/event/mass_hallucination,		25),
	)

/datum/event_container/brs_minor
	severity = BRS_EVENT_MINOR
	available_events = list(
		new /datum/event_meta(BRS_EVENT_MINOR, "Ничего",					/datum/event/nothing,					100),
		new /datum/event_meta(BRS_EVENT_MINOR, "Пространственный разрыв",	/datum/event/tear,						150,	list(ASSIGNMENT_SECURITY = 35)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Червоточины",				/datum/event/wormholes,					10),
		new /datum/event_meta(BRS_EVENT_MINOR, "Атмосферная аномалия",		/datum/event/anomaly/anomaly_pyro,		150,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Вортекс-аномалия",			/datum/event/anomaly/anomaly_vortex,	75,		list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Блюспейс-аномалия",			/datum/event/anomaly/anomaly_bluespace,	200,	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Флюкс-аномалия",			/datum/event/anomaly/anomaly_flux,		200,	list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Гравитационная аномалия",	/datum/event/anomaly/anomaly_grav,		300),
		new /datum/event_meta(BRS_EVENT_MINOR, "Скопление кои",				/datum/event/carp_migration/koi,		80),
		new /datum/event_meta(BRS_EVENT_MINOR, "Телекоммуникационный сбой",	/datum/event/communications_blackout,	500,	list(ASSIGNMENT_AI = 150, ASSIGNMENT_SECURITY = 120)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Массовые галлюцинации",		/datum/event/mass_hallucination,		100),
		new /datum/event_meta(BRS_EVENT_MINOR, "Сбой работы дверей",		/datum/event/door_runtime,				50,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Space Dust",				/datum/event/dust,						50,		list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(BRS_EVENT_MINOR, "Мясной дождь",				/datum/event/dust/meaty,				50,		list(ASSIGNMENT_ENGINEER = 20)),
	)

/datum/event_container/brs_major
	severity = BRS_EVENT_MAJOR
	available_events = list(
		new /datum/event_meta(BRS_EVENT_MAJOR, 	"Ничего",					/datum/event/nothing,					100),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Солнечная вспышка",			/datum/event/solar_flare,				150,	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Электрический шторм",		/datum/event/electrical_storm, 			250,	list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 150)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Радиационный шторм",		/datum/event/radiation_storm, 			50,		list(ASSIGNMENT_MEDICAL = 50)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Побег",						/datum/event/prison_break,				100,	list(ASSIGNMENT_SECURITY = 100)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Замыкание ЛКП",				/datum/event/apc_short, 				300,	list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Сбойные дроны",				/datum/event/rogue_drone, 				10,		list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Скопление карпов",			/datum/event/carp_migration,			100, 	list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Ионный шторм",				/datum/event/ion_storm, 				25,		list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Вспышка болезни",			/datum/event/disease_outbreak, 			10,		list(ASSIGNMENT_MEDICAL = 150)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Хедкрабы",					/datum/event/headcrabs, 				100,	list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Сбой работы дверей",		/datum/event/door_runtime,				80,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150)),
		new /datum/event_meta(BRS_EVENT_MAJOR, "Вортекс-аномалия",			/datum/event/anomaly/anomaly_vortex,	75,		list(ASSIGNMENT_ENGINEER = 25)),

	)

/datum/event_container/brs_critical
	severity = BRS_EVENT_CRITICAL
	available_events = list(
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Червоточины",			/datum/event/wormholes,					150),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Цифровой вирус",			/datum/event/brand_intelligence,		150, 	list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Перегрузка ЛКП",			/datum/event/apc_overload,				200),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Миграция карпов",		/datum/event/carp_migration,			25,		list(ASSIGNMENT_SECURITY =  3)),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Хонкономалия",			/datum/event/tear/honk,					50),
		new /datum/event_meta(BRS_EVENT_CRITICAL, "Сбой работы дверей",		/datum/event/door_runtime,				80,		list(ASSIGNMENT_ENGINEER = 25, ASSIGNMENT_AI = 150))
	)



#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY



//==========================================
//============ Локальные ивенты ============
//==========================================
//Выбор локального ивента
/obj/brs_rift/proc/choose_random_event(var/list/objects)
	var/prob_chance = 85
	var/choosen = rand(1, 2)
	switch(choosen)
		if(1)
			if(prob(prob_chance))
				local_emp(objects)
			else
				local_explosive(objects)
		if(2)
			local_random_grenade(objects)

//Выбор локального связанного ивента
/obj/brs_rift/proc/choose_random_related_event(var/list/objects)
	var/prob_chance = 70
	var/prob_living_chance = 50
	var/choosen = rand(1, 4)
	switch(choosen)
		if(1)
			if(prob(prob_chance))
				if(prob(prob_living_chance))
					local_teleport_living(objects)
				else
					local_teleport_objects(objects)
			else
				local_teleport_all(objects)
		if(2)
			if(prob(prob_chance))
				if(prob(prob_living_chance))
					local_teleport_living_zloc(objects)
				else
					local_teleport_objects_zloc(objects)
			else
				local_teleport_all(objects)
		if(3)
			if(prob(prob_chance))
				if(prob(prob_living_chance))
					local_teleport_living_reshuffle(objects)
				else
					local_teleport_objects_reshuffle(objects)
			else
				local_teleport_all_reshuffle(objects)
		if(4)
			local_random_grenade_living(objects)


//============ Телепорты ============

//Телепорты в небольшом радиусе
/obj/brs_rift/proc/local_teleport_living(var/list/objects)
	for(var/mob/living/H in objects)
		do_teleport(H, get_turf(H), 7)
		investigate_log("teleported [key_name_log(H)] to [COORD(H)]", INVESTIGATE_TELEPORTATION)

/obj/brs_rift/proc/local_teleport_objects(var/list/objects)
	for(var/obj/O in objects)
		if (O.anchored)
			continue
		do_teleport(O, get_turf(O), 7)


//Телепорт в случайную безопасную точку на станции
/obj/brs_rift/proc/local_teleport_living_zloc(var/list/objects)
	for(var/mob/living/H in objects)
		var/turf/simulated/floor/F = find_safe_turf(zlevels = src.z)
		do_teleport(H, F)
		investigate_log("teleported [key_name_log(H)] to [COORD(F)]", INVESTIGATE_TELEPORTATION)

/obj/brs_rift/proc/local_teleport_objects_zloc(var/list/objects)
	for(var/obj/O in objects)
		if (O.anchored)
			continue
		var/turf/simulated/floor/F = find_safe_turf(zlevels = src.z)
		do_teleport(O, F)


//Перемешивание объектов между собой
/obj/brs_rift/proc/local_teleport_living_reshuffle(var/list/objects)
	var/temp_object
	for(var/mob/living/H in objects)
		if (temp_object)
			var/turf/T = get_turf(H)
			do_teleport(H, get_turf(temp_object))
			do_teleport(temp_object, T)
			investigate_log("teleported reshuffle [key_name_log(H)] and [key_name_log(temp_object)]", INVESTIGATE_TELEPORTATION)
			temp_object = null
		else
			temp_object = H

/obj/brs_rift/proc/local_teleport_objects_reshuffle(var/list/objects)
	var/temp_object
	for(var/obj/O in objects)
		if (O.anchored)
			continue
		if (temp_object)
			var/turf/T = get_turf(O)
			do_teleport(O, get_turf(temp_object))
			do_teleport(temp_object, T)
			temp_object = null
		else
			temp_object = O


//Телепорты всех объектов
/obj/brs_rift/proc/local_teleport_all(var/list/objects)
	local_teleport_living(objects)
	local_teleport_objects(objects)

/obj/brs_rift/proc/local_teleport_all_zloc(var/list/objects)
	local_teleport_living_zloc(objects)
	local_teleport_objects_zloc(objects)

/obj/brs_rift/proc/local_teleport_all_reshuffle(var/list/objects)
	local_teleport_living_reshuffle(objects)
	local_teleport_objects_reshuffle(objects)

//============ АОЕ эффекты ============
/obj/brs_rift/proc/local_explosive(var/list/objects)
	for(var/obj/O in objects)
		var/fs = force_sized
		explosion(O.loc, 0, 1, fs, 2*fs, flame_range = 3*fs, cause = O)

/obj/brs_rift/proc/local_emp(var/list/objects)
	for(var/obj/O in objects)
		var/fs = force_sized
		empulse(O.loc, fs, 2*fs, TRUE, name)


//============ Случайные эффекты из гранат ============
/obj/brs_rift/proc/local_random_grenade_living(var/list/objects)
	var/choosen = rand(1, 23)
	for(var/mob/living/carbon/human/H in objects)
		make_random_grenade_prime(choosen, H)

/obj/brs_rift/proc/local_random_grenade(var/list/objects)
	var/choosen = rand(1, 23)
	for(var/obj/O in objects)
		make_random_grenade_prime(choosen, O)

//Выбираем гранату и сразу же её подрываем, тем самым "воруя" её эффект хе-хе-хе
/obj/brs_rift/proc/make_random_grenade_prime(var/choosen, var/new_loc)
	var/obj/item/grenade/gr
	switch(choosen)
		if(1)
			gr = new /obj/item/grenade/smokebomb(new_loc)
		if(2)
			gr = new /obj/item/grenade/frag(new_loc)
		if(3)
			gr = new /obj/item/grenade/flashbang(new_loc)
		if(4)
			gr = new /obj/item/grenade/chem_grenade/meat(new_loc)
		if(5)
			gr = new /obj/item/grenade/chem_grenade/holywater(new_loc)
		if(6)
			gr = new /obj/item/grenade/chem_grenade/hellwater(new_loc)
		if(7)
			gr = new /obj/item/grenade/chem_grenade/drugs(new_loc)
		if(8)
			gr = new /obj/item/grenade/chem_grenade/ethanol(new_loc)
		if(9)
			gr = new /obj/item/grenade/chem_grenade/lube(new_loc)
		if(10)
			gr = new /obj/item/grenade/chem_grenade/large/monster(new_loc)
		if(11)
			gr = new /obj/item/grenade/chem_grenade/large/feast(new_loc)
		if(12)
			gr = new /obj/item/grenade/confetti(new_loc)
		if(13)
			gr = new /obj/item/grenade/clown_grenade(new_loc)
		if(14)
			gr = new /obj/item/grenade/bananade(new_loc)
		if(15)
			gr = new /obj/item/grenade/gas/knockout(new_loc)
		if(16)
			gr = new /obj/item/grenade/gluon(new_loc)
		if(17)
			gr = new /obj/item/grenade/chem_grenade/metalfoam(new_loc)
		if(18)
			gr = new /obj/item/grenade/chem_grenade/firefighting(new_loc)
		if(19)
			gr = new /obj/item/grenade/chem_grenade/incendiary(new_loc)
		if(20)
			gr = new /obj/item/grenade/chem_grenade/antiweed(new_loc)
		if(21)
			gr = new /obj/item/grenade/chem_grenade/cleaner(new_loc)
		if(22)
			gr = new /obj/item/grenade/chem_grenade/teargas(new_loc)
		if(23)
			gr = new /obj/item/grenade/chem_grenade/facid(new_loc)
	gr.prime()




//============ Изменение облика ============
//рандомизация днк
/*
		if(5)
			if(prob(prob_chance))
				message_admins("--- рандом ДНК")
				local_dna_random(objects)
			else
				message_admins("--- рандом Специи")
				local_species_random(objects)
		if(6)
			message_admins("--- специи перемешивание")
			local_species_reshuffle(objects)

/obj/brs_rift/proc/local_dna_random(var/list/objects)
	for(var/mob/living/carbon/human/H in objects)
		if(istype(H) && H.stat != DEAD && !H.notransform)
			randomize_species(H)

//Рандомизация расы и её преференса
/obj/brs_rift/proc/local_species_random(var/list/objects)
	for(var/mob/living/carbon/human/H in objects)
		if(istype(H) && H.stat != DEAD && !H.notransform)
			var/pickable_species = list("Human", "Unathi", "Diona", "Vulpkanin", "Tajaran", "Kidan", "Grey", "Plasmaman", "Machine", "Skrell", "Slime People", "Skeleton", "Drask", "Vox", "Nian")
			var/schoosen_species = pick(pickable_species)
			var/temp_name = H.dna.real_name
			var/datum/species/new_species = GLOB.all_species[schoosen_species]
			H.set_species(new_species, retain_damage = TRUE)
			H.rename_character(null, temp_name)

/proc/randomize_species(var/mob/living/carbon/human/H)
	var/datum/species/S = H.dna.species

	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	H.age = rand(AGE_MIN, AGE_MAX)

	//лицевое
	if(S in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
		head_organ.facial_colour = rand_hex_color()
		head_organ.sec_facial_colour = rand_hex_color()
		head_organ.hair_colour = rand_hex_color()
		head_organ.sec_hair_colour = rand_hex_color()
	head_organ.h_style = random_hair_style(H.gender, S)
	head_organ.f_style = random_facial_hair_style(H.gender, S)
	H.change_eye_color(rand_hex_color())

	if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
		head_organ.headacc_colour = rand_hex_color()
		head_organ.ha_style = random_head_accessory(S)

	if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
		H.m_styles["head"] = random_marking_style("head", S, null, null, head_organ.alt_head)
		H.m_colours["head"] = rand_hex_color()

	if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
		H.m_styles["body"] = random_marking_style("body", S)
		H.m_colours["body"] = rand_hex_color()

	if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
		var/body_accessory = random_body_accessory(S, S.optional_body_accessory)
		H.m_styles["tail"] = random_marking_style("tail", S, null, body_accessory)
		H.m_colours["tail"] = rand_hex_color()

	if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
		H.s_tone = random_skin_tone(S)
	if(S.bodyflags & HAS_SKIN_COLOR)
		H.skin_colour  = rand_hex_color()

	H.regenerate_icons()
	H.update_body()

//Перемешивание рас с сохранением оригинального имени
/obj/brs_rift/proc/local_species_reshuffle(var/list/objects)
	var/mob/living/carbon/human/temp_human
	for(var/mob/living/carbon/human/H in objects)
		if(istype(H) && H.stat != DEAD && !H.notransform)
			if (temp_human)
				reshuffle_species(H, temp_human)
				investigate_log("species reshuffle [key_name_log(H)] and [key_name_log(temp_human)]", INVESTIGATE_TELEPORTATION)
				temp_human = null
			else
				temp_human = H

/proc/reshuffle_species(var/mob/living/carbon/human/H, var/mob/living/carbon/human/T)
	var/mob/living/carbon/human/T_human = new()
	T.dna.transfer_identity(T_human)

	var/T_name = T.dna.real_name
	H.dna.transfer_identity(T)
	T.rename_character(null, T_name)

	var/H_name = H.dna.real_name
	T_human.dna.transfer_identity(H)
	H.rename_character(null, H_name)
*/
