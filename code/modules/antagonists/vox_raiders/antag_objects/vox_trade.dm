/obj/machinery/vox_trader
	name = "Расчичетчикик"
	desc = "Приемная и расчетная связная машина для ценностей. Проста также как еда воксов."
	icon = 'icons/obj/machines/trader_machine.dmi'
	icon_state = "trader-idle-off"
	max_integrity = 5000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	var/icon_state_on = "trader-idle"

	var/cooldown = 3 SECONDS
	var/is_trading_now = FALSE

	var/angry_count = 0
	var/static/list/blacklist_users = list()

	var/precious_collected_dict = list()
	var/all_values_sum = 0
	var/precious_value
	var/collected_access_list = list()
	var/collected_tech_dict = list()

	var/list/blacklist_objects = list()

	var/denomination_div = 5

	var/static/list/datum/get_cost_step/get_value_steps = list(
		new /datum/get_cost_step/integrity_step,
		new /datum/get_cost_step/armor_step,
		new /datum/get_cost_step/force_step,
		new /datum/get_cost_step/get_tech_from_disk,
		new /datum/get_cost_step/get_tech,
		new /datum/get_cost_step/tech_step,
		new /datum/get_cost_step/stack_step,
		new /datum/get_cost_step/id_cart_step,
		new /datum/get_cost_step/item_step,
		new /datum/get_cost_step/stock_parts_step,
		new /datum/get_cost_step/gas_step,
		new /datum/get_cost_step/highrisk_step,
		new /datum/get_cost_step/valuable_objects_step,
		new /datum/get_cost_step/valuable_guns_step,
	)

/obj/machinery/vox_trader/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/vox_trader/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/hand_valuer))
		context[SCREENTIP_CONTEXT_LMB] = "Подключить оценщик"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/vox_trader/attack_hand(mob/user)
	if(!try_trade(user))
		return ..()

