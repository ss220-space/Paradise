/datum/action/cooldown/spell/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	smoke_type = /datum/effect_system/fluid_spread/smoke/bad
	smoke_amt = 5
	button_icon_state = "smoke"

/datum/action/cooldown/spell/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."
	button_icon_state = "parasmoke"
	background_icon_state = "bg_cult"
	cooldown_time = 20 SECONDS
	smoke_type = /datum/effect_system/fluid_spread/smoke/sleeping
