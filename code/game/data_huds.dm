/* Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */

/atom/proc/add_to_all_human_data_huds()
	for(var/datum/atom_hud/data/human/hud in GLOB.huds)
		hud.add_atom_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in GLOB.huds)
		hud.remove_atom_from_hud(src)

/datum/atom_hud/data

/datum/atom_hud/data/human/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

/datum/atom_hud/data/human/medical/basic

/datum/atom_hud/data/human/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H)) return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U)) return 0
	if(U.sensor_mode <= 2) return 0
	return 1

/datum/atom_hud/data/human/medical/basic/add_atom_to_single_mob_hud(mob/M, mob/living/carbon/H)
	if(check_sensors(H) || isobserver(M))
		..()

/datum/atom_hud/data/human/medical/basic/proc/update_suit_sensors(mob/living/carbon/H)
	check_sensors(H) ? add_atom_to_hud(H) : remove_atom_from_hud(H)

/datum/atom_hud/data/human/medical/advanced
	hud_icons = list(HEALTH_HUD, STATUS_HUD, INSURANCE_HUD)

/datum/atom_hud/data/human/security

/datum/atom_hud/data/human/security/basic
	hud_icons = list(ID_HUD)

/datum/atom_hud/data/human/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD, WANTED_HUD)

/datum/atom_hud/data/diagnostic
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_AISHELL_STAT_HUD)

/datum/atom_hud/data/diagnostic/advanced
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_PATH_HUD, DIAG_AISHELL_STAT_HUD)

/datum/atom_hud/data/bot_path
	// This hud exists so the bot can see itself, that's all
	uses_global_hud_category = FALSE
	hud_icons = list(DIAG_PATH_HUD)

/datum/atom_hud/abductor
	hud_icons = list(GLAND_HUD)

/datum/atom_hud/data/hydroponic
	hud_icons = list(PLANT_NUTRIENT_HUD, PLANT_WATER_HUD, PLANT_STATUS_HUD, PLANT_HEALTH_HUD, PLANT_TOXIN_HUD, PLANT_PEST_HUD, PLANT_WEED_HUD)

/datum/atom_hud/thoughts
	hud_icons = list(THOUGHT_HUD)

/datum/atom_hud/kidan_pheromones
	hud_icons = list(KIDAN_PHEROMONES_HUD)

/datum/atom_hud/pacifism
	hud_icons = list(PACIFISM_HUD)

/datum/atom_hud/diablerie_aura
	hud_icons = list(DIABLERIE_AURA_HUD)

