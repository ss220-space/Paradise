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
	name = "energy cannon"
	desc = "A heavy duty industrial laser."
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

	idle_power_usage = 0
	active_power_usage = 0

	active = TRUE
	locked = TRUE
	welded = TRUE
