/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 *		Beds
 *		Roller stretchers
 *		Dog Beds
 */

/*
 * Beds
 */

/obj/structure/bed
	name = "bed"
	desc = "Нужна для того, чтобы полежать, поспать или привязать кого-нибудь."
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/comfort = 2 // default comfort
	/// Directions in which the bed has its headrest on the left side.
	var/left_headrest_dirs = NORTHEAST
	/// Mobs standing on it are nudged up by this amount. Also used to align the person back when buckled to it after init.
	var/elevation = 6
	var/allow_tucking = TRUE

/obj/structure/bed/psych
	name = "psych bed"
	desc = "Для максимального комфорта на психиатрическом обследовании."
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "Выглядит подозрительно похожей на земные кровати, неужели инопланетяне крадут наши технологии?"
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/sandstone
	name = "sandstone plate"
	desc = "При желании на ней можно уснуть."
	icon_state = "bed_sand"
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 15
	comfort = 0.5

/obj/structure/bed/old
	name = "old bed"
	desc = "Она выглядит крайне неудобной, и вы бы не хотели спать на такой."
	icon_state = "catwalkcouch1"
	comfort = 0

/obj/structure/bed/wicker
	name = "wicker bed"
	desc = "Большая кровать, сотканная из чего-то, напоминающего ткань. Выглядит достаточно удобно."
	icon_state = "wicker_bed"
	comfort = 1.5
	buildstacktype = /obj/item/stack/sheet/cloth
	buildstackamount = 5

/obj/structure/bed/wicker/get_ru_names()
	return alist(
		NOMINATIVE = "плетёная кровать",
		GENITIVE = "плетёной кровати",
		DATIVE = "плетёной кровати",
		ACCUSATIVE = "плетёную кровать",
		INSTRUMENTAL = "плетёной кроватью",
		PREPOSITIONAL = "плетёной кровати",
	)

/obj/structure/bed/leather
	name = "leather bed"
	desc = "Куски кожи, грубо сшитые друг с другом и прикреплённые к деревянной раме. Не самое удобное место для лежания."
	icon_state = "leather_bed"
	comfort = 1.2
	buildstacktype = /obj/item/stack/sheet/leather

/obj/structure/bed/leather/get_ru_names()
	return alist(
		NOMINATIVE = "кровать из кожи",
		GENITIVE = "кровати из кожи",
		DATIVE = "кровати из кожи",
		ACCUSATIVE = "кровать из кожи",
		INSTRUMENTAL = "кроватью из кожи",
		PREPOSITIONAL = "кровати из кожи",
	)

/obj/structure/bed/wooden
	name = "wooden bed"
	desc = "Кровать, сделанная из качественной древесины. Выглядит очень мило и уютно."
	icon_state = "wooden_bed"
	comfort = 2.5
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/bed/wooden/get_ru_names()
	return alist(
		NOMINATIVE = "деревянная кровать",
		GENITIVE = "деревянной кровати",
		DATIVE = "деревянной кровати",
		ACCUSATIVE = "деревянную кровать",
		INSTRUMENTAL = "деревянной кроватью",
		PREPOSITIONAL = "деревянной кровати",
	)

/obj/structure/bed/cardboard
	name = "cardboard bed"
	desc = "Лежанка, сделанная из картона. Ты что, бомж?"
	icon_state = "cardboard_bed"
	comfort = 0.1
	buildstacktype = /obj/item/stack/sheet/cardboard

/obj/structure/bed/cardboard/get_ru_names()
	return alist(
		NOMINATIVE = "лежанка из картона",
		GENITIVE = "лежанки из картона",
		DATIVE = "лежанке из картона",
		ACCUSATIVE = "лежанку из картона",
		INSTRUMENTAL = "лежанкой из картона",
		PREPOSITIONAL = "лежанке из картона",
	)

/obj/structure/bed/cardboard/wrench_act(mob/user, obj/item/wrench)
	return FALSE

/obj/structure/bed/cardboard/wirecutter_act(mob/user, obj/item/wirecutter)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		balloon_alert(user, "нельзя разобрать!")
		return
	if(!wirecutter.use_tool(src, user, 0, volume = wirecutter.tool_volume))
		return
	deconstruct(TRUE)


/obj/structure/bed/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/soft_landing)
	if(elevation)
		AddElement(/datum/element/elevation, pixel_shift = elevation)
	update_buckle_vars(dir)

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/wrench)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		balloon_alert(user, "нельзя разобрать!")
		return
	if(!wrench.use_tool(src, user, 0, volume = wrench.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()

/obj/structure/bed/setDir(newdir)
	. = ..()
	update_buckle_vars(newdir)

/obj/structure/bed/proc/update_buckle_vars(newdir)
	buckle_lying = newdir & left_headrest_dirs ? 270 : 90

/*
 * Roller stretcher
 */

/obj/structure/bed/roller
	name = "roller stretcher"
	desc = "Используется для транспортировки пациентов."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	pull_push_slowdown = 0	// used for transporting lying mobs
	allow_tucking = FALSE
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller

/obj/structure/bed/roller/get_ru_names()
	return alist(
		NOMINATIVE = "каталка",
		GENITIVE = "каталки",
		DATIVE = "каталке",
		ACCUSATIVE = "каталку",
		INSTRUMENTAL = "каталкой",
		PREPOSITIONAL = "каталке",
	)

/obj/structure/bed/roller/wrench_act(mob/user, obj/item/wrench)
	return FALSE

/obj/structure/bed/roller/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/roller_holder))
		var/buckled_mobs = has_buckled_mobs()
		if(buckled_mobs)
			add_fingerprint(user)
			if(buckled_mobs > 1)
				unbuckle_all_mobs()
				user.visible_message(
					span_notice("[user] отстёгивает всех от [declent_ru(GENITIVE)]."),
					span_notice("Вы отстегнули всех от [declent_ru(GENITIVE)]."),
				)
			else
				user_unbuckle_mob(buckled_mobs[1], user)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		user.visible_message(
			span_notice("[user] сложил[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы сложили [declent_ru(ACCUSATIVE)]."),
		)
		var/obj/item/folded_item = new folded(drop_location())
		transfer_fingerprints_to(folded_item)
		folded_item.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/bed/roller/update_icon_state()
	icon_state = has_buckled_mobs() ? icon_up : icon_down

