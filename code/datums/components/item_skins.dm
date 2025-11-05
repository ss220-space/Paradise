

/datum/item_skin_data
	/// Name of skin (shown on radial menu)
	var/name
	/// Skin icon dmi (if null - use default item dmi)
	var/icon = null
	/// Skin icon_state
	var/icon_state
	/// Icon for radial menu (if null - use icon_state)
	var/menu_icon_state = null
	/// Minimal donater tier (0 for allow all players)
	var/donation_tier = 0

/datum/item_skin_data/New(name, icon_state, icon = null, menu_icon_state = null, donation_tier = 0)
	. = ..()
	src.name = name
	src.icon_state = icon_state
	src.icon = icon
	src.menu_icon_state = menu_icon_state
	src.donation_tier = donation_tier


/**
 * Items skins component.
 *
 * Add skins feature to /obj/item by alt_click.
 */
/datum/element/item_skins
	var/list/skins


/datum/element/item_skins/Attach(datum/target, list/skins = list())
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.skins = skins
	RegisterSignal(target, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))
	var/obj/item/item_target = target
	item_target.exists_skin_change = TRUE


/datum/element/item_skins/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_CLICK_ALT)


/datum/element/item_skins/proc/check_altclicked(datum/source, mob/living/carbon/human/user)
	if(!length(skins))
		return
	if(!istype(user)) //only humans use skins
		return
	var/obj/item/item = source
	if(item.current_skin) //already exists skin, no reskin allowed
		return

	INVOKE_ASYNC(src, PROC_REF(show_select_skins_radial_menu), item, user)
	return CLICK_ACTION_SUCCESS


/datum/element/item_skins/proc/show_select_skins_radial_menu(obj/item/item, mob/living/carbon/human/user)
	var/list/skin_options = list()
	for(var/datum/item_skin_data/skin as anything in skins)
		if(skin.donation_tier > user.client.donator_level)
			continue
		skin_options[skin.name] = image(icon = (skin.icon ? skin.icon : item.icon), icon_state = (skin.menu_icon_state ? skin.menu_icon_state : skin.icon_state) )

	if(!length(skin_options))
		to_chat(user, span_warning("Для получения скинов необходимо сделать пожертвование в Discord сообществе."))
		return

	var/choice = show_radial_menu(user, item, skin_options, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), item, user), require_near = TRUE)

	if(!choice || !reskin_radial_check(item, user) || item.current_skin)
		return

	var/datum/item_skin_data/skin = skin_options[choice]
	item.current_skin = skin.icon_state
	to_chat(user, "[capitalize(item.declent_ru(NOMINATIVE))] теперь имеет скин '[skin.name]'.")
	if(skin.icon != null)
		item.icon = skin.icon
	item.base_icon_state = skin.icon_state
	item.icon_state = skin.icon_state
	item.exists_skin_change = FALSE
	item.update_icon()
	item.update_equipped_item()

/datum/element/item_skins/proc/reskin_radial_check(obj/item/item, mob/living/carbon/human/user)
	if(!ishuman(user) || QDELETED(item) || !user.is_in_hands(item) || user.incapacitated())
		return FALSE
	return TRUE
