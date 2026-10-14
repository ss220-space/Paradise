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
	count = 8000

	lifespan = 30 SECONDS
	fade = 1 SECONDS
	fadein = 0.5 SECONDS

	/// Horizontal wind applied to gravity x each severity tick. Positive blows right, negative left.
	var/wind_strength = 0
	/// Minimum spawned particles per tick at the lowest non-zero severity (for gentle easing in/out).
	var/min_spawn = 0
	/// Maximum spawned particles per tick at full severity.
	var/max_spawn = 0

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
		gravity[1] = wind
	else
		gravity = list(wind)

/particles/weather/rain
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "drop"
	color = "#ccffff"
	position = generator(GEN_BOX, list(-510, -256, 0), list(400, 512, 0))
	grow = list(-0.01, -0.01)
	gravity = list(0, -10, 0.5)
	drift = generator(GEN_CIRCLE, 0, 1)
	friction = 0.3
	min_spawn = 50
	max_spawn = 300
	wind_strength = 5
	spin = 0
