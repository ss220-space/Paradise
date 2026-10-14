// Weather related particle systems, used by /datum/weather/particle to render world-space weather visuals.

/**
 * In-world emitter that owns a /particles/weather instance and renders it directly on its plane.
 */
/obj/effect/abstract/weather_holder
	icon = null
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	blocks_emissive = EMISSIVE_BLOCK_NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_NONE
	var/base_plane = RENDER_PLANE_PARTICLE_WEATHER

/**
 * Base type for weather particle visuals.
 */
/particles/weather
	spawning = 0
	width = 800
	height = 800
	count = 24000
	// Droplets only need enough life to cross the view; anything longer just parks off-screen drops in count.
	lifespan = 3 SECONDS
	/// Random horizontal acceleration layered on top of the gravity curve each severity tick.
	var/wind_strength = 0
	/// Spawn rate per tick at severity 0, so the weather eases in instead of snapping on.
	var/min_spawn = 0
	/// Spawn rate per tick at severity 1.
	var/max_spawn = 0
	/// Horizontal gravity at severity 0. Positive drifts east.
	var/gravity_x_min = 0
	/// Horizontal gravity at severity 1.
	var/gravity_x_max = 0
	/// Vertical gravity at severity 0. Negative falls down.
	var/gravity_y_min = -6
	/// Vertical gravity at severity 1.
	var/gravity_y_max = -14
	/// Depth gravity. Not animated by severity.
	var/gravity_z = 0.5
	/// Sprite rotation at severity 0, in degrees clockwise. Keeps near-vertical drops from carrying a steep icon.
	var/rotation_min = 0
	/// Sprite rotation at severity 1, in degrees clockwise.
	var/rotation_max = 0

/particles/weather/New()
	. = ..()
	gravity = list(gravity_x_min, gravity_y_min, gravity_z)
	rotation = rotation_min

/**
 * Adjusts the intensity of this particle field. Severity should be between 0 and 1 (0 stops spawning entirely).
 * wind_sign picks the horizontal direction so the wind can persist for the whole storm.
 */
/particles/weather/proc/animate_severity(severity, wind_sign)
	if(severity <= 0)
		spawning = 0
		return

	var/wind = wind_strength * severity * wind_sign
	spawning = LERP(min_spawn, max_spawn, severity)
	rotation = LERP(rotation_min, rotation_max, severity)
	gravity = list(LERP(gravity_x_min, gravity_x_max, severity) + wind, LERP(gravity_y_min, gravity_y_max, severity), gravity_z)

// MARK: Rain
/particles/weather/rain
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot" = 1, "drop" = 4)
	color = "#f4ffff"
	position = generator(GEN_BOX, list(-510, -256, 0), list(400, 512, 0))
	scale = list(1.6, 1.2)
	grow = list(-0.016, -0.032)
	rotation_min = 0
	rotation_max = -30
	drift = generator(GEN_CIRCLE, 0, 1)
	friction = 0.2
	wind_strength = 0
	min_spawn = 30
	max_spawn = 500
	gravity_x_min = 0
	gravity_x_max = 8
	gravity_y_min = -10
	gravity_y_max = -14

/particles/weather/rain/acid
	color = "#b7ffc9"
