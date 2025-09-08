//Simple borg hand.
//Limited use.
/obj/item/gripper
	name = "magnetic gripper"
	desc = "Простой захватывающий инструмент для синтетических материалов."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"

	//Has a list of items that it can hold.
	var/list/can_hold = list(
		/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/intercom_electronics,
		/obj/item/apc_electronics,
		/obj/item/access_control,
		/obj/item/tracker_electronics,
		/obj/item/stock_parts,
		/obj/item/vending_refill,
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/mounted/frame/extinguisher,
		/obj/item/mounted/frame/light_switch,
		/obj/item/mounted/frame/door_control,
		/obj/item/assembly/control,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/tile/light,
		/obj/item/stack/ore/bluespace_crystal
	)

	//Item currently being held.
	var/obj/item/gripped_item = null

/obj/item/gripper/get_ru_names()
	return list(
		NOMINATIVE = "магнитный захват",
		GENITIVE = "магнитного захвата",
		DATIVE = "магнитному захвату",
		ACCUSATIVE = "магнитный захват",
		INSTRUMENTAL = "магнитным захватом",
		PREPOSITIONAL = "магнитном захвате"
	)

/obj/item/gripper/medical
	name = "medical gripper"
	desc = "Захватывающий инструмент, используемый для удержания органов и помощи пациентам после завершения операции."
	can_hold = list(/obj/item/organ,
					/obj/item/reagent_containers/iv_bag,
					/obj/item/robot_parts/head,
					/obj/item/robot_parts/l_arm,
					/obj/item/robot_parts/r_arm,
					/obj/item/robot_parts/l_leg,
					/obj/item/robot_parts/r_leg,
					/obj/item/robot_parts/chest,
					/obj/item/stack/sheet/mineral/plasma) //for repair plasmamans

/obj/item/gripper/medical/get_ru_names()
	return list(
		NOMINATIVE = "медицинский захват",
		GENITIVE = "медицинского захвата",
		DATIVE = "медицинскому захвату",
		ACCUSATIVE = "медицинский захват",
		INSTRUMENTAL = "медицинским захватом",
		PREPOSITIONAL = "медицинском захвате"
	)

/obj/item/gripper/medical/attack_self(mob/user)
	return

/obj/item/gripper/proc/try_shake_up(mob/living/user, atom/target)
	if(!gripped_item && Adjacent(user, target) && target && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.body_position == LYING_DOWN)
			H.AdjustSleeping(-10 SECONDS)
			H.AdjustParalysis(-6 SECONDS)
			H.AdjustStunned(-6 SECONDS)
			H.AdjustWeakened(-6 SECONDS)
			if(!H.IsSleeping())
				H.set_resting(FALSE, instant = TRUE)
			playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			user.visible_message( \
				span_notice("[user] тряс[pluralize_ru(user.gender,"ет","ут")] [H] пытаясь поднять [genderize_ru(H.gender,"его","её","его","их")]!"),\
				span_notice("Вы трясёте [H] пытаясь поднять [genderize_ru(H.gender,"его","её","его","их")]!"),\
				)
			user.changeNext_move(CLICK_CD_MELEE)
		return

/obj/item/gripper/medical/melee_attack_chain(mob/living/user, atom/target, params)
	try_shake_up(user, target)
	. = ..()

/obj/item/gripper/service
	name = "Card gripper"
	desc = "Захватывающий инструмент, используемый для изъятия ID-карт, для уплаты налогов, и пробуждения пьяных членов экипажа."
	can_hold = list(/obj/item/card,
					/obj/item/camera_film,
					/obj/item/paper,
					/obj/item/photo,
					/obj/item/toy/plushie,
					/obj/item/reagent_containers/food,
					/obj/item/seeds,
					/obj/item/disk/plantgene)

/obj/item/gripper/service/get_ru_names()
	return list(
		NOMINATIVE = "карточный захват",
		GENITIVE = "карточного захвата",
		DATIVE = "карточному захвату",
		ACCUSATIVE = "карточный захват",
		INSTRUMENTAL = "карточным захватом",
		PREPOSITIONAL = "карточном захвате"
	)

/obj/item/gripper/service/melee_attack_chain(mob/living/user, atom/target, params)
	try_shake_up(user, target)
	. = ..()

/obj/item/gripper/cogscarab
	name = "ancient gripper"
	desc = "Латунный захватывающий инструмент для поддержки коллег."
	icon = 'icons/obj/device.dmi'
	icon_state = "clock_gripper"

