/datum/antagonist/ninja
	name = "Space Ninja"
	job_rank = ROLE_NINJA
	special_role = SPECIAL_ROLE_SPACE_NINJA
	antag_hud_name = "hudninja"
	antag_hud_type = ANTAG_HUD_NINJA
	/// Abilities bicons used for the end game info.
	var/purchased_abilities
	/// If `FALSE` ninja will not get default items.
	var/give_equip = TRUE
	/// If `TRUE` allows ninja to use ranged weapons.
	var/allow_guns = FALSE
	/// If `FALSE` ninja will get random name.
	var/allow_rename = TRUE
	/// Warning message when ninja tries to use ranged weapon.
	var/no_guns_message = "Технологии моего клана - гордость и счастье нашего будущего! Я не буду пользоваться этим мусором!"
	/// If `FALSE` additional minor antags will not be generated. Traitors, changelings and vampires currently.
	var/generate_antags = TRUE
	/// To check if we already generate minor antags.
	var/antags_done = FALSE
	/// Used for different objectives and additional antag generation.
	var/ninja_type = NINJA_TYPE_GENERIC
	/// Minds thats will be minor antags soon.
	var/list/pre_antags = list()
	/// Special rules for antag if it was was created during antag paradise gamemode.
	var/antag_paradise_mode_chosen = FALSE

	/// Quick access links.
	var/mob/living/carbon/human/human_ninja
	var/datum/martial_art/ninja_martial_art/creeping_widow
	var/obj/item/clothing/suit/space/space_ninja/my_suit
	var/obj/item/melee/energy_katana/my_katana
	var/obj/item/stock_parts/cell/cell


/datum/antagonist/ninja/on_gain()
	if(!owner?.current)
		return FALSE

	owner.special_role = special_role
	owner.offstation_role = TRUE
	owner.set_original_mob(owner.current)

	add_owner_to_gamemode()
	apply_innate_effects()

	if(generate_antags || antag_paradise_mode_chosen)
		ninja_type = pick(NINJA_TYPE_PROTECTOR, NINJA_TYPE_HACKER, NINJA_TYPE_KILLER)
		if(generate_antags)
			pick_antags()

	if(give_objectives && !antag_paradise_mode_chosen)
		give_objectives()

	finalize_antag()

	if(!silent)
		greet()
		announce_objectives()

	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))

	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
	return TRUE


/datum/antagonist/ninja/Destroy(force)
	owner.offstation_role = FALSE
	human_ninja = null
	creeping_widow = null
	my_suit = null
	my_katana = null
	cell = null
	purchased_abilities = null
	return ..()


/datum/antagonist/ninja/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
	if(!tested || !ishuman(tested.current))
		log_admin("Failed to make Space Ninja antagonist, owner is not a human!")
		return FALSE

	return TRUE


/datum/antagonist/ninja/add_owner_to_gamemode()
	SSticker.mode.space_ninjas |= owner


/datum/antagonist/ninja/remove_owner_from_gamemode()
	SSticker.mode.space_ninjas -= owner


/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, 'sound/ambience/antag/ninja_greeting.ogg')
	to_chat(owner.current, "Я элитный наёмник в составе могущественного Клана Паука! <font color='red'><B>Космический Ниндзя!</B></font>")
	to_chat(owner.current, "Моё оружие внезапность. Моя броня Тень. Без них, я ничто.")


/datum/antagonist/ninja/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы стали Роботом! И годы ваших тренировок становятся пылью..."))
	else
		to_chat(owner.current, span_userdanger("Вам промыло мозги! Вы больше не Ниндзя!"))


/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction = list(ROLE_NINJA)


/datum/antagonist/ninja/proc/change_species(mob/living/mob_to_change = null) // This should be used to fully to remove robo-limbs & change species for lack of sprites
	human_ninja = ishuman(mob_to_change) ? mob_to_change : null
	if(human_ninja)
		human_ninja.set_species(/datum/species/human)	// only human ninjas for now
		human_ninja.revive()


/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction = list("Station")
	if(user.hud_used)
		user.hud_used.remove_ninja_hud()


