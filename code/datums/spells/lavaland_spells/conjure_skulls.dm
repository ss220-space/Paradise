/obj/effect/proc_holder/spell/aoe/conjure/legion_skulls
	name = "Summon Skulls"
	desc = "Данное заклинание призывает три дружественных черепа легиона."

	school = "lavaland"
	base_cooldown = 15 SECONDS
	clothes_req = TRUE
	human_req = TRUE
	invocation = "TRAKI SUMON!"
	invocation_type = "shout"
	action_icon_state = "sumon_skulls"

	summon_type = list(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/magic)
	summon_amt = 3
	aoe_range = 1
	can_use_stunned = TRUE

	cast_sound = 'sound/magic/forcewall.ogg'

/obj/effect/proc_holder/spell/aoe/conjure/legion_skulls/cast(list/targets, mob/living/user = usr)
	. = ..()

	for(var/mob/skull in .)
		skull.faction += user.faction
