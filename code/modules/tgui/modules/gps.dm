/datum/ui_module/open_gps
    name = "GPS"
    var/obj/item/gps/cyborg/gps = new

/datum/ui_module/open_gps/ui_state(mob/user)
    return GLOB.inventory_state

/datum/ui_module/open_gps/ui_interact(mob/user, datum/tgui/ui = null)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "GPS", "GPS")
        ui.open()

/datum/ui_module/open_gps/ui_data(mob/user)
    var/list/data = list()
    if(gps.emped)
        data["emped"] = TRUE
        return data

    // General
    data["active"] = gps.tracking
    data["tag"] = gps.gpstag
    data["same_z"] = gps.same_z
    data["upgraded"] = gps.upgraded
    if(!gps.tracking)
        return data
    var/turf/T = get_turf(src)
    data["area"] = get_area_name(src, TRUE)
    data["position"] = ATOM_COORDS(T)

    // Saved location
    if(gps.locked_location)
        data["saved"] = ATOM_COORDS(gps.locked_location)
    else
        data["saved"] = null

    // GPS signals
    var/signals = list()
    for(var/g in GLOB.GPS_list)
        var/obj/item/gps/G = g
        var/turf/GT = get_turf(G)
        if(isnull(GT) || !G.tracking || G == src)
            continue
        if((G.local || gps.same_z) && (GT.z != T.z))
            continue

        var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
        if(!G.emped)
            signal["area"] = (GT.z == T.z) ? get_area_name(G, TRUE) : "???"
            signal["position"] = ATOM_COORDS(GT)
        signals += list(signal)
    data["signals"] = signals

    return data

/datum/ui_module/open_gps/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(!length(newtag) || gps.gpstag == newtag)
				return
			gps.gpstag = newtag
			name = "global positioning system ([gps.gpstag])"
		if("toggle")
			gps.toggle_gps(usr)
			return FALSE
		if("same_z")
			gps.same_z = !gps.same_z
		else
			return FALSE
