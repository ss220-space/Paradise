/**
 * Digital camouflage element (ported from /tg/station, extended for camera consoles).
 *
 * Hides the attached living mob from anyone watching them through a camera: it places a blank `override`
 * image over the mob on every camera-viewer's client (so the mob renders as nothing), and hides them from
 * the AI's silicon data HUDs (medical / security / diagnostic markers). The AI-tracking block itself is
 * handled separately by TRAIT_AI_UNTRACKABLE (master220 gates can_track() on that trait, see living.dm),
 * which the wearer of the lock robes already carries - this element supplies the visual half master220
 * lacked.
 *
 * Camera viewers covered every tick (these render the world through their MAIN view, where the camera-camo
 * plane trick from [/datum/component/camera_camo] does NOT hide the wearer, so they need the override too):
 * - Every AI (sees the world through its aiEye; only ever via cameras, so the override never inconveniences it).
 * - Everyone currently driving an ADVANCED camera console (GLOB.camera_console_watchers, maintained by
 *   camera_advanced.dm) - their perspective is relocated into the camera eye, so the override doesn't bother
 *   their in-person view either. The BASIC security camera console is NOT here: it renders through a popup
 *   plane group and is handled side-effect-free by the camera_camo component instead.
 *
 * tg only hides from the AI; the advanced-console coverage and the [camera_camo] component are master220
 * additions this path needed. Blanking targets whatever images sit in GLOB.digitalcamo_images, which is the
 * element's own mob-blank PLUS the component's proxy-blank, so both the body and its render-target proxy are
 * suppressed for these viewers.
 */
/// Flat list of every active blank `override` image produced by digitalcamo, across all wearers. Camera
/// viewers (AIs, camera-console watchers) get this whole list dumped into their client.images each tick, and
/// the consoles subtract it from a watcher's client when they stop watching.
GLOBAL_LIST_EMPTY(digitalcamo_images)

/datum/element/digitalcamo
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	/// Assoc list of attached_mob -> the blank override image we hide it behind on camera-viewer clients.
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
	GLOB.digitalcamo_images |= img
	hide_from_ai_huds(target)

/datum/element/digitalcamo/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)
	var/image/img = attached_mobs[target]
	GLOB.digitalcamo_images -= img
	// Pull the override off everyone who could be holding it, so the now-unrobed mob becomes visible at once.
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		ai.client?.images -= img
	for(var/mob/watcher as anything in GLOB.camera_console_watchers)
		watcher.client?.images -= img
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

// Re-assert the override images on every camera viewer each tick, so newly-spawned AIs, reconnects, freshly
// opened consoles and refreshed camera views keep the wearer hidden for as long as the element is attached.
// (We use the shared GLOB.digitalcamo_images list so a viewer who is watching multiple camo'd mobs gets all
// of them in one pass, and so the consoles can strip them on close without reaching into element state.)
/datum/element/digitalcamo/process(seconds_per_tick)
	if(!length(GLOB.digitalcamo_images))
		return
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(!ai.client)
			continue
		ai.client.images |= GLOB.digitalcamo_images
	for(var/mob/watcher as anything in GLOB.camera_console_watchers)
		if(QDELETED(watcher))
			// A watcher that got deleted without a clean console close - don't keep it pinned in the global.
			GLOB.camera_console_watchers -= watcher
			continue
		if(!watcher.client)
			continue
		watcher.client.images |= GLOB.digitalcamo_images
