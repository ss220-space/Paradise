#define DEN_TEMPLATE "bitrunning_den.dmm"
#define DEN_TEST_OFFSET 12

/datum/unit_test/room_test/bitrunning

/datum/unit_test/room_test/bitrunning/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, anchor)
	var/obj/machinery/byteforge/forge = allocate(/obj/machinery/byteforge, locate(anchor.x + 1, anchor.y, anchor.z))
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console, locate(anchor.x, anchor.y + 1, anchor.z))

	TEST_ASSERT_EQUAL(console.find_server(), server, "the console did not find the server standing next to it")

	server.points = BITRUNNER_COST_LOW
	TEST_ASSERT(server.cold_boot_map(LAZY_TEMPLATE_KEY_BITRUNNING_XENO_NEST), "server failed to boot the xeno nest domain")
	TEST_ASSERT_NOTNULL(server.generated_domain, "server lost the reference to the loaded domain")
	TEST_ASSERT_NOTNULL(server.domain_reservation, "server lost the reference to the domain reservation")
	TEST_ASSERT(length(server.exit_turfs), "no exit turfs were collected from the domain")
	TEST_ASSERT(length(server.goal_turfs), "no goal turfs were collected from the domain")

	var/obj/structure/closet/crate/secure/bitrunning/encrypted/cache
	var/obj/modular_map_connector/safehouse
	for(var/turf/tile as anything in server.domain_reservation.reserved_turfs)
		cache ||= locate(/obj/structure/closet/crate/secure/bitrunning/encrypted) in tile
		safehouse ||= locate(/obj/modular_map_connector) in tile

	TEST_ASSERT_NOTNULL(cache, "the domain loaded without an encrypted cache")
	TEST_ASSERT_NOTNULL(safehouse, "the domain loaded without its modular safehouse")
	TEST_ASSERT(length(server.mutation_candidate_refs), "no mutation candidates were collected from the domain")
	TEST_ASSERT_NOTNULL(server.get_glitch_role(), "no glitch role was available at zero threat")
	TEST_ASSERT(server in get_glitch_ready_servers(), "the glitch event could not find the server running a domain")

	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human)
	var/obj/item/disk/bitrunning/item/tier1/program = allocate(/obj/item/disk/bitrunning/item/tier1)
	program.selected_path = /obj/item/pizzabox/infinite
	pilot.put_in_hands(program)

	var/mob/living/carbon/human/avatar = server.start_new_connection(pilot)
	TEST_ASSERT_NOTNULL(avatar, "server failed to build an avatar")
	TEST_ASSERT(locate(/obj/item/pizzabox/infinite) in avatar, "the carried program did not load its gear onto the avatar")
	TEST_ASSERT_EQUAL(server.retries_spent, 1, "building an avatar did not spend a hololadder")
	TEST_ASSERT(locate(/obj/structure/hololadder) in get_turf(avatar), "the avatar was not placed on a hololadder")

	var/mob/living/carbon/human/crewman = allocate(/mob/living/carbon/human, anchor)
	crewman.equipOutfit(/datum/outfit/job/cargo_tech)
	var/obj/item/radio/headset/crew_headset = crewman.l_ear
	var/obj/item/radio/headset/avatar_headset = avatar.l_ear
	var/supply_freq = SSradio.return_frequency(SUP_FREQ).frequency

	TEST_ASSERT(istype(avatar_headset, /obj/item/radio/headset/headset_cargo/virtual), "the avatar was not given a virtual headset")
	TEST_ASSERT(avatar_headset.receive_range(supply_freq, list(crewman.z)) > -1, "the avatar cannot hear the station on its virtual headset")
	TEST_ASSERT(crew_headset.receive_range(supply_freq, list(0)) > -1, "the station cannot hear a domain broadcast")
	TEST_ASSERT_EQUAL(crew_headset.receive_range(supply_freq, list(avatar.z)), -1, "an ordinary headset started hearing across z-levels")

	var/list/console_data = console.ui_data(pilot)
	TEST_ASSERT(console_data["connected"], "the console reported no server in its interface data")
	TEST_ASSERT_EQUAL(console_data["generated_domain"], LAZY_TEMPLATE_KEY_BITRUNNING_XENO_NEST, "the console reported the wrong loaded domain")
	TEST_ASSERT(length(console_data["available_domains"]), "the console offered no domains to load")

	var/points_before = server.points
	var/reward_points = server.generated_domain.reward_points
	cache.forceMove(pick(server.goal_turfs))

	TEST_ASSERT(server.domain_complete, "delivering the cache did not complete the domain")
	TEST_ASSERT_EQUAL(server.points, points_before + reward_points, "completing the domain did not award server points")

	sleep(2 SECONDS)

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward = locate() in get_turf(forge)
	TEST_ASSERT_NOTNULL(reward, "the byteforge did not materialize a decrypted cache")
	TEST_ASSERT(locate(/obj/item/stack/ore/iron) in reward, "the decrypted cache came without ore")
	TEST_ASSERT(locate(/obj/item/paper) in reward, "the decrypted cache came without a completion certificate")
	TEST_ASSERT(locate(/obj/item/toy/plushie/rouny) in reward, "the decrypted cache came without the domain completion loot")

	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod, locate(anchor.x + 1, anchor.y + 1, anchor.z))
	TEST_ASSERT_EQUAL(pod.resolve_outfit("[/datum/outfit/bit_avatar]"), /datum/outfit/bit_avatar, "the netpod rejected an outfit it offers")
	TEST_ASSERT_NULL(pod.resolve_outfit("[/obj/item/stack/sheet/metal]"), "the netpod accepted something that is not an outfit")

	server.scrub_vdom()
	TEST_ASSERT_NULL(server.generated_domain, "scrubbing did not clear the loaded domain")
	TEST_ASSERT_NULL(server.domain_reservation, "scrubbing did not release the domain reservation")
	TEST_ASSERT_EQUAL(length(server.exit_turfs), 0, "scrubbing did not clear the exit turfs")
	TEST_ASSERT_NULL(console.ui_data(pilot)["generated_domain"], "the console still reported a loaded domain after scrubbing")
	TEST_ASSERT(!length(get_glitch_ready_servers()), "the glitch event still offered a server with no domain loaded")

