#define LOCKBOX_DRILL_SPARK_CHANCE 15
#define LOCKBOX_DRILL_TIME 150 SECONDS
#define DRILLING_PERCENT_TO_ALERT 30

/obj/item/storage/lockbox
	name = "lockbox"
	desc = "Кейс с замком."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "lockbox+l"
	righthand_file = 'icons/mob/inhands/storage_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/storage_lefthand.dmi'
	item_state = "lockbox"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 4
	req_access = list(ACCESS_ARMORY)
	var/locked = TRUE
	var/broken = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"
	/// The currently placed thermal drill, if any.
	var/obj/item/thermal_drill/drill = null
	/// The [/proc/addtimer] handle for the current thermal drill.
	var/drill_timer
	/// Drill duration of the current thermal drill.
	var/time_to_drill
	/// The world.time at which drilling started.
	var/drill_start_time
	/// The drill overlay image to display during the drilling process.
	var/image/drill_overlay
	/// The progress bar image to display during the drilling process.
	var/image/progress_bar
	var/drill_x_offset = -2
	var/drill_y_offset = 21
	var/progress_bar_y_offset = 26
	var/security_alert_chance
	var/tried_alert = FALSE
	var/lockbox_title_ru = ""
	var/allow_drilling = TRUE

/obj/item/storage/lockbox/get_ru_names()
	return alist(
		NOMINATIVE = "защищенный кейс [lockbox_title_ru]",
		GENITIVE = "защищенного кейса [lockbox_title_ru]",
		DATIVE = "защищенному кейсу [lockbox_title_ru]",
		ACCUSATIVE = "защищенный кейс [lockbox_title_ru]",
		INSTRUMENTAL = "защищенным кейсом [lockbox_title_ru]",
		PREPOSITIONAL = "защищенном кейсе [lockbox_title_ru]",
	)

/obj/item/storage/lockbox/update_icon_state()
	if(broken)
		icon_state = icon_broken
		return
	icon_state = locked ? icon_locked : icon_closed

/obj/item/storage/lockbox/update_overlays()
	. = ..()
	if(istype(drill, /obj/item/thermal_drill))
		var/drill_icon = istype(drill, /obj/item/thermal_drill/diamond_drill) ? "d" : "h"
		var/state = "floorsafe_[drill_icon]-drill-[drill_timer ? "on" : "off"]"
		drill_overlay = image(icon = 'icons/effects/drill.dmi', icon_state = state)
		var/matrix/matrix = matrix()
		matrix.Translate(drill_x_offset, drill_y_offset)
		matrix.Turn(180)
		drill_overlay.transform = matrix
		. += drill_overlay

/obj/item/storage/lockbox/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// to allow storing special items
		if(locked)
			add_fingerprint(user)
			to_chat(user, span_warning("Закрыто!"))
			return ATTACK_CHAIN_PROCEED
		return ..()

	if(item.GetID())
		add_fingerprint(user)
		if(broken)
			to_chat(user, span_warning("Похоже, оно сломано."))
			return ATTACK_CHAIN_PROCEED
		if(drill && drill_timer)
			to_chat(user, span_warning("Невозможно во время работы дрели."))
			return ATTACK_CHAIN_PROCEED
		if(!check_access(item))
			to_chat(user, span_warning("Доступ запрещен."))
			return ATTACK_CHAIN_PROCEED

		locked = !locked
		update_icon()
		if(locked)
			to_chat(user, span_warning("Вы закрыли [declent_ru(ACCUSATIVE)]!"))
			if(user.s_active == src)
				user.s_active.close(user)
		else
			to_chat(user, span_warning("Вы открыли [declent_ru(ACCUSATIVE)]!"))
			origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if((istype(item, /obj/item/card/emag) || (istype(item, /obj/item/melee/energy/blade)) && !broken))
		add_fingerprint(user)
		emag_act(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/thermal_drill) && allow_drilling && !broken && locked)
		if(drill)
			user.balloon_alert(user, "дрель уже стоит!")
			return ATTACK_CHAIN_PROCEED
		user.balloon_alert(user, "установка началась")
		if(!do_after(user, 2 SECONDS, src, category = DA_CAT_TOOL) || drill)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ATTACK_CHAIN_PROCEED
		drill = item
		time_to_drill = LOCKBOX_DRILL_TIME * drill.time_multiplier
		security_alert_chance = drill.security_alert_chance
		tried_alert = FALSE
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(locked)
		add_fingerprint(user)
		to_chat(user, span_warning("Закрыто!"))
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/storage/lockbox/Destroy()
	if(drill)
		drill.soundloop.stop()
		drill.forceMove(loc)
		drill = null
		drill_timer = null
		tried_alert = null
		security_alert_chance = null
	QDEL_NULL(progress_bar)
	QDEL_NULL(drill_overlay)
	return ..()

