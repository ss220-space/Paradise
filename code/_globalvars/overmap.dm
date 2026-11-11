GLOBAL_LIST_EMPTY(ship_engines)

GLOBAL_LIST_EMPTY(helm_computers)

GLOBAL_LIST_EMPTY(transponders)

GLOBAL_LIST_EMPTY(sensor_computers)

GLOBAL_LIST_EMPTY(sensor_arrays)

GLOBAL_LIST_EMPTY(overmap_request_consoles)

GLOBAL_LIST_EMPTY(navmap_computers)

GLOBAL_LIST_EMPTY(overmap_intercoms)

GLOBAL_LIST_INIT(overmap_ai_profiles, list(
	"light" = new /datum/overmap_ai_profile/light,
	"medium" = new /datum/overmap_ai_profile/medium,
	"heavy" = new /datum/overmap_ai_profile/heavy,
	"support" = new /datum/overmap_ai_profile/support,
	"flagship" = new /datum/overmap_ai_profile/support/flagship,
))

GLOBAL_LIST_INIT(default_ship_engines, list(
	/obj/machinery/ship_engine/small,
	/obj/machinery/ship_engine/large,
	/obj/machinery/ship_engine/huge,
	/obj/machinery/ship_engine/ion,
	/obj/machinery/ship_engine/ion/large,
	/obj/machinery/ship_engine/plasma,
	/obj/machinery/ship_engine/plasma/large,
	/obj/machinery/ship_engine/thruster,
	/obj/machinery/ship_engine/thruster/rcs,
))

GLOBAL_LIST_INIT(frontier_ship_engines, list(
	/obj/machinery/ship_engine/frontier_large,
	/obj/machinery/ship_engine/nfsd_stealth,
	/obj/machinery/ship_engine/nfsd_large,
	/obj/machinery/ship_engine/rogue,
	/obj/machinery/ship_engine/rogue_large,
	/obj/machinery/ship_engine/rogue_stealth,
	/obj/machinery/ship_engine/ussp,
	/obj/machinery/ship_engine/ussp_large,
))

GLOBAL_LIST_EMPTY(engine_consoles)

GLOBAL_LIST_INIT(overmap_shuttle_profiles, build_overmap_shuttle_profiles())

GLOBAL_LIST_EMPTY(landing_beacons)

GLOBAL_LIST_EMPTY(overmap_navigation_beacons)

GLOBAL_LIST_INIT(overmap_programmed_profiles, build_overmap_programmed_profiles())

GLOBAL_LIST_INIT(overmap_programmed_shuttle_ids, build_overmap_programmed_shuttle_ids())

GLOBAL_LIST_EMPTY(fog_proxy_backdrops)

GLOBAL_LIST_INIT(overmap_dock_hosts, list(
	"mining_home" = OVERMAP_HOST_STATION,
	"mining_away" = OVERMAP_HOST_LAVALAND,
	"laborcamp_home" = OVERMAP_HOST_STATION,
	"laborcamp_away" = OVERMAP_HOST_LAVALAND,
	"supply_home" = OVERMAP_HOST_STATION,
	"supply_away" = OVERMAP_SITE_CENTCOM,
	"emergency_home" = OVERMAP_HOST_STATION,
	"emergency_away" = OVERMAP_SITE_CENTCOM,
	"emergency_syndicate" = OVERMAP_SITE_SYNDICATE,
	"pod1_home" = OVERMAP_HOST_STATION,
	"pod2_home" = OVERMAP_HOST_STATION,
	"pod3_home" = OVERMAP_HOST_STATION,
	"pod4_home" = OVERMAP_HOST_STATION,
	"pod1_away" = OVERMAP_SITE_CENTCOM,
	"pod2_away" = OVERMAP_SITE_CENTCOM,
	"pod3_away" = OVERMAP_SITE_CENTCOM,
	"pod4_away" = OVERMAP_SITE_CENTCOM,
	"admin_home" = OVERMAP_HOST_STATION,
	"admin_away" = OVERMAP_SITE_CENTCOM,
	"ferry_home" = OVERMAP_HOST_STATION,
	"ferry_away" = OVERMAP_SITE_CENTCOM,
	"specops_home" = OVERMAP_HOST_STATION,
	"specops_away" = OVERMAP_SITE_CENTCOM,
	"gamma_home" = OVERMAP_HOST_STATION,
	"gamma_away" = OVERMAP_SITE_CENTCOM,
	"addition_goal_dock" = OVERMAP_SITE_CENTCOM,
	"shit_rain_base" = OVERMAP_SITE_CENTCOM,
	"trade_sol_base" = OVERMAP_SITE_TRADER,
	"trade_dock" = OVERMAP_HOST_STATION,
	"ombra_home" = OVERMAP_SITE_NINJA,
	"ombra_away" = OVERMAP_HOST_STATION,
	"vox_shuttle_away" = OVERMAP_SITE_VOX,
	"sit_away" = OVERMAP_SITE_SYNDICATE,
	"sit_arrivals" = OVERMAP_HOST_STATION,
	"sit_taipan" = OVERMAP_HOST_TAIPAN,
	"sst_away" = OVERMAP_SITE_SYNDICATE,
	"sst_home" = OVERMAP_HOST_STATION,
	"sst_taipan" = OVERMAP_HOST_TAIPAN,
	"syndicate_away" = OVERMAP_SITE_SYNDICATE,
	"syndicate_s" = OVERMAP_HOST_STATION,
	"syndicate_nw" = OVERMAP_HOST_STATION,
	"syndicate_ne" = OVERMAP_HOST_STATION,
	"syndicate_n" = OVERMAP_HOST_STATION,
	"syndicate_se" = OVERMAP_HOST_STATION,
	"syndicate_sw" = OVERMAP_HOST_STATION,
	"syndicate_z5" = OVERMAP_HOST_STATION,
	"syndicate_z3" = OVERMAP_HOST_STATION,
	"graveyard_church" = OVERMAP_HOST_STATION,
	"ntstation" = OVERMAP_HOST_STATION,
	"whiteship_home" = OVERMAP_HOST_STATION,
))

