//MARK: Presets for item actions
/datum/action/item_action
	name = "Item Action"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null

/datum/action/item_action/New(Target)
	. = ..()

	// If our button state is null, use the target's icon instead
	if(target && isnull(button_icon_state))
		AddComponent(/datum/component/action_item_overlay, target)

/datum/action/item_action/vv_edit_var(var_name, var_value)
	. = ..()
	if(!. || !target)
		return

	if(var_name == NAMEOF(src, button_icon_state))
		// If someone vv's our icon either add or remove the component
		if(isnull(var_name))
			AddComponent(/datum/component/action_item_overlay, target)
		else
			qdel(GetComponent(/datum/component/action_item_overlay))

/datum/action/item_action/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	return do_effect(trigger_flags)

/datum/action/item_action/proc/do_effect(trigger_flags)
	if(!target)
		return FALSE
	call_effect_proc()
	UpdateButtonIcon()
	return TRUE

/datum/action/item_action/proc/call_effect_proc()
	var/obj/item/item_target = target
	item_target.ui_action_click(owner, src)


// MARK: Actions

/datum/action/item_action/toggle_light
	name = "Переключить свет"

/datum/action/item_action/toggle_hood
	name = "Поднять/опустить капюшон"

/datum/action/item_action/toggle_firemode
	name = "Сменить режим огня"

/datum/action/item_action/toggle_defibrillator
	name = "Включить/выключить встроенный дефибриллятор"

/datum/action/item_action/startchainsaw
	name = "Дёрнуть стартовый шнур"

/datum/action/item_action/print_report
	name = "Печать отчёта"

/datum/action/item_action/print_forensic_report
	name = "Печать отчёта"
	button_icon_state = "scanner_print"

/datum/action/item_action/clear_records
	name = "Очистить записи сканера"

/datum/action/item_action/toggle_gunlight
	name = "Переключить тактический фонарь"

/datum/action/item_action/toggle_mode
	name = "Сменить режим"

/datum/action/item_action/toggle_barrier_spread
	name = "Переключить барье"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Экипировать/снять TED-пушку"

/datum/action/item_action/toggle_paddles
	name = "Взять электроды"

/datum/action/item_action/set_internals
	name = "Переключить баллон"

/datum/action/item_action/set_internals/is_action_active(atom/movable/screen/movable/action_button/current_button)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		return target == carbon_owner.internal
	return ..()

/datum/action/item_action/set_internals_ninja
	name = "Переключить баллон"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	background_icon_state_active = "background_green_active"

/datum/action/item_action/set_internals_ninja/is_action_active(atom/movable/screen/movable/action_button/current_button)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		return target == carbon_owner.internal
	return ..()

/datum/action/item_action/toggle_mister
	name = "Переключить распылитель"

/datum/action/item_action/toggle_helmet_light
	name = "Переключить фонарь шлема"

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Поднять/опустить сварочный щиток"

/datum/action/item_action/toggle_helmet_mode
	name = "Переключить режим костюма"

/datum/action/item_action/toggle_hardsuit_mode
	name = "Надеть/Снять шлем"

/datum/action/item_action/toggle_unfriendly_fire
	name = "Переключить дружественный огонь \[ВКЛ\]"
	desc = "Определяет, будут ли атаки посоха наносить урон союзникам."
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_backpack_light
	name = "Переключить мигалку на рюкзаке"

/datum/action/item_action/toggle_unfriendly_fire/do_effect(trigger_flags)
	if(..())
		UpdateButtonIcon()

/datum/action/item_action/toggle_unfriendly_fire/UpdateButtonIcon()
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_icon_state = "vortex_ff_off"
			name = "Переключить дружественный огонь \[ВЫКЛ\]"
		else
			button_icon_state = "vortex_ff_on"
			name = "Переключить дружественный огонь \[ВКЛ\]"
	..()

/datum/action/item_action/vortex_recall
	name = "Вихревой возврат"
	desc = "Телепортирует вас и ближайших существ к настроенному маяку иерофанта в любой момент.<br>Если маяк всё ещё прикреплён, он отсоединится."
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable(feedback = FALSE)
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.teleporting)
			return FALSE
	return ..()

/datum/action/item_action/change_headphones_song
	name = "Сменить трек в наушниках"

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Переключить [target]"

/datum/action/item_action/openclose

/datum/action/item_action/openclose/New(Target)
	..()
	name = "Открыть/Закрыть [target]"

/datum/action/item_action/button

/datum/action/item_action/button/New(Target)
	..()
	name = "Застегнуть/Расстегнуть [target]"

/datum/action/item_action/zipper