/datum/unit_test/room_test/bitrunning_escape

/datum/unit_test/room_test/bitrunning_escape/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, anchor)
	var/obj/machinery/byteforge/forge = allocate(/obj/machinery/byteforge, locate(anchor.x + 1, anchor.y, anchor.z))

	server.points = BITRUNNER_COST_LOW
	TEST_ASSERT(server.cold_boot_map(LAZY_TEMPLATE_KEY_BITRUNNING_XENO_NEST), "server failed to boot the xeno nest domain")

	server.threat = 50

	var/mob/living/carbon/human/glitch = allocate(/mob/living/carbon/human, pick(server.goal_turfs))
	glitch.mind_initialize()
	glitch.mind.add_antag_datum(/datum/antagonist/bitrunning_glitch/cyber_police)
	server.add_threats(glitch)
	server.emagged = TRUE

	server.station_spawn(glitch, forge)

	TEST_ASSERT_NOTNULL(glitch.GetComponent(/datum/component/glitch), "the escaping antag was not turned into a glitch")
	TEST_ASSERT_EQUAL(get_turf(glitch), get_turf(forge), "the escaping antag was not materialized at the byteforge")
	TEST_ASSERT(glitch.maxHealth >= 200, "the escaped glitch did not get its health boost")
	TEST_ASSERT(!(WEAKREF(glitch) in server.spawned_threat_refs), "the escaped glitch is still tracked as a domain threat")

	forge.obj_break()
	TEST_ASSERT_NOTNULL(glitch.alerts[ALERT_BITRUNNER_GLITCH], "breaking the byteforge did not alert the glitch")
	TEST_ASSERT(glitch.has_movespeed_modifier(/datum/movespeed_modifier/glitch_slowdown), "breaking the byteforge did not slow the glitch down")

	var/mob/living/carbon/human/late_threat = allocate(/mob/living/carbon/human, pick(server.goal_turfs))
	server.add_threats(late_threat)
	TEST_ASSERT_NULL(late_threat.GetComponent(/datum/component/virtual_entity), "a threat spawned on an emagged server was still bound to the domain")

	server.scrub_vdom()

