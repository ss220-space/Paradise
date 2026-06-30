// Widest viewport a player can pick in Settings -> "Диапазон обзора" is "19x15" (Ультраширокий): 19 tiles
// wide -> a horizontal view radius of (19-1)/2 = 9 tiles (vertical is only 7). The Refuge's watcher scan has
// to reach that far, or an ultrawide onlooker standing 8-9 tiles away (off-screen for the heretic) could
// watch them slip into / out of hiding. See setviewrange in preference/preferences.dm.
#define CARETAKER_MAX_WATCH_RANGE 9

// Последнее пристанище смотрителя (Caretaker's Last Refuge) — reworked into a jaunt (Paradise-original,
// improving on tg's intangible status-effect version). Built on the Space Crawl jaunt, but instead of
// requiring a space/low-pressure turf, the gate is "nobody is watching you":
//   * You may only ENTER the Refuge while no conscious onlooker can see you.
//   * You may only EXIT (resurface) on a spot no conscious onlooker can see.
// While phased you are intangible and unable to act, exactly like the Space Crawl. The jaunt model
// (the floating holder + position indicator) is intentionally kept identical to Space Crawl for now - a
// bespoke caretaker visual will come later. Because the parent's can_cast early-returns TRUE while jaunting,
// the cooldown never traps you inside: you can resurface the instant you reach an unwatched spot.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker
	name = "Последнее пристанище смотрителя"
	desc = "Скрывает вас в Убежище Смотрителя, делая прозрачным и неосязаемым. \
			Войти можно, только пока вас никто не видит; выйти — лишь там, где вас никто не видит. \
			В убежище вы неуязвимы, но не можете действовать."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "caretaker"
	base_cooldown = 2 SECONDS
	invalid_turf_message = "За вами наблюдают — вы не можете скрыться!"
	jaunt_type = /obj/effect/dummy/spell_jaunt/caretaker
	jaunt_hand_type = /obj/item/space_crawl/caretaker
	// One "locked door / turning key" sound for both submerging into and resurfacing from the Refuge.
	jaunt_in_sound = 'sound/magic/heretic/caretaker_lock.ogg'
	jaunt_out_sound = 'sound/magic/heretic/caretaker_lock.ogg'


/// The Refuge's "valid turf" is any spot where no conscious onlooker can see us. Used for both entering
/// (while we are visible) and resurfacing (checks the spot we would reappear on).
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/is_valid_turf(mob/user = usr)
	var/turf/our_turf = get_turf(user)
	if(!our_turf)
		return FALSE
	// Gather every living onlooker that could POSSIBLY see this turf (max viewport radius), then defer to each
	// watcher's OWN client.view for the real line-of-sight test - so a classic-view player 8 tiles away (who
	// genuinely can't see us) won't block the Refuge, but an ultrawide one at that distance will. view() also
	// respects walls/opacity, so a watcher behind a wall doesn't count.
	for(var/mob/living/watcher in range(CARETAKER_MAX_WATCH_RANGE, our_turf))
		if(watcher == user || watcher.stat == DEAD || !watcher.client)
			continue
		if(our_turf in view(watcher.client.view, watcher))
			return FALSE
	return TRUE


// The in-person watcher test above is cheap, so the parent runs it on every button-status refresh (each move,
// and each SSfastprocess tick while on cooldown). The camera/AI sweep is heavier, so we DON'T put it there -
// instead can_cast() runs it only on a genuine cast attempt (show_message), never on a button repaint.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(show_message && is_watched_by_camera(get_turf(user)))
		to_chat(user, span_warning(invalid_turf_message))
		return FALSE


/// TRUE if the AI, or anyone actively driving a camera console, could currently see this turf through a camera.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/proc/is_watched_by_camera(turf/our_turf)
	// Cheap gate first: if no working camera covers this spot at all, no camera-watcher can possibly see it.
	if(!GLOB.cameranet.checkTurfVis(our_turf))
		return FALSE
	// An AI only actually sees what's around its camera eye RIGHT NOW (not the whole net at once), so block only
	// when this turf is inside an AI's current view (and camera-covered, per the checkTurfVis gate above).
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(!ai.client || ai.stat == DEAD)
			continue
		var/mob/camera/aiEye/eye = ai.eyeobj
		if(isnull(eye))
			continue
		if(our_turf in view(ai.client.view, eye))
			return TRUE
	// Advanced camera consoles relocate the operator's own perspective into the camera eye.
	for(var/mob/watcher as anything in GLOB.camera_console_watchers)
		if(watcher.client)
			return TRUE
	// Basic security monitors: a working camera that can see us AND is currently being watched on a console.
	for(var/obj/machinery/camera/cam in range(CARETAKER_MAX_WATCH_RANGE, our_turf))
		if(!length(cam.computers_watched_by) || !cam.can_use())
			continue
		if(our_turf in view(cam.view_range, cam))
			return TRUE
	return FALSE


/// Jaunt holder for the Caretaker's Refuge. The holder itself is invisible; this only defines the
/// position-indicator the jaunter sees (a pulsing eldritch crystal, in icons/effects/eldritch.dmi).
/obj/effect/dummy/spell_jaunt/caretaker
	phased_mob_icon = 'icons/effects/eldritch.dmi'
	phased_mob_icon_state = "caretaker"
	movespeed = 0


/// Renamed jaunt "hands" for the Refuge - same purpose as the Space Crawl hands (block all hand use while
/// phased), just flavoured for the Caretaker instead of reading "космический сдвиг".
/obj/item/space_crawl/caretaker
	name = "нечестивая дымка"
	desc = "Пока вы скрыты в Убежище Смотрителя, ваши руки бесплотны и ни на что не способны."


/obj/item/space_crawl/caretaker/get_ru_names()
	return alist(
		NOMINATIVE = "нечестивая дымка",
		GENITIVE = "нечестивой дымки",
		DATIVE = "нечестивой дымке",
		ACCUSATIVE = "нечестивую дымку",
		INSTRUMENTAL = "нечестивой дымкой",
		PREPOSITIONAL = "нечестивой дымке",
	)

#undef CARETAKER_MAX_WATCH_RANGE
