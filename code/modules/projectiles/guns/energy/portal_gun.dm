#define PORTAL_GUN_MODE_PAIR "pair"
#define PORTAL_GUN_MODE_LOCATION "location"
#define PORTAL_GUN_MIN_LIFESPAN (10 SECONDS)
#define PORTAL_GUN_MAX_LIFESPAN (2 MINUTES)
#define PORTAL_GUN_DEFAULT_LIFESPAN (30 SECONDS)
#define PORTAL_GUN_BASE_FLUID_COST 5
#define PORTAL_GUN_COST_TIME_STEP (30 SECONDS)

/obj/item/reagent_containers/cup/portal_fluid_canister
	name = "portal fluid canister"
	desc = "Компактный герметичный картридж для квантового транспортного раствора."
	gender = MALE
	icon = 'icons/obj/weapons/portal_gun.dmi'
	icon_state = "portal_fluid_canister_empty"
	item_state = "beaker"
	w_class = WEIGHT_CLASS_SMALL
	volume = 100
	possible_transfer_amounts = list(5, 10, 20, 25, 50, 100)
	resistance_flags = ACID_PROOF | FIRE_PROOF

/obj/item/reagent_containers/cup/portal_fluid_canister/get_ru_names()
	return alist(
		NOMINATIVE = "картридж для портальной жидкости",
		GENITIVE = "картриджа для портальной жидкости",
		DATIVE = "картриджу для портальной жидкости",
		ACCUSATIVE = "картридж для портальной жидкости",
		INSTRUMENTAL = "картриджем для портальной жидкости",
		PREPOSITIONAL = "картридже для портальной жидкости",
	)

/obj/item/reagent_containers/cup/portal_fluid_canister/on_reagent_change()
	update_appearance(UPDATE_ICON_STATE)
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_held_items()

/obj/item/reagent_containers/cup/portal_fluid_canister/update_icon_state()
	if(reagents?.get_reagent_amount(/datum/reagent/portal_fluid))
		icon_state = "portal_fluid_canister"
		return
	icon_state = "portal_fluid_canister_empty"

/obj/item/reagent_containers/cup/portal_fluid_canister/full
	list_reagents = list(/datum/reagent/portal_fluid = 100)

/obj/item/ammo_casing/energy/rick_portal
	projectile_type = /obj/projectile/energy/rick_portal
	select_name = "portal"
	fire_sound = 'sound/weapons/portal_gun.ogg'
	muzzle_flash_color = "#43F45B"
	harmful = FALSE

/obj/item/ammo_casing/energy/rick_portal/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	. = ..()
	if(BB && isturf(target))
		BB.range = max(round(get_dist_euclidean(user, target), 1), 1)

/obj/projectile/energy/rick_portal
	name = "portal bolt"
	icon = 'icons/obj/weapons/portal_gun.dmi'
	icon_state = "portal_bolt"
	hitsound = SFX_SPARKS
	nodamage = TRUE
	speed = 1
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_color = "#43F45B"
	ricochets_max = 0
	reflectability = REFLECTABILITY_NEVER

/obj/projectile/energy/rick_portal/get_ru_names()
	return alist(
		NOMINATIVE = "портальный сгусток",
		GENITIVE = "портального сгустка",
		DATIVE = "портальному сгустку",
		ACCUSATIVE = "портальный сгусток",
		INSTRUMENTAL = "портальным сгустком",
		PREPOSITIONAL = "портальном сгустке",
	)

/obj/projectile/energy/rick_portal/proc/anchor_portal()
	var/obj/item/gun/portal_gun/portal_gun = firer_source_atom
	if(!istype(portal_gun))
		return
	portal_gun.create_portal(get_turf(src), firer)

/obj/projectile/energy/rick_portal/on_hit(atom/target)
	anchor_portal()
	return ..()

/obj/projectile/energy/rick_portal/on_range()
	anchor_portal()
	return ..()

