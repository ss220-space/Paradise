#define HIEROPHANT_CLUB_CARDINAL_DAMAGE 30

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "Странные технологии этого массивного посоха позволяют совершать почти магические действия. Раньше он бил вас, теперь вы задаёте ритм."
	icon_state = "hierophant_club_ready_beacon"
	item_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	attack_verb = list("стукнул", "ударил")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 81 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/chaser_speed = 0.8 //how fast our chasers are
	var/timer = 0 //what our current cooldown is
	var/blast_range = 13 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/beacon //the associated beacon we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/tele_proof_bypass = FALSE //for admins to bypass tele_proof with VV
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/hierophant_club/get_ru_names()
	return list(
		NOMINATIVE = "посох Иерофанта",
		GENITIVE = "посоха Иерофанта",
		DATIVE = "посоху Иерофанта",
		ACCUSATIVE = "посох Иерофанта",
		INSTRUMENTAL = "посохом Иерофанта",
		PREPOSITIONAL = "посохе Иерофанта"
	)

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += span_hierophant_warning("[beacon ? "К маяку ничего не прикреплено" : "Здесь уже прикреплён маяк"].")

/obj/item/hierophant_club/suicide_act(mob/living/user)
	atom_say("Xverwpsgexmrk...")
	user.visible_message(span_suicide("[user] поднима[pluralize_ru(user.gender,"ет","ют")] [declent_ru(NOMINATIVE)] в воздух! Похоже, [genderize_ru(user.gender,"он","она","оно","они")] собира[pluralize_ru(user.gender,"ет","ют")]ся покончить с собой!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlock_open.ogg', 75, TRUE)
	user.visible_message(span_hierophant_warning("[user] растворя[pluralize_ru(user.gender,"ет","ют")]ся в воздухе, оставляя свои вещи!"))
	for(var/obj/item/I in user)
		if(I != src)
			user.drop_item_ground(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, TRUE)
		B.damage = 0
	user.drop_item_ground(src) //Drop us last, so it goes on top of their stuff
	qdel(user)
	return OBLITERATION


/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(world.time < timer)
		return

	if(!is_mining_level(user.z) || istype(get_area(user), /area/ruin/space/bubblegum_arena))//Will only spawn a few sparks if not on mining z level
		timer = world.time + cooldown_time
		user.visible_message(span_danger("Посох Иерофанта [user] даёт сбой!"))
		do_sparks(5, FALSE, user)
		return

	var/turf/T = get_turf(target)
	if(!T)
		return
	calculate_anger_mod(user)
	timer = world.time + attack_speed //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		INVOKE_ASYNC(src, PROC_REF(aoe_burst), T, user)
		if(is_station_level(T.z))
			add_attack_logs(user, target, "Fired 3x3 blast at [src]")
		else
			add_attack_logs(user, target, "Fired 3x3 blast at [src]", ATKLOG_ALL)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			INVOKE_ASYNC(src, PROC_REF(cardinal_blasts), T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(user), user, target, chaser_speed, friendly_fire_check)
				C.damage = 30
				C.monster_damage_boost = FALSE
				if(is_station_level(T.z))
					add_attack_logs(user, target, "Fired a chaser at [src]")
				else
					add_attack_logs(user, target, "Fired a chaser at [src]", ATKLOG_ALL)
			else
				INVOKE_ASYNC(src, PROC_REF(cardinal_blasts), T, user) //otherwise, just do cardinal blast
				if(is_station_level(T.z))
					add_attack_logs(user, target, "Fired cardinal blast at [src]")
				else
					add_attack_logs(user, target, "Fired cardinal blast at [src]", ATKLOG_ALL)
		else
			to_chat(user, span_warning("Цель вне зоны досягаемости!"))
			timer = world.time
	INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))

/obj/item/hierophant_club/proc/calculate_anger_mod(mob/user) //we get stronger as the user loses health
	chaser_cooldown = initial(chaser_cooldown)
	cooldown_time = initial(cooldown_time)
	chaser_speed = initial(chaser_speed)
	blast_range = initial(blast_range)
	if(isliving(user))
		var/mob/living/L = user
		var/health_percent = max(L.health / L.maxHealth, 0) // Don't go negative
		chaser_cooldown += round(health_percent * 20) //two tenths of a second for each missing 10% of health
		cooldown_time += round(health_percent * 10) //one tenth of a second for each missing 10% of health
		chaser_speed = max(chaser_speed + health_percent, 0.5) //one tenth of a second faster for each missing 10% of health
		blast_range -= round(health_percent * 10) //one additional range for each missing 10% of health


