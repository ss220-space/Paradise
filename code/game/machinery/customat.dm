// Vendor flick sequence bitflags
/// Machine is not using vending/denying overlays
#define FLICK_NONE 0
/// Machine is currently vending wares, and will not update its icon, unless its stat change.
#define FLICK_VEND 1
/// Machine is currently denying wares, and will not update its icon, unless its stat change.
#define FLICK_DENY 2


// !! Не забыть поудалять старые комментарии и сделать свои
// ! Добавить звуки и сообщения разным взаимодействиям с автоматом


/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/customat_product
	name = "generic"
	///How many of this product we currently have
	var/amount = 0
	var/key = "generic_0"
	var/list/obj/item/containtment = list()
	var/price = 0  // Price to buy one
	var/icon = ""

/datum/data/customat_product/New(obj/item/I)
	name = I.name
	amount = 0
	containtment = list()
	price = 0
	icon = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1, FALSE))]"


/obj/machinery/customat
	name = "\improper Customat"
	desc = "Торговый автомат с кастомным содержимым."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic_off"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	max_integrity = 600 // base vending integrity * 2
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70) // base vending protection
	resistance_flags = FIRE_PROOF

	// All the overlay controlling variables
	/// Overlay of vendor maintenance panel.
	var/panel_overlay = ""
	/// Overlay of a vendor screen, will not apply of stat is NOPOWER.
	var/screen_overlay = ""
	/// Lightmask used when vendor is working properly.
	var/lightmask_overlay = ""
	/// Damage overlay applied if vendor is damaged enough.
	var/broken_overlay = ""
	/// Special lightmask for broken overlay. If vendor is BROKEN, but not dePOWERED we will see this, instead of `lightmask_overlay`.
	var/broken_lightmask_overlay = ""
	/// Overlay applied when machine is vending goods.
	var/vend_overlay = ""
	/// Special lightmask that will override default `lightmask_overlay`, while machine is vending goods.
	var/vend_lightmask = ""
	/// Amount of time until vending sequence is reseted.
	var/vend_overlay_time = 5 SECONDS
	/// Overlay applied when machine is denying its wares.
	var/deny_overlay = ""
	/// Special lightmask that will override default `lightmask_overlay`, while machine is denying its wares.
	var/deny_lightmask = ""
	/// Amount of time until denying sequence is reseted.
	var/deny_overlay_time = 1.5 SECONDS
	/// Flags used to correctly manipulate with vend/deny sequences.
	var/flick_sequence = FLICK_NONE
	/// If `TRUE` machine will only react to BROKEN/NOPOWER stat, when updating overlays.
	var/skip_non_primary_icon_updates = FALSE

	// Power
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/vend_power_usage = 150

	// Vending-related
	/// No sales pitches if off
	var/active = TRUE
	/// If off, vendor is busy and unusable until current action finishes
	var/vend_ready = TRUE
	/// How long vendor takes to vend one item.
	var/vend_delay = 1 SECONDS
	/// Item currently being bought
	var/datum/data/customat_product/currently_vending = null


	// Stuff relating vocalizations
	/// List of slogans the vendor will say, optional
	var/list/ads_list = list("Купи самый дорогой предмет из моего содержимого! Не пожалеешь!",
	"Мое содержимое разнообразней чем вся твоя жизнь!",
	"У меня богатый внутренний мир.",
	"Во мне может быть что угодно.",
	"Не ядерный ли это диск во мне продается, всего за 1984 кредита?",
	"Не хочешь платить за содержимое? Сломай меня и получи все бесплатно!",
	"Товары на любой вкус и цвет!",
	"Может во мне продается контробанда?",
	"Не нравится мое содержимое? Создай свой кастомат, со своим уникальным содержимым!",
	"Каждый раз, когда вы что-то покупаете, где-то в мире радуется один ассистент!")

	var/list/vend_reply	= list("Спасибо за покупку, приходите еще!",
	"Вы купили что-то, а разнообразие моего содержимого не уменьшилось!",
	"Ваши кредиты пойдут на разработку новых уникальных товаров!",
	"Спасибо что выбрали нас!",
	"А ведь мог сломать и не платить...")

	/// If true, prevent saying sales pitches
	var/shut_up = FALSE
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 600 SECONDS		//How long until we can pitch again?
	var/reply_delay = 20 SECONDS

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/canister = null
	var/obj/item/vending_refill/refill_canister = /obj/item/vending_refill/custom

	// Things that can go wrong
	/// Allows people to access a vendor that's normally access restricted.
	emagged = 0

	var/scan_id = TRUE

	/// blocks further flickering while true
	var/flickering = FALSE
	/// do I look unpowered, even when powered?
	var/force_no_power_icon_state = FALSE

	var/light_range_on = 1
	var/light_power_on = 0.5

	var/list/remembered_costs = list("akula plushie" = 666) // Why not?
	var/obj/item/card/id/connected_id = null
	var/fast_insert = FALSE

	// To be filled out at compile time
	var/list/products = list()

	var/inserted_items_count = 0
	var/max_items_inside = 50

