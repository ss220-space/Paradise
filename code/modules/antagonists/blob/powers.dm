#define BLOB_REROLL_RADIUS 60

/mob/camera/blob/proc/blob_help()
	var/list/messages = get_blob_help_messages(blobstrain)
	to_chat(src, chat_box_regular(messages.Join("<br>")))

/** Simple price check */
/mob/camera/blob/proc/can_buy(cost = 15)
	if(is_infinity || SSticker?.mode?.is_blob_infinity_points)
		return TRUE
	if(blob_points < cost)
		to_chat(src, span_warning("Вам не хватает рескрсов, вам нужно как минимум [cost]!"))
		balloon_alert(src, "нужно ещё [cost-blob_points]!")
		return FALSE
	add_points(-cost)
	return TRUE


/** Moves the core elsewhere. */
/mob/camera/blob/proc/transport_core()
	if(blob_core)
		forceMove(blob_core.drop_location())

/** Jumps to a node */
/mob/camera/blob/proc/jump_to_node()
	if(!length(GLOB.blob_nodes))
		return FALSE

	var/list/nodes = list()
	for(var/index in 1 to length(GLOB.blob_nodes))
		var/obj/structure/blob/special/node/blob = GLOB.blob_nodes[index]
		nodes["Узел #[index] ([get_area_name(blob)])"] = blob

	var/node_name = tgui_input_list(src, "Выберите узел для перемещения", "Выбор узла", nodes)
	if(isnull(node_name) || isnull(nodes[node_name]))
		return FALSE

	var/obj/structure/blob/special/node/chosen_node = nodes[node_name]
	if(chosen_node)
		forceMove(chosen_node.loc)


/** Places important blob structures */
/mob/camera/blob/proc/create_special(price, blobstrain, min_separation, needs_node, turf/tile)
	if(!tile)
		tile = get_turf(src)

	var/obj/structure/blob/blob = (locate(/obj/structure/blob) in tile)
	if(!blob)
		to_chat(src, span_warning("Тут нет плитки!"))
		balloon_alert(src, "тут нет плитки!")
		return FALSE

	if(!istype(blob, /obj/structure/blob/normal))
		to_chat(src, span_warning("Невозможно использовать на этой плитке. Найдите обычную плитку."))
		balloon_alert(src, "нужна обычная плитка!")
		return FALSE

	var/area/area = get_area(src)
	if(!(area.area_flags & BLOBS_ALLOWED)) //factory and resource blobs must be legit
		to_chat(src, span_warning("Эта плитка должна быть размещёна на станции!"))
		balloon_alert(src, "нельзя поставить вне станции!")
		return FALSE

	if(needs_node)
		if(nodes_required && node_check(tile))
			to_chat(src, span_warning("Вам нужно разместить эту плитку ближе к узлу или ядру!"))
			balloon_alert(src, "слишком далеко от узла или ядра!")
			return FALSE //handholdotron 2000

	if(min_separation)
		for(var/obj/structure/blob/other_blob in get_sep_tile(tile, min_separation))
			if(other_blob.type == blobstrain)
				to_chat(src, span_warning("Поблизости находится ресурсная плитка, отойдите на расстояние более [min_separation] плиток от неё!"))
				other_blob.balloon_alert(src, "слишком близко!")
				return FALSE

	if(!can_buy(price))
		return FALSE

	var/obj/structure/blob/node = blob.change_to(blobstrain, src)
	return node


/mob/camera/blob/proc/node_check(turf/tile)
	if(is_there_multiz())
		return !(locate(/obj/structure/blob/special/node) in urange_multiz(BLOB_NODE_PULSE_RANGE, tile, TRUE)) && !(locate(/obj/structure/blob/special/core) in urange_multiz(BLOB_CORE_PULSE_RANGE, tile, TRUE))
	return !(locate(/obj/structure/blob/special/node) in orange(BLOB_NODE_PULSE_RANGE, tile)) && !(locate(/obj/structure/blob/special/core) in orange(BLOB_CORE_PULSE_RANGE, tile))

/mob/camera/blob/proc/get_sep_tile(turf/tile, min_separation)
	if(is_there_multiz())
		return urange_multiz(min_separation, tile, TRUE)
	return orange(min_separation, tile)

