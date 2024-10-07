// customat flick sequence bitflags
/// Machine is not using vending/denying overlays
#define FLICK_NONE 0
/// Machine is currently vending wares, and will not update its icon, unless its stat change.
#define FLICK_VEND 1
/// Machine is currently denying wares, and will not update its icon, unless its stat change.
#define FLICK_DENY 2



/**
 *  Datum used to hold information about a product in a vending machine
 */
/datum/data/customat_product
	name = "generic"
	///How many of this product we currently have
	var/amount = 0
	///The key by which the object is pushed into the machine's row
	var/key = "generic_0"
	///List of items in row
	var/list/obj/item/containtment = list()
	/// Price to buy one
	var/price = 0
	///Icon in tgui
	var/icon = ""

/datum/data/customat_product/New(obj/item/I)
	name = I.name
	amount = 0
	containtment = list()
	price = 0
	icon = icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1, FALSE))


/obj/machinery/customat
	name = "\improper Customat"
	desc = "Торговый автомат с кастомным содержимым."
	icon = 'icons/obj/machines/customat.dmi'
	icon_state = "custommate-off"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	max_integrity = 600 // base vending integrity * 2
	armor = list(melee = 20, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70) // base vending protection
	resistance_flags = FIRE_PROOF

	// All the overlay controlling variables
	/// Overlay of customat maintenance panel.
	var/panel_overlay = "custommate-panel"
	/// Overlay of a customat screen, will not apply of stat is NOPOWER.
	var/screen_overlay = "custommate"
	/// Lightmask used when customat is working properly.
	var/lightmask_overlay = ""
	/// Damage overlay applied if customat is damaged enough.
	var/broken_overlay = "custommate-broken"
	/// Special lightmask for broken overlay. If customat is BROKEN, but not dePOWERED we will see this, instead of `lightmask_overlay`.
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

	// Power
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	/// Power used for one vend
	var/vend_power_usage = 150

	// Vending-related
	/// No sales pitches if off
	var/active = TRUE
	/// If off, customat is busy and unusable until current action finishes
	var/vend_ready = TRUE
	/// How long customat takes to vend one item.
	var/vend_delay = 1 SECONDS
	/// Item currently being bought
	var/datum/data/customat_product/currently_vending = null


	// Stuff relating vocalizations
	/// List of slogans the customat will say, optional
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

	/// List of replies the customat will say after vends
	var/list/vend_reply	= list("Спасибо за покупку, приходите еще!",
	"Вы купили что-то, а разнообразие моего содержимого не уменьшилось!",
	"Ваши кредиты пойдут на разработку новых уникальных товаров!",
	"Спасибо что выбрали нас!",
	"А ведь мог сломать и не платить...")

	/// If true, prevent saying sales pitches
	var/shut_up = FALSE
	var/last_reply = 0
	var/reply_delay = 20 SECONDS
	COOLDOWN_DECLARE(reply_cooldown)
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 600 SECONDS		//How long until we can pitch again?
	COOLDOWN_DECLARE(slogan_cooldown)
	var/alarm_delay = 10 SECONDS
	COOLDOWN_DECLARE(alarm_cooldown)

	///The type of refill canisters used by this machine.
	var/obj/item/vending_refill/custom/canister = null
	/// Type of canister used to build it
	var/obj/item/vending_refill/refill_canister = /obj/item/vending_refill/custom // we need it for req_components of vendomat circuitboard

	// Things that can go wrong
	/// Makes all prices 0
	emagged = 0

	/// blocks further flickering while true
	var/flickering = FALSE
	/// do I look unpowered, even when powered?
	var/force_no_power_icon_state = FALSE

	var/light_range_on = 1
	var/light_power_on = 0.5

	/// Last costs of inserted types of items
	var/list/remembered_costs = list("akula plushie" = 666) // Why not?
	/// ID that was used to block customat
	var/obj/item/card/id/connected_id = null // Id that was used to block src
	// If true, price will be equal last prict of the same item
	var/fast_insert = TRUE // If true, new price of inserted item will be equal previous price of the same item

	/// Map of {key; customat_product}
	var/list/products = list()

	var/inserted_items_count = 0
	var/max_items_inside = 60

	COOLDOWN_DECLARE(emp_cooldown)
	var/weak_emp_cooldown = 60 SECONDS
	var/strong_emp_cooldown = 180 SECONDS

	/// Direct ref to the trunk pipe underneath us
	var/obj/structure/disposalpipe/trunk/trunk

