/obj/machinery/computer/helm/weapons
	name = "ship weapons console"
	desc = "TEMP123TEMP"
	circuit = /obj/item/circuitboard/ship_weapons
	icon_screen = "syndinavigation"
	icon_keyboard = "security_key"
	light_color = COLOR_SOFT_RED

/obj/machinery/computer/helm/weapons/ui_interact(mob/user, datum/tgui/ui = null)
	if(!user.client)
		return
	link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapWeapons", name)
		ui.open()
	vessel?.watch_radar(ui)

/obj/machinery/computer/helm/weapons/ui_close(mob/user)
	return

/obj/machinery/computer/helm/weapons/can_pilot(mob/user)
	return FALSE

/obj/machinery/computer/helm/weapons/ui_data(mob/user)
	overmap_watch_radar(src, user, vessel)
	var/list/data = list("linked" = !!vessel)
	if(!vessel)
		return data
	data["vessel_name"] = vessel.get_overmap_display_name()
	data["weapons"] = weapon_data()
	data["sector_name"] = vessel.sector?.name
	data["sector_id"] = vessel.sector?.id
	data["sector_size"] = vessel.sector?.size || OVERMAP_DEFAULT_SIZE
	data["cell_span"] = OVERMAP_TILE_SPAN * (vessel.sector?.tile_travel || 1)
	data["radar_reach"] = radar_reach
	data["map_jammed"] = vessel.is_overmap_jammed()
	vessel.fill_radar_data(data, radar_reach)
	return data

/obj/machinery/computer/helm/weapons/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!(action in list("select_weapon", "weapon_auto", "radar_point", "set_dest", "helm_radar_reach", "relink")))
		return TRUE
	if((action == "radar_point" || action == "set_dest") && !length(selected_weapons))
		return TRUE
	return ..()

/obj/item/circuitboard/ship_weapons
	desc = "TEMP123TEMP"
	board_name = "Ship Weapons Console"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/helm/weapons
	origin_tech = "programming=3;magnets=2"
