/**
 * Items skins element.
 *
 * Add skins feature to /obj/item by alt_click.
 */
/datum/element/item_skins

/datum/element/item_skins/Attach(datum/target, item_path = null)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/item_target = target
	if(item_path == null)
		item_path = target.type

	item_target.skins = GLOB.item_skins[item_path]
	if(!item_target.skins || !length(item_target.skins))
		item_target.skins = null
		return

	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(check_altclicked), override = TRUE)
	item_target.exists_skin_change = TRUE


/datum/element/item_skins/Detach(datum/target)
	UnregisterSignal(target, COMSIG_CLICK_ALT)
	return ..()

/datum/element/item_skins/proc/check_altclicked(datum/source, mob/living/carbon/human/user)
	var/obj/item/item = source
	if(!item.skins || !length(item.skins))
		return NONE
	if(!istype(user) && user.client) //only humans use skins
		return NONE
	if(item.current_skin) //already exists skin, no reskin allowed
		to_chat(user, span_warning("Предмет уже имеет измененный внешний вид, его больше нельзя менять."))
		return CLICK_ACTION_BLOCKING
	if(!user.is_in_hands(item)) // can not apply skin if item not in hands
		to_chat(user, span_warning("Чтобы изменить внешний вид предмета, вы должны держать его в руках."))
		return CLICK_ACTION_BLOCKING

	var/list/skins = collect_available_skins(item, user)
	if(!length(skins))
		if(!user.client.donate_offer_text_shown)
			to_chat(user, span_warning("Для получения изменения внешнего вида необходимо сделать пожертвование в Discord-сообществе проекта!"))
			user.client.donate_offer_text_shown = TRUE
		return NONE // no blocking click

	if(is_need_use_tgui_input_list(skins))
		INVOKE_ASYNC(src, PROC_REF(show_select_skin_with_tgui_input_list), item, user, skins)
		return CLICK_ACTION_SUCCESS

	INVOKE_ASYNC(src, PROC_REF(show_select_skin_with_radial_menu), item, user, skins)
	return CLICK_ACTION_SUCCESS

/datum/element/item_skins/proc/collect_available_skins(obj/item/item, mob/living/carbon/human/user)
	var/list/skins = list()
	var/user_ckey = user.client.ckey
	var/user_donator_level = user.client.donator_level
	for(var/datum/item_skin_data/skin as anything in item.skins)
		if(skin.allowed_ckeys && !(user_ckey in skin.allowed_ckeys))
			continue
		else if(skin.donation_tier > user_donator_level)
			continue
		skins += skin

	return skins

/datum/element/item_skins/proc/is_need_use_tgui_input_list(list/skins)
	for(var/datum/item_skin_data/skin as anything in skins)
		if(skin.greyscale_colors != null)
			return TRUE
	return FALSE

/datum/element/item_skins/proc/show_select_skin_with_tgui_input_list(obj/item/item, mob/living/carbon/human/user, list/skins)
	var/list/skin_options = list()
	for(var/datum/item_skin_data/skin as anything in skins)
		skin_options += skin.name

	var/choice = tgui_input_list(user, "Доступные внешние виды", "Выбрать внешний вид", skin_options)
	on_select_skin(item, user, skins, choice)

/datum/element/item_skins/proc/show_select_skin_with_radial_menu(obj/item/item, mob/living/carbon/human/user, list/skins)
	var/list/skin_options = list()
	for(var/datum/item_skin_data/skin as anything in skins)
		skin_options[skin.name] = image(icon = (skin.icon ? skin.icon : item.icon), icon_state = (skin.menu_icon_state ? skin.menu_icon_state : skin.icon_state))

	var/choice = show_radial_menu(user, item, skin_options, radius = 40, require_near = TRUE)
	on_select_skin(item, user, skins, choice)

/datum/element/item_skins/proc/on_select_skin(obj/item/item, mob/living/carbon/human/user, list/skins, choice)
	if(!choice || QDELETED(item) || !user.is_in_hands(item) || user.incapacitated() || item.current_skin)
		return

	var/datum/item_skin_data/selected_skin = null
	for(var/datum/item_skin_data/skin as anything in skins)
		if(skin.name == choice)
			selected_skin = skin
			break

	item.exists_skin_change = FALSE
	item.skins = null
	if(!selected_skin)
		return

	to_chat(user, "Изменен внешний вид [item.declent_ru(GENITIVE)] на \"[selected_skin.name]\".")
	if(selected_skin.icon != null)
		item.icon = selected_skin.icon
	item.current_skin = selected_skin.icon_state
	item.base_icon_state = selected_skin.icon_state
	item.icon_state = selected_skin.icon_state
	if(selected_skin.greyscale_colors)
		var/list/colors = selected_skin.greyscale_colors
		if(!islist(colors))
			colors = list(selected_skin.greyscale_colors)
		item.set_greyscale_colors(colors)

	selected_skin.on_apply(item)
	item.update_appearance(UPDATE_ICON|UPDATE_OVERLAYS)
	item.update_equipped_item()
