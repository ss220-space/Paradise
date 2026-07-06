/datum/action/cooldown/spell/touch/fake_disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = /obj/item/melee/touch_attack/fake_disintegrate
	invocation = "EI NATH!!"
	spell_requirements = NONE
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS//100 deciseconds reduction per rank
	sound = 'sound/magic/disintegrate.ogg'
	button_icon_state = "gib"

/obj/item/melee/touch_attack/fake_disintegrate
	name = "toy plastic hand"
	desc = "This hand of mine glows with an awesome power! Ok, maybe just batteries."
	icon_state = "disintegrate"
	item_state = "disintegrate"
	needs_permit = FALSE

/datum/action/cooldown/spell/touch/fake_disintegrate/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	do_sparks(4, FALSE, victim.loc)
	playsound(victim.loc, 'sound/goonstation/effects/gib.ogg', 50, TRUE)
	return TRUE
