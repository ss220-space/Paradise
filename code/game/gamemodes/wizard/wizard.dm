/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1

	var/finished = 0
	var/but_wait_theres_more = 0

	var/required_num_players_for_apprentice = 25	//Each additional number of players above the minimum, a new apprentice is added

	var/list/datum/mind/pre_wizards = list()
	var/list/datum/mind/pre_apprentices = list()

/datum/game_mode/wizard/announce()
	to_chat(world, "<b>The current game mode is - Wizard!</b>")
	to_chat(world, "<b>There is a <font color='red'>SPACE WIZARD</font> on the station. You can't let him achieve his objective!</b>")

/datum/game_mode/wizard/can_start()
	if(!..())
		return FALSE
	if(!length(GLOB.wizardstart))
		stack_trace("A starting location for wizard could not be found, please report this bug!")
		return FALSE
	var/list/datum/mind/possible_wizards = get_players_for_role(ROLE_WIZARD)
	if(!length(possible_wizards))
		return FALSE
	var/datum/mind/wizard = pick_n_take(possible_wizards)

	pre_wizards += wizard
	var/playerC = num_players()
	if(playerC >= required_players)
		for(var/i in 1 to round((playerC - required_players) / required_num_players_for_apprentice))
			if(!length(possible_wizards))
				break
			var/datum/mind/apprentice = pick_n_take(possible_wizards)
			pre_apprentices += apprentice

	return TRUE

/datum/game_mode/wizard/pre_setup()
	for(var/datum/mind/wizard in pre_wizards)
		wizard.assigned_role = SPECIAL_ROLE_WIZARD //So they aren't chosen for other jobs.
		wizard.offstation_role = TRUE
		wizard.set_original_mob(wizard.current)
		wizard.current.loc = pick(GLOB.wizardstart)
	for(var/datum/mind/apprentice in pre_apprentices)
		apprentice.assigned_role = SPECIAL_ROLE_WIZARD_APPRENTICE //So they aren't chosen for other jobs.
		apprentice.offstation_role = TRUE
		apprentice.set_original_mob(apprentice.current)
		apprentice.current.loc = pick(GLOB.wizardstart)
	..()
	return TRUE

/datum/game_mode/wizard/post_setup()
	var/datum/mind/wizard_teacher
	for(var/datum/mind/wizard in pre_wizards)
		add_game_logs("has been selected as a Wizard", wizard.current)
		forge_wizard_objectives(wizard)
		equip_wizard(wizard.current)
		INVOKE_ASYNC(src, PROC_REF(name_wizard), wizard.current)
		wizard.add_antag_datum(/datum/antagonist/wizard)
		if(!wizard_teacher)
			wizard_teacher = wizard

	for(var/datum/mind/apprentice in pre_apprentices)
		log_game("[key_name(apprentice)] has been selected as a Wizard-Apprentice")
		forge_wizard_apprentice_objectives(wizard_teacher, apprentice)
		equip_wizard_apprentice(apprentice.current)
		INVOKE_ASYNC(src, PROC_REF(name_wizard), apprentice.current)
		apprentice.add_antag_datum(/datum/antagonist/wizard/apprentice)

	..()

/datum/game_mode/proc/remove_wizard(datum/mind/wizard_mind)
	var/datum/antagonist/wizard/wizard = wizard_mind?.has_antag_datum(/datum/antagonist/wizard)
	if(!wizard)
		return
	add_conversion_logs(wizard_mind.current, wizard.deconversion_log)
	wizard_mind.remove_antag_datum(/datum/antagonist/wizard)

/datum/game_mode/proc/forge_wizard_objectives(datum/mind/wizard)
	var/datum/objective/wizchaos/wiz_objective = new
	wiz_objective.owner = wizard
	wizard.objectives += wiz_objective
	return

/datum/game_mode/proc/forge_wizard_apprentice_objectives(datum/mind/wizard, datum/mind/apprentice)
	apprentice.objectives += wizard.objectives

	var/datum/objective/wizchaos/wiz_objective = new /datum/objective/protect
	wiz_objective.owner = apprentice
	wiz_objective.target = wizard
	wiz_objective.explanation_text = "Protect [wizard.name], the wizard teacher."
	apprentice.objectives += wiz_objective
	return

