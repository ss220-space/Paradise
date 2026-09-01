/datum/action/cooldown/spell/teleport/area_teleport/wizard
	name = "Teleport"
	desc = "This spell teleports you to an area of your selection."
	button_icon_state = "spell_teleport"
	sound = 'sound/magic/teleport_diss.ogg'
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS
	spell_max_level = 3
	invocation = "SCYAR NILA" // gets punctuation auto applied
	invocation_type = INVOCATION_SHOUT
	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 2
	post_teleport_sound = 'sound/magic/teleport_app.ogg'

