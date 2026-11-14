/datum/overmap_radar_subscription
	var/datum/tgui/ui
	var/epoch
	var/sector_id
	var/list/sent = list()

/datum/overmap_radar_subscription/New(datum/tgui/window)
	ui = window
	RegisterSignal(ui, COMSIG_TGUI_PAYLOAD, PROC_REF(prepare_payload))

/datum/overmap_radar_subscription/Destroy()
	if(ui)
		UnregisterSignal(ui, COMSIG_TGUI_PAYLOAD)
	ui = null
	sent = null
	return ..()

/datum/overmap_radar_subscription/proc/prepare_payload(datum/source, list/payload, full_update)
	SIGNAL_HANDLER
	var/list/data = payload["data"]
	if(!data)
		return
	if(full_update || (("radar_epoch" in data) && epoch != data["radar_epoch"]) || (("sector_id" in data) && sector_id != data["sector_id"]))
		sent.Cut()
	if("radar_epoch" in data)
		epoch = data["radar_epoch"]
	if("sector_id" in data)
		sector_id = data["sector_id"]
	var/list/filtered = data.Copy()
	for(var/field in list("radar_terrain", "radar_scatter", "radar_shapes", "radar_outlines"))
		if(!(field in data))
			continue
		var/list/value = data[field]
		var/unchanged = (field in sent)
		if(field == "radar_terrain")
			unchanged = unchanged && sent[field] == value?["revision"]
			sent[field] = value?["revision"]
		else if(field == "radar_scatter")
			unchanged = unchanged && sent[field] == value
			sent[field] = value
		else
			var/list/previous = sent[field]
			unchanged = unchanged && length(previous) == length(value)
			if(unchanged)
				for(var/key in value)
					if(previous[key] != value[key])
						unchanged = FALSE
						break
			sent[field] = value
		if(unchanged)
			filtered -= field
	payload["data"] = filtered