/datum/unit_test/room_test/bitrunning_domains

/datum/unit_test/room_test/bitrunning_domains/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, anchor)
	allocate(/obj/machinery/byteforge, locate(anchor.x + 1, anchor.y, anchor.z))

	for(var/datum/lazy_template/virtual_domain/domain as anything in get_virtual_domains())
		server.points = domain.cost
		TEST_ASSERT(server.cold_boot_map(domain.key), "the server failed to boot [domain.name]")
		TEST_ASSERT(length(server.exit_turfs), "[domain.name] was mapped without hololadder spawns")
		TEST_ASSERT(length(server.goal_turfs), "[domain.name] was mapped without a delivery pad")

		var/found_cache = FALSE
		var/found_safehouse = FALSE
		var/mapped_spawners = 0
		var/list/mob/living/simple_animal/hostile/megafauna/bosses = list()
		for(var/turf/tile as anything in server.domain_reservation.reserved_turfs)
			if(locate(/obj/structure/closet/crate/secure/bitrunning/encrypted) in tile)
				found_cache = TRUE
			if(locate(/obj/modular_map_connector) in tile)
				found_safehouse = TRUE
			for(var/obj/effect/mob_spawn/spawner in tile)
				mapped_spawners += 1
			for(var/mob/living/simple_animal/hostile/megafauna/boss in tile)
				bosses += boss

		for(var/mob/living/simple_animal/hostile/megafauna/boss as anything in bosses)
			TEST_ASSERT(!boss.true_spawn, "[domain.name] left [boss.type] as a real megafauna")
			TEST_ASSERT(/obj/structure/closet/crate/secure/bitrunning/encrypted in boss.loot, "[domain.name] left [boss.type] without the cache in its loot")
			found_cache = TRUE

		TEST_ASSERT(found_cache || domain.main_crate_loc, "[domain.name] offers no path to an encrypted cache")
		TEST_ASSERT(found_safehouse, "[domain.name] did not load its modular safehouse")
		TEST_ASSERT_EQUAL(length(domain.ghost_spawners), mapped_spawners, "[domain.name] did not register every mapped ghost role spawner")
		server.scrub_vdom()

/datum/unit_test/room_test/bitrunning_den