/datum/action/item_action/zipper/New(Target)
	..()
	name = "Застегнуть/Расстегнуть [target]"

/datum/action/item_action/activate

/datum/action/item_action/activate/New(Target)
	..()
	name = "Активировать [target]"

/datum/action/item_action/activate/enchant

/datum/action/item_action/activate/enchant/New(Target)
	..()
	UpdateButtonIcon()

/datum/action/item_action/halt
	name = "СТОЯТЬ!"

/datum/action/item_action/selectphrase
	name = "Сменить фразу"

/datum/action/item_action/hoot
	name = "Ухнуть"

/datum/action/item_action/caw
	name = "Каркнуть"

/datum/action/item_action/toggle_voice_box
	name = "Переключить голосовой модуль"

/datum/action/item_action/change
	name = "Изменить"

/datum/action/item_action/noir
	name = "Нуар"

/datum/action/item_action/YEEEAAAAAHHHHHHHHHHHHH
	name = "ОУ ДАА!"

/datum/action/item_action/laugh_track
	name = "Проиграть смех"

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Поднять/Опустить [target]"

/datum/action/item_action/pontificate
	name = "Крутить усы"

/datum/action/item_action/tip_fedora
	name = "Поправить федору"

/datum/action/item_action/flip_cap
	name = "Развернуть кепку"

/datum/action/item_action/switch_hud
	name = "Переключить ИЛС"

/datum/action/item_action/toggle_wings
	name = "Скрыть/показать крылья"

/datum/action/item_action/toggle_helmet
	name = "Надеть/снять шлем"

/datum/action/item_action/remove_tape
	name = "Снять скотч"

/datum/action/item_action/remove_tape/do_effect(trigger_flags)
	if(!target)
		return FALSE
	var/component = target.GetComponent(/datum/component/ducttape)
	if(component)
		usr.transfer_fingerprints_to(target)
		to_chat(usr, span_notice("Вы отрываете скотч от [target]!"))
		qdel(component)
		UpdateButtonIcon()
		return TRUE

/datum/action/item_action/toggle_jetpack
	name = "Переключить джетпак"

/datum/action/item_action/jetpack_stabilization
	name = "Переключить стабилизацию джетпака"

/datum/action/item_action/jetpack_stabilization/IsAvailable(feedback = FALSE)
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_jetpack/ninja
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	background_icon_state_active = "background_green_active"

/datum/action/item_action/toggle_jetpack/ninja/is_action_active(atom/movable/screen/movable/action_button/current_button)
	. = ..()
	var/obj/item/tank/jetpack/jetpack = target
	return istype(jetpack) && jetpack.on

/datum/action/item_action/jetpack_stabilization/ninja
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	background_icon_state_active = "background_green_active"

/datum/action/item_action/jetpack_stabilization/ninja/is_action_active(atom/movable/screen/movable/action_button/current_button)
	. = ..()
	var/obj/item/tank/jetpack/jetpack = target
	return istype(jetpack) && jetpack.stabilize


/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS
	var/recharge_text_color = "#FFFFFF"

/datum/action/item_action/hands_free/activate
	name = "Активировать"

/datum/action/item_action/hands_free/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	var/obj/item/implant/implant = target
	if(!istype(implant))
		button.maptext = ""
		//button.maptext_x = 2
	return button

/datum/action/item_action/hands_free/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	if(IsAvailable())
		button.maptext = ""
		return
	var/obj/item/implant/implant = target
	if(!istype(implant))
		button.maptext = ""
		return
	var/text = implant.cooldown_system.cooldown_info()
	button.maptext = MAPTEXT("<b>[text]</b>")

/datum/action/item_action/hands_free/activate/always
	check_flags = NONE

/datum/action/item_action/toggle_research_scanner
	name = "Переключить исследовательский анализатор"


/datum/action/item_action/toggle_research_scanner/do_effect(trigger_flags)
	if(!..())
		return FALSE

	owner.research_scanner = !owner.research_scanner
	to_chat(owner, span_notice("Вы [owner.research_scanner ? "включили" : "отключили"] исследовательский анализатор."))

	return TRUE


/datum/action/item_action/toggle_research_scanner/Remove(mob/living/L)
	if(owner)
		owner.research_scanner = 0

	. = ..()


// /datum/action/item_action/toggle_research_scanner/ApplyIcon()
// 	button.cut_overlays()
// 	var/static/mutable_appearance/new_icon = mutable_appearance('icons/mob/actions/actions.dmi', "scan_mode", BUTTON_LAYER_ICON, appearance_flags = RESET_COLOR|RESET_ALPHA)
// 	button.add_overlay(new_icon)

