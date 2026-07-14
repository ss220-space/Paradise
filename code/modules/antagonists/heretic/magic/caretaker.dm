#define CARETAKER_MAX_WATCH_RANGE 9
#define CARETAKER_WATCH_CACHE_TIME (0.5 SECONDS)

/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker
	name = "Последнее Пристанище Смотрителя"
	desc = "Скрывает вас в Убежище Смотрителя, делая прозрачным и неосязаемым. \
			Войти можно, только пока вас никто не видит; выйти — лишь там, где вас никто не видит. \
			В убежище вы неуязвимы, но не можете действовать."
	action_icon_state = "caretaker"
	base_cooldown = 2 SECONDS
	invalid_turf_message = "За вами наблюдают — вы не можете скрыться!"
	jaunt_type = /obj/effect/dummy/spell_jaunt/caretaker
	jaunt_hand_type = /obj/item/space_crawl/caretaker
	jaunt_in_sound = 'sound/magic/heretic/caretaker_lock.ogg'
	jaunt_out_sound = 'sound/magic/heretic/caretaker_lock.ogg'
	var/cached_verdict
	var/turf/cached_turf
	var/cache_expires = 0


/// The Refuge's "valid turf" is any spot where no conscious onlooker can see us. Used for both entering
/// (while we are visible) and resurfacing (checks the spot we would reappear on).
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/is_valid_turf(mob/user = usr)
	var/turf/our_turf = get_turf(user)
	if(!our_turf)
		return FALSE
	if(our_turf == cached_turf && world.time < cache_expires)
		return cached_verdict
	cached_turf = our_turf
	cache_expires = world.time + CARETAKER_WATCH_CACHE_TIME
	cached_verdict = TRUE
	for(var/mob/living/watcher in range(CARETAKER_MAX_WATCH_RANGE, our_turf))
		if(watcher == user || watcher.stat == DEAD || !watcher.client)
			continue
		if(our_turf in view(watcher.client.view, watcher))
			cached_verdict = FALSE
			break
	return cached_verdict


/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(show_message && is_watched_by_camera(get_turf(user)))
		to_chat(user, span_warning(invalid_turf_message))
		return FALSE


/// TRUE if the AI, or anyone actively driving a camera console, could currently see this turf through a camera.
/// "Actively" is the operative word: a console that is merely powered on / has a camera selected does NOT count -
/// there has to be a live, conscious onlooker whose feed actually shows this turf right now. Otherwise a ghost
/// who peeked at a camera (which leaks into computers_watched_by, never cleared on a non-living close) or an
/// operator staring at a different part of the station would lock the heretic out of the Refuge forever.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/proc/is_watched_by_camera(turf/our_turf)
	if(!GLOB.cameranet.checkTurfVis(our_turf))
		return FALSE
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(!ai.client || ai.stat == DEAD)
			continue
		var/mob/camera/aiEye/eye = ai.eyeobj
		if(isnull(eye))
			continue
		if(our_turf in view(ai.client.view, eye))
			return TRUE
	for(var/mob/watcher as anything in GLOB.camera_console_watchers)
		if(!watcher.client || !isliving(watcher))
			continue
		var/mob/living/living_watcher = watcher
		if(living_watcher.stat == DEAD)
			continue
		var/atom/movable/eye = watcher.remote_control
		if(isnull(eye))
			continue
		if(our_turf in view(watcher.client.view, eye))
			return TRUE
	for(var/obj/machinery/camera/cam in range(CARETAKER_MAX_WATCH_RANGE, our_turf))
		if(!length(cam.computers_watched_by) || !cam.can_use())
			continue
		if(!has_live_console_watcher(cam))
			continue
		if(our_turf in view(cam.view_range, cam))
			return TRUE
	return FALSE


/// TRUE if any console currently showing this camera has a live, conscious operator present at it. We can't trust
/// computers_watched_by alone: it only means "a console has this camera selected," and it leaks (a ghost peeking
/// at the feed adds the console but a non-living ui_close never removes it), so we re-check the console's own
/// concurrent_users for a real watcher.
/obj/effect/proc_holder/spell/jaunt/space_crawl/caretaker/proc/has_live_console_watcher(obj/machinery/camera/cam)
	for(var/obj/machinery/computer/security/console as anything in cam.computers_watched_by)
		for(var/uid in console.concurrent_users)
			var/mob/living/operator = locateUID(uid)
			if(istype(operator) && operator.client && operator.stat != DEAD)
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
#undef CARETAKER_WATCH_CACHE_TIME
