//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "Сложенный мешок, предназначенный для хранения и транспортировки трупов."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	item_state = "bodybag"
	w_class = WEIGHT_CLASS_SMALL
	///Stored path we use for spawning a new body bag entity when unfolded.
	var/unfoldedbag_path = /obj/structure/closet/body_bag

/obj/item/bodybag/get_ru_names()
	return list(
		NOMINATIVE = "мешок для трупов",
		GENITIVE = "мешка для трупов",
		DATIVE = "мешку для трупов",
		ACCUSATIVE = "мешок для трупов",
		INSTRUMENTAL = "мешком для трупов",
		PREPOSITIONAL = "мешке для трупов"
	)

/obj/item/bodybag/attack_self(mob/user)
	if(loc == user)
		deploy_bodybag(user, get_turf(user))
	else
		deploy_bodybag(user, get_turf(src))

/obj/item/bodybag/pickup(mob/user)
	// can't pick ourselves up if we are inside of the bodybag, else very weird things may happen
	if(contains(user))
		return FALSE
	return ..()

/**
 * Creates a new body bag item when unfolded, at the provided location, replacing the body bag item.
 * * mob/user: User opening the body bag.
 * * atom/location: the place/entity/mob where the body bag is being deployed from.
 */
/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/item_bag = new unfoldedbag_path(location)
	item_bag.open(user)
	item_bag.add_fingerprint(user)
	item_bag.foldedbag_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_bag

/obj/item/bodybag/suicide_act(mob/living/user)
	if(isfloorturf(user.loc))
		user.visible_message(span_suicide("[user] заполза[pluralize_ru(user.gender, "ет", "ют")] в [declent_ru(ACCUSATIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить самоубийство!"))
		var/obj/structure/closet/body_bag/R = new unfoldedbag_path(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/items/zip.ogg', 15, TRUE, -3)
		return OXYLOSS

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "Пластиковый мешок, предназначенный для хранения и транспортировки трупов."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	density = FALSE
	integrity_failure = 50
	pull_push_slowdown = 0
	ignore_density_closed = TRUE
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null


/obj/structure/closet/body_bag/get_ru_names()
	return list(
		NOMINATIVE = "мешок для трупов",
		GENITIVE = "мешка для трупов",
		DATIVE = "мешку для трупов",
		ACCUSATIVE = "мешок для трупов",
		INSTRUMENTAL = "мешком для трупов",
		PREPOSITIONAL = "мешке для трупов"
	)


/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		var/new_name = rename_interactive(user, I)
		if(new_name)
			update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/structure/closet/body_bag/wirecutter_act(mob/living/user, obj/item/I)
	if(name == initial(name))
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("Вы срезаете бирку с [declent_ru(GENITIVE)]."))
	name = initial(name)
	update_icon(UPDATE_OVERLAYS)


/obj/structure/closet/body_bag/open()
	. = ..()
	if(.)
		pull_push_slowdown = 0


/obj/structure/closet/body_bag/close()
	. = ..()
	if(. && length(contents))
		pull_push_slowdown = 1.3


/obj/structure/closet/body_bag/update_icon_state()
	icon_state = opened ? icon_opened : icon_closed


/obj/structure/closet/body_bag/update_overlays()
	. = list()
	if(name != initial(name))
		. += "bodybag_label"

/obj/structure/closet/body_bag/proc/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, span_warning("Нельзя сложить [declent_ru(ACCUSATIVE)] в расстёгнутом виде."))
		return
	if(length(contents))
		return
	return TRUE

/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/the_folder)
	var/folding_bodybag = new foldedbag_path(get_turf(src))
	the_folder.put_in_hands(folding_bodybag)


/obj/structure/closet/body_bag/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && !opened && !length(contents) && usr.Adjacent(src))
		usr.visible_message(
			span_notice("[usr] складыва[pluralize_ru(usr.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы складываете [declent_ru(ACCUSATIVE)]."),
		)
		perform_fold(usr)
		qdel(src)
		return FALSE

	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && usr.Adjacent(src))
		if(attempt_fold(usr))
			usr.visible_message(
				span_notice("[usr] складыва[pluralize_ru(usr.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
				span_notice("Вы складываете [declent_ru(ACCUSATIVE)]."),
			)
			perform_fold(usr)
			qdel(src)
			return FALSE
	return ..()

/obj/structure/closet/body_bag/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/obj/structure/closet/body_bag/relaymove(mob/user)
	if(user.stat)
		return

	// Make it possible to escape from bodybags in morgues and crematoriums
	if(loc && (isturf(loc) || istype(loc, /obj/structure/morgue) || istype(loc, /obj/machinery/crematorium)))
		if(!open())
			loc.balloon_alert(user, "не поддаётся!")

/obj/structure/closet/body_bag/welder_act(mob/user, obj/item/I)
	return FALSE //Can't be weldled under any circumstances.


/obj/item/bodybag/biohazard
	name = "biohazard bodybag"
	desc = "Сложенный мешок, предназначенный для хранения и транспортировки инфицированных трупов."
	icon_state = "bodybag_biohazard_folded"
	item_state = "bodybag_biohazard"
	unfoldedbag_path = /obj/structure/closet/body_bag/biohazard

/obj/item/bodybag/biohazard/get_ru_names()
	return list(
		NOMINATIVE = "мешок для инфицированных трупов",
		GENITIVE = "мешка для инфицированных трупов",
		DATIVE = "мешку для инфицированных трупов",
		ACCUSATIVE = "мешок для инфицированных трупов",
		INSTRUMENTAL = "мешком для инфицированных трупов",
		PREPOSITIONAL = "мешке для инфицированных трупов"
	)

/obj/structure/closet/body_bag/biohazard
	name = "biohazard body bag"
	desc = "Пластиковый мешок, предназначенный для хранения и транспортировки инфицированных трупов."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_biohazard_closed"
	icon_closed = "bodybag_biohazard_closed"
	icon_opened = "bodybag_biohazard_open"
	foldedbag_path = /obj/item/bodybag/biohazard


/obj/structure/closet/body_bag/biohazard/get_ru_names()
	return list(
		NOMINATIVE = "мешок для инфицированных трупов",
		GENITIVE = "мешка для инфицированных трупов",
		DATIVE = "мешку для инфицированных трупов",
		ACCUSATIVE = "мешок для инфицированных трупов",
		INSTRUMENTAL = "мешком для инфицированных трупов",
		PREPOSITIONAL = "мешке для инфицированных трупов"
	)

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "Сложенный блюспейс мешок, предназначенный для хранения и транспортировки трупов."
	icon_state = "bluebag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "блюспейс мешок для трупов",
		GENITIVE = "блюспейс мешка для трупов",
		DATIVE = "блюспейс мешку для трупов",
		ACCUSATIVE = "блюспейс мешок для трупов",
		INSTRUMENTAL = "блюспейс мешком для трупов",
		PREPOSITIONAL = "блюспейс мешке для трупов"
	)


