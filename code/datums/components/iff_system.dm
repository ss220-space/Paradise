#define IFF_ACTION_MODE "mode"
#define IFF_ACTION_FRIENDS "friends"
#define IFF_ACTION_ENEMIES "enemies"

/datum/component/iff_system
	var/enabled = TRUE
	var/list/friends = list()
	var/list/enemies = list()
	var/scan_range = 8

/datum/component/iff_system/Initialize(...)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/iff_system/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_click_alt))
	RegisterSignal(parent, COMSIG_GUN_GET_HOMING_TARGET, PROC_REF(on_get_homing_target))
	RegisterSignal(parent, COMSIG_GUN_CHECK_FRIEND, PROC_REF(on_check_friend))

/datum/component/iff_system/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_CLICK_ALT, COMSIG_GUN_GET_HOMING_TARGET, COMSIG_GUN_CHECK_FRIEND))

/datum/component/iff_system/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Система «Свой-Чужой» имеет следующую настройку:")
	examine_list += "Режим: [enabled ? span_green("Включён") : span_red("Выключен")]."
	examine_list += "[span_green("Друзья")]: [russian_list(friends)]."
	examine_list += "[span_red("Враги")]: [russian_list(enemies)]."

/datum/component/iff_system/proc/on_click_alt(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!check_menu(user))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(open_menu), user)
	return CLICK_ACTION_SUCCESS

/datum/component/iff_system/proc/open_menu(mob/user)
	var/obj/item/gun/gun = parent
	while(check_menu(user))
		var/list/actions = list()
		var/mode_key = "Режим: [enabled ? "Включён" : "Выключен"]"
		actions[mode_key] = IFF_ACTION_MODE
		var/friends_key = "Друзья ([length(friends)])"
		actions[friends_key] = IFF_ACTION_FRIENDS
		var/enemies_key = "Враги ([length(enemies)])"
		actions[enemies_key] = IFF_ACTION_ENEMIES

		var/list/choices = list()
		choices[mode_key] = image(icon = 'icons/hud/radial.dmi', icon_state = enabled ? "module_active" : "dark")
		choices[friends_key] = image(icon = 'icons/hud/radial.dmi', icon_state = "green")
		choices[enemies_key] = image(icon = 'icons/hud/radial.dmi', icon_state = "red")

		var/choice = show_radial_menu(user, gun, choices, uniqueid = "iff_menu_[gun.UID()]", custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
		if(!choice || !actions[choice])
			return

		switch(actions[choice])
			if(IFF_ACTION_MODE)
				enabled = !enabled
				user.balloon_alert(user, "режим [enabled ? "включён" : "выключен"]")
			if(IFF_ACTION_FRIENDS)
				edit_list(user, friends, "Друзья")
				return
			if(IFF_ACTION_ENEMIES)
				edit_list(user, enemies, "Враги")
				return

/datum/component/iff_system/proc/edit_list(mob/user, list/names, list_title)
	var/static/add_entry = "Добавить имя"

	while(check_menu(user))
		var/list/options = names.Copy()
		options += add_entry

		var/choice = pick_from_list(user, "Список «[list_title]»", options)
		if(!choice)
			return
		if(choice == add_entry)
			var/new_name = tgui_input_text(user, "Введите имя объекта", "Свой-Чужой", max_length = MAX_NAME_LEN)
			if(isnull(new_name))
				return
			if(length(new_name))
				names |= new_name
			continue
		var/edited_name = tgui_input_text(user, "Измените имя объекта", "Свой-Чужой", choice, max_length = MAX_NAME_LEN)
		if(isnull(edited_name))
			return
		names -= choice
		if(length(edited_name))
			names |= edited_name

/datum/component/iff_system/proc/pick_from_list(mob/user, message, list/options)
	if(isnull(user.client))
		return null
	if(user.client.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		return input(user, message, "Свой-Чужой", options[1]) as null|anything in options

	var/datum/tgui_list_input/list_input = new(user, message, "Свой-Чужой", options, null, 0, GLOB.always_state)
	if(list_input.invalid)
		qdel(list_input)
		return null
	list_input.ui_interact(user)
	list_input.wait()
	var/choice = list_input.choice
	qdel(list_input)
	return choice

/datum/component/iff_system/proc/check_menu(mob/user)
	var/obj/item/gun/gun = parent
	if(QDELETED(gun) || QDELETED(src) || !user)
		return FALSE
	if(user.incapacitated() || gun.loc != user)
		return FALSE
	return TRUE

/datum/component/iff_system/proc/is_friend(atom/target)
	if(!enabled || !length(friends) || !isliving(target))
		return FALSE
	return matches_list(friends, target)

/datum/component/iff_system/proc/find_enemy_target(mob/user)
	if(!enabled || !length(enemies) || !isliving(user))
		return null

	var/mob/living/picked
	var/picked_dist
	for(var/mob/living/candidate in view(scan_range, user))
		if(candidate == user || candidate.stat == DEAD || HAS_TRAIT(candidate, TRAIT_RESTRAINED))
			continue
		if(!matches_list(enemies, candidate) || !user.can_see(candidate, scan_range))
			continue
		var/distance = get_dist(user, candidate)
		if(isnull(picked_dist) || distance < picked_dist)
			picked_dist = distance
			picked = candidate
	return picked

/datum/component/iff_system/proc/matches_list(list/names, atom/target)
	var/target_name = lowertext(target.get_visible_name())
	for(var/entry in names)
		if(lowertext(entry) == target_name)
			return TRUE
	return FALSE

/datum/component/iff_system/proc/on_get_homing_target(datum/source, mob/user, list/targets)
	SIGNAL_HANDLER
	var/mob/living/target = find_enemy_target(user)
	if(target)
		targets += target

/datum/component/iff_system/proc/on_check_friend(datum/source, atom/target)
	SIGNAL_HANDLER
	if(is_friend(target))
		return GUN_TARGET_IS_FRIEND
	return NONE

#undef IFF_ACTION_MODE
#undef IFF_ACTION_FRIENDS
#undef IFF_ACTION_ENEMIES
