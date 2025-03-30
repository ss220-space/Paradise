GLOBAL_LIST_EMPTY(gear_datums)

/datum/gear
	var/index_name       //index. Must be unique.
	var/display_name = "bug" //Name
	var/description        //Description of this gear. If left blank will default to the description of the pathed item.
	var/atom/path          //Path to item.
	var/icon_state		   //Icon state of item
	var/icon			   //File of icon
	var/base64icon         //It will be generated automaticly
	var/cost = 1           //Number of points used. Items in general cost 1 point, storage/armor/gloves/special use costs 2 points.
	var/slot               //Slot to equip to.
	var/list/allowed_roles //Roles that can spawn with this item.
	var/sort_category = "General"
	var/list/gear_tweaks = list() //List of datums which will alter the item after it has been spawned.
	var/subtype_path = /datum/gear //for skipping organizational subtypes (optional)
	var/subtype_cost_overlap = TRUE //if subtypes can take points at the same time
	var/implantable = FALSE    //For organ-like implants (huds, pumps, etc)
	var/donator_tier = 0

/datum/gear/New()
	..()
	if(!description)
		description = path::desc
	update_gear_icon()


/datum/gear/proc/update_gear_icon(color)
	var/gear_icon = get_gear_icon(color)
	if(!gear_icon)
		return
	base64icon = gear_icon

/datum/gear/proc/get_gear_icon(color)
	if(initial(icon) && initial(icon_state))
		return
	icon_state = path::icon_state
	icon = path::icon
	if(!initial(description))
		description = path::desc
	if(!icon || !icon_state || !color)
		return
	var/icon/new_icon = icon(icon, icon_state, SOUTH, 1, FALSE)
	if(color)
		new_icon.Blend(color, ICON_MULTIPLY)
	return icon2base64(new_icon)

/datum/gear/proc/get_display_name()
	return ((display_name == /datum/gear::display_name)? path.name : display_name)

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(npath, nlocation)
	path = npath
	location = nlocation

/datum/gear/proc/spawn_item(location, metadata)
	var/datum/gear_data/gear_data = new(path, location)
	for(var/datum/gear_tweak/tweak in gear_tweaks)
		tweak.tweak_gear_data(metadata["[tweak]"], gear_data)
	var/item = new gear_data.path(gear_data.location)
	for(var/datum/gear_tweak/tweak in gear_tweaks)
		tweak.tweak_item(item, metadata["[tweak]"])
	return item

/datum/gear/proc/can_select(client/cl, job_name, species_name, silent = FALSE)
	if(!job_name || !LAZYLEN(allowed_roles))
		return TRUE

	if(job_name in allowed_roles)
		return TRUE

	if(cl && !silent)
		to_chat(cl, span_warning("\"[capitalize(get_display_name())]\" недоступно для вашей профессии!"))

	return FALSE


/datum/gear/proc/get_header_tips()
	return