/** Creates a shield to reflect projectiles */
/mob/camera/blob/proc/create_shield(turf/tile)
	var/obj/structure/blob/blob = (locate(/obj/structure/blob) in tile)
	if(!blob)
		to_chat(src, span_warning("Тут нет плитки!"))
		balloon_alert(src, "тут нет плитки!")
		return FALSE

	if(istype(blob, /obj/structure/blob/special))
		to_chat(src, span_warning("Невозможно использовать на этой плитке. Найдите обычную плитку."))
		balloon_alert(src, "нужна обычная плитка!")
		return FALSE

	var/obj/structure/blob/shield/shield = blob
	if(!istype(shield) && can_buy(BLOB_UPGRADE_STRONG_COST))
		shield = shield.change_to(/obj/structure/blob/shield, src)
		shield?.balloon_alert(src, "улучшено в [shield.name]!")
		return FALSE

	if(istype(shield, /obj/structure/blob/shield/reflective))
		to_chat(src, span_warning("Невозможно использовать на этой плитке. Ее больше некуда улучшать."))
		balloon_alert(src, "улучшено на максимум!")
		return FALSE

	if(!can_buy(BLOB_UPGRADE_REFLECTOR_COST))
		return FALSE

	if(shield.get_integrity() < shield.max_integrity * 0.5)
		add_points(BLOB_UPGRADE_REFLECTOR_COST)
		to_chat(src, span_warning("Эта крепкая плитка слишком повреждена, чтобы ее можно было улучшить!"))
		return FALSE

	to_chat(src, span_warning("Вы выделяете отражающую слизь на крепкую плитку, позволяя ей отражать энергетические снаряды ценой снижения прочности."))
	shield = shield.change_to(/obj/structure/blob/shield/reflective, src, shield.point_return)
	shield.balloon_alert(src, "улучшено в [shield.name]!")

/** Preliminary check before polling ghosts. */
/mob/camera/blob/proc/create_blobbernaut()
	var/turf/current_turf = get_turf(src)
	var/obj/structure/blob/special/factory/factory = locate(/obj/structure/blob/special/factory) in current_turf
	if(!factory)
		to_chat(src, span_warning("Вы должны быть на фабрике блоба!"))
		balloon_alert(src, "нужна фабрика!")
		return FALSE
	if(factory.blobbernaut || factory.is_creating_blobbernaut) //if it already made or making a blobbernaut, it can't do it again
		to_chat(src, span_warning("Эта фабрика уже создает блобернаута."))
		return FALSE
	if(factory.get_integrity() < factory.max_integrity * 0.5)
		to_chat(src, span_warning("Эта фабрика уже создала и поддерживает блобернаута."))
		return FALSE
	if(!can_buy(BLOBMOB_BLOBBERNAUT_RESOURCE_COST))
		return FALSE

	factory.is_creating_blobbernaut = TRUE
	to_chat(src, span_notice("Вы пытаетесь создать блоббернаута."))
	pick_blobbernaut_candidate(factory)

/// Polls ghosts to get a blobbernaut candidate.
/mob/camera/blob/proc/pick_blobbernaut_candidate(obj/structure/blob/special/factory/factory)
	if(isnull(factory))
		return
	var/icon/blobbernaut_icon = icon(icon, "blobbernaut")
	blobbernaut_icon.Blend(blobstrain.color, ICON_MULTIPLY)
	var/image/blobbernaut_image = image(blobbernaut_icon)
	var/list/candidates = SSghost_spawns.poll_candidates(
		question = "Вы хотите сыграть за блобернаута?",
		role = ROLE_BLOB,
		poll_time = 20 SECONDS,
		antag_age_check = TRUE,
		check_antaghud = TRUE,
		source = blobbernaut_image,
		role_cleanname = "blobbernaut",
	)
	if(candidates.len)
		var/mob/chosen_one = pick(candidates)
		on_poll_concluded(factory, chosen_one)
	else
		to_chat(src, span_warning("Вы не смогли создать блобернаута. Ваши ресурсы были возвращены. Повторите попытку позже."))
		add_points(BLOBMOB_BLOBBERNAUT_RESOURCE_COST)
		factory.assign_blobbernaut(null)

/// Called when the ghost poll concludes
/mob/camera/blob/proc/on_poll_concluded(obj/structure/blob/special/factory/factory, mob/dead/observer/ghost)
	var/mob/living/simple_animal/hostile/blob_minion/blobbernaut/minion/blobber = new(get_turf(factory))
	assume_direct_control(blobber)
	factory.assign_blobbernaut(blobber)
	blobber.assign_key(ghost.key, blobstrain)
	RegisterSignal(blobber, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_blobbernaut_attacked))

