/proc/overmap_watch_radar(atom/source, mob/user, obj/overmap/entity/vessel)
	for(var/datum/tgui/ui as anything in user?.tgui_open_uis)
		if(ui.src_object != source)
			continue
		if(vessel)
			vessel.watch_radar(ui)
		else
			ui.radar_source?.unwatch_radar(ui)
