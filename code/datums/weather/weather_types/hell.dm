#define TURF_PROSSES_COUNT 100
#define LAVA_PROB 40
#define METEOR_PROB 50
#define PORTAL_PROB 10
#define LAVA_TIME 2 SECONDS
#define LAVA_MODE 1
#define PORTAL_MODE 2
#define METEOR_MODE 3
#define EMPTY_MODE 4

/datum/weather/hell
	name = "Ад"

	telegraph_duration = 2 SECONDS
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
	var/static/list/possible_modes = list(LAVA_MODE = 10, PORTAL_MODE = 10, METEOR_MODE = 20, EMPTY_MODE = )

/datum/weather/hell/start()
	. = ..()
	SSshuttle.emergency.request(null, coefficient = 0.3)
	for(var/area/area as anything in impacted_areas)
		for(var/turf/turf in area.get_contained_turfs())
			if(is_space_or_openspace(turf) || turf.density)
				continue
			affected_turfs_list += turf


/datum/weather/hell/fire()




/obj/structure/hell_rift
	name = "hell rift"
	desc = "Разлом, позвляющий бесам проникнуть из ада в этот мир."
	armor = list("melee" = 30, "bullet" = 40, "laser" = 20, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	color = "#7D1E20"
	light_color = LIGHT_COLOR_DARKRED
	light_range = 8
	anchored = TRUE
	density = FALSE
	plane = OBJ_LAYER

/obj/structure/hell_rift/attack_ghost(mob/dead/observer/user)
	var/result = tgui_alert(user, "Вы действительно хотите стать бесом?", "", list("Да", "Нет")) == "Да"
	if(!result)
		return ..()
	var/mob/living/simple_animal/imp/imp = new(get_turf(loc))
	imp.key = user.key
	imp.mind.add_antag_datum(/datum/antagonist/imp)
