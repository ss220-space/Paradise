/obj/item/implantpad
	name = "bio-chip pad"
	desc = "Used to modify bio-chips."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantpad-off"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	/// Bio-chip case inside source.
	var/obj/item/implantcase/case


/obj/item/implantpad/Destroy()
	if(case)
		eject_case()
	return ..()


/obj/item/implantpad/update_icon_state()
	icon_state = "implantpad-[case ? "on" : "off"]"


/obj/item/implantpad/attack_self(mob/user)
	ui_interact(user)


/obj/item/implantpad/attackby(obj/item/implantcase/new_case, mob/user, params)
	if(istype(new_case))
		addcase(user, new_case)
	else
		return ..()


/obj/item/implantpad/proc/addcase(mob/user, obj/item/implantcase/new_case)
	if(!user || !new_case)
		return
	if(case)
		to_chat(user, span_warning("There's already a bio-chip in the pad!"))
		return
	user.drop_transfer_item_to_loc(new_case, src)
	case = new_case
	update_icon(UPDATE_ICON_STATE)


/obj/item/implantpad/proc/eject_case(mob/user)
	if(!case)
		to_chat(user, span_warning("There's no bio-chip in the pad!"))
		return

	case.forceMove_turf()
	if(user?.put_in_hands(case, ignore_anim = FALSE))
		add_fingerprint(user)
		case.add_fingerprint(user)

	case = null
	update_icon(UPDATE_ICON_STATE)


/obj/item/implantpad/AltClick(mob/living/user)
	if(!ishuman(user) || user.incapacitated() || !Adjacent(user))
		return
	eject_case(user)


/obj/item/implantpad/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ImplantPad", name, 410, 400, master_ui, state)
		ui.open()


/obj/item/implantpad/ui_data(mob/user)
	var/list/data = list()
	data["contains_case"] = case ? TRUE : FALSE
	if(case && case.imp)
		var/datum/implant_fluff/implant_data = case.imp.implant_data
		data["implant"] = list(
			"name" = implant_data.name,
			"life" = implant_data.life,
			"notes" = implant_data.notes,
			"function" = implant_data.function,
			"image" = "[icon2base64(icon(initial(case.imp.icon), initial(case.imp.icon_state), SOUTH, 1))]",
		)
		var/obj/item/implant/tracking/tracking_imp = case.imp
		data["tag"] = istype(tracking_imp) ? tracking_imp.gps_tag : null
	return data


/obj/item/implantpad/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	switch(action)
		if("tag")
			var/obj/item/implant/tracking/tracking_imp = case.imp
			if(!istype(tracking_imp))
				return
			var/newtag = params["newtag"] || tracking_imp.gps_tag
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(length(newtag))
				tracking_imp.gps_tag = newtag

		if("eject_case")
			eject_case(ui.user)

