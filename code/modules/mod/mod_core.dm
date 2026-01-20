/obj/item/mod/core
	name = "MOD core"
	desc = "Родитель для ядер модсьюта. Если вы это видите, сообщите в баг-репорты."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "mod-core"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/devices_righthand.dmi'
	/// MOD unit we are powering.
	var/obj/item/mod/control/mod

/obj/item/mod/core/Destroy()
	if(mod)
		uninstall()
	return ..()

/obj/item/mod/core/proc/install(obj/item/mod/control/mod_unit)
	mod = mod_unit
	mod.core = src
	forceMove(mod)

/obj/item/mod/core/proc/uninstall()
	mod.core = null
	mod = null

/obj/item/mod/core/proc/charge_source()
	return

/obj/item/mod/core/proc/charge_amount()
	return 0

/obj/item/mod/core/proc/max_charge_amount()
	return 1

/obj/item/mod/core/proc/add_charge(amount)
	return FALSE

/obj/item/mod/core/proc/subtract_charge(amount)
	return FALSE

/obj/item/mod/core/proc/check_charge(amount)
	return FALSE

/obj/item/mod/core/proc/update_charge_alert()
	mod.wearer.clear_alert("mod_charge")

/// Gets what the UI should use for the charge bar color.
/obj/item/mod/core/proc/get_chargebar_color()
	return "bad"

/// Gets what the UI should use for the charge bar text.
/obj/item/mod/core/proc/get_chargebar_string()
	var/charge_amount = charge_amount()
	var/max_charge_amount = max_charge_amount()
	return "[display_joules(charge_amount)] из [display_joules(max_charge_amount())] \
		([round((100 * charge_amount) / max_charge_amount, 1)]%)"

/obj/item/mod/core/infinite //Admin only.
	name = "MOD infinite core"
	icon_state = "mod-core-infinite"
	desc = "Невероятно навороченное сверх-ультра-хайэнд-макскап-ультраделюкс-хайтек ядро, способное бесконечно питать модсьют."

/obj/item/mod/core/infinite/charge_source()
	return src

/obj/item/mod/core/infinite/charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/max_charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/add_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/subtract_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/check_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/get_chargebar_color()
	return "teal"

/obj/item/mod/core/infinite/get_chargebar_string()
	return "Infinite"

/obj/item/mod/core/standard
	name = "MOD standard core"
	desc = "В наиболее плодородных участках планеты Спраут растут редкие кристаллы, известные как \"Сердцесвет.\" \
			Эти редкие, крайне ценные пьезоэлектрические кристаллы, будучи по своей природе органическими, являются самым мощным проводником в галактике. \n\
			И сейчас этот кристалл, внешне похожий на человеческое сердце, будет использован для питания модульного экзокостюма."
	icon_state = "mod-core-standard"
	/// Installed cell.
	var/obj/item/stock_parts/cell/cell

/obj/item/mod/core/standard/get_ru_names()
	return list(
		NOMINATIVE = "стандартное ядро МЭК",
		GENITIVE = "стандартного ядра МЭК",
		DATIVE = "стандартному ядру МЭК",
		ACCUSATIVE = "стандартное ядро МЭК",
		INSTRUMENTAL = "стандартным ядром МЭК",
		PREPOSITIONAL = "стандартном ядре МЭК"
	)

/obj/item/mod/core/standard/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/mod/core/standard/install(obj/item/mod/control/mod_unit)
	. = ..()
	if(cell)
		install_cell(cell)
	RegisterSignal(mod, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mod, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(mod, COMSIG_MOD_WEARER_SET, PROC_REF(on_wearer_set))
	if(mod.wearer)
		on_wearer_set(mod, mod.wearer)

/obj/item/mod/core/standard/uninstall()
	if(!QDELETED(cell))
		cell.forceMove(drop_location())
	UnregisterSignal(mod, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_ATTACK_HAND, COMSIG_MOD_WEARER_SET))
	if(mod.wearer)
		on_wearer_unset(mod, mod.wearer)
	return ..()