/obj/machinery/customat/proc/set_up_components()
	component_parts = list()
	var/obj/item/circuitboard/vendor/V = new
	V.set_type(replacetext(initial(name), "\improper", ""))
	component_parts += V
	canister = new /obj/item/vending_refill/custom
	component_parts += canister

/obj/machinery/customat/RefreshParts()
	. = ..()
	for(var/obj/item/vending_refill/custom/VR in component_parts)
		canister.linked_accounts = VR.linked_accounts.Copy()
		canister.accounts_weights = VR.accounts_weights.Copy()
		canister.sum_of_weigths = VR.sum_of_weigths

/obj/machinery/customat/Initialize(mapload)
	. = ..()
	set_up_components()
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/customat/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..(AM, skipcatch, hitpush, blocked, throwingdatum)
	if (!AM.throwforce)
		return

	if(COOLDOWN_FINISHED(src, emp_cooldown) && COOLDOWN_FINISHED(src, alarm_cooldown))
		playsound(src, 'sound/machines/burglar_alarm.ogg', AM.throwforce * 5, 0)
		COOLDOWN_START(src, alarm_cooldown, alarm_delay)
		return ..()

/obj/machinery/customat/bullet_act(obj/item/projectile/P, def_zone)
	. = ..(P, def_zone)

	if(COOLDOWN_FINISHED(src, emp_cooldown) && COOLDOWN_FINISHED(src, alarm_cooldown))
		playsound(src, 'sound/machines/burglar_alarm.ogg', P.damage * 5, 0)
		COOLDOWN_START(src, alarm_cooldown, alarm_delay)
		return ..()

/obj/machinery/customat/proc/eject_all()
	for (var/key in products)
		var/datum/data/customat_product/product = products[key]
		for (var/obj/item/I in product.containtment)
			I.forceMove(get_turf(src))
		product.amount = 0
		inserted_items_count -= product.containtment.len
		product.containtment = list()

/obj/machinery/customat/Destroy()
	eject_all()
	if (trunk)
		var/obj/structure/disposalholder/holder = locate() in trunk
		if(holder)
			trunk.expel(holder)
		trunk.linked = null
		trunk = null
	return ..()

/obj/machinery/customat/LateInitialize()
	. = ..()
	set_up_components()
	RefreshParts()
	update_icon(UPDATE_OVERLAYS)
	var/obj/structure/disposalpipe/trunk/found_trunk = locate() in loc
	if(found_trunk)
		found_trunk.set_linked(src)
		trunk = found_trunk

/obj/machinery/customat/update_icon(updates = ALL)
	return ..()


/obj/machinery/customat/update_overlays()
	. = ..()

	underlays.Cut()

	if((stat & NOPOWER) || force_no_power_icon_state || !COOLDOWN_FINISHED(src, emp_cooldown))
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
	var/flick_time = (flick_flag & FLICK_VEND) ? vend_overlay_time : (flick_flag & FLICK_DENY) ? deny_overlay_time : 0
	addtimer(CALLBACK(src, PROC_REF(flick_reset)), flick_time)


/obj/machinery/customat/proc/flick_reset()
	flick_sequence = FLICK_NONE
	update_icon(UPDATE_OVERLAYS)


/*
 * Reimp, flash the screen on and off repeatedly.
 */
