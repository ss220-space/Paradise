/datum/event/drifting_contractor
	name = "Дрейфующий Контрактник Синдиката"

/datum/event/drifting_contractor/start()
	processing = 0
	var/list/check_list = GLOB.player_list - GLOB.new_player_mobs
	if(length(check_list) < 20)
		message_admins("[name] event failed to start. Not enough players.")
		return
	if(!get_contractor())
		message_admins("[name] event failed to find players. Retrying in 30s.")
		addtimer(CALLBACK(src, PROC_REF(get_contractor)), 30 SECONDS)

/datum/event/drifting_contractor/proc/get_contractor()
	processing = 0
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль дрейфующего контрактника?", ROLE_TRAITOR, TRUE, source = image('icons/mob/simple_human.dmi', "contractor"))
	if(!length(candidates))
		log_and_message_admins("Warning: nobody volunteered to become a drifting contractor!")
		kill()
		return FALSE
	var/mob/living/carbon/human/contractor = new (pick(GLOB.carplist))
	var/mob/candidate = pick(candidates)
	contractor.possess_by_player(candidate.key)
	create_syndicate(contractor.mind)
	var/datum/antagonist/contractor/drifting_contractor/datum = contractor.mind.add_antag_datum(/datum/antagonist/contractor/drifting_contractor)
	datum.equip()
	log_and_message_admins("[ADMIN_LOOKUPFLW(contractor)] has been made into a drifting contractor by an event.")
	log_game("[contractor.key] was spawned as a drifting contractor by an event.")
	return TRUE
