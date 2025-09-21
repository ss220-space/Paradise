#define TIME_TO_DEATH 5 MINUTES

GLOBAL_LIST_EMPTY(cashed_viruses)

/datum/component/spidorak
	var/list/datum/disease/virus/viruses = list()
	var/list/active_timers_to_death = list()

/datum/component/spidorak/Initialize(var/list/datum/disease/virus/linked_virus)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	
	for(var/datum/disease/virus/virus in linked_virus)
		addtimer(CALLBACK(src, PROC_REF(virus_death)))

/datum/component/spidorak/RegisterWithParent()
	if(isatom(parent))
		RegisterSignal(COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	if(isitem(parent))
		RegisterSignal(COMSIG_ITEM_PICKUP, PROC_REF(pick_up))

/datum/component/spidorak/proc/append_new_viruses(list/datum/disease/virus/viruses_to_append)


/datum/component/spidorak/proc/append_component(atom/target, list/virus_to_add)
	target.AddComponent(/datum/component/spidorak, virus_to_add)

/datum/component/spidorak/proc/virus_death(datum/disease/virus/virus_to_death)


/datum/component/spidorak/proc/virus_contact(atom/target_to_contact)
	var/list/virus_to_contact_add = list()

	for(var/datum/disease/virus/virus in viruses)
		if(virus.spread_flags & NON_CONTAGIOUS)
			continue

		if(virus.spread_flags & CONTACT)
			if(isliving(target_to_contact))
				virus.Contract(target_to_contact)

			virus_to_contact_add += virus

	if(length(virus_to_contact_add))
		virus_contact(target_to_contact, virus_to_contact_add)

/datum/component/spidorak/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(ishuman(arrived))
		var/mob/living/carbon/human/target_human = arrived

		if(target_human.shoes)
			virus_contact(target_human.shoes)
			return

	virus_contact(arrived)

/datum/component/spidorak/proc/pick_up(obj/item/I, mob/user)
	SIGNAL_HANDLER

	if(ishuman(user))
		var/mob/living/carbon/human/target_human = user

		if(target_human.gloves)
			virus_contact(target_human.shoes)
			return
	virus_contact(user)
	