/* MED/SEC/DIAG HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
	Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

/// Whether the carbon mob is currently in crit.
// Even though "crit" does not realistically happen for non-humans..
/mob/living/carbon/proc/is_in_crit()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(istype(D, /datum/disease/critical))
			return TRUE
	return FALSE

/mob/living/carbon/human/is_in_crit()
	if(..())
		return TRUE
	if(undergoing_cardiac_arrest())
		return TRUE
	return FALSE

/// Whether a virus worthy displaying on the HUD is present.
/mob/living/proc/has_virus()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(!D.discovered) // Early-stage viruses should not show up on med HUD (though health analywers can still pick them up)
			continue
		if(!(D.visibility_flags & HIDDEN_HUD))
			return TRUE
	return FALSE

/mob/living/proc/has_bleeding()
	return FALSE

/mob/living/proc/has_heavy_bleeding()
	return FALSE

/// Called when a carbon changes virus
/mob/living/proc/check_virus()
	var/threat
	var/severity

	for(var/datum/disease/virus as anything in diseases)
		var/datum/virus_severity/virus_severity = GLOB.viruses_severity[virus.severity]

		if(virus.visibility_flags & HIDDEN_HUD)
			continue

		if(threat && virus_severity.severity <= threat) //a buffing virus gets an icon
			continue

		threat = virus_severity.severity
		severity = virus_severity.name

	return severity

/// Helper for getting the appropriate health status
/proc/RoundHealth(mob/living/M)
	if(M.stat == DEAD || HAS_TRAIT(M, TRAIT_FAKEDEATH))
		return "health-100-dead" //what's our health? it doesn't matter, we're dead, or faking

	var/maxi_health = M.maxHealth
	if(iscarbon(M) && M.health < 0)
		maxi_health = 100 //so crit shows up right for aliens and other high-health carbon mobs; noncarbons don't have crit.
	var/resulthealth = (M.health / maxi_health) * 100

	switch(resulthealth)
		if(100 to INFINITY)
			return "health100"
		if(95 to 100)
			return "health95"
		if(90 to 95)
			return "health90"
		if(80 to 90)
			return "health80"
		if(70 to 80)
			return "health70"
		if(60 to 70)
			return "health60"
		if(50 to 60)
			return "health50"
		if(40 to 50)
			return "health40"
		if(30 to 40)
			return "health30"
		if(20 to 30)
			return "health20"
		if(10 to 20)
			return "health10"
		if(0 to 10)
			return "health0"
		if(-10 to 0)
			return "health-0" //The health bar will turn a brilliant red and flash as usual, but deducted health will be black.
		if(-20 to -10)
			return "health-10"
		if(-30 to -20)
			return "health-20"
		if(-40 to -30)
			return "health-30"
		if(-50 to -40)
			return "health-40"
		if(-60 to -50)
			return "health-50"
		if(-70 to -60)
			return "health-60"
		if(-80 to -70)
			return "health-70"
		if(-90 to -80)
			return "health-80"
		if(-100 to -90)
			return "health-90"
		else
			return "health-100" //past this point, you're just in trouble

///HOOKS

/// Called when a human changes suit sensors
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/human/medical/basic/B = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)


/// Called when a living mob changes health
/mob/living/proc/med_hud_set_health()
	set_hud_image_state(ismachineperson(src) ? DIAG_HUD : HEALTH_HUD, "hud[RoundHealth(src)]")

/// Called when a carbon changes stat, virus or XENO_HOST
/mob/proc/med_hud_set_status()
	return

/mob/living/med_hud_set_status()
	if(stat == DEAD)
		set_hud_image_state(STATUS_HUD, STATUS_HUD_DEAD)
	else if(has_virus())
		med_hud_set_virus_threat()
	else
		set_hud_image_state(STATUS_HUD, STATUS_HUD_HEALTHY)

/mob/living/carbon/med_hud_set_status()
	if(ismachineperson(src))
		if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
			set_hud_image_state(DIAG_STAT_HUD, "kpb_dead")

		else if(health < 0)
			set_hud_image_state(DIAG_STAT_HUD, "kpb_alert")

		else if(nutrition < NUTRITION_LEVEL_STARVING)
			set_hud_image_state(DIAG_STAT_HUD, "kpb_low_power")

		else
			set_hud_image_state(DIAG_STAT_HUD, "kpb_nominal")

		return

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	// To the right of health bar
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		var/can_reenter = ghost_can_reenter() && !suiciding && mind
		var/revivable = timeofdeath && (round(world.time - timeofdeath) < DEFIB_TIME_LIMIT)

		if(revivable && can_reenter)
			set_hud_image_state(STATUS_HUD, STATUS_HUD_FLATLINE)
		else
			if(can_reenter)
				set_hud_image_state(STATUS_HUD, STATUS_HUD_DEAD)
			else
				set_hud_image_state(STATUS_HUD, STATUS_HUD_DNR)

	else if(HAS_TRAIT(src, TRAIT_XENO_HOST))
		set_hud_image_state(STATUS_HUD, STATUS_HUD_XENO)
	else if(HAS_TRAIT(src, TRAIT_LEGION_TUMOUR))
		set_hud_image_state(STATUS_HUD, STATUS_HUD_TUMOUR)
	else if(B?.controlling && !B.sneaking)
		set_hud_image_state(STATUS_HUD, STATUS_HUD_BRAINWORM)
	else if(is_in_crit())
		set_hud_image_state(STATUS_HUD, STATUS_HUD_DEFIB)
	else if(has_heavy_bleeding())
		set_hud_image_state(STATUS_HUD, STATUS_HUD_RAPID_BLEEDING)
	else if(has_bleeding())
		set_hud_image_state(STATUS_HUD, STATUS_HUD_BLEEDING)
	else if(has_virus())
		med_hud_set_virus_threat()
	else
		set_hud_image_state(STATUS_HUD, STATUS_HUD_HEALTHY)

/mob/living/carbon/human/proc/med_hud_insurance_set_overlay()
	var/datum/money_account/account = null
	var/obj/item/card/id/temp_id = null
	set_hud_image_inactive(INSURANCE_HUD)

	if(!wear_id)
		if((wear_mask && wear_mask.flags_inv & HIDENAME) || (head && head.flags_inv & HIDENAME))
			return
	else
		temp_id = wear_id.GetID()

	if(!temp_id)
		if(dna.real_name == get_visible_name(add_id_name = FALSE))
			account = get_insurance_account_DNA(src)
	else
		account = get_money_account(temp_id.associated_account_number)

	if(account)
		set_hud_image_state(INSURANCE_HUD, "[STATUS_HUD_HEALTHY]_[account.insurance_type]")
		set_hud_image_active(INSURANCE_HUD)


/mob/living/carbon/human/proc/update_hud_set()
	sec_hud_set_ID()
	med_hud_insurance_set_overlay()

/mob/living/proc/get_desc_for_medical_status(icon_state)
	var/static/list/icon_states = list(
			STATUS_HUD_FLATLINE = "Отсутствует сердцебиение. Требуется немедленная дефибрилляция.",
			STATUS_HUD_DEAD = "Пациент мертв. Возвращение возможно только через клонирование или иное вмешательство.",
			STATUS_HUD_DNR ="Пациент отказался от реанимации или активность мозга не обнаружена.",
			STATUS_HUD_XENO = "Обнаружена инопланетная форма жизни в грудной клетке. Требуется срочное хирургическое удаление!",
			STATUS_HUD_TUMOUR = "Обнаружена опухоль. Требуется срочное хирургическое удаление!",
			STATUS_HUD_BRAINWORM = "Обнаружена аномальная активность в мозге. Возможно наличие паразита или иного воздействия.",
			STATUS_HUD_DEFIB = "Критическое состояние! Пациент близок к смерти. Требуется немедленная помощь для стабилизации!",
			STATUS_HUD_RAPID_BLEEDING = "Пациент интенсивно истекает кровью.",
			STATUS_HUD_BLEEDING = "Пациент истекает кровью.",
			STATUS_HUD_ILL = "Обнаружены признаки инфекции или интоксикации. Требуется применение лекарства или диагностика причины интоксикации.",
			STATUS_HUD_HEALTHY = "Серьезных проблем со здоровьем пациента не обнаружено."
		)
	if(!icon_state)
		return "ОШИБКА. Не удалось обнаружить статус пациента."

	var/desc_medical_status = icon_states[icon_state]

	if(isnull(desc_medical_status))
		return "ОШИБКА. Неизвестное состояние пациента."

	return desc_medical_status


/mob/living/proc/med_hud_set_virus_threat()
	var/virus_threat = check_virus()
	if(!virus_threat)
		set_hud_image_state(STATUS_HUD, "hudhealthy")
		return TRUE

	var/datum/virus_severity/severity = GLOB.viruses_severity[virus_threat]
	set_hud_image_state(STATUS_HUD, severity.hud_state)

/***********************************************
	Security HUDs! Basic mode shows only the job.
************************************************/

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	if(wear_id)
		set_hud_image_state(ID_HUD, "hud[ckey(wear_id.GetJobName())]")
	else
		set_hud_image_state(ID_HUD, "hudunknown")
	sec_hud_set_security_status()

