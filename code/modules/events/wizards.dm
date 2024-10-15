#define MINIMUM_CREW_REQ 10
#define CREW_PER_WIZARD 30
GLOBAL_VAR_INIT(wizard_events_triggered, 0)
/datum/event/space_wizards
	name = "Рейд ФКВ"
	var/mages_made

/datum/event/space_wizards/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))

/datum/event/space_wizards/proc/get_wizards_number()
	if(num_station_players() <= MINIMUM_CREW_REQ)
		return 0

	return floor(num_station_players() / CREW_PER_WIZARD) || 1 //every mage each 30 crew


/datum/event/space_wizards/proc/wrappedstart()
	var/mages_number = get_wizards_number()

	if(mages_number < 1)
		log_and_message_admins("Warning: Could not spawn any mobs for event Wizard Raid. Reason - not enough players.")
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 SECONDS)
		return

	var/image/source = image('icons/obj/cardboard_cutout.dmi', "cutout_wizard")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Space Wizard?", ROLE_WIZARD, TRUE, poll_time = 60 SECONDS, source = source)
	if(!candidates.len)
		log_and_message_admins("Warning: Could not spawn any mobs for event Wizard Raid. Reason - not enough candidates.")
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 SECONDS)

	while(mages_number && length(candidates))
		var/mob/new_mage = pick_n_take(candidates)
		if(new_mage)
			GLOB.wizard_events_triggered += 1
			var/mob/living/carbon/human/new_character= makeBody(new_mage)
			new_character.mind.make_Wizard() // This puts them at the wizard spawn, worry not
			mages_number--
			log_game("Spawned [new_character] (ckey: [new_character.key]) as midround Wizard.")

#undef MINIMUM_CREW_REQ
#undef CREW_PER_WIZARD
