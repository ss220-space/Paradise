/datum/action/cooldown/spell/emplosion
	name = "Emplosion"
	desc = "This spell emplodes an area."
	button_icon_state = "emp"
	var/emp_heavy = 2
	var/emp_light = 3

/datum/action/cooldown/spell/emplosion/cast(atom/cast_on)
	. = ..()
	empulse(cast_on.loc, emp_heavy, emp_light, TRUE)

/datum/action/cooldown/spell/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 0.5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "NEC CANTIO"
	invocation_type = INVOCATION_SHOUT
	emp_heavy = 6
	emp_light = 10
	sound = 'sound/magic/disable_tech.ogg'