/mob/living/carbon/human/proc/sec_hud_set_implants()
	for(var/hud_type in list(IMPTRACK_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD))
		set_hud_image_inactive(hud_type)

	for(var/obj/item/implant/current_implant in src)
		if(!current_implant.implanted)
			return

		if(istype(current_implant,/obj/item/implant/tracking))
			set_hud_image_state(IMPTRACK_HUD, "hud_imp_tracking")
			set_hud_image_active(IMPTRACK_HUD)

		else if(HAS_TRAIT(src, TRAIT_MINDSHIELD_HUD))
			set_hud_image_state(IMPMINDSHIELD_HUD, "hud_imp_loyal")
			set_hud_image_active(IMPMINDSHIELD_HUD)

		else if(istype(current_implant,/obj/item/implant/chem))
			set_hud_image_state(IMPCHEM_HUD, "hud_imp_chem")
			set_hud_image_active(IMPCHEM_HUD)

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	if(!SSticker)
		return //wait till the game starts or the monkeys runtime....

	var/perpname = get_visible_name(add_id_name = FALSE) //gets the name of the perp, works if they have an id or if their face is uncovered

	if(!perpname)
		return

	var/datum/data/record/target = find_record("name", perpname, GLOB.data_core.security)

	if(!target || target.fields["criminal"] == SEC_RECORD_STATUS_NONE)
		set_hud_image_inactive(WANTED_HUD)
		return

	switch(target.fields["criminal"])
		if(SEC_RECORD_STATUS_EXECUTE)
			set_hud_image_state(WANTED_HUD, "hudexecute")

		if(SEC_RECORD_STATUS_ARREST)
			set_hud_image_state(WANTED_HUD, "hudwanted")

		if(SEC_RECORD_STATUS_SEARCH)
			set_hud_image_state(WANTED_HUD, "hudsearch")

		if(SEC_RECORD_STATUS_MONITOR)
			set_hud_image_state(WANTED_HUD, "hudmonitor")

		if(SEC_RECORD_STATUS_DEMOTE)
			set_hud_image_state(WANTED_HUD, "huddemote")

		if(SEC_RECORD_STATUS_INCARCERATED)
			set_hud_image_state(WANTED_HUD, "hudprisoner")

		if(SEC_RECORD_STATUS_PAROLLED)
			set_hud_image_state(WANTED_HUD, "hudparolled")

		if(SEC_RECORD_STATUS_RELEASED)
			set_hud_image_state(WANTED_HUD, "hudreleased")

	set_hud_image_active(WANTED_HUD)