/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/newname = tgui_input_text(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname, max_length = MAX_NAME_LEN)

	if(!newname)
		newname = randomname

	wizard_mob.real_name = newname
	wizard_mob.name = newname
	if(wizard_mob.mind)
		wizard_mob.mind.name = newname

	for(var/datum/mind/apprentice in get_antag_minds(/datum/antagonist/wizard/apprentice))
		for(var/datum/objective/protect/objective in apprentice.objectives)
			objective.explanation_text = "Protect [wizard_mob.real_name], the wizard teacher."

/datum/game_mode/proc/greet_wizard()
	var/list/messages = list()
	messages.Add(span_danger("You are the Space Wizard!"))
	messages.Add("<b>The Space Wizards Federation has given you the following tasks:</b>")
	return messages

/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if(!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	if(isplasmaman(wizard_mob))
		wizard_mob.equipOutfit(new /datum/outfit/plasmaman/wizard)
		wizard_mob.internal = wizard_mob.r_hand
		wizard_mob.update_action_buttons_icon()
	else
		if(isvox(wizard_mob))
			wizard_mob.internal = wizard_mob.r_hand
			wizard_mob.update_action_buttons_icon()
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), ITEM_SLOT_CLOTH_INNER)
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), ITEM_SLOT_HEAD)
		wizard_mob.dna.species.after_equip_job(null, wizard_mob)
	wizard_mob.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	wizard_mob.equip_to_slot_or_del(new /obj/item/radio/headset(wizard_mob), ITEM_SLOT_EAR_LEFT)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), ITEM_SLOT_FEET)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), ITEM_SLOT_CLOTH_OUTER)
	wizard_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(wizard_mob), ITEM_SLOT_BACK)
	if(wizard_mob.dna.species.speciesbox)
		wizard_mob.equip_to_slot_or_del(new wizard_mob.dna.species.speciesbox(wizard_mob), ITEM_SLOT_BACKPACK)
	else
		wizard_mob.equip_to_slot_or_del(new /obj/item/storage/box/survival(wizard_mob), ITEM_SLOT_BACKPACK)
	wizard_mob.equip_or_collect(new /obj/item/teleportation_scroll(wizard_mob), ITEM_SLOT_POCKET_RIGHT)
	var/obj/item/spellbook/spellbook = new /obj/item/spellbook(wizard_mob)
	spellbook.owner = wizard_mob
	wizard_mob.equip_or_collect(spellbook, ITEM_SLOT_HAND_LEFT)

	wizard_mob.faction = list("wizard")

	to_chat(wizard_mob, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(wizard_mob, "The spellbook is bound to you, and others cannot use it.")
	to_chat(wizard_mob, "In your pockets you will find a teleport scroll. Use it as needed.")
	wizard_mob.mind.store_memory("<b>Remember:</b> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	wizard_mob.set_gene_stability(wizard_mob.gene_stability + DEFAULT_GENE_STABILITY) //magic
	return TRUE

/datum/game_mode/proc/equip_wizard_apprentice(mob/living/carbon/human/wizard_mob)
	if(!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	if(isplasmaman(wizard_mob))
		wizard_mob.equipOutfit(new /datum/outfit/plasmaman/wizard)
		wizard_mob.internal = wizard_mob.r_hand
		wizard_mob.update_action_buttons_icon()
	else
		if(isvox(wizard_mob))
			wizard_mob.internal = wizard_mob.r_hand
			wizard_mob.update_action_buttons_icon()
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), ITEM_SLOT_CLOTH_INNER)
		wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(wizard_mob), ITEM_SLOT_HEAD)
		wizard_mob.dna.species.after_equip_job(null, wizard_mob)
	wizard_mob.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc while round setups
	wizard_mob.equip_to_slot_or_del(new /obj/item/radio/headset(wizard_mob), ITEM_SLOT_EAR_LEFT)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), ITEM_SLOT_FEET)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(wizard_mob), ITEM_SLOT_CLOTH_OUTER)
	wizard_mob.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(wizard_mob), ITEM_SLOT_BACK)
	if(wizard_mob.dna.species.speciesbox)
		wizard_mob.equip_to_slot_or_del(new wizard_mob.dna.species.speciesbox(wizard_mob), ITEM_SLOT_BACKPACK)
	else
		wizard_mob.equip_to_slot_or_del(new /obj/item/storage/box/survival(wizard_mob), ITEM_SLOT_BACKPACK)
	wizard_mob.equip_to_slot_or_del(new /obj/item/reagent_containers/cup/glass/mugwort, ITEM_SLOT_BACKPACK)
	wizard_mob.equip_or_collect(new /obj/item/teleportation_scroll(wizard_mob), ITEM_SLOT_POCKET_RIGHT)
	var/obj/item/contract/apprentice_choose_book/apprentice_book = new /obj/item/contract/apprentice_choose_book(wizard_mob)
	apprentice_book.owner = wizard_mob
	wizard_mob.equip_or_collect(apprentice_book, ITEM_SLOT_HAND_LEFT)

	wizard_mob.faction = list("wizard")

	to_chat(wizard_mob, span_notice("Вы найдёте набор из доступных закинаний в вашем магическом учебнике."))
	to_chat(wizard_mob, span_notice("Магический учебник привязан к вам, другие не могут ей воспользоваться."))
	to_chat(wizard_mob, span_notice("В карманах вы найдёте свиток телепортации. Используйте его при необходимости."))
	wizard_mob.mind.store_memory("<b>Помните:</b> не забудьте выбрать предпочитаемый набор.")
	wizard_mob.update_icons()
	wizard_mob.set_gene_stability(wizard_mob.gene_stability + DEFAULT_GENE_STABILITY) //magic
	return TRUE

