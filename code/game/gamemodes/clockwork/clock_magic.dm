/datum/action/innate/clockwork/clock_magic //Clockwork magic casting.
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. The magic you will cast depends on what's in your hand."
	//The spells on his hands!
	var/list/spells = list()
	var/channeling = FALSE

//get_active_hand it gets the thing in active one
//put_in_hands it PUTS but i think it won't be needed

/datum/action/innate/clockwork/clock_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/clockwork/clock_magic/Activate()
	. = ..()
	var/obj/item/I = owner.get_active_hand()
	if(!I)
		var/max_spells = CLOCK_MAX_HANDSPELLS
		if(length(spells) >= max_spells)
			to_chat(owner, "<span class='clockitalic'>You cannot store more than [max_spells] spell\s. <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [max_spells] spell\s, pick a spell to remove.")


/datum/action/innate/clockwork/clock_magic/proc/remove_spell(message = "Pick a spell to remove.")
	var/nullify_spell = input(owner, message, "Current Spells") as null|anything in spells
	if(nullify_spell)
		qdel(nullify_spell)
