/****************Mining Charges****************/
/obj/item/grenade/plastic/miningcharge
	name = "industrial mining charge"
	desc = "Применяется для создания больших отверстий в породе. Эффективно только при работе с камнем!"
	ru_names = list(
		NOMINATIVE = "промышленный шахтёрский заряд",
		GENITIVE = "промышленного шахтёрского заряда",
		DATIVE = "промышленному шахтёрскому заряду",
		ACCUSATIVE = "промышленный шахтёрский заряд",
		INSTRUMENTAL = "промышленным шахтёрским зарядом",
		PREPOSITIONAL = "промышленном шахтёрском заряде"
	)
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining-charge-2"
	item_state = "charge_indust"
	det_time = 5 SECONDS
	notify_admins = FALSE // no need to make adminlogs on lavaland, while they are "safe" to use
	/// When TRUE, charges won't detonate on it's own. Used for mining detonator
	var/timer_off = FALSE
	/// list of sizes for explosion. Third number is used for actual rock explosion size, second number is radius for Weaken() effects, first is used for hacked charges
	var/boom_sizes = list(2,3,5)

	var/hacked = FALSE
	var/installed = FALSE
	var/smoke_amount = 3

/obj/item/grenade/plastic/miningcharge/examine(mob/user)
	. = ..()
	if(hacked)
		. += span_warning("Его проводка была небрежно изменена.")
	if(timer_off)
		. += span_notice("Шахтёрский заряд подключён к детонатору.")

/obj/item/grenade/plastic/miningcharge/Initialize(mapload)
	. = ..()
	image_overlay = mutable_appearance(icon, "[icon_state]_active", ON_EDGED_TURF_LAYER)

/obj/item/grenade/plastic/miningcharge/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)

/obj/item/grenade/plastic/miningcharge/afterattack(atom/movable/AM, mob/user, flag, params)
	if(ismineralturf(AM) || hacked)
		if(isancientturf(AM) && !hacked)
			visible_message(span_notice("Эта порода, кажется, устойчива ко всем инструментам, кроме кирок!"))
			return
		if(timer_off) //override original proc for plastic explosions
			if(!flag)
				return
			if(iscarbon(AM))
				return
			balloon_alert(user, "установка взрывчатки...")
			if(do_after(user, 2.5 SECONDS * toolspeed, AM, category = DA_CAT_TOOL))
				if(!user.drop_item_ground(src))
					return
				src.target = AM
				loc = null
				if(hacked)
					message_admins("[ADMIN_LOOKUPFLW(user)] planted [src] on [target.name] at [ADMIN_COORDJMP(target)]")
					add_game_logs("planted [name] on [target.name] at [COORD(target)]", user)
				installed = TRUE
				target.add_overlay(image_overlay)
			return
		..()


/obj/item/grenade/plastic/miningcharge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/detonator))
		add_fingerprint(user)
		var/obj/item/detonator/detonator = I
		if((src in detonator.bombs) || timer_off)
			balloon_alert(user, "уже синхронизировано!")
			return ATTACK_CHAIN_PROCEED
		detonator.bombs += src
		timer_off = TRUE
		balloon_alert(user, "синхронизировано")
		playsound(loc, 'sound/machines/twobeep.ogg', 50)
		detonator.update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/grenade/plastic/miningcharge/proc/detonate()
	addtimer(CALLBACK(src, PROC_REF(prime)), 3 SECONDS)

/obj/item/grenade/plastic/miningcharge/prime()
	if(hacked) //explosion
		explode()
		return
	var/turf/simulated/mineral/location = get_turf(target)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = smoke_amount, location = location)
	smoke.start()
	//location.attempt_drill(null,TRUE,3) //orange says it doesnt include the actual middle
	for(var/turf/simulated/mineral/rock in circlerangeturfs(location, boom_sizes[3]))
		var/distance = get_dist_euclidean(location, rock)
		if(distance <= boom_sizes[1])
			rock.attempt_drill(null,TRUE,3)
		else if (distance <= boom_sizes[2])
			rock.attempt_drill(null,TRUE,2)
		else if (distance <= boom_sizes[3])
			rock.attempt_drill(null,TRUE,1)

	for(var/mob/living/carbon/C in circlerange(location,boom_sizes[3]))
		if(ishuman(C)) //working on everyone
			var/distance = get_dist_euclidean(location, C)
			C.flash_eyes()
			C.Knockdown((boom_sizes[2] - distance) * 1 SECONDS) //1 second for how close you are to center if you're in range
			C.AdjustDeaf((boom_sizes[3] - distance) * 10 SECONDS)
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(istype(ears))
				ears.internal_receive_damage((boom_sizes[3] - distance) * 2) //something like that i guess. Mega charge makes 12 damage to ears if nearby
			to_chat(C, span_userdanger("Вас сбивает с ног мощь горнодобывающего заряда!"))
	qdel(src)

/obj/item/grenade/plastic/miningcharge/proc/explode() //c4 code
	var/turf/location
	if(target)
		if(!QDELETED(target))
			if(istype(target, /turf/))
				location = get_turf(target)
			else
				location = get_atom_on_turf(target)
			target.cut_overlay(image_overlay)
	else
		location = get_atom_on_turf(src)
	if(location)
		explosion(location, devastation_range = boom_sizes[1], heavy_impact_range = boom_sizes[2], light_impact_range = boom_sizes[3], cause = src)
		location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/grenade/plastic/update_icon_state()
	return //Remove plastic icon_state change logic override


