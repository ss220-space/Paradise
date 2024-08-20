// Used to edit areas.
#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

/obj/item/areaeditor
	name = "area modification item"
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	attack_verb = list("attacked", "bapped", "hit")
	/// Whether someone is currently using us
	var/currently_used = FALSE
	/// Fluff name for station in interaction window
	var/station_name_overrride
	/// More fluff description for interaction window
	var/fluffnotice = "Nobody's gonna read this stuff!"
	/// Whether item can be used to edit existing areas.
	var/allow_non_space_use = FALSE
	/// When using it to create a new area, this will be its type.
	var/new_area_type = /area


/obj/item/areaeditor/attack_self(mob/user)
	interact_prints(user)


/obj/item/areaeditor/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	user << browse(null, "window=blueprints")


/obj/item/areaeditor/proc/interact_prints(mob/user)
	add_fingerprint(user)
	. = "<BODY><HTML><head><title>[src]</title></head> \
				<h2>[isnull(station_name_overrride) ? "\"[station_name()]\"" : station_name_overrride ? "\"[station_name_overrride]\"" : null] [src.name]</h2> \
				<small>[fluffnotice]</small><hr>"
	switch(get_area_type())
		if(AREA_SPACE)
			. += "<p>According to the [src.name], you are now in an unclaimed territory.</p>"
			if(!allow_non_space_use)
				. += "<p><a href='byond://?src=[UID()];create_area=1'>Create or modify an existing area</a></p>"
		if(AREA_SPECIAL)
			. += "<p>This place is not noted on the [src.name].</p>"
	if(allow_non_space_use)
		. += "<p><a href='byond://?src=[UID()];create_area=1'>Create or modify an existing area</a></p>"


/obj/item/areaeditor/Topic(href, href_list)
	if(..())
		return TRUE
	if(usr != loc)
		usr << browse(null, "window=blueprints")
		return TRUE
	if(href_list["create_area"])
		if(currently_used)
			return
		currently_used = TRUE
		create_area_wrapper(usr, new_area_type)
		if(QDELETED(src))
			return
		currently_used = FALSE
		interact_prints(usr)
		return TRUE


/obj/item/areaeditor/proc/create_area_wrapper(mob/user, new_area_type)
	return create_area(user, new_area_type)


/obj/item/areaeditor/proc/get_area_type(area/check_area)
	if(!check_area)
		check_area = get_area(usr)
	if(check_area.outdoors)
		return AREA_SPACE
	var/static/list/special_areas = typecacheof(list(
		/area/shuttle,
		/area/admin,
		/area/centcom,
		/area/asteroid,
		/area/tdome,
		/area/wizard_station,
	))
	if(is_type_in_typecache(check_area, special_areas))
		return AREA_SPECIAL
	return AREA_STATION


/obj/item/areaeditor/proc/edit_area(mob/user)
	var/area/user_area = get_area(user)
	var/prevname = "[sanitize(user_area.name)]"
	var/str = tgui_input_text(usr, "New area name:", "Blueprint Editing", prevname, MAX_NAME_LEN, encode = FALSE)
	if(!str || !length(str) || str == prevname) // Cancel
		return
	rename_area(user_area, str)
	to_chat(user, span_notice("You rename the '[prevname]' to '[str]'."))
	add_game_logs("has renamed [prevname] to [str]", user)
	interact_prints(user)
	return user_area


/obj/item/areaeditor/proc/rename_area(passed, new_name)
	var/area/our_area = get_area(passed)
	var/prevname = "[sanitize(our_area.name)]"
	set_area_machinery_title(our_area, new_name, prevname)
	our_area.name = new_name

	if(our_area.firedoors)
		for(var/obj/machinery/door/firedoor/firedoor as anything in our_area.firedoors)
			firedoor.CalculateAffectingAreas()


/obj/item/areaeditor/proc/set_area_machinery_title(area/check_area, title, oldtitle)
	if(!oldtitle) // or replacetext goes to infinite loop
		return

	//stuff tied to the area to rename
	var/static/list/to_rename = typecacheof(list(
		/obj/machinery/alarm,
		/obj/machinery/power/apc,
		/obj/machinery/atmospherics/unary/vent_scrubber,
		/obj/machinery/atmospherics/unary/vent_pump,
		/obj/machinery/door,
		/obj/machinery/firealarm,
		/obj/machinery/light_switch,
	))

	for(var/obj/machinery/machine as anything in typecache_filter_list(check_area.machinery_cache, to_rename))
		machine.name = replacetext(machine.name, oldtitle, title)


