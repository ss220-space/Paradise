#define SECSPEAR_BLOCK_CHANCE 30

/obj/item/twohanded/spear/secspear
	name = "telescopic energy spear"
	desc = "Телескопическое энергокопье, разработанное для офицеров службы безопасности. \
			При активации создает стабильное лезвие из чистой плазмы, обладающее различными свойствами, в зависимости от выбранного режима. \
			Применяется в тех случаях, когда энергетическое и огнестрельное оружие дальнего боя не подходит для выполнения задачи."
	throwforce = 10
	embed_chance = 0
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "secspear"
	base_icon_state = "secspear"
	sharp = FALSE
	materials = null
	block_type = MELEE_ATTACKS
	icon = 'icons/obj/secspear.dmi'
	actions_types = list(/datum/action/item_action/switch_spear_mode, /datum/action/item_action/toggle_folded)
	var/folded = TRUE
	var/fold_sound = 'sound/weapons/batonextend.ogg'
	var/datum/secspear_mode/spear_mode = /datum/secspear_mode/off
	/// Cell to use, can be a path, to start loaded.
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/super

/obj/item/twohanded/spear/secspear/get_ru_names()
	return list(
		NOMINATIVE = "телескопическое энергетическое копьё",
		GENITIVE = "телескопического энергетического копья",
		DATIVE = "телескопическому энергетическому копью",
		ACCUSATIVE = "телескопическое энергетическое копьё",
		INSTRUMENTAL = "телескопическим энергетическим копьём",
		PREPOSITIONAL = "телескопическом энергетическом копье",
	)

/obj/item/twohanded/spear/secspear/Initialize(mapload)
	cell = new cell(src)
	add_traits(list(TRAIT_TWOHANDED_BLOCKED, TRAIT_CLEAVE_BLOCKED), UNIQUE_TRAIT_SOURCE(src))
	. = ..()
	spear_mode = GLOB.secspear_modes[spear_mode.name]
	spear_mode.on_activate(src)
	update_icon()

/obj/item/twohanded/spear/secspear/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Зарад батареи [round(cell.percent())]%.")
	else
		. += span_warning("Батарея не установлена.")


/obj/item/twohanded/spear/secspear/update_icon_state()
	var/state = "secspear[folded? "_folded" : ""]"
	icon_state = state
	item_state = "[state][wielded? "_wielded" : ""]"

/obj/item/twohanded/spear/secspear/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[icon_state][istype(cell)? "_battery" : ""]")
	. += mutable_appearance(icon, "[icon_state][spear_mode.overlay_prefix]")

/obj/item/twohanded/spear/secspear/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()

	if(!isinhands)
		return

	. += mutable_appearance(icon_file, "[item_state][spear_mode.overlay_prefix]")

/obj/item/twohanded/spear/secspear/emp_act(severity)
	. = ..()
	cell.emp_act(severity)

/obj/item/twohanded/spear/secspear/attackby(obj/item/I, mob/user, params)
	if(iscell(I))
		var/obj/item/stock_parts/cell/new_cell = I

		if(new_cell.maxcharge < spear_mode.power_cost)
			balloon_alert(user, "энергоёмкость недостаточна!")
			return ATTACK_CHAIN_PROCEED

		to_chat(user, span_notice("Вы начинаете подключать [new_cell.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]"))

		if(!do_after(user, 10 SECONDS, src))
			return

		if(!user.drop_transfer_item_to_loc(new_cell, src))
			return ..()

		cell.forceMove(get_turf(src))
		cell = new_cell
		balloon_alert(user, "установлено")
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/twohanded/spear/secspear/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim)
	. = ..()

	if(!(. & ATTACK_CHAIN_SUCCESS))
		return

	power_usage()

/obj/item/twohanded/spear/secspear/attack_obj(obj/object, mob/living/user, params)
	. = ..()

	if(!(. & ATTACK_CHAIN_SUCCESS))
		return

	power_usage()

/obj/item/twohanded/spear/secspear/wield(obj/item/source, mob/living/carbon/user)
	. = ..()
	update_cleave_component()
	user.update_held_items()

