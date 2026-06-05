#define DRILL_SPARK_CHANCE 15
#define DRILL_TIME 150 SECONDS
#define DRILLING_PERCENT_TO_ALERT 30

/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
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
	var/mutable_apperance/drill_overlay
	/// The progress bar image to display during the drilling process.
	var/image/progress_bar
	var/drill_x_offset = 0
	var/drill_y_offset = 18
	var/security_alert_chance
	var/tried_alert = FALSE
	alert_channel = SEC_FREQ_NAME

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
		drill_overlay = mutable_apperance(icon = 'icons/effects/drill.dmi', icon_state = state)
		var/matrix/matrix = matrix()
		matrix.Translate(drill_x_offset, drill_y_offset)
		matrix.Turn(180)
		drill_overlay.transform = matrix
		. += drill_overlay

/obj/item/storage/lockbox/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// to allow storing special items
		if(locked)
			add_fingerprint(user)
			to_chat(user, span_warning("It's locked!"))
			return ATTACK_CHAIN_PROCEED
		return ..()

	if(item.GetID())
		add_fingerprint(user)
		if(broken)
			to_chat(user, span_warning("It appears to be broken."))
			return ATTACK_CHAIN_PROCEED
		if(drill && drill_timer)
			to_chat(user, span_warning("Невозможно во время работы дрели."))
			return ATTACK_CHAIN_PROCEED
		if(!check_access(item))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED

		locked = !locked
		update_icon()
		if(locked)
			to_chat(user, span_warning("You lock [src]!"))
			if(user.s_active == src)
				user.s_active.close(user)
		else
			to_chat(user, span_warning("You unlock [src]!"))
			origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if((istype(item, /obj/item/card/emag) || (istype(item, /obj/item/melee/energy/blade)) && !broken))
		add_fingerprint(user)
		emag_act(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(item, /obj/item/thermal_drill) && !broken && locked)
		if(drill)
			user.balloon_alert(user, "дрель уже стоит!")
			return ATTACK_CHAIN_PROCEED
		user.balloon_alert(user, "установка началась")
		if(!do_after(user, 2 SECONDS, src, category = DA_CAT_TOOL) || drill)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ATTACK_CHAIN_PROCEED
		drill = item
		time_to_drill = DRILL_TIME * drill.time_multiplier
		security_alert_chance = drill.security_alert_chance
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(locked)
		add_fingerprint(user)
		to_chat(user, span_warning("It's locked!"))
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/storage/lockbox/Destroy()
	if(drill)
		drill.soundloop.stop()
		drill.forceMove(loc)
		drill = null
		tried_alert = null
		security_alert_chance = null
	QDEL_NULL(progress_bar)
	QDEL_NULL(drill_overlay)
	clear_payback()
	return ..()

/obj/item/storage/lockbox/process()
	if(!drill_timer)
		return
	cut_overlay(progress_bar)
	progress_bar = image('icons/effects/progressbar.dmi', src, "prog_bar_[round((((world.time - drill_start_time) / time_to_drill) * 100), 5)]", HUD_LAYER)
	add_overlay(progress_bar)
	if(prob(DRILL_SPARK_CHANCE))
		drill.spark_system.start()
	if(!tried_alert && (world.time - drill_start_time) / time_to_drill) * 100 >= DRILLING_PERCENT_TO_ALERT)
		try_alert_security()

/obj/item/storage/lockbox/attack_self(mob/user) 
	if(drill && !broken)
		switch(tgui_alert(user, "Что вы собираетесь сделать?", "Дрель с усиленным сверлом", list("[drill_timer ? "Выключить" : "Включить"]", "Убрать дрель", "Отмена")))
			if("Включить")
				if(do_after(user, 2 SECONDS, src))
					drill_timer = addtimer(CALLBACK(src, PROC_REF(drill_open)), time_to_drill, TIMER_STOPPABLE)
					drill_start_time = world.time
					drill.soundloop.start()
					update_icon()
					START_PROCESSING(SSobj, src)
			if("Выключить")
				if(do_after(user, 10 SECONDS, src)) //Can't be too easy to turn off
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
		to_chat(user, span_warning("It's locked!"))
	else
		..()
	return

/obj/item/storage/lockbox/can_be_inserted(obj/item/W, stop_messages = 0)
	if(!locked)
		return ..()
	if(!stop_messages)
		to_chat(usr, span_notice("[src] is locked!"))
	return FALSE