// Station Blueprints
/obj/item/areaeditor/blueprints
	name = "station blueprints"
	desc = "Blueprints of the station. There is a \"Classified\" stamp and several coffee stains on it."
	icon = 'icons/obj/items.dmi'
	icon_state = "blueprints"
	fluffnotice = "Property of Nanotrasen. For heads of staff only. Store in high-secure storage."
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	w_class = WEIGHT_CLASS_NORMAL
	allow_non_space_use = TRUE
	var/list/showing = list()
	var/client/viewing
	/// Viewing the wire legend
	var/legend = FALSE


/obj/item/areaeditor/blueprints/Destroy()
	clear_viewer()
	return ..()


/obj/item/areaeditor/blueprints/interact_prints(mob/user)
	. = ..()
	if(!legend)
		var/area/user_area = get_area(user)
		if(get_area_type() == AREA_STATION)
			. += "<p>According to \the [src], you are now in <b>\"[sanitize(user_area.name)]\"</b>.</p>"
			. += "<p><a href='byond://?src=[UID()];edit_area=1'>Change area name</a></p>"
		. += "<p><a href='byond://?src=[UID()];view_legend=1'>View wire colour legend</a></p>"
		if(!viewing)
			. += "<p><a href='byond://?src=[UID()];view_blueprints=1'>View structural data</a></p>"
		else
			. += "<p><a href='byond://?src=[UID()];refresh=1'>Refresh structural data</a></p>"
			. += "<p><a href='byond://?src=[UID()];hide_blueprints=1'>Hide structural data</a></p>"
	else
		if(legend == TRUE)
			. += "<a href='byond://?src=[UID()];exit_legend=1'><< Back</a>"
			. += view_wire_devices(user);
		else
			//legend is a wireset
			. += "<a href='byond://?src=[UID()];view_legend=1'><< Back</a>"
			. += view_wire_set(user, legend)
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")


/obj/item/areaeditor/blueprints/Topic(href, href_list)
	if(..())
		return
	if(href_list["edit_area"])
		if(get_area_type() != AREA_STATION)
			return
		if(currently_used)
			return
		currently_used = TRUE
		edit_area(usr)
		if(QDELETED(src))
			return
		currently_used = FALSE
	if(href_list["exit_legend"])
		legend = FALSE
	if(href_list["view_legend"])
		legend = TRUE
	if(href_list["view_wireset"])
		legend = href_list["view_wireset"];
	if(href_list["view_blueprints"])
		set_viewer(usr, span_notice("You flip the blueprints over to view the complex information diagram."))
	if(href_list["hide_blueprints"])
		clear_viewer(usr,span_notice("You flip the blueprints over to view the simple information diagram."))
	if(href_list["refresh"])
		clear_viewer(usr)
		set_viewer(usr)

	interact_prints(usr)


/obj/item/areaeditor/blueprints/proc/get_images(turf/central_turf, viewsize)
	. = list()
	var/list/dimensions = getviewsize(viewsize)
	var/horizontal_radius = dimensions[1] / 2
	var/vertical_radius = dimensions[2] / 2
	for(var/turf/nearby_turf as anything in RECT_TURFS(horizontal_radius, vertical_radius, central_turf))
		if(nearby_turf.blueprint_data)
			. += nearby_turf.blueprint_data


/obj/item/areaeditor/blueprints/proc/set_viewer(mob/user, message = "")
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(viewing.eye || user), viewing.view)
		viewing.images |= showing
		if(message)
			to_chat(user, message)


/obj/item/areaeditor/blueprints/proc/clear_viewer(mob/user, message = "")
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()
	if(message)
		to_chat(user, message)


/obj/item/areaeditor/blueprints/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	clear_viewer()
	legend = FALSE


/obj/item/areaeditor/blueprints/proc/view_wire_devices(mob/user)
	var/message = "<br>You examine the wire legend.<br>"
	for(var/wireset in GLOB.wire_color_directory)
		message += "<br><a href='byond://?src=[UID()];view_wireset=[wireset]'>[GLOB.wire_name_directory[wireset]]</a>"
	message += "</p>"
	return message


/obj/item/areaeditor/blueprints/proc/view_wire_set(mob/user, wireset)
	//for some reason you can't use wireset directly as a derefencer so this is the next best :/
	for(var/device in GLOB.wire_color_directory)
		if("[device]" == wireset) //I know... don't change it...
			var/message = "<p><b>[GLOB.wire_name_directory[device]]:</b>"
			for(var/Col in GLOB.wire_color_directory[device])
				var/wire_name = GLOB.wire_color_directory[device][Col]
				if(!findtext(wire_name, WIRE_DUD_PREFIX)) //don't show duds
					message += "<p><span style='color: [Col]'>[Col]</span>: [wire_name]</p>"
			message += "</p>"
			return message
	return ""