GLOBAL_LIST_INIT(overmap_shuttle_admin_hosts, list(
	"mining" = OVERMAP_SITE_CENTCOM,
	"laborcamp" = OVERMAP_SITE_CENTCOM,
	"supply" = OVERMAP_SITE_CENTCOM,
	"emergency" = OVERMAP_SITE_CENTCOM,
	"pod1" = OVERMAP_SITE_CENTCOM,
	"pod2" = OVERMAP_SITE_CENTCOM,
	"pod3" = OVERMAP_SITE_CENTCOM,
	"pod4" = OVERMAP_SITE_CENTCOM,
	"admin" = OVERMAP_SITE_CENTCOM,
	"ferry" = OVERMAP_SITE_CENTCOM,
	"specops" = OVERMAP_SITE_CENTCOM,
	"gamma_shuttle" = OVERMAP_SITE_CENTCOM,
	"addition_goal" = OVERMAP_SITE_CENTCOM,
	"shit_rain" = OVERMAP_SITE_CENTCOM,
	"trade_sol" = OVERMAP_SITE_TRADER,
	"ombra" = OVERMAP_SITE_NINJA,
	"vox_shuttle" = OVERMAP_SITE_VOX,
	"sit" = OVERMAP_SITE_SYNDICATE,
	"sst" = OVERMAP_SITE_SYNDICATE,
	"syndicate" = OVERMAP_SITE_SYNDICATE,
	"steel_rain" = OVERMAP_SITE_SYNDICATE,
	"ruins_civil_shuttle" = OVERMAP_SITE_CENTCOM,
	"ruins_transport_shuttle" = OVERMAP_SITE_CENTCOM,
	"funeral" = OVERMAP_SITE_CENTCOM,
))

GLOBAL_LIST_INIT(overmap_transponder_colors, list(
	"Белый" = COLOR_WHITE,
	"Красный" = COLOR_RED,
	"Жёлтый" = COLOR_VERY_SOFT_YELLOW,
	"Зелёный" = COLOR_ETHIOPIA_GREEN,
	"Лаймовый" = COLOR_JADE,
	"Синий" = COLOR_COMMAND_BLUE,
	"Фиолетовый" = COLOR_PURPLE,
	"Серый" = COLOR_SILVER,
))

GLOBAL_LIST_EMPTY(overmap_virtual_structures)

GLOBAL_LIST_INIT(monofrontier_ship_weapons, list(
	/obj/machinery/porta_turret/syndicate/ship/gun_50cal,
	/obj/machinery/porta_turret/syndicate/ship/adder,
	/obj/machinery/ship_gun/ak820,
	/obj/machinery/ship_gun/apollo,
	/obj/machinery/ship_gun/bofors,
	/obj/machinery/ship_gun/cerberus,
	/obj/machinery/ship_gun/charon,
	/obj/machinery/ship_gun/cyrexa,
	/obj/machinery/ship_gun/dymere,
	/obj/machinery/ship_gun/fang,
	/obj/machinery/ship_gun/hades,
	/obj/machinery/ship_gun/harbringer,
	/obj/machinery/porta_turret/syndicate/ship/hlgg9,
	/obj/machinery/porta_turret/syndicate/ship/l85,
	/obj/machinery/ship_gun/leviathan,
	/obj/machinery/ship_gun/paladin,
	/obj/machinery/ship_gun/prometheus,
	/obj/machinery/ship_gun/rac_30_draupnir,
	/obj/machinery/ship_gun/sandbox,
	/obj/machinery/ship_gun/scylla,
	/obj/machinery/ship_gun/serpent,
	/obj/machinery/ship_gun/t241,
	/obj/machinery/ship_gun/tartarus,
	/obj/machinery/ship_gun/thanatos,
	/obj/machinery/ship_gun/vanquisher
))

GLOBAL_LIST_EMPTY(overmap_weapons)

GLOBAL_LIST_INIT(overmap_ai_enemy_options, list("nt" = "Nanotrasen", "syndicate" = "Синдикат", "unknown" = "Неизвестные / без транспондера"))

GLOBAL_LIST_INIT(overmap_ai_default_enemies, list(
	"nt" = list("syndicate"),
	"syndicate" = list("nt", "unknown"),
	"rogue" = list("nt", "syndicate", "unknown"),
))