/obj/effect/portal/rick
	name = "interdimensional portal"
	desc = "Непрозрачная зелёная поверхность дрожит, словно жидкость."
	icon = 'icons/obj/weapons/portal_gun.dmi'
	fail_icon = null
	failed_teleport = FALSE
	failchance = 0
	light_color = "#43F45B"
	can_mecha_pass = TRUE
	create_sparks = FALSE

/obj/effect/portal/rick/get_ru_names()
	return alist(
		NOMINATIVE = "межпространственный портал",
		GENITIVE = "межпространственного портала",
		DATIVE = "межпространственному порталу",
		ACCUSATIVE = "межпространственный портал",
		INSTRUMENTAL = "межпространственным порталом",
		PREPOSITIONAL = "межпространственном портале",
	)

/obj/effect/portal/rick/examine(mob/user)
	. = ..()
	if(!target)
		. += span_warning("Поверхность гладкая и глухая — второй конец ещё не пробит.")

/obj/effect/portal/rick/can_teleport(atom/movable/mover, silent = FALSE)
	if(!target)
		return FALSE
	return ..()

/obj/item/gun/portal_gun
	name = "portal gun"
	desc = "Компактное устройство, пробивающее устойчивые проходы в пространстве. Работает на квантовом транспортном растворе."
	gender = FEMALE
	icon = 'icons/obj/weapons/portal_gun.dmi'
	icon_state = "portal_gun_empty"
	item_state = "portal_gun_empty"
	lefthand_file = 'icons/mob/inhands/weapons/portal_gun_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/portal_gun_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	fire_delay = 1 SECONDS
	accuracy = GUN_ACCURACY_SNIPER
	clumsy_check = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	fire_sound = 'sound/weapons/portal_gun.ogg'
	fire_sound_text = "портальный разряд"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	origin_tech = "bluespace=7;engineering=6;plasmatech=5"
	var/obj/item/reagent_containers/cup/portal_fluid_canister/fluid_canister
	var/obj/effect/portal/rick/entrance_portal
	var/obj/effect/portal/rick/exit_portal
	var/portal_mode = PORTAL_GUN_MODE_PAIR
	var/portal_lifespan = PORTAL_GUN_DEFAULT_LIFESPAN
	var/selected_location

/obj/item/gun/portal_gun/get_ru_names()
	return alist(
		NOMINATIVE = "портальная пушка",
		GENITIVE = "портальной пушки",
		DATIVE = "портальной пушке",
		ACCUSATIVE = "портальную пушку",
		INSTRUMENTAL = "портальной пушкой",
		PREPOSITIONAL = "портальной пушке",
	)

/obj/item/gun/portal_gun/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/energy/rick_portal(src)
	register_item_context()
	update_appearance(UPDATE_ICON_STATE)

/obj/item/gun/portal_gun/Destroy()
	close_portals()
	QDEL_NULL(fluid_canister)
	return ..()

/obj/item/gun/portal_gun/examine(mob/user)
	. = ..()
	. += span_notice("Режим: <b>[portal_mode == PORTAL_GUN_MODE_PAIR ? "парный" : "локация"]</b>, время жизни портала — <b>[portal_lifespan / (1 SECONDS)]</b> сек.")
	if(portal_mode == PORTAL_GUN_MODE_LOCATION)
		. += span_notice("Назначение: <b>[selected_location || "не выбрано"]</b>.")
	if(entrance_portal && !exit_portal)
		. += span_notice("Первый портал уже пробит и ждёт пару.")
	if(!fluid_canister)
		. += span_warning("Картридж не установлен.")
		return
	var/fluid_amount = fluid_canister.reagents.get_reagent_amount(/datum/reagent/portal_fluid)
	. += span_notice("В картридже осталось <b>[fluid_amount]</b> единиц портальной жидкости, выстрел стоит <b>[calculate_fluid_cost()]</b>.")

