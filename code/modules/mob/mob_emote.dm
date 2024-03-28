
// The datum in use is defined in code/datums/emotes.dm

/**
 * Send an emote.
 *
 * * emote_key - Key of the emote being triggered
 * * type_override - Type of the emote, like EMOTE_AUDIBLE. If this is not null, the default type of the emote will be overridden.
 * * message - Custom parameter for the emote. This should be used if you want to pass something like a target programmatically.
 * * intentional - Whether or not the emote was deliberately triggered by the mob. If `FALSE`, it's forced, which skips some checks when calling the emote.
 * * force_silence - If `TRUE`, unusable/nonexistent emotes will not notify the user.
 * * ignore_cooldowns - If `TRUE` all cooldowns will be skipped.
 */
/mob/proc/emote(emote_key, type_override = null, message = null, intentional = FALSE, force_silence = FALSE, ignore_cooldowns = FALSE)
	emote_key = lowertext(emote_key)
	var/param = message
	var/custom_param_offset = findtext(emote_key, EMOTE_PARAM_SEPARATOR, 1, null)
	if(custom_param_offset)
		param = copytext(emote_key, custom_param_offset + length(emote_key[custom_param_offset]))
		emote_key = copytext(emote_key, 1, custom_param_offset)

	var/list/key_emotes = GLOB.emote_list[emote_key]

	if(!length(key_emotes))
		if(intentional && !force_silence)
			to_chat(src, span_notice("'[emote_key]' emote does not exist. Say *help for a list."))
		else if(!intentional)
			CRASH("Emote with key [emote_key] was attempted to be called, though doesn't exist!")
		return FALSE

	var/silenced = FALSE
	for(var/datum/emote/emote as anything in key_emotes)
		// can this mob run the emote at all?
		if(!emote.can_run_emote(src, intentional = intentional))
			continue
		if(!emote.check_cooldown(src, intentional, ignore_cooldowns))
			// if an emote's on cooldown, don't spam them with messages of not being able to use it
			silenced = TRUE
			continue
		if(emote.try_run_emote(src, param, type_override, intentional))
			return TRUE
	if(intentional && !silenced && !force_silence)
		to_chat(src, span_notice("Unusable emote '[emote_key]'. Say *help for a list."))
	return FALSE


/**
 * Perform a custom emote.
 *
 * * m_type: Type of message to send.
 * * message: Content of the message. If none is provided, the user will be prompted to choose the input.
 * * intentional: Whether or not the user intendeded to perform the emote.
 */
/mob/proc/custom_emote(m_type = EMOTE_VISIBLE, message = null, intentional = FALSE, ignore_cooldowns = FALSE)
	var/input = ""
	if(!message && !client)
		CRASH("An empty custom emote was called from a client-less mob.")
	else if(!message)
		input = sanitize(copytext_char(input(src,"Choose an emote to display.") as text|null, 1, MAX_MESSAGE_LEN))
	else
		input = message

	emote("me", m_type, input, intentional, ignore_cooldowns = ignore_cooldowns)


/**
 * Get a list of all emote keys usable by the current mob.
 *
 * * intentional_use: Whether or not to check based on if the action was intentional.
 */
/mob/proc/usable_emote_keys(intentional_use)
	var/list/all_keys = list()
	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			if(P.key in all_keys)
				continue
			if(P.can_run_emote(src, status_check = FALSE, intentional = intentional_use))
				all_keys += P.key
				if(P.key_third_person)
					all_keys += P.key_third_person
	return all_keys


/datum/emote/help
	key = "help"
	mob_type_ignore_stat_typecache = list(/mob/dead/observer, /mob/living/silicon/ai)


/datum/emote/help/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/list/base_keys = list()
	var/list/all_keys = list()
	var/list/species_emotes = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	var/mob/living/carbon/human/H = user
	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			var/full_key = P.key
			if(P.key in all_keys)
				continue
			if(P.can_run_emote(user, status_check = FALSE, intentional = TRUE))
				if(P.message_param && P.param_desc)
					// Add our parameter description, like flap-user
					full_key = P.key + "\[[EMOTE_PARAM_SEPARATOR][P.param_desc]\]"
				if(istype(H) && P.species_type_whitelist_typecache && H.dna && is_type_in_typecache(H.dna.species, P.species_type_whitelist_typecache))
					species_emotes += full_key
				else
					base_keys += full_key
				all_keys += P.key

	base_keys = sortList(base_keys)
	message += base_keys.Join(", ")
	message += "."
	message = message.Join("")
	if(length(species_emotes))
		species_emotes = sortList(species_emotes)
		message += "\n<u>[user?.dna?.species.name] specific emotes</u> :- "
		message += species_emotes.Join(", ")
		message += "."
	to_chat(user, message)


/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	message = "дела%(ет,ют)% кувырок!"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE|EMOTE_FORCE_NO_RUNECHAT  // don't need an emote to see that
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)  // okay but what if we allowed ghosts to flip as well
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/living/captive_brain, /mob/camera, /mob/living/silicon/ai)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)


/datum/emote/flip/run_emote(mob/living/carbon/human/user, params, type_override, intentional)

	if(isobserver(user))
		if(user.orbiting)
			user.stop_orbit()
		user.SpinAnimation(5, 1)
		return TRUE

	if(isliving(user) && (user.lying || user.resting))
		message = "круж%(ит,ат)%ся на полу."
		return ..()

	else if(params)
		message_param = "дела%(ет,ют)% кувырок в сторону %t."
	else if(ishuman(user))
		var/obj/item/grab/grab = user.get_active_hand()
		if(istype(grab) && grab.affecting)
			var/mob/living/target = grab.affecting

			if(user.buckled || target.buckled)
				to_chat(user, span_warning("[target] is buckled, you can't flip around [target.p_them()]!"))
				return TRUE

			var/turf/oldloc = user.loc
			var/turf/newloc = target.loc
			if(isturf(oldloc) && isturf(newloc))
				user.SpinAnimation(5, 1)
				var/old_pass = user.pass_flags
				user.pass_flags |= (PASSTABLE)
				step(user, get_dir(oldloc, newloc))
				user.pass_flags = old_pass
				message = "дела%(ет,ют)% кувырок через [target.name]!"
				return ..()

	user.SpinAnimation(5, 1)

	if(ishuman(user) && (prob(5) || (iskidan(user) && !user.get_organ(BODY_ZONE_HEAD))))
		message = "пыта%(ет,ют)%ся сделать кувырок и с грохотом пада%(ет,ют)% на пол!"
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, Weaken), 4 SECONDS), 0.3 SECONDS, TIMER_UNIQUE)
	return ..()


/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	hands_use_check = TRUE
	emote_type = EMOTE_VISIBLE|EMOTE_FORCE_NO_RUNECHAT
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain, /mob/living/captive_brain, /mob/camera, /mob/living/silicon/ai)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)
	cooldown = 3 SECONDS // how long the spin takes, any faster and mobs can spin


/datum/emote/spin/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user) || prob(95))
		if(isobserver(user) && user.orbiting)
			user.stop_orbit()
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, spin), 20, 1)

	else
		to_chat(user, span_warning("You spin too much!"))
		user.Dizzy(24 SECONDS)
		user.Confused(24 SECONDS)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, spin), 32, 1)
	return TRUE

