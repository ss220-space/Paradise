#define PORTAGRAV_MAX_LEVEL 5
#define PORTAGRAV_MAX_TILES_PER_LEVEL 3
#define PORTAGRAV_BASE_POWER_PER_LEVEL 10

/obj/machinery/power/portagrav
	name = "Portable Gravity Unit"
	desc = "Компактный гравитационный генератор на переносной платформе. Создаёт поле искусственной гравитации вокруг себя, питаясь от батареи или от силового кабеля. Работает только закреплённым."
	icon = 'icons/obj/machines/gravity_generator.dmi'
	icon_state = "portagrav"
	base_icon_state = "portagrav"
	density = TRUE
	anchored = FALSE
	max_integrity = 250
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 40, BIO = 0, FIRE = 100, ACID = 30)
	interaction_flags_click = ALLOW_SILICON_REACH
	processing_flags = START_PROCESSING_MANUALLY
	var/obj/item/stock_parts/cell/cell
	var/on = FALSE
	var/wire_mode = FALSE
	var/datum/proximity_monitor/advanced/gravity/subtle_effect/gravity_field
	var/gravity_strength = STANDARD_GRAVITY
	var/field_level = 1
	var/tiles_per_level = 1
	var/power_per_level = PORTAGRAV_BASE_POWER_PER_LEVEL

/obj/machinery/power/portagrav/get_ru_names()
	return alist(
		NOMINATIVE = "портативный гравигенератор",
		GENITIVE = "портативного гравигенератора",
		DATIVE = "портативному гравигенератору",
		ACCUSATIVE = "портативный гравигенератор",
		INSTRUMENTAL = "портативным гравигенератором",
		PREPOSITIONAL = "портативном гравигенераторе",
	)