/obj/machinery/customat/Initialize(mapload)
	. = ..()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new
	V.set_type(replacetext(initial(name), "\improper", ""))
	component_parts += V
	canister = new /obj/item/vending_refill/custom
	component_parts += canister
	RefreshParts()

	update_icon(UPDATE_OVERLAYS)

/obj/machinery/customat/proc/eject_all()
	for (var/datum/data/customat_product/product in products)
		for (var/obj/item/I in product.containtment)
			I.forceMove(get_turf(src))
		product.amount = 0
		inserted_items_count -= product.containtment.len
		product.containtment = list()

/obj/machinery/customat/Destroy()
	eject_all()
	return ..()

/obj/machinery/customat/update_icon(updates = ALL)
	if(skip_non_primary_icon_updates && !(stat & (NOPOWER|BROKEN)))
		return ..(NONE)
	return ..()


/obj/machinery/customat/update_overlays()
	. = ..()

	underlays.Cut()

	if((stat & NOPOWER) || force_no_power_icon_state)
		if(broken_overlay && (stat & BROKEN))
			. += broken_overlay

		if(panel_overlay && panel_open)
			. += panel_overlay
		return

	if(stat & BROKEN)
		if(broken_overlay)
			. += broken_overlay
		if(broken_lightmask_overlay)
			underlays += emissive_appearance(icon, broken_lightmask_overlay, src)
		if(panel_overlay && panel_open)
			. += panel_overlay
		return

	if(screen_overlay)
		. += screen_overlay

	var/lightmask_used = FALSE
	if(vend_overlay && (flick_sequence & FLICK_VEND))
		. += vend_overlay
		if(vend_lightmask)
			lightmask_used = TRUE
			. += vend_lightmask

	else if(deny_overlay && (flick_sequence & FLICK_DENY))
		. +=  deny_overlay
		if(deny_lightmask)
			lightmask_used = TRUE
			. += deny_lightmask

	if(!lightmask_used && lightmask_overlay)
		underlays += emissive_appearance(icon, lightmask_overlay, src)

	if(panel_overlay && panel_open)
		. += panel_overlay


/obj/machinery/customat/power_change(forced = FALSE)
	. = ..()
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(light_range_on, light_power_on, l_on = TRUE)
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/customat/extinguish_light(force = FALSE)
	if(light_on)
		set_light_on(FALSE)
		underlays.Cut()


/obj/machinery/customat/proc/flick_vendor_overlay(flick_flag = FLICK_NONE)
	if(flick_sequence & (FLICK_VEND|FLICK_DENY))
		return
	if((flick_flag & FLICK_VEND) && !vend_overlay)
		return
	if((flick_flag & FLICK_DENY) && !deny_overlay)
		return
	flick_sequence = flick_flag
	update_icon(UPDATE_OVERLAYS)
	skip_non_primary_icon_updates = TRUE
	var/flick_time = (flick_flag & FLICK_VEND) ? vend_overlay_time : (flick_flag & FLICK_DENY) ? deny_overlay_time : 0
	addtimer(CALLBACK(src, PROC_REF(flick_reset)), flick_time)


