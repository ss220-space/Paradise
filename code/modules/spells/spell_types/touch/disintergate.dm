/datum/action/cooldown/spell/touch/disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = /obj/item/melee/magic_hand/disintegrate
	invocation = "EI NATH!!"
	sound = 'sound/magic/disintegrate.ogg'
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS //100 deciseconds reduction per rank
	button_icon_state = "gib"

/obj/item/melee/magic_hand/disintegrate
	name = "disintegrating touch"
	desc = "This hand of mine glows with an awesome power!"
	icon_state = "disintegrate"
	item_state = "disintegrate"

/datum/action/cooldown/spell/touch/disintegrate/cast_on_hand_hit(obj/item/melee/magic_hand/hand, atom/victim, mob/living/carbon/caster)
	var/mob/M = victim
	do_sparks(4, FALSE, M.loc) //no idea what the 0 is
	M.gib()
	return TRUE
