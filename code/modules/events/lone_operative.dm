/datum/event/lone_operative
	name = "Ядерный Оперативник - Одиночка"


/datum/event/lone_operative/start()
	processing = 0
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Ядерного оперативника - Одиночки?", ROLE_OPERATIVE, TRUE, source = image('icons/mob/simple_human.dmi', "syndicate_space_sword"))
	if(!length(candidates))
		log_and_message_admins("Warning: nobody volunteered to become a Lone Operative!")
		kill()
		return
	var/mob/living/carbon/human/operative = new (pick(GLOB.carplist))
	var/mob/candidate = pick(candidates)
	operative.key = candidate.key
	create_syndicate(operative.mind)
	var/datum/antagonist/nuclear_operative/datum = operative.mind.add_antag_datum(/datum/antagonist/nuclear_operative/loneop)
	datum.equip()
	log_and_message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into a Lone Operative by an event.")
	log_game("[operative.key] was spawned as a Lone Operative by an event.")