/obj/item/storage/lockbox/process()
	if(!drill)
		drill_timer = null
		drill.soundloop.stop()
		cut_overlay(progress_bar)
		update_icon()
		STOP_PROCESSING(SSobj, src)
	if(!drill_timer)
		return
	cut_overlay(progress_bar)
	progress_bar = image('icons/effects/progressbar.dmi', src, "prog_bar_[round((((world.time - drill_start_time) / time_to_drill) * 100), 5)]", HUD_LAYER)
	var/matrix/matrix = matrix()
	matrix.Translate(0, progress_bar_y_offset)
	progress_bar.transform = matrix
	add_overlay(progress_bar)
	if(prob(LOCKBOX_DRILL_SPARK_CHANCE))
		drill.spark_system.start()
	if(!tried_alert && ((world.time - drill_start_time) / time_to_drill) * 100 >= DRILLING_PERCENT_TO_ALERT)
		try_alert_security()

/obj/item/storage/lockbox/attack_self(mob/user) 
	if(drill && !broken)
		switch(tgui_alert(user, "Что вы собираетесь сделать?", "Дрель с усиленным сверлом", list("[drill_timer ? "Выключить" : "Включить"]", "Убрать дрель", "Отмена")))
			if("Включить")
				if(!locked)
					user.balloon_alert(user, "уже открыто.")
					return
				if(do_after(user, 2 SECONDS, src))
					if(!drill || !locked || !drill_timer)
						return
					drill_timer = addtimer(CALLBACK(src, PROC_REF(drill_open)), time_to_drill, TIMER_STOPPABLE)
					drill_start_time = world.time
					drill.soundloop.start()
					update_icon()
					START_PROCESSING(SSobj, src)
			if("Выключить")
				if(do_after(user, 10 SECONDS, src)) //Can't be too easy to turn off
					if(!drill || !locked || !drill_timer)
						return
					deltimer(drill_timer)
					drill_timer = null
					drill.soundloop.stop()
					cut_overlay(progress_bar)
					update_icon()
					STOP_PROCESSING(SSobj, src)
			if("Убрать дрель")
				if(drill_timer)
					user.balloon_alert(user, "дрель работает!")
				else if(do_after(user, 2 SECONDS, src))
					if(drill)
						remove_drill(user)
			if("Отмена")
				return
	else if(drill && broken)
		remove_drill(user)

/obj/item/storage/lockbox/dump_storage(mob/user, obj/item/storage/target)
	if(locked)
		user?.balloon_alert(user, "заперто")
		return
	return ..()

/obj/item/storage/lockbox/show_to(mob/user)
	if(locked)
		to_chat(user, span_warning("Закрыто!"))
	else
		..()
	return

/obj/item/storage/lockbox/can_be_inserted(obj/item/item, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, span_notice("[declent_ru(NOMINATIVE)] заперт!"))
	return FALSE

/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		add_attack_logs(user, src, "emagged")
		broken = TRUE
		locked = FALSE
		desc = "Похоже, оно сломано."
		update_icon()
		if(user)
			to_chat(user, span_notice("Вы открыли [declent_ru(ACCUSATIVE)]."))
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.

