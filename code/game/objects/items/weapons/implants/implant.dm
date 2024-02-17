/**
 * # Implants
 *
 * Code for implants that can be inserted into a person and have some sort of passive or triggered action.
 *
 */
/obj/item/implant
	name = "bio-chip"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as a auto surgeon, used as a placeholder when a implant doesn't have a sprite
	origin_tech = "materials=2;biotech=3;programming=2"
	actions_types = list(/datum/action/item_action/hands_free/activate)
	item_color = "black"
	flags = DROPDEL  // By default, don't let implants be harvestable.

	/// Which implant overlay should be used for implant cases. This should point to a state in implants.dmi
	var/implant_state = "implant-default"
	/// How the implant is activated.
	var/activated = BIOCHIP_ACTIVATED_ACTIVE
	/// Whether the implant is currently implanted (`BIOCHIP_IMPLANTED`), was implanted previously (`BIOCHIP_USED`) or if its new and intact (`BIOCHIP_NEW`).
	var/implanted = BIOCHIP_NEW
	/// Who the implant is inside of.
	var/mob/living/imp_in

	/// Whether multiple implants of this same type can be inserted into someone.
	var/allow_multiple = FALSE
	/// Amount of times that the implant can be triggered by the user. If the implant can't be used, it can't be inserted.
	var/uses = -1

	/// List of emote keys that activate this implant when used.
	var/list/trigger_emotes
	/// What type of action will trigger this emote. Bitfield of IMPLANT_EMOTE_* defines.
	var/trigger_causes
	/// Whether this implant has already triggered on death or not, to prevent it firing multiple times.
	var/has_triggered_on_death = FALSE

	///the implant_fluff datum attached to this implant, purely cosmetic "lore" information
	var/datum/implant_fluff/implant_data = /datum/implant_fluff


/obj/item/implant/Initialize(mapload)
	. = ..()
	if(ispath(implant_data, /datum/implant_fluff))
		implant_data = new implant_data


/obj/item/implant/Destroy()
	if(imp_in)
		removed(imp_in)
		imp_in = null
	if(istype(loc, /obj/item/implanter))
		var/obj/item/implanter/implanter = loc
		implanter.imp = null
		implanter.update_state()
	if(istype(loc, /obj/item/implantpad))
		var/obj/item/implantcase/implantcase = loc
		implantcase.imp = null
		implantcase.update_state()
	QDEL_NULL(implant_data)
	return ..()


/obj/item/implant/proc/unregister_emotes()
	if(imp_in && LAZYLEN(trigger_emotes))
		for(var/emote in trigger_emotes)
			UnregisterSignal(imp_in, COMSIG_MOB_EMOTED(emote))


/**
 * Set the emote that will trigger the implant.
 *
 * Arguments:
 * * user - User who is trying to associate the implant to themselves.
 * * emote_key - Key of the emote that should trigger the implant.
 * * on_implant - Whether this proc is being called during the implantation of the implant.
 * * silent - If `TRUE`, the user won't get any to_chat messages if an implantation fails.
 */
/obj/item/implant/proc/set_trigger(mob/user, emote_key, on_implant = FALSE, silent = TRUE)
	if(imp_in != user)
		return FALSE

	if(!emote_key)
		return FALSE

	if(LAZYIN(trigger_emotes, emote_key) && !on_implant)
		if(!silent)
			to_chat(user, span_warning("You've already registered [emote_key]!"))
		return FALSE

	if(emote_key == "me" || emote_key == "custom")
		if(!silent)
			to_chat(user, span_warning("You can't trigger [src] with a custom emote."))
		return FALSE

	var/intentional_cause = (trigger_causes & BIOCHIP_EMOTE_TRIGGER_INTENTIONAL) && !(trigger_causes & BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL)
	if(!(emote_key in user.usable_emote_keys(intentional_cause)))
		if(!silent)
			to_chat(user, span_warning("You can't trigger [src] with that emote [intentional_cause ? "intentionally" : "unintentionally"]! Try *help to see emotes you can use."))
		return FALSE

	LAZYADDOR(trigger_emotes, emote_key)
	RegisterSignal(user, COMSIG_MOB_EMOTED(emote_key), PROC_REF(on_emote))


/obj/item/implant/proc/on_emote(mob/living/user, datum/emote/fired_emote, key, emote_type, message, intentional)
	SIGNAL_HANDLER

	if(!implanted || !imp_in)
		return

	if(!(intentional && (trigger_causes & BIOCHIP_EMOTE_TRIGGER_INTENTIONAL)) && !(!intentional && (trigger_causes & BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL)))
		return

	add_attack_logs(user, user, "[src] was [intentional ? "intentionally" : "unintentionally"] triggered with the emote [fired_emote].")
	emote_trigger(key, user, intentional)


