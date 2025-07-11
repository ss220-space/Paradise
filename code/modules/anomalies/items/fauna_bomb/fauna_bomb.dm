#define	MAX_CREATED_MOBS	12
#define	MAX_REMEMBERED_MOBS	12

/obj/item/fauna_bomb
	name = "fauna bomb"
	ru_names = list(
		NOMINATIVE = "фаунная бомба", \
		GENITIVE = "фаунной бомбы", \
		DATIVE = "фаунной бомбе", \
		ACCUSATIVE = "фаунную бомбу", \
		INSTRUMENTAL = "фаунной бомбой", \
		PREPOSITIONAL = "фаунной бомбе"
	)
	desc = "Эксперементальный прибор, способный создавать и поддерживать плотные копии отсканированных существ, \
			сделанные из окружающих газов. Для работы требует ядро атмосферной аномалии."
	gender = FEMALE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "bomb"
	item_state = "bomb"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	origin_tech = "bluespace=4;engineering=5"
	/// Inserted atmospheric cnomaly core.
	var/obj/item/assembly/signaler/core/atmospheric/core
	/// List of saved mob datas.
	var/list/datum/airmob_data/datas = list()
	/// List of already created and still alive mobs.
	var/list/mob/living/simple_animal/hostile/airmob/created_mobs = list()
	/// Used level of max_charge.
	var/used_charge = 0
	/// Max level of charge, that can be stored. Depends of inserted core and created mobs.
	var/max_charge = 0
	/// Current level of charge.
	var/charge = 0
	/// Amount of charge that regenerates every SSobj process.
	var/charge_speed = 0
	/// Number of all scans. Used for generating keys for datas.
	var/scan_num = 1
	/// A mob that currently carries src with it.
	var/mob/living/owner = null
	/// If true, owner is choosing someone right now.
	var/in_choose_mode = FALSE
	/// Timer of choosing target.
	var/choose_target_timer
	/// Current choosen target.
	var/atom/current_target = null
		/// Last command that was given. (attack/go/stop) null == stop
	var/last_command = null
	/// Client of somebody, who needs to choose target.
	var/client/chooser = null
	/// Number of current target choosing. Used to not stop choosing because of multiclicks.
	var/cur_choosing = 0

/obj/item/fauna_bomb/Destroy()
	for(var/mob/living/mob in created_mobs)
		mob.death()

	QDEL_LAZYLIST(created_mobs)
	QDEL_LAZYLIST(datas)
	current_target = null
	owner = null
	chooser = null
	core?.forceMove(get_turf(src))
	core = null
	. = ..()

/obj/item/fauna_bomb/proc/use_charge(amount)
	if(amount > charge)
		return FALSE

	var/delta = clamp(amount, -(max_charge - charge), charge)
	charge -= delta
	if(charge == max_charge)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)

	return TRUE

/obj/item/fauna_bomb/attackby(obj/item/item, mob/user, params)
	if(!iscoreatmos(item))
		return ..()

	if(!user.drop_transfer_item_to_loc(item, src))
		balloon_alert(user, "отпустить невозможно!")
		return ATTACK_CHAIN_PROCEED

	var/msg = "ядро вставлено"
	if(core)
		msg = "ядро заменено"
		user.put_in_hands(core)

	core = item
	user.balloon_alert(user, msg)
	update_core()
	return ATTACK_CHAIN_PROCEED

/obj/item/fauna_bomb/process(seconds_per_tick)
	use_charge(-charge_speed)

/obj/item/fauna_bomb/click_alt(mob/user)
	if(!core)
		user.balloon_alert(user, "нет ядра")
		return

	user.put_in_hands(core)
	core = null
	user.balloon_alert(user, "ядро извлечено")
	update_core()

