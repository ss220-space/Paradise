/**
 * Ranged attacks switcher for hostile mobs (not basic)
 *
 * On right click on self opens up a radial menu containing
 * specific ranged modes (/datum/ranged_mob_switcher_mode), passed in as a list.
 */
/datum/element/ranged_mob_switcher
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// List of all modes the mob can switch to, passed in Attach()
	var/list/possible_modes = list()
	/// Time required to switch modes, passed in Attach()
	var/switch_delay = 1 SECONDS
	/// Associative list in format: [mode_name] = image()
	var/list/radial_menu_list = list()
	/// Associative list in format: [mode_name] = mode_type
	var/list/mode_name_to_type = list()

/datum/element/ranged_mob_switcher/Attach(mob/living/simple_animal/hostile/target, list/possible_modes, switch_delay)
	. = ..()
	if(!istype(target))
		return COMPONENT_INCOMPATIBLE

	if(!length(possible_modes))
		return COMPONENT_INCOMPATIBLE

	for(var/mode in possible_modes)
		if(!ispath(mode, /datum/ranged_mob_switcher_mode))
			stack_trace("Element ranged_mob_switcher tried to be attached to [target.type] with non-valid mode value in list: [mode]")
			return COMPONENT_INCOMPATIBLE

	if(!target.ranged)
		target.ranged = TRUE

	src.possible_modes = possible_modes
	src.switch_delay = switch_delay ? switch_delay : src.switch_delay

	if(!length(radial_menu_list)) // Create the lists immediately
		create_radial_lists(possible_modes)

	apply_mode(pick(possible_modes), target) // Apply any given mode
	RegisterSignal(target, COMSIG_LIVING_RIGHT_CLICK_ATTACK, PROC_REF(on_right_click_attack))

/datum/element/ranged_mob_switcher/Detach(mob/living/simple_animal/hostile/target, ...)
	UnregisterSignal(target, COMSIG_LIVING_RIGHT_CLICK_ATTACK)
	return ..()

/**
 * Main signal proc of the element
 *
 * Returns SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN if we attacked ourselves.
 * Creates according lists if there aren't any at the moment, and then
 * opens up the radial menu.
 */
/datum/element/ranged_mob_switcher/proc/on_right_click_attack(mob/living/source, mob/living/simple_animal/hostile/target, list/modifiers)
	SIGNAL_HANDLER
	if(source != target)
		return

	INVOKE_ASYNC(src, PROC_REF(handle_right_click_async), target, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Since both radial and balloon alerts proc stoplag(), everything is in this proc for async invoking
/datum/element/ranged_mob_switcher/proc/handle_right_click_async(mob/living/simple_animal/hostile/target, list/modifiers)
	var/datum/ranged_mob_switcher_mode/mode = get_radial_menu_choice(target)
	if(!mode)
		return

	if(!do_after(target, switch_delay, target, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_TARGET_LOC_CHANGE, max_interact_count = 1, cancel_on_max = TRUE))
		target.balloon_alert(target, "сбито!")
		return

	target.balloon_alert(target, "успех!")
	apply_mode(mode, target)

/// Shows radial menu and returns type of chosen mode
/datum/element/ranged_mob_switcher/proc/get_radial_menu_choice(mob/living/simple_animal/hostile/target)
	var/list/final_radial_menu_list = radial_menu_list - find_current_mode_name(target)
	var/choice = show_radial_menu(target, target, final_radial_menu_list)
	if(!choice)
		return

	return mode_name_to_type[choice]

/// Finds what mode the mob currently has active (by checking proj_type and amount of shots), and returns the mode's name
/datum/element/ranged_mob_switcher/proc/find_current_mode_name(mob/living/simple_animal/hostile/target)
	var/projectiletype = target.projectiletype
	var/rapid_amount = target.rapid
	for(var/mode_type in possible_modes)
		var/datum/ranged_mob_switcher_mode/mode = mode_type
		if((projectiletype == mode::proj_type) && (rapid_amount = mode::amount))
			return mode::name

/// Applies a given mode to the target
/datum/element/ranged_mob_switcher/proc/apply_mode(datum/ranged_mob_switcher_mode/mode, mob/living/simple_animal/hostile/target)
	var/datum/ranged_mob_switcher_mode/chosen_mode = mode
	target.projectiletype = chosen_mode::proj_type
	target.ranged_cooldown_time = chosen_mode::cooldown
	target.rapid_fire_delay = chosen_mode::rapid_fire_delay
	target.rapid_spread = chosen_mode::rapid_fire_spread
	target.rapid = chosen_mode::amount
	target.projectilesound = chosen_mode::sound

/// Creates both of radial required lists.
/datum/element/ranged_mob_switcher/proc/create_radial_lists()
	for(var/mode_type in possible_modes)
		var/datum/ranged_mob_switcher_mode/mode = mode_type
		mode_name_to_type[mode::name] = mode_type
		radial_menu_list[mode::name] = image(icon = mode::icon, icon_state = mode::icon_state)