/obj/machinery/customat/flicker()
	if(flickering)
		return FALSE

	if((stat & (BROKEN|NOPOWER)) || !COOLDOWN_FINISHED(src, emp_cooldown))
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
	if(!canister) //the non constructable customats drop metal instead of a machine frame.
		new /obj/item/stack/sheet/metal(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/customat/proc/idcard_act(mob/user, obj/item/I)
	if (!isLocked())
		connected_id = I
		balloon_alert(user, "заблокировано")
	else if (connected_id == I)
		connected_id = null
		balloon_alert(user, "разблокировано")
	else
		balloon_alert(user, "карта не подходит")

/obj/machinery/customat/proc/get_key(obj/item/I, cost)
	return I.name + "_[cost]"

/obj/machinery/customat/proc/insert(mob/user, obj/item/I, cost)
	if (inserted_items_count >= max_items_inside)
		if (user)
			to_chat(user, span_warning("Лимит в [max_items_inside] предметов достигнут."))
		return
	remembered_costs[I.name] = cost
	var/key = get_key(I, cost)
	if(user && !user.drop_transfer_item_to_loc(I, src))
		to_chat(user, span_warning("Вы не можете положить это внутрь."))
		return

	if (!user) // If from pipe, transfer into src.
		I.forceMove(src)

	var/datum/data/customat_product/product
	if (!(key in products))
		product = new /datum/data/customat_product(I)
		product.price = !emagged ? cost : 0
		product.key = key
		products[key] = product

	product = products[key]
	product.containtment += I
	product.amount++
	inserted_items_count++

/obj/machinery/customat/proc/try_insert(mob/user, obj/item/I, from_tube = FALSE)
	var/cost = 100
	if (from_tube)
		if (I.name in remembered_costs)
			cost = remembered_costs[I.name]
	else if (fast_insert && (I.name in remembered_costs))
		cost = remembered_costs[I.name]
	else
		var/input_cost = tgui_input_number(user, "Пожалуйста, выберите цену для этого товара. Цена не может быть ниже 0 и выше 1000000 кредитов.", "Выбор цены", 0, 1000000, 0)
		if (!input_cost)
			to_chat(user, span_warning("Цена не указанна!"))
			return
		cost = input_cost
	if (user && get_dist(get_turf(user), get_turf(src)) > 1)
		to_chat(user, span_warning("Вы слишком далеко!"))
		return
	insert(user, I, cost)

/obj/machinery/customat/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM && COOLDOWN_FINISHED(src, emp_cooldown) && COOLDOWN_FINISHED(src, alarm_cooldown))
		playsound(src, 'sound/machines/burglar_alarm.ogg', I.force * 5, 0)
		COOLDOWN_START(src, alarm_cooldown, alarm_delay)
		return ..()

	if(istype(I, /obj/item/crowbar) || istype(I, /obj/item/wrench))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if (panel_open)
		if (istype(I, /obj/item/card/id))
			idcard_act(user, I)
			return ATTACK_CHAIN_BLOCKED_ALL
		else if (!isLocked())
			try_insert(user, I)
			return ATTACK_CHAIN_BLOCKED_ALL

	if (!istype(I, /obj/item/stack/nanopaste) && !istype(I, /obj/item/detective_scanner) && COOLDOWN_FINISHED(src, emp_cooldown) && COOLDOWN_FINISHED(src, alarm_cooldown))
		COOLDOWN_START(src, alarm_cooldown, alarm_delay)
		playsound(src, 'sound/machines/burglar_alarm.ogg', I.force * 5, 0)

	return ..()


/obj/machinery/customat/crowbar_act(mob/user, obj/item/I)
	if(!component_parts)
		return
	if (isLocked())
		to_chat(user, span_warning("[src] is locked."))
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
	if (anchored)
		trunk_check()

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
	for (var/key in products)
		var/datum/data/customat_product/product = products[key]
		product.price = 0
		products[key] = product
	if(user)
		to_chat(user, "You short out the product lock on [src]")

