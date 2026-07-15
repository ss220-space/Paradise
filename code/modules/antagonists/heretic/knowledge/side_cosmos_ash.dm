/datum/heretic_knowledge/limited_amount/summon/fire_shark
	drafting_tier = 3
	name = "Опаляющая Акула"
	desc = "Позволяет преобразовать горстку пепла, печень и лист плазмы в Огненную Акулу. \
			Огненные Акулы быстры и сильны в группах, но быстро погибают. Они также очень устойчивы к огню. \
			Огненные Акулы впрыскивают в своих жертв флогистон и выделяют плазму после смерти."
	gain_text = "Колыбель туманности была холодной, но не мёртвой. Свет и тепло проникают даже сквозь самую глубокую тьму, но даже за ними охотятся хищники."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/fire_shark
	limit = 5
	cost = 2
	research_tree_icon_dir = EAST


/datum/heretic_knowledge/spell/space_phase
	drafting_tier = 4
	name = "Космический Сдвиг"
	desc = "Даёт вам способность \"Космический Сдвиг\", заклинание, позволяющее свободно перемещаться в пространстве. \
			Вы можете переходить использовать её, только находясь в месте с низким давлением."
	gain_text = "Вы чувствуете, что ваше тело может перемещаться в пространстве, словно вы космическая пыль."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "space_crawl"
	spell_to_add = /obj/effect/proc_holder/spell/jaunt/space_crawl
	cost = 1

	research_tree_icon_frame = 6


/datum/heretic_knowledge/eldritch_coin
	drafting_tier = 1
	name = "Жуткая Монета"
	desc = "Позволяет преобразовать лист плазмы и алмаз в Жуткую Монету. \
			Монета будет открывать или закрывать ближайшие шлюзы при выпадении \"Еретика\" и переключать их болты \
			при выпадении \"Клинка\". Если вставить монету в шлюз, она будет уничтожена \
			и сожжёт его электронику, что сделает шлюз открытым навсегда, если только он не был заблокирован."
	gain_text = "Обитель — сборище всевозможных грехов. Но жадность играет здесь особую роль."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"


/obj/item/coin/eldritch
	name = "eldritch coin"
	desc = "Удивительно тяжёлая, богато украшенная монета. Рисунки на гранях постоянно меняются."
	gender = FEMALE
	icon_state = "coin_heretic"
	sideslist = list("heretic", "blade")
	/// The range at which airlocks are effected.
	var/airlock_range = 5


/obj/item/coin/eldritch/Initialize(mapload)
	. = ..()
	icon_state = "coin_heretic"


/obj/item/coin/eldritch/get_ru_names()
	return alist(
		NOMINATIVE = "жуткая монета",
		GENITIVE = "жуткой монеты",
		DATIVE = "жуткой монете",
		ACCUSATIVE = "жуткую монету",
		INSTRUMENTAL = "жуткой монетой",
		PREPOSITIONAL = "жуткой монете",
	)


/obj/item/coin/eldritch/attack_self(mob/user)
	var/mob/living/living_user = user
	if(!isheretic(user))
		living_user.adjustBruteLoss(5)
		return

	if(cooldown >= world.time - 15)
		return
	var/coinflip = pick(sideslist)
	cooldown = world.time
	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)
	if(!do_after(user, 1.5 SECONDS, src))
		return
	var/static/list/ru_coinflip = list(
		"heretic" = "Еретик",
		"blade" = "Клинок",
	)
	user.visible_message(
		span_notice("[user] подбрасыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]. Выпало: [span_bold(ru_coinflip[coinflip])]."),
		span_notice("Вы подбросили [declent_ru(ACCUSATIVE)]. Выпало: [span_bold(ru_coinflip[coinflip])]."),
		span_notice("Слышен звон монеты."),
	)
	on_result_act(coinflip)


/obj/item/coin/eldritch/proc/on_result_act(coinflip)
	switch(coinflip)
		if("heretic")
			for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, get_turf(src)))
				if(target_airlock.density)
					target_airlock.open()
					continue

				target_airlock.close()

		if("blade")
			for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, get_turf(src)))
				if(target_airlock.locked)
					target_airlock.unlock()
					continue

				target_airlock.lock()


/obj/item/coin/eldritch/melee_attack_chain(mob/living/user, atom/interacting_with, params)
	if(!is_airlock(interacting_with))
		return ..()

	if(!isheretic(user))
		user.adjustBruteLoss(5)
		user.adjustFireLoss(5)
		user.drop_from_active_hand()
		return ATTACK_CHAIN_BLOCKED_ALL

	var/obj/machinery/door/airlock/target_airlock = interacting_with
	to_chat(user, span_warning("Вы вставляете [declent_ru(ACCUSATIVE)] в шлюз."))
	target_airlock.emag_act(user, src)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL
