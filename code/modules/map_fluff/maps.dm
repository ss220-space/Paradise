/datum/map
	var/name = "Unnamed Map"
	var/map_path = ""
	var/lavaland_path = "_maps/map_files/generic/Lavaland.dmm"
	var/admin_only = FALSE // check true if you don't want this to be in map rotation

	// a list of lists: every list inside is a trait list for every z-level. (May used by snow station or multi-z station)
	var/list/traits = null // null for default 1 z-level space station.
	var/linkage = CROSSLINKED
	var/space_ruins_levels = null //null for default number of ruins. use it to override. Can be used to neglect lagging from multi-z station.

	var/station_name  = "BAD Station"
	var/station_short = "Baddy"
	var/dock_name     = "THE PirateBay"
	var/company_name  = "BadMan"
	var/company_short = "BM"
	var/starsys_name  = "Dull Star"
	/// URL to the maps webmap
	var/webmap_url
