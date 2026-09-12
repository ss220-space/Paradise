/datum/action/cooldown/spell/pointed/projectile/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = 1 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "ONI SOMA"
	invocation_type = INVOCATION_SHOUT
	active_msg = span_notice_alt("Your prepare to cast your fireball spell!")
	deactive_msg = span_notice_alt("You extinguish your fireball...for now.")
	projectile_type = /obj/projectile/magic/fireball
	button_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'

/datum/action/cooldown/spell/pointed/projectile/fireballl/hellish
	name = "Адское пламя"
	desc = "Это заклинание запускает сгусток адского пламени в цель."

	cooldown_time = 15 SECONDS

	invocation = "Quaeso, quemdam inter vos quaero!"

	projectile_type = /obj/projectile/magic/fireball/infernal
	button_icon_state = "bg_demon"

/datum/action/cooldown/spell/pointed/projectile/fireball/hellish/acsend
	projectile_type = /obj/projectile/magic/fireball/infernal/acsend