/obj/machinery/vox_trader/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return

	if(!istype(tool, /obj/item/hand_valuer))
		return

	var/obj/item/hand_valuer/valuer = tool
	valuer.connect(user, src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/vox_trader/attack_ai(mob/user)
	return FALSE	// Ха-ха, глупая железяка не понимает как пользоваться технологиями ВОКСов!

/obj/machinery/vox_trader/proc/check_usable(mob/user)
	. = FALSE
	if(issilicon(user))
		return
	if(!isvox(user))
		to_chat(user, span_notice("Вы осматриваете [src] и не понимаете как оно работает и куда сувать свои пальцы..."))
		return
	if(is_trading_now)
		to_chat(user, span_warning("[src] обрабатываем и пересчитывает ценности. Ожидайте."))
		return
	if(length(blacklist_users) && (user in blacklist_users))
		to_chat(user, span_warning("Вы пытаетесь связаться с [src], но никто не отзывается."))
		return
	return TRUE

/obj/machinery/vox_trader/proc/sparks()
	do_sparks(5, 1, get_turf(src))

/obj/machinery/vox_trader/proc/try_trade(mob/user)
	if(!check_usable(user))
		return FALSE
	add_fingerprint(user)
	user.do_attack_animation(src)
	trade_start()
	addtimer(CALLBACK(src, PROC_REF(do_trade), user), cooldown)
	return TRUE

/obj/machinery/vox_trader/proc/do_trade(mob/user)
	var/list/items_list = get_trade_contents(user)
	INVOKE_ASYNC(src, PROC_REF(make_cash), user, items_list)

/obj/machinery/vox_trader/proc/make_cash(mob/user, list/items_list)
	if(!src || QDELETED(src))
		return

	var/values_sum = get_value(user, items_list)

	if(values_sum <= 10)
		if(values_sum <= 0)
			angry_count++
			switch(angry_count)
				if(3)
					atom_say(span_warning("Вами очень недовольны. Где товар?!"))
				if(4)
					atom_say(span_warning("Вами ОЧЕНЬ недовольны... Нам нужен реальный товар!"))
				if(5)
					atom_say(span_warning("Отправляй товар!"))
				if(6)
					atom_say(span_warning("Что ты щелкаешь как дятел?!"))
				if(7)
					atom_say(span_warning("Или ты будешь отправлять товар или не будешь больше отправлять ничего!"))
				if(8)
					atom_say(span_warning("Я не буду с тобой торговать пока ты не дашь товар!"))
				if(9)
					atom_say(span_warning("Ты шутки шутишь? Товар. Последнее предупреждение."))
				if(10)
					atom_say(span_warning("[user.name], [src] больше не будет с вами торговать!"))
					blacklist_users.Add(user)	// Докикикировался.
				else
					atom_say(span_warning("Вами недовольны. Где товар?"))
		else
			atom_say(span_notice("Расчет окончен. Средства отправлены на транспортные погашения."))
		trade_cancel()
		return

	if(values_sum > 100)
		all_values_sum += values_sum
		atom_say(span_greenannounce("Расчет окончен. [values_sum > 2000 ? "Крайне ценно!" : "Ценно!"] Ваша доля [values_sum]"))
	else
		atom_say(span_notice("Расчет окончен. Вы бы еще консервных банок насобирали! Ваша доля [values_sum]"))

	angry_count = 0
	trade_cancel()
	beam()
	new /obj/item/stack/vox_cash(get_turf(src), values_sum)

/obj/machinery/vox_trader/proc/trade_start()
	is_trading_now = TRUE
	icon_state = icon_state_on
	sparks()
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
	try_update_blacklist()

/obj/machinery/vox_trader/proc/trade_cancel()
	is_trading_now = FALSE
	icon_state = initial(icon_state)
	sparks()

/obj/machinery/vox_trader/proc/beam()
	playsound(get_turf(src), 'sound/weapons/contractorbatonhit.ogg', 25, TRUE)
	flick("trader-beam", src)

/obj/machinery/vox_trader/proc/get_value(mob/user, list/items_list, is_visuale_only = FALSE)
	var/values_sum = 0
	var/values_sum_precious = 0
	var/accepted_access = list()

	var/tech_flag

	for(var/obj/item as anything in items_list)
		if(item.anchored)
			continue

		if(is_cash(item) || isvoxcash(item))
			continue

		var/temp_values_sum = 0
		var/temp_values_sum_precious = 0
		var/list/temp_values = list(
			TRAIDER_VALUE_TEMP_VALUES_SUM = 0,
			TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS = 0,
			TRAIDER_VALUE_ORIGIN_TECH = null,
			TRAIDER_VALUE_TECH_FLAG = NONE,
			TRAIDER_VALUE_IS_VISUALISE_ONLY = is_visuale_only,
			TRAIDER_VALUE_ACCEPTED_ACCESS = list()
		)
		for(var/datum/get_cost_step/step in get_value_steps)
			if(step.can_process_object(item, src, temp_values))
				step.process_object(item, src, temp_values)

		temp_values_sum = temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM]
		temp_values_sum_precious = temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS]

		temp_values_sum /= denomination_div

		if(!is_visuale_only)
			precious_grading(user, item, temp_values_sum + temp_values_sum_precious)

		values_sum += temp_values_sum
		values_sum_precious += temp_values_sum_precious
		tech_flag |= temp_values[TRAIDER_VALUE_TECH_FLAG]
		accepted_access |= temp_values[TRAIDER_VALUE_ACCEPTED_ACCESS]
		if(!is_visuale_only && (temp_values_sum + temp_values_sum_precious) >= 0)
			var/atom/item_location = item.loc
			if(ismob(item_location))	// Cyborg Parts, wearing clothes, but not contents
				var/mob/mob_location = item_location
				mob_location.temporarily_remove_item_from_inventory(item)
			qdel(item)

	var/list/addition_text = list()
	if(length(accepted_access))
		if(!is_visuale_only)
			collected_access_list += accepted_access
		addition_text += span_boldnotice("\nОценка имеющихся доступов: \n")
		for(var/access in accepted_access)
			var/access_desc = get_access_desc(access)
			if(!access_desc)
				continue
			addition_text += span_notice("[access_desc]; ")
		if(tech_flag & VOX_TRADER_ACCESS_UNIQUE)
			addition_text += span_good("\nИмеются ценные доступы. Очень ценно!")

	if(tech_flag & VOX_TRADER_WEIGHT)
		addition_text += span_notice("\nТяжесть — значит надежность.")
	if(tech_flag & VOX_TRADER_EQUIP)
		addition_text += span_notice("\nХорошее снаряжение. Ценно.")
	if(tech_flag & VOX_TRADER_TECH)
		addition_text += span_notice("\nТехнологии — ценно!")
	if(tech_flag & VOX_TRADER_UNIQUE_TECH)
		addition_text += span_notice("\nНовые технологии! Очень ценно! Необходимо!")
	if(tech_flag & VOX_TRADER_VALUABLE_TECH)
		addition_text += span_notice("\nЦенные технологии! Крайне ценно!")

	if(!is_visuale_only && (tech_flag & VOX_TRADER_UNIQUE_TECH))
		update_shops()
		addition_text += span_notice("\nЦены на некоторые товары снижены!")

	if(user && length(addition_text))
		to_chat(user, custom_boxed_message("blue_box", addition_text.Join("")))

	values_sum -= values_sum % 10
	values_sum += values_sum_precious
	return round(values_sum)

/obj/machinery/vox_trader/proc/precious_grading(mob/user, obj/object, value)
	if(!user)
		return
	if(!correct_precious_value(user))
		return
	update_precious_collected_dict(object.name, value)