/obj/item/mod/core/proc/on_attackby(obj/item/attacking_item, mob/user, params)
	return

/obj/item/mod/core/standard/charge_source()
	return cell

/obj/item/mod/core/standard/charge_amount()
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	return charge_source?.charge || 0

/obj/item/mod/core/standard/max_charge_amount()
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	return charge_source?.maxcharge || 1

/obj/item/mod/core/standard/add_charge(amount)
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	return charge_source.give(amount)

/obj/item/mod/core/standard/subtract_charge(amount)
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	return charge_source.use(amount, TRUE)

/obj/item/mod/core/standard/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/standard/update_charge_alert()
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocell)
		return
	var/remaining_cell = charge_amount() / max_charge_amount()
	switch(remaining_cell)
		if(CELL_CHARGE_HIGH to INFINITY)
			mod.wearer.clear_alert("mod_charge")
		if(0.5 to 0.75)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 1)
		if(0.25 to 0.5)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 2)
		if(0.01 to 0.25)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 3)
		else
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/emptycell)

/obj/item/mod/core/standard/get_chargebar_color()
	if(isnull(charge_source()))
		return "transparent"
	switch(round(charge_amount() / max_charge_amount(), 0.01))
		if(-CELL_CHARGE_UPPER_BORDER to CELL_CHARGE_ONE_THIRD)
			return "bad"
		if(CELL_CHARGE_ONE_THIRD to CELL_CHARGE_TWO_THIRDS)
			return "average"
		if(CELL_CHARGE_TWO_THIRDS to CELL_CHARGE_UPPER_BORDER)
			return "good"

/obj/item/mod/core/standard/get_chargebar_string()
	if(isnull(charge_source()))
		return "Power Cell Missing"
	return ..()

/obj/item/mod/core/standard/emp_act(severity)
	cell?.emp_act(severity)

/obj/item/mod/core/standard/proc/install_cell(new_cell)
	cell = new_cell
	cell.forceMove(src)
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))

/obj/item/mod/core/standard/proc/uninstall_cell()
	if(!cell)
		return
	cell = null
	UnregisterSignal(src, COMSIG_ATOM_EXITED)

/obj/item/mod/core/standard/proc/on_exit(datum/source, obj/item/stock_parts/cell, direction)
	SIGNAL_HANDLER

	if(!istype(cell) || cell.loc == src)
		return
	uninstall_cell()

/obj/item/mod/core/standard/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!mod.open)
		return
	examine_text += span_notice("[cell ? "Вы можете отсоединить батарею от ядра." : "Вы можете установить новую батарею в ядро."]")

