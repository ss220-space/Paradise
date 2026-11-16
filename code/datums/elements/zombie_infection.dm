#define ZOMBIE_COUNT_TO_START 3
#define ZOMBIE_CYCLE_COOLDOWN 30 SECONDS

#define ZOMBIE_RATIO_CLEAR 10
#define ZOMBIE_RATIO_BIOHAZARD 20
#define ZOMBIE_RATIO_DIRECTIVE 45
#define ZOMBIE_RATIO_ENDGAME 70

#define ZOMBIE_STAGE_STARTED (1 << 0)
#define ZOMBIE_STAGE_BIOHAZARD (1 << 1)
#define ZOMBIE_STAGE_DIRECTIVE (1 << 2)
#define ZOMBIE_STAGE_ENDGAME (1 << 3)

/datum/element/zombie_infection
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/list/infected = list()
	var/stage_flags = NONE

/datum/element/zombie_infection/Attach(datum/target)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	infected |= target
	if(!(stage_flags & ZOMBIE_STAGE_STARTED) && length(infected) >= ZOMBIE_COUNT_TO_START)
		stage_flags |= ZOMBIE_STAGE_STARTED
		zombie_cycle()
	return ..()

/datum/element/zombie_infection/proc/zombie_cycle()
	var/players_count = num_station_players() || 1
	var/infected_count = infected_count()
	var/infected_percent = (infected_count / (infected_count + players_count)) * 100

	if(infected_percent < ZOMBIE_RATIO_CLEAR)
		stage_flags = NONE
		SSshuttle?.remove_hostile_environment(src)
		SSsecurity_level.set_level(SEC_LEVEL_RED)
		return

	if(infected_percent >= ZOMBIE_RATIO_BIOHAZARD && !(stage_flags & ZOMBIE_STAGE_BIOHAZARD))
		stage_flags |= ZOMBIE_STAGE_BIOHAZARD
		GLOB.major_announcement.announce(
			message = "Вспышка биологической угрозы 10-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой! Особая директива распечатана на всех консолях связи.",
			new_title = ANNOUNCE_BIOHAZARD_RU,
			new_sound = 'sound/effects/siren-spooky.ogg',
			new_sound2 = 'sound/AI/outbreak7.ogg'
		)
		SSticker?.mode?.special_directive()
		SSshuttle?.emergency.cancel()
		SSshuttle?.add_hostile_environment(src)
		SSsecurity_level.set_level(SEC_LEVEL_GAMMA)
		addtimer(CALLBACK(src, PROC_REF(zombie_cycle)), ZOMBIE_CYCLE_COOLDOWN)
		return

	if(infected_percent >= ZOMBIE_RATIO_DIRECTIVE && !(stage_flags & ZOMBIE_STAGE_DIRECTIVE))
		stage_flags |= ZOMBIE_STAGE_DIRECTIVE
		directive_7_12()
		addtimer(CALLBACK(src, PROC_REF(zombie_cycle)), ZOMBIE_CYCLE_COOLDOWN)
		return

	if(infected_percent >= ZOMBIE_RATIO_ENDGAME && !(stage_flags & ZOMBIE_STAGE_ENDGAME))
		stage_flags |= ZOMBIE_STAGE_ENDGAME
		launch_endgame_missile()
		addtimer(CALLBACK(src, PROC_REF(zombie_cycle)), ZOMBIE_CYCLE_COOLDOWN)
		return

	addtimer(CALLBACK(src, PROC_REF(zombie_cycle)), ZOMBIE_CYCLE_COOLDOWN)

/datum/element/zombie_infection/proc/infected_count()
	var/count = 0
	for(var/mob/infected_mob as anything in infected)
		var/turf/location = get_turf(infected_mob)
		if(location && is_station_level(location.z) && infected_mob?.mind)
			count++
	return count

/datum/element/zombie_infection/Detach(datum/source, ...)
	infected -= source
	return ..()

#undef ZOMBIE_COUNT_TO_START
#undef ZOMBIE_RATIO_CLEAR
#undef ZOMBIE_RATIO_BIOHAZARD
#undef ZOMBIE_RATIO_DIRECTIVE
#undef ZOMBIE_RATIO_ENDGAME
#undef ZOMBIE_STAGE_STARTED
#undef ZOMBIE_STAGE_BIOHAZARD
#undef ZOMBIE_STAGE_DIRECTIVE
#undef ZOMBIE_STAGE_ENDGAME
#undef ZOMBIE_CYCLE_COOLDOWN
