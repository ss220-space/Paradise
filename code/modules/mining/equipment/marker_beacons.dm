/*****************Marker Beacons**************************/
GLOBAL_LIST_INIT(marker_beacon_colors, list(
"Random" = FALSE, //not a true color, will pick a random color
"Burgundy" = LIGHT_COLOR_FLARE,
"Bronze" = LIGHT_COLOR_ORANGE,
"Yellow" = LIGHT_COLOR_DIM_YELLOW,
"Lime" = LIGHT_COLOR_SLIME_LAMP,
"Olive" = LIGHT_COLOR_GREEN,
"Jade" = LIGHT_COLOR_BLUEGREEN,
"Teal" = LIGHT_COLOR_LIGHT_CYAN,
"Cerulean" = LIGHT_COLOR_BLUE,
"Indigo" = LIGHT_COLOR_DARK_BLUE,
"Purple" = LIGHT_COLOR_PURPLE,
"Violet" = LIGHT_COLOR_LAVENDER,
"Fuchsia" = LIGHT_COLOR_PINK))

/obj/item/stack/marker_beacon
	name = "marker beacon"
	singular_name = "marker beacon"
	desc = "Устройства освещения пути. Используются шахтёрами для разметки маршрутов и обозначения опасностей."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "marker"
	armor = list(MELEE = 50, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 25, BIO = 100, RAD = 100, FIRE = 25, ACID = 0)
	max_integrity = 50
	merge_type = /obj/item/stack/marker_beacon
	max_amount = 100
	var/picked_color = "random"

/obj/item/stack/marker_beacon/get_ru_names()
	return list(
		NOMINATIVE = "маркерный маячок",
		GENITIVE = "маркерного маячка",
		DATIVE = "маркерному маячку",
		ACCUSATIVE = "маркерный маячок",
		INSTRUMENTAL = "маркерным маячком",
		PREPOSITIONAL = "маркерном маячке"
	)

/obj/item/stack/marker_beacon/ten //miners start with 10 of these
	amount = 10

/obj/item/stack/marker_beacon/thirty //and they're bought in stacks of 1, 10, or 30
	amount = 30

/obj/item/stack/marker_beacon/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/marker_beacon/examine(mob/user)
	. = ..()
	. += span_notice("Используйте в руке, чтобы установить [declent_ru(ACCUSATIVE)].")
	. += span_notice("Alt-ЛКМ для выбора цвета. Текущий цвет: [picked_color].")

/obj/item/stack/marker_beacon/update_icon_state()
	icon_state = "[initial(icon_state)][lowertext(picked_color)]"

/obj/item/stack/marker_beacon/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, span_warning("Здесь недостаточно места для установки [declent_ru(GENITIVE)]."))
		return
	if(locate(/obj/structure/marker_beacon) in user.loc)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] уже установлен здесь."))
		return
	if(use(1))
		to_chat(user, span_notice("Вы активируете и закрепляете [declent_ru(ACCUSATIVE)] на месте."))
		playsound(user, 'sound/machines/click.ogg', 50, TRUE)
		var/obj/structure/marker_beacon/M = new(user.loc, picked_color)
		transfer_fingerprints_to(M)

/obj/item/stack/marker_beacon/click_alt(mob/living/user)
	var/input_color = tgui_input_list(user, "Выберите цвет", "Цвет маячка", GLOB.marker_beacon_colors)
	if(!Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return CLICK_ACTION_BLOCKING
	if(!input_color)
		return CLICK_ACTION_BLOCKING
	picked_color = input_color
	update_icon(UPDATE_ICON_STATE)
	return CLICK_ACTION_SUCCESS

/obj/structure/marker_beacon
	name = "marker beacon"
	desc = "Устройство освещения пути. Надёжно закреплено и светится ровным светом."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "marker"
	layer = BELOW_OPEN_DOOR_LAYER
	armor = list(MELEE = 50, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 25, BIO = 100, RAD = 100, FIRE = 25, ACID = 0)
	max_integrity = 50
	anchored = TRUE
	light_range = 2
	light_power = 3
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING
	var/remove_speed = 15
	var/picked_color

/obj/structure/marker_beacon/Initialize(mapload, set_color)
	. = ..()
	picked_color = set_color
	update_state()

/obj/structure/marker_beacon/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/obj/item/stack/marker_beacon/M = new(loc)
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
	qdel(src)

/obj/structure/marker_beacon/examine(mob/user)
	. = ..()
	. += span_notice("Alt-ЛКМ для выбора цвета. Текущий цвет: [picked_color].")


/obj/structure/marker_beacon/update_icon_state()
	while(!picked_color || !GLOB.marker_beacon_colors[picked_color])
		picked_color = pick(GLOB.marker_beacon_colors)
	icon_state = "[initial(icon_state)][lowertext(picked_color)]-on"


/obj/structure/marker_beacon/proc/update_state()
	update_icon(UPDATE_ICON_STATE)
	set_light(light_range, light_power, GLOB.marker_beacon_colors[picked_color])


/obj/structure/marker_beacon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated())
		to_chat(user, span_warning("Сейчас это невозможно!"))
		return
	to_chat(user, span_notice("Вы начинаете подбирать [declent_ru(ACCUSATIVE)]..."))
	if(do_after(user, remove_speed, src))
		var/obj/item/stack/marker_beacon/M = new(drop_location())
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
		transfer_fingerprints_to(M)
		user.put_in_hands(M, ignore_anim = FALSE)
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)


/obj/structure/marker_beacon/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/marker_beacon) && I != src)
		add_fingerprint(user)
		var/obj/item/stack/marker_beacon/beacon = I
		if(beacon.amount >= beacon.max_amount)
			to_chat(user, span_warning("Нет места."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы начинаете подбирать [declent_ru(ACCUSATIVE)]..."))
		if(!do_after(user, remove_speed, src) || beacon.amount >= beacon.max_amount)
			return ATTACK_CHAIN_PROCEED
		beacon.add(1)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/marker_beacon/click_alt(mob/living/user)
	var/input_color = tgui_input_list(user, "Выберите цвет", "Цвет маячка", GLOB.marker_beacon_colors)
	if(!Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return CLICK_ACTION_BLOCKING
	if(!input_color)
		return CLICK_ACTION_BLOCKING
	picked_color = input_color
	update_state()
	return CLICK_ACTION_SUCCESS