/***********************************************
	Diagnostic HUDs!
************************************************/

//For Diag health and cell bars!
/proc/RoundDiagBar(value)
	switch(value * 100)
		if(95 to INFINITY)
			return "max"
		if(80 to 100)
			return "good"
		if(60 to 80)
			return "high"
		if(40 to 60)
			return "med"
		if(20 to 40)
			return "low"
		if(1 to 20)
			return "crit"
		else
			return "dead"

//Sillycone hooks
/mob/living/silicon/proc/diag_hud_set_health()
	if(stat == DEAD)
		set_hud_image_state(DIAG_HUD, "huddiagdead")
	else
		set_hud_image_state(DIAG_HUD, "huddiag[RoundDiagBar(health/maxHealth)]")

/mob/living/silicon/proc/diag_hud_set_status()
	switch(stat)
		if(CONSCIOUS)
			set_hud_image_state(DIAG_STAT_HUD, "hudstat")
		if(UNCONSCIOUS)
			set_hud_image_state(DIAG_STAT_HUD, "hudoffline")
		else
			set_hud_image_state(DIAG_STAT_HUD, "huddead2")

//Borgie battery tracking!
/mob/living/silicon/robot/proc/diag_hud_set_borgcell()
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		set_hud_image_state(DIAG_BATT_HUD, "hudbatt[RoundDiagBar(chargelvl)]")
	else
		set_hud_image_state(DIAG_BATT_HUD, "hudnobatt")

