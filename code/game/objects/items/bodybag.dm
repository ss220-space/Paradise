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
		PREPOSITIONAL = "мешке для трупов",
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
	item_bag.balloon_alert_to_viewers("раскладыва[PLUR_ET_YUT(user)] мешок", "мешок разложен")
	item_bag.open(user)
	item_bag.add_fingerprint(user)
	item_bag.foldedbag_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_bag

/obj/item/bodybag/suicide_act(mob/living/user)
	if(isfloorturf(user.loc))
		user.visible_message(span_suicide("[user] заполза[PLUR_ET_YUT(user)] в [declent_ru(ACCUSATIVE)]! Похоже, что [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся совершить самоубийство!"))
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
	anchorable = FALSE
	pull_push_slowdown = 0
	ignore_density_closed = TRUE
	interaction_flags_mouse_drop = NEED_HANDS
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null

/obj/structure/closet/body_bag/get_ru_names()
	return list(
		NOMINATIVE = "мешок для трупов",
		GENITIVE = "мешка для трупов",
		DATIVE = "мешку для трупов",
		ACCUSATIVE = "мешок для трупов",
		INSTRUMENTAL = "мешком для трупов",
		PREPOSITIONAL = "мешке для трупов",
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
	balloon_alert(user, "бирка срезана")
	name = initial(name)
	ru_names = get_ru_names()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/closet/body_bag/open(mob/living/user, force = FALSE)
	. = ..()
	if(.)
		pull_push_slowdown = 0

/obj/structure/closet/body_bag/close(mob/living/user)
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
		balloon_alert(the_folder, "застегните мешок!")
		return
	if(length(contents))
		return
	return TRUE

/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/the_folder)
	var/turf/turf = get_turf(src)
	var/obj/item/folding_bodybag = new foldedbag_path(turf)
	turf.balloon_alert_to_viewers("складыва[PLUR_ET_YUT(the_folder)] мешок", "мешок сложен")
	the_folder.put_in_hands(folding_bodybag)


/obj/structure/closet/body_bag/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object != user || !ishuman(user) || user.incapacitated())
		return

	if(!opened && !length(contents))
		perform_fold(user)
		qdel(src)
		return FALSE

	if(attempt_fold(user))
		perform_fold(user)
		qdel(src)
		return FALSE

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
		PREPOSITIONAL = "мешке для инфицированных трупов",
	)

/obj/structure/closet/body_bag/biohazard
	name = "biohazard body bag"
	desc = "Пластиковый мешок, предназначенный для хранения и транспортировки инфицированных трупов."
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
		PREPOSITIONAL = "мешке для инфицированных трупов",
	)

/obj/item/bodybag/bluespace
	name = "bluespace body bag"
	desc = "Сложенный блюспейс мешок, предназначенный для хранения и транспортировки трупов."
	icon_state = "bluebag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/bluespace
	item_flags = NO_MAT_REDEMPTION

/obj/item/bodybag/bluespace/get_ru_names()
	return list(
		NOMINATIVE = "блюспейс мешок для трупов",
		GENITIVE = "блюспейс мешка для трупов",
		DATIVE = "блюспейс мешку для трупов",
		ACCUSATIVE = "блюспейс мешок для трупов",
		INSTRUMENTAL = "блюспейс мешком для трупов",
		PREPOSITIONAL = "блюспейс мешке для трупов",
	)

/obj/item/bodybag/bluespace/examine(mob/user)
	. = ..()
	var/contents_number = length(contents)
	if(contents_number)
		. += span_notice("Вы можете разглядеть форм[declension_ru(contents_number, "у", "ы", "ы")] [contents_number] объект[declension_ru(contents_number, "а", "ов", "ов")] через ткань.")

/obj/item/bodybag/bluespace/Destroy()
	for(var/atom/movable/movable in contents)
		movable.forceMove(get_turf(src))
		if(isliving(movable))
			balloon_alert(movable, "вы свободны!")
	return ..()

/obj/item/bodybag/bluespace/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/body_bag/item_bag = new unfoldedbag_path(location)
	item_bag.balloon_alert_to_viewers("раскладыва[PLUR_ET_YUT(user)] мешок", "мешок разложен")
	for(var/atom/movable/inside in contents)
		inside.forceMove(item_bag)
		if(isliving(inside))
			balloon_alert(inside, "вы свободны!")
	item_bag.open(user)
	item_bag.add_fingerprint(user)
	item_bag.foldedbag_instance = src
	user.drop_item_ground(src)
	move_to_null_space()
	return item_bag

