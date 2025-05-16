/obj/item/death_book
	name = "Летопись вашей погибели"
	desc = "Странная книга с мерцающими страницами. Кажется, её корешок выполнен из человеческой кожи..."
	icon = 'icons/obj/death_book.dmi'
	icon_state = "close_death_book"
	lefthand_file = 'icons/mob/inhands/death_book_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/death_book_rigthhand.dmi'
	
	var/list/outfits = list(
		/datum/outfit/radial_outfit/death_book/executioner,
		/datum/outfit/radial_outfit/death_book/bandit,
		/datum/outfit/radial_outfit/death_book/killer,
		/datum/outfit/radial_outfit/death_book/crusher,
		/datum/outfit/radial_outfit/death_book/plague_inc
	)
	var/cooldown = FALSE
	var/datum/dynamic_outfit/temp_outfit_storage = null

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
	to_chat(user, span_info(choise.message_to_chat))
	//Even death will not stop the progress of the bar
	if(do_after(user, 1 SECONDS, src, INFINITY & !(DA_IGNORE_HELD_ITEM)))
		cooldown = TRUE
		addtimer(CALLBACK(src, PROC_REF(cooldown_stop), user), choise.cooldown)
		addtimer(CALLBACK(src, PROC_REF(alert_user), user), choise.time_action - 30 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(phantom_delete), user), choise.time_action)
		temp_outfit_storage = new()	
		temp_outfit_storage.temp_unequip(user, selective_mode = (choise.force_unequip_slots | choise.used_slots | user.is_in_hands_to_flag(src)))
		choise.equip(user, prom_component = /datum/component/phantom_component, comp_args = list(src, TRUE))
	else
		flick("close_death_book", src)
		to_chat(user, span_info("Вам не хватает терпения и вы перестаете читать!"))
	qdel(choise)
		
/obj/item/death_book/proc/radial_menu(mob/living/carbon/user)
	var/list/radial_look = list()
	var/list/desc_to_outfit = list()
	for(var/prom_outfit in outfits)
		var/datum/outfit/radial_outfit/death_book/prom_obj = new prom_outfit()
		if(prom_obj.can_choise(user))
			desc_to_outfit[prom_obj.descr] = prom_obj
			radial_look[prom_obj.descr] = prom_obj.get_image()

	return desc_to_outfit?[show_radial_menu(user, src, radial_look, require_near = TRUE)]

/obj/item/death_book/proc/alert_user(mob/user)
	user.balloon_alert(user, "Ваша экипировка теряет очертания медленно растворяясь в воздухе")

/obj/item/death_book/proc/phantom_delete(mob/user)
	SEND_SIGNAL(src, COMSIG_PHANTOM_DELETE)
	temp_outfit_storage.equip(user)

/obj/item/death_book/proc/cooldown_stop(mob/user)
	user.balloon_alert(user, "Вас наполняет решимость. Вы готовы прочесть книгу вновь.")
	cooldown = FALSE