/*~~~~~~~~~~~~~~~~~~~~
	BIG STOMPY MECHS
~~~~~~~~~~~~~~~~~~~~~*/
/obj/mecha/proc/diag_hud_set_mechhealth()
	var/pixel_y = get_cached_height() - ICON_SIZE_Y
	set_hud_image_state(DIAG_MECH_HUD, "huddiag[RoundDiagBar(obj_integrity/max_integrity)]", y_offset = pixel_y)

/obj/mecha/proc/diag_hud_set_mechcell()
	if(cell)
		var/chargelvl = cell.charge/cell.maxcharge
		set_hud_image_state(DIAG_BATT_HUD, "hudbatt[RoundDiagBar(chargelvl)]")
	else
		set_hud_image_state(DIAG_BATT_HUD, "hudnobatt")

/obj/mecha/proc/diag_hud_set_mechstat()
	if(!internal_damage)
		set_hud_image_inactive(DIAG_STAT_HUD)
		return

	set_hud_image_state(DIAG_STAT_HUD, "hudwarn")
	set_hud_image_active(DIAG_STAT_HUD)

/// Shows tracking beacons on the mech
/obj/mecha/proc/diag_hud_set_mechtracking()
	var/new_icon_state //This var exists so that the holder's icon state is set only once in the event of multiple mech beacons.
	for(var/obj/item/mecha_parts/mecha_tracking/tracker in trackers)
		if(tracker.ai_beacon) //Beacon with AI uplink
			new_icon_state = "hudtrackingai"
			break //Immediately terminate upon finding an AI beacon to ensure it is always shown over the normal one, as mechs can have several trackers.
		else
			new_icon_state = "hudtracking"
	set_hud_image_state(DIAG_TRACK_HUD, new_icon_state)

/*~~~~~~~~~
	Bots!
~~~~~~~~~~*/
/mob/living/simple_animal/bot/proc/diag_hud_set_bothealth()
	if(stat == DEAD)
		set_hud_image_state(DIAG_HUD, "huddiagdead")
	else
		set_hud_image_state(DIAG_HUD, "huddiag[RoundDiagBar(health/maxHealth)]")

/mob/living/simple_animal/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	if(on)
		set_hud_image_state(DIAG_STAT_HUD, "hudstat")
	else if(stat) //Generally EMP causes this
		set_hud_image_state(DIAG_STAT_HUD, "hudoffline")
	else //Bot is off
		set_hud_image_state(DIAG_STAT_HUD, "huddead2")

/mob/living/simple_animal/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	if(client) //If the bot is player controlled, it will not be following mode logic!
		set_hud_image_state(DIAG_BOT_HUD, "hudsentient")
		set_hud_image_active(DIAG_BOT_HUD)
		return

	var/has_status_entry = TRUE
	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			set_hud_image_state(DIAG_BOT_HUD, "hudcalled")
		if(BOT_CLEANING, BOT_HEALING) //Cleanbot cleaning, repairbot fixing, or Medibot Healing
			set_hud_image_state(DIAG_BOT_HUD, "hudworking")
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			set_hud_image_state(DIAG_BOT_HUD, "hudpatrol")
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT) //STOP RIGHT THERE, CRIMINAL SCUM!
			set_hud_image_state(DIAG_BOT_HUD, "hudalert")
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			set_hud_image_state(DIAG_BOT_HUD, "hudmove")
		else
			set_hud_image_state(DIAG_BOT_HUD, "")
			has_status_entry = FALSE

	if(has_status_entry)
		set_hud_image_active(DIAG_BOT_HUD)
		return

	set_hud_image_inactive(DIAG_BOT_HUD)

/*~~~~~~~~~~~~~~
	PLANT HUD
~~~~~~~~~~~~~~~*/
/proc/RoundPlantBar(value)
	switch(value * 100)
		if(1 to 10)
			return "10"
		if(10 to 20)
			return "20"
		if(20 to 30)
			return "30"
		if(30 to 40)
			return "40"
		if(40 to 50)
			return "50"
		if(50 to 60)
			return "60"
		if(60 to 70)
			return "70"
		if(70 to 80)
			return "80"
		if(80 to 90)
			return "90"
		if(90 to INFINITY)
			return "max"
		else
			return "zero"