/obj/item/implant/proc/on_death(mob/source, gibbed)
	SIGNAL_HANDLER

	if(!implanted || !imp_in)
		return

	if(gibbed && (trigger_causes & BIOCHIP_TRIGGER_NOT_WHEN_GIBBED))
		return

	// This should help avoid infinite recursion for things like dust that call death()
	if(has_triggered_on_death && (trigger_causes & BIOCHIP_TRIGGER_DEATH_ONCE))
		return

	has_triggered_on_death = TRUE

	add_attack_logs(source, source, "had their [src] bio-chip triggered on [gibbed ? "gib" : "death"].")
	death_trigger(source, gibbed)


/obj/item/implant/proc/emote_trigger(emote, mob/source, intentional)
	return


/obj/item/implant/proc/death_trigger(mob/source, gibbed)
	return


/obj/item/implant/proc/activate(cause)
	return


/obj/item/implant/ui_action_click()
	activate("action_button")


/**
 * Try to implant ourselves into a mob.
 *
 * Arguments:
 * * source - The person the implant is being administered to.
 * * user - The person who is doing the implanting.
 * * force - If `TRUE` bypasses all checks in [/obj/item/implant/proc/can_implant()]
 *
 * Returns `TRUE` on success.
 */
/obj/item/implant/proc/implant(mob/living/carbon/human/source, mob/user, force = FALSE)
	if(!force && !can_implant(source, user))
		return
	var/obj/item/implant/imp_e = locate(type) in source
	if(!allow_multiple && imp_e && imp_e != src)
		if(imp_e.uses < initial(imp_e.uses) * 2)
			if(uses == -1)
				imp_e.uses = -1
			else
				imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses) * 2)
			qdel(src)
			return TRUE
		return FALSE

	loc = source
	imp_in = source
	implanted = BIOCHIP_IMPLANTED

	if(trigger_emotes)
		if(!(trigger_causes & BIOCHIP_EMOTE_TRIGGER_INTENTIONAL|BIOCHIP_EMOTE_TRIGGER_UNINTENTIONAL))
			CRASH("Bio-chip [src] has trigger emotes defined but no trigger cause with which to use them!")
		if(activated == BIOCHIP_ACTIVATED_PASSIVE && (trigger_causes & BIOCHIP_EMOTE_TRIGGER_INTENTIONAL))
			CRASH("Bio-chip [src] has intentional emote triggers on a passive bio-chip")
		// If you can't activate the implant manually, you shouldn't be able to deliberately activate it with an emote
		for(var/emote in trigger_emotes)
			set_trigger(source, emote, on_implant = TRUE)

	if(activated == BIOCHIP_ACTIVATED_ACTIVE)
		for(var/datum/action/action as anything in actions)
			action.Grant(source)
			update_button(action)

	if(trigger_causes & (BIOCHIP_TRIGGER_DEATH_ONCE|BIOCHIP_TRIGGER_DEATH_ANY))
		RegisterSignal(source, COMSIG_MOB_DEATH, PROC_REF(on_death))

	if(ishuman(source))
		source.sec_hud_set_implants()

	if(user)
		add_attack_logs(user, source, "Chipped with [src]")

	return TRUE


/**
 * Check that we can actually implant this before implanting it
 * * source - The person being implanted
 * * user - The person doing the implanting
 *
 * Returns:
 * `TRUE` - I could care less, implant it, maybe don't. I don't care.
 * `FALSE` - Don't implant!
 */
/obj/item/implant/proc/can_implant(mob/source, mob/user)
	return TRUE


/**
 * Clean up when an implant is removed.
 *
 * Arguments:
 * * source - the user who the implant was removed from.
 */
/obj/item/implant/proc/removed(mob/living/carbon/human/source)
	loc = null
	imp_in = null
	implanted = BIOCHIP_USED

	for(var/datum/action/action as anything in actions)
		action.Remove(source)

	if(ishuman(source))
		source.sec_hud_set_implants()

	if(trigger_causes & (BIOCHIP_TRIGGER_DEATH_ONCE|BIOCHIP_TRIGGER_DEATH_ANY))
		UnregisterSignal(source, COMSIG_MOB_DEATH)

	unregister_emotes()

	return TRUE


/**
 * Updates button name and description.
 */
/obj/item/implant/proc/update_button(datum/action/action)
	action.name = "[initial(action.name)] [name]"
	action.desc = desc
	action.UpdateButtonIcon()