/obj/item/fauna_bomb/proc/update_core()
	charge = 0
	if(!core)
		for(var/mob/living/simple_animal/airmob in created_mobs)
			airmob.death()

		max_charge = 0
		charge_speed = 0
		used_charge = 0
		use_charge(0) // Stop charging.
		return

	max_charge = core.get_strength()
	charge_speed = max_charge / 75
	var/req_charge = 0
	for(var/mob/living/simple_animal/hostile/airmob/airmob as anything in created_mobs)
		airmob.leash_radius = round(core.get_strength() / 15 + 0.5)
		if (get_dist(src, airmob) > airmob.leash_radius)
			airmob.dust()
			continue

		req_charge += airmob.req_charge

	while(used_charge > max_charge)
		var/mob/living/simple_animal/hostile/airmob/cheapest_mob = null
		for(var/mob/living/simple_animal/hostile/airmob/airmob as anything in created_mobs)
			if(cheapest_mob && cheapest_mob.req_charge <= airmob.req_charge)
				continue

			cheapest_mob = airmob

		cheapest_mob.death()

	max_charge -= used_charge
	charge = min(charge, max_charge)
	use_charge(0) // Start charging.

/obj/item/fauna_bomb/examine(mob/user)
	. = ..()
	if(!core)
		. += span_warning("В [declent_ru(PREPOSITIONAL)] нет ядра атмосферной аномалии!")
		return

	. += span_info("Текущий заряд: [charge != max_charge ? charge : span_boldnotice("[charge]")]/[max_charge + used_charge]")
	. += span_info("Свободный заряд: [max_charge != max_charge + used_charge ? max_charge : span_boldnotice("[max_charge]")]/[max_charge + used_charge]")
	. += span_info("Скорость восстановления заряда: [charge_speed]")
	. += span_info("Проецируется существ: [created_mobs.len != MAX_CREATED_MOBS ? created_mobs.len : span_boldnotice("[created_mobs.len]")]/[MAX_CREATED_MOBS]")

/obj/item/fauna_bomb/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] направля[pluralize_ru(user.gender,"ет","ют")] проецирующую систему [declent_ru(GENITIVE)] себе в рот, \
						выкручива[pluralize_ru(user.gender,"ет","ют")] на максимальную мощность и активиру[pluralize_ru(user.gender,"ет","ют")]."), \
						span_suicide("Вы направляете проецирующую систему [declent_ru(GENITIVE)] себе в рот, \
						выкручиваете на максимальную мощность и активируете."),
						span_warning("Вы слышите громкий хлопок!"))
	user.gib()
	return OBLITERATION

/obj/item/fauna_bomb/afterattack(atom/target, mob/user, proximity, params, status)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return ..()

	if(choose_target_timer && user.client == chooser)
		choosing_target_off(cur_choosing)
		current_target = target
		do_commands()
		return

	if(!isanimal(target) && !iscarbon(target))
		return ..()

	if(isancientrobot(target) || isancientrobotleg(target) || isairmob(target))
		return ..()

	if(!proximity)
		return ..()

	if(datas.len >= MAX_REMEMBERED_MOBS)
		user.balloon_alert(user, "мало памяти")
		return

	if(!do_after(user, 0.5 SECONDS, target))
		return

	var/datum/airmob_data/data = new(target, src)
	datas["[scan_num]"] = data
	data.scan_num = scan_num
	scan_num++
	user.balloon_alert(user, "особь просканированна")

/obj/item/fauna_bomb/attack_self(mob/user)
	ui_interact(user)
	if(owner == user)
		return

	if(owner)
		owner.faction -= "fauna_bomb[UID()]"

	user.faction += "fauna_bomb[UID()]"
	owner = user

/obj/item/fauna_bomb/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FaunaBomb", "Управление проецированием")
		ui.open()

/obj/item/fauna_bomb/ui_data(mob/user)
	var/list/data = list()
	var/list/scans = list()
	for(var/key in datas)
		var/datum/airmob_data/scan = datas[key]
		scans += list(list(
			"name" = scan.normal_name + " ([key])",
			"cost" = scan.req_charge,
			"health" = scan.maxHealth,
			"dmg_low" = scan.melee_damage_lower,
			"dmg_high" = scan.melee_damage_upper,
			"dmg_obj" = scan.obj_damage,
			"icon" = icon2base64(scan.icon),
			"index" = scan.scan_num,
		))

	data["scans"] = scans
	data["charge"] = charge
	data["max_charge"] = max_charge
	data["charge_speed"] = charge_speed
	data["created_len"] = created_mobs.len
	return data

