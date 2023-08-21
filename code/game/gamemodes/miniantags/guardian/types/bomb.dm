/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "Будучи <b>Подрывником</b> у вас весьма посредственные боевые способности, но вы можете конвертировать любой предмет вокруг себя в скрытую бомбу на Alt+Click. Даже будучи в хозяине. Помните: бомбы живут минуту!"
	magic_fluff_string = "...и вытаскиваете Ученого, мастера взрывной смерти."
	tech_fluff_string = "Последовательность загрузки завершена. Взрывные модули активны. Голопаразитный рой активирован."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, способный незаметно заминировать предметы."
	var/bomb_cooldown = 0
	var/default_bomb_cooldown = 10 SECONDS

/mob/living/simple_animal/hostile/guardian/bomb/Stat()
	..()
	if(statpanel("Status"))
		if(bomb_cooldown >= world.time)
			stat(null, "Перезарядка до следующей бомбы: [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] секунд.")

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(get_dist(get_turf(src), get_turf(A)) > 3)
		to_chat(src, "<span class='danger'>Слишком далеко от [A] чтобы скрыть это как бомбу.</span>")
		return
	if(isobj(A) && can_plant(A))
		if(bomb_cooldown <= world.time && !stat)
			add_attack_logs(src, A, "booby trapped (summoner: [summoner])")
			to_chat(src, "<span class='danger'>Успех! Бомба на [A] взведена!</span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Ваш Подрывник взвел [A] для взрыва!</span>")
			bomb_cooldown = world.time + default_bomb_cooldown
			A.AddComponent(/datum/component/guardian_mine, src)
		else
			to_chat(src, "<span class='danger'>Ваши силы на перезарядке! Вы должны ждать ещё [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] секунд до установки следующей бомбы.</span>")

/mob/living/simple_animal/hostile/guardian/bomb/proc/can_plant(atom/movable/A)
	if(istype(A, /obj/mecha))
		var/obj/mecha/target = A
		if(target.occupant)
			to_chat(src, "<span class='warning'>Пилотируемые мехи непригодны для минирования!</span>")
			return FALSE
	if(istype(A, /obj/spacepod))
		var/obj/spacepod/target = A
		if(target.pilot)
			to_chat(src, "<span class='warning'>Челноки не пригодны для минирования!</span>")
			return FALSE
	if(istype(A, /obj/machinery/disposal)) // Have no idea why they just destroy themselves
		to_chat(src, "<span class='warning'>Бомбы не мусор! Нельзя минировать мусорки!</span>")
		return FALSE
	return TRUE