/obj/item/mod/core/standard/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(mod.seconds_electrified && charge_amount() && mod.shock(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(mod.open && mod.loc == user)
		INVOKE_ASYNC(src, PROC_REF(mod_uninstall_cell), user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/obj/item/mod/core/standard/proc/mod_uninstall_cell(mob/living/user)
	if(!cell)
		balloon_alert(user, "нет батареи!")
		return
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	balloon_alert(user, "батарея отсоединена!")
	playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	var/obj/item/cell_to_move = cell
	cell_to_move.forceMove(drop_location())
	user.put_in_hands(cell_to_move)
	mod.update_charge_alert()

/obj/item/mod/core/standard/on_attackby(obj/item/attacking_item, mob/user, params)
	if(iscell(attacking_item))
		if(!mod.open)
			balloon_alert(user, "откройте крышку!")
			playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return NONE
		if(cell)
			balloon_alert(user, "уже есть батарея!")
			playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return COMPONENT_NO_AFTERATTACK
		user.drop_from_active_hand()
		install_cell(attacking_item)
		balloon_alert(user, "батарея установлена")
		playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		mod.update_charge_alert()
		return COMPONENT_NO_AFTERATTACK
	return NONE

/obj/item/mod/core/standard/proc/on_wearer_set(datum/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(mod, COMSIG_MOD_WEARER_UNSET, PROC_REF(on_wearer_unset))

/obj/item/mod/core/standard/proc/on_wearer_unset(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(mod, COMSIG_MOD_WEARER_UNSET)

/obj/item/mod/core/standard/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	add_charge(amount)
	mod.update_charge_alert()

/obj/item/mod/core/plasma
	name = "MOD plasma core"
	desc = "Попытка \"Нанотрейзен\" извлечь выгоду из своих исследований плазмы. Данный тип ядер можно подзаряжать \
			с помощью листов плазмы, позволяя шахтёрским бригадам работать без необходимости постоянно возвращаться для дозарядки костюмов."
	icon_state = "mod-core-plasma"
	/// How much charge we can store.
	var/maxcharge = 10000
	/// How much charge we are currently storing.
	var/charge = 10000
	/// Associated list of charge sources, only stacks allowed.
	var/list/charger_list = list(/obj/item/stack/ore/plasma, /obj/item/stack/sheet/mineral/plasma)

/obj/item/mod/core/plasma/get_ru_names()
	return list(
		NOMINATIVE = "плазменное ядро МЭК",
		GENITIVE = "плазменного ядра МЭК",
		DATIVE = "плазменному ядру МЭК",
		ACCUSATIVE = "плазменное ядро МЭК",
		INSTRUMENTAL = "плазменным ядром МЭК",
		PREPOSITIONAL = "плазменном ядре МЭК"
	)

/obj/item/mod/core/plasma/attackby(obj/item/attacking_item, mob/user, params)
	if(charge_plasma(attacking_item, user))
		return TRUE
	return ..()

/obj/item/mod/core/plasma/charge_source()
	return src

/obj/item/mod/core/plasma/charge_amount()
	return charge

/obj/item/mod/core/plasma/max_charge_amount()
	return maxcharge

/obj/item/mod/core/plasma/add_charge(amount)
	charge = min(maxcharge, charge + amount)
	return TRUE

/obj/item/mod/core/plasma/subtract_charge(amount)
	charge = max(0, charge - amount)
	return TRUE

/obj/item/mod/core/plasma/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/plasma/update_charge_alert()
	var/remaining_plasma = charge_amount() / max_charge_amount()
	switch(remaining_plasma)
		if(CELL_CHARGE_HIGH to CELL_CHARGE_UPPER_BORDER)
			mod.wearer.clear_alert("mod_charge")
		if(CELL_CHARGE_MEDIUM to CELL_CHARGE_HIGH)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 1)
		if(CELL_CHARGE_LOW to CELL_CHARGE_MEDIUM)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 2)
		if(CELL_CHARGE_LOWER_BORDER to CELL_CHARGE_LOW)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 3)
		else
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/emptycell)

/obj/item/mod/core/plasma/get_chargebar_color()
	switch(round(charge_amount() / max_charge_amount(), 0.01))
		if(-CELL_CHARGE_UPPER_BORDER to CELL_CHARGE_ONE_THIRD)
			return "bad"
		if(CELL_CHARGE_ONE_THIRD to CELL_CHARGE_UPPER_BORDER)
			return "purple"

/obj/item/mod/core/plasma/on_attackby(obj/item/attacking_item, mob/user, params)
	charge_plasma(attacking_item, user)

/obj/item/mod/core/plasma/proc/charge_plasma(obj/item/stack/plasma, mob/user)
	var/charge_given = is_type_in_list(plasma, charger_list)
	if(!charge_given)
		return FALSE
	if(charge_amount() == max_charge_amount())
		balloon_alert(user, "полностью заряжено!")
		// We didn't succeed but we don't want to treat it as an attackby
		return TRUE
	var/uses_needed = min(plasma.amount, ((max_charge_amount() - charge_amount()) / 2000))
	if(!plasma.use(uses_needed))
		return FALSE
	add_charge(uses_needed * 2000)
	balloon_alert(user, "костюм подзаряжен")
	return TRUE