//Blueprint Subtypes

/obj/item/areaeditor/blueprints/ce


/obj/item/areaeditor/blueprints/cyborg
	name = "station schematics"
	desc = "A digital copy of the station blueprints stored in your memory."
	fluffnotice = "Intellectual Property of Nanotrasen. For use in engineering cyborgs only. Wipe from memory upon departure from the station."
	allow_non_space_use = FALSE


/obj/item/areaeditor/blueprints/slime
	name = "cerulean prints"
	desc = "A one use set of blueprints made of jelly like organic material. Extends the reach of the management console."
	color = "#2956B2"
	allow_non_space_use = FALSE


/obj/item/areaeditor/blueprints/slime/create_area_wrapper(mob/user, new_area_type)
	. = ..()
	if(.)
		qdel(src)


/obj/item/areaeditor/blueprints/slime/edit_area(mob/user)
	var/area/edited_area = ..()
	if(!edited_area)
		return
	for(var/turf/turf in edited_area.contents)
		turf.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		turf.add_atom_colour("#2956B2", FIXED_COLOUR_PRIORITY)
	edited_area.xenobiology_compatible = TRUE
	qdel(src)


//One-use area creation permits.
/obj/item/areaeditor/permit
	name = "construction permit"
	icon_state = "permit"
	desc = "This is a one-use permit that allows the user to officially declare a built room as an addition to the station."
	fluffnotice = "Nanotrasen Engineering requires all on-station construction projects to be approved by a head of staff, as detailed in Nanotrasen Company Regulation 512-C (Mid-Shift Modifications to Company Property). \
						By submitting this form, you accept any fines, fees, or personal injury/death that may occur during construction."
	w_class = WEIGHT_CLASS_TINY


/obj/item/areaeditor/permit/create_area_wrapper(mob/user, new_area_type)
	. = ..()
	if(.)
		qdel(src)


/obj/item/areaeditor/permit/interact_prints(mob/user)
	. = ..()
	var/area/user_area = get_area(user)
	if(get_area_type() == AREA_STATION)
		. += "<p>According to the [src], you are now in <b>\"[sanitize(user_area.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")


//One-use syndicate permits. Sprites by ElGood
/obj/item/areaeditor/permit/syndicate
	name = "syndicate construction permit"
	icon_state = "permit_syndie"
	desc = "This is a one-use permit that allows the user to officially declare a built room as a property of the syndicate"
	fluffnotice = "Intellectual Property of the Syndicate. Syndicate Engineering requires all construction projects to be approved by an officer of sufficient authority, as detailed in Syndicate RaMSS Anti-Nanotrasen Company Regulation F##K-NT-027. \
					By submitting this form, you accept any fines, fees, or personal injury/death that may occur during construction."
	station_name_overrride = "RaMSS Taipan"
	new_area_type = /area/syndicate/unpowered/syndicate_space_base


// Basic area creation blueprints.
/obj/item/areaeditor/create_area_only
	name = "construction blueprints"
	desc = "Used to define new areas in space."
	allow_non_space_use = FALSE


/obj/item/areaeditor/create_area_only/interact_prints(mob/user)
	. = ..()
	var/area/user_area = get_area(user)
	if(get_area_type() == AREA_STATION)
		. += "<p>According to the [src], you are now in <b>\"[sanitize(user_area.name)]\"</b>.</p>"
	var/datum/browser/popup = new(user, "blueprints", "[src]", 700, 500)
	popup.set_content(.)
	popup.open()
	onclose(user, "blueprints")


//Free golem blueprints
/obj/item/areaeditor/create_area_only/golem
	name = "Golem Land Claim"
	station_name_overrride = ""
	fluffnotice = "Praise the Liberator!"


//Blueprint for Theta station
/obj/item/areaeditor/create_area_only/theta
	station_name_overrride = "Theta Station"
	fluffnotice = "Метеорито-стойкая станция, даем гарантию на 200 лет!"


//Blueprint for Gorky17 station
/obj/item/areaeditor/create_area_only/gorky17
	station_name_overrride = "Gorky17 Station"
	fluffnotice = "Секретные чертежи передого фронтира Горький17"


//Blueprint for USSP station
/obj/item/areaeditor/create_area_only/ussp
	station_name_overrride = "USSP Station"
	fluffnotice = "В случае поломки - смотри сюда"


#undef AREA_ERRNONE
#undef AREA_STATION
#undef AREA_SPACE
#undef AREA_SPECIAL

