//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "Стандартный мешок для тел, выполненный из прочного чёрного пластика. \
			Предназначен для временного хранения и транспортировки тел. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок достаточного размера для помещения внутрь тела гуманоида."
	ru_names = list(
		NOMINATIVE = "мешок для тел",
		GENITIVE = "мешка для тел",
		DATIVE = "мешку для тел",
		ACCUSATIVE = "мешок для тел",
		INSTRUMENTAL = "мешком для тел",
		PREPOSITIONAL = "мешке для тел"
	)
	gender = MALE
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	item_state = "bodybag"
	w_class = WEIGHT_CLASS_SMALL
	///Stored path we use for spawning a new body bag entity when unfolded.
	var/unfoldedbag_path = /obj/structure/closet/body_bag

/obj/item/bodybag/attack_self(mob/user)
	if(loc == user)
		deploy_bodybag(user, get_turf(user))
	else
		deploy_bodybag(user, get_turf(src))
	user.balloon_alert(user, "разложено")

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
		user.visible_message(span_suicide("[user] залеза[pluralize_ru(user.gender, "ет", "ют")] в [declent_ru(ACCUSATIVE)]! Похоже, что [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "ет", "ют")]ся совершить самоубийство!"))
		var/obj/structure/closet/body_bag/R = new unfoldedbag_path(user.loc)
		R.add_fingerprint(user)
		qdel(src)
		user.forceMove(R)
		playsound(src, 'sound/items/zip.ogg', 15, TRUE, -3)
		return OXYLOSS

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "Стандартный мешок для тел, выполненный из прочного чёрного пластика. \
			Предназначен для временного хранения и транспортировки тел. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок достаточного размера для помещения внутрь тела гуманоида."
	ru_names = list(
		NOMINATIVE = "мешок для тел",
		GENITIVE = "мешка для тел",
		DATIVE = "мешку для тел",
		ACCUSATIVE = "мешок для тел",
		INSTRUMENTAL = "мешком для тел",
		PREPOSITIONAL = "мешке для тел"
	)
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
	user.balloon_alert(user, "бирка срезана")
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

/obj/structure/closet/body_bag/proc/attempt_fold(mob/living/carbon/human/user)
	. = FALSE
	if(!istype(user))
		return
	if(opened)
		user.balloon_alert(user, "открытый мешок не сложится!")
		return
	if(length(contents))
		return
	return TRUE

/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/user)
	var/folding_bodybag = new foldedbag_path(get_turf(src))
	user.put_in_hands(folding_bodybag)


/obj/structure/closet/body_bag/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	var/mob/user = usr
	if(over_object == user && ishuman(user) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) && !opened && !length(contents) && user.Adjacent(src))
		user.balloon_alert(user, "сложено")
		perform_fold(user)
		qdel(src)
		return FALSE

	if(over_object == user && ishuman(usr) && !user.incapacitated() && user.Adjacent(src))
		if(attempt_fold(user))
			user.balloon_alert(user, "сложено")
			perform_fold(user)
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
			user.balloon_alert(user, "не поддаётся!")

/obj/structure/closet/body_bag/welder_act(mob/user, obj/item/I)
	return FALSE //Can't be weldled under any circumstances.


/obj/item/bodybag/biohazard
	name = "biohazard bodybag"
	desc = "Специализированный мешок для тел повышенной герметичности, выполненный из прочного пластика. \
			Предназначен для временного хранения и транспортировки тел в условиях биологической опасности. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок достаточного размера для помещения внутрь тела гуманоида. \
			Отличается жёлто-чёрной окраской и знаком биологической опасности на поверхности."
	ru_names = list(
		NOMINATIVE = "биозащитный мешок для тел",
		GENITIVE = "биозащитного мешка для тел",
		DATIVE = "биозащитному мешку для тел",
		ACCUSATIVE = "биозащитный мешок для тел",
		INSTRUMENTAL = "биозащитным мешком для тел",
		PREPOSITIONAL = "биозащитном мешке для тел"
	)
	icon_state = "bodybag_biohazard_folded"
	item_state = "bodybag_biohazard"
	unfoldedbag_path = /obj/structure/closet/body_bag/biohazard

/obj/structure/closet/body_bag/biohazard
	name = "biohazard body bag"
	desc = "Специализированный мешок для тел повышенной герметичности, выполненный из прочного пластика. \
			Предназначен для временного хранения и транспортировки тел в условиях биологической опасности. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок достаточного размера для помещения внутрь тела гуманоида. \
			Отличается жёлто-чёрной окраской и знаком биологической опасности на поверхности."
	ru_names = list(
		NOMINATIVE = "биозащитный мешок для тел",
		GENITIVE = "биозащитного мешка для тел",
		DATIVE = "биозащитному мешку для тел",
		ACCUSATIVE = "биозащитный мешок для тел",
		INSTRUMENTAL = "биозащитным мешком для тел",
		PREPOSITIONAL = "биозащитном мешке для тел"
	)
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_biohazard_closed"
	icon_closed = "bodybag_biohazard_closed"
	icon_opened = "bodybag_biohazard_open"
	foldedbag_path = /obj/item/bodybag/biohazard