/// When one of our boys attacked something, we sometimes want to perform extra effects
/mob/camera/blob/proc/on_blobbernaut_attacked(mob/living/simple_animal/hostile/blobbynaut, atom/target, success)
	SIGNAL_HANDLER
	if(!success)
		return
	if(!QDELETED(src))
		blobstrain.blobbernaut_attack(target, blobbynaut)

/** Moves the core */
/mob/camera/blob/proc/relocate_core()
	var/turf/tile = get_turf(src)
	var/obj/structure/blob/special/node/blob = locate(/obj/structure/blob/special/node) in tile

	if(!blob)
		to_chat(src, span_warning("Вы должны быть на узле!"))
		balloon_alert(src, "нужно быть на узле!")
		return FALSE

	if(!blob_core)
		to_chat(src, span_userdanger("У вас нет ядра и вы на пороге смерти. Покойтесь с миром!"))
		balloon_alert(src, "у вас нет ядра!")
		return FALSE

	var/area/area = get_area(tile)
	if(isspaceturf(tile) || area && !(area.area_flags & BLOBS_ALLOWED))
		to_chat(src, span_warning("Вы не можете переместить свое ядро сюда!"))
		balloon_alert(src, "нельзя переместить сюда!")
		return FALSE

	if(!can_buy(BLOB_POWER_RELOCATE_COST))
		return FALSE

	var/turf/old_turf = get_turf(blob_core)
	var/old_dir = blob_core.dir
	blob_core.forceMove(tile)
	blob_core.setDir(blob.dir)
	blob.forceMove(old_turf)
	blob.setDir(old_dir)

/** Searches the tile for a blob and removes it. */
/mob/camera/blob/proc/remove_blob(turf/tile, atom/location)
	var/obj/structure/blob/blob = locate() in tile

	if(!blob)
		to_chat(src, span_warning("Тут нет плитки блоба!"))
		return FALSE

	if(blob.point_return < 0)
		to_chat(src, span_warning("Невозможно удалить эту плитку."))
		return FALSE

	if(max_blob_points < blob.point_return + blob_points)
		to_chat(src, span_warning("У вас слишком много ресурсов для удаления этой плитки!"))
		return FALSE

	if(blob.point_return)
		add_points(blob.point_return)
		to_chat(src, span_notice("Получено [blob.point_return] за удаление [blob]."))
		blob.balloon_alert(src, "+[blob.point_return]")

	qdel(blob)

	return TRUE

/** Expands to nearby tiles */
/mob/camera/blob/proc/expand_blob(turf/tile, atom/location)
	if(world.time < last_attack)
		return FALSE
	var/list/possible_blobs = list()
	var/turf/T

	if(is_there_multiz())
		T = get_turf(location)
		for(var/obj/structure/blob/blob in urange_multiz(1, T))
			possible_blobs += blob
	else
		T = tile
		for(var/obj/structure/blob/blob in range(1, T))
			possible_blobs += blob

	if(!length(possible_blobs))
		to_chat(src, span_warning("Рядом с целью нету плиток блоба!"))
		return FALSE

	if(!can_buy(BLOB_EXPAND_COST))
		return FALSE

	var/attack_success
	for(var/mob/living/player in T)
		if(!player.can_blob_attack())
			continue
		if(ROLE_BLOB in player.faction) //no friendly/dead fire
			continue
		if(player.stat != DEAD)
			attack_success = TRUE
		blobstrain.attack_living(player, possible_blobs)

	var/obj/structure/blob/blob = locate() in T

	if(blob)
		if(attack_success) //if we successfully attacked a turf with a blob on it, only give an attack refund
			blob.blob_attack_animation(T, src)
			add_points(BLOB_ATTACK_REFUND)
		else
			to_chat(src, span_warning("Здесь уже есть плитка!"))
			add_points(BLOB_EXPAND_COST) //otherwise, refund all of the cost
	else
		directional_attack(T, possible_blobs, attack_success)

	if(attack_success)
		last_attack = world.time + CLICK_CD_MELEE
	else
		last_attack = world.time + CLICK_CD_RAPID


