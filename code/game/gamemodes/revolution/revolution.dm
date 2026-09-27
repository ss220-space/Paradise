// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely

/datum/game_mode/revolution
	name = "revolution"
	config_tag = "revolution"
	restricted_jobs = list(JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	required_players = 20
	required_enemies = 1
	recommended_enemies = 3

	var/list/datum/mind/pre_head_revolutionaries = list()

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/announce()
	to_chat(world, "<b>Текущий режим игры - <font color='red'>Революция</font>!</b>")
	to_chat(world, "<b>Мятеж на станции спонсируется и возглавляется Синдикатом. Об этом знают и сами мятежники, и служба безопасности.</b>")
	to_chat(world, "Революционеры — наберите сторонников, запустите с консоли связи передачу данных флоту Синдиката и удержите её до подхода флота.")
	to_chat(world, "Экипаж — не дайте передаче состояться. Рабов революции возвращайте имплантами защиты разума, добровольцев и главрев судите как врагов \"Нанотрейзен\".")

///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/pre_setup()
	var/list/possible_revolutionaries = get_players_for_role(ROLE_REV)

	for(var/i=1 to MAX_HEAD_REVOLUTIONARIES)
		if(!length(possible_revolutionaries))
			break
		var/datum/mind/lenin = pick(possible_revolutionaries)
		possible_revolutionaries -= lenin
		pre_head_revolutionaries += lenin
		lenin.restricted_roles = get_restricted_roles()

	if(length(pre_head_revolutionaries) < required_enemies)
		return FALSE

	return TRUE

/datum/game_mode/revolution/post_setup()
	var/list/heads = get_living_heads()
	var/list/sec = get_living_sec()
	var/weighted_score = min(max(round(length(heads) - ((8 - length(sec)) / 3)),1),MAX_HEAD_REVOLUTIONARIES)

	while(weighted_score < length(pre_head_revolutionaries)) //das vi danya
		var/datum/mind/trotsky = pick(pre_head_revolutionaries)
		pre_head_revolutionaries -= trotsky

	for(var/datum/mind/rev_mind in pre_head_revolutionaries)
		add_game_logs("has been selected as a head rev", rev_mind.current)
		rev_mind.add_antag_datum(/datum/antagonist/rev/head)
	..()

/datum/objective/revolution
	explanation_text = "Наберите сторонников, запустите с консоли связи поток данных для флота Синдиката и удерживайте её до подхода флота."
	needs_target = FALSE
	antag_menu_name = "Революция"

/datum/objective/revolution/check_completion()
	var/datum/team/revolution/team = get_revolution_team()
	return team?.victor == REVOLUTION_VICTOR_SYNDICATE

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	var/obj/item/toy/crayon/spraycan/R = new(mob)
	var/obj/item/clothing/glasses/hud/security/chameleon/C = new(mob)
	var/obj/item/storage/box/revolution/kit = new(mob)

	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_POCKET_LEFT,
		"right pocket" = ITEM_SLOT_POCKET_RIGHT,
		"left hand" = ITEM_SLOT_HAND_LEFT,
		"right hand" = ITEM_SLOT_HAND_RIGHT,
	)
	var/where2 = mob.equip_in_one_of_slots(C, slots, qdel_on_fail = TRUE)
	mob.equip_in_one_of_slots(R,slots)
	mob.equip_in_one_of_slots(kit, slots)

	mob.update_icons()

	if(!where2)
		to_chat(mob, "The Syndicate were unfortunately unable to get you a chameleon security HUD.")
	else
		to_chat(mob, "The chameleon security HUD in your [where2] will help you keep track of who is mindshield-implanted, and unable to be recruited.")
		return 1

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind, rev_type = /datum/antagonist/rev/volunteer)
	if(rev_mind.has_antag_datum(/datum/antagonist/rev))
		return 0
	if(!rev_mind.add_antag_datum(rev_type))
		return 0
	add_conversion_logs(rev_mind.current, "recruited to the revolution")
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind, beingborged)
	var/datum/antagonist/rev/rev = rev_mind.has_antag_datum(/datum/antagonist/rev)
	if(!rev)
		return
	if(!beingborged && !rev.can_be_deconverted)
		return
	var/remove_head = istype(rev, /datum/antagonist/rev/head)
	add_conversion_logs(rev_mind.current, "renounced the revolution")
	if(beingborged)
		to_chat(rev_mind.current, span_danger(span_fontsize3("The frame's firmware detects and deletes your neural reprogramming! You remember nothing[remove_head ? "." : " but the name of the one who recruited you."]")))
		message_admins("[ADMIN_LOOKUPFLW(rev_mind.current)] has been borged while being a [remove_head ? "leader" : " member"] of the revolution.")
		rev.silent = TRUE
	rev_mind.remove_antag_datum(/datum/antagonist/rev)

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/declare_completion()
	..()
	return TRUE
