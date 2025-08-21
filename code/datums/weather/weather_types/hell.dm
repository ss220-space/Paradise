#define TURF_LAVA_COUNT 10
#define TURF_PORTAL_COUNT 1
#define TURF_METEOR_COUNT 4
#define PORTAL_LIFETIME 30 SECONDS
#define PORTAL_MAX_IMPS 5
#define LAVA_TIME 10 SECONDS
#define LAVA_MODE "lava"
#define PORTAL_MODE "portal"
#define METEOR_MODE "meteor"
#define EMPTY_MODE "none"
#define TELEGRAPH_TIME 15 SECONDS

/datum/weather/hell
	name = "Ад"

	telegraph_duration = TELEGRAPH_TIME
	telegraph_message = null

	weather_message = null
	weather_duration_lower = 9 MINUTES
	weather_duration_upper = 13 MINUTES

	end_message = null
	end_duration = 10 SECONDS

	area_type = /area
	protected_areas = list(/area/space)
	target_trait = STATION_LEVEL

	immunity_type = TRAIT_WEATHER_IMMUNE

	self_fire = TRUE

	var/list/affected_turfs_list = list()
	var/static/list/possible_modes = list(LAVA_MODE = 10, PORTAL_MODE = 5, METEOR_MODE = 10, EMPTY_MODE = 50)
	var/static/music = 'sound/music/dies_irae.ogg'

/datum/weather/hell/telegraph()
	. = ..()
	SSshuttle.emergency.request(null, coefficient = 0.3)
	transform_mobs()
	for(var/area/area as anything in impacted_areas)
		for(var/turf/turf in area.get_contained_turfs())
			if(is_space_or_openspace(turf) || turf.density)
				continue
			affected_turfs_list += turf


/datum/weather/hell/proc/transform_mobs()
	var/list/devils
	for(var/datum/mind/mind as anything in SSticker?.mode?.devils)
		LAZYADD(devils, mind.has_antag_datum(/datum/antagonist/devil))
	transform_demons()
	transform_imps(devils)
	transform_shadows(devils)

/datum/weather/hell/proc/transform_demons()
	for(var/datum/mind/mind as anything in SSticker?.mode?.sintouched)
		if(!mind.current || mind.current.stat == DEAD)
			continue
		var/mob/mob = mind.current
		to_chat(mob, span_warning("Вы чувствуете необычайный прилив сил и изменения в теле. Ваши грехи берут над вами верх, изменяя до неузнаваемости."))
		addtimer(CALLBACK(src, PROC_REF(transform_demon), mob), TELEGRAPH_TIME)

/datum/weather/hell/proc/transform_demon(mob/mob)
	if(QDELETED(src))
		return
	var/demon_type = (prob(50))? /mob/living/simple_animal/demon/slaughter : /mob/living/simple_animal/demon/slaughter/laughter
	var/mob/new_mob = new demon_type(get_turf(mob))
	LAZYOR(new_mob.faction, "hell")
	new_mob.key = mob.key
	mob.dust()
	new_mob.mind?.add_antag_datum(/datum/antagonist/imp/demon)

/datum/weather/hell/proc/transform_imps(list/devils)
	for(var/datum/antagonist/devil/devil as anything in devils)
		for(var/datum/mind/soul as anything in devil.soulsOwned)
			if(!soul.current || soul.current.stat == DEAD)
				continue
			var/mob/mob = soul.current
			to_chat(mob, span_warning("Ваша проданная душа взывает к вам. Вы вынуждены повиноваться ее воле. Вы чувствуете серьезные изменения в своем теле."))
			addtimer(CALLBACK(src, PROC_REF(transform_imp), mob), TELEGRAPH_TIME)


/datum/weather/hell/proc/transform_imp(mob/mob)
	if(QDELETED(src))
		return
	var/mob/new_mob = new /mob/living/simple_animal/imp(get_turf(mob))
	LAZYOR(new_mob.faction, "hell")
	new_mob.key = mob.key
	mob.dust()
	new_mob.mind?.add_antag_datum(/datum/antagonist/imp/from_soul)

/datum/weather/hell/proc/transform_shadows(list/devils)
	for(var/datum/antagonist/devil/devil as anything in devils)
		for(var/datum/mind/soul as anything in devil.soulsOwned)
			if(!soul.current || soul.current.stat == DEAD)
				continue
			var/datum/objective/objective = locate(/datum/objective/assassinate/shadow_kill) in soul.objectives
			var/objective_check = objective?.check_completion()
			var/mob/mob = soul.current
			if(objective_check)
				to_chat(soul.current, span_warning("Вы выполнили свою цель и готовы к возвышению в нечто более могущественное. Вы чувствуете первые изменения."))
			else
				to_chat(soul.current, span_warning("Вы не выполнили свою цель. Поток силы, сочащейся из адского измерения неизбежно испепелит вас."))
			addtimer(CALLBACK(src, PROC_REF(transform_shadow), mob, objective_check), TELEGRAPH_TIME)

