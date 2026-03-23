/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'// figure out how to work with 2 of these

/obj/item/mod/control
	name = "MOD control unit"
	desc = "Устройство управления модульным экзокостюмом — высокотехнологичной бронёй, используемой для защиты пользователя от опасной внешней среды."
	icon_state = "standard-control"
	item_state = "mod_control"
	base_icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	actions_types = list(
		/datum/action/item_action/mod/deploy,
		/datum/action/item_action/mod/activate,
		/datum/action/item_action/mod/panel,
		/datum/action/item_action/mod/module,
	)
	onmob_sheets = list(
		ITEM_SLOT_BACK_STRING = 'icons/mob/clothing/modsuit/mod_clothing.dmi',
	)
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	siemens_coefficient = 0.5
	var/datum/wires/mod/wires

	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"
	/// Theme of the MOD TGUI
	var/ui_theme = "ntos"
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = 0
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// Power usage of the MOD.
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when all of its pieces are deployed.
	var/slowdown_deployed = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD core.
	var/obj/item/mod/core/core
	/// List of MODsuit part datums.
	var/list/mod_parts = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer
	/// Internal storage in a modsuit.
	var/obj/item/storage/backpack/modstorage/bag
	/// Is it EMP proof?
	var/emp_proof = FALSE
	/// List of overlays the mod has. Needs to be cut onremoval / module deactivation
	var/list/mod_overlays = list()
	/// Is the jetpack on so we should make ion effects?
	var/jetpack_active = FALSE
	/// Cham option for when the cham module is installed.
	var/datum/action/item_action/chameleon/change/modsuit/chameleon_action
	/// Is the control unit disquised?
	var/current_disguise = FALSE
	/// AI or pAI mob inhabiting the MOD.
	var/mob/living/silicon/ai_assistant


/obj/item/mod/control/get_ru_names()
	return list(
		NOMINATIVE = "блок управления МЭК",
		GENITIVE = "блока управления МЭК",
		DATIVE = "блоку управления МЭК",
		ACCUSATIVE = "блок управления МЭК",
		INSTRUMENTAL = "блоком управления МЭК",
		PREPOSITIONAL = "блоке управления МЭК"
	)

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	if(new_theme)
		theme = new_theme
	theme = GLOB.mod_themes[theme]
	theme.set_up_parts(src, new_skin)
	for(var/obj/item/part as anything in get_parts())
		RegisterSignal(part, COMSIG_PREQDELETED, PROC_REF(on_part_destruction))
	wires = new/datum/wires/mod(src)
	if(length(req_access))
		locked = TRUE
	new_core?.install(src)
	update_speed()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	for(var/obj/item/mod/module/module as anything in theme.inbuilt_modules)
		module = new module(src)
		install(module)
	START_PROCESSING(SSobj, src)

/obj/item/mod/control/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	if(core)
		QDEL_NULL(core)
	for(var/part_key in mod_parts)
		var/datum/mod_part/part_datum = mod_parts[part_key]
		mod_parts -= part_key
		qdel(part_datum)
	QDEL_NULL(wires)
	return ..()

/obj/item/mod/control/examine(mob/user)
	. = ..()
	if(active)
		. += "[core ? span_notice("Заряд: [get_charge_percent()]%") : span_warning("<b>ОШИБКА:</b> Ядро отсутствует")]."
		. += span_notice("Выбранный модуль: [selected_module?.declent_ru(NOMINATIVE) || "Модуль не выбран"].")
	if(!open && !active)
		if(!wearer)
			. += span_notice("Чтобы начать работу с модульным костюмом, наденьте его.")
		. += span_notice("Вы можете открыть крышку, <b>открутив винты</b>.")
	else if(open)
		. += span_notice("Вы можете открыть крышку, <b>открутив винты</b>.")
		. += span_notice("Вы можете установить дополнительные <b>модули</b> внутрь, если для них есть место.")
		. += span_notice("Вы можете извлечь лишние модули, <b>поддев</b> их.")
		. += span_notice("Вы можете установить блокировку по уровню доступа с помощью <b>ID-карты</b>.")
		. += span_notice("Вы можете получить доступ к проводам с помощью любого <b>подходящего инструмента</b>.")
		if(core)
			. += span_notice("Вы можете извлечь [core.declent_ru(ACCUSATIVE)], <b>ослабив болты</b>.")
		else
			. += span_notice("Слот для ядра пуст.")