/obj/machinery/customat/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/customat/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/customat/attack_hand(mob/user)
	if((stat & (BROKEN|NOPOWER)) || !COOLDOWN_FINISHED(src, emp_cooldown))
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
	data["products"] = list()
	for (var/key in products)
		var/datum/data/customat_product/product = products[key]
		var/list/data_pr = list(
			name = product.name,
			price = product.price,
			stock = product.amount,
			icon = product.icon,
			Key = product.key
		)
		data["products"] += list(data_pr)
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
			var/key = params["Key"]
			var/datum/data/customat_product/product = products[key]
			if (product.amount <= 0)
				to_chat(usr, "Sold out of [product.name].")
				flick_vendor_overlay(FLICK_VEND)
				return

			vend_ready = FALSE // From this point onwards, customat is locked to performing this transaction only, until it is resolved.

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
				paid = FALSE
				var/left = currently_vending.price
				for (var/ind = 1; ind <= canister.linked_accounts.len; ++ind)
					var/pay_now = round(currently_vending.price * canister.accounts_weights[ind] / canister.sum_of_weigths)
					pay_now = min(pay_now, left)
					left -= pay_now
					paid = pay_with_cash(S, usr, pay_now, currently_vending.name, canister.linked_accounts[ind]) || paid
			else if(get_card_account(usr))
				var/datum/money_account/customer_account = get_card_account(usr)
				paid = FALSE
				var/left = currently_vending.price
				for (var/ind = 1; ind <= canister.linked_accounts.len; ++ind)
					var/pay_now = round(currently_vending.price * canister.accounts_weights[ind] / canister.sum_of_weigths)
					pay_now = min(pay_now, left)
					left -= pay_now
					paid = customer_account.charge(pay_now, canister.linked_accounts[ind],
		"Purchase of [product.name]", name, canister.linked_accounts[ind].owner_name,
		"Sale of [product.name]", customer_account.owner_name) || paid

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

/obj/machinery/customat/proc/isLocked()
	return connected_id != null

/obj/machinery/customat/proc/vend(datum/data/customat_product/product, mob/user)
	if(!product.amount)
		to_chat(user, span_warning("В автомате не осталось содержимого."))
		vend_ready = TRUE
		return

	vend_ready = FALSE //One thing at a time!!

	product.amount--

	if(COOLDOWN_FINISHED(src, reply_cooldown) && vend_reply)
		speak(pick(src.vend_reply))
		COOLDOWN_START(src, reply_cooldown, reply_delay)

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
	inserted_items_count--
	return TRUE

/obj/machinery/customat/process()
	if((stat & (BROKEN|NOPOWER)) || !COOLDOWN_FINISHED(src, emp_cooldown))
		return

	if(!active)
		return

	//Pitch to the people!  Really sell it!
	if(COOLDOWN_FINISHED(src, slogan_cooldown) && (LAZYLEN(ads_list)) && (!shut_up) && prob(5))
		var/slogan = pick(src.ads_list)
		speak(slogan)
		COOLDOWN_START(src, slogan_cooldown, slogan_delay)


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

/obj/machinery/customat/AltClick(atom/movable/A)
	if (!panel_open)
		balloon_alert(A, "панель закрыта")
		return
	if (isLocked())
		balloon_alert(A, "автомат заблокирован")
		return

	balloon_alert(A, "быстрый режим " + (fast_insert ? "отключен" : "включен"))
	fast_insert = !fast_insert

/obj/machinery/customat/emp_act(severity)
	switch(severity)
		if(1)
			COOLDOWN_START(src, emp_cooldown, weak_emp_cooldown)
		if(2)
			COOLDOWN_START(src, emp_cooldown, strong_emp_cooldown)

/obj/machinery/customat/proc/expel(obj/structure/disposalholder/holder)
	var/turf/origin_turf = get_turf(src)
	var/list/contents = holder.contents
	for (var/atom/movable/content in contents)
		if (istype(content, /obj/item))
			try_insert(null, content, TRUE)
		else
			content.forceMove(origin_turf)
	qdel(holder)

/obj/machinery/customat/proc/trunk_check()
	var/obj/structure/disposalpipe/trunk/found_trunk = locate() in loc
	if(found_trunk)
		found_trunk.set_linked(src) // link the pipe trunk to self
		trunk = found_trunk

#undef FLICK_NONE
#undef FLICK_VEND
#undef FLICK_DENY