/obj/item/bodybag/bluespace/container_resist_act(mob/living/user)
	if(user.incapacitated())
		balloon_alert(user, "вы связаны!")
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	balloon_alert(user, "вы сопротивляетесь...")
	visible_message(span_warning("Кто-то пытается выбраться из [declent_ru(GENITIVE)]!"))
	if(!do_after(user, 12 SECONDS, target = src))
		return
	// you are still in the bag? time to go unless you KO'd, honey!
	// if they escape during this time and you rebag them the timer is still clocking down and does NOT reset so they can very easily get out.
	if(user.incapacitated())
		to_chat(loc, span_warning("Давление ослабевает. Похоже, [GEND_HE_SHE(user)] перестал[GEND_A_O_I(user)] сопротивляться..."))
		return
	loc.visible_message(span_warning("[user] внезапно появляется перед [loc.declent_ru(INSTRUMENTAL)]!"))
	balloon_alert(user, "вы вырываетесь!")
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
		PREPOSITIONAL = "блюспейс мешке для трупов",
	)

/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE

	if(!istype(the_folder))
		return

	if(opened)
		balloon_alert(the_folder, "застегните мешок!")
		return

	if(the_folder.in_contents_of(src))
		balloon_alert(the_folder, "невозможно!")
		to_chat(the_folder, span_warning("Вы не можете сложить [declent_ru(ACCUSATIVE)], находясь внутри!"))
		return

	for(var/obj/item/bodybag/bluespace/B in src)
		balloon_alert(the_folder, "невозможно!")
		to_chat(the_folder, span_warning("Вы не можете сложить блюспейс мешки друг в друга!") )
		return

	return TRUE

/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/the_folder)
	var/turf/turf = get_turf(src)
	var/obj/item/folding_bodybag = new foldedbag_path(turf)
	turf.balloon_alert_to_viewers("складыва[PLUR_ET_YUT(the_folder)] мешок", "мешок сложен")
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


/obj/item/bodybag/environmental
	name = "environmental protection bag"
	desc = "Продвинутый мешок, созданный для защиты от опасной окружающей среды или экстремально низкого давления."
	icon_state = "envirobag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/environmental
	w_class = WEIGHT_CLASS_NORMAL //It's reinforced and insulated, like a beefed-up sleeping bag, so it has a higher bulkiness than regular bodybag
	resistance_flags = ACID_PROOF | FIRE_PROOF | FREEZE_PROOF

/obj/item/bodybag/environmental/get_ru_names()
	return list(
		NOMINATIVE = "защитный мешок",
		GENITIVE = "защитного мешка",
		DATIVE = "защитному мешку",
		ACCUSATIVE = "защитный мешок",
		INSTRUMENTAL = "защитным мешком",
		PREPOSITIONAL = "защитном мешке"
	)

/obj/item/bodybag/environmental/nanotrasen
	name = "elite environmental protection bag"
	desc = "Продвинутая версия защитного мешка, способная полностью обезопасить содержимое от любого воздействия внешней среды."
	icon_state = "ntenvirobag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/environmental/nanotrasen
	resistance_flags = ACID_PROOF | FIRE_PROOF | FREEZE_PROOF | LAVA_PROOF

/obj/item/bodybag/environmental/nanotrasen/get_ru_names()
	return list(
		NOMINATIVE = "элитный защитный мешок",
		GENITIVE = "элитного защитного мешка",
		DATIVE = "элитному защитному мешку",
		ACCUSATIVE = "элитный защитный мешок",
		INSTRUMENTAL = "элитным защитным мешком",
		PREPOSITIONAL = "элитном защитном мешке"
	)

/obj/item/bodybag/environmental/prisoner
	name = "prisoner transport bag"
	desc = "Мешок, созданный для транспортировки заключённых в условиях враждебной окружающей среды. Оснащён стяжками, \
			позволяющими насильно удерживать заключённого внутри."
	icon_state = "prisonerenvirobag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/environmental/prisoner

