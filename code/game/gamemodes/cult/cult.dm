GLOBAL_LIST_EMPTY(all_cults)

/datum/game_mode
	/// A list of all minds currently in the cult
	var/list/datum/mind/cult = list()
	var/datum/cult_objectives/cult_objs = new
	/// Does the cult have glowing eyes
	var/cult_risen = FALSE
	/// Does the cult have halos
	var/cult_ascendant = FALSE
	/// How many crew need to be converted to rise
	var/rise_number
	/// How many crew need to be converted to ascend
	var/ascend_number
	/// Used for the CentComm announcement at ascension
	var/ascend_percent

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && (M.mind in SSticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(is_sacrifice_target(mind))
		return FALSE
	if(isclocker(mind.current))
		return FALSE // Go away Ratvar
	if(iscultist(mind.current))
		return TRUE //If they're already in the cult, assume they are convertable
	if(mind.isholy)
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
	if(mind.offstation_role)
		return FALSE
	if(issilicon(mind.current))
		return FALSE //can't convert machines, that's ratvar's thing
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!iscultist(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	if(isgolem(mind.current))
		return FALSE
	return TRUE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_AI, JOB_TITLE_CYBORG, JOB_TITLE_LAWYER, JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_PILOT, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_HOP, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_JUDGE, JOB_TITLE_BRIGDOC, JOB_TITLE_CCOFFICER, "Nanotrasen Navy Field Officer", JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/const/max_cultist_to_start = 4

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the offer rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)
	for(var/cultists_number = 1 to max_cultist_to_start)
		if(!length(cultists_possible))
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	return (length(cult) > 0)

/datum/game_mode/cult/post_setup()
	cult_objs.setup()

	for(var/datum/mind/cult_mind in cult)
		SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		var/list/messages = list(CULT_GREETING)
		to_chat(cult_mind.current, chat_box_red(messages.Join("<br>")))
		equip_cultist(cult_mind.current)
		cult_mind.current.faction |= "cult"
		ADD_TRAIT(cult_mind.current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
		var/datum/objective/servecult/obj = new
		obj.owner = cult_mind
		cult_mind.objectives += obj

		if(cult_mind.assigned_role == JOB_TITLE_CLOWN)
			to_chat(cult_mind.current, "<span class='cultitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			cult_mind.current.force_gene_block(GLOB.clumsyblock, FALSE)
			// Don't give them another action if they already have one.
			if(!(locate(/datum/action/innate/toggle_clumsy) in cult_mind.current.actions))
				var/datum/action/innate/toggle_clumsy/toggle_clumsy = new
				toggle_clumsy.Grant(cult_mind.current)

		add_cult_actions(cult_mind)
		update_cult_icons_added(cult_mind)
		cult_objs.study(cult_mind.current)
	cult_threshold_check()
	addtimer(CALLBACK(src, PROC_REF(cult_threshold_check)), 2 MINUTES) // Check again in 2 minutes for latejoiners
	..()

/**
  * Decides at the start of the round how many conversions are needed to rise/ascend.
  *
  * The number is decided by (Percentage * (Players - Cultists)), so for example at 110 players it would be 11 conversions for rise. (0.1 * (110 - 4))
  * These values change based on population because 20 cultists are MUCH more powerful if there's only 50 players, compared to 120.
  *
  * Below 100 players, [CULT_RISEN_LOW] and [CULT_ASCENDANT_LOW] are used.
  * Above 100 players, [CULT_RISEN_HIGH] and [CULT_ASCENDANT_HIGH] are used.
  */
/datum/game_mode/proc/cult_threshold_check()
	var/players = length(GLOB.player_list)
	var/cultists = get_cultists() // Don't count the starting cultists towards the number of needed conversions
	if(players >= CULT_POPULATION_THRESHOLD)
		// Highpop
		ascend_percent = CULT_ASCENDANT_HIGH
		rise_number = round(CULT_RISEN_HIGH * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_HIGH * (players - cultists))
	else
		// Lowpop
		ascend_percent = CULT_ASCENDANT_LOW
		rise_number = round(CULT_RISEN_LOW * (players - cultists))
		ascend_number = round(CULT_ASCENDANT_LOW * (players - cultists))
	add_game_logs("Blood Cult rise/ascend numbers: [rise_number]/[ascend_number].")

/**
  * Returns the current number of cultists and constructs.
  *
  * Returns the number of cultists and constructs in a list ([1] = Cultists, [2] = Constructs), or as one combined number.
  *
  * * separate - Should the number be returned in two separate values (Humans and Constructs) or as one?
  */
/datum/game_mode/proc/get_cultists(separate = FALSE)
	var/cultists = 0
	var/constructs = 0
	for(var/I in cult)
		var/datum/mind/M = I
		if(ishuman(M.current) && !M.current.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
			cultists++
		else if(isconstruct(M.current))
			constructs++
	if(separate)
		return list(cultists, constructs)
	else
		return cultists + constructs

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/H, metal = TRUE)
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(H, "<span class='cult'>These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

/datum/game_mode/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_POCKET_LEFT,
		"right pocket" = ITEM_SLOT_POCKET_RIGHT)
	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots, qdel_on_fail = TRUE)
	if(!where)
		to_chat(H, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return FALSE
	else
		to_chat(H, "<span class='danger'>You have a [item_name] in your [where].</span>")
		return TRUE


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind)
	if(!istype(cult_mind))
		return FALSE

	if(!ascend_percent) // If the rise/ascend thresholds haven't been set (non-cult rounds)
		cult_objs.setup()
		cult_threshold_check()

	if(!(cult_mind in cult))
		cult += cult_mind
		cult_mind.current.faction |= "cult"
		cult_mind.special_role = SPECIAL_ROLE_CULTIST
		ADD_TRAIT(cult_mind.current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)

		if(cult_mind.assigned_role == JOB_TITLE_CLOWN)
			to_chat(cult_mind.current, "<span class='cultitalic'>A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself.</span>")
			cult_mind.current.force_gene_block(GLOB.clumsyblock, FALSE)
			// Don't give them another action if they already have one.
			if(!(locate(/datum/action/innate/toggle_clumsy) in cult_mind.current.actions))
				var/datum/action/innate/toggle_clumsy/toggle_clumsy = new
				toggle_clumsy.Grant(cult_mind.current)

		SEND_SOUND(cult_mind.current, 'sound/ambience/antag/bloodcult.ogg')
		add_conversion_logs(cult_mind.current, "converted to the blood cult")

		if(jobban_isbanned(cult_mind.current, ROLE_CULTIST) || jobban_isbanned(cult_mind.current, ROLE_SYNDICATE))
			replace_jobbanned_player(cult_mind.current, ROLE_CULTIST)
		if(!cult_objs.cult_status && ishuman(cult_mind.current))
			cult_objs.setup()
		update_cult_icons_added(cult_mind)
		add_cult_actions(cult_mind)
		var/datum/objective/servecult/obj = new
		obj.owner = cult_mind
		cult_mind.objectives += obj

		if(cult_risen)
			rise(cult_mind.current)
			if(cult_ascendant)
				ascend(cult_mind.current)
		check_cult_size()
		cult_objs.study(cult_mind.current)
		return TRUE


/datum/game_mode/proc/check_cult_size()
	if(cult_ascendant)
		return
	var/cult_players = get_cultists()

	if((cult_players >= rise_number) && !cult_risen)
		cult_risen = TRUE
		for(var/datum/mind/M in cult)
			if(!M.current || !ishuman(M.current))
				continue
			SEND_SOUND(M.current, 'sound/ambience/antag/bloodcult_eyes.ogg')
			to_chat(M.current, "<span class='cultlarge'>The veil weakens as your cult grows, your eyes begin to glow...</span>")
			log_admin("The Blood Cult has risen. The eyes started to glow.")
			addtimer(CALLBACK(src, PROC_REF(rise), M.current), 20 SECONDS)

	else if(cult_players >= ascend_number)
		cult_ascendant = TRUE
		for(var/datum/mind/M in cult)
			if(!M.current || !ishuman(M.current))
				continue
			SEND_SOUND(M.current, 'sound/ambience/antag/bloodcult_halos.ogg')
			to_chat(M.current, "<span class='cultlarge'>Your cult is ascendant and the red harvest approaches - you cannot hide your true nature for much longer!")
			log_admin("The Blood Cult has Ascended. The blood halo started to appear.")
			addtimer(CALLBACK(src, PROC_REF(ascend), M.current), 20 SECONDS)
		GLOB.command_announcement.Announce("На вашей станции обнаружена внепространственная активность, связанная с культом [SSticker.cultdat ? SSticker.cultdat.entity_name : "Нар’Си"]. Данные свидетельствуют о том, что в ряды культа обращено около [ascend_percent * 100]% экипажа станции. Служба безопасности получает право свободно применять летальную силу против культистов. Прочий персонал должен быть готов защищать себя и свои рабочие места от нападений культистов (в том числе используя летальную силу в качестве крайней меры самообороны). Погибшие члены экипажа должны быть оживлены и деконвертированы, как только ситуация будет взята под контроль.", "Отдел Центрального Командования по делам высших измерений.", 'sound/AI/commandreport.ogg')
		log_game("Blood cult reveal. Powergame allowed.")


/datum/game_mode/proc/rise(cultist)
	if(ishuman(cultist) && iscultist(cultist))
		var/mob/living/carbon/human/H = cultist
		if(!H.original_eye_color)
			H.original_eye_color = H.get_eye_color()
		H.change_eye_color(BLOODCULT_EYE, FALSE)
		H.update_eyes()
		ADD_TRAIT(H, CULT_EYES, CULT_TRAIT)
		H.update_body()

/datum/game_mode/proc/ascend(cultist)
	if(ishuman(cultist) && iscultist(cultist))
		var/mob/living/carbon/human/H = cultist
		new /obj/effect/temp_visual/cult/sparks(get_turf(H), H.dir)
		H.update_halo_layer()


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = TRUE)
	if(cult_mind in cult)
		var/mob/cultist = cult_mind.current
		cult -= cult_mind
		cultist.faction -= "cult"
		cult_mind.special_role = null
		for(var/datum/objective/servecult/O in cult_mind.objectives)
			cult_mind.objectives -= O
			qdel(O)
		REMOVE_TRAIT(cult_mind.current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
		for(var/datum/action/innate/cult/C in cultist.actions)
			qdel(C)
		update_cult_icons_removed(cult_mind)

		if(ishuman(cultist))
			var/mob/living/carbon/human/H = cultist
			REMOVE_TRAIT(H, CULT_EYES, null)
			H.change_eye_color(H.original_eye_color, FALSE)
			H.update_eyes()
			H.remove_overlay(HALO_LAYER)
			H.update_body()
		check_cult_size()
		add_conversion_logs(cultist, "deconverted from the blood cult.")
		if(show_message)
			cultist.visible_message("<span class='cult'>[cultist] looks like [cultist.p_they()] just reverted to [cultist.p_their()] old faith!</span>",
			"<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "Nar'Sie"] and the memories of your time as their servant with it.</span>")

/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	if(cult_mind?.current)
		culthud.join_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, "hudcultist")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	if(cult_mind?.current)
		culthud.leave_hud(cult_mind.current)
		set_antag_hud(cult_mind.current, null)

/datum/game_mode/proc/add_cult_actions(datum/mind/cult_mind)
	if(cult_mind.current)
		var/datum/action/innate/cult/comm/C = new
		var/datum/action/innate/cult/check_progress/D = new
		C.Grant(cult_mind.current)
		D.Grant(cult_mind.current)
		if(ishuman(cult_mind.current))
			var/datum/action/innate/cult/blood_magic/magic = new
			magic.Grant(cult_mind.current)
			var/datum/action/innate/cult/use_dagger/dagger = new
			dagger.Grant(cult_mind.current)
		cult_mind.current.update_action_buttons(TRUE)


/datum/game_mode/cult/declare_completion()
	if(cult_objs.cult_status == NARSIE_HAS_RISEN)
		SSticker.mode_result = "cult win - cult win"
		to_chat(world, "<span class='danger'> <FONT size = 3>The cult wins! It has succeeded in summoning [SSticker.cultdat.entity_name]!</FONT></span>")
	else if(cult_objs.cult_status == NARSIE_HAS_FALLEN)
		SSticker.mode_result = "cult draw - narsie died, nobody wins"
		to_chat(world, "<span class='danger'> <FONT size = 3>Nobody wins! [SSticker.cultdat.entity_name] was summoned, but banished!</FONT></span>")
	else
		SSticker.mode_result = "cult loss - staff stopped the cult"
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	var/endtext
	endtext += "<br><b>The cultists' objectives were:</b>"
	for(var/datum/objective/obj in cult_objs.presummon_objs)
		endtext += "<br>[obj.explanation_text] - "
		if(!obj.check_completion())
			endtext += "<font color='red'>Fail.</font>"
		else
			endtext += "<font color='green'><B>Success!</B></font>"
	if(cult_objs.cult_status >= NARSIE_NEEDS_SUMMONING)
		endtext += "<br>[cult_objs.obj_summon.explanation_text] - "
		if(!cult_objs.obj_summon.check_completion())
			endtext+= "<font color='red'>Fail.</font>"
		else
			endtext += "<font color='green'><B>Success!</B></font>"

	to_chat(world, endtext)
	..()


/proc/is_cultist(mob/living/user)
	return istype(user) && user.mind && SSticker && SSticker.mode && (user.mind in SSticker.mode.cult)