/** Finds cardinal and diagonal attack directions */
/mob/camera/blob/proc/directional_attack(turf/tile, list/possible_blobs, attack_success = FALSE)
	var/list/cardinal_blobs = list()
	var/list/diagonal_blobs = list()

	for(var/obj/structure/blob/blob in possible_blobs)
		if(get_dir_multiz(blob, tile) in GLOB.cardinals_multiz)
			cardinal_blobs += blob
		else
			diagonal_blobs += blob

	var/obj/structure/blob/attacker
	if(length(cardinal_blobs))
		attacker = pick(cardinal_blobs)
		if(!attacker.expand(tile, src))
			add_points(BLOB_ATTACK_REFUND) //assume it's attacked SOMETHING, possibly a structure
	else
		attacker = pick(diagonal_blobs)
		if(attack_success)
			attacker.blob_attack_animation(tile, src)
			playsound(attacker, 'sound/effects/splat.ogg', 50, TRUE)
			add_points(BLOB_ATTACK_REFUND)
		else
			add_points(BLOB_EXPAND_COST) //if we're attacking diagonally and didn't hit anything, refund
	return TRUE

/** Rally spores to a location */
/mob/camera/blob/proc/rally_spores(turf/tile)
	to_chat(src, "Вы направляете свои споры.")
	var/list/surrounding_turfs = TURF_NEIGHBORS(tile)
	if(!length(surrounding_turfs))
		return FALSE
	for(var/mob/living/simple_animal/hostile/blob_mob as anything in blob_mobs)
		if(!isturf(blob_mob.loc) || get_dist(blob_mob, tile) > 35 || blob_mob.key)
			continue
		blob_mob.lose_target()
		blob_mob.Goto(pick(surrounding_turfs), blob_mob.move_to_delay)


/mob/camera/blob/proc/split_consciousness()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/area/Ablob = get_area(T)
	if(isspaceturf(T) || Ablob && !(Ablob.area_flags & BLOBS_ALLOWED))
		to_chat(src, span_warning("Вы не можете поделиться вне станции!"))
		balloon_alert(src, "нельзя поделиться вне станции!")
		return FALSE
	if(split_used)
		to_chat(src, span_warning("Вы уже произвели потомка."))
		balloon_alert(src, "вы уже поделились!")
		return
	if(is_offspring)
		to_chat(src, span_warning("Потомки блоба не могут производить потомков."))
		balloon_alert(src, "вы сами потомок блоба!")
		return

	var/obj/structure/blob/N = (locate(/obj/structure/blob) in T)
	if(N && !istype(N, /obj/structure/blob/special/node))
		to_chat(src, span_warning("Для создания вашего потомка необходим узел."))
		balloon_alert(src, "необходим узел!")
		return

	if(!can_buy(BLOB_CORE_SPLIT_COST))
		return

	split_used = TRUE
	new /obj/structure/blob/special/core/ (get_turf(N), null, TRUE)
	qdel(N)


/** Opens the reroll menu to change strains */
/mob/camera/blob/proc/strain_reroll()
	if(!free_strain_rerolls && blob_points < BLOB_POWER_REROLL_COST)
		to_chat(src, span_warning("Вам нужно как минимум [BLOB_POWER_REROLL_COST], чтобы снова изменить свой штамм!"))
		return FALSE

	open_reroll_menu()

/** Controls changing strains */
/mob/camera/blob/proc/open_reroll_menu()
	if(!strain_choices)
		strain_choices = list()

		var/list/new_strains = GLOB.valid_blobstrains.Copy() - blobstrain.type
		for (var/unused in 1 to BLOB_POWER_REROLL_CHOICES)
			var/datum/blobstrain/strain = pick_n_take(new_strains)

			var/image/strain_icon = image('icons/mob/blob.dmi', "blob_core")
			strain_icon.color = initial(strain.color)

			//var/info_text = span_boldnotice("[initial(strain.name)]")
			//info_text += "<br>[span_notice("[initial(strain.analyzerdescdamage)]")]"
			//if(!isnull(initial(strain.analyzerdesceffect)))
				//info_text += "<br>[span_notice("[initial(strain.analyzerdesceffect)]")]"

			strain_choices[initial(strain.name)] = strain_icon

	var/strain_result = show_radial_menu(src, src, strain_choices, radius = BLOB_REROLL_RADIUS)
	if(isnull(strain_result))
		return

	if(!free_strain_rerolls && !can_buy(BLOB_POWER_REROLL_COST))
		return

	for (var/_other_strain in GLOB.valid_blobstrains)
		var/datum/blobstrain/other_strain = _other_strain
		if(initial(other_strain.name) == strain_result)
			set_strain(other_strain)

			if(free_strain_rerolls)
				free_strain_rerolls -= 1

			last_reroll_time = world.time
			strain_choices = null

			return

#undef BLOB_REROLL_RADIUS
