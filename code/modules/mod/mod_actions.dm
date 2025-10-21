/datum/action/item_action/mod
	background_icon_state = "bg_mod"
	button_icon_state = "bg_mod_border"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	use_itemicon = FALSE

/datum/action/item_action/mod/New(Target, custom_icon, custom_icon_state)
	..()
	if(!ismodcontrol(Target))
		stack_trace("invalid target([Target]) for modsuit action.")
		qdel(src)

/datum/action/item_action/mod/Trigger(left_click, attack_self)
	if(!IsAvailable())
		return FALSE
	var/obj/item/mod/control/mod = target
	if(mod.malfunctioning && prob(75))
		usr.balloon_alert(usr, "сбой активации!")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Развернуть модульный костюм"
	desc = "ЛКМ — развернуть или свернуть все компоненты модульного костюма. СКМ — развернуть/свернуть определённый компонент."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	if(left_click)
		mod.quick_deploy(usr)
	else
		mod.choose_deploy(usr)

/datum/action/item_action/mod/activate
	name = "Активировать модульный костюм"
	desc = "ЛКМ — активировать модульный костюм с необходимостью дополнительного подтверждения. СКМ — мгновенная активация."
	button_icon_state = "activate"
	/// First time clicking this will set it to TRUE, second time will activate it.
	var/ready = FALSE

/datum/action/item_action/mod/activate/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	if(!ready && left_click)
		ready = TRUE
		button_icon_state = "activate-ready"
		UpdateButtonIcon()
		addtimer(CALLBACK(src, PROC_REF(reset_ready)), 3 SECONDS)
		return
	var/obj/item/mod/control/mod = target
	reset_ready()
	mod.toggle_activate(usr)

/// Resets the state requiring to be doubleclicked again.
/datum/action/item_action/mod/activate/proc/reset_ready()
	ready = FALSE
	button_icon_state = initial(button_icon_state)
	UpdateButtonIcon()

/datum/action/item_action/mod/module
	name = "Активировать модуль"
	desc = "Активировать модуль МЭК."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.quick_module(usr)

/datum/action/item_action/mod/panel
	name = "Панель управления МЭК"
	desc = "Включить панель управления модульным костюмом."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = target
	mod.ui_interact(usr)

/datum/action/item_action/mod/pinned_module
	desc = "Активировать модуль"
	icon_icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	button_icon_state = "module"
	/// Module we are linked to.
	var/obj/item/mod/module/module
	/// A ref to the mob we are pinned to.
	var/pinner_uid
	/// Timer until we remove our cooldown overlay
	var/cooldown_timer

/datum/action/item_action/mod/pinned_module/New(Target, custom_icon, custom_icon_state, obj/item/mod/module/linked_module, mob/user)
	name = "Активировать [linked_module.declent_ru(ACCUSATIVE)]"
	desc = "Быстрая активация [linked_module.declent_ru(GENITIVE)]"
	..()
	module = linked_module
	button_icon_state = module.icon_state
	if(!(linked_module.allow_flags & MODULE_ALLOW_INCAPACITATED))
		check_flags |= AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED
	Grant(user)
	RegisterSignal(linked_module, COMSIG_MODULE_COOLDOWN_STARTED, PROC_REF(cooldown_started))

/datum/action/item_action/mod/pinned_module/Destroy()
	deltimer(cooldown_timer)
	UnregisterSignal(module, list(COMSIG_MODULE_ACTIVATED, COMSIG_MODULE_DEACTIVATED, COMSIG_MODULE_USED, COMSIG_MODULE_COOLDOWN_STARTED))
	module.pinned_to -= pinner_uid
	module = null
	return ..()

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	var/user_uid = user.UID()
	if(!pinner_uid)
		pinner_uid = user_uid
		module.pinned_to[pinner_uid] = src
	else if(pinner_uid != user_uid)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger(left_click, attack_self)
	. = ..()
	if(!.)
		return
	module.on_select()

/datum/action/item_action/mod/pinned_module/proc/cooldown_started(datum/source, cooldown_time)
	SIGNAL_HANDLER

	deltimer(cooldown_timer)
	UpdateButtonIcon()
	if(cooldown_time == 0)
		return
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon)), cooldown_time + 1, TIMER_STOPPABLE)

/datum/action/item_action/mod/pinned_module/IsAvailable()
	if(..() && COOLDOWN_FINISHED(module, cooldown_timer))
		return TRUE
	return FALSE
