/obj/item/ammo_casing
	name = "bullet casing"
	desc = "Иногда гильза от пули — это просто гильза, и ничего более."
	gender = FEMALE
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "s-casing"
	origin_tech = "materials=3;combat=3"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 1000)
	override_notes = TRUE
	/// What sound should play when this ammo is fired
	var/fire_sound = null
	/// What sound should play when this ammo hits the ground
	var/casing_drop_sound = SFX_CASING_DROP
	/// Which kind of guns it can be loaded into
	var/caliber = null
	/// The bullet type to create when New() is called
	var/projectile_type = null
	/// The loaded bullet
	var/obj/projectile/BB = null
	/// Pellets for spreadshot
	var/pellets = 1
	/// Variance for inaccuracy fundamental to the casing
	var/variance = 0
	/// Delay for energy weapons
	var/delay = 0
	/// Randomspread for automatics
	var/randomspread = FALSE
	/// Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/click_cooldown_override = 0
	/// pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/harmful = TRUE
	/// Whether we can pick this shell by clicking on it with the ammo box
	var/can_be_box_inserted = TRUE

	/// What type of muzzle flash effect will be shown. If null then no effect and flash of light will be shown
	var/muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	/// What color the flash has. If null then the flash won't cause lighting
	var/muzzle_flash_color = LIGHT_COLOR_TUNGSTEN
	/// What range the muzzle flash has
	var/muzzle_flash_range = MUZZLE_FLASH_RANGE_WEAK
	/// How strong the flash is
	var/muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK
	/// Ammo type overlay for magazines (not add overlay if null)
	var/bullet_type = null

	/// Ammo marking for desc and names. Should be like `"9x19 мм БП."`
	var/ammo_marking = null
	/**
	 * Extra description info for specific ammo types.
	 *
	 * Example: `"Воспламеяется при попадании."`
	 */
	var/extra_info = null
	/// `name` and `ru_names` won't be dynamically updated if set to `TRUE`
	var/no_update_names = FALSE
	/// `desc` won't be dynamically updated if set to `TRUE`
	var/no_update_desc = FALSE

/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	dir = pick(GLOB.alldirs)
	update_appearance(updates = ALL)

/obj/item/ammo_casing/Destroy()
	QDEL_NULL(BB)
	if(isammobox(loc))
		var/obj/item/ammo_box/box = loc
		box.stored_ammo?.RemoveAll(src)
	if(!isgun(loc))
		return ..()
	var/obj/item/gun/gun = loc
	if(gun.chambered != src)
		return ..()
	gun.chambered = null
	. = ..()

/obj/item/ammo_casing/update_icon_state()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"

/obj/item/ammo_casing/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_ammo))

/**
 *
 * Outputs type-specific weapon stats for ammunition based on the projectile loaded inside the casing.
 * Distinguishes between critting and stam-critting in separate lines
 *
 */
/obj/item/ammo_casing/proc/add_notes_ammo()
	// Try to get a projectile to derive stats from
	var/obj/projectile/exam_proj = projectile_type
	var/initial_damage = initial(exam_proj.damage)
	var/initial_stamina = initial(exam_proj.stamina)
	// projectile damage multiplier for guns with snowflaked damage multipliers
	var/proj_damage_mult = 1
	// projectile stamina damage multiplier
	var/proj_stamine_mult = 1
	if(!ispath(exam_proj) || pellets == 0)
		return

	// are we in an ammo box?
	if(isammobox(loc))
		var/obj/item/ammo_box/our_box = loc
		// is our ammo box in a gun?
		if(isgun(our_box.loc))
			var/obj/item/gun/our_gun = our_box.loc
			// grab the damage multiplier
			proj_damage_mult = our_gun.damage_mod
			proj_stamine_mult = our_gun.stamina_mod
	// if not, are we just in a gun e.g. chambered
	else if(isgun(loc))
		var/obj/item/gun/our_gun = loc
		// grab the damage multiplier.
		proj_damage_mult = our_gun.damage_mod
		proj_stamine_mult = our_gun.stamina_mod

	var/list/readout = list()
	readout += "<b><u>СТРЕЛЬБА — [get_ammo_marking()]</u></b>"
	if((proj_damage_mult <= 0 && proj_stamine_mult <= 0) || (initial_damage <= 0 && initial_stamina <= 0))
		return span_boldnotice("- Боеприпасы [span_warning(get_ammo_marking())] не наносят значимого ущерба при попадании.")

	// No dividing by 0
	if(initial_damage)
		var/lethal_hits_to_crit_str = span_warning("[HITS_TO_CRIT((initial(exam_proj.damage) * proj_damage_mult) * pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.damage) * proj_damage_mult) * pellets), "ие", "ия", "ий")]")
		readout += "- Для нанесения <b>[span_red("летальных ранений")]</b> противнику боеприпасами [span_warning(get_ammo_marking())] потребуется примерно [lethal_hits_to_crit_str]."
	if(initial_stamina)
		var/non_lethal_hits_to_crit_str = span_warning("[HITS_TO_CRIT((initial(exam_proj.stamina) * proj_stamine_mult) * pellets)] попадан[declension_ru(HITS_TO_CRIT((initial(exam_proj.stamina) * proj_stamine_mult) * pellets), "ие", "ия", "ий")]")
		readout += "- Для <b>[span_blue("нелетального")]</b> обезвреживания противника боеприпасами [span_warning(get_ammo_marking())] потребуется примерно [non_lethal_hits_to_crit_str]."

	return readout.Join("\n") // Sending over a single string, rather than the whole list

