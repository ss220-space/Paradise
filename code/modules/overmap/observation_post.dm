/obj/overmap/entity/virtual_structure/observation_post
	name = "observation post"
	overmap_kind = OVERMAP_KIND_OTHER
	desc = "TEMP123TEMP"
	icon_state = "radio"
	map_color = "#a0a0a0"
	var/operational = TRUE
	var/template_path = "_maps/map_files/overmap/observation_post.dmm"
	var/template_loaded = FALSE
	var/loading_template = FALSE
	var/destroyed_cells = 0

/obj/overmap/entity/virtual_structure/observation_post/get_ru_names()
	return alist(
		NOMINATIVE = "наблюдательный пост",
		GENITIVE = "наблюдательного поста",
		DATIVE = "наблюдательному посту",
		ACCUSATIVE = "наблюдательный пост",
		INSTRUMENTAL = "наблюдательным постом",
		PREPOSITIONAL = "наблюдательном посте",
	)

/obj/overmap/entity/virtual_structure/observation_post/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	RegisterSignal(SSovermap, COMSIG_OVERMAP_RELAY_TRANSIT, PROC_REF(on_relay_transit))
	return INITIALIZE_HINT_LATELOAD

/obj/overmap/entity/virtual_structure/observation_post/LateInitialize()
	load_post_template()

/obj/overmap/entity/virtual_structure/observation_post/Destroy()
	UnregisterSignal(SSovermap, COMSIG_OVERMAP_RELAY_TRANSIT)
	if(SSovermap.observation_post == src)
		SSovermap.observation_post = null
	return ..()

/obj/overmap/entity/virtual_structure/observation_post/proc/load_post_template()
	if(template_loaded || loading_template)
		return TRUE
	var/path = template_path
	if(!fexists(path))
		path = "_maps/map_files/generic/observation_post.dmm"
	if(!fexists(path))
		path = "observation_post.dmm"
	if(!fexists(path))
		GLOB.overmap_virtual_structures -= src
		return FALSE
	loading_template = TRUE
	var/datum/map_template/template = new(path, WRAP_FILE(path), name)
	template_loaded = load_template(template, FALSE)
	overmap_kind = OVERMAP_KIND_OTHER
	qdel(template)
	loading_template = FALSE
	if(template_loaded)
		GLOB.overmap_virtual_structures |= src
	else
		GLOB.overmap_virtual_structures -= src
		QDEL_LIST_ASSOC_VAL(virtual_models)
		virtual_cells.Cut()
		hull_radius = 0
		radar_shape = null
	update_overmap_visibility()
	return template_loaded

/obj/overmap/entity/virtual_structure/observation_post/is_overmap_visible()
	return template_loaded

/obj/overmap/entity/virtual_structure/observation_post/in_free_flight()
	return template_loaded

/obj/overmap/entity/virtual_structure/observation_post/sector_obstacle_box(span)
	return template_loaded ? ..() : null

/obj/overmap/entity/virtual_structure/observation_post/is_ai_destroyed()
	return !operational

/obj/overmap/entity/virtual_structure/observation_post/damage_cell(list/cell, damage)
	if(cell[4] <= 0)
		return
	. = ..()
	if(cell[4] <= 0)
		destroyed_cells++
		if(operational && destroyed_cells / max(1, length(virtual_cells)) >= 0.35)
			operational = FALSE
			map_color = "#888888"
			identity_color = map_color
			radar_epoch++

/obj/overmap/entity/virtual_structure/observation_post/proc/on_relay_transit(datum/source, obj/overmap/entity/ship, datum/overmap_sector/from_sector, datum/overmap_sector/to_sector, arrived)
	SIGNAL_HANDLER
	if(!operational || radio_silence || !sector || !SSovermap.observation_comms_key || QDELETED(ship))
		return
	if(arrived ? to_sector != sector : from_sector != sector)
		return
	if(ship.overmap_kind != OVERMAP_KIND_SHUTTLE)
		return
	var/list/identity = ship.traffic_identity()
	var/affiliation = GLOB.overmap_ai_faction_options[identity["faction"]] || (identity["faction"] == "neutral" ? "нейтральная" : "не установлена")
	var/route = arrived ? "прибыл из сектора '[from_sector?.name || "неизвестно"]'" : "убыл в сектор '[to_sector?.name || "неизвестно"]'"
	var/body = "Контроль гиперпереходов: корабль класса [identity["class"]], фракция: [affiliation], номер: [identity["number"]], [route]."
	sector.add_comms_message(new /datum/overmap_sector_message(body, SSovermap.observation_comms_key, "Наблюдательный пост", sector.id))

/datum/controller/subsystem/overmap/proc/spawn_observation_post()
	var/datum/overmap_sector/sector = station_entity?.sector || local_sector
	if(!sector || !QDELETED(observation_post))
		return
	var/turf/spot = sector.get_random_open_turf()
	if(!spot)
		return
	observation_post = new(spot)
	observation_post.load_post_template()
	if(!ai_controller)
		ai_controller = new
	spot = ai_controller.spawn_position(sector, sector.coord_x(spot), sector.coord_y(spot), observation_post.hull_radius)
	if(!spot)
		QDEL_NULL(observation_post)
		return
	sector.add_object(observation_post, spot)
