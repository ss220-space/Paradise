///Beds

/obj/structure/bed
	name = "bed"
	desc = "Стандартная кровать, предназначенная для сна, отдыха или фиксации кого-либо. \
			Изготовлена из металлической рамы и мягкой обивки. Достаточно комфортная."
	ru_names = list(
		NOMINATIVE = "кровать",
		GENITIVE = "кровати",
		DATIVE = "кровати",
		ACCUSATIVE = "кровать",
		INSTRUMENTAL = "кроватью",
		PREPOSITIONAL = "кровати"
	)
	gender = FEMALE
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = TRUE
	anchored = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	layer = BELOW_OBJ_LAYER
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/comfort = 2 // default comfort


/obj/structure/bed/psych
	name = "psych bed"
	desc = "Специализированная кровать, предназначенная для использования во время психиатрического обследования. \
			Изготовлена из металлической рамы и мягкой обивки. Достаточно комфортная."
	ru_names = list(
		NOMINATIVE = "психиатрическая кровать",
		GENITIVE = "психиатрической кровати",
		DATIVE = "психиатрической кровати",
		ACCUSATIVE = "психиатрическую кровать",
		INSTRUMENTAL = "психиатрической кроватью",
		PREPOSITIONAL = "психиатрической кровати"
	)
	icon_state = "psychbed"
	buildstackamount = 5

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "Необычная приспособление, напоминающее кровать. \
			Выполнено из неизвестного сплава. Выглядит ужасно некомфортно. \
			Судя по всему, это продукт неизвестной галактическому сообществу разумной цивилизации."
	ru_names = list(
		NOMINATIVE = "устройство для отдыха",
		GENITIVE = "устройства для отдыха",
		DATIVE = "устройству для отдыха",
		ACCUSATIVE = "устройство для отдыха",
		INSTRUMENTAL = "устройством для отдыха",
		PREPOSITIONAL = "устройстве для отдыха"
	)
	gender = NEUTER
	icon_state = "abed"
	comfort = 0.3

/obj/structure/bed/sandstone
	name = "sandstone plate"
	desc = "Массивная плита из песчаника, установленная горизонтально для использования в качестве ложа. \
			Достаточно комфортная, хотя таковой совершенно не кажется. Интересно, кто вообще спит на таких?"
	ru_names = list(
		NOMINATIVE = "плита из песчаника",
		GENITIVE = "плити из песчаника",
		DATIVE = "плите из песчаника",
		ACCUSATIVE = "плиту из песчаника",
		INSTRUMENTAL = "плитой из песчаника",
		PREPOSITIONAL = "плите из песчаника"
	)
	icon_state = "bed_sand"
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	buildstacktype = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 15

/obj/structure/bed/old
	name = "old bed"
	desc = "Старая кровать. Судя по внешнему виду, ей не один десяток лет. От одного только взгляда на торчащие из неё пружины начинает ныть спина..."
	ru_names = list(
		NOMINATIVE = "старая кровать",
		GENITIVE = "старой кровати",
		DATIVE = "старой кровати",
		ACCUSATIVE = "старую кровать",
		INSTRUMENTAL = "старой кроватью",
		PREPOSITIONAL = "старой кровати"
	)
	icon_state = "catwalkcouch1"
	comfort = 0

/obj/structure/bed/wicker
	name = "wicker bed"
	desc = "Большая кровать, сотканная из плотного переплетённого материала. \
			Относительно комфортная, хотя и значительно отстаёт от своих современных аналогов."
	ru_names = list(
		NOMINATIVE = "плетёная кровать",
		GENITIVE = "плетёной кровати",
		DATIVE = "плетёной кровати",
		ACCUSATIVE = "плетёную кровать",
		INSTRUMENTAL = "плетёной кроватью",
		PREPOSITIONAL = "плетёной кровати"
	)
	icon_state = "wicker_bed"
	comfort = 1.5
	buildstacktype = /obj/item/stack/sheet/cloth
	buildstackamount = 5

