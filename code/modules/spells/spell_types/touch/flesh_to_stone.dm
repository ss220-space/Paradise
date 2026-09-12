/datum/action/cooldown/spell/touch/flesh_to_stone
	name = "Flesh to Stone"
	desc = "This spell charges your hand with the power to turn victims into inert statues for a long period of time."
	hand_path = /obj/item/melee/touch_attack/flesh_to_stone
	invocation = "STAUN EI!!"
	sound = 'sound/magic/fleshtostone.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS //100 deciseconds reduction per rank
	button_icon_state = "statue"

/obj/item/melee/touch_attack/flesh_to_stone
	name = "petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/datum/action/cooldown/spell/touch/flesh_to_stone/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/touch/flesh_to_stone/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/target = victim
	target.Stun(4 SECONDS)
	new /obj/structure/closet/statue(target.loc, target)
	return TRUE
