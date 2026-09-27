/datum/lazy_template/virtual_domain
	map_dir = "_maps/virtual_domains"
	key = "Virtual Domain"
	var/announce_to_ghosts = FALSE
	var/name = "Virtual Domain"
	var/desc = "Пустой домен."
	var/cost = BITRUNNER_COST_NONE
	var/difficulty = BITRUNNER_DIFFICULTY_NONE
	var/reward_points = BITRUNNER_REWARD_MIN
	var/domain_flags = NONE
	var/help_text = "Найдите зашифрованный контейнер и доставьте его на площадку выдачи."
	var/start_time
	var/datum/outfit/forced_outfit
	var/list/completion_loot
	var/list/secondary_loot = list()
	var/secondary_loot_generated = 0
	var/disk_reward_spawned = FALSE
	var/main_crate_points = 0
	var/main_crate_point_goal = 10
	var/main_crate_loc
	var/is_modular = FALSE
	var/list/datum/modular_mob_segment/mob_modules = list()
	var/modular_unique_mobs = FALSE
	var/mission_min_candidates = 0
	var/mission_max_candidates = 0
	var/list/obj/effect/mob_spawn/ghost_spawners
	var/list/mob/living/ghost_mobs
	var/spawner_role = "Antagonist"

/datum/lazy_template/virtual_domain/Destroy(force)
	ghost_spawners = null
	ghost_mobs = null
	return ..()

/datum/lazy_template/virtual_domain/proc/can_view_name(scanner_tier, server_points)
	return difficulty < scanner_tier && cost <= server_points + 5

/datum/lazy_template/virtual_domain/proc/can_view_reward(scanner_tier, server_points)
	return difficulty < (scanner_tier + 1) && cost <= server_points + 3

/datum/lazy_template/virtual_domain/proc/take_secondary_loot()
	var/path = pick_weight_classic(secondary_loot)
	if(isnull(path))
		return

	secondary_loot[path] -= 1
	return path

/datum/lazy_template/virtual_domain/proc/add_points(points_to_add = 1)
	main_crate_points += points_to_add
	if(main_crate_points >= main_crate_point_goal)
		reveal()

/datum/lazy_template/virtual_domain/proc/reveal()
	if(isnull(main_crate_loc))
		return

	var/turf/spawn_loc = get_turf(main_crate_loc)
	playsound(spawn_loc, 'sound/effects/phasein.ogg', 50, TRUE)
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/crate = new()
	crate.forceMove(spawn_loc)
	do_sparks(5, FALSE, spawn_loc)
	main_crate_loc = null

/datum/lazy_template/virtual_domain/proc/load_advanced_npcs(list/mob/lucky_ghosts)
	for(var/mob/lucky_ghost as anything in lucky_ghosts)
		if(!length(ghost_spawners))
			return

		var/obj/effect/mob_spawn/ghost_spawner = pick_n_take(ghost_spawners)
		var/mob/new_mob = ghost_spawner.create(lucky_ghost, name = lucky_ghost.real_name)
		LAZYADD(ghost_mobs, new_mob)

		notify_ghosts("[lucky_ghost.name] выбран на роль [spawner_role]!", source = new_mob, title = "001010110")

/datum/lazy_template/virtual_domain/proc/setup_domain(list/created_atoms)
	return

/proc/get_virtual_domains()
	var/static/list/domains
	if(!isnull(domains))
		return domains

	domains = list()
	for(var/template_key in GLOB.lazy_templates)
		var/datum/lazy_template/virtual_domain/domain = GLOB.lazy_templates[template_key]
		if(!istype(domain) || domain.type == /datum/lazy_template/virtual_domain)
			continue
		if(domain.domain_flags & DOMAIN_TEST_ONLY)
			continue
		domains += domain

	return domains

/proc/get_available_domains(scanner_tier, server_points)
	var/list/entries = list()

	for(var/datum/lazy_template/virtual_domain/domain as anything in get_virtual_domains())
		var/can_view = domain.can_view_name(scanner_tier, server_points)
		entries += list(list(
			"cost" = domain.cost,
			"desc" = can_view ? domain.desc : "Сканера не хватает, чтобы разобрать содержимое домена.",
			"difficulty" = domain.difficulty,
			"id" = domain.key,
			"is_modular" = domain.is_modular,
			"name" = can_view ? domain.name : DOMAIN_REDACTED,
			"reward" = domain.can_view_reward(scanner_tier, server_points) ? domain.reward_points : DOMAIN_REDACTED,
		))

	return entries