/obj/machinery/power/portagrav/Initialize(mapload)
	. = ..()
	if(mapload)
		cell = new /obj/item/stock_parts/cell/high(src)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/portagrav(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()
	if(anchored && wire_mode)
		connect_to_network()
	update_icon(UPDATE_OVERLAYS)

	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Включить/выключить")

	var/static/list/tool_behaviors = list(
		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Закрепить",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/machinery/power/portagrav/Destroy()
	QDEL_NULL(gravity_field)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/power/portagrav/on_deconstruction()
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	return ..()

/obj/machinery/power/portagrav/RefreshParts()
	. = ..()
	var/capacitor_rating = 0
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		capacitor_rating += capacitor.rating
	tiles_per_level = clamp(round(capacitor_rating / 2), 1, PORTAGRAV_MAX_TILES_PER_LEVEL)

	var/laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating
	power_per_level = max(PORTAGRAV_BASE_POWER_PER_LEVEL - (laser_rating - 2), 1)
	update_field()

/obj/machinery/power/portagrav/get_cell()
	return cell

/obj/machinery/power/portagrav/examine(mob/user)
	. = ..()
	. += span_notice("Генератор [on ? "включён" : "выключен"], панель [panel_open ? "открыта" : "закрыта"].")
	. += span_notice("Заряд батареи: [cell ? "[round(cell.percent(), 1)]%" : "батарея отсутствует"].")
	. += span_notice("Питание идёт от [wire_mode ? "силового кабеля" : "батареи"].")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Используйте <b>ПКМ</b>, чтобы [on ? "выключить" : "включить"].")

/obj/machinery/power/portagrav/update_icon_state()
	icon_state = panel_open ? "[base_icon_state]_o" : base_icon_state

/obj/machinery/power/portagrav/update_overlays()
	. = ..()
	if(anchored)
		. += "portagrav_anchors"
	if(on)
		. += "portagrav_lights"
		. += "activated"

/obj/machinery/power/portagrav/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!iscell(tool))
		return NONE
	if(!panel_open)
		balloon_alert(user, "откройте панель!")
		return ITEM_INTERACT_BLOCKING
	if(cell)
		balloon_alert(user, "батарея уже внутри!")
		return ITEM_INTERACT_BLOCKING
	if(!user.drop_transfer_item_to_loc(tool, src))
		return ITEM_INTERACT_BLOCKING
	cell = tool
	tool.add_fingerprint(user)
	balloon_alert(user, "батарея вставлена")
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/portagrav/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/power/portagrav/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[base_icon_state]_o", base_icon_state, tool)

/obj/machinery/power/portagrav/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/power/portagrav/wrench_act(mob/living/user, obj/item/tool)
	if(on)
		balloon_alert(user, "сначала выключите!")
		return TRUE
	. = default_unfasten_wrench(user, tool)
	if(anchored && wire_mode)
		connect_to_network()
	else
		disconnect_from_network()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/portagrav/connect_to_network()
	if(!anchored)
		return FALSE
	return ..()

/obj/machinery/power/portagrav/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .
	if(panel_open)
		balloon_alert(user, "закройте панель!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	toggle_power(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/power/portagrav/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	do_sparks(3, TRUE, src)
	balloon_alert(user, "ограничитель поля снят")
	add_attack_logs(user, src, "emagged")

/obj/machinery/power/portagrav/proc/toggle_power(mob/user)
	if(on)
		turn_off(user)
		return
	turn_on(user)

/obj/machinery/power/portagrav/proc/turn_on(mob/user)
	if(!anchored)
		balloon_alert(user, "не закреплено!")
		return
	if(!has_power())
		balloon_alert(user, "нет энергии!")
		return
	on = TRUE
	begin_processing()
	gravity_field = new(src, field_level * tiles_per_level, FALSE, gravity_strength)
	balloon_alert(user, "включено")
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/portagrav/proc/turn_off(mob/user)
	on = FALSE
	end_processing()
	QDEL_NULL(gravity_field)
	balloon_alert(user, "выключено")
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/portagrav/proc/has_power()
	if(wire_mode)
		return surplus() >= power_per_level * field_level
	return cell?.charge >= power_per_level * field_level

/obj/machinery/power/portagrav/proc/max_gravity()
	return emagged ? GRAVITY_DAMAGE_THRESHOLD + 1 : GRAVITY_DAMAGE_THRESHOLD - 1

/obj/machinery/power/portagrav/proc/update_field()
	if(!gravity_field)
		return
	gravity_field.gravity_value = gravity_strength
	gravity_field.set_range(field_level * tiles_per_level)
	gravity_field.recalculate_field(full_recalc = TRUE)

/obj/machinery/power/portagrav/process()
	if(!on)
		return
	if(!anchored)
		turn_off()
		return
	var/draw = power_per_level * field_level
	if(wire_mode)
		if(surplus() < draw)
			turn_off()
			return
		add_load(draw)
		return
	if(!cell?.use(draw))
		turn_off()

/obj/machinery/power/portagrav/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/power/portagrav/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Portagrav", name)
		ui.open()

/obj/machinery/power/portagrav/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["open"] = panel_open
	data["anchored"] = anchored
	data["wireMode"] = wire_mode
	data["hasPowercell"] = !isnull(cell)
	data["powerLevel"] = cell ? round(cell.percent(), 1) : 0
	data["level"] = field_level
	data["maxLevel"] = PORTAGRAV_MAX_LEVEL
	data["range"] = field_level * tiles_per_level
	data["gravity"] = gravity_strength
	data["maxGravity"] = max_gravity()
	data["draw"] = display_power(power_per_level * field_level)
	return data

/obj/machinery/power/portagrav/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			toggle_power(ui.user)
			return TRUE
		if("wire_mode")
			wire_mode = !wire_mode
			if(wire_mode && anchored)
				connect_to_network()
			else
				disconnect_from_network()
			if(on && !has_power())
				turn_off()
			return TRUE
		if("eject")
			if(!panel_open || !cell)
				return
			cell.forceMove_turf()
			ui.user.put_in_hands(cell, ignore_anim = FALSE)
			cell = null
			if(on && !wire_mode)
				turn_off()
			return TRUE
		if("adjust_level")
			var/adjustment = text2num(params["adjustment"])
			var/new_level = clamp(field_level + adjustment, 1, PORTAGRAV_MAX_LEVEL)
			if(new_level == field_level)
				return
			field_level = new_level
			update_field()
			return TRUE
		if("adjust_gravity")
			var/adjustment = text2num(params["adjustment"])
			var/new_gravity = clamp(gravity_strength + adjustment, 0, max_gravity())
			if(new_gravity == gravity_strength)
				return
			gravity_strength = new_gravity
			update_field()
			return TRUE

/obj/machinery/power/portagrav/anchored
	anchored = TRUE

#undef PORTAGRAV_MAX_LEVEL
#undef PORTAGRAV_MAX_TILES_PER_LEVEL
#undef PORTAGRAV_BASE_POWER_PER_LEVEL
