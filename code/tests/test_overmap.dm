/datum/unit_test/overmap_penetration/Run()
	var/obj/projectile/shot = allocate(/obj/projectile)
	shot.damage = 100
	shot.ship_penetrations = 2
	shot.ship_penetration_chance = 100
	shot.ship_penetration_decay = 0.5
	TEST_ASSERT(shot.try_ship_penetration("first"), "The first contact should be penetrated.")
	TEST_ASSERT_EQUAL(shot.damage, 50, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(shot.ship_penetrations, 1, "Unexpected overmap state.")
	TEST_ASSERT(shot.try_ship_penetration("first"), "Objects on an already pierced tile must not consume another penetration.")
	TEST_ASSERT_EQUAL(shot.damage, 50, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(shot.ship_penetrations, 1, "Unexpected overmap state.")
	TEST_ASSERT(shot.try_ship_penetration("second"), "The second contact should consume the remaining penetration.")
	TEST_ASSERT_EQUAL(shot.damage, 25, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(shot.ship_penetrations, 0, "Unexpected overmap state.")
	TEST_ASSERT_NOT(shot.try_ship_penetration("third"), "An exhausted projectile must stop at a new contact.")

/datum/unit_test/overmap_navigation_policy/Run()
	var/obj/overmap/entity/vessel = allocate(/obj/overmap/entity)
	var/datum/component/overmap_flight/flight = vessel.AddComponent(/datum/component/overmap_flight)
	TEST_ASSERT_NOTNULL(flight, "Unexpected overmap state.")
	flight.navigate_world(10, 20)
	TEST_ASSERT_NOT(vessel.navigation_collision_disabled(), "Ordinary navigation must retain collisions.")
	flight.navigate_world(10, 20, ignore_collisions = TRUE, known_obstacles_only = FALSE, entry_box = list(0, 0, 5, 5))
	TEST_ASSERT(vessel.navigation_collision_disabled(), "A route must explicitly opt out of collisions.")
	flight.set_autopilot(FALSE)
	TEST_ASSERT_NOT(vessel.navigation_collision_disabled(), "Cancelling a route must restore collisions.")
	TEST_ASSERT_NULL(flight.navigation_entry_box, "A previous route must not retain its entry region.")
	flight.navigate_world(20, 30)
	TEST_ASSERT_NOT(vessel.navigation_collision_disabled(), "A new ordinary route must not inherit a programmed route's policy.")
	TEST_ASSERT(flight.navigation_known_obstacles_only, "Unexpected overmap state.")

/datum/unit_test/overmap_projected_explosion/Run()
	TEST_ASSERT_EQUAL(overmap_explosion_damage(EXPLODE_DEVASTATE), 250, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_damage(EXPLODE_HEAVY), 150, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_damage(EXPLODE_LIGHT), 60, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 0, 0, 1, 2, FALSE, 0, 90), EXPLODE_HEAVY, "Directional blasts must include their epicenter.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 0, 0, 1, 2, FALSE, 0, 360), EXPLODE_HEAVY, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 1, 0, 1, 2, FALSE, 0, 360), EXPLODE_LIGHT, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 2, 0, 1, 2, FALSE, 0, 360), 0, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 0, 0, 1, 2, TRUE, 0, 360), 0, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, -1, 0, 1, 2, FALSE, 0, 90), 0, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 1, 0, 1, 2, FALSE, 0, 90), EXPLODE_LIGHT, "Unexpected overmap state.")
	TEST_ASSERT_EQUAL(overmap_explosion_severity(0, 1, 0, 1, 2, FALSE, 350, 40), EXPLODE_LIGHT, "Unexpected overmap state.")

/datum/unit_test/room_test/overmap_fog/Run()
	var/turf/center = locate(run_loc_floor_bottom_left.x + 5, run_loc_floor_bottom_left.y + 5, run_loc_floor_bottom_left.z)
	var/datum/fog_scene/projected/scene = allocate(/datum/fog_scene/projected, 8)
	var/datum/fog_view/view = allocate(/datum/fog_view)
	view.center = center
	view.radius = 4
	scene.set_frame(center, center.x, center.y, center.x, center.y, 0)
	var/list/blockers = list()
	for(var/turf/tile as anything in RANGE_TURFS(view.radius, center))
		var/obj/effect/abstract/hull_proxy_tile/proxy = allocate(/obj/effect/abstract/hull_proxy_tile, tile)
		scene.drawn[proxy] = proxy
		scene.source_positions[proxy] = list(tile.x, tile.y)
		if(tile.x == center.x + 1 && abs(tile.y - center.y) <= 1)
			blockers[tile] = TRUE
			scene.add_opaque_point(list(tile.x, tile.y))
	var/was_rust_enabled = GLOB.fog_rust_enabled
	var/old_model = GLOB.fog_model
	GLOB.fog_rust_enabled = FALSE
	var/differences = 0
	for(var/model in list(FOG_MODEL_DIAGONAL, FOG_MODEL_UNION, FOG_MODEL_STRAIGHT, FOG_MODEL_PIXEL))
		GLOB.fog_model = model
		var/list/visible = fog_cast(center, view.radius, blockers = blockers)
		var/list/expected = fog_hidden_from_visible(visible, center, view.radius)
		var/list/actual = scene.hidden_for(view)
		for(var/atom/proxy, point_entry in scene.source_positions)
			var/list/point = point_entry
			var/turf/source = locate(point[1], point[2], center.z)
			if((source in expected) != (proxy in actual))
				differences++
	GLOB.fog_rust_enabled = was_rust_enabled
	GLOB.fog_model = old_model
	TEST_ASSERT_EQUAL(differences, 0, "Projected fog must use the same mask and source keys as ordinary tiles without Rust.")