/obj/machinery/customat/proc/flick_reset()
	skip_non_primary_icon_updates = FALSE
	flick_sequence = FLICK_NONE
	update_icon(UPDATE_OVERLAYS)


/*
 * Reimp, flash the screen on and off repeatedly.
 */
/obj/machinery/customat/flicker()
	if(flickering)
		return FALSE

	if(stat & (BROKEN|NOPOWER))
		return FALSE

	flickering = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/customat, flicker_event))

	return TRUE

/*
 * Proc to be called by invoke_async in the above flicker() proc.
 */
/obj/machinery/customat/proc/flicker_event()
	var/amount = rand(5, 15)

	for(var/i in 1 to amount)
		force_no_power_icon_state = TRUE
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 3))

		force_no_power_icon_state = FALSE
		update_icon(UPDATE_OVERLAYS)
		sleep(rand(1, 10))
	update_icon(UPDATE_OVERLAYS)
	flickering = FALSE

/obj/machinery/customat/deconstruct(disassembled = TRUE)
	if(!canister) //the non constructable vendors drop metal instead of a machine frame.
		new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/customat/proc/idcard_act(mob/user, obj/item/I)
	if (!connected_id)
		connected_id = I
		balloon_alert(user, "Автомат заблокирован.")
	else if (connected_id == I)
		connected_id = null
		balloon_alert(user, "Автомат разблокирован.")
	else
		balloon_alert(user, "Карта не подходит.")

/obj/machinery/customat/proc/get_key(obj/item/I, cost)
	return I.name + "_[cost]"

/obj/machinery/customat/proc/insert(mob/user, obj/item/I, cost)
	if (inserted_items_count == max_items_inside)
		return
	remembered_costs[I.name] = cost
	var/key = get_key(I, cost)
	if(!user.drop_transfer_item_to_loc(I, src))
		to_chat(usr, span_warning("Вы не можете положить это внутрь."))
		return
	if (!(key in products))
		var/datum/data/customat_product/product = new /datum/data/customat_product(I)
		product.price = cost
		product.key = key
		products[key] = product

	var/datum/data/customat_product/product = products[key]
	product.containtment += I
	product.amount++
	inserted_items_count++

/obj/machinery/customat/proc/try_insert(mob/user, obj/item/I, from_tube = FALSE)
	var/cost = 100
	if (fast_insert || from_tube)
		if (I.name in remembered_costs)
			cost = remembered_costs[I.name]
	else
		var/new_cost = input("Пожалуйста, выберите цену для этого товара. Цена не может быть ниже 0 и выше 1000000 кредитов.", "Выбор цены", 0) as null|num
		if(new_cost)
			cost = clamp(new_cost, 0, 1000000)
	if (get_dist(get_turf(user), get_turf(src)) > 1)
		to_chat(usr, span_warning("Вы слишком далеко!"))
		return
	insert(user, I, cost)

/obj/machinery/customat/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if (panel_open)
		if (istype(I, /obj/item/card/id))
			idcard_act(user, I)
			return ATTACK_CHAIN_BLOCKED_ALL
		else
			try_insert(user, I)
			return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		playsound(src, 'sound/machines/burglar_alarm.ogg', I.force * 5, 0)
	return ..()


/obj/machinery/customat/crowbar_act(mob/user, obj/item/I)
	if(!component_parts)
		return
	. = TRUE
	eject_all()
	default_deconstruction_crowbar(user, I)

/obj/machinery/customat/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		panel_open = !panel_open
		panel_open ? SCREWDRIVER_OPEN_PANEL_MESSAGE : SCREWDRIVER_CLOSE_PANEL_MESSAGE
		update_icon()
		SStgui.update_uis(src)

/obj/machinery/customat/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 60)

