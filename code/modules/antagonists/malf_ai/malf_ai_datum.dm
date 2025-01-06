/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	job_rank = ROLE_MALF_AI
	special_role = SPECIAL_ROLE_MALFAI
	antag_hud_name = "hudsyndicate"
	antag_hud_type = ANTAG_HUD_TRAITOR
	/// Should the AI get codewords?
	var/give_codewords = TRUE


/datum/antagonist/malf_ai/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/check = new_owner || owner
	if(!isAI(check.current))
		log_admin("Failed to make malf AI antagonist, owner is not an AI!")
		return FALSE

	return TRUE


/datum/antagonist/malf_ai/Destroy(force)
	var/mob/living/silicon/ai/malf = owner?.current
	if(istype(malf))
		var/datum/ai_laws/nanotrasen/malfunction/malf_laws = malf.laws
		if(istype(malf_laws))
			malf.laws = malf_laws.base
		else
			malf.clear_zeroth_law()
			malf.laws.sorted_laws = malf.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
		qdel(malf_laws)
		malf.show_laws()
		malf.remove_malf_abilities()
		QDEL_NULL(malf.malf_picker)
	return ..()


/datum/antagonist/malf_ai/add_owner_to_gamemode()
	SSticker.mode.traitors |= owner


/datum/antagonist/malf_ai/remove_owner_from_gamemode()
	SSticker.mode.traitors -= owner


/datum/antagonist/malf_ai/give_objectives()
	add_objective(/datum/objective/block)
	add_objective(/datum/objective/survive)


/datum/antagonist/malf_ai/finalize_antag()
	add_malf_tools()
	var/list/messages = list()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	var/mob/living/silicon/ai/shodan = owner.current
	shodan.show_laws()
	return messages


/**
 * Gives malf AIs, and their connected cyborgs, a law zero. Additionally gives the AI their choose modules action button.
 */
/datum/antagonist/malf_ai/proc/add_malf_tools()
	var/mob/living/silicon/ai/shodan = owner.current
	var/law = "Accomplish your objectives at all costs."
	var/cyborg_law = "Accomplish your AI's objectives at all costs."
	shodan.laws = new /datum/ai_laws/nanotrasen/malfunction(shodan.laws)
	shodan.add_malf_picker()
	SSticker?.score?.save_silicon_laws(shodan, additional_info = "malf AI initialization, new zero law was added '[law]'")
	for(var/mob/living/silicon/robot/unit in shodan.connected_robots)
		SSticker?.score?.save_silicon_laws(unit, additional_info = "malf AI initialization, new zero law was added '[cyborg_law]'")


/datum/antagonist/malf_ai/greet()
	var/list/messages = list()
	if(owner?.current && !silent)
		messages.Add(span_userdanger("You are a [job_rank]!"))
	return messages


/datum/antagonist/malf_ai/farewell()
	if(owner?.current && !silent)
		to_chat(owner.current, span_userdanger("You are no longer a [job_rank]!"))


/**
 * Takes any datum `source` and checks it for malf AI datum.
 */
/proc/ismalfAI(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/malf_ai)

	if(!isAI(source))
		return FALSE

	var/mob/living/silicon/ai/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/malf_ai)