/obj/item/bodybag/environmental/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "защитный мешок для заключённых",
		GENITIVE = "защитного мешка для заключённых",
		DATIVE = "защитному мешку для заключённых",
		ACCUSATIVE = "защитный мешок для заключённых",
		INSTRUMENTAL = "защитным мешком для заключённых",
		PREPOSITIONAL = "защитном мешке для заключённых"
	)

/obj/item/bodybag/environmental/prisoner/pressurized
	unfoldedbag_path = /obj/structure/closet/body_bag/environmental/prisoner/pressurized

/obj/item/bodybag/environmental/prisoner/syndicate
	name = "syndicate prisoner transport bag"
	desc = "Мешок, созданный для транспортировки пленников синдиката в условиях враждебной окружающей среды. Оснащён стяжками, \
			позволяющими насильно удерживать пленника внутри."
	icon_state = "syndieenvirobag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/environmental/prisoner/pressurized/syndicate
	resistance_flags = ACID_PROOF | FIRE_PROOF | FREEZE_PROOF | LAVA_PROOF

/obj/item/bodybag/environmental/prisoner/syndicate/get_ru_names()
	return list(
		NOMINATIVE = "мешок для заключённых синдиката",
		GENITIVE = "мешка для заключённых синдиката",
		DATIVE = "мешку для заключённых синдиката",
		ACCUSATIVE = "мешок для заключённых синдиката",
		INSTRUMENTAL = "мешком для заключённых синдиката",
		PREPOSITIONAL = "мешке для заключённых синдиката"
	)

/// Environmental bags. They protect against bad weather.
/obj/structure/closet/body_bag/environmental
	name = "environmental protection bag"
	desc = "Продвинутый мешок, созданный для защиты от опасной окружающей среды или экстремально низкого давления."
	icon_state = "envirobag"
	mob_storage_capacity = 1
	contents_pressure_protection = 0.8
	contents_thermal_insulation = 0.5
	foldedbag_path = /obj/item/bodybag/environmental
	/// The list of weathers we protect from.
	var/list/weather_protection = list(TRAIT_ASHSTORM_IMMUNE, TRAIT_RADSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE) // Does not protect against lava or the The Floor Is Lava spell.
	/// The contents of the gas to be distributed to an occupant. Set in Initialize()
	var/datum/gas_mixture/air_contents = null

/obj/structure/closet/body_bag/environmental/get_ru_names()
	return list(
		NOMINATIVE = "защитный мешок",
		GENITIVE = "защитного мешка",
		DATIVE = "защитному мешку",
		ACCUSATIVE = "защитный мешок",
		INSTRUMENTAL = "защитным мешком",
		PREPOSITIONAL = "защитном мешке"
	)

/obj/structure/closet/body_bag/environmental/Initialize(mapload)
	. = ..()
	add_traits(weather_protection, INNATE_TRAIT)
	refresh_air()

/obj/structure/closet/body_bag/environmental/Destroy()
	QDEL_NULL(air_contents)
	return ..()

/obj/structure/closet/body_bag/environmental/return_obj_air()
	refresh_air()
	return air_contents

/obj/structure/closet/body_bag/environmental/return_analyzable_air()
	refresh_air()
	return air_contents

/obj/structure/closet/body_bag/environmental/togglelock(mob/living/user, silent)
	. = ..()
	for(var/mob/living/target in contents)
		to_chat(target, span_warning("Вы слышите тихое шипение, после чего белый дым заполняет пространство мешка..."))

/obj/structure/closet/body_bag/environmental/proc/refresh_air()
	air_contents = null
	air_contents = new	//liters
	air_contents.set_temperature(T20C)
	air_contents.volume = 50

	air_contents.set_oxygen(O2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))
	air_contents.set_nitrogen(N2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))

/obj/structure/closet/body_bag/environmental/update_icon_state()
	return

