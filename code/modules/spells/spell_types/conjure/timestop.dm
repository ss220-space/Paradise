/datum/action/cooldown/spell/conjure/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	cooldown_time = 50 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS
	invocation = "TOKI WO TOMARE"
	invocation_type = INVOCATION_SHOUT

	button_icon_state = "time"

	summon_type = list(/obj/effect/timestop/wizard)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/timestop/Grant(mob/grant_to)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_TIME_STOP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/action/cooldown/spell/conjure/timestop/Remove(mob/living/remove_from)
	. = ..()
	REMOVE_TRAIT(remove_from, TRAIT_TIME_STOP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))