/obj/item/gun/portal_gun/attackby(obj/item/item, mob/living/user, list/modifiers)
	if(!istype(item, /obj/item/reagent_containers/cup/portal_fluid_canister))
		return ..()

	if(fluid_canister)
		balloon_alert(user, "картридж уже установлен!")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(item, src))
		return ATTACK_CHAIN_PROCEED

	fluid_canister = item
	add_fingerprint(user)
	update_appearance(UPDATE_ICON_STATE)
	user.update_held_items()
	balloon_alert(user, "картридж установлен")
	SStgui.update_uis(src)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/gun/portal_gun/attack_self(mob/living/user)
	ui_interact(user)

/obj/item/gun/portal_gun/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!entrance_portal && !exit_portal)
		balloon_alert(user, "нет активных порталов")
		return
	close_portals()
	balloon_alert(user, "порталы закрыты")

/obj/item/gun/portal_gun/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = portal_mode == PORTAL_GUN_MODE_PAIR && entrance_portal ? "Пробить выход" : "Пробить портал"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/gun/portal_gun/update_icon_state()
	if(!fluid_canister)
		icon_state = "portal_gun_empty"
		item_state = "portal_gun_empty"
		return
	if(fluid_canister.reagents.get_reagent_amount(/datum/reagent/portal_fluid))
		icon_state = "portal_gun"
		item_state = "portal_gun"
		return
	icon_state = "portal_gun_canister_empty"
	item_state = "portal_gun_canister_empty"

/obj/item/gun/portal_gun/can_shoot(mob/user)
	if(!fluid_canister)
		return FALSE
	if(portal_mode == PORTAL_GUN_MODE_LOCATION && !selected_location)
		return FALSE
	return fluid_canister.reagents.get_reagent_amount(/datum/reagent/portal_fluid) >= calculate_fluid_cost()

/obj/item/gun/portal_gun/shoot_with_empty_chamber(mob/living/user)
	if(!fluid_canister)
		balloon_alert(user, "нет картриджа!")
		return
	if(portal_mode == PORTAL_GUN_MODE_LOCATION && !selected_location)
		balloon_alert(user, "локация не выбрана!")
		return
	balloon_alert(user, "недостаточно жидкости!")
	playsound(user, 'sound/weapons/empty.ogg', 50, TRUE)

/obj/item/gun/portal_gun/newshot()
	if(chambered && !chambered.BB)
		chambered.newshot()

/obj/item/gun/portal_gun/process_fire(zone_override, secondary_fire = FALSE)
	newshot()
	return ..()

/obj/item/gun/portal_gun/handle_chamber()
	return

/obj/item/gun/portal_gun/proc/calculate_fluid_cost(portal_count)
	if(isnull(portal_count))
		portal_count = portal_mode == PORTAL_GUN_MODE_LOCATION ? 2 : 1
	var/time_cost = CEILING(portal_lifespan / PORTAL_GUN_COST_TIME_STEP, 1) - 1
	return portal_count * (PORTAL_GUN_BASE_FLUID_COST + time_cost)

/obj/item/gun/portal_gun/proc/is_valid_portal_turf(turf/portal_turf)
	if(!portal_turf || portal_turf.density || is_in_teleport_proof_area(portal_turf))
		return FALSE
	if(locate(/obj/effect/portal) in portal_turf)
		return FALSE
	for(var/atom/movable/blocker in portal_turf)
		if(blocker.density && blocker.anchored)
			return FALSE
	return TRUE

/obj/item/gun/portal_gun/proc/find_destination_turf(area/destination_area, randomize = TRUE)
	var/list/candidates = destination_area.get_turfs_from_all_zlevels()
	if(randomize)
		candidates = shuffle(candidates)
	for(var/turf/candidate as anything in candidates)
		if(!is_valid_portal_turf(candidate))
			continue
		if(!is_safe_turf(candidate, extended_safety_checks = TRUE, dense_atoms = TRUE))
			continue
		return candidate