/obj/structure/closet/body_bag/environmental/update_overlays()
	. = ..()
	if(!opened)
		return

	var/mutable_appearance/open_overlay = mutable_appearance(icon, "[icon_state]_open", alpha = src.alpha)
	. += open_overlay
	open_overlay.overlays += emissive_blocker(open_overlay.icon, open_overlay.icon_state, src, alpha = open_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.

/obj/structure/closet/body_bag/environmental/nanotrasen
	name = "elite environmental protection bag"
	desc = "Продвинутая версия защитного мешка, способная полностью обезопасить содержимое от любого воздействия внешней среды."
	icon_state = "ntenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/nanotrasen
	weather_protection = list(TRAIT_WEATHER_IMMUNE)

/obj/structure/closet/body_bag/environmental/nanotrasen/get_ru_names()
	return list(
		NOMINATIVE = "элитный защитный мешок",
		GENITIVE = "элитного защитного мешка",
		DATIVE = "элитному защитному мешку",
		ACCUSATIVE = "элитный защитный мешок",
		INSTRUMENTAL = "элитным защитным мешком",
		PREPOSITIONAL = "элитном защитном мешке"
	)

/// Securable enviro. bags
/obj/structure/closet/body_bag/environmental/prisoner
	name = "prisoner transport bag"
	desc = "Мешок, созданный для транспортировки заключённых в условиях враждебной окружающей среды. Оснащён зажимами, \
			позволяющими насильно удерживать заключённого внутри."
	icon_state = "prisonerenvirobag"
	foldedbag_path = /obj/item/bodybag/environmental/prisoner
	breakout_time = 1 MINUTES
	/// How long it takes to sinch the bag.
	var/sinch_time = 5 SECONDS
	/// Whether or not the bag is sinched. Starts unsinched.
	var/sinched = FALSE
	/// The sound that plays when the bag is done sinching.
	var/sinch_sound = 'sound/items/handling/equip/toolbelt_equip.ogg'

/obj/structure/closet/body_bag/environmental/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "защитный мешок для заключённых",
		GENITIVE = "защитного мешка для заключённых",
		DATIVE = "защитному мешку для заключённых",
		ACCUSATIVE = "защитный мешок для заключённых",
		INSTRUMENTAL = "защитным мешком для заключённых",
		PREPOSITIONAL = "защитном мешке для заключённых"
	)

/obj/structure/closet/body_bag/environmental/prisoner/attempt_fold(mob/living/carbon/human/the_folder)
	if(sinched)
		balloon_alert(the_folder, "ослабьте зажимы!")
		return FALSE
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/can_open()
	. = ..()
	if(!.)
		return FALSE

	if(sinched)
		return FALSE

	return TRUE

/obj/structure/closet/body_bag/environmental/prisoner/update_icon()
	. = ..()
	if(sinched)
		icon_state = initial(icon_state) + "_sinched"
	else
		icon_state = initial(icon_state)

/obj/structure/closet/body_bag/environmental/prisoner/container_resist_act(mob/living/user, loc_required = TRUE)
	// copy-pasted with changes because flavor text as well as some other misc stuff
	if(opened || ismovable(loc) || !sinched)
		return ..()

	balloon_alert(user, "вы сопротивляетесь...")
	user.visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] заметно подёргивается!"),
		span_notice("Вы пытаетесь выбраться из [declent_ru(GENITIVE)]. Это займёт приблизительно [DisplayTimeText(breakout_time)]."),
		span_hear("Вы слышите странное шуршание.")
	)

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	if(!do_after(user, (breakout_time), target = src))
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("Вам не удалось выбраться из [declent_ru(GENITIVE)]!"))
		return

	if(!user || user.stat != CONSCIOUS || user.loc != src || opened || !sinched)
		return

	// we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
	user.visible_message(
		span_danger("[user] успешно освобожда[PLUR_ET_UT(user)]ся из [declent_ru(GENITIVE)]!"),
		ignored_mobs = user
		)

	user.balloon_alert(user, "вы вырываетесь!")
	if(istype(loc, /obj/machinery/disposal))
		return ..()
	bust_open()

/obj/structure/closet/body_bag/environmental/prisoner/bust_open()
	sinched = FALSE
	// We don't break the bag, because the buckles were backed out as opposed to fully broken.
	open()

/obj/structure/closet/body_bag/environmental/prisoner/click_alt(mob/user)
	if(!user.can_perform_action(src) || !isturf(loc))
		return CLICK_ACTION_BLOCKING
	togglelock(user)

	return CLICK_ACTION_SUCCESS

/obj/structure/closet/body_bag/environmental/prisoner/proc/is_closed()
	return !opened

