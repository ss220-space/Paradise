// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>Вы не можете себе этого позволить!</span>")
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Блоб"
	set name = "Перемещение к Ядру"
	set desc = "Переместиться обратно к вашему Ядру."

	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Блоб"
	set name = "Перемещение к Узлу"
	set desc = "Переместиться обратно к выбранному Ззлу."

	if(GLOB.blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= GLOB.blob_nodes.len; i++)
			var/obj/structure/blob/node/B = GLOB.blob_nodes[i]
			nodes["Узел Блоба #[i] ([get_location_name(B)])"] = B
		var/node_name = input(src, "Выберите узел для перемещения.", "Перемещение к Узлу") in nodes
		var/obj/structure/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/toggle_node_req()
	set category = "Блоб"
	set name = "Переключить Требования Узла"
	set desc = "Переключение требуется узлу для размещения Фабрик и Ресурсных Блобов."
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, "<span class='warning'>Вам требуется ближайший узел или ядро для размещения Фабрик и Ресурсных Блобов.</span>")
	else
		to_chat(src, "<span class='warning'>Вам больше не требуется ближайший узел или ядро для размещения Фабрик и Ресурсных Блобов.</span>")

/mob/camera/blob/verb/create_shield_power()
	set category = "Блоб"
	set name = "Создать/Улучшить Крепкого Блоба (15)"
	set desc = "Создать/Улучшить Крепкого Блоба. Использование этого на существующем Крепком Блобе преобразует его в Отражающего Блоба, способного отражать большинство энергетических снарядов, но делает его намного слабее для грубых атак."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	var/obj/structure/blob/shield/S = locate(/obj/structure/blob/shield) in T

	if(!S)
		if(!B)//We are on a blob
			to_chat(src, "Здесь нет Блоба!")
			return

		else if(!istype(B, /obj/structure/blob/normal))
			to_chat(src, "Невозможно использовать этого блоба, найди другой.")
			return

		else if(!can_buy(15))
			return

		B.color = blob_reagent_datum.color
		B.change_to(/obj/structure/blob/shield)
	else

		if(istype(S, /obj/structure/blob/shield/reflective))
			to_chat(src, "<span class='warning'>Здесь уже есть Отражающий Блоб!</span>")
			return


		else if(S.obj_integrity < S.max_integrity * 0.5)
			to_chat(src, "<span class='warning'>Этот Крепкий Блоб слишком поврежден, чтобы его изменить!</span>")
			return

		else if (!can_buy(15))
			return

		to_chat(src, "<span class='warning'>Вы выделяете отражающее вещество на Крепкого Блоба, позволяя ему отражать энергетические снаряды за счет снижение сопротивления к грубым атакам.</span>")

		S.change_to(/obj/structure/blob/shield/reflective)
		S.color = blob_reagent_datum.color
	return

/mob/camera/blob/verb/create_resource()
	set category = "Блоб"
	set name = "Создать Ресурсного Блоба (40)"
	set desc = "Создание Ресурсного Блоба будет приносить вам очки."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Здесь нет Блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать этого блоба, найди другой.")
		return

	for(var/obj/structure/blob/resource/blob in orange(4, T))
		to_chat(src, "Поблизости есть Ресурсный Блоб, размести новый за 4 клетки от него!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>Нужно разместить этого блоба ближе к Ядру или Узлу!</span>")
			return //handholdotron 2000

	if(!can_buy(40))
		return

	B.color = blob_reagent_datum.color
	B.change_to(/obj/structure/blob/resource)
	var/obj/structure/blob/resource/R = locate() in T
	if(R)
		R.overmind = src

	return