/obj/item/gripper/cogscarab/get_ru_names()
	return list(
		NOMINATIVE = "древний захват",
		GENITIVE = "древнего захвата",
		DATIVE = "древнему захвату",
		ACCUSATIVE = "древний захват",
		INSTRUMENTAL = "древним захватом",
		PREPOSITIONAL = "древнем захвате"
	)

/obj/item/gripper/cogscarab/New()
	//Has a list of items that it can hold.
	can_hold += list(
		/obj/item/clockwork/integration_cog,
		/obj/item/clockwork/shard,
		/obj/item/stack/sheet,
		/obj/item/mmi/robotic_brain/clockwork
	)
	..()

/obj/item/gripper/universal
	name = "Universal gripper"
	desc = "Универсальный захватывающий инструмент, используемый для выполнения сверх секретных заданий клана паука."
	icon_state = "diskgripper"
	can_hold = list(/obj/item/firealarm_electronics,
		/obj/item/airalarm_electronics,
		/obj/item/airlock_electronics,
		/obj/item/firelock_electronics,
		/obj/item/intercom_electronics,
		/obj/item/apc_electronics,
		/obj/item/access_control,
		/obj/item/tracker_electronics,
		/obj/item/stock_parts,
		/obj/item/vending_refill,
		/obj/item/mounted/frame/light_fixture,
		/obj/item/mounted/frame/apc_frame,
		/obj/item/mounted/frame/alarm_frame,
		/obj/item/mounted/frame/firealarm,
		/obj/item/mounted/frame/newscaster_frame,
		/obj/item/mounted/frame/intercom,
		/obj/item/mounted/frame/extinguisher,
		/obj/item/mounted/frame/light_switch,
		/obj/item/mounted/frame/door_control,
		/obj/item/assembly/control,
		/obj/item/rack_parts,
		/obj/item/camera_assembly,
		/obj/item/tank,
		/obj/item/circuitboard,
		/obj/item/stack/tile/light,
		/obj/item/stack/ore/bluespace_crystal,
		/obj/item/organ,
		/obj/item/reagent_containers/iv_bag,
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_leg,
		/obj/item/robot_parts/chest,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/card,
		/obj/item/camera_film,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/toy/plushie,
		/obj/item/reagent_containers/food,
		/obj/item/seeds,
		/obj/item/disk/plantgene)

/obj/item/gripper/universal/get_ru_names()
	return list(
		NOMINATIVE = "универсальный захват",
		GENITIVE = "универсального захвата",
		DATIVE = "универсальному захвату",
		ACCUSATIVE = "универсальный захват",
		INSTRUMENTAL = "универсальным захватом",
		PREPOSITIONAL = "универсальном захвате"
	)

/obj/item/gripper/nuclear
	name = "Nuclear gripper"
	desc = "Создан для всех ваших ядерных нужд."
	icon_state = "diskgripper"
	can_hold = list(/obj/item/disk/nuclear)

/obj/item/gripper/nuclear/get_ru_names()
	return list(
		NOMINATIVE = "ядерный захват",
		GENITIVE = "ядерного захвата",
		DATIVE = "ядерному захвату",
		ACCUSATIVE = "ядерный захват",
		INSTRUMENTAL = "ядерным захватом",
		PREPOSITIONAL = "ядерном захвате"
	)

/obj/item/gripper/New()
	..()
	can_hold = typecacheof(can_hold)

/obj/item/gripper/verb/drop_item_gripped()
	set name = "Выкинуть предмет"
	set desc = "Release an item from your magnetic gripper."
	set category = STATPANEL_DRONE
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	drop_gripped_item()

/obj/item/gripper/attack_self(mob/user)
	if(gripped_item)
		gripped_item.attack_self(user)
	else
		balloon_alert(user, "клешня пуста!")