/obj/item/grenade/plastic/miningcharge/proc/override_safety()
	hacked = TRUE
	notify_admins = TRUE
	boom_sizes[1] = round(boom_sizes[1]/3)	//lesser - 0, normal - 0, mega - 1; c4 - 0
	boom_sizes[2] = round(boom_sizes[2]/3)	//lesser - 0, normal - 1, mega - 2; c4 - 0
	boom_sizes[3] = round(boom_sizes[3]/1.5)//lesser - 2, normal - 3, mega - 5; c4 - 3

/obj/item/grenade/plastic/miningcharge/deconstruct(disassembled = TRUE) //no gibbing a miner with pda bombs
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/plastic/miningcharge/lesser
	name = "mining charge"
	desc = "Заряд для шахтёрских работ. Этот кажется менее мощным, чем промышленный. Работает только на породе!"
	ru_names = list(
		NOMINATIVE = "шахтёрский заряд",
		GENITIVE = "шахтёрского заряда",
		DATIVE = "шахтёрскому заряду",
		ACCUSATIVE = "шахтёрский заряд",
		INSTRUMENTAL = "шахтёрским зарядом",
		PREPOSITIONAL = "шахтёрском заряде"
	)
	icon_state = "mining-charge-1"
	item_state = "charge_lesser"
	smoke_amount = 1
	boom_sizes = list(1,2,3)

/obj/item/grenade/plastic/miningcharge/mega
	name = "experimental mining charge"
	desc = "Заряд для шахтёрских работ. Этот кажется значительно мощнее обычного!"
	ru_names = list(
		NOMINATIVE = "экспериментальный шахтёрский заряд",
		GENITIVE = "экспериментального шахтёрского заряда",
		DATIVE = "экспериментальному шахтёрскому заряду",
		ACCUSATIVE = "экспериментальный шахтёрский заряд",
		INSTRUMENTAL = "экспериментальным шахтёрским зарядом",
		PREPOSITIONAL = "экспериментальном шахтёрском заряде"
	)
	icon_state = "mining-charge-3"
	item_state = "charge_mega"
	smoke_amount = 5
	boom_sizes = list(4,6,8) //did you see the price? It has to be better..

/obj/item/storage/backpack/duffel/miningcharges/populate_contents()
	for(var/i in 1 to 2)
		new /obj/item/grenade/plastic/miningcharge/mega(src)
	for(var/i in 1 to 4)
		new /obj/item/grenade/plastic/miningcharge(src)
	for(var/i in 1 to 5)
		new /obj/item/grenade/plastic/miningcharge/lesser(src)
	new /obj/item/detonator(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore/bigger(src)


//MINING CHARGE HACKER
/obj/item/t_scanner/adv_mining_scanner/syndicate
	var/charges = 6
	description_antag = "Это устройство имеет дополнительный порт, который позволяет обойти меры безопасности шахтёрских зарядов."

/obj/item/t_scanner/adv_mining_scanner/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(target,/obj/item/grenade/plastic/miningcharge))
		var/obj/item/grenade/plastic/miningcharge/charge = target
		if(charge.hacked)
			balloon_alert(user, "уже взломано!")
			return
		if(charges <= 0)
			balloon_alert(user, "заряды закончились!")
			return
		charge.override_safety()
		visible_message(span_warning("Из [declent_ru(GENITIVE)] летят искры!"), span_notice("Вы перегружаете [declent_ru(ACCUSATIVE)], отключая его защиту."))
		playsound(src, SFX_SPARKS, 50, TRUE)
		charges--
		if(charges <= 0)
			to_chat(user , span_warning("Внутренняя батарея [declent_ru(GENITIVE)], предназначенная для перегрузки шахтёрских зарядов, разрядилась!"))

// MINING CHARGES DETONATOR

/obj/item/detonator
	name = "mining charge detonator"
	desc = "Специализированное устройство для контролируемых подрывных работ с использованием шахтёрских зарядов."
	ru_names = list(
		NOMINATIVE = "детонатор шахтёрских зарядов",
		GENITIVE = "детонатора шахтёрских зарядов",
		DATIVE = "детонатору шахтёрских зарядов",
		ACCUSATIVE = "детонатор шахтёрских зарядов",
		INSTRUMENTAL = "детонатором шахтёрских зарядов",
		PREPOSITIONAL = "детонаторе шахтёрских зарядов"
	)
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/mining.dmi'
	icon_state = "Detonator-0"
	/// list of all bombs connected to a detonator for a moment
	var/list/bombs = list()

/obj/item/detonator/examine(mob/user)
	. = ..()
	if(bombs.len)
		. += span_notice("Список синхронизированных зарядов:")
		for(var/obj/item/grenade/plastic/miningcharge/charge in bombs)
			. += span_notice("[bicon(charge)] [capitalize(charge.declent_ru(NOMINATIVE))]. Текущий статус: [charge.installed ? "готов к подрыву" : "готов к установке"].")


/obj/item/detonator/update_icon_state()
	if(length(bombs))
		icon_state = "Detonator-1"
	else
		icon_state = initial(icon_state)


/obj/item/detonator/attack_self(mob/user)
	playsound(src, 'sound/items/detonator.ogg', 40)
	if(bombs.len)
		balloon_alert(user, "активация взрывчатки...")
		for(var/obj/item/grenade/plastic/miningcharge/charge in bombs)
			if(QDELETED(charge))
				to_chat(user, span_notice("Не удаётся найти [charge.declent_ru(ACCUSATIVE)]. Удаление из списка..."))
				bombs -= charge
				return
			if(charge.installed)
				bombs -= charge
				charge.detonate()
	else
		balloon_alert(user, "нет привязанной взрывчатки!")
	update_icon(UPDATE_ICON_STATE)
	. = ..()
