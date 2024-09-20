/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/weapons/energy.dmi'
	fire_sound_text = "laser blast"
	gun_light_overlay = "flight"
	ammo_x_offset = 2

	var/obj/item/stock_parts/cell/cell	//What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell/laser
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1	//The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/modifystate = FALSE
	var/shaded_charge = FALSE	//if this gun uses a stateful charge bar for more detail
	var/selfcharge = FALSE
	var/can_charge = TRUE
	var/charge_sections = 4
	var/charge_tick = 0
	var/charge_delay = 4
	/// Used when updating icon and overlays
	var/new_icon_state
	/// If the item uses a shared set of overlays instead of being based on icon_state
	var/overlay_set
	/// Used when updating icon and overlays to determine the energy pips
	var/ratio

	var/can_add_sibyl_system = TRUE	//if a sibyl system's mod can be added or removed if it already has one
	var/obj/item/sibyl_system_mod/sibyl_mod = null

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(sibyl_mod)
		. += span_notice("Вы видите индикаторы модуля Sibyl System.")


/obj/item/gun/energy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/sibyl_system_mod))
		add_fingerprint(user)
		var/obj/item/sibyl_system_mod/new_sibyl = I
		if(!can_add_sibyl_system)
			to_chat(user, span_warning("The [name] is incompatible with the sibyl systems module."))
			return ATTACK_CHAIN_PROCEED
		if(sibyl_mod)
			to_chat(user, span_warning("The [name] is already has a sibyl systems module installed."))
			return ATTACK_CHAIN_PROCEED
		new_sibyl.install(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(sibyl_mod && istype(I, /obj/item/card/id))
		add_fingerprint(user)
		sibyl_mod.toggleAuthorization(I, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/gun/energy/proc/toggle_voice()
	set name = "Переключить голос Sibyl System"
	set category = "Object"
	set desc = "Кликните для переключения голосовой подсистемы."

	if(sibyl_mod)
		sibyl_mod.toggle_voice(usr)

/obj/item/gun/energy/screwdriver_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_SCREWDRIVER_ACT)
			sibyl_mod.state = SIBSYS_STATE_INSTALLED
			to_chat(user, span_notice("Вы закрутили шурупы мода Sibyl System в [src]."))
			return
		else
			if(prob(90))
				sibyl_mod.state = SIBSYS_STATE_SCREWDRIVER_ACT
				to_chat(user, span_notice("Вы успешно открутили шурупы мода Sibyl System от [src]."))
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] сорвалась и повредила [affecting.name]!"))
			return