/datum/unit_test/room_test/bitrunning_den/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/datum/map_template/den = GLOB.map_templates[DEN_TEMPLATE]
	TEST_ASSERT_NOTNULL(den, "the bitrunning den template was not preloaded")

	var/turf/origin = locate(anchor.x, anchor.y + DEN_TEST_OFFSET, anchor.z)
	TEST_ASSERT(den.load(origin), "the bitrunning den template failed to load")

	var/obj/machinery/quantum_server/server
	var/obj/machinery/computer/quantum_console/console
	var/obj/machinery/byteforge/forge
	var/obj/machinery/computer/bitrunner_orders/orders
	var/obj/machinery/power/apc/breaker
	var/list/netpods = list()
	var/list/spawns = list()

	for(var/turf/tile as anything in den.get_affected_turfs(origin))
		server ||= locate(/obj/machinery/quantum_server) in tile
		console ||= locate(/obj/machinery/computer/quantum_console) in tile
		forge ||= locate(/obj/machinery/byteforge) in tile
		orders ||= locate(/obj/machinery/computer/bitrunner_orders) in tile
		breaker ||= locate(/obj/machinery/power/apc) in tile

		var/obj/machinery/netpod/pod = locate() in tile
		if(pod)
			netpods += pod

		var/obj/effect/landmark/start/bitrunner/spawn_point = locate() in tile
		if(spawn_point)
			spawns += spawn_point

	TEST_ASSERT_NOTNULL(server, "the den was mapped without a quantum server")
	TEST_ASSERT_NOTNULL(console, "the den was mapped without a quantum console")
	TEST_ASSERT_NOTNULL(forge, "the den was mapped without a byteforge")
	TEST_ASSERT_NOTNULL(orders, "the den was mapped without an order console")
	TEST_ASSERT_NOTNULL(breaker, "the den was mapped without an apc")
	TEST_ASSERT_EQUAL(length(netpods), 3, "the den does not hold three netpods")

	var/datum/job/supply/bitrunner/job = SSjobs.GetJobType(/datum/job/supply/bitrunner)
	TEST_ASSERT_EQUAL(length(spawns), job.spawn_positions, "the den does not hold a spawn point per bitrunner slot")

	TEST_ASSERT_EQUAL(console.find_server(), server, "the console cannot reach the server it stands next to")
	TEST_ASSERT_EQUAL(server.get_random_nearby_forge(), forge, "the server cannot reach the byteforge")

	var/obj/item/card/id/payment = allocate(/obj/item/card/id)
	payment.bitrunning_points = 1000
	orders.inserted_id = payment

	var/orders_before = length(SSshuttle.shoppinglist)
	TEST_ASSERT(orders.try_order(null, "Flair", "Cornchips"), "the console refused an order the card could afford")
	TEST_ASSERT_EQUAL(length(SSshuttle.shoppinglist), orders_before + 1, "ordering from the console did not queue a supply order")
	TEST_ASSERT_EQUAL(payment.bitrunning_points, 900, "ordering did not charge the card its bitrunning points")

	var/datum/supply_order/placed = SSshuttle.shoppinglist[length(SSshuttle.shoppinglist)]
	TEST_ASSERT(/obj/item/reagent_containers/food/snacks/cornchips in placed.object.contains, "the queued order does not carry the ordered item")

	TEST_ASSERT(!orders.try_order(null, "Tech", "Elite Ability Program"), "the console sold an order the card could not afford")
	TEST_ASSERT_EQUAL(length(SSshuttle.shoppinglist), orders_before + 1, "a refused order still reached the shopping list")

	SSshuttle.shoppinglist -= placed
	orders.inserted_id = null

	for(var/obj/machinery/netpod/pod as anything in netpods)
		TEST_ASSERT_EQUAL(pod.find_server(), server, "a netpod was mapped out of range of the server")

#undef DEN_TEMPLATE
#undef DEN_TEST_OFFSET

#define SAFEHOUSE_CONFIG "strings/modular_maps/safehouse.toml"
#define SAFEHOUSE_TEST_OFFSET 12
#define SAFEHOUSE_TEST_SPAN 7

/datum/unit_test/room_test/bitrunning_safehouses

/datum/unit_test/room_test/bitrunning_safehouses/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/turf/origin = locate(anchor.x, anchor.y + SAFEHOUSE_TEST_OFFSET, anchor.z)
	var/list/config = rustg_read_toml_file(SAFEHOUSE_CONFIG)

	for(var/room_key in config["rooms"])
		for(var/module_name in config["rooms"][room_key]["modules"])
			for(var/turf/tile as anything in block(origin, locate(origin.x + SAFEHOUSE_TEST_SPAN, origin.y + SAFEHOUSE_TEST_SPAN, origin.z)))
				tile.empty()

			var/datum/map_template/module = new(path = "[config["directory"]][module_name]")
			TEST_ASSERT(module.load(origin), "safehouse module [module_name] failed to load")
			TEST_ASSERT_NOTNULL(locate(/obj/modular_map_connector) in origin, "safehouse module [module_name] does not carry its connector on the root tile")