/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(contents.len)
		var/contents_number = contents.len
		. += span_notice("Вы можете разглядеть форм[declension_ru(contents_number, "у", "ы", "ы")] [contents_number] объект[declension_ru(contents_number, "а", "ов", "ов")] через ткань.")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, span_notice("Вы внезапно ощущаете, как пространство вокруг вас рвётся на части! Вы свободны!"))
	return ..()

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/item_bag = new unfoldedbag_path(location)
	for(var/atom/movable/inside in contents)
		inside.forceMove(item_bag)
		if(isliving(inside))
			to_chat(inside, span_notice("Вы снова чувствуете свежий воздух вокруг! Вы свободны!"))
	item_bag.open(user)
	item_bag.add_fingerprint(user)
	item_bag.foldedbag_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_bag

/obj/item/bodybag/bluespace/container_resist(mob/living/user)
	var/breakout_time = 10 SECONDS
	if(user.incapacitated())
		to_chat(user, span_warning("Вы не можете выбраться, будучи связанным!"))
		return
	user.changeNext_move(breakout_time)
	user.last_special = world.time + (breakout_time)
	to_chat(user, span_notice("Вы вцепляетесь в ткань [declent_ru(GENITIVE)], пытаясь разорвать её..."))
	to_chat(loc, span_warning("Кто-то пытается выбраться из [declent_ru(GENITIVE)]!"))
	if(!do_after(user, 12 SECONDS, src))
		return
	// you are still in the bag? time to go unless you KO'd, honey!
	// if they escape during this time and you rebag them the timer is still clocking down and does NOT reset so they can very easily get out.
	if(user.incapacitated())
		to_chat(loc, span_warning("Давление ослабевает. Похоже, [genderize_ru(user.gender, "он", "она", "оно", "они")] переста[genderize_ru(user.gender, "л", "ла", "ло", "ли")] сопротивляться..."))
		return
	loc.visible_message(
		span_warning("[user] внезапно появляется перед [loc.declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user] вырывается из [declent_ru(GENITIVE)]!")
	)
	qdel(src)

/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "Блюспейс мешок, предназначенный для хранения и транспортировки трупов."
	icon_state = "bluebag_closed"
	icon_closed = "bluebag_closed"
	icon_opened = "bluebag_open"
	foldedbag_path = /obj/item/bodybag/bluespace


/obj/structure/closet/body_bag/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "блюспейс мешок для трупов",
		GENITIVE = "блюспейс мешка для трупов",
		DATIVE = "блюспейс мешку для трупов",
		ACCUSATIVE = "блюспейс мешок для трупов",
		INSTRUMENTAL = "блюспейс мешком для трупов",
		PREPOSITIONAL = "блюспейс мешке для трупов"
	)


/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE

	if(!istype(the_folder))
		return

	if(opened)
		to_chat(the_folder, span_warning("Нельзя сложить [declent_ru(ACCUSATIVE)] в расстёгнутом виде."))
		return

	if(the_folder.in_contents_of(src))
		to_chat(the_folder, span_warning("Вы не можете сложить [declent_ru(ACCUSATIVE)], находясь внутри!"))
		return

	for(var/obj/item/bodybag/bluespace/B in src)
		to_chat(the_folder, span_warning("Вы не можете сложить блюспейс мешки друг в друга!") )
		return

	return TRUE


/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/the_folder)
	visible_message(span_notice("[the_folder] складывает [declent_ru(ACCUSATIVE)]."))
	var/obj/item/bodybag/folding_bodybag = new foldedbag_path
	var/max_weight_of_contents = initial(folding_bodybag.w_class)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(folding_bodybag)
		if(isliving(content))
			to_chat(content, span_userdanger("Внезапно вы оказываетесь сложены в крохотное блюспейс пространство!"))
		if(HAS_TRAIT(content, TRAIT_DWARF))
			max_weight_of_contents = max(WEIGHT_CLASS_NORMAL, max_weight_of_contents)
			continue
		if(!isitem(content))
			max_weight_of_contents = max(WEIGHT_CLASS_BULKY, max_weight_of_contents)
			continue
		var/obj/item/A_is_item = content
		if(A_is_item.w_class < max_weight_of_contents)
			continue
		max_weight_of_contents = A_is_item.w_class
	folding_bodybag.w_class = max_weight_of_contents
	the_folder.put_in_hands(folding_bodybag)