/datum/weather/hell/proc/transform_shadow(mob/mob, objective_check)
	if(QDELETED(src))
		return

	if(!objective_check)
		mob.dust()
		return

	var/mob/new_mob = new /mob/living/simple_animal/demon/shadow(get_turf(mob))
	LAZYOR(new_mob.faction, "hell")
	new_mob.key = mob.key
	mob.dust()
	new_mob.mind?.add_antag_datum(/datum/antagonist/imp/demon/shadow)

/datum/weather/hell/start()
	. = ..()
	for(var/mob/player in (GLOB.player_list))
		var/turf/player_loc = get_turf(player)
		var/z = player_loc.z
		if(!is_station_level(z) && !is_admin_level(z) && !is_reserved_level(z))
			continue
		SEND_SOUND(player, sound(
				music,
				channel = CHANNEL_BOSS_MUSIC,
				volume = player?.client?.prefs?.get_channel_volume(CHANNEL_BOSS_MUSIC) || 50,
				repeat = TRUE
			))

/datum/weather/hell/fire()
	switch(pickweight(possible_modes))
		if(LAVA_MODE)
			prosses_turfs(PROC_REF(run_lava), TURF_LAVA_COUNT)

		if(PORTAL_MODE)
			prosses_turfs(PROC_REF(run_portals), TURF_PORTAL_COUNT)

		if(METEOR_MODE)
			prosses_turfs(PROC_REF(run_meteors), TURF_METEOR_COUNT)

/datum/weather/hell/proc/prosses_turfs(proc_ref, count)
	for(var/i = 1; i <= count; i++)
		var/turf = pick(affected_turfs_list)
		call(src, proc_ref)(turf)

/datum/weather/hell/proc/run_lava(turf/affected_turf)
	var/lava_turf = /turf/simulated/floor/lava
	var/reset_turf = affected_turf.type
	affected_turf.ChangeTurf(lava_turf)
	addtimer(CALLBACK(src, PROC_REF(undo_lava), affected_turf, reset_turf), LAVA_TIME)

/datum/weather/hell/proc/undo_lava(turf/affected_turf, reset_turf)
	affected_turf.ChangeTurf(reset_turf)

/datum/weather/hell/proc/run_portals(turf/affected_turf)
	new /obj/structure/hell_rift(affected_turf)

/datum/weather/hell/proc/run_meteors(turf/affected_turf)
	var/obj/effect/temp_visual/fireball/meteor = new /obj/effect/temp_visual/fireball(affected_turf)
	addtimer(CALLBACK(src, PROC_REF(meteor_explosion), affected_turf), meteor.duration)

/datum/weather/hell/proc/meteor_explosion(turf/affected_turf)
	explosion(affected_turf, 0, 0, 3, 5, FALSE, FALSE)
	flame_radius(3, affected_turf, 5 SECONDS, BURN_LEVEL_TIER_6, FLAMESHAPE_STAR)

/datum/weather/hell/end()
	. = ..()

	if(QDELETED(src))
		return

	for(var/mob/player in (GLOB.player_list))
		SEND_SOUND(player, sound(null, channel = CHANNEL_BOSS_MUSIC))


/obj/structure/hell_rift
	name = "hell rift"
	desc = "Разлом, позволяющий адским существам проникнуть в этот мир."
	armor = list(MELEE = 30, BULLET = 40, LASER = 20, ENERGY = 100, BOMB = 50, BIO = 100, RAD = 0, FIRE = 100, ACID = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	color = "#7D1E20"
	light_color = COLOR_SOFT_RED
	light_range = 8
	anchored = TRUE
	density = FALSE
	plane = OBJ_LAYER
	var/imps_count = 0
	var/timer_id

/obj/structure/hell_rift/get_ru_names()
	return list(
		NOMINATIVE = "адский разлом",
		GENITIVE = "адского разлома",
		DATIVE = "адскому разлому",
		ACCUSATIVE = "адский разлом",
		INSTRUMENTAL = "адским разломом",
		PREPOSITIONAL = "адском разломе"
	)

/obj/structure/hell_rift/ComponentInitialize()
	. = ..()
	AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		simple_heal = 4, \
		limit_to_trait = TRAIT_HEALS_FROM_HELL_RIFTS, \
		healing_color = "#7D1E20", \
	)

/obj/structure/hell_rift/Initialize(mapload)
	. = ..()
	notify_ghosts("Завеса между мирами прорвана. Вы можете проникнуть в этот мир в качестве беса.", source = src, action = NOTIFY_FOLLOW, flashwindow = FALSE, title = "Открыт адский разлом")
	timer_id = QDEL_IN_STOPPABLE(src, PORTAL_LIFETIME)

/obj/structure/hell_rift/attack_ghost(mob/dead/observer/user)
	var/result = tgui_alert(user, "Вы действительно хотите стать бесом?", "", list("Да", "Нет")) == "Да"
	if(!result)
		return ..()
	var/mob/living/simple_animal/imp/imp = new(get_turf(loc))
	imp.key = user.key
	imp.mind?.add_antag_datum(/datum/antagonist/imp)
	imps_count++
	if(imps_count < PORTAL_MAX_IMPS)
		return
	deltimer(timer_id)
	qdel(src)