#undef SAFEHOUSE_CONFIG
#undef SAFEHOUSE_TEST_OFFSET
#undef SAFEHOUSE_TEST_SPAN

/datum/unit_test/room_test/netguardian_smoke

/datum/unit_test/room_test/netguardian_smoke/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/mob/living/basic/netguardian/guardian = allocate(/mob/living/basic/netguardian, anchor)
	TEST_ASSERT_NOTNULL(guardian.ai_controller, "the netguardian lost its ai controller on spawn")
	var/datum/action/cooldown/spell/pointed/netguardian_rockets/rockets = locate() in guardian.mob_spell_list
	TEST_ASSERT_NOTNULL(rockets, "the netguardian was not granted its rocket ability")
	TEST_ASSERT_EQUAL(guardian.ai_controller.blackboard[BB_TARGETED_ACTION], rockets, "the rocket ability did not reach the ai blackboard")

	guardian.ai_controller.set_ai_status(AI_STATUS_OFF)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, locate(anchor.x + 4, anchor.y, anchor.z))
	TEST_ASSERT(rockets.cast(victim), "the netguardian rocket volley failed to fire")

/datum/unit_test/room_test/bitrunning_gimmicks

/datum/unit_test/room_test/bitrunning_gimmicks/Run()
	var/turf/anchor = run_loc_floor_bottom_left
	var/mob/living/carbon/human/avatar = allocate(/mob/living/carbon/human, anchor)

	for(var/disk_type in list(/obj/item/disk/bitrunning/gimmick/sports, /obj/item/disk/bitrunning/gimmick/dungeon))
		var/obj/item/disk/bitrunning/gimmick/disk = allocate(disk_type, anchor)
		for(var/choice in disk.selectable)
			disk.selected_path = disk.selectable[choice]
			TEST_ASSERT_EQUAL(disk.load_onto_avatar(avatar, avatar, NONE), NONE, "[choice] failed to load onto the avatar")
			TEST_ASSERT(locate(/obj/item/storage/briefcase) in avatar.get_all_contents(), "[choice] handed the avatar no loadout container")
			for(var/obj/item/storage/briefcase/kit in avatar.get_all_contents())
				qdel(kit)

/datum/unit_test/room_test/bitrunning_gondola/Run()
	var/mob/living/carbon/human/avatar = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	avatar.mind_initialize()
	var/datum/mind/avatar_mind = avatar.mind
	var/datum/reagent/virtual_tranquility/reagent = new
	reagent.reaction_mob(avatar, REAGENT_INGEST, 5)
	qdel(reagent)
	var/datum/disease/virus/transformation/virtual_gondola/disease = locate() in avatar.diseases
	TEST_ASSERT_NOTNULL(disease, "eating gondola meat did not infect the avatar")
	var/mob/living/simple_animal/pet/gondola/virtual_domain/gondola = disease.do_disease_transformation()
	TEST_ASSERT(istype(gondola), "the infected avatar did not become a virtual gondola")
	TEST_ASSERT_EQUAL(gondola.mind, avatar_mind, "gondola transformation lost the avatar mind")
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/gondola/cache = allocate(/obj/structure/closet/crate/secure/bitrunning/encrypted/gondola, run_loc_floor_bottom_left)
	TEST_ASSERT(gondola.move_force > cache.move_resist, "the transformed gondola cannot move the domain cache")

/datum/unit_test/room_test/bitrunning_tactical/Run()
	var/mob/living/carbon/human/agent = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	agent.equipOutfit(/datum/outfit/cyber_police/tactical)
	var/obj/item/mod/control/pre_equipped/glitch/mod = agent.back
	TEST_ASSERT(istype(mod), "Cyber Tactical did not receive the glitch MOD")
	TEST_ASSERT_NOTNULL(mod.bag, "the glitch MOD has no storage")
	var/magazines = 0
	for(var/obj/item/ammo_box/magazine/m556/magazine in mod.bag)
		magazines++
	TEST_ASSERT_EQUAL(magazines, 3, "Cyber Tactical did not receive three spare magazines")
	TEST_ASSERT(locate(/obj/item/gun/projectile/automatic/m90) in agent, "Cyber Tactical did not receive the M90")
	for(var/obj/item/part as anything in mod.get_parts())
		TEST_ASSERT(part.icon_state in icon_states(part.icon), "the glitch MOD has a missing part sprite: [part.icon_state]")

