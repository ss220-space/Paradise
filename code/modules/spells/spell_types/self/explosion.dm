/datum/action/cooldown/spell/explosion
	name = "Explosion"
	desc = "This spell explodes an area."
	button_icon_state = "explosion"
	var/ex_severe = 0
	var/ex_heavy = 0
	var/ex_light = 0
	var/ex_flash = 0
	var/ex_flame = 0

/datum/action/cooldown/spell/explosion/cast(atom/cast_on)
	. = ..()
	explosion(cast_on.loc, devastation_range = ex_severe, heavy_impact_range = ex_heavy, light_impact_range = ex_light, flame_range = ex_flash, flame_range = ex_flame)

