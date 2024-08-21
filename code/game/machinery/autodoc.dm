/*автодок это достаточно крупная штука, делающая простые вещи. Я начал ее делать, но потом выгорел,
 да и в конечном итоге решил, что он нахер не нужен в нашем билде, но
 мне было жалко, удалять то, на что я потратил большое колво времени, поэтому тут я решил оставить полностью
 закоменченный файл. сори

#define BODY_ZONE_BY_GROUPS list(BODY_ZONE_HEAD = BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES = BODY_ZONE_HEAD,
								BODY_ZONE_PRECISE_MOUTH = BODY_ZONE_HEAD, BODY_ZONE_CHEST= BODY_ZONE_CHEST,
								BODY_ZONE_L_ARM = BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND = BODY_ZONE_L_ARM,
								BODY_ZONE_R_ARM = BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND = BODY_ZONE_R_ARM,
								BODY_ZONE_L_LEG = BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT = BODY_ZONE_L_LEG,
								BODY_ZONE_R_LEG = BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT = BODY_ZONE_R_LEG,
								BODY_ZONE_TAIL = "other", BODY_ZONE_WING = "other",
								BODY_ZONE_PRECISE_GROIN = BODY_ZONE_PRECISE_GROIN)

#define HEAL_PER_TIME 5

#define FIXING_TIME 30 SECONDS

/obj/machinery/autodoc
	name = "autodoc"
	icon = 'icons/obj/machines/autodoc.dmi'
	icon_state = "autodoc"
	anchored = TRUE
	density = TRUE
	var/obj/structure/autodoc_tray/connected
	var/mob/living/carbon/human/occupant
	var/toggle_sound = 'sound/items/deconstruct.ogg'
	var/list/organ_by_name = list("extOrgan" = list(), "intOrgan" = list())
	var/list/tgui_icons = list()
	var/list/organs_to_heal
	var/ishealing = FALSE
	var/healing
	var/fixtimer = 0

/obj/machinery/autodoc/Initialize(mapload)
	. = ..()
	update_icon()
	set_light(1, LIGHTING_MINIMUM_POWER)
	for(var/i in list("head", "chest", "l_arm", "r_arm", "l_leg", "r_leg", "groin", "other", "human"))
		tgui_icons[i] = icon2base64(icon('icons/misc/autodoc.dmi', i))

/obj/machinery/autodoc/Destroy()
	remove_contents()
	return ..()

/obj/machinery/autodoc/obj_break(damage_flag)
	remove_contents()
	return ..()

/obj/machinery/autodoc/proc/remove_contents()
	if(connected)
		QDEL_NULL(connected)
	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/target in src)
		target.forceMove(source_turf)


/obj/machinery/autodoc/examine(mob/user)
	. = ..()
	. += span_info("You can rotate [src] by using </b>wrench<b>.")


/obj/machinery/autodoc/update_overlays()
	. = ..()
	underlays.Cut()
	underlays += emissive_appearance(icon, "indicator")

	if(connected)
		return


/obj/machinery/autodoc/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		add_fingerprint(user)
		return
	if(istype(I, /obj/item/organ))
		user.drop_item_ground(I)
		I.forceMove(src)
		return
	return ..()


/obj/machinery/autodoc/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(length(contents))
		to_chat(user, span_warning("You can not rotate [src] while its full!"))
		return .
	if(connected)
		to_chat(user, span_warning("You can not rotate [src] while its open!"))
		return .
	if(!I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume) || length(contents) || connected)
		return .
	dir = turn(dir, 90)
	to_chat(user, span_notice("You rotate [src]."))

/obj/machinery/autodoc/attack_ai(mob/user)
	return

/obj/machinery/autodoc/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/autodoc/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AutoDoc", name, 800, 500, master_ui, state)
		ui.open()

/obj/machinery/autodoc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	switch(action)
		if("ChangeTrayState")
			tray_toggle(ui.user)
		if("RemoveOrgans")
			remove_organs()
		if("ScanOccupant")
			scan_occupant()
		if("CompleteExternal")
			if(!occupant)
				return
			fixtimer = world.time + FIXING_TIME
			healing = addtimer(CALLBACK(src, PROC_REF(complete_external)), FIXING_TIME, (TIMER_STOPPABLE|TIMER_UNIQUE))
		if("HealBruteBurn")
			if(!occupant)
				return
			var/list/extOrgans = organ_by_name["extOrgan"]
			organs_to_heal = extOrgans.Copy()
		if("FixOrgan")
			if(!occupant)
				return
			fixtimer = world.time + FIXING_TIME
			healing = addtimer(CALLBACK(src, PROC_REF(fixorgan), params["organ"], params["type"], ), FIXING_TIME, (TIMER_STOPPABLE|TIMER_UNIQUE))
		if("EmptyOrganStorage")
			for(var/obj/item/organ/internal/new_organ in contents)
				new_organ.forceMove(get_turf(src))

/obj/machinery/autodoc/proc/fixorgan(organ_name, type)
	var/obj/item/organ/external/extOrgan
	var/obj/item/organ/internal/intOrgan
	if(organ_name in organ_by_name["extOrgan"])
		extOrgan = organ_by_name["extOrgan"][organ_name]
	else if(organ_name in organ_by_name["intOrgan"])
		intOrgan = organ_by_name["intOrgan"][organ_name]
	if(!(intOrgan && (intOrgan in occupant.internal_organs) || extOrgan && (extOrgan in occupant.bodyparts)))
		type = null
		visible_message("блять")
	switch(type)
		if("fracture")
			extOrgan.mend_fracture()
		if("bleeding")
			extOrgan.stop_internal_bleeding()
		if("completeInternal")
			for(var/obj/item/organ/internal/organ in contents)
				if(occupant.get_organ_slot(organ.slot) || (extOrgan.limb_zone != organ.parent_organ_zone))
					continue
				organ.insert(occupant)
		if("damage")
			intOrgan.damage = 0
		if("replace")
			for(var/obj/item/organ/internal/new_organ in contents)
				if(intOrgan.slot == new_organ.slot)
					new_organ.replaced(occupant)
					break
		if("remove")
			intOrgan.remove(occupant)
			intOrgan.forceMove(src)
	fixtimer = 0
	healing = null

/obj/machinery/autodoc/proc/complete_external()
	for(var/obj/item/organ/external/organ in contents)
		if(occupant.bodyparts_by_name[organ.limb_zone])
			continue
		if(!occupant.get_organ(organ.parent_organ_zone))
			continue
		organ.replaced(occupant)
	occupant.UpdateDamageIcon()
	fixtimer = 0
	healing = null

/obj/machinery/autodoc/process()
	if(!organs_to_heal)
		return
	var/obj/item/organ/external/current_organ = organs_to_heal[organs_to_heal[1]]
	if(current_organ.brute_dam)
		current_organ.brute_dam = clamp(current_organ.brute_dam-HEAL_PER_TIME, 0, current_organ.brute_dam)
		return
	if(current_organ.burn_dam)
		current_organ.burn_dam = clamp(current_organ.brute_dam-HEAL_PER_TIME, 0, current_organ.burn_dam)
		return
	if(organs_to_heal.len > 1)
		organs_to_heal = organs_to_heal.Copy(2)
		occupant.updatehealth("heal overall damage")
		occupant.UpdateDamageIcon()
		return
	occupant.UpdateDamageIcon()
	organs_to_heal = null

/obj/machinery/autodoc/proc/scan_occupant()
	if(!occupant)
		return

/obj/machinery/autodoc/ui_data(mob/user)
	var/list/data = list()
	data["HasTray"] = istype(connected)
	data["isHealing"] = !(isnull(healing) && isnull(organs_to_heal))
	data["fixtimer"] = fixtimer? time2text((fixtimer - world.time), "mm:ss") : FALSE
	var/occupantData[0]
	occupantData["TotalBruteBurn"] = 0

	if(occupant)
		for(var/obj/item/organ/external/E as anything in occupant.bodyparts)
			var/organData[0]
			organData["name"] = E.name
			organData["open"] = E.open
			organData["germ_level"] = E.germ_level
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			occupantData["TotalBruteBurn"] += E.brute_dam + E.burn_dam
			organData["broken"] = E.has_fracture()
			organData["dead"] = E.is_dead()
			organData["internalBleeding"] = E.has_internal_bleeding()

			if(!occupantData[BODY_ZONE_BY_GROUPS[E.limb_zone]])
				occupantData[BODY_ZONE_BY_GROUPS[E.limb_zone]] = list()
				occupantData[BODY_ZONE_BY_GROUPS[E.limb_zone]]["extOrgan"] = list()
			occupantData[BODY_ZONE_BY_GROUPS[E.limb_zone]]["extOrgan"] += list(organData)

		for(var/obj/item/organ/internal/organ as anything in occupant.internal_organs)
			var/organData[0]
			organData["name"] = organ.name
			organData["germ_level"] = organ.germ_level
			organData["damage"] = organ.damage
			organData["dead"] = (organ.is_dead())
			if(!occupantData[BODY_ZONE_BY_GROUPS[organ.parent_organ_zone]]["intOrgan"])
				occupantData[BODY_ZONE_BY_GROUPS[organ.parent_organ_zone]]["intOrgan"] = list()
			occupantData[BODY_ZONE_BY_GROUPS[organ.parent_organ_zone]]["intOrgan"] += list(organData)

	data["healtimer"] = organs_to_heal? time2text(((occupantData["TotalBruteBurn"]*2/5) SECONDS), "mm:ss") : FALSE
	data["occupant"] = occupantData
	return data

/obj/machinery/autodoc/ui_static_data(mob/user)
	var/list/data = list()
	data["TguiIcons"] = tgui_icons
	return data

/obj/machinery/autodoc/proc/tray_toggle(mob/user, skip_checks = FALSE)
	if(connected)
		for(var/mob/living/carbon/human/check in connected.loc)
			if(!skip_checks && (check.anchored || check.move_resist == INFINITY))
				continue
			check.forceMove(src)
			occupant = check
			for(var/obj/item/organ/external/E as anything in occupant.bodyparts)
				organ_by_name["extOrgan"][E.name] = E
			for(var/obj/item/organ/internal/organ as anything in occupant.internal_organs)
				organ_by_name["intOrgan"][organ.name] = organ
			break

		playsound(loc, toggle_sound, 50, TRUE)
		QDEL_NULL(connected)
	else
		var/turf/check_turf = get_step(src, dir)
		var/desity_found = check_turf.density
		if(!skip_checks && !desity_found)
			for(var/atom/movable/check in check_turf)
				if(!skip_checks && check.density)
					desity_found = TRUE
					break
		if(!skip_checks && desity_found)
			if(user)
				to_chat(user, span_warning("Tray location is blocked!"))
			return FALSE
		playsound(loc, toggle_sound, 50, TRUE)
		connect()

	if(user)
		add_fingerprint(user)
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/machinery/autodoc/proc/connect()
	var/turf/target_turf = get_step(src, dir)

	connected = new /obj/structure/autodoc_tray(target_turf)

	if(target_turf.contents.Find(connected))
		connected.doc = src
		update_icon(UPDATE_OVERLAYS)

		for(var/mob/check in src)
			check.forceMove(connected.loc)
		occupant = null
		organ_by_name = list("extOrgan" = list(), "intOrgan" = list())
		connected.dir = dir
		return

	QDEL_NULL(connected)

/obj/machinery/autodoc/proc/remove_organs()
	var/turf/target_turf = get_step(src, dir)
	for(var/obj/items/check in src)
			check.forceMove(target_turf)

/obj/machinery/autodoc/relaymove(mob/user)
	if(user.incapacitated())
		return
	tray_toggle(user)


/obj/machinery/autodoc/container_resist(mob/living/carbon/user)
	if(!iscarbon(user) || user.incapacitated())
		return
	to_chat(user, span_alert("You attempt to slide yourself out of [src]..."))
	tray_toggle(user)


/obj/machinery/autodoc/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)

/obj/structure/autodoc_tray
	name = "autodoc tray"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema_tray"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/obj/machinery/autodoc/doc

#undef BODY_ZONE_BY_GROUPS */
