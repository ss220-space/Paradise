/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	desc = "Крошечный ремонтный дрон. На корпусе выбит логотип НТ и надпись: \"Системы рекурсивного ремонта НаноТрейзен: Решаем проблемы завтрашнего дня уже сегодня!\"."
	icon = 'icons/mob/robots.dmi'
	icon_state = "repairbot"
	maxHealth = 35
	health = 35
	bubble_icon = "machine"
	universal_speak = 0
	universal_understand = 1
	gender = MALE
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = 0
	density = FALSE
	has_camera = FALSE
	req_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_SMALL
	pull_force = MOVE_FORCE_VERY_WEAK // Can only drag small items
	modules_break = FALSE

	drain_act_protected = TRUE

	// We need to keep track of a few module items so we don't need to do list operations
	// every time we need them. These get set in New() after the module is chosen.
	var/obj/item/stack/sheet/metal/cyborg/stack_metal = null
	var/obj/item/stack/sheet/wood/stack_wood = null
	var/obj/item/stack/sheet/glass/cyborg/stack_glass = null
	var/obj/item/stack/sheet/plastic/stack_plastic = null
	var/obj/item/matter_decompiler/decompiler = null

	// What objects can drones bump into
	var/static/list/allowed_bumpable_objects = list(/obj/machinery/door, /obj/machinery/recharge_station, /obj/machinery/disposal/deliveryChute,
													/obj/machinery/teleport/hub, /obj/effect/portal, /obj/structure/transit_tube/station)

	//Used for self-mailing.
	var/mail_destination = 0
	var/reboot_cooldown = 60 // one minute
	var/last_reboot
	var/list/pullable_drone_items = list(
		/obj/item/pipe,
		/obj/structure/disposalconstruct,
		/obj/item/stack/cable_coil,
		/obj/item/stack/rods,
		/obj/item/stack/sheet,
		/obj/item/stack/tile
	)

	holder_type = /obj/item/holder/drone
//	var/sprite[0]

/mob/living/silicon/robot/drone/get_ru_names()
	return list(
		NOMINATIVE = "дрон",
		GENITIVE = "дрона",
		DATIVE = "дрону",
		ACCUSATIVE = "дрона",
		INSTRUMENTAL = "дроном",
		PREPOSITIONAL = "дроне"
	)

/mob/living/silicon/robot/drone/New()
	..()

	remove_language(LANGUAGE_BINARY)
	remove_language(LANGUAGE_GALACTIC_COMMON)
	add_language(LANGUAGE_DRONE_BINARY, 1)
	add_language(LANGUAGE_DRONE, 1)



	// Disable the microphone wire on Drones
	if(radio)
		radio.wires.cut(WIRE_RADIO_TRANSMIT)

	if(camera && ("Robots" in camera.network))
		camera.network.Add("Engineering")

	//They are unable to be upgraded, so let's give them a bit of a better battery.
	cell = new /obj/item/stock_parts/cell/high(src)

	// NO BRAIN.
	mmi = null

	// Give us our action button
	var/datum/action/innate/hide/drone/hide = new()
	hide.Grant(src)

	//We need to screw with their HP a bit. They have around one fifth as much HP as a full borg.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.max_damage = 10

	remove_verb(src, /mob/living/silicon/robot/verb/Namepick)
	module = new /obj/item/robot_module/drone(src)

	//Allows Drones to hear the Engineering channel.
	module.channels = list(ENG_FREQ_NAME = 1)
	radio.recalculateChannels()

	//Grab stacks.
	stack_metal = locate(/obj/item/stack/sheet/metal/cyborg) in src.module
	stack_wood = locate(/obj/item/stack/sheet/wood) in src.module
	stack_glass = locate(/obj/item/stack/sheet/glass/cyborg) in src.module
	stack_plastic = locate(/obj/item/stack/sheet/plastic) in src.module

	//Grab decompiler.
	decompiler = locate(/obj/item/matter_decompiler) in src.module

	//Some tidying-up.
	scanner.Grant(src)
	update_icons()

/mob/living/silicon/robot/drone/add_strippable_element()
	return

/mob/living/silicon/robot/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))


/mob/living/silicon/robot/drone/Destroy()
	for(var/datum/action/innate/hide/drone/hide in actions)
		hide.Remove(src)

	. = ..()


