/**
 * # Fastload
 *
 * Special zones for fastload.dmm.
 * Each zone is marked with its own color, and each color corresponds to a specific floor.
 * You can edit the parameters on the floors, for your purposes.
 */

// MARK: Floor №3
/area/fastload
	name = "Fastload Room Yellow"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "fastload_yellow"
	has_gravity = STANDARD_GRAVITY
	area_flags = NONE

// MARK: Floor №2
/area/fastload/purple
	name = "Fastload Room Purple"
	icon_state = "fastload_purple"

// MARK: Floor №1
/area/fastload/blue
	name = "Fastload Room Blue"
	icon_state = "fastload_blue"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	hide_attacklogs = TRUE