// Checks if the game should end due to all wizards and apprentices being dead, or MMI'd/Borged
/datum/game_mode/wizard/check_finished()
	var/wizards_alive = 0
	var/apprentices_alive = 0

	// Wizards
	for(var/datum/mind/wizard in get_antag_minds(/datum/antagonist/wizard, specific = TRUE))
		if(!iscarbon(wizard.current))
			continue
		if(wizard.current.stat==DEAD)
			continue
		if(is_mmi(wizard.current)) // wizard is in an MMI, don't count them as alive
			continue
		wizards_alive++

	// Apprentices
	if(!wizards_alive)
		for(var/datum/mind/apprentice in get_antag_minds(/datum/antagonist/wizard/apprentice))
			if(!iscarbon(apprentice.current))
				continue
			if(apprentice.current.stat==DEAD)
				continue
			if(is_mmi(apprentice.current)) // apprentice is in an MMI, don't count them as alive
				continue
			apprentices_alive++

	if(wizards_alive || apprentices_alive || but_wait_theres_more)
		return ..()
	else
		finished = 1
		return 1

/datum/game_mode/wizard/declare_completion(ragin = 0)
	if(finished && !ragin)
		SSticker.mode_result = "wizard loss - wizard killed"
		var/wizard_count = length(get_antag_minds(/datum/antagonist/wizard, specific = TRUE))
		var/apprentice_count = length(get_antag_minds(/datum/antagonist/wizard/apprentice))
		to_chat(world, span_warning(span_bold(span_fontsize3(" The wizard[wizard_count > 1 ? "s" : ""] [apprentice_count > 1 ? "and apprentices" : ""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!"))))
	..()
	return 1

/mob/proc/spellremove(mob/M)
	if(!mind)
		return
	for(var/datum/action/cooldown/spell/spell_to_remove as anything in mind.spell_list)
		mind.RemoveSpell(spell_to_remove)

//To batch-remove mob spells.
/mob/proc/mobspellremove(mob/M)
	for(var/datum/action/cooldown/spell/spell_to_remove as anything in mob_spell_list)
		RemoveSpell(spell_to_remove)

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now.
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		to_chat(usr, "I don't feel strong enough without my robe.")
		return 0
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		to_chat(usr, "I don't feel strong enough without my sandals.")
		return 0
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		to_chat(usr, "I don't feel strong enough without my hat.")
		return 0
	else
		return 1
