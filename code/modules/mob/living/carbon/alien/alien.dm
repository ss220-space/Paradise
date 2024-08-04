#define ALIEN_BURN_MOD 1.25
#define ALIEN_BRUTE_MOD 0.75

/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	speak_emote = list("hisses")
	tts_seed = "Ladyvashj"
	bubble_icon = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER
	dna = null
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALIEN

	var/nightvision_enabled = FALSE
	nightvision = 4

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = FALSE
	var/move_delay_add = 0 // movement delay to add
	var/caste_movement_delay = 0

	status_flags = CANPARALYSE|CANPUSH

	var/attack_damage = 20
	var/armour_penetration = 20
	var/disarm_stamina_damage = 20
	var/obj_damage = 60
	var/devour_time = 3 SECONDS
	var/environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	var/time_to_open_doors = 5 SECONDS

	var/large = FALSE
	var/heat_protection = 0.5
	var/leaping = FALSE
	dirslash_enabled = TRUE

	var/can_evolve = FALSE
	var/evolution_points = 0
	var/max_evolution_points = 200

	/// See [/proc/genderize_decode] for more info.
	var/death_message = "изда%(ет,ют)% тихий гортанный звук, зелёная кровь пузырится из %(его,её,его,их)% пасти..."
	var/death_sound = 'sound/voice/hiss6.ogg'

	var/datum/action/innate/alien_nightvision_toggle/night_vision_action
	var/static/praetorian_count = 0
	var/static/queen_count = 0
	var/static/queen_maximum = 0


/mob/living/carbon/alien/New()
	..()
	create_reagents(1000)
	add_verb(src, /mob/living/verb/mob_sleep)
	night_vision_action = new
	night_vision_action.Grant(src)

	for(var/organ_path in get_caste_organs())
		new organ_path(src)

	if(caste_movement_delay)
		update_alien_speed()


/mob/living/carbon/alien/Destroy()
	if(night_vision_action)
		night_vision_action.Remove(src)
		night_vision_action = null
	return ..()


/**
 * Returns the list of type paths of the organs that we need to insert into this particular xeno upon its creation
 */
/mob/living/carbon/alien/proc/get_caste_organs()
	RETURN_TYPE(/list/obj/item/organ/internal)
	return list(
		/obj/item/organ/internal/brain/xeno,
		/obj/item/organ/internal/xenos/hivenode,
		/obj/item/organ/internal/ears
	)


/mob/living/carbon/alien/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Intent:", "[a_intent]")
	status_tab_data[++status_tab_data.len] = list("Move Mode:", "[m_intent]")
	if(can_evolve)
		status_tab_data[++status_tab_data.len] = list("Evolution progress: [evolution_points]/[max_evolution_points]")


/mob/living/carbon/alien/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages[LANGUAGE_XENOS]

/mob/living/carbon/alien/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "hisses"
	var/ending = copytext(message, length(message))

	if(speaking && (speaking.name != "Galactic Common")) //this is so adminbooze xenos speaking common have their custom verbs,
		verb = speaking.get_spoken_verb(ending)          //and use normal verbs for their own languages and non-common languages
	else
		if(ending=="!")
			verb = "roars"
		else if(ending=="?")
			verb = "hisses curiously"
	return verb


/mob/living/carbon/alien/adjustToxLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return STATUS_UPDATE_NONE


/mob/living/carbon/alien/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()

	switch(damagetype)
		if(BRUTE)
			. *= ALIEN_BRUTE_MOD
		if(BURN)
			. *= ALIEN_BURN_MOD


/mob/living/carbon/alien/check_eye_prot()
	return FLASH_PROTECTION_WELDER

/mob/living/carbon/alien/handle_environment(var/datum/gas_mixture/environment)

	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]")

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				adjust_bodytemperature((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR))
		else
			adjust_bodytemperature(1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR))
		//	bodytemperature -= max((loc_temp - bodytemperature / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 360.15)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")


/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation


/mob/living/carbon/alien/Weaken(amount, ignore_canweaken)
	. = ..()
	if(. && check_incapacitating_immunity(CANWEAKEN, ignore_canweaken) && amount && !large)
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 5), 10)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/alien_stun_delay, multiplicative_slowdown = move_delay_add)