/obj/structure/closet/body_bag/environmental/prisoner/togglelock(mob/living/user, silent)
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	if(opened)
		balloon_alert(user, "закройте мешок!")
		return
	if(user in contents)
		balloon_alert(user, "невозможно!")
		to_chat(user, span_warning("Вы не можете сложить [declent_ru(ACCUSATIVE)], находясь внутри!"))
		return
	if(iscarbon(user))
		add_fingerprint(user)
	if(!sinched)
		for(var/mob/living/target in contents)
			to_chat(target, span_userdanger("Вы чувствуете, как мешок становится теснее. Ещё немного, и вы больше не сможете выбраться без посторонней помощи!"))
		user.balloon_alert_to_viewers("закрыва[PLUR_ET_UT(user)] зажимы...", "закрытие зажимов...")
		if(!(do_after(user, sinch_time, src, extra_checks = CALLBACK(src, PROC_REF(is_closed)))))
			return
	sinched = !sinched
	if(sinched)
		playsound(loc, sinch_sound, 15, TRUE, -2)
	user.visible_message(
		span_notice("[user] [sinched ? "защёлкива" : "отщёлкива"][PLUR_ET_UT(user)] зажимы на [declent_ru(PREPOSITIONAL)]."),
		span_notice("Вы [sinched ? "зещёлкиваете" : "отщёлкиваете"] зажимы на [declent_ru(PREPOSITIONAL)]."),
		span_hear("Вы слышите странный щелчок.")
	)
	add_game_logs("[sinched ? "sinched" : "unsinched"] secure environmental bag [src]", user)
	update_appearance()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate
	name = "syndicate prisoner transport bag"
	desc = "Мешок, используемый \"Синдикатом\" для транспортировки живых целей в условиях враждебной окружающей среды. Оснащён зажимами, \
			позволяющими насильно удерживать цель внутри. Зарекомендовал себя как эффективный инструмент после использования \
			в серии успешных похищений."
	icon_state = "syndieenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/prisoner/syndicate
	weather_protection = list(TRAIT_WEATHER_IMMUNE)
	sinch_time = 7 SECONDS

/obj/structure/closet/body_bag/environmental/prisoner/pressurized/syndicate/refresh_air()
	air_contents = null
	air_contents = new	//liters
	air_contents.set_temperature(T20C)
	air_contents.volume = 50

	air_contents.set_oxygen(O2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))
	air_contents.set_sleeping_agent(N2STANDARD * ONE_ATMOSPHERE * 50 / (R_IDEAL_GAS_EQUATION * T20C))

/obj/structure/closet/body_bag/environmental/hardlight
	name = "hardlight bodybag"
	desc = "Мешок, созданный на основе твёрдого света. Достаточно крепкий, чтобы поддерживать атмосферу внутри."
	icon_state = "holobag_med"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	foldedbag_path = null
	weather_protection = list(TRAIT_SNOWSTORM_IMMUNE)

/obj/structure/closet/body_bag/environmental/hardlight/get_ru_names()
	return list(
		NOMINATIVE = "голографический защитный мешок",
		GENITIVE = "голографического защитного мешка",
		DATIVE = "голографическому защитному мешку",
		ACCUSATIVE = "голографический защитный мешок",
		INSTRUMENTAL = "голографическим защитным мешком",
		PREPOSITIONAL = "голографическом защитном мешке"
	)

/obj/structure/closet/body_bag/environmental/hardlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type in list(BRUTE, BURN))
		playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/closet/body_bag/environmental/prisoner/hardlight
	name = "hardlight prisoner bodybag"
	desc = "Мешок, созданный на основе твёрдого света. Достаточно крепкий, чтобы поддерживать атмосферу внутри. \
			Имеет зажимы для транспортировки заключённых."
	icon_state = "holobag_sec"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	foldedbag_path = null
	weather_protection = list(TRAIT_SNOWSTORM_IMMUNE)

/obj/structure/closet/body_bag/environmental/prisoner/hardlight/get_ru_names()
	return list(
		NOMINATIVE = "голографический защитный мешок для заключённых",
		GENITIVE = "голографического защитного мешка для заключённых",
		DATIVE = "голографическому защитному мешку для заключённых",
		ACCUSATIVE = "голографический защитный мешок для заключённых",
		INSTRUMENTAL = "голографическим защитным мешком для заключённых",
		PREPOSITIONAL = "голографическом защитном мешке для заключённых"
	)


/obj/structure/closet/body_bag/environmental/prisoner/hardlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type in list(BRUTE, BURN))
		playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
