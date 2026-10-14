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
	count = 16000
	// Droplets only need enough life to cross the view; anything longer just parks off-screen drops in count.
	lifespan = 3 SECONDS
	/// Horizontal wind applied to gravity x each severity tick. Positive blows right, negative left.
	var/wind_strength = 0
	/// Minimum spawned particles per tick at the lowest non-zero severity (for gentle easing in/out).
	var/min_spawn = 0
	/// Maximum spawned particles per tick at full severity.
	var/max_spawn = 0
	/// Constant horizontal acceleration superimposed on the wind. For slanted rain.
	var/base_gravity_x = 0

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
	if(islist(gravity) && length(gravity))
		gravity[1] = base_gravity_x + wind
	else
		gravity = list(base_gravity_x + wind)

// MARK: Rain
/particles/weather/rain
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot" = 1, "drop" = 4)
	color = "#f4ffff"
	position = generator(GEN_BOX, list(-510, -256, 0), list(400, 512, 0))
	grow = list(-0.01, -0.01)
	gravity = list(0, -10, 0.5)
	drift = generator(GEN_CIRCLE, 0, 1)
	friction = 0.3
	min_spawn = 50
	max_spawn = 300
	wind_strength = 2

/particles/weather/rain/light
	lifespan = 5 SECONDS
	grow = list(-0.04, -0.04)
	gravity = list(0, -9, 0.5)
	friction = 0.35
	min_spawn = 1
	max_spawn = 70

/particles/weather/rain/heavy
	icon_state = list("drop" = 2, "long_drop" = 5)
	scale = list(1.6, 1.2)
	grow = list(-0.016, -0.032)
	gravity = list(5, -20, 0.5)
	base_gravity_x = 5
	friction = 0.15
	rotation = -30
	min_spawn = 100
	max_spawn = 600

/particles/weather/rain/heavy/acid
	color = "#b7ffc9"
