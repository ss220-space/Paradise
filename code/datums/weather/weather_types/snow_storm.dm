#define KRAMPUS_SPAWN_PROBABILITY 30
#define KRAMPUS_PER_PLAYER 13

/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this arctic planet, burying any area unfortunate enough to be in its path."
	probability = 99

	telegraph_message = span_warning("Drifting particles of snow begin to dust the surrounding area...")
	telegraph_duration = 40 SECONDS
	telegraph_overlay = "light_snow"
	telegraph_sound = 'sound/ambience/weather/snowstorm/snow_start.ogg'
	telegraph_sound_vol = /datum/looping_sound/snowstorm::volume + 10

	weather_message = span_userdanger("<i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i>")
	weather_overlay = "snow_storm"
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS

	end_duration = 10 SECONDS
	end_message = span_boldannounceic("The snowfall dies down, it should be safe to go outside again.")
	end_overlay = "light_snow"
	end_sound = 'sound/ambience/weather/snowstorm/snow_end.ogg'
	end_sound_vol = /datum/looping_sound/snowstorm::volume + 10

	area_type = /area
	target_trait = ZTRAIT_SNOWSTORM
	protected_areas = list(
		/area/maintenance,
		/area/turret_protected/ai_upload,
		/area/turret_protected/ai_upload_foyer,
		/area/turret_protected/ai,
		/area/storage/emergency,
		/area/storage/emergency2,
		/area/solar,
		/area/toxins/test_area,
		/area/engineering/engine,
		/area/crew_quarters/sleep,
		/area/security/brig,
		/area/shuttle,
		/area/space,
		/area/coldcolony/malta,
		/area/crew_quarters/bar/atrium/safe,
	)

	immunity_type = TRAIT_SNOWSTORM_IMMUNE

	weather_cooldown_upper = 20 MINUTES
	weather_cooldown_lower = 10 MINUTES

	var/list/affected_turfs_list

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

	var/snow_per_tick = 60


/datum/weather/snow_storm/proc/update_eligible_areas()
	var/list/eligible_areas = list()
	for(var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]

/datum/weather/snow_storm/telegraph()
	. = ..()
	affected_turfs_list = generate_turf_list()
	if(.)
		update_eligible_areas()

/datum/weather/snow_storm/start()
	GLOB.snowstorm_sounds.Cut() // it's passed by ref
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.snowstorm_sounds[impacted_area] = /datum/looping_sound/snowstorm
	return ..()

/datum/weather/snow_storm/fire()
	for(var/i in 1 to snow_per_tick)
		var/turf/turf = pick(affected_turfs_list)
		var/turf_hotness = T0C
		if(issimulatedturf(turf))
			var/turf/simulated/simulated = turf
			turf_hotness = simulated.air.temperature

		if(turf_hotness > T0C && prob(10 * (turf_hotness - T0C))) //Cloud disappears if it's too warm
			continue

		try_to_snowturf(turf, turf_hotness)

/datum/weather/snow_storm/proc/try_to_snowturf(turf/turf, turf_hotness = T0C)
	if(locate(/obj/effect/snow, turf))
		return

	new /obj/effect/snow/slowdown(turf)

/datum/weather/snow_storm/end()
	GLOB.snowstorm_sounds.Cut()
	. = ..()

	if(GLOB.new_year_celebration)
		for(var/obj/structure/flora/tree/pine/xmas/xmas_tree in GLOB.world_flora)
			xmas_tree.spawn_gifts()
		spawn_krampus(affected_turfs_list)

/datum/weather/snow_storm/weather_act(mob/living/target)
	var/temp_drop = -rand(20, 50)
	var/simulatuon_temp = T0C + temp_drop

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/cold_protection = 1 - human_target.get_cold_protection(simulatuon_temp)
		temp_drop *= cold_protection

	else if(istype(target, /mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/borer = target
		var/cold_protection = 1 - borer.host?.get_cold_protection(simulatuon_temp)
		temp_drop *= cold_protection

	target.adjust_bodytemperature(temp_drop)

/datum/weather/snow_storm/proc/can_spawn_krampus()
	var/players_count = num_station_players()
	var/krampus_count = get_krampus_count()

	if(players_count < KRAMPUS_PER_PLAYER)
		return FALSE

	var/krampus_need = round(players_count / KRAMPUS_PER_PLAYER)

	if(krampus_count > krampus_need)
		return FALSE

	if(!prob(KRAMPUS_SPAWN_PROBABILITY))
		return FALSE

	return TRUE

/datum/weather/snow_storm/proc/spawn_krampus(list/possible_turfs)
	set waitfor = FALSE

	if(!(can_spawn_krampus()))
		return

	var/image/krampus_image = image(/mob/living/carbon/true_devil/krampus::icon, /mob/living/carbon/true_devil/krampus::icon_state)
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Крампуса?", ROLE_DEVIL, FALSE, 30 SECONDS, source = krampus_image, role_cleanname = "Крампус")

	if(!length(candidates))
		return

	var/mob/living/carbon/true_devil/krampus/krampus = new(pick(possible_turfs))
	var/mob/dead/observer/candidate = pick(candidates)
	krampus.possess_by_player(candidate.ckey)
	krampus.mind.add_antag_datum(/datum/antagonist/krampus)

/datum/weather/snow_storm/proc/get_krampus_count()
	var/count = 0
	for(var/datum/antagonist/krampus/krampus in GLOB.antagonists)

		if(QDELETED(krampus.owner?.current) || krampus.owner.current.stat == DEAD)
			continue

		count++
	return count

#undef KRAMPUS_SPAWN_PROBABILITY
#undef KRAMPUS_PER_PLAYER