/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "Экспериментальный мешок для тел, выполненный с использованием блюспейс-технологий. \
			Предназначен для временного хранения и транспортировки тел. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок с блюспейс-карманом внутри, куда попадает тело гуманоида."
	ru_names = list(
		NOMINATIVE = "блюспейс мешок для тел",
		GENITIVE = "блюспейс мешка для тел",
		DATIVE = "блюспейс мешку для тел",
		ACCUSATIVE = "блюспейс мешок для тел",
		INSTRUMENTAL = "блюспейс мешком для тел",
		PREPOSITIONAL = "блюспейс мешке для тел"
	)
	icon_state = "bluebag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	if(contents.len)
		var/s = contents.len == 1 ? "" : "s"
		. += span_notice("Судя по форме мешка, внутри наход[declension_ru(contents.len, "ит", "ят", "ит")]ся <b>[contents.len]</b> объект[declension_ru(contents.len, "", "а", "ов")].")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, span_boldnotice("Вы чувствуете, как пространство вокруг схлопывается! Вы свободны!"))
	return ..()

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/item_bag = new unfoldedbag_path(location)
	for(var/atom/movable/inside in contents)
		inside.forceMove(item_bag)
		if(isliving(inside))
			to_chat(inside, span_boldnotice("Вы чувствуете, как пространство вокруг схлопывается! Вы свободны!"))
	item_bag.open(user)
	item_bag.add_fingerprint(user)
	item_bag.foldedbag_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_bag

/obj/item/bodybag/bluespace/container_resist(mob/living/user)
	var/breakout_time = 10 SECONDS
	if(user.incapacitated())
		user.balloon_alert(user, "нельзя выбраться, пока вы скованы!")
		return
	user.changeNext_move(breakout_time)
	user.last_special = world.time + (breakout_time)
	user.visible_message(
		span_warning("Кто-то пытается выбраться из [declent_ru(GENITIVE)]!"),
		span_boldwarning("Вы вцепляетесь в пространство вокруг себя, пытаясь выбраться из [declent_ru(GENITIVE)]...")
	)
	if(!do_after(user, 12 SECONDS, src))
		return
	// you are still in the bag? time to go unless you KO'd, honey!
	// if they escape during this time and you rebag them the timer is still clocking down and does NOT reset so they can very easily get out.
	if(user.incapacitated())
		to_chat(loc, span_warning("Текстура [declent_ru(GENITIVE)] перестаёт двигаться. Судя по всему, находящийся внутри перестал сопротивляться..."))
		return
	user.visible_message(
		span_warning("[user] выбира[pluralize_ru(user.gender, "ет", "ют")]ся из [declent_ru(GENITIVE)]!"),
		span_userdanger("Вы выбираетесь из [declent_ru(GENITIVE)]!")
	)
	qdel(src)

/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "Экспериментальный мешок для тел, выполненный с использованием блюспейс-технологий. \
			Предназначен для временного хранения и транспортировки тел. \
			В сложенном виде занимает мало места, что делает его удобным для размещения в медицинских и спасательных комплектах. \
			В разложенном виде представляет собой мешок с блюспейс-карманом внутри, куда попадает тело гуманоида."
	ru_names = list(
		NOMINATIVE = "блюспейс мешок для тел",
		GENITIVE = "блюспейс мешка для тел",
		DATIVE = "блюспейс мешку для тел",
		ACCUSATIVE = "блюспейс мешок для тел",
		INSTRUMENTAL = "блюспейс мешком для тел",
		PREPOSITIONAL = "блюспейс мешке для тел"
	)
	icon_state = "bluebag_closed"
	icon_closed = "bluebag_closed"
	icon_opened = "bluebag_open"
	foldedbag_path = /obj/item/bodybag/bluespace

/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/user)
	. = FALSE

	if(!istype(user))
		return

	if(opened)
		user.balloon_alert(user, "открытый мешок не сложится!")
		return

	if(user.in_contents_of(src))
		user.balloon_alert(user, "нельзя сложить изнутри!")
		return

	for(var/obj/item/bodybag/bluespace/B in src)
		user.balloon_alert(user, "рекурсивное складывание невозможно!")
		return

	return TRUE


/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/user)
	user.balloon_alert(user, "сложено")
	var/obj/item/bodybag/folding_bodybag = new foldedbag_path
	var/max_weight_of_contents = initial(folding_bodybag.w_class)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(folding_bodybag)
		if(isliving(content))
			to_chat(content, span_userdanger("Вы чувствуете, что пространство вокруг резко свернулось!"))
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
	user.put_in_hands(folding_bodybag)
