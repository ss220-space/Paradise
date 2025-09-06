/obj/machinery/papershredder
	name = "paper shredder"
	desc = "Устройство для тех документов, которых вы не хотите видеть."
	gender = MALE
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = TRUE
	anchored = TRUE
	var/max_paper = 15
	var/paperamount = 0
	var/list/shred_amounts = list(
		/obj/item/photo = 1,
		/obj/item/shredded_paper = 1,
		/obj/item/paper = 1,
		/obj/item/newspaper = 3,
		/obj/item/card/id = 3,
		/obj/item/paper_bundle = 3,
		/obj/item/folder = 4,
		/obj/item/book = 5
		)

/obj/machinery/papershredder/get_ru_names()
	return list(
		NOMINATIVE = "измельчитель бумаги",
		GENITIVE = "измельчителя бумаги",
		DATIVE = "измельчителю бумаги",
		ACCUSATIVE = "измельчитель бумаги",
		INSTRUMENTAL = "измельчителем бумаги",
		PREPOSITIONAL = "измельчителе бумаги"
	)

/obj/machinery/papershredder/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(isstorage(I))
		add_fingerprint(user)
		empty_bin(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	var/paper_result = 0
	for(var/shred_type in shred_amounts)
		if(istype(I, shred_type))
			paper_result = shred_amounts[shred_type]
	if(!paper_result)
		return ..()

	add_fingerprint(user)
	if(paperamount == max_paper)
		balloon_alert(user, "нет места!")
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	. = ATTACK_CHAIN_BLOCKED_ALL
	balloon_alert(user, "помещено внутрь")
	qdel(I)
	paperamount += paper_result
	playsound(loc, 'sound/items/pshred.ogg', 75, TRUE)
	if(paperamount > max_paper)
		to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] переполняется и куски бумаги разлетаются повсюду!"))
		var/atom/drop_loc = drop_location()
		var/turf/throw_to = get_edge_target_turf(src, pick(GLOB.alldirs))
		for(var/i = 1 to (paperamount - max_paper))
			var/obj/item/shredded_paper/shredded = get_shredded_paper(drop_loc)
			shredded.throw_at(throw_to, 1, 1)
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/papershredder/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

/obj/machinery/papershredder/verb/empty_contents()
	set name = "Опустошить корзину"
	set category = STATPANEL_OBJECT
	set src in range(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(!paperamount)
		balloon_alert(usr, "пусто!")
		return

	empty_bin(usr)

/obj/machinery/papershredder/proc/empty_bin(mob/living/user, obj/item/storage/empty_into)

	// Sanity.
	if(empty_into && !istype(empty_into))
		empty_into = null

	if(empty_into && empty_into.contents.len >= empty_into.storage_slots)
		balloon_alert(user, "нет места!")
		return

	var/atom/drop_loc = drop_location()
	while(paperamount)
		var/obj/item/shredded_paper/SP = get_shredded_paper(drop_loc)
		if(!SP)
			break
		if(empty_into)
			empty_into.handle_item_insertion(SP)
			if(empty_into.contents.len >= empty_into.storage_slots)
				break
	if(empty_into)
		if(paperamount)
			to_chat(user, span_notice("Вы заполняете [empty_into.declent_ru(ACCUSATIVE)] стольким количеством растерзанной бумаги, сколько [genderize_ru(empty_into.gender, "он", "она", "оно", "они")] мо[pluralize_ru(empty_into.gender, "жет", "гут")] вместить."))
		else
			to_chat(user, span_notice("Вы опустошаете [declent_ru(ACCUSATIVE)] в [empty_into.declent_ru(ACCUSATIVE)]."))
	else
		to_chat(user, span_notice("Вы опустошаете [declent_ru(ACCUSATIVE)]."))
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/papershredder/proc/get_shredded_paper(atom/location)
	if(!paperamount)
		return
	if(!location)
		location = drop_location()
	paperamount--
	return new /obj/item/shredded_paper(location)


/obj/machinery/papershredder/update_icon_state()
	icon_state = "papershredder[clamp(round(paperamount/3), 0, 5)]"


/obj/item/shredded_paper/attackby(obj/item/I, mob/living/user, params)
	if(resistance_flags & ON_FIRE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.get_heat())
		add_fingerprint(user)
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(
				span_warning("[user] случайно поджигает себя!"),
				span_userdanger("Вы промахиваетесь по куче разорванной бумаги и случайно поджигаете себя!")
			)
			user.drop_item_ground(I)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return ATTACK_CHAIN_BLOCKED_ALL

		user.drop_item_ground(src)
		user.visible_message(
			span_danger("[user] burns right through [src], turning it to ash. It flutters through the air before settling on the floor in a heap."),
			span_danger("You burn right through [src], turning it to ash. It flutters through the air before settling on the floor in a heap."),
		)
		fire_act()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/shredded_paper
	name = "shredded paper"
	desc = "Куча разорванной бумаги."
	gender = MALE
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredded_paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	layer = 4
	max_integrity = 25
	throw_range = 3
	throw_speed = 2

/obj/item/shredded_paper/get_ru_names()
	return list(
		NOMINATIVE = "измельчённая бумага",
		GENITIVE = "измельчённой бумаги",
		DATIVE = "измельчённой бумаге",
		ACCUSATIVE = "измельчённую бумагу",
		INSTRUMENTAL = "измельчонной бумагой",
		PREPOSITIONAL = "измельчённой бумаге"
	)

/obj/item/shredded_paper/Initialize(mapload)
	. = ..()
	if(prob(65)) color = pick("#7c7c7c","#e7e4e4", "#aeacc9")
