/mob/living/simple_animal/hostile/carp/rift_carp
	name = "rift carp"
	health = 65
	maxHealth = 65
	melee_damage_lower = 18
	melee_damage_upper = 18
	carp_stamina_damage = 18
	speed = -0.2
	a_intent = INTENT_HARM
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	gold_core_spawnable = NO_SPAWN
	/// Ability which lets carp teleport around
	var/datum/action/innate/lesser_carp_rift/teleport


/mob/living/simple_animal/hostile/carp/rift_carp/Initialize(mapload)
	. = ..()
	teleport = new
	teleport.Grant(src)


/mob/living/simple_animal/hostile/carp/rift_carp/AttackingTarget()
	if(istype(target, /obj/structure/carp_rift))
		to_chat(src, span_warning("Вы почти укусили разлом, но вовремя остановились."))
		return

	if(isliving(target))
		var/mob/living/living_target = target
		if("carp" in living_target.faction)
			to_chat(src, span_warning("Вы почти укусили своего сородича, но вовремя остановились."))
			return
	. = ..()