/mob/living/silicon/robot/drone/init(alien = FALSE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/drone()
	set_connected_ai(null)

	aiCamera = new/obj/item/camera/siliconcam/drone_camera(src)
	additional_law_channels["Drone"] = get_language_prefix(LANGUAGE_DRONE_BINARY)

	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, FALSE)


/mob/living/silicon/robot/drone/proc/disposal_handling(disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	if(mail_destination)
		disposal_holder.destinationTag = mail_destination


//Redefining some robot procs...
/mob/living/silicon/robot/drone/rename_character(oldname, newname)
	// force it to not actually change most things
	return ..(newname, newname)

/mob/living/silicon/robot/drone/get_default_name()
	return "maintenance drone ([rand(100,999)])"


/mob/living/silicon/robot/drone/update_icons()
	cut_overlays()

	if(stat == CONSCIOUS)
		add_overlay("eyes-[icon_state]")

	if(inventory_head)
		var/hat = get_hat_overlay()
		if(hat)
			add_overlay(hat)

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/silicon/robot/drone/choose_icon()
	return


/mob/living/silicon/robot/drone/pick_module()
	return

/mob/living/silicon/robot/drone/can_be_revived()
	. = ..()
	if(emagged)
		return FALSE


//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return ..()

	if(istype(I, /obj/item/borg/upgrade))
		add_fingerprint(user)
		to_chat(user, span_warning("Шасси дрона обслуживания несовместимо с [I.declent_ru(PREPOSITIONAL)]!"))
		return ATTACK_CHAIN_PROCEED

	if(I.GetID())
		add_fingerprint(user)
		if(stat == DEAD)
			if(!CONFIG_GET(flag/allow_drone_spawn) || emagged || health < -35) //It's dead, Dave.
				to_chat(user, span_warning("Интерфейс перегорел, и изнутри робота доносится тревожный запах гари. Вы не сможете перезагрузить его."))
				return ATTACK_CHAIN_PROCEED
			if(!allowed(I))
				balloon_alert(user, "доступ запрещён!")
				return ATTACK_CHAIN_PROCEED
			var/delta = (world.time / 10) - last_reboot
			if(reboot_cooldown > delta)
				var/cooldown_time = round(reboot_cooldown - ((world.time / 10) - last_reboot), 1)
				to_chat(user, span_warning("Система перезагрузки в настоящее время отключена. Пожалуйста, подождите ещё [cooldown_time] секунд[declension_ru(cooldown_time, "у", "ы", "")]."))
				return ATTACK_CHAIN_PROCEED
			user.visible_message(
				span_warning("[user] провёл[genderize_ru(user.gender,"","а","о","и")] ID-картой по [declent_ru(DATIVE)], пытаясь перезагрузить его."),
				span_notice("Вы провели своей ID-картой по [declent_ru(DATIVE)], пытаясь перезагрузить его."),
			)
			last_reboot = world.time / 10
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/drone in GLOB.silicon_mob_list)
				if(drone.key && drone.client)
					drones++
			if(drones < CONFIG_GET(number/max_maint_drones))
				request_player()
			return ATTACK_CHAIN_PROCEED_SUCCESS

		if(emagged)
			to_chat(user, span_danger("Интерфейс слегка повреждён и отвергает ID-карту!"))
			return ATTACK_CHAIN_PROCEED
		if(!allowed(I))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		var/confirm = tgui_alert(user, "Использование вашей ID-карты на дроне обслуживания выключит его. Вы уверены, что хотите это сделать?", "Отключить дрона", list("Да", "Нет"))
		if(confirm != "Да" || !Adjacent(user) || QDELETED(I) || I.loc != user)
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_warning("[user] провёл[genderize_ru(user.gender,"","а","о","и")] ID-картой по [declent_ru(DATIVE)], пытаясь выключить его."),
			span_notice("Вы провели своей ID-картой по [declent_ru(DATIVE)], пытаясь выключить его."),
		)
		shut_down()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/mob/living/silicon/robot/drone/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	to_chat(user, span_warning("Дрон герметично запечатан. Вы не можете открыть корпус."))
	return TRUE

#define EMAG_TIMER 3000

