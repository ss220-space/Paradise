#define ORDERS_REFRESH_DURATION (10 * 60 SECONDS)
#define AVAILABLE_MANUALS_COUNT 10
#define MANUAL_AMOUNT_MIN 1
#define MANUAL_AMOUNT_MAX 3
#define MANUAL_PRICE_MIN 500
#define MANUAL_PRICE_MAX 1500

GLOBAL_VAR_INIT(skill_manual_computer_refresh_time, world.time)
GLOBAL_LIST_EMPTY(skill_manual_orders)

/obj/item/circuitboard/computer/skill_manuals
	board_name = "skill manuals console"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/skill_manuals
	origin_tech = "engineering=2;bluespace=3;programming=2"

/datum/skill_manual_order
	/// Manual path
	var/manual_type
	/// Manual name
	var/name
	/// Manual description
	var/desc
	/// Purchase price
	var/price
	/// Available amount
	var/amount

/obj/machinery/computer/skill_manuals
	name = "skill manuals console"
	desc = "Используется для покупки различных руководств."
	icon_screen = "request"
	req_access = list(ACCESS_LIBRARY)
	circuit = /obj/item/circuitboard/computer/skill_manuals

/obj/machinery/computer/skill_manuals/Initialize(mapload, obj/structure/computerframe/frame)
	. = ..()
	if(length(GLOB.skill_manual_orders) == 0)
		refresh_available_manuals()

/obj/machinery/computer/skill_manuals/get_ru_names()
	return alist(
		NOMINATIVE = "консоль магазина руководств",
		GENITIVE = "консоли магазина руководств",
		DATIVE = "консоли магазина руководств",
		ACCUSATIVE = "консоль магазина руководств",
		INSTRUMENTAL = "консолью магазина руководств",
		PREPOSITIONAL = "консоли магазина руководств",
	)

/obj/machinery/computer/skill_manuals/attack_hand(mob/user)
	. = ..()
	if(.)
		return TRUE
	ui_interact(user)

/obj/machinery/computer/skill_manuals/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkillManualsShop", "Магазин руководств")
		ui.open()

/obj/machinery/computer/skill_manuals/ui_data(mob/user)
	var/list/data = list()
	data["modal"] = ui_modal_data(src)
	if(ishuman(user))
		var/datum/money_account/money_account = get_card_account(user)
		var/mob/living/carbon/human/human_user = user
		var/obj/item/stack/spacecash/cash = human_user.get_active_hand()
		if(istype(money_account))
			data["cash"] = istype(cash) ? cash.amount : money_account.money
		else
			data["cash"] = istype(cash) ? cash.amount : "Нет данных!"
	else
		data["cash"] = "Нет данных!"

	data["refresh_available"] = GLOB.skill_manual_computer_refresh_time + ORDERS_REFRESH_DURATION <= world.time
	var/list/manuals_data = list()
	for(var/datum/skill_manual_order/manual in GLOB.skill_manual_orders)
		var/list/manual_data = list()
		manual_data["type"] = manual.manual_type
		manual_data["name"] = manual.name
		manual_data["desc"] = manual.desc
		manual_data["price"] = manual.price
		manual_data["amount"] = manual.amount
		manuals_data += list(manual_data)
	data["manuals"] = manuals_data
	return data

/obj/machinery/computer/skill_manuals/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("refresh")
			refresh_available_manuals()
			SStgui.update_uis(src)
		if("purchase")
			var/manual_type = text2path(params["type"])
			purchase(manual_type)

/obj/machinery/computer/skill_manuals/proc/purchase(var/manual_type)
	var/datum/skill_manual_order/manual = find_manual_by_type(manual_type)
	if(!manual)
		to_chat(usr, "Ошибка, товар не найден!")
		return

	if(manual.amount <= 0)
		to_chat(usr, "Ошибка, товар распродан!")
		return

	if(!ishuman(usr))
		to_chat(usr, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] отказывается продавать вам товар, поскольку вы не входите в его целевую аудиторию!"))
		return

	if(!GLOB.vendor_account || GLOB.vendor_account.suspended)
		to_chat(usr, "Удалённый сервер торговых автоматов отключён. Не удается обработать операцию.")
		return

	var/paid = FALSE
	if(is_cash(usr.get_active_hand()))
		var/obj/item/stack/spacecash/cash = usr.get_active_hand()
		paid = pay_with_cash(cash, usr, manual.price, manual.name)
	else if(get_card_account(usr))
		// Because this uses H.get_id_card(), it will attempt to use:
		// active hand, inactive hand, wear_id, pda, and then w_uniform ID in that order
		// this is important because it lets people buy stuff with someone else's ID by holding it while using the vendor
		paid = pay_with_card(usr, manual.price, manual.name)
	else
		to_chat(usr, span_warning("Сбой платежа: у вас нет ID-карты или другого способа оплаты."))
		return

	if(paid)
		var/mob/user = usr
		manual.amount -= 1
		to_chat(usr, "[user.name] спасибо за покупку руководства \"[manual.name]\"!")
		SStgui.update_uis(src)
		var/put_on_turf = TRUE
		var/obj/item/vended_item = new manual.manual_type(drop_location())
		if(IsReachableBy(user) && user.put_in_hands(vended_item, ignore_anim = FALSE))
			put_on_turf = FALSE
		if(put_on_turf)
			var/turf/target_turf = get_turf(src)
			vended_item.forceMove(target_turf)
	else
		to_chat(usr, span_warning("Сбой платежа: не удаётся обработать платеж."))


/obj/machinery/computer/skill_manuals/proc/find_manual_by_type(var/type)
	for(var/datum/skill_manual_order/manual in GLOB.skill_manual_orders)
		if(manual.manual_type == type)
			return manual
	return null

/obj/machinery/computer/skill_manuals/proc/refresh_available_manuals()
	QDEL_LIST(GLOB.skill_manual_orders)
	var/list/manual_types = pick_multiple_unique(GLOB.skill_manual_types, AVAILABLE_MANUALS_COUNT)
	for(var/manual_type in manual_types)
		var/datum/skill_manual_order/manual = new()
		manual.manual_type = manual_type
		var/obj/item/book/skill_manual/manual_obj = new manual_type(src)
		manual.name = manual_obj.manual_title
		manual.desc = manual_obj.desc
		manual.price = rand(MANUAL_PRICE_MIN, MANUAL_PRICE_MAX)
		manual.amount = rand(MANUAL_AMOUNT_MIN, MANUAL_AMOUNT_MAX)
		qdel(manual_obj)
		GLOB.skill_manual_orders += manual
	GLOB.skill_manual_computer_refresh_time = world.time


#undef ORDERS_REFRESH_DURATION
#undef AVAILABLE_MANUALS_COUNT
#undef MANUAL_AMOUNT_MIN
#undef MANUAL_AMOUNT_MAX
#undef MANUAL_PRICE_MIN
#undef MANUAL_PRICE_MAX