/obj/structure/bed/leather
	name = "leather bed"
	desc = "Куски кожи, грубо сшитые друг с другом и прикреплённые к деревянной раме. \
			Не очень то и комфортная, но всё ещё лучше, чем ничего."
	ru_names = list(
		NOMINATIVE = "кровать из кожи",
		GENITIVE = "кровати из кожи",
		DATIVE = "кровати из кожи",
		ACCUSATIVE = "кровать из кожи",
		INSTRUMENTAL = "кроватью из кожи",
		PREPOSITIONAL = "кровати из кожи"
	)
	icon_state = "leather_bed"
	comfort = 1.2
	buildstacktype = /obj/item/stack/sheet/leather
	buildstackamount = 2

/obj/structure/bed/wooden
	name = "wooden bed"
	desc = "Кровать, выполненная из натурального дерева с аккуратной отделкой. \
			в плане комфорта и удобства превосходит современные аналоги с металлическим каркасом. \
			От неё веет каким-то домашнию уютом..."
	ru_names = list(
		NOMINATIVE = "деревянная кровать",
		GENITIVE = "деревянной кровати",
		DATIVE = "деревянной кровати",
		ACCUSATIVE = "деревянную кровать",
		INSTRUMENTAL = "деревянной кроватью",
		PREPOSITIONAL = "деревянной кровати"
	)
	icon_state = "wooden_bed"
	comfort = 2.5
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 5

/obj/structure/bed/proc/handle_rotation()
	return

/obj/structure/bed/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(obj_flags & NODECONSTRUCT)
		user.balloon_alert(user, "невозможно разобрать!")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc, buildstackamount)
	..()

/// Roller beds

/obj/structure/bed/roller
	name = "roller bed"
	desc = "Стандартная медицинская каталка, предназначенная для перемещения пациентов. \
			Может быть сложена для удобной транспортировки."
	ru_names = list(
		NOMINATIVE = "каталка",
		GENITIVE = "каталки",
		DATIVE = "каталке",
		ACCUSATIVE = "каталку",
		INSTRUMENTAL = "каталкой",
		PREPOSITIONAL = "каталке"
	)
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	resistance_flags = NONE
	anchored = FALSE
	comfort = 1
	pull_push_slowdown = 0	// used for transporting lying mobs
	var/icon_up = "up"
	var/icon_down = "down"
	var/folded = /obj/item/roller


/obj/structure/bed/roller/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/roller_holder))
		var/buckled_mobs = has_buckled_mobs()
		if(buckled_mobs)
			add_fingerprint(user)
			if(buckled_mobs > 1)
				unbuckle_all_mobs()
				user.balloon_alert(user, "пациент отцеплен")
			else
				user_unbuckle_mob(buckled_mobs[1], user)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		user.balloon_alert(user, "сложено")
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
	target.pixel_y = target.base_pixel_y + 3


/obj/structure/bed/roller/post_unbuckle_mob(mob/living/target)
	set_density(FALSE)
	update_icon(UPDATE_ICON_STATE)
	target.pixel_y = target.base_pixel_y + target.body_position_pixel_y_offset


/obj/structure/bed/roller/holo
	name = "holo stretcher"
	desc = "Голографическая медицинская каталка, \
			созданная на основе технологии твёрдого света. \
			Предназначена для перемещения пациентов. \
			Может быть сложена для удобной транспортировки."
	ru_names = list(
		NOMINATIVE = "голо-каталка",
		GENITIVE = "голо-каталки",
		DATIVE = "голо-каталке",
		ACCUSATIVE = "голо-каталку",
		INSTRUMENTAL = "голо-каталкой",
		PREPOSITIONAL = "голо-каталке"
	)
	icon_state = "holo_down"
	icon_up = "holo_up"
	icon_down = "holo_down"
	folded = /obj/item/roller/holo