/obj/machinery/hydroponics/proc/plant_hud_set_nutrient()
	set_hud_image_state(PLANT_NUTRIENT_HUD, "hudnutrient[RoundPlantBar(nutrilevel/maxnutri)]")

/obj/machinery/hydroponics/proc/plant_hud_set_water()
	set_hud_image_state(PLANT_WATER_HUD, "hudwater[RoundPlantBar(waterlevel/maxwater)]")

/obj/machinery/hydroponics/proc/plant_hud_set_status()
	if(!myseed)
		set_hud_image_state(PLANT_STATUS_HUD, "")
		set_hud_image_inactive(PLANT_STATUS_HUD)
		return
	if(harvest)
		set_hud_image_state(PLANT_STATUS_HUD, "hudharvest")
		return
	if(dead)
		set_hud_image_state(PLANT_STATUS_HUD, "huddead")
		return
	set_hud_image_state(PLANT_STATUS_HUD, "")
	set_hud_image_active(PLANT_STATUS_HUD)

/obj/machinery/hydroponics/proc/plant_hud_set_health()
	if(!myseed)
		set_hud_image_state(PLANT_HEALTH_HUD, "")
		set_hud_image_inactive(PLANT_HEALTH_HUD)
		return
	set_hud_image_state(PLANT_HEALTH_HUD, "hudplanthealth[RoundPlantBar(plant_health/myseed.endurance)]")
	set_hud_image_active(PLANT_HEALTH_HUD)

/obj/machinery/hydroponics/proc/plant_hud_set_toxin()
	if(toxic < 10)	// You don't want to see these icons if the value is small
		set_hud_image_state(PLANT_TOXIN_HUD, "")
		set_hud_image_inactive(PLANT_TOXIN_HUD)
		return
	set_hud_image_state(PLANT_TOXIN_HUD, "hudtoxin[RoundPlantBar(toxic/100)]")
	set_hud_image_active(PLANT_TOXIN_HUD)

/obj/machinery/hydroponics/proc/plant_hud_set_pest()
	if(pestlevel < 1)	// You don't want to see these icons if the value is small
		set_hud_image_state(PLANT_PEST_HUD, "")
		set_hud_image_inactive(PLANT_PEST_HUD)
		return
	set_hud_image_state(PLANT_PEST_HUD, "hudpest[RoundPlantBar(pestlevel/10)]")
	set_hud_image_active(PLANT_PEST_HUD)

/obj/machinery/hydroponics/proc/plant_hud_set_weed()
	if(weedlevel < 1)	// You don't want to see these icons if the value is small
		set_hud_image_state(PLANT_WEED_HUD, "")
		set_hud_image_inactive(PLANT_WEED_HUD)
		return
	set_hud_image_state(PLANT_WEED_HUD, "hudweed[RoundPlantBar(weedlevel/10)]")
	set_hud_image_active(PLANT_WEED_HUD)

/*~~~~~~~~~~~~~~~~~~
	TELEPATHY HUD
~~~~~~~~~~~~~~~~~~*/

/mob/living/proc/thoughts_hud_set(thoughts, say_test)
	if(!src)
		return

	if(!thoughts || (client?.prefs.toggles & PREFTOGGLE_SHOW_TYPING))
		set_hud_image_state(THOUGHT_HUD, "")
		set_hud_image_inactive(THOUGHT_HUD)
	else
		if(istext(say_test))
			set_hud_image_state(THOUGHT_HUD, "hudthoughts-[say_test]")
			addtimer(CALLBACK(src, PROC_REF(thoughts_hud_set), FALSE), 3 SECONDS)

		else if(!typing)
			set_hud_image_state(THOUGHT_HUD, "hudthoughtstyping")
			typing = TRUE
		set_hud_image_active(THOUGHT_HUD)

