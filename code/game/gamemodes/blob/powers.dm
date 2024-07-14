// Point controlling procs

/mob/camera/blob/proc/can_buy(var/cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>Вы не можете себе это позволить!</span>")
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Возвращает вас к вашему ядру."

	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Перемещает вас к выбранному узлу."

	if(GLOB.blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= GLOB.blob_nodes.len; i++)
			var/obj/structure/blob/node/B = GLOB.blob_nodes[i]
			nodes["Blob Node #[i] ([get_location_name(B)])"] = B
		var/node_name = input(src, "Выберете.", "Перемещение к узлу") in nodes
		var/obj/structure/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/toggle_node_req()
	set category = "Blob"
	set name = "Toggle Node Requirement"
	set desc = "Переключить требование узла для размещения ресурсной плитки и фабрики."
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, "<span class='warning'>Теперь вам необходимо иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки.</span>")
	else
		to_chat(src, "<span class='warning'>Теперь вам не нужно иметь узел или ядро рядом ​​для размещения фабрики и ресурсной плитки.</span>")

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create/Upgrade Shield Blob (15)"
	set desc = "Создайте/улучшите крепкую плитку. Использование на существующей крепкой плитке превращает её в отражающую плитку, способную отражать большинство энергетических снарядов, но делая её намного слабее для остальных атак."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	var/obj/structure/blob/shield/S = locate(/obj/structure/blob/shield) in T

	if(!S)
		if(!B)//We are on a blob
			to_chat(src, "Тут нет плитки!")
			return

		else if(!istype(B, /obj/structure/blob/normal))
			to_chat(src, "Невозможно использовать на этой плитке. Найдите обычную плитку.")
			return

		else if(!can_buy(15))
			return

		B.color = blob_reagent_datum.color
		B.change_to(/obj/structure/blob/shield)
	else

		if(istype(S, /obj/structure/blob/shield/reflective))
			to_chat(src, "<span class='warning'>Здесь уже отражающая плитка!</span>")
			return


		else if(S.obj_integrity < S.max_integrity * 0.5)
			to_chat(src, "<span class='warning'>Эта крепкая плитка слишком повреждена, чтобы ее можно было модифицировать!</span>")
			return

		else if (!can_buy(15))
			return

		to_chat(src, "<span class='warning'>Вы выделяете отражающую слизь на крепкую плитку, позволяя ей отражать энергетические снаряды ценой снижения прочности.</span>")

		S.change_to(/obj/structure/blob/shield/reflective)
		S.color = blob_reagent_datum.color
	return