/obj/item/gun/portal_gun/proc/create_portal(turf/impact_turf, mob/creator)
	if(!is_valid_portal_turf(impact_turf) || !can_shoot(creator))
		if(creator)
			balloon_alert(creator, "портал нестабилен!")
		return

	if(portal_mode == PORTAL_GUN_MODE_LOCATION)
		create_location_portals(impact_turf, creator)
		return
	create_paired_portal(impact_turf, creator)

/obj/item/gun/portal_gun/proc/create_paired_portal(turf/impact_turf, mob/creator)
	if(entrance_portal && exit_portal)
		close_portals()

	var/fluid_cost = calculate_fluid_cost(portal_count = 1)
	if(!entrance_portal)
		entrance_portal = new(impact_turf, null, src, portal_lifespan, creator, FALSE)
		fluid_canister.reagents.remove_reagent(/datum/reagent/portal_fluid::id, fluid_cost)
		investigate_log("was used by [key_name_log(creator)] to anchor an unpaired portal at [COORD(entrance_portal)].", INVESTIGATE_TELEPORTATION)
		finish_portal_creation(creator)
		return

	exit_portal = new(impact_turf, get_turf(entrance_portal), src, portal_lifespan, creator, FALSE)
	entrance_portal.target = impact_turf
	fluid_canister.reagents.remove_reagent(/datum/reagent/portal_fluid::id, fluid_cost)
	investigate_log("was used by [key_name_log(creator)] to link portals between [COORD(entrance_portal)] and [COORD(exit_portal)].", INVESTIGATE_TELEPORTATION)
	finish_portal_creation(creator)

/obj/item/gun/portal_gun/proc/create_location_portals(turf/impact_turf, mob/creator)
	var/area/destination_area = GLOB.teleportlocs[selected_location]
	if(!destination_area || destination_area.tele_proof)
		balloon_alert(creator, "локация недоступна!")
		return

	var/turf/destination_turf = find_destination_turf(destination_area)
	if(!destination_turf || destination_turf == impact_turf)
		balloon_alert(creator, "нет безопасного выхода!")
		return

	close_portals()
	entrance_portal = new(impact_turf, destination_turf, src, portal_lifespan, creator, FALSE)
	exit_portal = new(destination_turf, impact_turf, src, portal_lifespan, creator, FALSE)
	fluid_canister.reagents.remove_reagent(/datum/reagent/portal_fluid::id, calculate_fluid_cost(portal_count = 2))
	investigate_log("was used by [key_name_log(creator)] to open a portal from [COORD(impact_turf)] to [COORD(destination_turf)].", INVESTIGATE_TELEPORTATION)
	finish_portal_creation(creator)

/obj/item/gun/portal_gun/proc/finish_portal_creation(mob/creator)
	update_appearance(UPDATE_ICON_STATE)
	creator?.update_held_items()
	SStgui.update_uis(src)

/obj/item/gun/portal_gun/proc/close_portals()
	var/obj/effect/portal/rick/old_entrance = entrance_portal
	var/obj/effect/portal/rick/old_exit = exit_portal
	entrance_portal = null
	exit_portal = null
	if(!QDELETED(old_entrance))
		qdel(old_entrance)
	if(!QDELETED(old_exit))
		qdel(old_exit)
	SStgui.update_uis(src)

/obj/item/gun/portal_gun/portal_destroyed(obj/effect/portal/destroyed_portal)
	var/obj/effect/portal/rick/other_portal
	if(destroyed_portal == entrance_portal)
		entrance_portal = null
		other_portal = exit_portal
		exit_portal = null
	else if(destroyed_portal == exit_portal)
		exit_portal = null
		other_portal = entrance_portal
		entrance_portal = null
	if(!QDELETED(other_portal))
		qdel(other_portal)
	SStgui.update_uis(src)