/obj/item/gun/energy/welder_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
			to_chat(user, span_notice("Вы начинаете заваривать болты мода Sibyl System от [src]..."))
			if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				sibyl_mod.state = SIBSYS_STATE_SCREWDRIVER_ACT
				to_chat(user, span_notice("Вы заварили болты мода Sibyl System в [src]."))
			return
		if(sibyl_mod.state == SIBSYS_STATE_SCREWDRIVER_ACT)
			to_chat(user, span_notice("Вы начинаете разваривать болты мода Sibyl System от [src]..."))
			if(I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				if(prob(70))
					sibyl_mod.state = SIBSYS_STATE_WELDER_ACT
					to_chat(user, span_notice("Вы успешно разварили болты мода Sibyl System от [src]."))
				else
					var/mob/living/carbon/human/H = user
					var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
					user.apply_damage(10, BURN , affecting)
					user.emote("scream")
					to_chat(user, span_warning("Проклятье! [I] дёрнулась и прожгла [affecting.name]!"))
			return

/obj/item/gun/energy/crowbar_act(mob/living/user, obj/item/I)
	..()
	if(sibyl_mod && user.a_intent != INTENT_HARM)
		if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
			to_chat(user, span_notice("Вы начинаете отковыривать болты мода Sibyl System от [src]..."))
			if(!I.use_tool(src, user, 16 SECONDS, volume = I.tool_volume))
				return
			if(prob(95))
				if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
					sibyl_mod.uninstall(src)
					to_chat(user, span_notice("Вы успешно отковыряли болты мода Sibyl System от [src]."))
			else
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/affecting = H.get_organ(user.r_hand == I ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				user.apply_damage(5, BRUTE , affecting)
				user.emote("scream")
				to_chat(user, span_warning("Проклятье! [I] соскальзнула и повредила [affecting.name]!"))
			return

/obj/item/gun/energy/emag_act(mob/user)
	if(!sibyl_mod?.emagged)
		add_attack_logs(user, sibyl_mod, "emagged")
		sibyl_mod.emagged = TRUE
		sibyl_mod.unlock()
		if(user)
			user.visible_message(span_warning("От [src] летят искры!"), span_notice("Вы взломали [src], что привело к выключению болтов предохранителя."))
		playsound(src.loc, 'sound/effects/sparks4.ogg', 30, 1)
		do_sparks(5, 1, src)
		return

/obj/item/gun/energy/emp_act(severity)
	cell.use(round(cell.charge / severity))
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot() //phil235
	update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize(mapload, ...)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.give(cell.maxcharge)
	update_ammo_types()
	on_recharge()
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if(selfcharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/process()
	if(selfcharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return // check if we actually need to recharge
		cell.give(100) //... to recharge the shot
		on_recharge()
		update_icon()

/obj/item/gun/energy/proc/on_recharge()
	newshot()


/obj/item/gun/energy/attack_self(mob/living/user)
	. = ..()
	if(!. && length(ammo_type) > 1)
		select_fire(user)
		update_icon()


/obj/item/gun/energy/can_shoot(mob/living/user)
	if(user && sibyl_mod && !sibyl_mod.check_auth(user))
		return FALSE

	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	. = cell.charge >= shot.e_cost

	if(!.)
		sibyl_mod?.sibyl_sound(user, 'sound/voice/dominator/battery.ogg', 5 SECONDS)


/obj/item/gun/energy/newshot()
	if(!ammo_type || !cell)
		return
	if(!chambered)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if(cell.charge >= shot.e_cost) //if there's enough power in the WEAPON'S cell...
			chambered = shot //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
		robocharge()
	chambered = null //either way, released the prepared shot
	newshot()

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = 1, params, zone_override, bonus_spread = 0)
	if(!chambered && can_shoot(user))
		process_chamber()
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	if(!user)	// If it's called by something, but not human (Security level changing), drop firemode to non-lethal.
		select = 1
	else if(++select > ammo_type.len)
		select = 1
	else
		if(sibyl_mod && !sibyl_mod.check_select(select))
			select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(!isnull(user) && (shot.select_name || shot.fluff_select_name))
		var/static/gun_modes_ru = list( //about 2/3 of them will never be shown in game, but better save, than sorry
			"practice" = "режим практики",
			"kill" = "летальный режим",
			"shuriken" = "метатель сюрикенов",
			"energy" = "стандартный режим",
			"anti-vehicle" = "тяжелый лазер",
			"DESTROY" = "режим УНИЧТОЖЕНИЯ",
			"ANNIHILATE" = "режим ИСТРЕБЛЕНИЯ",
			"bluetag" = "синий режим",
			"redtag" = "красный режим",
			"precise" = "точный выстрел", //both used in multi-lens scattershot
			"scatter" = "рассеянный выстрел",
			"stun" = "тазер",
			"ion" = "ионный выстрел",
			"declone" = "деклонер",
			"MINDFUCK" = "мозгодавка",
			"floraalpha" = "альфа режим",
			"florabeta" = "бета режим",
			"floragamma" = "гамма режим",
			"goddamn meteor" = "стрельба чертовым метеоритом",
			"disable" = "нейтрализатор",
			"plasma burst" = "пучок плазмы",
			"blue" = "синий портал",
			"orange" = "оранжевый портал",
			"bolt" = "дротик", //used in e-crossbows
			"heavy bolt" = "тяжелый дротик",
			"toxic dart" = "токсичный дротик",
			"lightning beam" = "луч молнии",
			"plasma dart" = "плазменный дротик",
			"clown" = "клоунский режим",
			"snipe" = "снайперский режим",
			"teleport beam" = "режим телепортации",
			"gun mimic" = "режим мимикрии",
			"non-lethal paralyzer" = "нелетальный парализатор",
			"lethal-eliminator" = "летальный устранитель",
			"execution-slaughter" = "режим казни",
			"emitter" = "режим эмиттера",
			"spraydown" = "режим распыления",
			"spike" = "стрельба шипами",
			"kinetic" = "кинетический выстрел",
			"accelerator" = "ускоренный выстрел",
		)

		balloon_alert(user, "[gun_modes_ru[shot.fluff_select_name ? shot.fluff_select_name : shot.select_name]]")
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot()
	update_icon()


/obj/item/gun/energy/update_icon(updates = ALL)
	. = ..()
	update_equipped_item(update_speedmods = FALSE)


/obj/item/gun/energy/update_icon_state()
	icon_state = initial(icon_state)
	ratio = CEILING((cell.charge / cell.maxcharge) * charge_sections, 1)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	new_icon_state = "[icon_state]_charge"
	var/new_item_state = null
	if(!initial(item_state))
		new_item_state = icon_state
	if(modifystate)
		new_icon_state += "_[shot.select_name]"
		if(new_item_state)
			new_item_state += "[shot.select_name]"
	if(new_item_state)
		new_item_state += "[ratio]"
		item_state = new_item_state
	if(current_skin)
		icon_state = current_skin


/obj/item/gun/energy/update_overlays()
	. = ..()
	var/overlay_name = overlay_set ? overlay_set : icon_state
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(modifystate)
		. += "[overlay_name]_[shot.select_name]"
	if(cell.charge < shot.e_cost)
		. += "[overlay_name]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				. += image(icon = icon, icon_state = new_icon_state, pixel_x = ammo_x_offset * (i - 1))
		else
			. += image(icon = icon, icon_state = "[overlay_name]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(gun_light && gun_light_overlay)
		var/iconF = gun_light_overlay
		if(gun_light.on)
			iconF = "[gun_light_overlay]_on"
		. += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(bayonet && bayonet_overlay)
		. += bayonet_overlay


/obj/item/gun/energy/ui_action_click(mob/user, datum/action/action, leftclick)
	toggle_gunlight()


/obj/item/gun/energy/suicide_act(mob/user)
	if(can_trigger_gun(user))
		user.visible_message(span_suicide("[user] is putting the barrel of the [name] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide."))
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message(span_suicide("[user] melts [user.p_their()] face off with the [name]!"))
			playsound(loc, fire_sound, 50, TRUE, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return FIRELOSS
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(span_suicide("[user] is pretending to blow [user.p_their()] brains out with the [name]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/weapons/empty.ogg', 50, TRUE, -1)
		return OXYLOSS


/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, selfcharge))
		if(var_value)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)


/obj/item/gun/energy/proc/robocharge()
	if(cell.charge == cell.maxcharge)
		// No point in recharging a weapon's cell that is already at 100%. That would just waste borg cell power for no reason.
		return
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				cell.give(shot.e_cost)	//... to recharge the shot
