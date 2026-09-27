/obj/machinery/byteforge
	name = "byteforge"
	desc = "Приёмник квантового сервера. Здесь код домена сходится в осязаемый груз."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "byteforge"
	base_icon_state = "byteforge"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	idle_power_usage = 100
	var/angry = FALSE

/obj/machinery/byteforge/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/byteforge(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	register_context()
	update_icon()

/obj/machinery/byteforge/get_ru_names()
	return alist(
		NOMINATIVE = "байткузница",
		GENITIVE = "байткузницы",
		DATIVE = "байткузнице",
		ACCUSATIVE = "байткузницу",
		INSTRUMENTAL = "байткузницей",
		PREPOSITIONAL = "байткузнице",
	)

/obj/machinery/byteforge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Закрыть панель" : "Открыть панель"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/byteforge/examine(mob/user)
	. = ..()
	. += span_notice("Должна стоять не дальше четырёх плиток от квантового сервера.")

/obj/machinery/byteforge/update_icon_state()
	icon_state = panel_open ? "[base_icon_state]_panel" : base_icon_state

/obj/machinery/byteforge/update_overlays()
	. = ..()
	if(!is_operational() || panel_open)
		return

	. += mutable_appearance(icon, "on_particles[angry ? "_angry" : ""]", ABOVE_MOB_LAYER)

/obj/machinery/byteforge/power_change(forced = FALSE)
	..()
	update_icon()

/obj/machinery/byteforge/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, tool))
		update_icon()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/byteforge/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/byteforge/proc/setup_particles(angry = FALSE)
	if(src.angry == angry)
		return

	src.angry = angry
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/byteforge/proc/charge_up()
	flick_overlay_view(mutable_appearance(icon, "on_overlay[angry ? "_angry" : ""]"), 1 SECONDS)
	set_light(l_range = 2, l_power = 1.5, l_color = angry ? LIGHT_COLOR_INTENSE_RED : LIGHT_COLOR_BABY_BLUE, l_on = TRUE)
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, TRUE)

/obj/machinery/byteforge/proc/flash()
	set_light(l_on = FALSE)
	playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)
	do_sparks(5, TRUE, get_turf(src))

/obj/machinery/byteforge/proc/start_to_spawn(obj/cache)
	charge_up()
	addtimer(CALLBACK(src, PROC_REF(spawn_cache), cache), 1 SECONDS, TIMER_DELETE_ME)

/obj/machinery/byteforge/proc/spawn_cache(obj/cache)
	flash()

	if(QDELETED(cache))
		return

	cache.forceMove(get_turf(src))