/mob/camera/blob/verb/create_node()
	set category = "Блоб"
	set name = "Создать Узел Блоба (60)"
	set desc = "Создать Узел."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Здесь нет Блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать этого блоба, найди другой.")
		return

	for(var/obj/structure/blob/node/blob in orange(5, T))
		to_chat(src, "Поблизойти есть другой Узел, размести новый за 5 клеток от него!")
		return

	if(!can_buy(60))
		return

	B.change_to(/obj/structure/blob/node)
	var/obj/structure/blob/node/R = locate() in T
	if(R)
		R.adjustcolors(blob_reagent_datum.color)
		R.overmind = src
	return


/mob/camera/blob/verb/create_factory()
	set category = "Блоб"
	set name = "Создать Фабрику Блоба (60)"
	set desc = "Создает Фабрику производящую Споровиков Блоба."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "Здесь нет Блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать этого блоба, найди другой.")
		return

	for(var/obj/structure/blob/factory/blob in orange(7, T))
		to_chat(src, "Поблизости есть Фабрика Блоба, размести новый за 7 клеток от него!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>Нужно разместить этого блоба ближе к Ядру или Узлу!</span>")
			return //handholdotron 2000

	if(!can_buy(60))
		return

	B.change_to(/obj/structure/blob/factory)
	B.color = blob_reagent_datum.color
	var/obj/structure/blob/factory/R = locate() in T
	if(R)
		R.overmind = src
	return


/mob/camera/blob/verb/create_blobbernaut()
	set category = "Блоб"
	set name = "Создать Блоббернаута (60)"
	set desc = "Создать мощное порождение Блоба, Блоббернаута"

	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "Вы должны быть на Блобе!")
		return

	if(!istype(B, /obj/structure/blob/factory))
		to_chat(src, "Невозможно изменить этого Блоба, найдите Фабрику Блоба!")
		return

	if(!can_buy(60))
		return

	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut (get_turf(B))
	if(blobber)
		qdel(B)
	blobber.color = blob_reagent_datum.complementary_color
	blobber.overmind = src
	blob_mobs.Add(blobber)
	blobber.AIStatus = AI_OFF
	blobber.LoseTarget()
	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Не хотите сыграть за Блоббернаута?", ROLE_BLOB, TRUE, 10 SECONDS, source = blobber)
		if(candidates.len)
			var/mob/C = pick(candidates)
			if(C)
				blobber.key = C.key
				to_chat(blobber, "<span class='biggerdanger'>Ты Блоббернаут! Ты должен помогать всем порождениям Блоба в их миссии поглощения всего!</span>")
				to_chat(blobber, "<span class='danger'>Ты исцеляешься стоя на порождениях Блоба, однако ты будешь медленно распадаться если будешь за их пределами.</span>")
		if(!blobber.ckey)
			blobber.AIStatus = AI_ON
	return


/mob/camera/blob/verb/relocate_core()
	set category = "Блоб"
	set name = "Переместить Ядро (80)"
	set desc = "Перемещение вашего Ядра вместо Узла на котором вы находитесь, ваше старое ядро преобразуется в Узел."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/node/B = locate(/obj/structure/blob/node) in T
	if(!B)
		to_chat(src, "Вы должны находиться на Блобе!")
		return

	if(!can_buy(80))
		return

	// The old switcharoo.
	var/turf/old_turf = blob_core.loc
	blob_core.loc = T
	B.loc = old_turf
	return


/mob/camera/blob/verb/revert()
	set category = "Блоб"
	set name = "Убрать Блоба"
	set desc = "Убирает Блоба. Вы получаете 30% от его стоимости."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/proc/remove_blob(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!T)
		return
	if(!B)
		to_chat(src, "<span class='warning'>Здесь нет Блоба!</span>")
		return
	if(B.point_return < 0)
		to_chat(src, "<span class='warning'>Невозможно убрать этого Блоба.</span>")
		return
	if(max_blob_points < B.point_return + blob_points)
		to_chat(src, "<span class='warning'>У вас слишком много ресурсов для убирания этого Блоба!</span>")
		return
	if(B.point_return)
		add_points(B.point_return)
		to_chat(src, "<span class='notice'>Получено [B.point_return] ресурсов от убранного [B].</span>") //Убрано \the после "убранного"
	qdel(B)
	return