/datum/action/item_action/instrument
	name = "Использовать инструмент"
	desc = "Использовать указанный инструмент."

/datum/action/item_action/instrument/do_effect(trigger_flags)
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()


/datum/action/item_action/remove_badge
	name = "Снять голобейдж"

/datum/action/item_action/change_holotool_color
	name = "Сменить цвет голотула"

// MARK: Cleave attack
/datum/action/item_action/toggle_cleave_attack
	name = "Переключить режим атаки со взмахом"
	check_flags = NONE


/datum/action/item_action/toggle_cleave_attack/is_action_active(atom/movable/screen/movable/action_button/current_button)
	. = ..()
	return !HAS_TRAIT(target, TRAIT_CLEAVE_BLOCKED)


/datum/action/item_action/toggle_cleave_attack/do_effect(trigger_flags)
	if(!target)
		return

	if(HAS_TRAIT_NOT_FROM(target, TRAIT_CLEAVE_BLOCKED, BUTTON_TRAIT))
		to_chat(usr, span_warning("Включение атаки со взмахом заблокировано."))
		return

	var/has_trait = HAS_TRAIT_FROM(target, TRAIT_CLEAVE_BLOCKED, BUTTON_TRAIT)

	if(has_trait)
		REMOVE_TRAIT(target, TRAIT_CLEAVE_BLOCKED, BUTTON_TRAIT)
	else
		ADD_TRAIT(target, TRAIT_CLEAVE_BLOCKED, BUTTON_TRAIT)

	UpdateButtonIcon()
	to_chat(usr, span_notice("Вы [!has_trait ? "включаете" : "отключаете"] атаку со взмахом."))


// MARK: Jump boots
/datum/action/item_action/bhop
	name = "Активировать прыжковые ботинки"
	desc = "Активирует систему прыжков, позволяя преодолевать препятствия шириной до 4 тайлов."
	button_icon_state = "jetboot"

/datum/action/item_action/bhop/clown
	name = "Активировать хонк-ботинки"
	desc = "Активирует хонк-систему, позволяя перепрыгивать препятствия шириной до 6 тайлов."
	button_icon_state = "clown"

/datum/action/item_action/gravity_jump
	name = "Гравитационный прыжок"
	desc = "Направляет импульс гравитации перед пользователем, придавая ему ускорение."

/datum/action/item_action/gravity_jump/do_effect(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/clothing/shoes/magboots/gravity/G = target
	G.dash(usr)

/datum/action/item_action/toggle_rapier_nodrop
	name = "Переключить Антидроп"
	desc = "Активирует/деактивирует систему предотвращения выпадения рапиры."

///prset for organ actions
/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable(feedback = FALSE)
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Переключить [target]"

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Использовать [target]"

/datum/action/item_action/voice_changer/toggle
	name = "Переключить исказитель голоса"

/datum/action/item_action/voice_changer/voice
	name = "Установить голос"

/datum/action/item_action/voice_changer/voice/do_effect(trigger_flags)
	if(!IsAvailable())
		return FALSE

	var/obj/item/voice_changer/V = target
	V.set_voice(usr)

// for clothing accessories like holsters
/datum/action/item_action/accessory

/datum/action/item_action/accessory/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	var/obj/target_obj = target
	if(istype(target_obj))
		if(target_obj.loc == owner)
			return TRUE
		if(istype(target_obj.loc, /obj/item/clothing/under) && target_obj.loc.loc == owner)
			return TRUE
	return FALSE

/datum/action/item_action/accessory/holster
	name = "Кобура"

/datum/action/item_action/accessory/holobadge
	name = "Голобейдж"

/datum/action/item_action/accessory/storage
	name = "Просмотр хранилища"

/datum/action/item_action/accessory/petcollar
	name = "Извлечь ID"

/datum/action/item_action/accessory/herald
	name = "Зеркальный переход"
	desc = "Используйте рядом с зеркалом, чтобы войти в него."

/datum/action/item_action/accessory/mining_camera
	name = "Переключить камеру"


//MARK: Advanced item action
// This item actions have their own charges/cooldown system like spell procholders, but without all the unnecessary magic stuff
/datum/action/item_action/advanced
	var/recharge_text_color = "#FFFFFF"
	var/charge_type = ADV_ACTION_TYPE_RECHARGE //can be recharge, toggle, toggle_recharge or charges, see description in the defines file
	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or "toggle_recharge", alternatively counts as starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only use if it equals "recharge" or "toggle_recharge", ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/starts_charged = TRUE //Does this action start ready to go?
	var/still_recharging_msg = span_notice(" действие всё ещё перезаряжается.")
	//toggle and toggle_recharge stuff
	var/action_ready = TRUE //Only for toggle and toggle_recharge charge_type. Toggle it via code yourself. Haha 'toggle', get it?
	var/icon_state_active = "bg_default_on"	//What icon_state we switch to when we toggle action active in "toggle" actions
	var/icon_state_disabled = "bg_default"	//Old icon_state we switch to when we toggle action back in "toggle" actions
	//cooldown overlay stuff
	var/coold_overlay_icon = 'icons/mob/screen_white.dmi'
	var/coold_overlay_icon_state = "template"
	var/no_count = FALSE  // This means that the action is charged but unavailable due to something else
	var/wait_time = 2 SECONDS // Prevents spamming the button. Only for "charges" type actions
	var/last_use_time = null

/datum/action/item_action/advanced/New()
	. = ..()
	still_recharging_msg = span_notice("[name] всё ещё перезаряжается.")
	icon_state_disabled = background_icon_state
	last_use_time = world.time
	if(charge_type == ADV_ACTION_TYPE_CHARGES)
		UpdateButtonIcon()
	if(starts_charged)
		charge_counter = charge_max
	else
		start_recharge()

/datum/action/item_action/advanced/proc/start_recharge()
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/item_action/advanced/process()
	charge_counter += 2
	UpdateButtonIcon()
	if(charge_counter < charge_max)
		return
	STOP_PROCESSING(SSfastprocess, src)
	action_ready = TRUE
	charge_counter = charge_max

/datum/action/item_action/advanced/proc/recharge_action() //resets charge_counter or readds one charge
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE)	//this type doesn't use those var's, but why not
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter++
			UpdateButtonIcon()

