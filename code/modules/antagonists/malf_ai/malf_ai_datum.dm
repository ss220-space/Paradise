/datum/antagonist/malf_ai
	name = "Malfunctioning AI"
	roundend_category = "traitors"
	job_rank = ROLE_MALF_AI
	special_role = SPECIAL_ROLE_TRAITOR
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


/datum/antagonist/malf_ai/Destroy(force, ...)
	var/mob/living/silicon/ai/malf = owner?.current
	if(istype(malf))
		malf.clear_zeroth_law()
		malf.common_radio.channels.Remove("Syndicate")  // De-traitored AIs can still state laws over the syndicate channel without this
		malf.laws.sorted_laws = malf.laws.inherent_laws.Copy() // AI's 'notify laws' button will still state a law 0 because sorted_laws contains it
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

	var/objective_count = 1
	for(var/i = objective_count, i < CONFIG_GET(number/traitor_objectives_amount))
		add_objective(/datum/objective/assassinate)
		i += 1

	add_objective(/datum/objective/survive)


/datum/antagonist/malf_ai/finalize_antag()
	add_malf_tools()
	var/list/messages = list()
	if(give_codewords)
		messages.Add(give_codewords())
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
	shodan.set_zeroth_law(law, cyborg_law)
	shodan.set_syndie_radio()
	if(!silent)
		to_chat(shodan, "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!")
	shodan.add_malf_picker()
	SSticker?.score?.save_silicon_laws(shodan, additional_info = "malf AI initialization, new zero law was added '[law]'")
	for(var/mob/living/silicon/robot/unit in shodan.connected_robots)
		SSticker?.score?.save_silicon_laws(unit, additional_info = "malf AI initialization, new zero law was added '[cyborg_law]'")


/**
 * Notify the AI of their codewords and write them to `antag_memory` (notes).
 */
/datum/antagonist/malf_ai/proc/give_codewords()
	if(!owner.current)
		return

	var/mob/traitor_mob = owner.current

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")

	antag_memory += "<b>Code Phrase</b>: <span class='red'>[phrases]</span><br>"
	antag_memory += "<b>Code Response</b>: <span class='red'>[responses]</span><br>"
	traitor_mob.client.chatOutput?.notify_syndicate_codes()

	var/list/messages = list()
	if(!silent)
		messages.Add("<U><B>The Syndicate have provided you with the following codewords to identify fellow agents:</B></U>")
		messages.Add("<span class='bold body'>Code Phrase: <span class='codephrases'>[phrases]</span></span>")
		messages.Add("<span class='bold body'>Code Response: <span class='coderesponses'>[responses]</span></span>")
		messages.Add("Use the codewords during regular conversation to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
		messages.Add("<b><font color=red>You memorize the codewords, allowing you to recognize them when heard.</font></b>")
	return messages

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