/datum/antagonist/ninja/finalize_antag()
	INVOKE_ASYNC(src, PROC_REF(name_ninja))
	if(give_equip)
		equip_ninja()

	if(generate_antags && !antag_paradise_mode_chosen)
		generate_antags()

	if(antag_paradise_mode_chosen)
		// to ensure all antags were properly generated
		addtimer(CALLBACK(src, PROC_REF(finalize_antag_paradise_mode)), 15 SECONDS)


/datum/antagonist/ninja/proc/finalize_antag_paradise_mode()
	give_objectives()
	announce_objectives()
	SEND_SOUND(owner.current, 'sound/ambience/alarm4.ogg')


/datum/antagonist/ninja/proc/name_ninja()
	var/ninja_name_first = pick(GLOB.ninja_titles)
	var/ninja_name_second = pick(GLOB.ninja_names)
	var/newname = "[ninja_name_first] [ninja_name_second]"
	if(allow_rename)
		newname = sanitize(copytext_char(input(human_ninja, "Вы космический Ниндзя, гордый член клана Паука. Как вы хотите себя называть?", "Смена имени", newname) as null|text, 1, MAX_NAME_LEN))

	human_ninja.real_name = newname
	human_ninja.name = newname
	owner.name = newname


/**
 * All the equipment for ninja.
 */
/datum/antagonist/ninja/proc/equip_ninja()
	if(!istype(human_ninja))
		stack_trace("Trying to equip non-human mob with ninja antag datum")

	for(var/obj/item/item in (human_ninja.contents - (human_ninja.bodyparts|human_ninja.internal_organs)))
		human_ninja.drop_item_ground(item, force = TRUE, silent = TRUE)

	human_ninja.equip_to_slot(new /obj/item/clothing/under/ninja, ITEM_SLOT_CLOTH_INNER, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/clothing/glasses/ninja, ITEM_SLOT_EYES, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/clothing/mask/gas/space_ninja, ITEM_SLOT_MASK, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/clothing/shoes/space_ninja, ITEM_SLOT_FEET, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/clothing/gloves/space_ninja, ITEM_SLOT_GLOVES, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/clothing/head/helmet/space/space_ninja, ITEM_SLOT_HEAD, initial = TRUE)
	human_ninja.equip_to_slot(new /obj/item/tank/internals/emergency_oxygen/ninja, ITEM_SLOT_POCKET_RIGHT, initial = TRUE)

	var/obj/item/storage/backpack/ninja/my_backpack = new
	human_ninja.equip_to_slot(my_backpack, ITEM_SLOT_BACK, initial = TRUE)

	var/obj/item/radio/headset/ninja/my_headset = new
	human_ninja.equip_to_slot(my_headset, ITEM_SLOT_EAR_RIGHT, initial = TRUE)

	my_katana = new
	human_ninja.equip_to_slot(my_katana, ITEM_SLOT_BELT, initial = TRUE)

	my_suit = new
	human_ninja.equip_to_slot(my_suit, ITEM_SLOT_CLOTH_OUTER, initial = TRUE)
	my_suit.preferred_clothes_gender = human_ninja.gender
	my_suit.n_headset = my_headset
	my_suit.n_backpack = my_backpack
	my_suit.energyKatana = my_katana
	cell = my_suit.cell


/**
 * HUD creating and updates.
 */