/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		add_attack_logs(user, src, "emagged")
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		update_icon()
		if(user)
			to_chat(user, span_notice("You unlock \the [src]."))
		origin_tech = null //wipe out any origin tech if it's unlocked in any way so you can't double-dip tech levels at R&D.

/obj/item/storage/lockbox/proc/remove_drill(mob/user)
	user.put_in_hands(drill)
	drill = null
	update_icon()
	
/obj/item/storage/lockbox/proc/drill_open()
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
		speak("Попытка незаконного доступа к содержимому кейса в локации <b>[location]</b>.", alert_channel)
		playsound(src, 'sound/machines/burglar_alarm.ogg', 50, FALSE)
		tried_alert = TRUE

/obj/item/storage/lockbox/hear_talk(mob/living/M, list/message_pieces)
	if(locked)
		return

	..()

/obj/item/storage/lockbox/hear_message(mob/living/M, msg)
	return

/obj/item/storage/lockbox/mindshield
	name = "Lockbox (Mindshield Implants)"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/mindshield/populate_contents()
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/mindshield/ert
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/lockbox/sibyl_system_mod
	name = "lockbox (Sibyl System Mods)"
	desc = "Contains proprietary Sibyl System mods for energy guns."
	max_w_class = WEIGHT_CLASS_TINY
	storage_slots = 10
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/sibyl_system_mod/populate_contents()
	for(var/i in 1 to 10)
		new /obj/item/gun_module/sibyl(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/populate_contents()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/suppression
	name = "Lockbox (Suppression Implants)"
	desc = "Содержит био-чипы \"Подавление\" для ограничения навыков боевых искусств."
	req_access = list(ACCESS_SECURITY)

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
	desc = "A locked box used to store medals of honor."
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

/obj/item/storage/lockbox/medal/populate_contents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/leadership(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/heart(src)

/obj/item/storage/lockbox/t4
	name = "lockbox (T4)"
	desc = "Contains three T4 breaching charges."
	req_access = list(ACCESS_CENT_SPECOPS)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/lockbox/t4/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/lockbox/research

/obj/item/storage/lockbox/research/deconstruct(disassembled = TRUE) // Get wrecked, Science nerds
	qdel(src)

/obj/item/storage/lockbox/research/large
	name = "Large lockbox"
	desc = "A large lockbox"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 4 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 1

/obj/item/storage/lockbox/research/modsuit
	name = "Plating lockbox"
	desc = "Большой защитный кейс. Электронный замок выглядит довольно уязвимым."

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

/obj/item/storage/lockbox/research/mantis/populate_contents()
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard(src)
	new /obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard/l(src)

/obj/item/storage/lockbox/medal/hardmode_box
	name = "HRD-MDE program medal box"
	desc = "A locked box used to store medals of pride. Use a fauna research disk on the box to transmit the data and print a medal."
	req_access = list(ACCESS_MINING) //No grubby assistant hands on my hard earned medals
	can_hold = list(/obj/item/clothing/accessory, /obj/item/coin) //Whoops almost gave miners boxes that could store 12 legion cores. Scoped to accessory if they want to store neclaces or hope or something in there. Or a coin collection.
	var/list/completed_fauna = list()
	var/number_of_megafauna = 7 //Increase this if new megafauna are added.

/obj/item/storage/lockbox/medal/hardmode_box/Initialize(mapload)
	. = ..()
	number_of_megafauna = length(subtypesof(/obj/item/disk/fauna_research))

/obj/item/storage/lockbox/medal/hardmode_box/populate_contents()
	return

/obj/item/storage/lockbox/medal/hardmode_box/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/disk/fauna_research))
		var/obj/item/disk/fauna_research/disky = I
		if(!user.drop_transfer_item_to_loc(disky, src))
			return ..()
		add_fingerprint(user)
		var/atom/drop_loc = drop_location()
		var/obj/item/pride = new disky.output(drop_loc)
		to_chat(user, span_notice("The [name] accepts [disky], and prints out [pride]."))
		qdel(disky)
		if(!is_type_in_list(pride, completed_fauna))
			completed_fauna += pride.type
			if(length(completed_fauna) == number_of_megafauna)
				to_chat(user, span_notice("The [name] prints out a very fancy medal."))
				var/obj/item/clothing/accessory/medal/gold/heroism/hardmode_full/accomplishment = new(drop_loc)
				user.put_in_hands(accomplishment, ignore_anim = FALSE)
		user.put_in_hands(pride, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

