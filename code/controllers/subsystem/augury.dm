SUBSYSTEM_DEF(augury)
	name = "Augury"
	ss_flags = SS_NO_INIT|SS_HIBERNATE

	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/watchers = list()
	var/list/doombringers = list()
	var/list/storm_sources = list()

/datum/controller/subsystem/augury/PreInit()
	. = ..()
	hibernate_checks = list(
		NAMEOF(src, watchers),
		NAMEOF(src, doombringers),
		NAMEOF(src, storm_sources),
	)

/datum/controller/subsystem/augury/stat_entry(msg)
	msg = "W:[length(watchers)]|D:[length(doombringers)]"
	return ..()

/datum/controller/subsystem/augury/proc/register_doom(atom/A, severity)
	doombringers[A] = severity
	RegisterSignal(A, COMSIG_QDELETING, PROC_REF(unregister_doom))

/datum/controller/subsystem/augury/proc/unregister_doom(atom/A)
	SIGNAL_HANDLER
	UnregisterSignal(A, COMSIG_QDELETING)
	doombringers -= A

/// Registers an event source that keeps the tracking alert up even between meteor waves
/datum/controller/subsystem/augury/proc/register_storm(datum/source)
	if(!source || (source in storm_sources))
		return
	storm_sources += source
	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(unregister_storm))

/datum/controller/subsystem/augury/proc/unregister_storm(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	storm_sources -= source

/datum/controller/subsystem/augury/fire()
	var/biggest_doom = null
	var/biggest_threat = null

	for(var/db in doombringers)
		var/datum/d = db
		if(!d || QDELETED(d))
			doombringers -= d
			continue
		var/threat = doombringers[d]
		if((biggest_threat == null) || (biggest_threat < threat))
			biggest_doom = d
			biggest_threat = threat

	for(var/db in storm_sources)
		var/datum/d = db
		if(!d || QDELETED(d))
			storm_sources -= d

	if(length(doombringers) || length(storm_sources))
		for(var/i in GLOB.player_list)
			if(!isobserver(i))
				continue
			var/mob/dead/observer/ghost = i
			var/atom/movable/screen/alert/augury/tracking_alert = ghost.throw_alert(ALERT_AUGURY, /atom/movable/screen/alert/augury)
			tracking_alert?.update_tracking_state()
	else
		for(var/w in watchers)
			var/mob/dead/observer/tracked = w
			if(istype(tracked))
				tracked.clear_alert(ALERT_AUGURY)
		watchers.Cut()
		for(var/i in GLOB.player_list)
			if(isobserver(i))
				var/mob/dead/observer/ghost = i
				ghost.clear_alert(ALERT_AUGURY)

	for(var/w in watchers)
		var/mob/dead/observer/tracked = w
		if(QDELETED(tracked))
			watchers -= w
			continue
		if(biggest_doom && (!tracked.orbiting || tracked.orbiting != biggest_doom))
			tracked.ManualFollow(biggest_doom)

/**
 * Toggleable alert for observers, thrown while something dangerous (meteors, the immovable rod, etc) is around.
 * Clicking it toggles auto-follow of the threat.
 */
/atom/movable/screen/alert/augury
	name = "Авто-отслеживание обломков"
	desc = "Нажмите, чтобы включить или выключить автоматическое отслеживание обломков."
	timeout = 0
	click_master = FALSE
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// Outline overlay shown while tracking is enabled - the same one used by candidate poll alerts
	var/mutable_appearance/tracking_overlay

/atom/movable/screen/alert/augury/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance('icons/obj/meteor.dmi', "flaming"))
	tracking_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "selector", layer = FLOAT_LAYER)

/atom/movable/screen/alert/augury/Destroy()
	tracking_overlay = null
	return ..()

/atom/movable/screen/alert/augury/Click(location, control, params)
	. = ..()
	if(!. || !SSaugury || !isobserver(owner))
		return FALSE

	if(SSaugury.watchers[owner])
		SSaugury.watchers -= owner
		to_chat(owner, span_notice("Вы больше не отслеживаете обломки."))
	else
		SSaugury.watchers[owner] = TRUE
		to_chat(owner, span_notice("Вы теперь автоматически отслеживаете обломки."))

	update_tracking_state()
	return TRUE

/atom/movable/screen/alert/augury/proc/update_tracking_state()
	cut_overlay(tracking_overlay)
	if(SSaugury?.watchers[owner])
		add_overlay(tracking_overlay)
