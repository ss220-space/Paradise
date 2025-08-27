/obj/item/gun/energy/anomaly_stabilizer
	name = "стабилизатор аномалий"
	desc = "Продвинутое устройство, предназначенное для стабилизации аномалий. \
			Имеет две ячейки для ядер аномалий."
	icon = 'icons/obj/anomaly/anomaly_stuff.dmi'
	icon_state = "pistol_base_item"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "pistol_base"
	gender = MALE
	can_add_sibyl_system = FALSE
	origin_tech = "programming=3;magnets=3"
	cell_type = /obj/item/stock_parts/cell/high
	resistance_flags = FIRE_PROOF
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	var/cur_ammo_type = /obj/item/ammo_casing/energy/anomaly/stabilizer
	/// Cores inserted into this anomaly stabilizer.
	var/list/obj/item/assembly/signaler/core/cores = list()
	/// Range of allowed stability deltas. If val - X, range is [-x; x].
	var/stability_range = 1
	/// The current value of the anomaly's stability change upon impact.
	var/stability_delta = 1
	/// Max allowed anomaly pull range.
	var/pull_range = 0
	/// Choosen anomaly pull distance.
	var/choosen_pull_dist = 0
	/// Choosen time on which beams block anomaly's normal movements.
	var/block_move_time = 0
	/// Choosen time on which beams block anomaly's impulsive movements.
	var/block_move_impulses_time = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/weaken_val = 0
	/// The time after hit at which the reduction in the effects of the anomaly will be reset.
	var/weaken_time = 0
	/// If true, tgui will show more info about this anomaly_stabilizer.
	var/full_info = FALSE

/obj/item/gun/energy/anomaly_stabilizer/get_ru_names()
	return list(
		NOMINATIVE = "стабилизатор аномалий", \
		GENITIVE = "стабилизатора аномалий", \
		DATIVE = "стабилизатору аномалий", \
		ACCUSATIVE = "стабилизатор аномалий", \
		INSTRUMENTAL = "стабилизатором аномалий", \
		PREPOSITIONAL = "стабилизаторе аномалий"
	)

/obj/item/gun/energy/anomaly_stabilizer/Initialize(mapload, ...)
	. = ..()
	update_stability_delta(1)

