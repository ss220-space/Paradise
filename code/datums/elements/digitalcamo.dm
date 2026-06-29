/**
 * Digital camouflage element (ported from /tg/station).
 *
 * Hides the attached living mob from AI eyes: it places a blank `override` image over the mob on every
 * AI's client (so the AI literally cannot see them through cameras), and hides them from the AI's silicon
 * data HUDs (medical / security / diagnostic markers). The AI-tracking block itself is handled separately
 * by TRAIT_AI_UNTRACKABLE (master220 gates can_track() on that trait, see living.dm), which the wearer of
 * the lock robes already carries - this element supplies the visual half that master220 was missing.
 */
/datum/element/digitalcamo
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// Assoc list of attached_mob -> the blank override image we hide it behind on AI clients.
	var/list/attached_mobs = list()

/datum/element/digitalcamo/New()
	. = ..()
	START_PROCESSING(SSdcs, src)

/datum/element/digitalcamo/Destroy()
	STOP_PROCESSING(SSdcs, src)
	return ..()

/datum/element/digitalcamo/Attach(datum/target)
	. = ..()
	if(!isliving(target) || (target in attached_mobs))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/image/img = image(loc = target)
	img.override = TRUE
	attached_mobs[target] = img
	hide_from_ai_huds(target)

/datum/element/digitalcamo/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)
	var/image/img = attached_mobs[target]
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.client?.images -= img
	attached_mobs -= target
	unhide_from_ai_huds(target)

/// Hides the mob from every AI's silicon data HUDs (so no health/ID/diagnostic marker betrays them).
/datum/element/digitalcamo/proc/hide_from_ai_huds(mob/living/target)
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		for(var/hud_id in list(ai.med_hud, ai.sec_hud, ai.d_hud, DATA_HUD_DIAGNOSTIC))
			var/datum/atom_hud/silicon_hud = GLOB.huds[hud_id]
			silicon_hud?.hide_single_atomhud_from(ai, target)

/datum/element/digitalcamo/proc/unhide_from_ai_huds(mob/living/target)
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		for(var/hud_id in list(ai.med_hud, ai.sec_hud, ai.d_hud, DATA_HUD_DIAGNOSTIC))
			var/datum/atom_hud/silicon_hud = GLOB.huds[hud_id]
			silicon_hud?.unhide_single_atomhud_from(ai, target)

/datum/element/digitalcamo/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("Кожа словно перетекает, будто что-то движется под ней.")

// Re-assert the override image on every AI client each tick, so newly-spawned AIs, reconnects and refreshed
// camera views keep the wearer hidden for as long as the element is attached.
/datum/element/digitalcamo/process(seconds_per_tick)
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(!ai.client)
			continue
		for(var/mob/hidden_mob as anything in attached_mobs)
			ai.client.images |= attached_mobs[hidden_mob]