/datum/antagonist/ninja/proc/handle_ninja()
	if(!human_ninja?.hud_used)
		return

	var/datum/hud/hud = human_ninja.hud_used
	if(human_ninja.wear_suit != my_suit)	// No suit no interface
		hud.remove_ninja_hud()
		return

	if(!hud.ninja_energy_display)	// creating new interface if none
		hud.ninja_energy_display = new /atom/movable/screen()
		hud.ninja_energy_display.name = "Заряд батареи"
		hud.ninja_energy_display.icon = 'icons/mob/screen_64x64.dmi'
		hud.ninja_energy_display.maptext_x = 0
		hud.ninja_energy_display.maptext_y = 0
		hud.ninja_energy_display.maptext_width = 64
		hud.ninja_energy_display.screen_loc = "SOUTH :48, CENTER :-16"
		hud.infodisplay += hud.ninja_energy_display
		hud.show_hud(hud.hud_version)
		hud.hidden_inventory_update()

	if(my_suit && cell)	// suit charge level
		var/check_percentage = (cell.maxcharge/100)*20
		var/warning = cell.charge >= check_percentage ? "" : "_warning"
		hud.ninja_energy_display.icon_state = "ninja_energy_display_[my_suit.color_choice][warning]"
		hud.ninja_energy_display.maptext = "<div align='center' valign='middle' style='position:relative;'><font color='#FFFFFF' size='1'>[round(cell.charge)]</font></div>"
		hud.ninja_energy_display.invisibility = my_suit.show_charge_UI ? 0 : INVISIBILITY_ABSTRACT

	// concentration level
	if(!hud.ninja_focus_display && owner.martial_art && istype(owner.martial_art, /datum/martial_art/ninja_martial_art))
		creeping_widow = owner.martial_art
		hud.ninja_focus_display = new /atom/movable/screen()
		hud.ninja_focus_display.name = "Концентрация"
		hud.ninja_focus_display.screen_loc = "EAST:-6,CENTER-2:15"
		hud.infodisplay += hud.ninja_focus_display
		hud.show_hud(hud.hud_version)
		hud.hidden_inventory_update()

	// martial art update
	if(creeping_widow && my_suit)
		hud.ninja_focus_display.icon_state = creeping_widow.has_focus ? "focus_active_[my_suit.color_choice]" : "focus"
		hud.ninja_focus_display.invisibility = my_suit.show_concentration_UI ? 0 : INVISIBILITY_ABSTRACT


/**
 * HUD cleaning proc.
 */
/datum/hud/proc/remove_ninja_hud()
	if(!ninja_energy_display && !ninja_focus_display)
		return
	infodisplay -= ninja_energy_display
	QDEL_NULL(ninja_energy_display)
	infodisplay -= ninja_focus_display
	QDEL_NULL(ninja_focus_display)
	show_hud(hud_version)
	hidden_inventory_update()


/**
 * Stat panel cell charge info.
 */
/datum/antagonist/ninja/proc/get_cell_charge()
	if(!cell)
		return "ERROR!"
	return "[cell.charge]/[cell.maxcharge]"


/**
 * Stat panel katana charge info.
 */
/datum/antagonist/ninja/proc/get_dash_charge()
	if(!my_katana)
		return "ERROR!"
	return "[my_katana.jaunt.current_charges]/[my_katana.jaunt.max_charges]"


/datum/antagonist/ninja/proc/pick_antags()
	if(ninja_type == NINJA_TYPE_GENERIC)
		return

	var/list/possible_antags = list()
	switch(ninja_type)
		if(NINJA_TYPE_PROTECTOR)
			var/datum/game_mode/traitor/traitor_mode = new
			for(var/mob/living/player in GLOB.alive_mob_list)
				if(player.client && player.mind && player.stat != DEAD && ishuman(player) && !player.mind.special_role && \
					!player.mind.offstation_role && (ROLE_TRAITOR in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_TRAITOR) && \
					!jobban_isbanned(player, ROLE_SYNDICATE) && player_old_enough_antag(player.client, ROLE_TRAITOR) && \
					!(player.mind.assigned_role in (traitor_mode.restricted_jobs|traitor_mode.protected_jobs)))

					possible_antags |= player.mind

			qdel(traitor_mode)

		if(NINJA_TYPE_HACKER)
			var/datum/game_mode/vampire/vampire_mode = new
			for(var/mob/living/player in GLOB.alive_mob_list)
				if(player.client && player.mind && player.stat != DEAD && ishuman(player) && !player.mind.special_role && \
					!player.mind.offstation_role && (ROLE_VAMPIRE in player.client.prefs.be_special) && !jobban_isbanned(player, ROLE_VAMPIRE) && \
					!jobban_isbanned(player, ROLE_SYNDICATE) && player_old_enough_antag(player.client, ROLE_VAMPIRE) && \
					!(player.mind.assigned_role in (vampire_mode.restricted_jobs|vampire_mode.protected_jobs)) && \
					!(player.dna.species.name in vampire_mode.protected_species))

					possible_antags |= player.mind

			qdel(vampire_mode)

		if(NINJA_TYPE_KILLER)
			var/datum/game_mode/changeling/changeling_mode = new
			for(var/mob/living/player in GLOB.alive_mob_list)
				if(player.client && player.mind && player.stat != DEAD && ishuman(player) && !player.mind.special_role && \
					!player.mind.offstation_role && (ROLE_CHANGELING in player.client.prefs.be_special) && \
					!jobban_isbanned(player, ROLE_CHANGELING) && !jobban_isbanned(player, ROLE_SYNDICATE) && \
					player_old_enough_antag(player.client, ROLE_CHANGELING) && \
					!(player.mind.assigned_role in (changeling_mode.restricted_jobs|changeling_mode.protected_jobs)) && \
					!(player.dna.species.name in changeling_mode.protected_species))

					possible_antags |= player.mind

			qdel(changeling_mode)

	if(!length(possible_antags))
		return

	var/antag_amt = 0
	var/antag_max = max(1, round(SSticker.mode.num_players_started() / CONFIG_GET(number/traitor_scaling)))
	for(var/datum/mind/antag in shuffle(possible_antags))
		if(antag_amt++ > antag_max)
			break
		pre_antags |= antag


