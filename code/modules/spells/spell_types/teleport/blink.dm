/datum/action/cooldown/spell/teleport/radius_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."
	button_icon_state = "blink"
	sound = 'sound/magic/blink.ogg'
	cooldown_time = 2 SECONDS
	cooldown_reduction_per_rank = 0.4 SECONDS
	smoke_type = /datum/effect_system/fluid_spread/smoke
	inner_tele_radius = 0
	outer_tele_radius = 6

	post_teleport_sound = 'sound/magic/blink.ogg'

/datum/action/cooldown/spell/teleport/radius_turf/blink/slow
	name = "Minor Blink"
	desc = "This spell randomly teleports you a short distance, you're still practising doing it quickly."
	cooldown_time = 8 SECONDS
