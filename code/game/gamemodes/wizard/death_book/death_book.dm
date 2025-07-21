/obj/item/death_book
	name = "Летопись вашей погибели"
	desc = "Странная книга с мерцающими страницами. Кажется, её корешок выполнен из человеческой кожи..."
	ru_names = list(
		NOMINATIVE = "летопись вашей погибели",
		GENITIVE = "летописи вашей погибели",
		DATIVE = "летописе вашей погибели",
		ACCUSATIVE = "летопись вашей погибели",
		INSTRUMENTAL = "летописью вашей погибели",
		PREPOSITIONAL = "летописе вашей погибели",
	)
	icon = 'icons/obj/death_book.dmi'
	icon_state = "close_death_book"
	lefthand_file = 'icons/mob/inhands/death_book_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/death_book_rigthhand.dmi'

	var/cooldown = FALSE
	var/datum/dynamic_outfit/temp_outfit_storage = null
	var/static/list/cached_outfit = list()

/obj/item/death_book/Initialize(mapload)
	. = ..()

	if(length(cached_outfit)) //О майн год это что какой-то там паттерн???!?
		return
	for(var/prom_outfit in subtypesof(/datum/outfit/radial_outfit/death_book))
		var/datum/outfit/radial_outfit/death_book/prom_obj = new prom_outfit()
		cached_outfit += prom_obj

/obj/item/death_book/Destroy()
	SEND_SIGNAL(src, COMSIG_PHANTOM_DELETE)
	. = ..()

/obj/item/death_book/attack_self(mob/user)
	. = ..()
	if(cooldown)
		to_chat(user, span_warning("Вы еще не готовы прочитать книгу!"))
		return

	if(!iscarbon(user))
		return
	var/datum/outfit/radial_outfit/death_book/choise = radial_menu(user)
	if(isnull(choise))
		return
	flick("animate_death_book", src)
	to_chat(user, span_notice(choise.message_to_chat))
	//Even death will not stop the progress of the bar
	if(!do_after(user, 1 SECONDS, src, INFINITY & !(DA_IGNORE_HELD_ITEM)))
		flick("close_death_book", src)
		to_chat(user, span_notice("Вам не хватает терпения и вы перестаете читать!"))
		return
	cooldown_start(choise, user)
	phantom_timer_start(choise, user)
	equip_choise_outfit(choise, user)

/obj/item/death_book/proc/cooldown_start(datum/outfit/radial_outfit/death_book/choise, mob/user)
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown_stop), user), choise.cooldown)

/obj/item/death_book/proc/phantom_timer_start(datum/outfit/radial_outfit/death_book/choise, mob/user)
	addtimer(CALLBACK(src, PROC_REF(alert_user), user), choise.time_action - 30 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(phantom_delete), user), choise.time_action)

/obj/item/death_book/proc/equip_choise_outfit(datum/outfit/radial_outfit/death_book/equip_choise, mob/user)
	temp_outfit_storage = new()
	temp_outfit_storage.temp_unequip(user, selective_mode = (equip_choise.force_unequip_slots | equip_choise.used_slots | user.is_in_hands_to_flag(src)))
	equip_choise.equip(user, prom_component = /datum/component/phantom_component, comp_args = list(src, TRUE))

/obj/item/death_book/proc/radial_menu(mob/living/carbon/user)
	var/list/radial_look = list()
	var/list/desc_to_outfit = list()
	for(var/datum/outfit/radial_outfit/death_book/prom_obj in cached_outfit)
		if(!prom_obj.can_choise(user))
			continue
		desc_to_outfit[prom_obj.descr] = prom_obj
		radial_look[prom_obj.descr] = prom_obj.get_image()

	return desc_to_outfit?[show_radial_menu(user, src, radial_look, require_near = TRUE)]

/obj/item/death_book/proc/alert_user(mob/user)
	user.balloon_alert(user, "экипировка медленно исчезает")

/obj/item/death_book/proc/phantom_delete(mob/user)
	SEND_SIGNAL(src, COMSIG_PHANTOM_DELETE)
	temp_outfit_storage.equip(user)

/obj/item/death_book/proc/cooldown_stop(mob/user)
	user.balloon_alert(user, "книга что-то шепчет")
	cooldown = FALSE