/obj/machinery/customat/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if(!W.works_from_distance)
		return FALSE
	if(!component_parts || !canister)
		return FALSE

	var/moved = 0
	if(panel_open || W.works_from_distance)
		if(W.works_from_distance)
			to_chat(user, display_parts(user))
	else
		to_chat(user, display_parts(user))
	if(moved)
		to_chat(user, "[moved] items restocked.")
		W.play_rped_sound()
	return TRUE

/obj/machinery/customat/emag_act(mob/user)
	emagged = TRUE
	if(user)
		to_chat(user, "You short out the product lock on [src]")

/obj/machinery/customat/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/customat/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/customat/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/customat/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Customat",  name)
		ui.open()

/obj/machinery/customat/ui_data(mob/user)
	var/list/data = list()
	var/datum/money_account/account = null
	data["guestNotice"] = "Идентификационной карты не обнаружено.";
	data["userMoney"] = 0
	data["products"] = products
	data["user"] = null
	if(issilicon(user) && !istype(user, /mob/living/silicon/robot/drone) && !istype(user, /mob/living/silicon/pai))
		account = get_card_account(user)
		data["user"] = list()
		data["user"]["name"] = account.owner_name
		data["userMoney"] = account.money
		data["user"]["job"] = "Silicon"
	if(ishuman(user))
		account = get_card_account(user)
		var/mob/living/carbon/human/H = user
		var/obj/item/stack/spacecash/S = H.get_active_hand()
		if(istype(S))
			data["userMoney"] = S.amount
			data["guestNotice"] = "Accepting Cash. You have: [S.amount] credits."
		else if(istype(H))
			var/obj/item/card/id/idcard = H.get_id_card()
			if(istype(account))
				data["user"] = list()
				data["user"]["name"] = account.owner_name
				data["userMoney"] = account.money
				data["user"]["job"] = (istype(idcard) && idcard.rank) ? idcard.rank : "No Job"
			else
				data["guestNotice"] = "Unlinked ID detected. Present cash to pay.";
	data["stock"] = list()
	for (var/datum/data/customat_product/product in products)
		data["stock"][product.key] = product.amount
	data["icons"] = list()
	for (var/datum/data/customat_product/product in products)
		var/obj/item/I = product.containtment[1]
		data["icons"][product.key] = product.icon
	data["vend_ready"] = vend_ready
	data["panel_open"] = panel_open ? TRUE : FALSE
	data["speaker"] = shut_up ? FALSE : TRUE
	return data


/obj/machinery/customat/ui_static_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/customat/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(issilicon(usr) && !isrobot(usr))
		to_chat(usr, span_warning("The vending machine refuses to interface with you, as you are not in its target demographic!"))
		return
	switch(action)
		if("toggle_voice")
			if(panel_open)
				shut_up = !shut_up
				. = TRUE
		if("vend")
			if(!vend_ready)
				to_chat(usr, span_warning("The vending machine is busy!"))
				return
			if(panel_open)
				to_chat(usr, span_warning("The vending machine cannot dispense products while its service panel is open!"))
				return
			var/key = text2num(params["key"])
			var/datum/data/customat_product/product = products[key]
			if(!istype(product))
				to_chat(usr, span_warning("ERROR: unknown vending_product record. Report this bug."))
				return
			var/list/record_to_check = products
			if(!product || !istype(product) || !product.key)
				to_chat(usr, span_warning("ERROR: unknown product record. Report this bug."))
				return
			else if (!(product in record_to_check))
				// Exploit prevention, stop the user
				message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
				return
			if (product.amount <= 0)
				to_chat(usr, "Sold out of [product.name].")
				flick_vendor_overlay(FLICK_VEND)
				return

			vend_ready = FALSE // From this point onwards, vendor is locked to performing this transaction only, until it is resolved.

			if(!(ishuman(usr) || issilicon(usr)) || product.price <= 0)
				// Either the purchaser is not human nor silicon, or the item is free.
				// Skip all payment logic.
				vend(product, usr)
				add_fingerprint(usr)
				vend_ready = TRUE
				. = TRUE
				return

			// --- THE REST OF THIS PROC IS JUST PAYMENT LOGIC ---
			if(!GLOB.vendor_account || GLOB.vendor_account.suspended)
				to_chat(usr, "Vendor account offline. Unable to process transaction.")
				flick_vendor_overlay(FLICK_DENY)
				vend_ready = TRUE
				return

			currently_vending = product
			var/paid = FALSE

			if(istype(usr.get_active_hand(), /obj/item/stack/spacecash))
				var/obj/item/stack/spacecash/S = usr.get_active_hand()
				paid = pay_with_cash(S, usr, currently_vending.price, currently_vending.name)
			else if(get_card_account(usr))
				// Because this uses H.get_id_card(), it will attempt to use:
				// active hand, inactive hand, wear_id, pda, and then w_uniform ID in that order
				// this is important because it lets people buy stuff with someone else's ID by holding it while using the vendor
				paid = pay_with_card(usr, currently_vending.price, currently_vending.name)
			else if(usr.can_advanced_admin_interact())
				to_chat(usr, span_notice("Vending object due to admin interaction."))
				paid = TRUE
			else
				to_chat(usr, span_warning("Payment failure: you have no ID or other method of payment."))
				vend_ready = TRUE
				flick_vendor_overlay(FLICK_DENY)
				. = TRUE // we set this because they shouldn't even be able to get this far, and we want the UI to update.
				return
			if(paid)
				vend(currently_vending, usr)
				. = TRUE
			else
				to_chat(usr, span_warning("Payment failure: unable to process payment."))
				vend_ready = TRUE
	if(.)
		add_fingerprint(usr)




