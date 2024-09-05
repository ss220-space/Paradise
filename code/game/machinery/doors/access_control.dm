/// Maximum brain damage a mob can have until it can't use the electronics
#define MAX_BRAIN_DAMAGE 60

/obj/item/access_control
	name = "access control electronics"
	icon = 'icons/obj/module.dmi'
	icon_state = "access-control"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
	req_access = list(ACCESS_ENGINE)
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

	/// List of accesses currently set
	var/list/selected_accesses = list()
	/// Is the door access require one access or all
	var/one_access = FALSE
	/// An associative list containing all station accesses. Includes their name and access number.
	var/static/list/door_accesses_list = list()
	var/list/current_door_accesses_list = list()


	/// Which direction has unrestricted access to the airlock (e.g. medbay doors from the inside)
	var/unres_access_from = null

	var/emagged

	var/region_min = REGION_GENERAL
	var/region_max = REGION_COMMAND

/obj/item/access_control/Initialize(mapload)
	. = ..()
	if(!length(door_accesses_list))
		for(var/access in get_all_accesses())
			door_accesses_list += list(list(
				"name" = get_access_desc(access),
				"id" = access))
	current_door_accesses_list = door_accesses_list

/obj/item/access_control/emag_act(mob/user)
	emagged = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/access_control/update_icon_state()
	icon_state = "access-control[emagged ? "-smoked" : ""]"

/obj/item/access_control/attack_self(mob/user)
	if(!ishuman(user) && !isrobot(user) || emagged)
		return ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= MAX_BRAIN_DAMAGE)
			to_chat(user, span_warning("You forget how to use [src]."))
			return
	ui_interact(user)

/obj/item/access_control/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/access_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/access_control/ui_data(mob/user)
	var/list/data = list()
	data["selected_accesses"] = selected_accesses
	data["one_access"] = one_access
	data["unrestricted_dir"] = unres_access_from
	return data

/obj/item/access_control/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(region_min, region_max)
	data["door_access_list"] = current_door_accesses_list
	return data

/obj/item/access_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	if(emagged)
		return
	// Mostly taken from the RCD code
	switch(action)
		if("unrestricted_access")
			var/direction = text2num(params["unres_dir"])
			unres_access_from ^= direction

		if("set_one_access")
			one_access = params["access"] == "one" ? TRUE : FALSE

		if("set")
			var/access = text2num(params["access"])
			if(isnull(access))
				return FALSE
			if(access in selected_accesses)
				selected_accesses -= access
			else
				selected_accesses |= access

		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < region_min || region > region_max)
				return FALSE
			selected_accesses |= get_region_accesses(region)

		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < region_min || region > region_max)
				return FALSE
			selected_accesses -= get_region_accesses(region)

		if("grant_all")
			selected_accesses = get_all_accesses()

		if("clear_all")
			selected_accesses = list()

/obj/item/access_control/syndicate
	name = "suspicious access control electronics"
	req_access = list(ACCESS_SYNDICATE)
	/// An associative list containing all station accesses. Includes their name and access number. For use with the UI.
	var/static/list/syndie_door_accesses_list = list()
	region_min = REGION_TAIPAN
	region_max = REGION_TAIPAN

/obj/item/access_control/syndicate/Initialize(mapload)
	. = ..()
	if(!length(syndie_door_accesses_list))
		for(var/access in get_taipan_syndicate_access())
			syndie_door_accesses_list += list(list(
				"name" = get_access_desc(access),
				"id" = access))
	current_door_accesses_list = syndie_door_accesses_list

#undef MAX_BRAIN_DAMAGE