/obj/item/ammo_casing/proc/get_ammo_marking()
	return ammo_marking ? ammo_marking : caliber

/obj/item/ammo_casing/update_name(updates = ALL)
	. = ..()
	if(no_update_names)
		return

	if(BB)
		gender = MALE
		name = "[get_ammo_marking()] cartridge"
		ru_names = string_list(list(
			NOMINATIVE = "патрон [get_ammo_marking()]",
			GENITIVE = "патрона [get_ammo_marking()]",
			DATIVE = "патрону [get_ammo_marking()]",
			ACCUSATIVE = "патрон [get_ammo_marking()]",
			INSTRUMENTAL = "патроном [get_ammo_marking()]",
			PREPOSITIONAL = "патроне [get_ammo_marking()]",
		))
	else
		gender = FEMALE
		name = "[caliber] bullet casing"
		ru_names = string_list(list(
			NOMINATIVE = "гильза [caliber]",
			GENITIVE = "гильзы [caliber]",
			DATIVE = "гильзе [caliber]",
			ACCUSATIVE = "гильзу [caliber]",
			INSTRUMENTAL = "гильзой [caliber]",
			PREPOSITIONAL = "гильзе [caliber]",
		))

/obj/item/ammo_casing/update_desc(updates = ALL)
	. = ..()
	if(no_update_desc)
		return

	if(BB)
		desc = "Заряженный и готовый к использованию патрон [get_ammo_marking()].[extra_info ? " " + extra_info : ""]"
	else
		desc = "Пустая гильза от пули калибра [caliber]." // no extra info because no bullet

/obj/item/ammo_casing/proc/newshot(params) //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, params)
	return

/obj/item/ammo_casing/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!BB)
		qdel(src)
		return TRUE
	return ..()

/obj/item/ammo_casing/attackby(obj/item/item, mob/user, params)
	if(!isammobox(item) || !can_be_box_inserted)
		return ..()
	add_fingerprint(user)
	var/obj/item/ammo_box/box = item
	if(!isturf(loc))
		balloon_alert(user, "не получилось собрать")
		return ATTACK_CHAIN_PROCEED
	if(length(box.stored_ammo) >= box.max_ammo)
		balloon_alert(user, "уже заполнено")
		return ATTACK_CHAIN_PROCEED
	var/boolets = 0
	var/turf/load_loc = loc
	for(var/obj/item/ammo_casing/bullet in loc)
		if(length(box.stored_ammo) >= box.max_ammo)
			break
		if(!bullet.BB)
			continue
		if(!box.can_fast_load)
			playsound(box, box.insert_sound, 50, TRUE)
			if(!do_after(user, box.bullet_load_duration, box, max_interact_count = 1))
				break
			if(bullet.loc != load_loc)
				break
			box.update_appearance(UPDATE_ICON|UPDATE_DESC)
		if(box.give_round(bullet, FALSE))
			boolets++
	if(!boolets)
		balloon_alert(user, "не получилось собрать")
		return ATTACK_CHAIN_PROCEED
	box.update_appearance(UPDATE_ICON|UPDATE_DESC)
	to_chat(user, span_notice("Вы собрали [boolets] гильз[DECL_SEC_MIN(boolets)]. Теперь в [box.declent_ru(GENITIVE)] [length(box.stored_ammo)] гильз[declension_ru(length(box.stored_ammo),"а","ы","")]."))
	if(box.can_fast_load)
		playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, TRUE)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/ammo_casing/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		to_chat(user, span_warning("В гильзе нет пули для нанесения гравировки."))
		return .
	if(initial(BB.name) != BULLET)
		to_chat(user, span_notice("Вы можете гравировать только металлические пули.")) //because inscribing beanbags is silly
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/label_text = tgui_input_text(user, "Нанесите текст на патрон", "Гравировка", "", 20)
	if(isnull(label_text))
		return .
	if(label_text == "")
		to_chat(user, span_notice("Вы соскабливаете гравировку с патрона."))
		BB.name = initial(BB.name)
	else
		to_chat(user, span_notice("Вы наносите \"[label_text]\" на патрон."))
		BB.ru_names = list(
			NOMINATIVE = "пуля \"[label_text]\"",
			GENITIVE = "пули \"[label_text]\"",
			DATIVE = "пуле \"[label_text]\"",
			ACCUSATIVE = "пулю \"[label_text]\"",
			INSTRUMENTAL = "пулей \"[label_text]\"",
			PREPOSITIONAL = "пуле \"[label_text]\"",
		)

/obj/item/ammo_casing/proc/leave_residue(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	if(istype(H) && H.gloves)
		var/obj/item/clothing/G = H.gloves
		G.gunshot_residue = caliber
	else
		H.gunshot_residue = caliber

/obj/item/ammo_casing/proc/after_fire()
	return

// MARK: Caseless
// TODO: port caseless element from TG — https://github.com/tgstation/tgstation/pull/76335
/obj/item/ammo_casing/caseless
	desc = "Безгильзовый патрон."

/obj/item/ammo_casing/caseless/after_fire()
	qdel(src)