/obj/item/hierophant_club/update_icon_state()
	icon_state = "hierophant_club[timer <= world.time ? "_ready":""][(beacon && !QDELETED(beacon)) ? "":"_beacon"]"
	item_state = icon_state
	update_equipped_item(update_speedmods = FALSE)


/obj/item/hierophant_club/proc/prepare_icon_update()
	update_icon(UPDATE_ICON_STATE)
	sleep(timer - world.time)
	update_icon(UPDATE_ICON_STATE)


/obj/item/hierophant_club/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_unfriendly_fire)) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		to_chat(user, span_warning("Вы [friendly_fire_check ? "отключаете" : "включаете"] дружественный огонь!"))
		return
	if(timer > world.time)
		return
	if(user.is_in_active_hand(src) && user.is_in_inactive_hand(src)) //you need to hold the staff to teleport
		to_chat(user, span_warning("Нужно держать посох в руках, чтобы [beacon ? "телепортироваться" : "отсоединить маяк"]!"))
		return
	if(is_in_teleport_proof_area(user) && !tele_proof_bypass)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] искрит и потрескивает."))
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message(
				span_hierophant_warning("[user] воз[pluralize_ru(user.gender,"ит","ят")]ся с навершием [declent_ru(GENITIVE)]..."),
				span_notice("Вы начинаете отсоединять маяк Иерофанта...")
			)
			timer = world.time + 51
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			if(do_after(user, 5 SECONDS, user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				beacon.add_fingerprint(user)
				user.update_action_buttons_icon()
				user.visible_message(span_hierophant_warning("[user] размеща[pluralize_ru(user.gender,"ет","ют")] странный механизм у своих ног!"), "[span_hierophant("Вы отсоединяете маяк Иерофанта, позволяя телепортироваться к нему в любой момент!")]\n[span_notice("Можете ударить посохом, чтобы забрать его.")]")
			else
				timer = world.time
				INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
		else
			to_chat(user, span_warning("Для установки маяка нужно твёрдо стоять на земле!"))
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, span_warning("Вы слишком близко к маяку для телепортации"))
		return
	if(is_in_teleport_proof_area(beacon) && !tele_proof_bypass)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] искрит и потрескивает."))
		return
	var/turf/beacon_turf = get_turf(beacon)
	if(beacon_turf.is_blocked_turf(exclude_mobs = TRUE))
		to_chat(user, span_warning("Телепортация невозможна – маяк заблокирован!"))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("Здесь недостаточно места для телепортации!"))
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message(span_hierophant_warning("[user] начина[pluralize_ru(user.gender,"ет","ют")] слабо светиться..."))
	timer = world.time + 50
	INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
	beacon.teleporting = TRUE
	beacon.update_icon(UPDATE_ICON_STATE)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 4 SECONDS, user) && user && beacon)
		var/turf/source = get_turf(user)
		if(beacon_turf.is_blocked_turf(exclude_mobs = TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("Телепортация невозможна – маяк заблокирован!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			beacon.teleporting = FALSE
			beacon.update_icon(UPDATE_ICON_STATE)
			return
		new /obj/effect/temp_visual/hierophant/telegraph(beacon_turf, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(beacon_turf,'sound/magic/wand_teleport.ogg', 200, TRUE)
		playsound(source,'sound/machines/airlock_open.ogg', 200, TRUE)
		if(!do_after(user, 0.3 SECONDS, user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			if(beacon)
				beacon.teleporting = FALSE
				beacon.update_icon(UPDATE_ICON_STATE)
			return
		if(beacon_turf.is_blocked_turf(exclude_mobs = TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("Телепортация невозможна – маяк заблокирован!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			beacon.teleporting = FALSE
			beacon.update_icon(UPDATE_ICON_STATE)
			return
		add_attack_logs(user, beacon, "Teleported self from ([AREACOORD(source)]) to ([AREACOORD(beacon)])")
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(beacon_turf, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, beacon_turf))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, PROC_REF(teleport_mob), source, L, beacon_turf, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
		if(beacon)
			beacon.teleporting = FALSE
			beacon.update_icon(UPDATE_ICON_STATE)
	else
		qdel(TE1)
		qdel(TE2)
		timer = world.time
		INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
	if(beacon)
		beacon.teleporting = FALSE
		beacon.update_icon(UPDATE_ICON_STATE)
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || turf_to_teleport_to.is_blocked_turf(exclude_mobs = TRUE))
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message(span_hierophant_warning("[M] растворяется!"))
	sleep(2)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message(span_hierophant_warning("[M] материализуется!"))
	if(user != M)
		add_attack_logs(user, M, "Teleported from [COORD(source)]")

/obj/item/hierophant_club/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, TRUE)
	sleep(2)
	var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, friendly_fire_check)
	B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
	B.monster_damage_boost = FALSE
	for(var/d in GLOB.cardinal)
		INVOKE_ASYNC(src, PROC_REF(blast_wall), T, d, user)

/obj/item/hierophant_club/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		var/obj/effect/temp_visual/hierophant/blast/B = new(J, user, friendly_fire_check)
		B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
		B.monster_damage_boost = FALSE
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/hierophant_club/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, TRUE)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, user, friendly_fire_check)
		B.damage = 15 //keeps monster damage boost due to lower damage

/obj/item/clothing/accessory/necklace/hierophant_talisman
	name = "Dormnant talisman of warding"
	desc = "Защитный талисман Иерофанта. Он спасёт вас."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "hierophant_talisman_nonactive"
	item_state = "hierophant_talisman_nonactive"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, RAD = 5, FIRE = 100, ACID = 100)
	allow_duplicates = FALSE
	var/possessed = FALSE
	var/mob/living/simple_animal/shade/talisman/slave // Talisman
	var/obj/effect/proc_holder/spell/hierophant_talisman_heal/spell_heal
	var/obj/effect/proc_holder/spell/hierophant_talisman_teleport/spell_teleport
	var/obj/effect/proc_holder/spell/hierophant_talisman_message/spell_message

/obj/item/clothing/accessory/necklace/hierophant_talisman/get_ru_names()
	return list(
		NOMINATIVE = "дремлющий защитный талисман",
		GENITIVE = "дремлющего защитного талисмана",
		DATIVE = "дремлющему защитному талисману",
		ACCUSATIVE = "дремлющий защитный талисман",
		INSTRUMENTAL = "дремлющим защитным талисманом",
		PREPOSITIONAL = "дремлющем защитном талисмане"
	)

/obj/item/clothing/accessory/necklace/hierophant_talisman/attack_self(mob/living/user)
	if(possessed)
		if(!slave)
			to_chat(user, span_hierophant("Всё ещё ищу подходящую душу для вас..."))
			return
		if(slave.master != user.ckey)
			to_chat(slave, span_hierophant("Теперь вы служите [user.real_name]. Вы должны защищать его."))
			to_chat(user, span_hierophant("Теперь этот талисман ваш... Он будет оберегать вас..."))
			log_game("[user.real_name] has become master of [slave.ckey] hierophant's talisman.")
			slave.master = user.ckey
		else
			to_chat(user, span_hierophant("Этот талисман уже ваш! ЧЕГО ЕЩЁ ВЫ ХОТИТЕ!?"))
		return


	to_chat(user, span_hierophant("Вы пытаетесь пробудить мою сущность..."))

	possessed = TRUE

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите стать духом талисмана защиты [user.real_name]?", ROLE_PAI, FALSE, 15 SECONDS, source = src)
	var/mob/dead/observer/theghost = null

	if(length(candidates))
		theghost = pick(candidates)
		slave = new(src)
		slave.ckey = theghost.ckey
		slave.master = user.ckey
		name = "Talisman of warding"
		ru_names = list(
			NOMINATIVE = "защитный талисман",
			GENITIVE = "защитного талисмана",
			DATIVE = "защитному талисману",
			ACCUSATIVE = "защитный талисман",
			INSTRUMENTAL = "защитным талисманом",
			PREPOSITIONAL = "защитном талисмане"
		)
		slave.real_name = name
		slave.name = name
		var/input = tgui_input_text(slave, "Как вас зовут?", "Смена имени", max_length = MAX_NAME_LEN)
		if(QDELETED(src) || isnull(input))
			return
		name = input
		slave.real_name = input
		slave.name = input
		log_game("[slave.ckey] has become spirit of [user.real_name]'s talisman.")
		to_chat(slave, span_hierophant("Теперь вы служите [user.real_name]. Вы должны защищать его."))
		update_icon(UPDATE_ICON_STATE)
	else
		log_game("No one has decided to be [user.real_name]'s talisman.")
		to_chat(user, span_hierophant("Талисман дремлет... Попробуйте позже..."))
		possessed = FALSE


/obj/item/clothing/accessory/necklace/hierophant_talisman/update_icon_state()
	icon_state = "hierpohant_talisman_[slave ? "active" : "nonactive"]"
	item_state = "hierpohant_talisman_[slave ? "active" : "nonactive"]"


/obj/item/clothing/accessory/necklace/hierophant_talisman/Initialize(mapload)
	.=..()
	spell_heal = new
	spell_teleport = new
	spell_message = new

/obj/item/clothing/accessory/necklace/hierophant_talisman/Destroy()
	for(var/mob/living/simple_animal/shade/talisman/S in contents)
		to_chat(S, span_hierophant("Вас уничтожили! Но... я создам новый талисман в будущем."))
		playsound(get_turf(src),'sound/magic/repulse.ogg', 200, TRUE)
		S.ghostize()
		qdel(S)
	QDEL_NULL(spell_heal)
	QDEL_NULL(spell_teleport)
	QDEL_NULL(spell_message)
	return ..()

/obj/effect/proc_holder/spell/hierophant_talisman_heal
	name = "Маяк помощи"
	desc = "Исцеляет вашего хозяина."
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	should_recharge_after_cast = FALSE
	stat_allowed = UNCONSCIOUS
	action_icon_state = "hierophant_talisman_heal"
	action_background_icon_state = "bg_hierophant_talisman"

/obj/effect/proc_holder/spell/hierophant_talisman_heal/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.target_priority = SPELL_TARGET_CLOSEST
	T.max_targets = 1
	T.range = 1
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/hierophant_talisman_heal/valid_target(mob/living/carbon/human/target, mob/living/simple_animal/shade/talisman/user)
	if (target.ckey == user.master)
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/hierophant_talisman_heal/cast(list/targets, mob/living/simple_animal/shade/talisman/user  = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/update = NONE
	update |= target.heal_overall_damage(15, 15, updating_health = FALSE, affect_robotic = TRUE)
	update |= target.heal_damage_type(15, TOX, updating_health = FALSE)
	if(update)
		target.updatehealth()
	if(target.health / target.maxHealth <= 0.25)
		cooldown_handler.start_recharge(10 SECONDS)
		to_chat(user, span_hierophant("Это существо умирает... Жалко, но... вы должны защитить его..."))
	else
		cooldown_handler.start_recharge(20 SECONDS)
		to_chat(user, span_hierophant("Вы защищаете... это существо... Хорошо, мой ученик."))
	to_chat(target, span_hierophant("Мой талисман защищает вас... Жалкое зрелище..."))

/obj/effect/proc_holder/spell/hierophant_talisman_teleport
	name = "Малая телепортация Иерофанта"
	desc = "Перемещает хозяина в выбранное место."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	should_recharge_after_cast = FALSE
	stat_allowed = UNCONSCIOUS
	centcom_cancast = FALSE
	action_icon_state = "hierophant_talisman_teleport"
	action_background_icon_state = "bg_hierophant_talisman"

/obj/effect/proc_holder/spell/hierophant_talisman_teleport/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /turf/simulated
	T.range = 3
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/hierophant_talisman_teleport/cast(list/targets, mob/living/simple_animal/shade/talisman/user)
	var/turf/target_turf = get_turf(targets[1])
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.ckey == user.master)
			var/turf/start_turf = get_turf(H)
			H.forceMove(target_turf)
			new /obj/effect/temp_visual/hierophant/telegraph(target_turf, src)
			new /obj/effect/temp_visual/hierophant/telegraph(start_turf, src)
			playsound(start_turf,'sound/machines/airlock_open.ogg', 200, TRUE)
			if(H.health / H.maxHealth <= 0.25)
				cooldown_handler.start_recharge(15 SECONDS)
				to_chat(user, span_hierophant("Телепортируй! Телепортируй! Никогда не сдавайся!"))
				user.say("Мгновенная телепортация, мой дорогой друг!")
			else
				cooldown_handler.start_recharge(30 SECONDS)
				to_chat(user, span_hierophant("Танцуйте, мои прелестные!"))
				user.say("Исчезни, мой друг!")
			addtimer(CALLBACK(src, PROC_REF(talisman_teleport_2), target_turf, start_turf), 2)
			break

/obj/effect/proc_holder/spell/hierophant_talisman_teleport/proc/talisman_teleport_2(turf/T, turf/S)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, src)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(S, src)
	animate(src, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	visible_message(span_hierophant("[capitalize(declent_ru(NOMINATIVE))] растворяется!"))
	set_density(FALSE)
	addtimer(CALLBACK(src, PROC_REF(talisman_teleport_3), T), 2)

/obj/effect/proc_holder/spell/hierophant_talisman_teleport/proc/talisman_teleport_3(turf/T)
	animate(src, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	set_density(TRUE)
	visible_message(span_hierophant("[capitalize(declent_ru(NOMINATIVE))] материализуется!"))

/obj/effect/proc_holder/spell/hierophant_talisman_message
	name = "Телепатическое послание"
	desc = "Отправляет мысленное сообщение людям."
	base_cooldown = 5 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	should_recharge_after_cast = TRUE
	stat_allowed = UNCONSCIOUS
	action_icon_state = "hierophant_talisman_message"
	action_background_icon_state = "bg_hierophant_talisman"

/obj/effect/proc_holder/spell/hierophant_talisman_message/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	T.use_turf_of_user = TRUE
	return T

/obj/effect/proc_holder/spell/hierophant_talisman_message/cast(list/targets, mob/living/simple_animal/shade/talisman/user)
	var/mob/living/carbon/human/choice = targets[1]
	var/msg = tgui_input_text(usr, "Что вы хотите сообщить [choice]?", null, "")
	if(!(msg))
		return
	add_say_logs(usr, msg, choice, "SLAUGHTER")
	to_chat(usr, span_hierophant("Вы говорите в разум [choice]:</b> [msg]"))
	to_chat(choice, "[span_deadsay(span_hierophant("Странные, магические и одновременно чуждые мысли обращаются к вам..."))] [span_hierophant("[msg]")]")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message(span_hierophant("Послание Иерофанта от <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) к <b>[choice]</b> ([ghost_follow_link(choice, ghost=G)]): [msg]</i>")) //what the fuck...


/obj/item/clothing/accessory/necklace/hierophant_talisman/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(!. || !ishuman(attacher) || !slave || slave.master != attacher.ckey)
		return .
	toggle_spell_actions(TRUE)


/obj/item/clothing/accessory/necklace/hierophant_talisman/on_removed(mob/detacher)
	. = ..()
	if(!slave)
		return .
	toggle_spell_actions(FALSE)


/obj/item/clothing/accessory/necklace/hierophant_talisman/attached_equip(mob/user)
	if(!ishuman(user) || !slave || slave.master != user.ckey)
		return
	toggle_spell_actions(TRUE)


/obj/item/clothing/accessory/necklace/hierophant_talisman/attached_unequip(mob/user)
	if(!slave)
		return
	toggle_spell_actions(FALSE)


/obj/item/clothing/accessory/necklace/hierophant_talisman/proc/toggle_spell_actions(add_actions)
	if(add_actions)
		LAZYADD(slave.mob_spell_list, spell_heal)
		LAZYADD(slave.mob_spell_list, spell_teleport)
		LAZYADD(slave.mob_spell_list, spell_message)
		spell_heal.action.Grant(slave)
		spell_teleport.action.Grant(slave)
		spell_message.action.Grant(slave)
	else
		LAZYREMOVE(slave.mob_spell_list, spell_heal)
		LAZYREMOVE(slave.mob_spell_list, spell_teleport)
		LAZYREMOVE(slave.mob_spell_list, spell_message)
		spell_heal.action.Remove(slave)
		spell_teleport.action.Remove(slave)
		spell_message.action.Remove(slave)


#undef HIEROPHANT_CLUB_CARDINAL_DAMAGE
