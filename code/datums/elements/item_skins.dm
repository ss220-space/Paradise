/**
 * Items skins component.
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
	. = ..()
	UnregisterSignal(target, COMSIG_CLICK_ALT)


/datum/element/item_skins/proc/check_altclicked(datum/source, mob/living/carbon/human/user)
	var/obj/item/item = source
	if(!istype(item))
		return
	if(!item.skins || !length(item.skins))
		return
	if(!istype(user)) //only humans use skins
		return
	if(item.current_skin) //already exists skin, no reskin allowed
		return

	INVOKE_ASYNC(src, PROC_REF(show_select_skins_radial_menu), item, user)
	return CLICK_ACTION_SUCCESS


/datum/element/item_skins/proc/show_select_skins_radial_menu(obj/item/item, mob/living/carbon/human/user)
	var/list/skin_options = list()
	for(var/datum/item_skin_data/skin as anything in item.skins)
		if(skin.donation_tier > user.client.donator_level)
			continue
		skin_options[skin.name] = image(icon = (skin.icon ? skin.icon : item.icon), icon_state = (skin.menu_icon_state ? skin.menu_icon_state : skin.icon_state) )

	if(!length(skin_options))
		to_chat(user, span_warning("Для получения скинов необходимо сделать пожертвование в Discord-сообществе проекта!"))
		return

	var/choice = show_radial_menu(user, item, skin_options, radius = 40, require_near = TRUE)

	if(!choice || QDELETED(item) || !user.is_in_hands(item) || user.incapacitated() || item.current_skin)
		return

	var/datum/item_skin_data/skin = skin_options[choice]
	item.current_skin = skin.icon_state
	to_chat(user, "На [item.declent_ru(ACCUSATIVE)] установлен скин \"[choice]\".")
	if(skin.icon != null)
		item.icon = skin.icon
	item.base_icon_state = skin.icon_state
	item.icon_state = skin.icon_state
	item.exists_skin_change = FALSE
	item.skins = null
	item.update_icon()
	item.update_equipped_item()
