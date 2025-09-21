//Challenge Areas

/area/awaymission/challenge
	name = "Challenge"

/area/awaymission/challenge/start
	name = "Where Am I?"

/area/awaymission/challenge/main
	name = "Danger Room"
	icon_state = "away1"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/challenge/end
	name = "Administration"
	icon_state = "away2"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255


/obj/machinery/power/emitter/energycannon
	name = "Energy Cannon"
	anchored = TRUE

	idle_power_usage = 0
	active_power_usage = 0

	active = 1
	locked = 1
	state = 2
