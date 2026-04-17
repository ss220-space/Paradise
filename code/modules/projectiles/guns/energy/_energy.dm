/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/weapons/energy.dmi'
	fire_sound_text = "laser blast"
	ammo_x_offset = 2
	attachable_allowed = GUN_MODULE_CLASS_ENERGY_WEAPON

	/// What type of power cell this uses
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell/laser
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	/// The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/select = 1
	var/modifystate = FALSE
	/// If this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	var/selfcharge = FALSE
	/// Recharge rate if self-charging
	var/recharge_rate = 100
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
	/// If a sibyl system's mod can be added or removed if it already has one
	var/can_add_sibyl_system = TRUE
	var/obj/item/gun_module/sibyl/sibyl_mod = null
	var/isclockwork = FALSE

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(sibyl_mod)
		. += span_notice("Вы видите индикаторы модуля Sibyl System.")
		if(sibyl_mod.state == SIBSYS_STATE_SCREWDRIVER_ACT)
			. += span_notice("Крепление модуля Sibyl System ослаблено.")
		else if(sibyl_mod.state == SIBSYS_STATE_WELDER_ACT)
			. += span_danger("Модуль Sibyl System поврежден.")

/obj/item/gun/energy/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_energy))

/**
 *
 * Outputs type-specific weapon stats for energy-based firearms based on its firing modes
 * and the stats of those firing modes. Esoteric firing modes like ion are currently not supported
 * but can be added easily
 *
 */
/obj/item/gun/energy/proc/add_notes_energy()
	var/list/readout = list()
	readout += "<b><u>СТРЕЛЬБА</u></b>"
	// Make sure there is something to actually retrieve
	if(!length(ammo_type))
		return
	var/obj/projectile/exam_proj
	readout += "- Имеет <b>[length(ammo_type)]</b> режим[DECL_CREDIT(length(ammo_type))] стрельбы."
	for(var/obj/item/ammo_casing/energy/for_ammo as anything in ammo_type)
		exam_proj = for_ammo.projectile_type

		if((damage_mod <= 0 && stamina_mod <= 0) || (initial(exam_proj.damage) <= 0 && initial(exam_proj.stamina) <= 0))
			readout += span_boldnotice("- Не наносит значимого ущерба при попадании.")
			return readout.Join("\n") // Sending over the singular string, rather than the whole list

		if(!ispath(exam_proj))
			continue

		if(initial(exam_proj.damage) > 0) // Don't divide by 0!!!!!
			var/lethality_str = initial(exam_proj.damage_type) == STAMINA ? span_blue("<b>нелетального</b>") : span_red("<b>летального</b>")
			var/lethal_hits_to_crit = span_warning("[HITS_TO_CRIT((initial(exam_proj.damage) * damage_mod) * for_ammo.pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.damage) * damage_mod) * for_ammo.pellets), "ие", "ия", "ий")]")
			readout += "- Для [lethality_str] устранения противника в режиме \"[span_warning("[for_ammo.select_name]")]\" потребуется в среднем [lethal_hits_to_crit]."
			if(initial(exam_proj.stamina) > 0) // In case a projectile does damage AND stamina damage (Energy Crossbow)
				var/non_lethal_hits_to_crit = span_warning("[HITS_TO_CRIT((initial(exam_proj.stamina) * stamina_mod) * for_ammo.pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.stamina) * stamina_mod) * for_ammo.pellets), "ие", "ия", "ий")]")
				readout += "- Для <b>[span_blue("нелетального")]</b> обезвреживания противника в режиме \"[span_warning("[for_ammo.select_name]")]\" потребуется в среднем [non_lethal_hits_to_crit]."

	return readout.Join("\n") // Sending over the singular string, rather than the whole list

/obj/item/gun/energy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun_module/sibyl))
		add_fingerprint(user)
		var/obj/item/gun_module/sibyl/new_sibyl = I
		if(!can_add_sibyl_system)
			to_chat(user, span_warning("The [name] is incompatible with the sibyl systems module."))
			return ATTACK_CHAIN_PROCEED

		if(sibyl_mod)
			to_chat(user, span_warning("The [name] is already has a sibyl systems module installed."))
			return ATTACK_CHAIN_PROCEED

		if(new_sibyl.try_attach(src, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	if(sibyl_mod && is_id_card(I))
		add_fingerprint(user)
		sibyl_mod.toggle_authorization(I, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/gun/energy/proc/toggle_voice()
	set name = "Сменить голос Sibyl System"
	set category = VERB_CATEGORY_OBJECT
	set desc = "Кликните для переключения голосовой подсистемы."

	if(sibyl_mod)
		sibyl_mod.toggle_voice(usr)

/obj/item/gun/energy/emp_act(severity)
	cell?.use(round(cell.charge / severity))
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot() //phil235
	update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize(mapload)
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
	update_appearance()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= length(ammo_type), i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if(selfcharge)
		STOP_PROCESSING(SSobj, src)
	QDEL_NULL(cell)
	QDEL_NULL(sibyl_mod)
	QDEL_LIST(ammo_type)
	return ..()

/obj/item/gun/energy/process()
	if(selfcharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return // check if we actually need to recharge
		cell.give(recharge_rate) // to recharge the shot
		on_recharge()
		update_icon()

/obj/item/gun/energy/proc/on_recharge()
	newshot()

/obj/item/gun/energy/attack_self(mob/living/user)
	. = ..()
	if(!. && length(ammo_type) > 1)
		select_fire(user)
		update_icon()

/obj/item/gun/energy/can_shoot(mob/living/user, silent = FALSE)
	if(user && sibyl_mod)
		if(!sibyl_mod.check_auth(user))
			return FALSE

		if(!sibyl_mod.can_fire(user))
			return FALSE

	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	. = cell.charge >= shot.e_cost

	if(!. && !silent)
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

/obj/item/gun/energy/handle_chamber()
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
	else if(++select > length(ammo_type))
		select = 1
	else
		if(sibyl_mod && !sibyl_mod.check_select(select))
			select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(!isnull(user) && (shot.select_name || shot.fluff_select_name))
		var/static/gun_modes_ru = list(//about 2/3 of them will never be shown in game, but better save, than sorry
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
	ratio = ceil((cell.charge / cell.maxcharge) * charge_sections)
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
	if(isclockwork)
		return
	var/overlay_name = overlay_set ? overlay_set : icon_state
	if(!length(ammo_type))
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(modifystate)
		. += "[overlay_name]_[shot.select_name]"
	if(!cell || cell.charge < shot.e_cost)
		. += "[overlay_name]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				. += image(icon = icon, icon_state = new_icon_state, pixel_w = ammo_x_offset * (i - 1))
		else
			. += image(icon = icon, icon_state = "[overlay_name]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(bayonet && bayonet_overlay)
		. += bayonet_overlay

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
		if(R?.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))		//Take power from the borg...
				cell.give(shot.e_cost)	//... to recharge the shot

/obj/item/gun/energy/proc/turret_check()
	return !HAS_TRAIT(src, TRAIT_NOT_TURRET_GUN)

/obj/item/gun/energy/proc/turret_deconstruct(list/data)
	return

/obj/item/gun/energy/proc/prepare_gun_data(list/data)
	return

/obj/item/gun/energy/proc/setup_gun_for_turret(list/data)
	return

// MARK: Sibyl System

/obj/item/gun/energy/proc/install_sibyl()
	var/obj/item/gun_module/sibyl/module = new /obj/item/gun_module/sibyl()
	module.voice_is_enabled = FALSE
	module.try_attach(src, null)