/datum/action/item_action/advanced/proc/use_action()
	if(!IsAvailable(feedback = TRUE))
		return
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_TOGGLE)
			toggle_button_on_off()
			action_ready = !action_ready
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			charge_counter = 0
			start_recharge()
		if(ADV_ACTION_TYPE_CHARGES)
			charge_counter--
			last_use_time = world.time
			UpdateButtonIcon()

/* Basic availability checks in this proc.
 * Arguments:
 * feedback - Do we show recharging message to the caller?
 */
/datum/action/item_action/advanced/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter < charge_max)
				if(feedback)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(charge_counter < charge_max)
				if(feedback)
					to_chat(owner, still_recharging_msg)
				return FALSE
		if(ADV_ACTION_TYPE_CHARGES)
			if(world.time < last_use_time + wait_time)
				if(feedback)
					to_chat(owner, span_warning("[name] уже используется."))
				return FALSE
			if(!charge_counter)
				if(feedback)
					to_chat(owner, span_notice("[name] разряжен."))
				return FALSE
	return TRUE

/datum/action/item_action/advanced/proc/get_availability_percentage()
	switch(charge_type)
		if(ADV_ACTION_TYPE_RECHARGE)
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_TOGGLE_RECHARGE)
			if(action_ready)
				return 1
			if(charge_counter == 0)
				return 0
			if(charge_max == 0)
				return 1
			return charge_counter / charge_max
		if(ADV_ACTION_TYPE_CHARGES)
			if(charge_counter)
				return 1
			return 0

/datum/action/item_action/advanced/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext = ""
	return button

/datum/action/item_action/advanced/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	if(charge_type != ADV_ACTION_TYPE_CHARGES)
		return
	button.maptext = MAPTEXT("<b>[charge_counter]/[charge_max]</b>")

	//visuals only
/datum/action/item_action/advanced/proc/toggle_button_on_off()
	if(!action_ready)
		icon_state_disabled = background_icon_state
		background_icon_state = "[background_icon_state]_on"
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()


//Ninja action type
/datum/action/item_action/advanced/ninja
	coold_overlay_icon = 'icons/mob/actions/actions_ninja.dmi'
	coold_overlay_icon_state = "background_green"
	background_icon = 'icons/mob/actions/actions_ninja.dmi'
	icon_state_active = "background_green_active"
	icon_state_disabled = "background_green"
	var/action_initialisation_text = null

/datum/action/item_action/advanced/ninja/New(Target)
	. = ..()
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target
	if(istype(ninja_suit))
		recharge_text_color = ninja_suit.color_choice
		coold_overlay_icon_state = "background_[ninja_suit.color_choice]"

/datum/action/item_action/advanced/ninja/IsAvailable(feedback = FALSE)
	if(!target && !istype(target, /obj/item/clothing/suit/space/space_ninja))
		return FALSE
	return ..()

/datum/action/item_action/advanced/ninja/toggle_button_on_off()
	if(action_ready)
		background_icon_state = icon_state_active
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()
