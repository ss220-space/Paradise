/**
 * Map Datum
 *
 * Datum which holds all of the information for maps ingame.
 * This is used for showing map information, as well as map loading.
 */
/datum/map
	var/name = "Unnamed Map"
	/// Path to the map file.
	var/map_path = ""
	var/lavaland_path = "_maps/map_files/generic/Lavaland.dmm"

	// Multi-z vars.
	/// A list of lists: every list inside is a trait list for every z-level. null for default 1 z-level space station. (May used by snow station or multi-z station)
	var/list/traits = null
	var/linkage = CROSSLINKED
	/// null for default number of ruins. Use it to override. Can be used to neglect lagging from multi-z station.
	var/space_ruins_levels = null

	/// Ingame Station name in Russian.
	var/station_name = "BAD Station"
	/// Ingame Station name in English for Byond Hub.
	var/english_station_name = null

	// Lore information.
	var/station_short = "Baddy"
	var/dock_name = "THE PirateBay"
	var/company_name = "BadMan"
	var/company_short = "BM"
	var/starsys_name = "Dull Star"

	/// Is this map voteable? True if you don't want this to be in map rotation.
	var/admin_only = FALSE
	/// URL to the maps webmap.
	var/webmap_url

	var/datum/game_mode/forced_mode
