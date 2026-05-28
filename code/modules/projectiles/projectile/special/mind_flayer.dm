/obj/projectile/beam/mindflayer
	name = "flayer ray"

/obj/projectile/beam/mindflayer/get_ru_names()
	return list(
		NOMINATIVE = "заряд мозгоёба",
		GENITIVE = "заряда мозгоёба",
		DATIVE = "заряду мозгоёба",
		ACCUSATIVE = "заряд мозгоёба",
		INSTRUMENTAL = "зарядом мозгоёба",
		PREPOSITIONAL = "заряде мозгоёба",
	)

/obj/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.apply_damage(20, BRAIN)
		M.AdjustHallucinate(20 SECONDS)
		M.last_hallucinator_log = name