/obj/item/roller
	name = "roller bed"
	desc = "Стандартная медицинская каталка, предназначенная для перемещения пациентов. \
			Может быть сложена для удобной транспортировки."
	ru_names = list(
		NOMINATIVE = "каталка",
		GENITIVE = "каталки",
		DATIVE = "каталке",
		ACCUSATIVE = "каталку",
		INSTRUMENTAL = "каталкой",
		PREPOSITIONAL = "каталке"
	)
	gender = FEMALE
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	/// Whether it can be picked up by roller holder
	var/collectable = TRUE
	var/extended = /obj/structure/bed/roller
	w_class = WEIGHT_CLASS_BULKY // Can't be put in backpacks.


/obj/item/roller/attack_self(mob/user)
	user.balloon_alert(user, "разложено")
	var/obj/structure/bed/roller/R = new extended(drop_location())
	R.add_fingerprint(user)
	qdel(src)


/obj/item/roller/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/roller_holder))
		var/obj/item/roller_holder/roller = I
		if(roller.held)
			user.balloon_alert(user, "уже имеется!")
			return ATTACK_CHAIN_PROCEED
		if(!collectable)
			user.balloon_alert(user, "неподходящая каталка!")
			return ATTACK_CHAIN_PROCEED
		if(loc == user && !user.can_unEquip(src))
			return ..()
		user.balloon_alert(user, "прикреплено к стойке")
		user.visible_message(span_notice("[user] веша[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)] на [I.declent_ru(ACCUSATIVE)]."))
		if(loc == user)
			user.transfer_item_to_loc(src, roller)
		else
			forceMove(roller)
		roller.held = src
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/bed/roller/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	var/mob/user = usr
	if(has_buckled_mobs())
		user.balloon_alert(user, "сначала отцепите пациента!")
		return FALSE
	if(over_object == usr && ishuman(usr) && !usr.incapacitated() && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) && usr.Adjacent(src))
		user.balloon_alert(user, "сложено")
		var/obj/item/folded_item = new folded(drop_location())
		folded_item.add_fingerprint(usr)
		qdel(src)
		return FALSE
	return ..()


/obj/item/roller/holo
	name = "holo stretcher"
	desc = "Голографическая медицинская каталка, \
			созданная на основе технологии твёрдого света. \
			Предназначена для перемещения пациентов. \
			Может быть сложена для удобной транспортировки."
	ru_names = list(
		NOMINATIVE = "голо-каталка",
		GENITIVE = "голо-каталки",
		DATIVE = "голо-каталке",
		ACCUSATIVE = "голо-каталку",
		INSTRUMENTAL = "голо-каталкой",
		PREPOSITIONAL = "голо-каталке"
	)
	icon_state = "holo_retracted"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=3;biotech=4;powerstorage=3"
	extended = /obj/structure/bed/roller/holo
	collectable = FALSE


/obj/item/roller_holder
	name = "roller bed rack"
	desc = "Стойка, предназначенная для крепления и транспортировки медицинской каталки."
	ru_names = list(
		NOMINATIVE = "стойка для каталки",
		GENITIVE = "стойки для каталки",
		DATIVE = "стойке для каталки",
		ACCUSATIVE = "стойку для каталки",
		INSTRUMENTAL = "стойкой для каталки",
		PREPOSITIONAL = "стойке для каталки"
	)
	gender = FEMALE
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
		user.balloon_alert(user, "пусто!")
		return

	user.balloon_alert(user, "каталка размещена")
	var/obj/structure/bed/roller/roller = new held.extended(drop_location())
	roller.add_fingerprint(user)
	QDEL_NULL(held)



/*
 * Dog beds
 */

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, just in case the gravity turns off."
	anchored = FALSE
	buildstackamount = 10
	buildstacktype = /obj/item/stack/sheet/wood
	comfort = 0.5

/obj/structure/bed/dogbed/ian
	name = "Ian's bed"
	desc = "Ian's bed! Looks comfy."
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/pet
	name = "Удобная лежанка"
	desc = "Комфортная лежанка для любимейшего питомца отдела."
	anchored = TRUE
