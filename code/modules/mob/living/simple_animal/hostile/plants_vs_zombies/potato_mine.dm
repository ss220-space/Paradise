/mob/living/simple_animal/hostile/plant/potato_mine
	name = "potato_mine"
	desc = "Выглядит как живая, взрывоопасная и слегка разумная картошка."

/mob/living/simple_animal/hostile/plant/potato_mine/death(gibbed)
	. = ..(gibbed)
	var/turf/simulated/floor/ivy/T = get_turf(src)
	T.mine_mob = null

/mob/living/simple_animal/hostile/plant/potato_mine/New()
	. = ..()
	var/turf/simulated/floor/ivy/ivy_turf = get_turf(src)
	ivy_turf.mine_mob = src
	sleep(10 SECONDS) // Для проверки работоспособности. Позже поменять на норм значение
	if (!is_dead(src))
		qdel(ivy_turf.mine_mob)
		ivy_turf.mine_mob = null
		ivy_turf.has_ready_mine = TRUE