/datum/atom_hud/thoughts/proc/manage_hud(mob/user, perception)
	if(!user)
		return
	user.thoughtsHUD += perception
	if(user.thoughtsHUD && !(user in hud_atoms_all_z_levels))
		show_to(user)
		add_atom_to_hud(user)
	else if(!user.thoughtsHUD && (user in hud_atoms_all_z_levels))
		hide_from(user)
		remove_atom_from_hud(user)

/*~~~~~~~~~~~~
	Airlocks!
~~~~~~~~~~~~~*/
/obj/machinery/door/airlock/proc/diag_hud_set_electrified()
	if(!electrified_until)
		set_hud_image_inactive(DIAG_AIRLOCK_HUD)
		return

	set_hud_image_state(DIAG_AIRLOCK_HUD, "electrified")
	set_hud_image_active(DIAG_AIRLOCK_HUD)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	I'll just put this somewhere near the end...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/// Helper function to add a "comment" to a data record. Used for medical or security records.
/mob/living/carbon/human/proc/add_comment(mob/commenter, comment_kind, comment_text)
	var/perpname = get_visible_name(add_id_name = FALSE) //gets the name of the perp, works if they have an id or if their face is uncovered
	if(!perpname)
		return
	var/datum/data/record/target
	switch(comment_kind)
		if("security")
			target = find_record("name", perpname, GLOB.data_core.security)
		if("medical")
			target = find_record("name", perpname, GLOB.data_core.medical)
	if(!target)
		return

	var/commenter_display = "Something(???)"
	if(ishuman(commenter))
		var/mob/living/carbon/human/U = commenter
		commenter_display = "[U.get_authentification_name()] ([U.get_assignment()])"
	else if(isrobot(commenter))
		var/mob/living/silicon/robot/U = commenter
		commenter_display = "[U.name] ([U.modtype?.name] [U.braintype])"
	else if(isAI(commenter))
		var/mob/living/silicon/ai/U = commenter
		commenter_display = "[U.name] (artificial intelligence)"
	comment_text = "Made by [commenter_display] on [GLOB.current_date_string] [station_time_timestamp()]:<br>[comment_text]"

	if(!target.fields["comments"])
		target.fields["comments"] = list()
	target.fields["comments"] += list(comment_text)

/atom/proc/get_visual_width()
	var/width = get_cached_width()
	var/height = get_cached_height()
	var/scale_list = list(
		width * transform.a + height * transform.b + transform.c,
		width * transform.a + transform.c,
		height * transform.b + transform.c,
		transform.c
	)
	return max(scale_list) - min(scale_list)

/atom/proc/get_visual_height()
	var/width = get_cached_width()
	var/height = get_cached_height()
	var/scale_list = list(
		width * transform.d + height * transform.e + transform.f,
		width * transform.d + transform.f,
		height * transform.e + transform.f,
		transform.f
	)
	return max(scale_list) - min(scale_list)


/atom/proc/set_hud_image_state(hud_type, hud_state, x_offset = 0, y_offset = 0)
	if(!hud_list) // Still initializing
		return

	var/image/holder = hud_list[hud_type]

	if(!holder)
		return

	if(!istype(holder)) // Can contain lists for HUD_LIST_LIST hinted HUDs, if someone fucks up and passes this here we wanna know about it
		CRASH("[src] ([type]) had a HUD_LIST_LIST hud_type [hud_type] passed into set_hud_image_state!")

	holder.icon_state = hud_state

	if(!x_offset && !y_offset)
		return

	holder.pixel_w += x_offset
	holder.pixel_z += y_offset

/datum/atom_hud/data/pressure
	hud_icons = list(PRESSURE_HUD)

/// Pressure hud is special, because it doesn't use hudatoms. SSair manages its images, so tell SSair to add the initial set.
/datum/atom_hud/data/pressure/show_to(mob/new_viewer)
	. = ..()
	SSair.add_pressure_hud(new_viewer)

