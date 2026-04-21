#define PLAGUE_INC_USES_TO_USE 3

GLOBAL_LIST_EMPTY_TYPED(death_outfits, /datum/outfit/radial_outfit/death_book)

/obj/item/death_book
	name = "Летопись вашей погибели"
	desc = "Странная книга с мерцающими страницами. Кажется, её корешок выполнен из человеческой кожи..."
	icon = 'icons/obj/death_book.dmi'
	icon_state = "close_death_book"
	lefthand_file = 'icons/mob/inhands/death_book_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/death_book_rigthhand.dmi'

	var/cooldown = FALSE
	var/datum/dynamic_outfit/temp_outfit_storage = null

	var/alist/latest_outfits = alist(/datum/outfit/radial_outfit/death_book/plague_inc = PLAGUE_INC_USES_TO_USE)
	var/atom/objects_to_delete = null

/obj/item/death_book/get_ru_names()
	return list(
		NOMINATIVE = "летопись вашей погибели",
		GENITIVE = "летописи вашей погибели",
		DATIVE = "летописе вашей погибели",
		ACCUSATIVE = "летопись вашей погибели",
		INSTRUMENTAL = "летописью вашей погибели",
		PREPOSITIONAL = "летописе вашей погибели",
	)

/obj/item/death_book/Initialize(mapload)
	temp_outfit_storage = new()
	. = ..()

/obj/item/death_book/Destroy(force)
	delete_registered_atoms()
	qdel(temp_outfit_storage)
	. = ..()

/obj/item/death_book/attack_self(mob/user)
	. = ..()
	if(cooldown)
		to_chat(user, span_warning("Вы еще не готовы прочитать книгу!"))
		return
	if(!iscarbon(user))
		return

	var/datum/outfit/radial_outfit/death_book/choise = radial_menu(user)
	if(!choise)
		return

	flick("animate_death_book", src)
	to_chat(user, span_notice(choise.message_to_chat))

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
	addtimer(CALLBACK(src, PROC_REF(delete_registered_atoms), user), choise.time_action)

/obj/item/death_book/proc/equip_choise_outfit(datum/outfit/radial_outfit/death_book/equip_choise, mob/user)
	temp_outfit_storage = new()
	temp_outfit_storage.temp_unequip(user, selective_mode = (equip_choise.force_unequip_slots | equip_choise.used_slots | user.is_in_hands_to_flag(src)))
	register_objects_to_del(equip_choise.equip(user))

/obj/item/death_book/proc/radial_menu(mob/living/carbon/user)
	var/list/radial_look = list()
	var/list/desc_to_outfit = list()
	for(var/datum/outfit/radial_outfit/death_book/temp_obj in GLOB.death_outfits)
		if(!temp_obj.can_choise(user))
			continue
		desc_to_outfit[temp_obj.descr] = temp_obj
		radial_look[temp_obj.descr] = temp_obj.get_image()

	return desc_to_outfit?[show_radial_menu(user, src, radial_look, require_near = TRUE)]

/obj/item/death_book/proc/alert_user(mob/user)
	user.balloon_alert(user, "экипировка медленно исчезает")

/obj/item/death_book/proc/time_to_delete(mob/user)
	delete_registered_atoms()
	temp_outfit_storage.equip(user)

/obj/item/death_book/proc/cooldown_stop(mob/user)
	//Не стоит оповещать о завершении перезарядки юзеру потерявшему книгу
	if(user && (get_dist(user, src) <= 2))
		user.balloon_alert(user, "книга что-то шепчет")

	cooldown = FALSE

/obj/item/death_book/proc/register_objects_to_del(var/list/atom/atoms_list = null)
	if(!atoms_list || !length(atoms_list))
		stack_trace("Нехороший, передавай список")
		return

	for(var/atom/atom_to_register as anything in atoms_list)
		if(QDELETED(atom_to_register)) //На всякий чтобы лишнее не проскользило
			continue

		LAZYADD(atoms_list, atom_to_register.contents)
		RegisterSignal(atom_to_register, COMSIG_QDELETING, PROC_REF(early_delete))

	objects_to_delete = atoms_list

/obj/item/death_book/proc/early_delete(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(objects_to_delete, source)
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/item/death_book/proc/delete_registered_atoms()

	if(!objects_to_delete || !length(objects_to_delete))
		return

	for(var/atom/atom_to_del as anything in objects_to_delete)
		if(QDELETED(atom_to_del))
			continue

		if(ishuman(atom_to_del.loc))
			var/mob/living/carbon/human/temp_human_var = atom_to_del.loc
			temp_human_var.temporarily_remove_item_from_inventory(atom_to_del, TRUE, FALSE, TRUE)

		atom_to_del.force_drop_all_contents()
		UnregisterSignal(atom_to_del, COMSIG_QDELETING)
		qdel(atom_to_del)

	LAZYNULL(objects_to_delete)