/obj/structure/bed/roller/post_buckle_mob(mob/living/target)
	set_density(TRUE)
	update_icon(UPDATE_ICON_STATE)
	target.add_offsets(UID(), y_add = 10)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/target)
	set_density(FALSE)
	update_icon(UPDATE_ICON_STATE)
	target.remove_offsets(UID())

/obj/structure/bed/roller/holo
	name = "holo stretcher"
	desc = "Используется для транспортировки пациентов. Почему они не падают?"
	icon_state = "holo_down"
	icon_up = "holo_up"
	icon_down = "holo_down"
	folded = /obj/item/roller/holo

/obj/structure/bed/roller/holo/get_ru_names()
	return alist(
		NOMINATIVE = "носилки",
		GENITIVE = "носилок",
		DATIVE = "носилкам",
		ACCUSATIVE = "носилки",
		INSTRUMENTAL = "носилками",
		PREPOSITIONAL = "носилках",
	)

/obj/item/roller
	name = "roller stretcher"
	desc = "Это сложенная каталка на роликах. Её можно развернуть."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	interaction_flags_mouse_drop = NEED_DEXTERITY | NEED_HANDS
	/// Whether it can be picked up by roller holder
	var/collectable = TRUE
	var/extended = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_BULKY // Can't be put in backpacks.

/obj/item/roller/get_ru_names()
	return alist(
		NOMINATIVE = "каталка",
		GENITIVE = "каталки",
		DATIVE = "каталке",
		ACCUSATIVE = "каталку",
		INSTRUMENTAL = "каталкой",
		PREPOSITIONAL = "каталке",
	)

/obj/item/roller/attack_self(mob/user)
	var/obj/structure/bed/roller/roller = new extended(drop_location())
	roller.add_fingerprint(user)
	user.visible_message(
			span_notice("[user] разложил[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы разложили [declent_ru(ACCUSATIVE)]."),
		)
	qdel(src)

/obj/item/roller/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/roller_holder))
		var/obj/item/roller_holder/roller = item
		if(roller.held)
			balloon_alert(user, "уже есть каталка!")
			return ATTACK_CHAIN_PROCEED
		if(!collectable)
			balloon_alert(user, "неверный тип каталки!")
			return ATTACK_CHAIN_PROCEED
		if(loc == user && !user.can_unEquip(src))
			return ..()
		user.visible_message(
			span_notice("[user] собрал[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы собрали [declent_ru(ACCUSATIVE)]."),
		)
		if(loc == user)
			user.transfer_item_to_loc(src, roller)
		else
			forceMove(roller)
		roller.held = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/bed/roller/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(has_buckled_mobs() || over_object != user || !ishuman(user))
		return

	user.visible_message(
		span_notice("[user] собрал[GEND_A_O_I(user)] [declent_ru(NOMINATIVE)]."),
		span_notice("Вы собрали [declent_ru(NOMINATIVE)]."),
	)
	var/obj/item/folded_item = new folded(drop_location())
	folded_item.add_fingerprint(user)
	qdel(src)

/obj/item/roller/holo
	name = "holo stretcher"
	desc = "Это голографические носилки из твердого света? Их можно развернуть и носить с собой."
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo
	collectable = FALSE

/obj/item/roller/holo/get_ru_names()
	return alist(
		NOMINATIVE = "носилки",
		GENITIVE = "носилок",
		DATIVE = "носилкам",
		ACCUSATIVE = "носилки",
		INSTRUMENTAL = "носилками",
		PREPOSITIONAL = "носилках",
	)

/obj/item/roller_holder
	name = "roller stretcher rack"
	desc = "В нём можно перевозить сложенную каталку."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held = /obj/item/roller

/obj/item/roller_holder/Initialize(mapload)
	. = ..()
	if(ispath(held, /obj/item/roller))
		held = new held(src)

/obj/item/roller_holder/Destroy()
	QDEL_NULL(held)
	return ..()

/obj/item/roller_holder/attack_self(mob/user)
	if(!held)
		balloon_alert(user, "пуст!")
		return

	to_chat(user, span_notice("Вы разложили каталку."))
	var/obj/structure/bed/roller/roller = new held.extended(drop_location())
	roller.add_fingerprint(user)
	QDEL_NULL(held)

/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "Ваш питомец не потеряется, даже если гравитация отключится."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	comfort = 0.5
	elevation = 0

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Выглядит удобной."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	name = "Renault's bed"
	desc = "Выглядит, как производитель машин 21 века."
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	name = "Runtime's bed"
	desc = "Похожа на ошибку."
	anchored = TRUE

/obj/structure/bed/dogbed/pet
	name = "Удобная лежанка"
	desc = "Комфортная лежанка для любимейшего питомца отдела."
	anchored = TRUE