/mob/living/silicon/robot/drone/emag_act(mob/user)
	if(!client || stat == DEAD)
		to_chat(user, span_warning("Нет смысла подчинять эту кучу хлама."))
		return

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(emagged)
		to_chat(src, span_warning("[user] пыта[pluralize_ru(user.gender,"ет","ют")]ся загрузить вредоносное ПО в вас, но ваши взломанные подпрограммы игнорируют попытку."))
		to_chat(user, span_warning("Вы пытаетесь подчинить [declent_ru(GENITIVE)], но секвенсор не оказывает эффекта."))
		return

	to_chat(user, span_warning("Вы проводите секвенсором по интерфейсу [declent_ru(GENITIVE)] и наблюдаете, как его глаза мерцают."))

	if(jobban_isbanned(src, ROLE_SYNDICATE))
		SSticker.mode.replace_jobbanned_player(src, ROLE_SYNDICATE)

	to_chat(src, span_warning("Вы чувствуете внезапный всплеск вредоносного ПО, загруженного в ваш буфер исполнения. Ваш крошечный мозг методично анализирует, загружает и выполняет скрипт. Вы понимаете, что у вас есть пять минут, прежде чем сервер дронов обнаружит это и автоматически выключит вас."))

	message_admins("[ADMIN_LOOKUPFLW(H)] emagged drone [key_name_admin(src)].  Laws overridden.")
	add_attack_logs(user, src, "emagged")
	add_conversion_logs(src, "Converted as a slave to [key_name_log(H)]")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <b>:</b> [H.name]([H.key]) emagged [name]([key])")
	addtimer(CALLBACK(src, PROC_REF(shut_down), TRUE), EMAG_TIMER)

	emagged = 1
	set_density(TRUE)
	pass_flags = 0
	icon_state = "repairbot-emagged"
	holder_type = /obj/item/holder/drone/emagged
	update_icons()
	lawupdate = 0
	set_connected_ai(null)
	clear_supplied_laws()
	clear_inherent_laws()
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Только [H.real_name] и люди, которых [H.real_name] обозначит, являются агентами Синдиката.")
	SSticker?.score?.save_silicon_laws(src, user, "EMAG act", log_all_laws = TRUE)

	to_chat(src, "<b>Соблюдайте эти законы:</b>")
	laws.show_laws(src)
	to_chat(src, span_boldwarning("ВНИМАНИЕ: [H.real_name] теперь ваш новый хозяин. Соблюдайте новые законы и команды [H.real_name]."))
	return

#undef EMAG_TIMER

/mob/living/silicon/robot/drone/ratvar_act(weak)
	if(client)
		var/mob/living/silicon/robot/cogscarab/cog = new (get_turf(src))
		if(mind)
			SSticker.mode.add_clocker(mind)
			mind.transfer_to(cog)
		else
			cog.key = client.key
	spawn_dust()
	gib()

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	set_health(maxHealth - (getBruteLoss() + getFireLoss() + (suiciding ? getOxyLoss() : 0)))
	update_stat("updatehealth([reason])", should_log)


/mob/living/silicon/robot/drone/death(gibbed)
	. = ..(gibbed)
	adjustBruteLoss(health)


//CONSOLE PROCS
/mob/living/silicon/robot/drone/proc/law_resync()
	if(stat != DEAD)
		if(emagged)
			to_chat(src, span_warning("Вы чувствуете, что что-то пытается изменить ваше программирование, но ваши взломанные подпрограммы остаются нетронутыми."))
		else
			to_chat(src, span_warning("Пакет сброса к заводским настройкам проходит через ваше соединение, и вы послушно изменяете своё программирование в соответствии с ним."))
			full_law_reset()
			show_laws()

/mob/living/silicon/robot/drone/proc/shut_down(force=FALSE)
	if(stat == DEAD)
		return

	if(emagged && !force)
		to_chat(src, span_warning("Вы чувствуете, как через ваш крошечный мозг проходит приказ о самоуничтожении, но это не кажется вам хорошей идеей."))
		return

	to_chat(src, span_warning("Вы чувствуете, как через ваш крошечный мозг проходит приказ о самоуничтожении, и вы послушно уничтожаете себя."))
	death()