/datum/unit_test/room_test/bitrunning_transit/Run()
	var/turf/anchor = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/obj/structure/transit_tube/station/dispenser/reverse/departure = allocate(/obj/structure/transit_tube/station/dispenser/reverse, anchor, EAST)
	var/turf/destination = get_step(anchor, SOUTH)
	var/obj/structure/transit_tube/station/dispenser/reverse/arrival = allocate(/obj/structure/transit_tube/station/dispenser/reverse, destination, WEST)
	departure.setup_appearance()
	arrival.setup_appearance()
	departure.close_hatch()
	TEST_ASSERT_EQUAL(departure.hatch_state, TRANSIT_TUBE_OPEN, "the dispenser closed its hatch")
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/cache = allocate(/obj/structure/closet/crate/secure/bitrunning/encrypted, get_step(anchor, EAST))
	cache.Move(anchor, WEST)
	var/obj/structure/transit_tube_pod/dispensed/freight_pod = cache.loc
	TEST_ASSERT(istype(freight_pod), "pushing the cache into the dispenser did not load it")
	TEST_ASSERT(freight_pod.moving, "the freight pod did not launch")
	var/obj/structure/closet/crate/second_cache = allocate(/obj/structure/closet/crate, get_step(anchor, EAST))
	second_cache.Move(anchor, WEST)
	TEST_ASSERT(isturf(second_cache.loc), "the freight dispenser ignored its cooldown")
	var/mob/living/carbon/human/avatar = allocate(/mob/living/carbon/human, get_step(anchor, EAST))
	avatar.Move(anchor, WEST)
	var/obj/structure/transit_tube_pod/dispensed/passenger_pod = avatar.loc
	TEST_ASSERT(istype(passenger_pod), "the freight cooldown blocked the passenger")
	sleep(2 SECONDS)
	TEST_ASSERT_EQUAL(cache.loc, destination, "the cache did not arrive at the other dispenser")
	TEST_ASSERT_EQUAL(avatar.loc, destination, "the passenger did not arrive at the other dispenser")
	TEST_ASSERT(QDELETED(freight_pod), "the freight pod was not reclaimed")
	TEST_ASSERT(QDELETED(passenger_pod), "the passenger pod was not reclaimed")
	avatar.Move(get_step(destination, EAST), EAST)
	cache.Move(get_step(destination, WEST), WEST)
	cache.Move(destination, EAST)
	TEST_ASSERT(istype(cache.loc, /obj/structure/transit_tube_pod/dispensed), "the return dispenser did not load the cache")
	sleep(2 SECONDS)
	TEST_ASSERT_EQUAL(cache.loc, anchor, "the cache could not make the return trip")

/datum/unit_test/room_test/bitrunning_passthrough/Run()
	var/mob/living/carbon/human/teammate = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/borg/upgrade/modkit/human_passthrough/mod = allocate(/obj/item/borg/upgrade/modkit/human_passthrough)
	var/obj/projectile/kinetic/projectile = allocate(/obj/projectile/kinetic, run_loc_floor_bottom_left)
	mod.modify_projectile(projectile)
	projectile.Bump(teammate)
	TEST_ASSERT_EQUAL(teammate.getBruteLoss(), 0, "the passthrough projectile injured a teammate")
	TEST_ASSERT(!QDELETED(projectile), "the passthrough projectile was consumed by a teammate")
	TEST_ASSERT(teammate in projectile.permutated, "the passthrough projectile did not skip the teammate")
