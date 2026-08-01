/area/misc/testroom
	name = "Unit Test Room"
	icon_state = "test_room"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	// Mobs should be able to see inside the testroom
	static_lighting = FALSE
	base_lighting_alpha = 255

// will be unused once kurper gets his login interface patch done
/area/misc/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	has_gravity = STANDARD_GRAVITY
	ambient_buzz = null