/obj/item/fauna_bomb/proc/do_commands()
	for(var/mob/living/simple_animal/hostile/airmob/mob in created_mobs)
		mob.do_commands()

/obj/item/fauna_bomb/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("forget")
			atom_say("Функция временно недоступна!", FALSE)
			/*return
			var/index = params["index"]
			for(var/mob/living/simple_animal/hostile/airmob/airmob in created_mobs)
				if(airmob.scan_num != datas["[index]"].scan_num)
					continue

				airmob.death()

			datas.Remove("[index]")*/

		if("kill")
			var/index = params["index"]
			var/mob/living/simple_animal/hostile/airmob/weakest_mob = null
			for(var/mob/living/simple_animal/hostile/airmob/airmob in created_mobs)
				if(airmob.scan_num == datas["[index]"].scan_num && (!weakest_mob || weakest_mob.health > airmob.health))
					weakest_mob = airmob

			if(!weakest_mob)
				ui.user.balloon_alert(ui.user, "нет таких проекций")
				return

			weakest_mob.death()
			ui.user.balloon_alert(ui.user, "проекция развеяна")

		if("create")
			if(created_mobs.len >= MAX_CREATED_MOBS)
				ui.user.balloon_alert(ui.user, "превышение нагрузки")
				return

			var/index = params["index"]
			if(!use_charge(datas["[index]"].req_charge))
				ui.user.balloon_alert(ui.user, "недостаточно энергии")
				return

			used_charge += datas["[index]"].req_charge
			max_charge -= datas["[index]"].req_charge
			var/mob/mob = new /mob/living/simple_animal/hostile/airmob(get_turf(src), src, datas["[index]"])
			created_mobs.Add(mob)
			mob.faction = list("fauna_bomb[UID()]")
			for(var/j = 1, j <= rand(1, 3), j++)
				step(mob, GLOB.cardinal)

			ui.user.balloon_alert(ui.user, "проекция создана")

		if("attack")
			last_command = action
			choose_target(ui.user.client)

		if("go")
			last_command = action
			choose_target(ui.user.client)

		if("stop")
			current_target = src
			last_command = action
			do_commands()


#define CHOOSING_ICON 'icons/effects/cult_target.dmi'

/obj/item/fauna_bomb/proc/choose_target(client/client)
	cur_choosing++
	choose_target_timer = addtimer(CALLBACK(src, PROC_REF(choosing_target_off), cur_choosing), 3 SECONDS)
	chooser = client
	in_choose_mode = TRUE
	if(chooser?.mouse_pointer_icon == initial(chooser.mouse_pointer_icon))
		chooser.mouse_pointer_icon = CHOOSING_ICON

/obj/item/fauna_bomb/proc/choosing_target_off(choosing_num)
	if(choosing_num != cur_choosing)
		return

	choose_target_timer = null
	in_choose_mode = FALSE
	if(chooser?.mouse_pointer_icon == CHOOSING_ICON)
		chooser.mouse_pointer_icon = initial(chooser.mouse_pointer_icon)

#undef CHOOSING_ICON

/obj/item/fauna_bomb/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim)
	return ATTACK_CHAIN_PROCEED

/obj/item/fauna_bomb/preloaded/Initialize(mapload)
	. = ..()
	update_core()

/obj/item/fauna_bomb/preloaded/t1
	core = new /obj/item/assembly/signaler/core/atmospheric/tier1

/obj/item/fauna_bomb/preloaded/t2
	core = new /obj/item/assembly/signaler/core/atmospheric/tier2

/obj/item/fauna_bomb/preloaded/t3
	core = new /obj/item/assembly/signaler/core/atmospheric/tier3

/datum/crafting_recipe/fauna_bomb
	name = "Fauna bomb"
	result = /obj/item/fauna_bomb
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/relict_production/pet_spray = 1,
				/obj/item/grenade/chem_grenade/adv_release = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

#undef	MAX_CREATED_MOBS
#undef	MAX_REMEMBERED_MOBS
