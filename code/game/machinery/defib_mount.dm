//Holds defibs and recharges them from the powernet
//You can activate the mount with an empty hand to grab the paddles
//Not being adjacent will cause the paddles to snap back
/obj/machinery/defibrillator_mount
	name = "defibrillator mount"
	desc = "Станция для хранения и зарядки дефибрилляторов. Вы можете использовать использовать дефибриллятор прямо отсюда, если оный имеется."
	ru_names = list(
		NOMINATIVE = "крепление для дефибриллятора",
		GENITIVE = "крепления для дефибриллятора",
		DATIVE = "креплению для дефибриллятора",
		ACCUSATIVE = "крепление для дефибриллятора",
		INSTRUMENTAL = "креплением для дефибриллятора",
		PREPOSITIONAL = "креплении для дефибриллятора"
	)
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	density = FALSE
	use_power = IDLE_POWER_USE
	anchored = TRUE
	idle_power_usage = 1
	power_channel = EQUIP
	req_access = list(ACCESS_MEDICAL, ACCESS_HEADS) //used to control clamps
	var/obj/item/defibrillator/defib //this mount's defibrillator
	var/clamps_locked = FALSE //if true, and a defib is loaded, it can't be removed without unlocking the clamps

/obj/machinery/defibrillator_mount/attack_ai()
	return

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

/obj/machinery/defibrillator_mount/New(location, direction, building = 0)
	..()

	if(location)
		loc = location

	if(direction)
		setDir(direction)

	if(building)
		set_pixel_offsets_from_dir(30, -30, 30, -30)

/obj/machinery/defibrillator_mount/loaded/Initialize(mapload)	//loaded subtype for mapping use
	. = ..()
	defib = new/obj/item/defibrillator/loaded(src)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/defibrillator_mount/Destroy()
	QDEL_NULL(defib)
	return ..()

/obj/machinery/defibrillator_mount/examine(mob/user)
	. = ..()
	if(defib)
		. += span_info("Используйте <b>Alt + ЛКМ</b>, чтобы взять прикреплённый дефибриллятор.")
		if(GLOB.security_level >= SEC_LEVEL_RED)
			. += span_notice("Автоматическа система блокировки активирована. Используйте любую ID-карту для разблокировки.")
		else
			. += span_notice("Вы можете активировать систему блокировки, использовав свою ID-карту.")

/obj/machinery/defibrillator_mount/process()
	if(defib && defib.cell && defib.cell.charge < defib.cell.maxcharge && is_operational())
		use_power(200)
		defib.cell.give(180) //90% efficiency, slightly better than the cell charger's 87.5%
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/defibrillator_mount/update_overlays()
	. = ..()
	if(defib)
		. += "defib"
		if(defib.powered)
			. += "[defib.safety ? "online" : "emagged"]"
			var/ratio = defib.cell.charge / defib.cell.maxcharge
			ratio = CEILING(ratio * 4, 1) * 25
			. += "charge[ratio]"
		if(clamps_locked)
			. += "clamps"


//defib interaction
/obj/machinery/defibrillator_mount/attack_hand(mob/living/carbon/human/user = usr)

	if(!defib)
		balloon_alert(user, "дефибриллятор отсутствует!")
		return

	if(!defib.paddles_on_defib)
		balloon_alert(user, "лопасти уже кем-то взяты!")
		return

	defib.dispence_paddles(user)
	add_fingerprint(user)


/obj/machinery/defibrillator_mount/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/defibrillator))
		add_fingerprint(user)
		if(defib)
			balloon_alert(user, "дефибриллятор уже установлен!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		visible_message(span_notice("[user] прикрепил[genderize_ru(user.gender, "", "а", "о", "и")] [I.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]!"))
		balloon_alert(user, "дефибриллятор установлен")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		defib = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(defib && I == defib.paddles)
		add_fingerprint(user)
		user.drop_item_ground(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.GetID())
		add_fingerprint(user)
		if(check_access(I) || GLOB.security_level >= SEC_LEVEL_RED) //anyone can toggle the clamps in red alert!
			if(!defib)
				balloon_alert(user, "дефибриллятор отсутствует!")
				return ATTACK_CHAIN_PROCEED
			clamps_locked = !clamps_locked
			balloon_alert(user, "блокировка [clamps_locked ? "" : "де"]активирована")
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		balloon_alert(user, "отказано в доступе!")
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/machinery/defibrillator_mount/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(defib)
		balloon_alert(user, "болты закрыты дефибриллятором!")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/defib_mount(get_turf(user))
	qdel(src)


/obj/machinery/defibrillator_mount/click_alt(mob/living/carbon/human/user)
	if(!defib)
		balloon_alert(user, "дефибриллятор отсутствует!")
		return CLICK_ACTION_BLOCKING
	var/obj/item/organ/external/hand_right = user.get_organ(BODY_ZONE_PRECISE_R_HAND)
	var/obj/item/organ/external/hand_left = user.get_organ(BODY_ZONE_PRECISE_L_HAND)
	if((!hand_right || !hand_right.is_usable()) && (!hand_left || !hand_left.is_usable()))
		balloon_alert(user, "невозможно!")
		return CLICK_ACTION_BLOCKING
	if(clamps_locked)
		balloon_alert(user, "заблокировано!")
		return CLICK_ACTION_BLOCKING
	defib.forceMove_turf()
	user.put_in_hands(defib, ignore_anim = FALSE)
	visible_message(span_notice("[user] вынима[pluralize_ru(user.gender, "ет", "ют")] [defib.declent_ru(ACCUSATIVE)] из [declent_ru(GENITIVE)]."))
	balloon_alert(user, "дефибриллятор извлечён")
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	defib = null
	update_icon(UPDATE_OVERLAYS)
	return CLICK_ACTION_SUCCESS


//wallframe, for attaching the mounts easily
/obj/item/mounted/frame/defib_mount
	name = "unhooked defibrillator mount"
	desc = "Крепление для дефибриллятора, которое предварительно нужно будет закрепить."
	ru_names = list(
		NOMINATIVE = "разобранное крепление для дефибриллятора",
		GENITIVE = "разобранного крепления для дефибриллятора",
		DATIVE = "разобранному креплению для дефибриллятора",
		ACCUSATIVE = "разобранное крепление для дефибриллятора",
		INSTRUMENTAL = "разобранным креплением для дефибриллятора",
		PREPOSITIONAL = "разобранном креплении для дефибриллятора"
	)
	icon = 'icons/obj/machines/defib_mount.dmi'
	icon_state = "defibrillator_mount"
	sheets_refunded = 0
	materials = list(MAT_METAL = 300, MAT_GLASS = 100)
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mounted/frame/defib_mount/do_build(turf/on_wall, mob/user)
	new /obj/machinery/defibrillator_mount(get_turf(src), get_dir(user, on_wall), 1)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	qdel(src)