/obj/item/twohanded/spear/secspear/unwield(obj/item/source, mob/living/carbon/user)
	. = ..()
	update_cleave_component()
	user.update_held_items()

/obj/item/twohanded/spear/secspear/equipped(mob/user, slot, initial)
	. = ..()

	if(!(slot & ITEM_SLOT_HANDS))
		return

	off_spear()

/obj/item/twohanded/spear/secspear/dropped(mob/user, slot, silent)
	. = ..()
	off_spear()

/obj/item/twohanded/spear/secspear/get_cell()
	return cell

/obj/item/twohanded/spear/secspear/proc/power_usage()
	var/power_cost = spear_mode.power_cost
	cell.use(power_cost)

	if(cell.charge >= power_cost)
		return

	off_spear()

/obj/item/twohanded/spear/secspear/proc/update_cleave_component()
	var/datum/secspear_mode/current_spear_mode = spear_mode
	AddComponent( \
		/datum/component/cleave_attack, \
		arc_size = (wielded? current_spear_mode.arc_size_weided : current_spear_mode.arc_size), \
		swing_speed_mod = (wielded? current_spear_mode.swing_speed_mod : current_spear_mode.swing_speed_mod), \
		afterswing_slowdown = current_spear_mode.afterswing_slowdown, \
		slowdown_duration = current_spear_mode.slowdown_duration, \
		swing_sound = current_spear_mode.cleave_sound \
	)

/obj/item/twohanded/spear/secspear/proc/toggle_folded(mob/user = usr)
	playsound(get_turf(src), fold_sound, 50, TRUE)
	folded = !folded

	if(folded)
		if(wielded)
			attack_self(user)
		add_traits(list(TRAIT_TWOHANDED_BLOCKED, TRAIT_CLEAVE_BLOCKED), UNIQUE_TRAIT_SOURCE(src))
		w_class = WEIGHT_CLASS_SMALL
		slot_flags = null
		block_chance = initial(block_chance)
		update_icon()
		user.update_held_items()
		user.update_action_buttons_icon()
		balloon_alert(user, "сложено!")
		return

	remove_traits(list(TRAIT_TWOHANDED_BLOCKED, TRAIT_CLEAVE_BLOCKED), UNIQUE_TRAIT_SOURCE(src))
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	block_chance = SECSPEAR_BLOCK_CHANCE
	update_icon()
	user.update_held_items()
	user.update_action_buttons_icon()
	balloon_alert(user, "разложено!")

/obj/item/twohanded/spear/secspear/proc/off_spear()
	switch_spear_mode(/datum/secspear_mode/off)

/obj/item/twohanded/spear/secspear/proc/swap_spear_mode(mob/user = usr)
	var/datum/secspear_mode/next_mode = spear_mode.next_mode
	if(cell.charge < next_mode.power_cost)
		balloon_alert(user, "недостаточно энергии!")
		return

	switch_spear_mode(next_mode, user)

/obj/item/twohanded/spear/secspear/proc/switch_spear_mode(datum/secspear_mode/mode_type, mob/user = usr)
	if(mode_type == spear_mode.type)
		return

	var/datum/secspear_mode/mode = GLOB.secspear_modes[mode_type.name]
	spear_mode.on_deactivate(src)
	mode.on_activate(src)
	playsound(get_turf(src), mode.on_sound, 50, TRUE, -1)
	spear_mode = mode
	update_icon()
	user.update_held_items()
	balloon_alert(user, "режим [mode.name]!")

/datum/action/item_action/switch_spear_mode
	name = "Переключить режим копья"

/datum/action/item_action/switch_spear_mode/call_effect_proc()
	var/obj/item/twohanded/spear/secspear/spear = target
	spear.swap_spear_mode(owner)

/datum/action/item_action/toggle_folded
	name = "Сложить/разложить копье"

/datum/action/item_action/toggle_folded/call_effect_proc()
	var/obj/item/twohanded/spear/secspear/spear = target
	spear.toggle_folded(owner)

#undef SECSPEAR_BLOCK_CHANCE