/obj/item/gun/energy/anomaly_stabilizer/attack_self(mob/living/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/gun/energy/anomaly_stabilizer/newshot()
	if(!cell || cell.charge < get_req_ecost())
		return

	chambered = new cur_ammo_type
	if(!chambered.BB)
		chambered.newshot()

	var/obj/item/ammo_casing/energy/anomaly/en_chambered = chambered
	en_chambered.e_cost = get_req_ecost()

	var/obj/projectile/beam/anomaly/shot = chambered.BB
	shot.stability_delta = stability_delta
	shot.pull_strength = choosen_pull_dist
	shot.move_block = block_move_time
	shot.move_impulces_block = block_move_impulses_time
	shot.anom_weaken = weaken_val
	shot.weaken_time = weaken_time

/obj/item/gun/energy/anomaly_stabilizer/proc/update_stability_delta(new_val)
	new_val = clamp(new_val, -stability_range, stability_range)
	stability_delta = new_val

	if(new_val > 0)
		cur_ammo_type = /obj/item/ammo_casing/energy/anomaly/stabilizer
	else if(new_val < 0)
		cur_ammo_type = /obj/item/ammo_casing/energy/anomaly/destabilizer
	else
		cur_ammo_type = /obj/item/ammo_casing/energy/anomaly


/obj/item/gun/energy/anomaly_stabilizer/proc/eject_core(index, mob/user)
	if(user)
		user.put_in_hands(cores[index])
	else
		cores[index].forceMove(get_turf(src))

	cores.Remove(cores[index])
	update_cores()


/obj/item/gun/energy/anomaly_stabilizer/proc/insert_core(obj/item/assembly/signaler/core/core, mob/user)
	add_fingerprint(user)
	if(iscoreempty(core))
		balloon_alert(user, "ядро пустое!")
		return ATTACK_CHAIN_PROCEED

	if(cores.len >= 2)
		balloon_alert(user, "ячейки для ядер заняты!")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(core, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED

	cores.Add(core)
	update_cores()
	balloon_alert(user, "ядро вставлено")
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/energy/anomaly_stabilizer/proc/update_cores()
	var/strength_energetic = 0
	var/strength_atmospheric = 0
	var/strength_bluespace = 0
	var/strength_vortex = 0
	var/strength_gravitation = 0
	for(var/obj/item/assembly/signaler/core/core in cores)
		var/strength = core.get_strength()
		if(iscoreflux(core))
			strength_energetic += strength

		if(iscoreatmos(core))
			strength_atmospheric += strength

		if(iscorebluespace(core))
			strength_bluespace += strength

		if(iscorevortex(core))
			strength_vortex += strength

		if(iscoregrav(core))
			strength_gravitation += strength

	stability_range = 1 + round(strength_energetic / 50 + 0.5)
	update_stability_delta(stability_delta)

	pull_range = round(strength_gravitation / 50 + 0.5)
	choosen_pull_dist = clamp(choosen_pull_dist, -pull_range, pull_range)

	block_move_time = (strength_vortex / 100) SECONDS

	block_move_impulses_time = (strength_bluespace / 100) SECONDS

	weaken_val = strength_atmospheric / 3
	weaken_time = (strength_atmospheric / 50) SECONDS

	newshot()

/obj/item/gun/energy/anomaly_stabilizer/attackby(obj/item/item, mob/user, params)
	if(user.intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	if(iscell(item))
		if(!user.drop_transfer_item_to_loc(item, src))
			balloon_alert(user, "отпустить невозможно!")
			return ATTACK_CHAIN_PROCEED

		user.put_in_hands(cell)
		cell = item
		cell_type = item.type
		balloon_alert(user, "батарейка заменена")
		return ATTACK_CHAIN_PROCEED

	if(!iscore(item))
		return ..()

	return insert_core(item, user)


/obj/item/gun/energy/anomaly_stabilizer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyStabilizer", "Стабилизатор аномалий")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/gun/energy/anomaly_stabilizer/ui_data(mob/user)
	var/list/data = list()
	data["full_info"] = full_info
	data["core1_name"] = null
	data["core2_name"] = null
	if(cores.len > 0)
		data["core1_name"] = cores[1].name

	if(cores.len > 1)
		data["core2_name"] = cores[2].name

	data["possible_stability"] = stability_range
	data["stability_delta"] = stability_delta
	data["pull_range"] = pull_range
	data["choosen_pull_dist"] = choosen_pull_dist
	data["block_move_time"] = block_move_time
	data["block_move_impulses_time"] = block_move_impulses_time
	data["weaken_val"] = weaken_val
	data["weaken_time"] = weaken_time
	return data

/obj/item/gun/energy/anomaly_stabilizer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("eject1")
			eject_core(1, ui.user)

		if("eject2")
			eject_core(2, ui.user)

		if("change_stability")
			var/new_val = text2num(params["new_val"])
			update_stability_delta(new_val)
			update_icon(UPDATE_OVERLAYS)
			newshot()

		if("change_pull_dist")
			var/new_val = text2num(params["new_val"])
			choosen_pull_dist = new_val
			newshot()

		if("toggle_full_info")
			full_info = !full_info

		else
			return FALSE

/obj/item/gun/energy/anomaly_stabilizer/examine(mob/user)
	. = ..()
	var/shots = round(cell.charge / get_req_ecost())
	. += span_notice("Индикатор заряда сообщает: [cell.charge]\\[cell.maxcharge].")
	. += span_notice("Этого хватит на [shots] [declension_ru(shots, "выстрел", "выстрела", "выстрелов")] и изменение стабильности аномалии на [shots * stability_delta] [declension_ru(shots * stability_delta, "единицу", "единицы", "единиц")] при текущих настройках.")


/obj/item/gun/energy/anomaly_stabilizer/proc/get_req_ecost()
	var/cost = /obj/item/ammo_casing/energy/anomaly::e_cost
	cost *= max(1, stability_delta * stability_delta)
	return cost


/obj/item/gun/energy/anomaly_stabilizer/update_overlays()
	. = list()
	if(cell.charge < get_req_ecost())
		return

	if(stability_delta < 0)
		. += image(icon = icon, icon_state = "pistol_destab_overlay")
		return

	if(stability_delta > 0)
		. += image(icon = icon, icon_state = "pistol_stabil_overlay")
		return

	. += image(icon = icon, icon_state = "pistol_zero_overlay")