/mob/living/carbon/alien/SetWeakened(amount, ignore_canweaken)
	. = ..()
	if(. && check_incapacitating_immunity(CANWEAKEN, ignore_canweaken) && amount && !large)
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 5), 10)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/alien_stun_delay, multiplicative_slowdown = move_delay_add)
	else if(amount == 0)
		move_delay_add = 0
		remove_movespeed_modifier(/datum/movespeed_modifier/alien_stun_delay)


/mob/living/carbon/alien/update_stamina()
	return


/mob/living/carbon/alien/lying_angle_on_movement(direct)
	return


/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()


/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()


/mob/living/carbon/alien/proc/update_alien_speed()
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/alien_speed, multiplicative_slowdown = caste_movement_delay)


/mob/living/carbon/alien/getDNA()
	return null

/mob/living/carbon/alien/setDNA()
	return

/mob/living/carbon/alien/verb/nightvisiontoggle()
	set name = "Toggle Night Vision"

	if(!nightvision_enabled)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		nightvision = 8
		nightvision_enabled = TRUE
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
	else if(nightvision_enabled)
		lighting_alpha = initial(lighting_alpha)
		nightvision_enabled = FALSE
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"

	update_sight()
	if(is_ventcrawling(src))
		update_pipe_vision()


/mob/living/carbon/alien/assess_threat(var/mob/living/simple_animal/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0

	//Securitrons can't identify aliens
	if(!lasercolor && judgebot.idcheck)
		threatcount += 4

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/red)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/red)))
				threatcount += 4

		if(lasercolor == "r")
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/blue)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/blue)))
				threatcount += 4

		return threatcount

	//Check for weapons
	if(judgebot.weaponscheck)
		if(judgebot.check_for_weapons(l_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(r_hand))
			threatcount += 4

	//Mindshield implants imply trustworthyness
	if(ismindshielded(src))
		threatcount -= 1

	return threatcount

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if(client)
		for(var/mob/living/C in GLOB.mob_list)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				var/obj/item/organ/internal/body_egg/alien_embryo/A = C.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(client)
		for(var/image/I in client.images)
			if(dd_hasprefix_case(I.icon_state, "infected"))
				qdel(I)
	return


/mob/living/carbon/proc/get_plasma()
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return FALSE

	return vessel.stored_plasma


/**
 * Adjust_alien_plasma just requires the plasma amount, so admins can easily varedit it and stuff.
 * Updates the spell's actions on use as well, so they know when they can or can't use their powers.
 */
/mob/living/carbon/proc/adjust_alien_plasma(amount)
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return
	vessel.stored_plasma = clamp(vessel.stored_plasma + amount, 0, vessel.max_plasma)
	for(var/datum/action/spell_action/action in actions)
		action.UpdateButtonIcon()


/**
 * Although this is on the carbon level, we only want this proc'ing for aliens that do have this hud.
 * Only humanoid aliens do at the moment, so we have a check and carry the owner just to make sure.
 */
/mob/living/carbon/proc/update_plasma_display(mob/owner, update_buttons = FALSE)
	if(update_buttons)
		for(var/datum/action/spell_action/action in actions)
			action.UpdateButtonIcon()

	if(!hud_used || !isalien(owner)) //clientless aliens or non aliens
		return

	hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font face='Small Fonts' color='magenta'>[get_plasma()]</font></div>"
	hud_used.alien_plasma_display.maptext_x = -3


/mob/living/carbon/alien/larva/update_plasma_display(mob/owner, update_buttons = FALSE)
	return


/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick("xltrails_1", "xltrails_2")
	else
		return pick("xttrails_1", "xttrails_2")

/mob/living/carbon/alien/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	set_sight(SEE_MOBS)
	if(nightvision_enabled)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	for(var/obj/item/organ/internal/cyberimp/eyes/cyber_eyes in internal_organs)
		add_sight(cyber_eyes.vision_flags)
		if(cyber_eyes.see_in_dark)
			nightvision = max(nightvision, cyber_eyes.see_in_dark)
		if(cyber_eyes.see_invisible)
			set_invis_see(min(see_invisible, cyber_eyes.see_invisible))
		if(!isnull(cyber_eyes.lighting_alpha))
			lighting_alpha = min(lighting_alpha, cyber_eyes.lighting_alpha)

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

#undef ALIEN_BURN_MOD
#undef ALIEN_BRUTE_MOD
