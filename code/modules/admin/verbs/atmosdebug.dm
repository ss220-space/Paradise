ADMIN_VERB_VISIBILITY(atmos_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(atmos_debug, R_DEBUG, "Check Plumbing", "Verifies the integrity of the plumbing network.", ADMIN_CATEGORY_MAPPING)
	if(tgui_alert(user, "WARNING: This command should not be run on a live server. Do you want to continue?", "Check Piping", list("No", "Yes")) == "No")
		return

	//all plumbing - yes, some things might get stated twice, doesn't matter.
	to_chat(user, "Checking for unconnected pipes")
	var/list/atmos = list()
	for(var/turf/T in world)
		for(var/obj/machinery/atmospherics/atm in T)
			atmos += atm
	//Manifolds 3w
	for(var/obj/machinery/atmospherics/pipe/manifold/pipe in atmos)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	//Manifolds 4w
	for(var/obj/machinery/atmospherics/pipe/manifold4w/pipe in atmos)
		if(!pipe.node1 || !pipe.node2 || !pipe.node3 || !pipe.node4)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	//Pipes
	for(var/obj/machinery/atmospherics/pipe/simple/pipe in atmos)
		if(!pipe.node1 || !pipe.node2)
			to_chat(user, "Unconnected [pipe.name] located at [ADMIN_VERBOSEJMP(pipe)]", confidential = TRUE)
	to_chat(user, "Checking for overlapping pipes...")
	for(var/turf/T in world)
		for(var/dir in GLOB.cardinal)
			var/list/check = list(0, 0, 0)
			var/done = 0
			for(var/obj/machinery/atmospherics/pipe in T)
				if(dir & pipe.initialize_directions)
					for(var/ct in pipe.connect_types)
						check[ct]++
						if(check[ct] > 1)
							to_chat(user, "Overlapping pipe ([pipe.name]) located at [ADMIN_VERBOSEJMP(T)]", confidential = TRUE)
							done = 1
							break
				if(done)
					break
	to_chat(user, "Done")
	BLACKBOX_LOG_ADMIN_VERB("Check Plumbing")

ADMIN_VERB_VISIBILITY(power_debug, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(power_debug, R_ADMIN, "Check Power", "Verifies the integrity of the power network.", ADMIN_CATEGORY_MAPPING)
	for(var/datum/powernet/PN in SSmachines.powernets)
		if(!PN.nodes || !length(PN.nodes))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(user, "Powernet with no nodes! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

		if(!PN.cables || (length(PN.cables) < 10))
			if(PN.cables && (length(PN.cables) > 1))
				var/obj/structure/cable/C = PN.cables[1]
				to_chat(user, "Powernet with fewer than 10 cables! (number [PN.number]) - example cable at [ADMIN_VERBOSEJMP(C)]")

	BLACKBOX_LOG_ADMIN_VERB("Check Power")

ADMIN_VERB(raw_gas_scan, R_DEBUG|R_VIEWRUNTIMES, "Raw Gas Scan", "Scans your current tile, including LINDA data not normally displayed.", ADMIN_CATEGORY_DEBUG)
	var/mob/user_mob = user.mob
	atmos_scan(user_mob , get_turf(user_mob ), silent = TRUE, milla_turf_details = TRUE)


ADMIN_VERB(teleport_interesting_turf, R_DEBUG|R_VIEWRUNTIMES, "Interesting Turf", "Teleports you to a random Interesting Turf from MILLA", ADMIN_CATEGORY_DEBUG)
	var/mob/user_mob = user.mob

	if(!isobserver(user_mob))
		to_chat(user, span_warning("You must be an observer to do this!"))
		return

	var/list/interesting_tile = get_random_interesting_tile()
	if(!length(interesting_tile))
		to_chat(user, span_notice("There are no interesting turfs. How interesting!"))
		return

	var/turf/interesting_turf = interesting_tile[MILLA_INDEX_TURF]
	var/mob/dead/observer/observer = user_mob
	observer.forceMove(interesting_turf)
	observer.ManualFollow(interesting_turf)

#define I_AM_SURE "I am sure"
#define YEP "Yep"
#define NOPE "Nope"

ADMIN_VERB(visualize_interesting_turfs, R_DEBUG|R_VIEWRUNTIMES, "Visualize Interesting Turfs", "Shows all the Interesting Turfs from MILLA", ADMIN_CATEGORY_DEBUG)

	if(SSair.interesting_tile_count > 500)
		// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
		var/confirm = tgui_alert(user, "WARNING: There are [SSair.interesting_tile_count] Interesting Turfs. This process will be lag intensive and should only be used if the atmos controller is screaming bloody murder. Are you sure you with to continue", "WARNING", list(I_AM_SURE, NOPE))
		if(confirm != I_AM_SURE)
			return

	var/display_turfs_overlay = FALSE
	var/do_display_turf_overlay = tgui_alert(user, "Would you like to have all interesting turfs have a client side overlay applied as well?", "Optional", list(YEP,  NOPE))
	if(do_display_turf_overlay == "Yep")
		display_turfs_overlay = TRUE

	message_admins("[key_name_admin(user)] is visualising interesting atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	var/list/coords = get_interesting_atmos_tiles()
	if(!length(coords))
		to_chat(user, span_notice("There are no interesting turfs. How interesting!"))
		return

	while(length(coords))
		var/offset = length(coords) - MILLA_INTERESTING_TILE_SIZE
		var/turf/selected_turf = coords[offset + MILLA_INDEX_TURF]
		coords.len -= MILLA_INTERESTING_TILE_SIZE


		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[selected_turf.z]"])
			zlevel_turf_indexes["[selected_turf.z]"] = list()
		zlevel_turf_indexes["[selected_turf.z]"] |= selected_turf
		if(display_turfs_overlay)
			user.images += image('icons/effects/alphacolors.dmi', selected_turf, "red")
		CHECK_TICK

	// Sort the keys
	zlevel_turf_indexes = sortAssoc(zlevel_turf_indexes)

	for(var/key in zlevel_turf_indexes)
		to_chat(user, span_notice("Z[key]: <b>[length(zlevel_turf_indexes["[key]"])] Interesting Turfs</b>"))

	var/z_to_view = tgui_input_number(user, "A list of z-levels their ITs has appeared in chat. Please enter a Z to visualise. Enter 0 to cancel.", "Selection", 0)

	if(!z_to_view)
		return

	// Do not combine these
	var/list/ui_dat = list()
	var/list/turf_markers = list()

	var/datum/browser/vis = new(user, "atvis", "Interesting Turfs (Z[z_to_view])", 300, 315)
	ui_dat += "<center><canvas width=\"255px\" height=\"255px\" id=\"atmos\"></canvas></center>"
	ui_dat += "<script>e=document.getElementById(\"atmos\");c=e.getContext('2d');c.fillStyle='#ffffff';c.fillRect(0,0,255,255);function s(x,y){var p=c.createImageData(1,1);p.data\[0]=255;p.data\[1]=0;p.data\[2]=0;p.data\[3]=255;c.putImageData(p,(x-1),255-Math.abs(y-1));}</script>"
	// Now generate the other list
	for(var/turf/marked_turf as anything in zlevel_turf_indexes["[z_to_view]"])
		turf_markers += "s([marked_turf.x],[marked_turf.y]);"
		CHECK_TICK

	ui_dat += "<script>[turf_markers.Join("")]</script>"

	vis.set_content(ui_dat.Join(""))
	vis.open(FALSE)

#undef I_AM_SURE
#undef YEP
#undef NOPE