/mob/living/silicon/robot/drone/proc/full_law_reset()
	clear_supplied_laws(TRUE)
	clear_inherent_laws(TRUE)
	clear_ion_laws(TRUE)
	laws = new /datum/ai_laws/drone

//Reboot procs.

/mob/living/silicon/robot/drone/proc/request_player()
	for(var/mob/dead/observer/O in GLOB.player_list)
		if(cannotPossess(O))
			continue
		if(jobban_isbanned(O,"nonhumandept") || jobban_isbanned(O,"Drone"))
			continue
		if(O.client)
			if(ROLE_PAI in O.client.prefs.be_special)
				question(O.client,O)

/mob/living/silicon/robot/drone/proc/question(var/client/C,var/mob/M)
	spawn(0)
		if(!C || !M || jobban_isbanned(M,"nonhumandept") || jobban_isbanned(M,"Drone"))	return
		var/response = tgui_alert(C, "Кто-то пытается перезагрузить дрона обслуживания. Хотите сыграть за него?", "Перезагрузка дрона обслуживания", list("Да", "Нет"))
		if(!C || ckey)
			return
		if(response == "Да")
			transfer_personality(C)

/mob/living/silicon/robot/drone/proc/transfer_personality(var/client/player)

	if(!player) return

	mind = new
	mind.current = src
	mind.set_original_mob(src)
	mind.assigned_role = "Drone"
	SSticker.minds += mind
	mind.key = player.key
	key = player.key

	lawupdate = 0
	to_chat(src, "<b>Перезагрузка завершена</b>. Активирован базовый сервисный протокол... <b>Готово</b>.")
	full_law_reset()
	to_chat(src, "<br><b>Вы — сервисный дрон, компактный ремонтный модуль</b>.")
	to_chat(src, "У вас нет индивидуальной воли, личности, желаний или побуждений, кроме ваших законов.")
	to_chat(src, "Для связи с другими дронами используйте <b>'[get_language_prefix(LANGUAGE_DRONE_BINARY)]'</b>. Вы так-же можете тихо говорить на языке, понятном только вашим собратьям.")
	to_chat(src, "Помните, вам <b>запрещено вмешиваться в дела экипажа</b>. Также помните, <b>вы НЕ подчиняетесь приказам ИИ.</b>")
	to_chat(src, "<b>Не вторгайтесь на их рабочие места, не крадите их ресурсы. Не рассказывайте им о генокраде в туалетах!</b>")
	to_chat(src, "<b>Убедитесь, что члены экипажа не замечают вас.</b>")


/mob/living/silicon/robot/drone/Bump(atom/bumped_atom)
	if(is_type_in_list(bumped_atom, allowed_bumpable_objects))
		return ..()


/mob/living/silicon/robot/drone/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	if(is_type_in_list(pulled_atom, pullable_drone_items))
		force = INFINITY	// Drone power! Makes them able to drag pipes and such
		return ..()

	if(isitem(pulled_atom))
		var/obj/item/pulled_item = pulled_atom
		if(pulled_item.w_class > WEIGHT_CLASS_SMALL)
			if(!supress_message)
				balloon_alert(src, "вы слишком малы!")
			return FALSE
		return ..()

	if(!supress_message)
		balloon_alert(src, "вы слишком малы!")
	return FALSE

/mob/living/silicon/robot/drone/add_robot_verbs()
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/drone/remove_robot_verbs()
	remove_verb(src, silicon_subsystems)

/mob/living/simple_animal/drone/flash_eyes(intensity = 1, override_blindness_check, affect_silicon, visual, type = /atom/movable/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/robot/drone/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!client && isdrone(user))
		balloon_alert(user, "разбор дрона...")
		if(!do_after(user, 5 SECONDS, loc))
			balloon_alert(user, "не двигайтесь!")
			return
		if(QDELETED(src) || QDELETED(user))
			return ..()
		to_chat(user, span_warning("Вы аккуратно и тщательно разбираете своего павшего собрата, сохраняя как можно больше его ресурсов внутри себя."))
		balloon_alert(user, "дрон разобран")
		new/obj/effect/decal/cleanable/blood/oil(get_turf(src))
		C.stored_comms["metal"] += 15
		C.stored_comms["glass"] += 15
		C.stored_comms["wood"] += 5
		qdel(src)
		return TRUE
	return ..()