/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Создайте ресурсную плитку, которая будет приносить вам ресурсы."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Тут нет плитки!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать на этой плитке. Найдите обычную плитку.")
		return
	for(var/obj/structure/blob/resource/blob in orange(4, T))
		to_chat(src, "Поблизости находится ресурсная плитка, отойдите на расстояние более 4 плиток от неё!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>Вам нужно разместить этот объект ближе к узлу или ядру!</span>")
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
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Создает узел."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Тут нет плитки блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать на этой плитке. Найдите обычную плитку.")
		return

	for(var/obj/structure/blob/node/blob in orange(5, T))
		to_chat(src, "Поблизости находится узел, отойдите на расстояние более 5 плиток от него!")
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
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Создает плитку, производящую споры."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "Тут нет плитки!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать на этой плитке. Найдите обычную плитку.")
		return

	for(var/obj/structure/blob/factory/blob in orange(7, T))
		to_chat(src, "Поблизости находится фабрика, отойдите на расстояние более 7 плиток от неё!")
		return

	if(nodes_required)
		if(!(locate(/obj/structure/blob/node) in orange(3, T)) && !(locate(/obj/structure/blob/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>Вам нужно разместить этот объект ближе к узлу или ядру!</span>")
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
	set category = "Blob"
	set name = "Create Blobbernaut (60)"
	set desc = "Создает сильное порождение блоба. Блобернаута!"

	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!B)
		to_chat(src, "Вы должны быть на плитке блоба!")
		return FALSE

	if(!istype(B, /obj/structure/blob/factory))
		to_chat(src, "Невозможно использовать эту плитку, найдите фабрику.")
		return FALSE
	var/obj/structure/blob/factory/b_fac = B

	if(b_fac.is_waiting_spawn)
		return FALSE

	if(!can_buy(60))
		return FALSE

	spawn()
		var/mob/C
		b_fac.is_waiting_spawn = TRUE

		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за блобернаута?", ROLE_BLOB, TRUE, 10 SECONDS, source = /mob/living/simple_animal/hostile/blob/blobbernaut)
		if(length(candidates))
			C = pick(candidates)

		if(!C)
			add_points(60)
			b_fac.is_waiting_spawn = FALSE

		if(b_fac && b_fac.is_waiting_spawn)	//Если фабрика цела и её не разрушили во время голосования
			var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new (get_turf(b_fac))
			qdel(b_fac)
			blobber.key = C.key
			log_game("[blobber.key] has spawned as Blobbernaut")
			to_chat(blobber, "<span class='biggerdanger'>Вы блобернаут! Вы должны помочь всем формам блоба в их миссии по уничтожению всего!</span>")
			to_chat(blobber, "<span class='danger'>Вы исцеляетесь, стоя на плитках блоба, однако вы будете медленно разлагаться, если получите урон за пределами блоба.</span>")

			blobber.color = blob_reagent_datum.complementary_color
			blobber.overmind = src
			blob_mobs.Add(blobber)
			blobber.AIStatus = AI_OFF
			blobber.LoseTarget()
			addtimer(CALLBACK(blobber, TYPE_PROC_REF(/mob/living/simple_animal/hostile/blob/blobbernaut/, add_to_gamemode)), TIME_TO_ADD_OM_DATUM)
	return TRUE


/mob/camera/blob/verb/relocate_core()
	set category = "Blob"
	set name = "Relocate Core (80)"
	set desc = "Перемещает ваше ядро ​​на узел, на котором вы находитесь, ваше старое ядро ​​будет превращено в узел."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/node/B = locate(/obj/structure/blob/node) in T
	if(!B)
		to_chat(src, "Вы должны быть на узле!")
		return

	if(!can_buy(80))
		return

	// The old switcharoo.
	var/turf/old_turf = blob_core.loc
	blob_core.loc = T
	B.loc = old_turf
	return


/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Удаляет плитку. Вы получите 30 % возмещение стоимости специальных структур блоба."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/proc/remove_blob(var/turf/T)

	var/obj/structure/blob/B = locate(/obj/structure/blob) in T
	if(!T)
		return
	if(!B)
		to_chat(src, "<span class='warning'>Тут нет плитки блоба!</span>")
		return
	if(B.point_return < 0)
		to_chat(src, "<span class='warning'>Невозможно удалить эту плитку!</span>")
		return
	if(max_blob_points < B.point_return + blob_points)
		to_chat(src, "<span class='warning'>У вас слишком много ресурсов для удаления этой плитки!</span>")
		return
	if(B.point_return)
		add_points(B.point_return)
		to_chat(src, "<span class='notice'>Получено [B.point_return] ресурса после удаления \the [B].</span>")
	qdel(B)
	return


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob (5)"
	set desc = "Пытается создать новую плитку блоба в этом тайле. Если тайл не чист, мы наносим урон объекту, находящемуся в нем, что может его очистить."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(var/turf/T)
	if(!T)
		return

	if(!can_attack())
		return

	if(!is_location_within_transition_boundaries(T))
		to_chat(src, "Вы не можете расширяться сюда...")
		return

	var/obj/structure/blob/B = locate() in T
	if(B)
		to_chat(src, "Здесь уже есть плитка!")
		return

	var/obj/structure/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "Рядом с вами нет ни одной плитки.")
		return

	if(!((locate(/mob/living) in T) || can_buy(5)))
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
	set category = "Blob"
	set name = "Rally Spores"
	set desc = "Направьте споры, чтоб они переместились в выбранное место."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(var/turf/T)
	to_chat(src, "Вы направляете свои споры.")

	var/list/surrounding_turfs = block(T.x - 1, T.y - 1, T.z, T.x + 1, T.y + 1, T.z)
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in GLOB.alive_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/split_consciousness()
	set category = "Blob"
	set name = "Split consciousness (100) (One use)"
	set desc = "Тратьте ресурсы, чтобы попытаться создать еще одного блоба."

	var/turf/T = get_turf(src)
	if(!T)
		return
	if(split_used)
		to_chat(src, "<span class='warning'>Вы уже произвели потомка.</span>")
		return
	if(is_offspring)
		to_chat(src, "<span class='warning'>Потомки блоба не могут производить потомков.</span>")
		return

	var/obj/structure/blob/N = (locate(/obj/structure/blob) in T)
	if(!N)
		to_chat(src, "<span class='warning'>Для создания вашего потомка необходим узел.</span>")
		return
	if(!istype(N, /obj/structure/blob/node))
		to_chat(src, "<span class='warning'>Для создания вашего потомка необходим узел.</span>")
		return
	if(!can_buy(100))
		return

	split_used = TRUE

	new /obj/structure/blob/core/ (get_turf(N), 200, null, blob_core.point_rate, offspring = TRUE)
	qdel(N)


/mob/camera/blob/verb/blob_broadcast()
	set category = "Blob"
	set name = "Blob Broadcast"
	set desc = "Говорите, используя споры и блобернаутов в качестве рупоров. Это действие бесплатно."

	var/speak_text = clean_input("Что вы хотите сказать от лица ваших созданий?", "Blob Broadcast", null)

	if(!speak_text)
		return
	else
		to_chat(usr, "Вы говорите от лица ваших созданий, <B>[speak_text]</B>")
	for(var/mob/living/simple_animal/hostile/blob_minion in blob_mobs)
		if(blob_minion.stat == CONSCIOUS)
			blob_minion.say(speak_text)
	return

/mob/camera/blob/verb/create_storage()
	set category = "Blob"
	set name = "Create Storage Blob (40)"
	set desc = "Создаёт хранилище, которая будет накапливать дополнительные ресурсы для вас. Это увеличивает ваш максимальный предел ресурсов на 50."


	var/turf/T = get_turf(src)

	if(!T)
		return

	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "Тут нет плитки блоба!")
		return

	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, "Невозможно использовать эту плитку, найдите обычную.")
		return

	for(var/obj/structure/blob/storage/blob in orange(3, T))
		to_chat(src, "Поблизости находится хранилище, отойдите на расстояние более 4 плиток от него!")
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
	set category = "Blob"
	set name = "Reactive Chemical Adaptation (50)"
	set desc = "Заменяет ваш химикат на другой случайным образом."

	if(!can_buy(50))
		return

	var/datum/reagent/blob/B = pick((subtypesof(/datum/reagent/blob) - blob_reagent_datum.type))
	blob_reagent_datum = new B
	var/datum/antagonist/blob_overmind/overmind_datum = mind.has_antag_datum(/datum/antagonist/blob_overmind)
	if(overmind_datum)
		overmind_datum.reagent = blob_reagent_datum
	color = blob_reagent_datum.complementary_color

	for(var/obj/structure/blob/BL in GLOB.blobs)
		BL.adjustcolors(blob_reagent_datum.color)

	for(var/mob/living/simple_animal/hostile/blob/BLO)
		BLO.adjustcolors(blob_reagent_datum.complementary_color)

	to_chat(src, "Ваш новый реагент: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> - [blob_reagent_datum.description]")

/mob/camera/blob/verb/blob_help()
	set category = "Blob"
	set name = "*Blob Help*"
	set desc = "Help on how to blob."
	for (var/message in get_blob_help_messages(blob_reagent_datum))
		to_chat(src, message)