/obj/item/mod/control/get_description_info()
	if(extended_desc)
		return extended_desc
	return

/obj/item/mod/control/process()
	if(seconds_electrified > 0)
		seconds_electrified--
	if(!active)
		return
	if(get_charge() <= 10 && !activating) //Sometimes we get power being funky, this should fix it.
		power_off()
		return PROCESS_KILL
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1, 20)
	subtract_charge((charge_drain + malfunctioning_charge_drain))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && prob(5))
			module.on_deactivation(display_message = TRUE)
		module.on_process()

/obj/item/mod/control/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BACK)
		set_wearer(user)
		return
	if(!wearer)
		return

	unset_wearer()

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/mod/control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()

/obj/item/mod/control/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/carbon_mob = usr
	if(get_dist(usr, src) > 1) //1 as we want to access it if beside the user
		return

	if(!over)
		return

	if(ismecha(carbon_mob.loc))
		return

	if(HAS_TRAIT(carbon_mob, TRAIT_RESTRAINED) || carbon_mob.stat) //restrained or unconsious
		return

	playsound(loc, SFX_RUSTLE, 50, TRUE, -5)

	if(istype(over, /atom/movable/screen/inventory/hand))
		for(var/obj/item/part as anything in get_parts())
			if(part.loc != src)
				balloon_alert(wearer, "сверните костюм!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
				return
		if(!carbon_mob.temporarily_remove_item_from_inventory(src, silent = TRUE))
			return
		carbon_mob.put_in_any_hand_if_possible(src, TRUE)
	else if(bag)
		bag.forceMove(usr)
		bag.show_to(usr)

	add_fingerprint(carbon_mob)

// Grant pinned actions to pin owners, gives AI pinned actions to the AI and not the wearer
/obj/item/mod/control/grant_action_to_bearer(datum/action/action)
	if(!istype(action, /datum/action/item_action/mod/pinnable))
		return ..()
	var/datum/action/item_action/mod/pinnable/pinned = action
	give_item_action(action, pinned.pinner, slot_flags)

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(..())
		return TRUE
	if(seconds_electrified && get_charge() && shock(user))
		return TRUE
	if(open)
		if(!core)
			balloon_alert(user, "ядро отсутствует!")
			return TRUE
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			return TRUE
		if(!core)
			return TRUE
		wrench.play_tool_sound(src, 100)
		core.forceMove(drop_location())
		update_charge_alert()
		return TRUE
	return ..()

/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(..())
		return TRUE
	if(active || activating || locate(/mob/living/silicon/ai) in src)
		balloon_alert(user, "выключите костюм!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	screwdriver.play_tool_sound(src, 100)
	if(screwdriver.use_tool(src, user))
		if(active || activating)
			balloon_alert(user, "выключите костюм!")
			return FALSE
		playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE, -3)
		balloon_alert(user, "крышка [open ? "закрыта" : "открыта"]")
		open = !open
	return TRUE

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!open)
		balloon_alert(user, "откройте крышку!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!allowed(user))
		balloon_alert(user, "нет доступа!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(seconds_electrified && get_charge() && shock(user))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules[DECLENT_RU_CAP(module, NOMINATIVE)] = module
		if(!length(removable_modules))
			return
		var/choosen_module = tgui_input_list(user, "Какой модуль вы хотите извлечь?", "Удаление модулей", removable_modules)
		var/obj/item/mod/module/module_to_remove = removable_modules?[choosen_module]
		if(!module_to_remove || !module_to_remove.mod)
			return FALSE
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
		return TRUE
	balloon_alert(user, "нет модулей!")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/obj/item/mod/control/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			balloon_alert(user, "откройте крышку!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		install(attacking_item, user)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
		return ATTACK_CHAIN_PROCEED
	if(ismodcore(attacking_item))
		if(!open)
			balloon_alert(user, "откройте крышку!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		if(core)
			balloon_alert(user, "слот для ядра занят!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		var/obj/item/mod/core/attacking_core = attacking_item
		balloon_alert(user, "ядро установлено")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		user.drop_from_active_hand()
		attacking_core.install(src)
		update_charge_alert()
		return ATTACK_CHAIN_PROCEED
	if(ismultitool(attacking_item) && open)
		if(seconds_electrified && get_charge() && shock(user))
			return ATTACK_CHAIN_PROCEED
		wires.Interact(user)
		return ATTACK_CHAIN_PROCEED
	if(open && attacking_item.GetID())
		update_access(user, attacking_item.GetID())
		return ATTACK_CHAIN_PROCEED
	if(iscell(attacking_item))
		if(!core)
			balloon_alert(user, "ядро отсутствует!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		core.on_attackby(attacking_item, user, params)
		return ATTACK_CHAIN_PROCEED
	if(istype(attacking_item, /obj/item/stack/ore/plasma) || istype(attacking_item, /obj/item/stack/sheet/mineral/plasma))
		if(!core)
			balloon_alert(user, "ядро отсутствует!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return ATTACK_CHAIN_BLOCKED_ALL
		core.on_attackby(attacking_item, user, params)
	if(istype(attacking_item, /obj/item/mod/skin_applier))
		return ..()
	if(bag && istype(attacking_item))
		bag.forceMove(user)
		bag.attackby(attacking_item, user, params)

	return ..()

/obj/item/mod/control/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		if(!bag)
			return
		bag.forceMove(user)
		bag.show_to(user)
	else
		..()


/obj/item/mod/control/click_alt(mob/user)
	. = ..()
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated(FALSE, TRUE) || !bag)
		return
	bag.forceMove(user)
	bag.show_to(user)
	playsound(loc, SFX_RUSTLE, 50, TRUE, -5)
	add_fingerprint(user)
	return CLICK_ACTION_SUCCESS

/obj/item/mod/control/attack_ghost(mob/user)
	if(isobserver(user) && bag)
		bag.show_to(user)
		return
	return ..()

/obj/item/mod/control/proc/can_be_inserted(I, stop_messages)
	if(bag)
		return bag.can_be_inserted(I, stop_messages)
	return FALSE

/obj/item/mod/control/proc/handle_item_insertion(I, prevent_warning)
	if(bag)
		bag.handle_item_insertion(I, prevent_warning)

/obj/item/mod/control/get_cell()
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/control/GetAccess()
	if(locate(/mob/living/silicon/ai) in src)
		return req_access.Copy()
	return ..()

/obj/item/mod/control/emag_act(mob/user)
	locked = !locked
	balloon_alert(user, "доступ [locked ? "требуется" : "не требуется"]")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, span_warning("Зафиксирован [severity > 1 ? "слабый" : "мощный"] всплеск ЭМИ!"))
	if(emp_proof)
		return
	selected_module?.on_deactivation(display_message = TRUE)
	wearer.apply_damage(10 / severity, BURN) //Test this with ion shotguns.
	to_chat(wearer, span_danger("Костюм начинает резко нагреваться от ЭМИ, обжигая вас!"))
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")
	core.emp_act(severity)
	if(prob(50 / severity))
		wires.emp_pulse() //3 wires get pulsed. Dangerous to a mod user.
	for(var/obj/item/mod/module/holster/H in modules)
		H.holstered?.emp_act(severity)
	if(bag)
		bag.emp_act(severity)

/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(!wearer)
		return
	clean_up()

/obj/item/mod/control/update_icon_state()
	if(current_disguise || isnull(chameleon_action) || active)
		icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"

/obj/item/mod/control/proc/get_parts(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part.part_item

/obj/item/mod/control/proc/get_part_datums(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part

/obj/item/mod/control/proc/get_part_datum(obj/item/part)
	RETURN_TYPE(/datum/mod_part)
	var/datum/mod_part/potential_part = mod_parts["[part.slot_flags]"]
	if(potential_part?.part_item == part)
		return potential_part
	for(var/datum/mod_part/mod_part in get_part_datums())
		if(mod_part.part_item == part)
			return mod_part
	CRASH("get_part_datum called with incorrect item [part] passed.")

/obj/item/mod/control/proc/get_part_from_slot(slot)
	RETURN_TYPE(/obj/item)
	return get_part_datum_from_slot(slot)?.part_item

/obj/item/mod/control/proc/get_part_datum_from_slot(slot)
	RETURN_TYPE(/datum/mod_part)
	for(var/part_key in mod_parts)
		if(text2num(part_key) & slot)
			return mod_parts[part_key]

/obj/item/mod/control/proc/set_wearer(mob/living/carbon/human/user)
	if(wearer == user)
		CRASH("set_wearer() was called with the new wearer being the current wearer: [wearer]")
	else if(!isnull(wearer))
		stack_trace("set_wearer() was called with a new wearer without unset_wearer() being called")

	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(wearer, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))
	RegisterSignal(wearer, COMSIG_MOB_CLICKON, PROC_REF(click_on))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN, COMSIG_MOB_CLICKON))
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/obj/item/mod/control/proc/get_sealed_slots(list/parts)
	var/covered_slots = NONE
	for(var/obj/item/part as anything in parts)
		if(!get_part_datum(part).sealed)
			parts -= part
			continue
		covered_slots |= part.slot_flags
	return covered_slots

/obj/item/mod/control/proc/clean_up()
	if(QDELING(src))
		unset_wearer()
		return
	if(active || activating)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.active)
				continue
			module.deactivate(display_message = FALSE)
		for(var/obj/item/part as anything in get_parts())
			seal_part(part, is_sealed = FALSE)
	for(var/obj/item/part as anything in get_parts())
		if(part.loc == src)
			continue
		INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after
	if(active)
		control_activation(is_on = FALSE)
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.drop_from_active_hand()
	old_wearer.clear_alert("mod_charge")

/obj/item/mod/control/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species, pref_load, regenerate_icons)
	SIGNAL_HANDLER

	return

	// for(var/obj/item/part in get_parts(all = TRUE))
	// 	if(!(new_species.no_equip_flags & part.slot_flags) || is_type_in_list(new_species, part.species_exception))
	// 		continue
	// 	forceMove(drop_location())
	// 	return

/obj/item/mod/control/proc/click_on(mob/source, atom/A, list/modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(modifiers, CTRL_CLICK) && LAZYACCESS(modifiers, MIDDLE_CLICK))
		INVOKE_ASYNC(src, PROC_REF(quick_module), source, get_turf(A))
		return COMSIG_MOB_CANCEL_CLICKON

/obj/item/mod/control/proc/quick_module(mob/user, anchor_override = null)
	if(!length(modules))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[DECLENT_RU_CAP(module, NOMINATIVE)] = module.UID()
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown"))
		items += list(DECLENT_RU_CAP(module, NOMINATIVE) = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc) //they're phased out via some module, anchor the radial on the turf so it may still display
	if(!isnull(anchor_override))
		radial_anchor = anchor_override
	var/pick = show_radial_menu(user, radial_anchor, items, require_near = isnull(anchor_override))
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locateUID(module_reference)
	if(!istype(picked_module))
		return
	picked_module.on_select()

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 0.7, check_range)

/// Additional checks for whenever a module can be installed into a suit or not
/obj/item/mod/module/proc/can_install(obj/item/mod/control/mod)
	return TRUE

/obj/item/mod/control/proc/install(obj/item/mod/module/new_module, mob/user)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				to_chat(user, span_warning("[DECLENT_RU_CAP(new_module, NOMINATIVE)] несовместим с [old_module.declent_ru(INSTRUMENTAL)]!"))
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			to_chat(user, span_warning("[DECLENT_RU_CAP(new_module, NOMINATIVE)] превышает максимальную комплексность костюма!"))
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(!new_module.has_required_parts(mod_parts))
		if(user)
			balloon_alert(user, "некуда установить!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(!new_module.can_install(src))
		if(user)
			balloon_alert(user, "невозможно!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(user && !user.drop_from_active_hand())
		to_chat(user, span_warning("[DECLENT_RU_CAP(new_module, NOMINATIVE)] застрева[PLUR_ET_UT(new_module)] у вас в руке!"))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
	if(active && new_module.has_required_parts(mod_parts, need_active = TRUE))
		new_module.on_part_activation()
		new_module.part_activated = TRUE
	if(user)
		to_chat(user, span_notice("[DECLENT_RU_CAP(new_module, NOMINATIVE)] добавлен!")) //they all are "модуль чего-то там.", genderizing is unnecessary
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(wearer)
		old_module.on_unequip()
	if(active)
		old_module.on_part_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.deactivate(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	old_module.mod = null

/// Intended for callbacks, don't use normally, just get wearer by itself.
/obj/item/mod/control/proc/get_wearer()
	return wearer

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "нет доступа!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "доступ обновлён!")

/obj/item/mod/control/proc/get_charge_source()
	return core?.charge_source()

/obj/item/mod/control/proc/get_charge()
	return core?.charge_amount() || 0

/obj/item/mod/control/proc/get_max_charge()
	return core?.max_charge_amount() || 1 //avoid dividing by 0

/obj/item/mod/control/proc/get_charge_percent()
	return ((get_charge() / get_max_charge()) * 100)

/obj/item/mod/control/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/obj/item/mod/control/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/obj/item/mod/control/proc/check_charge(amount)
	return core?.check_charge(amount) || FALSE

/obj/item/mod/control/proc/get_chargebar_color()
	return core?.get_chargebar_color() || "transparent"

/obj/item/mod/control/proc/get_chargebar_string()
	return core?.get_chargebar_string() || "Ядро не обнаружено"

/**
 * Updates the wearer's hud according to the current state of the MODsuit
 */
/obj/item/mod/control/proc/update_charge_alert()
	if(isnull(wearer))
		return
	if(!core)
		wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocell)
		return
	core.update_charge_alert()

/obj/item/mod/control/proc/update_speed()
	var/total_slowdown = 0
	total_slowdown += slowdown_deployed

	var/list/module_slowdowns = list()
	SEND_SIGNAL(src, COMSIG_MOD_UPDATE_SPEED, module_slowdowns)
	for(var/module_slow in module_slowdowns)
		total_slowdown += module_slow

	for(var/datum/mod_part/part_datum as anything in get_part_datums(all = TRUE))
		var/obj/item/part = part_datum.part_item
		part.slowdown = total_slowdown / length(mod_parts)
		if(!part_datum.sealed)
			part.slowdown = max(part.slowdown, 0)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/power_off()
	balloon_alert(wearer, "батарея разряжена!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/set_mod_color(new_color)
	for(var/obj/item/part as anything in get_parts(TRUE))
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(!(part in get_parts()))
		return
	if(QDELING(part) && !QDELING(src))
		qdel(src)
		return
	var/datum/mod_part/part_datum = get_part_datum(part)
	if(part_datum.sealed)
		seal_part(part, is_sealed = FALSE)
	if(isnull(part.loc))
		return
	if(!wearer)
		part.forceMove(src)
		return
	INVOKE_ASYNC(src, PROC_REF(retract), wearer, part, TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after

/obj/item/mod/control/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(QDELING(src))
		return

	var/atom/visible_atom = wearer || src
	if(wearer)
		clean_up()
	visible_atom.visible_message(span_bolddanger("[DECLENT_RU_CAP(src, NOMINATIVE)] разваливается на глазах!"))
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	// if(ai_assistant)
	// 	if(ispAI(ai_assistant))
	// 		INVOKE_ASYNC(src, PROC_REF(remove_pai), /* user = */ null, /* forced = */ TRUE) // async to appease spaceman DMM because the branch we don't run has a do_after
	// 	else
	// 		for(var/datum/action/action as anything in actions)
	// 			if(action.owner == ai_assistant)
	// 				action.Remove(ai_assistant)
	// 		new /obj/item/mod/ai_minicard(drop_location(), ai_assistant)

/obj/item/mod/control/proc/on_overslot_exit(obj/item/part, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	var/datum/mod_part/part_datum = get_part_datum(part)
	if(overslot != part_datum.overslotting)
		return
	UnregisterSignal(part, COMSIG_ATOM_EXITED)
	part_datum.overslotting = null

// /obj/item/mod/control/proc/get_visor_overlay(mutable_appearance/standing)
// 		var/list/overrides = list()
// 		SEND_SIGNAL(src, COMSIG_MOD_GET_VISOR_OVERLAY, standing, overrides)
// 		if(length(overrides))
// 			return overrides[1]
// 		return mutable_appearance(worn_icon, "[skin]-helmet-visor", layer = standing.layer + 0.1)

/obj/item/mod/control/extinguish_light(force)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		module.extinguish_light(force)
