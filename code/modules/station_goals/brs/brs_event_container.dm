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
//============== Local Events ==============
//==========================================
// Local Event Selection
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

// Local Related Event Selection
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


//============ Teleports ============

// Teleports in a small radius
/obj/brs_rift/proc/local_teleport_living(var/list/objects)
	for(var/mob/living/H in objects)
		do_teleport(H, get_turf(H), 7)
		investigate_log("teleported [key_name_log(H)] to [COORD(H)]", INVESTIGATE_TELEPORTATION)

/obj/brs_rift/proc/local_teleport_objects(var/list/objects)
	for(var/obj/O in objects)
		if (O.anchored)
			continue
		do_teleport(O, get_turf(O), 7)


// Teleport to a random safe point in the station
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


// Shuffling objects together
/obj/brs_rift/proc/local_teleport_living_reshuffle(var/list/objects)
	var/mob/living/temp_mob
	for(var/mob/living/H in objects)
		if (temp_mob)
			var/turf/T = get_turf(H)
			do_teleport(H, get_turf(temp_mob))
			do_teleport(temp_mob, T)
			investigate_log("switched places [key_name_log(H)][COORD(H.loc)] and [key_name_log(temp_mob)][COORD(temp_mob.loc)]", INVESTIGATE_TELEPORTATION)
			temp_mob = null
		else
			temp_mob = H

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


// Teleports of all objects
/obj/brs_rift/proc/local_teleport_all(var/list/objects)
	local_teleport_living(objects)
	local_teleport_objects(objects)

/obj/brs_rift/proc/local_teleport_all_zloc(var/list/objects)
	local_teleport_living_zloc(objects)
	local_teleport_objects_zloc(objects)

/obj/brs_rift/proc/local_teleport_all_reshuffle(var/list/objects)
	local_teleport_living_reshuffle(objects)
	local_teleport_objects_reshuffle(objects)

//============ AOE effects ============
/obj/brs_rift/proc/local_explosive(var/list/objects)
	for(var/obj/O in objects)
		var/fs = force_sized
		explosion(O.loc, 0, 1, fs, 2*fs, flame_range = 3*fs, cause = O)

/obj/brs_rift/proc/local_emp(var/list/objects)
	for(var/obj/O in objects)
		var/fs = force_sized
		empulse(O.loc, fs, 2*fs, TRUE, name)


//============ Random grenade effects ============
/obj/brs_rift/proc/local_random_grenade_living(var/list/objects)
	var/obj/item/grenade/grenade_type = get_random_grenade_type()
	for(var/mob/living/carbon/human/H in objects)
		if(grenade_type)
			var/obj/item/grenade/gr = new grenade_type(H)
			gr.prime()

/obj/brs_rift/proc/local_random_grenade(var/list/objects)
	var/obj/item/grenade/grenade_type = get_random_grenade_type()
	for(var/obj/O in objects)
		if(grenade_type)
			var/obj/item/grenade/gr = new grenade_type(O)
			gr.prime()

//Select a grenade and immediately detonate it, thereby "stealing" its effect ke-ke-ke
/obj/brs_rift/proc/get_random_grenade_type()
	var/static/list/grenade_list = list(
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/frag,
		/obj/item/grenade/flashbang,
		/obj/item/grenade/chem_grenade/meat,
		/obj/item/grenade/chem_grenade/holywater,
		/obj/item/grenade/chem_grenade/hellwater,
		/obj/item/grenade/chem_grenade/drugs,
		/obj/item/grenade/chem_grenade/ethanol,
		/obj/item/grenade/chem_grenade/lube,
		/obj/item/grenade/chem_grenade/large/monster,
		/obj/item/grenade/chem_grenade/large/feast,
		/obj/item/grenade/confetti,
		/obj/item/grenade/clown_grenade,
		/obj/item/grenade/bananade,
		/obj/item/grenade/gas/knockout,
		/obj/item/grenade/gluon,
		/obj/item/grenade/chem_grenade/metalfoam,
		/obj/item/grenade/chem_grenade/firefighting,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/grenade/chem_grenade/facid
		)

	return pick(grenade_list)
