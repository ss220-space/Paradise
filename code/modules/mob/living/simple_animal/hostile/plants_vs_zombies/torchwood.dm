/mob/living/simple_animal/hostile/plant/torchwood
	name = "torchwood"
	desc = "Выглядит как живой и слегка разумный горящий пень."

/mob/living/simple_animal/hostile/plant/torchwood/on_bullet_fly_through(obj/item/projectile/bullet)
	var/obj/item/projectile/pea/pea = bullet
	if (!istype(pea))
		return
	pea.fired++