/obj/machinery/customat/proc/vend(datum/data/customat_product/product, mob/user)
	if(!allowed(user) && !user.can_admin_interact() && !emagged && scan_id)
		balloon_alert(user, "Access denied.")
		flick_vendor_overlay(FLICK_DENY)
		vend_ready = TRUE
		return

	if(!product.amount)
		to_chat(user, span_warning("В автомате не осталось содержимого."))
		vend_ready = TRUE
		return

	vend_ready = FALSE //One thing at a time!!

	product.amount--

	if(((last_reply + (vend_delay + reply_delay)) <= world.time) && vend_reply)
		speak(pick(src.vend_reply))
		last_reply = world.time

	use_power(vend_power_usage)	//actuators and stuff
	flick_vendor_overlay(FLICK_VEND)	//Show the vending animation if needed
	playsound(get_turf(src), 'sound/machines/machine_vend.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(delayed_vend), product, user), vend_delay)


/obj/machinery/customat/proc/delayed_vend(datum/data/customat_product/product, mob/user)
	do_vend(product, user)
	vend_ready = TRUE
	currently_vending = null


/**
 * Override this proc to add handling for what to do with the vended product
 * when you have a inserted item and remember to include a parent call for this generic handling
 */
/obj/machinery/customat/proc/do_vend(datum/data/customat_product/product, mob/user)
	var/put_on_turf = TRUE
	var/obj/item/vended = product.containtment[1]
	if(istype(vended) && user && iscarbon(user) && user.Adjacent(src))
		if(user.put_in_hands(vended, ignore_anim = FALSE))
			put_on_turf = FALSE
	if(put_on_turf)
		var/turf/T = get_turf(src)
		vended.forceMove(T)
	product.containtment.Remove(product.containtment[1])
	return TRUE

/obj/machinery/customat/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	//Pitch to the people!  Really sell it!
	if(((last_slogan + src.slogan_delay) <= world.time) && (LAZYLEN(ads_list)) && (!shut_up) && prob(5))
		var/slogan = pick(src.ads_list)
		speak(slogan)
		last_slogan = world.time


/obj/machinery/customat/proc/speak(message)
	if(stat & NOPOWER)
		return
	if(!message)
		return

	atom_say(message)


/obj/machinery/customat/obj_break(damage_flag)
	if(stat & BROKEN)
		return

	stat |= BROKEN
	update_icon(UPDATE_OVERLAYS)

#undef FLICK_NONE
#undef FLICK_VEND
#undef FLICK_DENY