/datum/antagonist/ninja/proc/generate_antags()
	if(antags_done)
		return

	if(!length(pre_antags))
		pick_antags()

	if(!length(pre_antags))	// no players are available for antags
		return

	switch(ninja_type)
		if(NINJA_TYPE_PROTECTOR)
			generate_traitors()
		if(NINJA_TYPE_HACKER)
			generate_vampires()
		if(NINJA_TYPE_KILLER)
			generate_changelings()

	pre_antags.Cut()
	antags_done = TRUE


/datum/antagonist/ninja/proc/generate_traitors()
	var/datum/objective/protect/ninja/protect_objective = locate() in owner.get_all_objectives()

	for(var/datum/mind/traitor in pre_antags)
		var/datum/antagonist/traitor/traitor_datum = new
		traitor_datum.give_objectives = FALSE
		traitor_datum.is_contractor = TRUE
		traitor.add_antag_datum(traitor_datum)

		var/objective_amount = protect_objective ? CONFIG_GET(number/traitor_objectives_amount) - 1 : CONFIG_GET(number/traitor_objectives_amount)

		// all traitors will try to maroon ninja's protect target
		if(protect_objective?.target)
			var/datum/objective/maroon/killer_objective = traitor_datum.add_objective(/datum/objective/maroon, "Prevent from escaping alive or free [protect_objective.target.current.real_name], the [protect_objective.target.assigned_role].", protect_objective.target.current)
			protect_objective.killers_objectives |= killer_objective

		for(var/i in 1 to objective_amount)
			traitor_datum.forge_single_human_objective()

		var/list/all_objectives = traitor.get_all_objectives()
		var/martyr_compatibility = TRUE
		for(var/datum/objective/objective in all_objectives)
			if(!objective.martyr_compatible)
				martyr_compatibility = FALSE
				break

		var/martyr = FALSE
		if(martyr_compatibility && !(locate(/datum/objective/die) in all_objectives) && prob(20))
			martyr = TRUE
			traitor_datum.add_objective(/datum/objective/die)

		if(!martyr && !(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
			traitor_datum.add_objective(/datum/objective/escape)

		traitor_datum.announce_objectives()


/datum/antagonist/ninja/proc/generate_vampires()
	for(var/datum/mind/vampire in pre_antags)
		vampire.add_antag_datum(/datum/antagonist/vampire/new_vampire)


/datum/antagonist/ninja/proc/generate_changelings()
	for(var/datum/mind/changeling in pre_antags)
		changeling.add_antag_datum(/datum/antagonist/changeling)


/datum/antagonist/ninja/proc/make_objectives_generate_antags(chosen_ninja_type, datum/objective/custom_objective)

	ninja_type = chosen_ninja_type
	if(!ninja_type)
		ninja_type = pick(NINJA_TYPE_PROTECTOR, NINJA_TYPE_HACKER, NINJA_TYPE_KILLER)

	// correct order to generate all objectives and antags
	pick_antags()
	give_objectives(custom_objective)
	generate_antags()


/datum/antagonist/ninja/give_objectives(datum/objective/custom_objective)
	switch(ninja_type)
		if(NINJA_TYPE_GENERIC)
			forge_generic_ninja_objectives(custom_objective)
		if(NINJA_TYPE_PROTECTOR)
			forge_protector_ninja_objectives()
		if(NINJA_TYPE_HACKER)
			forge_hacker_ninja_objectives()
		if(NINJA_TYPE_KILLER)
			forge_killer_ninja_objectives()


/datum/antagonist/ninja/proc/forge_generic_ninja_objectives(datum/objective/custom_objective)

	if(custom_objective)
		add_objective(custom_objective)
		return

	if(prob(50))
		// Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		add_objective(/datum/objective/cyborg_hijack)

	switch(pick(1,2))
		if(1)
			// AI Corrupt: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			add_objective(/datum/objective/ai_corrupt)
		if(2)
			// RnD Hack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			add_objective(/datum/objective/research_corrupt)

	if(prob(50))
		var/datum/objective/plant_explosive/bomb_objective = add_objective(/datum/objective/plant_explosive)
		bomb_objective.give_bomb(delayed = 0)

	else
		var/datum/objective/set_up/set_up_objective = add_objective(/datum/objective/set_up)
		if(!set_up_objective.target)
			qdel(set_up_objective)

	if(prob(50))
		add_objective(/datum/objective/get_money)

	else
		add_objective(/datum/objective/find_and_scan)

	if(prob(50))
		for(var/i in 1 to 2)
			var/datum/objective/assassinate/assassinate_objective = add_objective(/datum/objective/assassinate)
			if(!assassinate_objective.target)
				qdel(assassinate_objective)

	else
		for(var/i in 1 to 2)
			var/datum/objective/steal/steal_objective = add_objective(/datum/objective/steal)
			if(!steal_objective.steal_target)
				qdel(steal_objective)

	var/list/all_objectives = owner.get_all_objectives()
	if(!(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
		add_objective(/datum/objective/survive)


/datum/antagonist/ninja/proc/forge_protector_ninja_objectives()

	try_protect_objective()

	if(prob(50))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		add_objective(/datum/objective/cyborg_hijack)

	var/datum/objective/set_up/set_up_objective = add_objective(/datum/objective/set_up)
	if(!set_up_objective.target)
		qdel(set_up_objective)

	for(var/i in 1 to 2)
		var/datum/objective/steal/steal_objective = add_objective(/datum/objective/steal)
		if(!steal_objective.steal_target)
			qdel(steal_objective)

	var/datum/objective/pain_hunter/pain_hunter_objective = add_objective(/datum/objective/pain_hunter)
	if(!pain_hunter_objective.target)
		qdel(pain_hunter_objective)

	var/list/all_objectives = owner.get_all_objectives()
	if(!(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
		add_objective(/datum/objective/survive)


/**
 * Ninja protect. If traitors have been generated they will all hunt for our target.
 */
/datum/antagonist/ninja/proc/try_protect_objective()

	if(!antag_paradise_mode_chosen)
		var/datum/objective/protect/ninja/protect_objective = new
		protect_objective.killers = pre_antags	// chosen antags will be blacklisted
		protect_objective.owner = owner
		protect_objective.find_target(protect_objective.existing_targets_blacklist())
		objectives += protect_objective

		if(!protect_objective.target)
			qdel(protect_objective)

		return

	// this part will only proceed in antag paradise gamemode, long after antags have been generated
	var/list/all_traitors = (SSticker.mode.traitors|SSticker.mode.vampires|SSticker.mode.changelings)
	if(!length(all_traitors))
		return

	var/list/maroon_objectives = list()
	var/list/killers = list()
	for(var/datum/mind/traitor in all_traitors)
		var/datum/objective/maroon/maroon_objective = locate() in traitor.get_all_objectives()
		if(maroon_objective)	// only one maroon objective will be modified
			maroon_objectives |= maroon_objective
			killers |= traitor

	if(!length(maroon_objectives))
		return

	var/datum/objective/protect/ninja/protect_objective = new
	protect_objective.killers = killers	// antags with maroon objectives will be blacklisted
	protect_objective.owner = owner
	protect_objective.find_target(protect_objective.existing_targets_blacklist())
	objectives += protect_objective

	if(!protect_objective.target)
		qdel(protect_objective)
		return

	for(var/datum/objective/maroon/maroon_objective in maroon_objectives)
		maroon_objective.target = protect_objective.target	// swapping target
		maroon_objective.update_explanation()
		maroon_objective.alarm_changes()
		var/list/messages = maroon_objective.owner.prepare_announce_objectives()
		to_chat(maroon_objective.owner.current, chat_box_red(messages.Join("<br>")))


/datum/antagonist/ninja/proc/forge_hacker_ninja_objectives()

	try_blood_collect_objective()

	if(prob(75))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		add_objective(/datum/objective/cyborg_hijack)

	switch(pick(1,2))
		if(1)
			// AI Corrupt: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			add_objective(/datum/objective/ai_corrupt)
		if(2)
			// RnD Hack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
			add_objective(/datum/objective/research_corrupt)

	switch(pick(1,2))
		if(1)
			add_objective(/datum/objective/get_money)

		if(2)
			add_objective(/datum/objective/find_and_scan)

	var/datum/objective/steal/steal_objective = add_objective(/datum/objective/steal)
	if(!steal_objective.steal_target)
		qdel(steal_objective)

	var/datum/objective/assassinate/assassinate_objective = add_objective(/datum/objective/assassinate)
	if(!assassinate_objective.target)
		qdel(assassinate_objective)

	var/list/all_objectives = owner.get_all_objectives()
	if(!(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
		add_objective(/datum/objective/survive)


/**
 * Vampire blood collecting objective.
 */
/datum/antagonist/ninja/proc/try_blood_collect_objective()

	// if its antag paradise gamemode vampires will generate later
	var/vampires_amount = antag_paradise_mode_chosen ? length(SSticker.mode.vampires) : length(pre_antags)

	var/datum/objective/collect_blood/blood_objective = add_objective(/datum/objective/collect_blood)
	if(length(vampires_amount) < blood_objective.samples_to_win)	// no objective if there are fewer antagonists than needed
		qdel(blood_objective)


/datum/antagonist/ninja/proc/forge_killer_ninja_objectives()

	try_vermit_hunt_objective()

	if(prob(50))
		//Cyborg Hijack: Flag set to complete in the DrainAct in ninjaDrainAct.dm
		add_objective(/datum/objective/cyborg_hijack)

	var/datum/objective/plant_explosive/bomb_objective = add_objective(/datum/objective/plant_explosive)
	bomb_objective.give_bomb(delayed = 0)

	add_objective(/datum/objective/find_and_scan)

	for(var/i in 1 to 2)
		var/datum/objective/assassinate/assassinate_objective = add_objective(/datum/objective/assassinate)
		if(!assassinate_objective.target)
			qdel(assassinate_objective)

	var/list/all_objectives = owner.get_all_objectives()
	if(!(locate(/datum/objective/escape) in all_objectives) && !(locate(/datum/objective/survive) in all_objectives))
		add_objective(/datum/objective/survive)


/**
 * Changelings massacre objective.
 */
/datum/antagonist/ninja/proc/try_vermit_hunt_objective()

	// if its antag paradise gamemode changelingss will generate later
	var/changelings_amount = antag_paradise_mode_chosen ? length(SSticker.mode.changelings) : length(pre_antags)

	if(changelings_amount > 1)	// we will not hunt if only one ling is available
		var/datum/objective/vermit_hunt/hunt_changelings = add_objective(/datum/objective/vermit_hunt)
		hunt_changelings.update_objective(round(changelings_amount / 2))


/**
 * Takes any datum `source` and checks it for ninja datum.
 */
/proc/isninja(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/ninja)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/ninja)