/obj/item/gripper/tool_act(mob/living/user, obj/item/tool, tool_type)
	if(!gripped_item)
		return FALSE
	. = gripped_item.tool_act(user, tool, tool_type)
	if(QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything

/obj/item/gripper/Click(location,control,params)
	if(!usr.get_active_hand())
		usr.ClickOn(src, params)
		return
	gripped_item ? usr.ClickOn(gripped_item, params) : usr.ClickOn(src, params)

/obj/item/gripper/DblClick(location,control,params)
	if(!usr.get_active_hand())
		usr.DblClickOn(src, params)
		return
	gripped_item ? usr.DblClickOn(gripped_item, params) : usr.ClickOn(src, params)


/obj/item/gripper/attackby(obj/item/weapon, mob/user, params)
	if(!gripped_item)
		return ATTACK_CHAIN_PROCEED
	. = gripped_item.attackby(weapon, user, params)
	if(QDELETED(gripped_item)) // if item was dissasembled we need to clear the pointer
		drop_gripped_item(TRUE) // silent = TRUE to prevent "You drop X" message from appearing without actually dropping anything


/obj/item/gripper/proc/drop_gripped_item(silent = FALSE)
	if(!gripped_item)
		return
	if(!silent)
		balloon_alert(loc, "предмет выброшен")
	gripped_item.forceMove(get_turf(src))
	gripped_item = null


/obj/item/gripper/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/// Grippers are snowflakey so this is needed to to prevent forceMoving grippers after `if(!user.drop_from_active_hand())` checks done in certain attackby's.
/obj/item/gripper/forceMove(atom/destination)
	return

/obj/item/gripper/proc/isEmpty()
	return isnull(gripped_item)


/obj/item/gripper/melee_attack_chain(mob/user, atom/target, params)	// this shit requires massive refactoring
	. = ATTACK_CHAIN_PROCEED

	if(gripped_item) //Already have an item.
		//Pass the attack on to the target. This might delete/relocate gripped_item.
		. |= target.attackby(gripped_item, user, params)
		if((. & ATTACK_CHAIN_NO_AFTERATTACK) || QDELETED(src) || QDELETED(gripped_item) || QDELETED(target) || QDELETED(user))
			// If the attackby didn't resolve or delete the target or gripped_item, afterattack
			// (Certain things, such as mountable frames, rely on afterattack)
			gripped_item.afterattack(target, user, TRUE, params)

		//If gripped_item either didn't get deleted, or it failed to be transfered to its target
		if(!gripped_item && contents.len)
			gripped_item = contents[1]
		else if(gripped_item && !contents.len)
			gripped_item = null

	else if(isitem(target)) //Check that we're not pocketing a mob.
		var/obj/item/I = target
		if(is_type_in_typecache(I, can_hold)) // Make sure the item is something the gripper can hold
			. |= ATTACK_CHAIN_SUCCESS
			balloon_alert(user, "подобрано")
			I.forceMove(src)
			gripped_item = I
			I.update_icon(UPDATE_OVERLAYS) //Some items change their appearance upon being pulled (IV drip as an example)
			update_icon(UPDATE_OVERLAYS)
			RegisterSignal(I, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(handle_item_moving))
			RegisterSignal(I, list(COMSIG_ATOM_UPDATED_ICON), PROC_REF(handle_item_icon_update))
		else
			balloon_alert(user, "невозможно взять!")

	else //We are empty and trying to attack something else
		target.attack_hand(user)
		. |= ATTACK_CHAIN_SUCCESS


/obj/item/gripper/proc/handle_item_moving()
	SIGNAL_HANDLER
	UnregisterSignal(gripped_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_ATOM_UPDATED_ICON))
	gripped_item.update_icon(UPDATE_OVERLAYS)
	gripped_item = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/gripper/proc/handle_item_icon_update()
	SIGNAL_HANDLER
	update_icon(UPDATE_OVERLAYS)

/obj/item/gripper/update_overlays()
	. = ..()
	if(gripped_item)
		alpha = 128
		var/mutable_appearance/item_preview = mutable_appearance(gripped_item.icon, gripped_item.icon_state, appearance_flags = RESET_ALPHA|RESET_COLOR|RESET_TRANSFORM)
		item_preview.copy_overlays(gripped_item)
		. += item_preview
	else
		alpha = initial(alpha)

//TODO: Matter decompiler.
/obj/item/matter_decompiler

	name = "matter decompiler"
	desc = "Поедание мусора, осколков стекла или другого мусора пополнит ваши запасы."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"

	//Metal, glass, wood, plastic.
	var/list/stored_comms = list(
		"metal" = 0,
		"glass" = 0,
		"wood" = 0
		)

/obj/item/matter_decompiler/get_ru_names()
	return list(
		NOMINATIVE = "декомпилятор материи",
		GENITIVE = "декомпилятора материи",
		DATIVE = "декомпилятору материи",
		ACCUSATIVE = "декомпилятор материи",
		INSTRUMENTAL = "декомпилятором материи",
		PREPOSITIONAL = "декомпиляторе материи"
	)