/obj/item/gun/portal_gun/proc/eject_canister(mob/user)
	if(!fluid_canister)
		return
	var/obj/item/reagent_containers/cup/portal_fluid_canister/old_canister = fluid_canister
	fluid_canister = null
	old_canister.forceMove(drop_location())
	user.put_in_hands(old_canister, ignore_anim = FALSE)
	update_appearance(UPDATE_ICON_STATE)
	user.update_held_items()
	balloon_alert(user, "картридж извлечён")
	SStgui.update_uis(src)

/obj/item/gun/portal_gun/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/gun/portal_gun/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortalGun", "Портальная пушка")
		ui.open()

/obj/item/gun/portal_gun/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/nanomaps))

/obj/item/gun/portal_gun/proc/build_location_markers(list/station_level_numbers)
	var/list/markers = list()
	for(var/location_name in GLOB.teleportlocs)
		var/area/destination_area = GLOB.teleportlocs[location_name]
		if(!destination_area || destination_area.tele_proof)
			continue
		var/turf/marker_turf = find_destination_turf(destination_area, randomize = FALSE)
		if(!marker_turf || !(marker_turf.z in station_level_numbers))
			continue
		markers += list(list(
			"name" = location_name,
			"x" = marker_turf.x,
			"y" = marker_turf.y,
			"z" = marker_turf.z,
		))
	return markers

/obj/item/gun/portal_gun/ui_static_data(mob/user)
	var/static/list/location_markers
	var/list/station_level_numbers = levels_by_trait(STATION_LEVEL)
	var/list/station_level_names = list()

	for(var/z_level in station_level_numbers)
		station_level_names += check_level_trait(z_level, STATION_LEVEL)

	if(isnull(location_markers))
		location_markers = build_location_markers(station_level_numbers)

	return list(
		"stationLevelNum" = station_level_numbers,
		"stationLevelName" = station_level_names,
		"locations" = location_markers,
	)

/obj/item/gun/portal_gun/ui_data(mob/user)
	var/list/data = list()
	var/fluid_amount = fluid_canister?.reagents.get_reagent_amount(/datum/reagent/portal_fluid) || 0
	data["hasCanister"] = !!fluid_canister
	data["fluidAmount"] = fluid_amount
	data["fluidCapacity"] = fluid_canister?.volume || 0
	data["mode"] = portal_mode
	data["lifespan"] = portal_lifespan / (1 SECONDS)
	data["selectedLocation"] = selected_location
	data["requiredFluid"] = calculate_fluid_cost()
	data["hasEntrance"] = !!entrance_portal
	data["hasExit"] = !!exit_portal
	return data

/obj/item/gun/portal_gun/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("set_mode")
			var/new_mode = params["mode"]
			if(new_mode != PORTAL_GUN_MODE_PAIR && new_mode != PORTAL_GUN_MODE_LOCATION)
				return FALSE
			if(portal_mode != new_mode)
				close_portals()
			portal_mode = new_mode
		if("set_lifespan")
			var/new_lifespan = text2num(params["lifespan"])
			if(isnull(new_lifespan))
				return FALSE
			portal_lifespan = clamp(new_lifespan * (1 SECONDS), PORTAL_GUN_MIN_LIFESPAN, PORTAL_GUN_MAX_LIFESPAN)
		if("set_location")
			var/new_location = params["location"]
			var/area/destination_area = GLOB.teleportlocs[new_location]
			if(!destination_area || destination_area.tele_proof)
				return FALSE
			selected_location = new_location
		if("close_portals")
			close_portals()
		if("eject_canister")
			eject_canister(ui.user)

#undef PORTAL_GUN_MODE_PAIR
#undef PORTAL_GUN_MODE_LOCATION
#undef PORTAL_GUN_MIN_LIFESPAN
#undef PORTAL_GUN_MAX_LIFESPAN
#undef PORTAL_GUN_DEFAULT_LIFESPAN
#undef PORTAL_GUN_BASE_FLUID_COST
#undef PORTAL_GUN_COST_TIME_STEP
