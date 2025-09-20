// Given to ascended knock heretics, is a form of shapeshift that can turn into all 4 common heretic summons, and is not limited to 1 selection.
/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension
	name = "Высший полиморфизм"
	desc = "Заклинание, позволяющее вам принять облик другого сверхъестественного \
			существа, приобретая его способности. Вы можете изменить свой выбор в \
			любой момент, и если ваша форма умрёт, вы не умрёте."
	base_cooldown = 20 SECONDS
	//convert_damage = FALSE
	//die_with_shapeshifted_form = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "lock_ascension"
	possible_shapes = list(
		/mob/living/simple_animal/hostile/heretic_summon/ash_spirit,
		/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/ascended,
		/mob/living/simple_animal/hostile/heretic_summon/rust_walker,
		/mob/living/simple_animal/hostile/heretic_summon/stalker,
	)


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Shapeshift(mob/living/caster)
	. = ..()
	if(!.)
		return

	//buff our forms so this ascension ability isnt shit
	playsound(caster, 'sound/magic/demon_consume.ogg', 50, TRUE)
	var/mob/living/simple_animal/monster = .
	monster.AddComponent(/datum/component/seethrough_mob)
	monster.maxHealth *= 1.5
	monster.health = monster.maxHealth
	monster.melee_damage_lower = max((monster.melee_damage_lower * 2), 40)
	monster.melee_damage_upper = monster.melee_damage_upper / 2
	monster.transform *= 1.5
	monster.AddElement(/datum/element/wall_tearer)


/obj/effect/proc_holder/spell/shapeshift/eldritch/ascension/Restore(mob/living/caster)
	. = ..()
	shapeshift_type = null //pick another loser