/obj/item/storage/lockbox/proc/remove_drill(mob/user)
	user.put_in_hands(drill)
	drill = null
	update_icon()
	
/obj/item/storage/lockbox/proc/drill_open()
	if(!drill)
		return
	broken = TRUE
	locked = FALSE
	drill_timer = null
	drill.soundloop.stop()
	update_icon()
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	cut_overlay(progress_bar)
	update_icon()
	STOP_PROCESSING(SSobj, src)

/obj/item/storage/lockbox/proc/try_alert_security()
	if(security_alert_chance && prob(security_alert_chance))
		var/area/location = get_area(src)
		radio_announce("Попытка незаконного доступа к содержимому кейса в <b>[location]</b>!", declent_ru(NOMINATIVE), SEC_FREQ, src)
		playsound(src, 'sound/machines/burglar_alarm.ogg', 50, FALSE)
	tried_alert = TRUE

/obj/item/storage/lockbox/hear_talk(mob/living/target_mob, list/message_pieces)
	if(locked)
		return

	..()

/obj/item/storage/lockbox/hear_message(mob/living/target_mob, msg)
	return

/obj/item/storage/lockbox/mindshield
	name = "Lockbox (Mindshield Implants)"
	req_access = list(ACCESS_SECURITY)
	lockbox_title_ru = "(Импланты защиты разума)"

/obj/item/storage/lockbox/mindshield/populate_contents()
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/mindshield/ert
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/lockbox/sibyl_system_mod
	name = "lockbox (Sibyl System Mods)"
	desc = "Содержит модицикации системы Сибил для энергетического оружия."
	max_w_class = WEIGHT_CLASS_TINY
	storage_slots = 10
	req_access = list(ACCESS_SECURITY)
	lockbox_title_ru = "(Модификации Системы Сибил)"