/obj/machinery/vox_trader/proc/correct_precious_value(mob/user)
	if(precious_value)
		return TRUE
	if(!user)
		return FALSE
	var/list/objectives = user.mind?.get_all_objectives()
	if(!length(objectives))
		return FALSE
	var/datum/objective/raider_steal/objective = locate() in objectives
	precious_value = objective.precious_value
	return TRUE

/obj/machinery/vox_trader/proc/update_precious_collected_dict(object_name, object_value)
	if(!correct_precious_value())
		return
	if(object_value >= precious_value)
		var/precious_data = precious_collected_dict[object_name]
		if(!precious_data)
			precious_collected_dict[object_name] = list(VOX_TRADER_COUNT = 1, VOX_TRADER_VALUE = object_value)
		else
			precious_data[VOX_TRADER_COUNT]++
			precious_data[VOX_TRADER_VALUE] = max(precious_data[VOX_TRADER_VALUE], object_value)

/obj/machinery/vox_trader/proc/synchronize_traders_stats()
	for(var/obj/machinery/vox_trader/trader as anything in SSmachines.get_by_type(/obj/machinery/vox_trader))
		if(trader == src)
			continue

		all_values_sum += trader.all_values_sum

		for(var/access in trader.collected_access_list)
			if(access in collected_access_list)
				continue
			collected_access_list += access

		for(var/tech in trader.collected_tech_dict)
			if(tech in collected_tech_dict)
				collected_tech_dict[tech][1] = max(collected_tech_dict[tech][1], trader.collected_tech_dict[tech][1])
				continue
			collected_tech_dict += tech

		for(var/dict in trader.precious_collected_dict)
			update_precious_collected_dict(trader.precious_collected_dict[dict], trader.precious_collected_dict[dict][VOX_TRADER_VALUE])

/obj/machinery/vox_trader/proc/get_trade_contents(mob/user)
	var/turf/current_turf = get_turf(src)
	var/list/items_list = current_turf.get_all_contents(ON_BORDER|HOLOGRAM) - current_turf

	for(var/item in items_list)
		for(var/blacklist_object in blacklist_objects)
			if(istype(item, blacklist_object))
				items_list.Remove(item)
				continue
		if(isorgan(item)) // Inner organs
			var/obj/item/organ/organ = item
			if(organ.owner)
				items_list.Remove(item)
			continue
		if(isobj(item))
			var/obj/object = item
			if(ismob(object.loc))	// Cyborg Parts, wearing clothes, but not contents
				items_list.Remove(item)
				continue
		if(isliving(item))
			var/mob/living/mob = item
			items_list.Remove(item)
			if(isvox(mob))
				atom_say("Поприветствуйте нового члена стаи — [mob.declent_ru(NOMINATIVE)]")
				make_new_vox_raider(user, mob)
				continue
			send_to_station(mob)

	return items_list

/obj/machinery/vox_trader/proc/send_to_station(mob/living/M)
	M.Sleeping(16 SECONDS)
	M.setOxyLoss(0)
	M.adjustBruteLoss(-25)
	M.adjustFireLoss(-25)
	M.adjustToxLoss(-50)
	M.forceMove(pick(GLOB.latejoin))
	if(!iscarbon(M))
		return
	var/mob/living/carbon/C = M
	C.Silence(6 SECONDS)
	C.uncuff()
	to_chat(C, span_warning("\
		Вы ощущаете как ваши мозги были промыты. \
		Вы всё еще не можете прийти в себя и отрывками вспоминаете что неизвестные похители вас. \
		Неизвестно сколько они продержали вас у себя и что с вами делали... \
		Но вы чувствуете себя будто обновленным.\
	"))

/obj/machinery/vox_trader/proc/make_new_vox_raider(mob/user, mob/living/M)
	if(!M.mind)
		return FALSE

	var/datum/antagonist/vox_raider/antag = locate() in M.mind.antag_datums
	if(antag)
		return FALSE
	for(var/datum/antagonist/A as anything in user.mind.antag_datums)
		var/datum/team/team = A.get_team()
		if(team)
			team.add_member(M.mind, TRUE)
			break

	return TRUE

/obj/machinery/vox_trader/proc/update_shops()
	for(var/obj/machinery/vox_shop/shop as anything in SSmachines.get_by_type(/obj/machinery/vox_shop))
		shop.generate_pack_items()
		shop.generate_pack_lists()

/obj/machinery/vox_trader/proc/try_update_blacklist()
	if(length(blacklist_objects))
		return

	var/obj/machinery/vox_shop/shop = locate() in SSmachines.get_by_type(/obj/machinery/vox_shop)

	if(!shop)
		return

	var/list/all_objects = list()

	for(var/category in shop.packs_items)
		for(var/datum/vox_pack/pack in shop.packs_items[category])
			if(category == VOX_PACK_KIT)
				continue
			var/list/items_list = pack.get_items_list()
			if(!length(items_list))
				break
			all_objects += items_list

	blacklist_objects = all_objects