/obj/item/matter_decompiler/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/matter_decompiler/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity) return //Not adjacent.

	//We only want to deal with using this on turfs. Specific items aren't important.
	var/turf/T = get_turf(target)
	if(!istype(T))
		return

	//Used to give the right message.
	var/grabbed_something = FALSE

	for(var/atom/movable/A in T)
		if(A.decompile_act(src, user)) // Each decompileable mob or obj needs to have this defined
			grabbed_something = TRUE

	if(grabbed_something)
		to_chat(user, span_notice("Вы разворачиваете декомпилятор и забираете предметы с [T.declent_ru(GENITIVE)]."))
	else
		to_chat(user, span_warning("На [T.declent_ru(PREPOSITIONAL)] ничего полезного для вас нет."))
	return

//PRETTIER TOOL LIST.
/mob/living/silicon/robot/drone/installed_modules()

	if(weapon_lock)
		to_chat(src, span_warning("Активна блокировка оружия, невозможно использовать модули! Счётчик: [weaponlock_time]"))
		return

	if(!module)
		module = new /obj/item/robot_module/drone(src)

	var/dat = {"<meta charset="UTF-8"><head><title>Модули дрона</title><meta HTTP-EQUIV='Refresh' CONTENT='10'></head><body>\n"}
	dat += {"<a href='byond://?src=[UID()];mach_close=robotmod'>Закрыть</a>
	<br>
	<br>
	<b>Активированные модули</b>
	<br>
	Модуль 1: [module_state_1 ? "<a href=?src=[UID()];mod=\ref[module_state_1]>[module_state_1]<a>" : "Нет модуля"]<br>
	Модуль 2: [module_state_2 ? "<a href=?src=[UID()];mod=\ref[module_state_2]>[module_state_2]<a>" : "Нет модуля"]<br>
	Модуль 3: [module_state_3 ? "<a href=?src=[UID()];mod=\ref[module_state_3]>[module_state_3]<a>" : "Нет модуля"]<br>
	<br>
	<b>Установленные модули</b><br><br>"}


	var/tools = "<b>Инструменты и устройства</b><br>"
	var/resources = "<br><b>Рекурсы</b><br>"

	for(var/O in module.modules)

		var/module_string = ""

		if(!O)
			module_string += text("<b>Ресурсы исчерпаны</b><br>")
		else if(activated(O))
			module_string += text("[O]: <b>Активирован</b><br>")
		else
			module_string += text("[O]: <a href=?src=[UID()];act=\ref[O]>Активировать</a><br>")

		if(isitem(O) && !(istype(O,/obj/item/stack/cable_coil)))
			tools += module_string
		else
			resources += module_string

	dat += tools

	if(emagged)
		if(!module.emag)
			dat += text("<b>Ресурсы исчерпаны</b><br>")
		else if(activated(module.emag))
			dat += text("[module.emag]: <b>Активирован</b><br>")
		else
			dat += text("[module.emag]: <a href=?src=[UID()];act=\ref[module.emag]>Активировать</a><br>")

	dat += resources

	var/datum/browser/popup = new(src, "robotmod", "Drone modules")
	popup.set_content(dat)
	popup.set_window_options("can_close=0;")
	popup.open(FALSE)

//Putting the decompiler here to avoid doing list checks every tick.
/mob/living/silicon/robot/drone/use_power()

	..()
	if(low_power_mode || !decompiler)
		return

	//The decompiler replenishes drone stores from hoovered-up junk each tick.
	for(var/type in decompiler.stored_comms)
		if(decompiler.stored_comms[type] > 0)
			var/obj/item/stack/sheet/stack
			switch(type)
				if("metal")
					if(!stack_metal)
						stack_metal = new /obj/item/stack/sheet/metal/cyborg(src.module)
					stack = stack_metal
				if("glass")
					if(!stack_glass)
						stack_glass = new /obj/item/stack/sheet/glass/cyborg(src.module)
					stack = stack_glass
				if("wood")
					if(!stack_wood)
						stack_wood = new /obj/item/stack/sheet/wood/cyborg(src.module)
					stack = stack_wood
				if("plastic")
					if(!stack_plastic)
						stack_plastic = new /obj/item/stack/sheet/plastic(src.module)
					stack = stack_plastic

			stack.add(1)
			decompiler.stored_comms[type]--