/obj/item/storage/lockbox/sibyl_system_mod/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/gun_module/sibyl(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "У тебя плохое предчувствие об открытии этого."
	req_access = list(ACCESS_SECURITY)
	lockbox_title_ru = "(Кластерные Гранаты)"

/obj/item/storage/lockbox/clusterbang/populate_contents()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/suppression
	name = "Lockbox (Suppression Implants)"
	desc = "Содержит био-чипы \"Подавление\" для ограничения навыков боевых искусств."
	req_access = list(ACCESS_SECURITY)
	lockbox_title_ru = "(Импланты Подавления)"

/obj/item/storage/lockbox/suppression/populate_contents()
	new /obj/item/implantcase/suppression(src)
	new /obj/item/implanter/suppression(src)

/obj/item/storage/lockbox/suppression/cargo

/obj/item/storage/lockbox/suppression/cargo/populate_contents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/suppression(src)
	new /obj/item/implanter/suppression(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "Кейс с замком, используемый для хранения почетных медалей."
	icon_state = "medalbox+l"
	item_state = "medalbox"
	w_class = WEIGHT_CLASS_NORMAL
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 20
	storage_slots = 12
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/get_ru_names()
	return alist(
		NOMINATIVE = "кейс для медалей",
		GENITIVE = "кейса для медалей",
		DATIVE = "кейсу для медалей",
		ACCUSATIVE = "кейс для медалей",
		INSTRUMENTAL = "кейсом для медалей",
		PREPOSITIONAL = "кейсе для медалей",
	)

/obj/item/storage/lockbox/medal/populate_contents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/leadership(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/heart(src)

/obj/item/storage/lockbox/t4
	name = "lockbox (T4)"
	desc = "Содержит три пробивных заряда Т4."
	req_access = list(ACCESS_CENT_SPECOPS)
	w_class = WEIGHT_CLASS_NORMAL
	lockbox_title_ru = "(Т4)"

/obj/item/storage/lockbox/t4/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/lockbox/research

/obj/item/storage/lockbox/research/deconstruct(disassembled = TRUE) // Get wrecked, Science nerds
	qdel(src)

/obj/item/storage/lockbox/research/large
	name = "Large lockbox"
	desc = "Большой кейс с замком"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 1

/obj/item/storage/lockbox/research/large/get_ru_names()
	return alist(
		NOMINATIVE = "большой защищенный кейс",
		GENITIVE = "большого защищенного кейса",
		DATIVE = "большому защищенному кейсу",
		ACCUSATIVE = "большой защищенный кейс",
		INSTRUMENTAL = "большим защищенным кейсом",
		PREPOSITIONAL = "большом защищенном кейсе",
	)

/obj/item/storage/lockbox/research/modsuit
	name = "Plating lockbox"
	desc = "Большой защищенный кейс. Электронный замок выглядит довольно уязвимым."
	lockbox_title_ru = "(Внешняя обшивка МЭК)"

/obj/item/storage/lockbox/research/modsuit/emp_act(severity) //I want emp to get around it, it's not a gun, I just want people not to always make sec / med modsuits.
	. = ..()
	if(!broken || !prob(50 / severity))
		return

	locked = FALSE
	broken = TRUE
	update_icon(UPDATE_ICON_STATE)
	origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.

/obj/item/storage/lockbox/research/mantis
	name = "lockbox(hidden blade implant)"
	req_access = list(ACCESS_ARMORY)
	lockbox_title_ru = "(Имплант Скрытого Лезвия)"

/obj/item/storage/lockbox/research/mantis/populate_contents()
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard(src)
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard/l(src)

/obj/item/storage/lockbox/medal/hardmode_box
	name = "HRD-MDE program medal box"
	desc = "Кейс с замком, используемый для хранения медалей гордости. Используйте диск исследования фауны на кейс, чтобы передать данные и напечатать медаль."
	req_access = list(ACCESS_MINING) //No grubby assistant hands on my hard earned medals
	can_hold = list(/obj/item/clothing/accessory, /obj/item/coin) //Whoops almost gave miners boxes that could store 12 legion cores. Scoped to accessory if they want to store neclaces or hope or something in there. Or a coin collection.
	var/list/completed_fauna = list()
	var/number_of_megafauna = 7 //Increase this if new megafauna are added.

/obj/item/storage/lockbox/medal/hardmode_box/get_ru_names()
	return alist(
		NOMINATIVE = "кейс для медалей HRD-MDE",
		GENITIVE = "кейса для медалей HRD-MDE",
		DATIVE = "кейсу для медалей HRD-MDE",
		ACCUSATIVE = "кейс для медалей HRD-MDE",
		INSTRUMENTAL = "кейсом для медалей HRD-MDE",
		PREPOSITIONAL = "кейсе для медалей HRD-MDE",
	)

/obj/item/storage/lockbox/medal/hardmode_box/Initialize(mapload)
	. = ..()
	number_of_megafauna = length(subtypesof(/obj/item/disk/fauna_research))

/obj/item/storage/lockbox/medal/hardmode_box/populate_contents()
	return

/obj/item/storage/lockbox/medal/hardmode_box/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/disk/fauna_research))
		var/obj/item/disk/fauna_research/disky = item
		if(!user.drop_transfer_item_to_loc(disky, src))
			return ..()
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		var/obj/item/pride = new disky.output(drop_loc)
		to_chat(user, span_notice("[declent_ru(NOMINATIVE)] принимает [disky.declent_ru(ACCUSATIVE)], и печатает [pride.declent_ru(ACCUSATIVE)]."))
		qdel(disky)
		if(!is_type_in_list(pride, completed_fauna))
			completed_fauna += pride.type
			if(length(completed_fauna) == number_of_megafauna)
				to_chat(user, span_notice("[declent_ru(NOMINATIVE)] печатает очень красивую медаль."))
				var/obj/item/clothing/accessory/medal/gold/heroism/hardmode_full/accomplishment = new(drop_loc)
				user.put_in_hands(accomplishment, ignore_anim = FALSE)
		user.put_in_hands(pride, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