/mob/camera/blob/verb/expand_blob_power()
	set category = "Блоб"
	set name = "Расширить/Атака Блоба (5)"
	set desc = "Попытка создания Блоба на этой плите. Если плиты не очищена, то мы атакуем её для расчистки."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(var/turf/T)
	if(!T)
		return

	if(!can_attack())
		return
	var/obj/structure/blob/B = locate() in T
	if(B)
		to_chat(src, "Здесь уже есть Блоб!")
		return

	var/obj/structure/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "Поблизости с вами нет Блоба.")
		return

	if(!can_buy(5))
		return
	last_attack = world.time
	OB.expand(T, 0, blob_reagent_datum.color)
	for(var/mob/living/L in T)
		if(ROLE_BLOB in L.faction) //no friendly/dead fire
			continue
		var/mob_protection = L.get_permeability_protection()
		blob_reagent_datum.reaction_mob(L, REAGENT_TOUCH, 25, 1, mob_protection)
		blob_reagent_datum.send_message(L)
	OB.color = blob_reagent_datum.color
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Блоб"
	set name = "Сбор Споровиков"
	set desc = "Сбор Споровиков для перемещения на назначенную локацию."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(var/turf/T)
	to_chat(src, "Вы собрали ваших Споровиков.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in GLOB.alive_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/split_consciousness()
	set category = "Блоб"
	set name = "Разделить сознание (100) (Одно использование)"
	set desc = "Потратить ресурсы для попытки создания еще одного Разумного Сверхразума."

	var/turf/T = get_turf(src)
	if(!T)
		return
	if(split_used)
		to_chat(src, "<span class='warning'>Вы уже произвели потомка.</span>")
		return
	if(is_offspring)
		to_chat(src, "<span class='warning'>Вы не можете разделиться как потомок другого Блоба</span>")
		return

	var/obj/structure/blob/N = (locate(/obj/structure/blob) in T)
	if(!N)
		to_chat(src, "<span class='warning'>Необходим Узел для рождения вашего потомка.</span>")
		return
	if(!istype(N, /obj/structure/blob/node))
		to_chat(src, "<span class='warning'>Необходим Узел для рождения вашего потомка.</span>")
		return
	if(!can_buy(100))
		return

	split_used = TRUE
	new /obj/structure/blob/core/ (get_turf(N), 200, null, blob_core.point_rate, offspring = TRUE)
	qdel(N)

	if(SSticker && SSticker.mode.name == "blob")
		var/datum/game_mode/blob/BL = SSticker.mode
		BL.blobwincount += initial(BL.blobwincount)

/mob/camera/blob/verb/blob_broadcast()
	set category = "Блоб"
	set name = "Вещание Блоба"
	set desc = "Говорите со своими порождениями и Блобернаутами. Это бесплатно."

	var/speak_text = clean_input("Что вы хотели бы сказать вашим порождениям?", "Вещение Блоба", null)

	if(!speak_text)
		return
	else
		to_chat(usr, "Вы вещаете своим порождениям, <B>[speak_text]</B>")
	for(var/mob/living/simple_animal/hostile/blob_minion in blob_mobs)
		if(blob_minion.stat == CONSCIOUS)
			blob_minion.say(speak_text)
	return

/mob/camera/blob/verb/create_storage()
	set category = "Блоб"
	set name = "Создать Хранилище Блоба (40)"
	set desc = "Создание Хранилища Блоба, которое способно хранить для вас дополнительные ресурсы. Максимальное ограничение ресурсов увеличивается на 50."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Здесь нет Блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать этого Блоба, найди другой.")
		return

	for(var/obj/structure/blob/storage/blob in orange(3, T))
		to_chat(src, "Поблизости есть Хранилище Блоба, размести новое за 4 клетками от него!")
		return

	if(!can_buy(40))
		return

	B.color = blob_reagent_datum.color
	B.change_to(/obj/structure/blob/storage)
	var/obj/structure/blob/storage/R = locate() in T
	if(R)
		R.overmind = src
		R.update_max_blob_points(50)

	return


/mob/camera/blob/verb/chemical_reroll()
	set category = "Блоб"
	set name = "Химическая Адаптация (50)"
	set desc = "Заменяет ваше химическое вещество на другое случайное."

	if(!can_buy(50))
		return

	var/datum/reagent/blob/B = pick((subtypesof(/datum/reagent/blob) - blob_reagent_datum.type))
	blob_reagent_datum = new B

	color = blob_reagent_datum.complementary_color

	for(var/obj/structure/blob/BL in GLOB.blobs)
		BL.adjustcolors(blob_reagent_datum.color)

	for(var/mob/living/simple_animal/hostile/blob/BLO)
		BLO.adjustcolors(blob_reagent_datum.complementary_color)

	to_chat(src, "Ваш реагент Блоба: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]")

/mob/camera/blob/verb/blob_help()
	set category = "Блоб"
	set name = "*Справка Блоба*"
	set desc = "Помощь в том как быть Блобом."
	to_chat(src, "<b>Как Сверхразум, вы можете контролировать Блоба!</b>")
	to_chat(src, "Ваш реагент Блоба: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]")
	to_chat(src, "<b>Вы можете расширяться на плитку, повреждать объекты и атаковать живых существ. </b>")
	to_chat(src, "<i>Обычные Блобы</i> - расширяет ваш обзор и позволяет вам создавать специальные структуры на нем, выполняющие определенную функции.")
	to_chat(src, "<b>Вы можете улучшить обычного Блоба на данные типы:</b>")
	to_chat(src, "<i>Крепкие Блобы</i> - сильные и дорогие Блобы, способные сдерживать больше урона. Кроме того они пожароустойчивы и блокируют воздух. Используйте их для защиты себя от огня. Улучшение изменит их на <i>Отражающего Блоба</i>, способного отражать лазерные снаряды за счет уменьшения дополнительного здоровья.")
	to_chat(src, "<i>Ресурсные Блобы</i> - Блобы производящие для вас ресурсы. Размещаются возле Ядра или Узла. Создайте их как можно больше, чтобы скорее поглотить станцию.")
	to_chat(src, "<i>Фабрики Блоба</i> - Порождает Споровиков атакующих ближайших врагов. Их можно контролировать, а также они могут захватить цель и сделать из него Споровика-Зомби. Размещается возле Ядра или Узла.")
	to_chat(src, "<i>Блоббернауты</i> - могут быть произведены путем изменения Фабрик Блоба. Фабрика при этом будет уничтожена. Блоббернаутов сложно убить, они крайне мощные и тупые.")
	to_chat(src, "<i>Хранилище Блоба</i> - хранилище дающее вам дополнительное место для ресурсов. Увеличивает максимальную вместимость на 50.")
	to_chat(src, "<i>Узлы Блоба</i> - Блобы, которые расширяются как и Ядро. Позволяет размещать Фабрики и Ресурсных Блобов.")
	to_chat(src, "<b>В дополнении к кнопкам на вашем экране, у вашего HUD'а имеются кнопки быстрого действия.</b>")
	to_chat(src, "<b>Кнопки Быстрого Действия:</b> ЛКМ = Расширить Блоба <b>|</b> CTRL + ЛКМ = Создать Крепкого Блоба <b>|</b> Средняя Кнопка Мыши = Сбор Споровиков <b>|</b> Alt + ЛКМ = Убрать Блоба")
	to_chat(src, "Попытка поговорить отправит сообщения другим порождениям и <b>Сверхразумам</b>, используйте это для координации с ними.")
