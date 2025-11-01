/**
 * Items skins component.
 *
 * Add skins feature to /obj/item by alt_click.
 */
/datum/component/item_skins
	var/list/skins


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


/datum/component/item_skins/Initialize(list/skins = list())
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.skins = skins


/datum/component/item_skins/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))

/datum/component/item_skins/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CLICK_ALT)


/datum/component/item_skins/proc/check_altclicked(datum/source, mob/living/carbon/human/user)
	if(source != parent)
		return
	if(!length(skins))
		return
	if(!istype(user)) //only humans use skins
		return
	var/obj/item/item = parent
	if(item.current_skin) //already exists skin, no reskin allowed
		return

	INVOKE_ASYNC(src, PROC_REF(show_select_skins_radial_menu), user)
	return CLICK_ACTION_SUCCESS


/datum/component/item_skins/proc/show_select_skins_radial_menu(mob/living/carbon/human/user)
	var/obj/item/item = parent
	var/list/skin_options = list()
	for(var/datum/item_skin_data/skin as anything in skins)
		if(skin.donation_tier > user.client.donator_level)
			continue
		skin_options[skin.name] = image(icon = (skin.icon ? skin.icon : item.icon), icon_state = (skin.menu_icon_state ? skin.menu_icon_state : skin.icon_state) )

	if(!length(skin_options))
		to_chat(user, span_warning("Для получения скинов необходимо сделать пожертвование в Discord сообществе."))
		return

	var/choice = show_radial_menu(user, item, skin_options, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), user), require_near = TRUE)

	if(!choice || !reskin_radial_check(user) || item.current_skin)
		return

	var/datum/item_skin_data/skin = skin_options[choice]
	item.current_skin = skin.icon_state
	to_chat(user, "Теперь [item.declent_ru(NOMINATIVE)] имеет облик '[skin.name]'. Познакомьтесь с новым дизайном.")
	if(skin.icon != null)
		item.icon = skin.icon
	item.base_icon_state = skin.icon_state
	item.icon_state = skin.icon_state
	item.update_icon()
	item.update_equipped_item()

/datum/component/item_skins/proc/reskin_radial_check(mob/living/carbon/human/user)
	if(!ishuman(user) || QDELETED(parent) || !user.is_in_hands(parent) || user.incapacitated())
		return FALSE
	return TRUE
