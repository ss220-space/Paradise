/datum/orbit_menu
	var/mob/dead/observer/owner
	var/auto_observe = FALSE

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/orbit_menu/Destroy(force)
	var/owner_menu = owner?.orbit_menu
	if(owner_menu && owner_menu == src)
		owner.orbit_menu = null
	owner = null
	return ..()

/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Orbit", "Orbit")
		ui.open()

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("orbit")
			handle_orbit_action(params)
			return TRUE

		if("refresh")
			update_static_data(owner, ui)
			return TRUE

		if("toggle_observe")
			toggle_auto_observe()
			return TRUE
	return FALSE

/datum/orbit_menu/proc/handle_orbit_action(list/params)
	var/ref = params["ref"]
	var/atom/movable/poi = locateUID(ref)

	if(!poi)
		return

	var/atom/movable/cached_target = owner.orbiting
	owner.orbiting = null
	owner.reset_perspective(null)
	owner.orbiting = cached_target

	if(auto_observe)
		var/mob/eye_mob = poi
		if(istype(eye_mob) && eye_mob.client)
			owner.handle_when_autoobserve_move()
			owner.do_observe(eye_mob)
		else
			owner.handle_when_autoobserve_move()
			to_chat(owner, span_alert("Объект, за которым Вы следуете, не имеет за собой игрока! Показать инвентарь <b>невозможно</b>."))

	owner.ManualFollow(poi)

/datum/orbit_menu/proc/toggle_auto_observe()
	auto_observe = !auto_observe

	if(!owner.orbiting)
		owner.handle_when_autoobserve_move()
		return

	if(auto_observe)
		var/mob/eye_mob = owner.orbiting
		if(istype(eye_mob) && eye_mob.client)
			owner.do_observe(eye_mob)
			return
		else
			to_chat(owner, span_alert("Объект, за которым Вы следуете, не имеет за собой игрока. Показать инвентарь <b>невозможно</b>."))

	var/atom/movable/eye_mob = owner.orbiting
	owner.orbiting = null
	owner.handle_when_autoobserve_move()
	owner.orbiting = eye_mob

/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()
	data["auto_observe"] = auto_observe
	return data

/datum/orbit_menu/ui_static_data(mob/user)
	var/list/data = list()

	var/list/alive = list()
	var/list/highlights = list()
	var/list/antagonists = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()
	var/length_of_ghosts = length(get_observers())

	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = TRUE)
	for(var/name in pois)
		var/mob/M = pois[name]
		if(name == null)
			if(pois[name] && M.type)
				stack_trace("getpois returned something under a null name. Type: [M.type]")
			else
				stack_trace("getpois returned a null value")
			continue

		var/list/serialized = list()
		serialized["name"] = "[name]" // stringify it; If it's null or something - we'd like to know it and fix getpois()
		if(serialized["name"] != name)
			stack_trace("getpois returned something under a non-string name [name] - [pois[name]] - [M.type]")
			continue

		serialized["ref"] = M.UID()
		var/orbiters = 0
		if(ismob(M))
			orbiters = M.ghost_orbiting

		if(orbiters > 0)
			serialized["orbiters"] = orbiters

		if(istype(M))
			if(isnewplayer(M))  // People in the lobby screen; only have their ckey as a name.
				continue
			if(isobserver(M))
				ghosts += list(serialized)
			else if(M.mind == null)
				npcs += list(serialized)
			else if(M.stat == DEAD)
				dead += list(serialized)
			else
				if(orbiters >= 0.2 * length_of_ghosts) // They're important if 20% of observers are watching them
					highlights += list(serialized)
				alive += list(serialized)

				var/datum/mind/mind = M.mind
				var/list/other_antags = list()

				for(var/team_type in GLOB.antagonist_teams)
					var/datum/team/team = GLOB.antagonist_teams[team_type]
					if(!team.need_antag_hud)
						other_antags += list("[team.name] — ([team.alife_members_count()])" = (mind in team.members))
				if(user.antagHUD)
					// If a mind is many antags at once, we'll display all of them, each
					// under their own antag sub-section.
					// This is arguably better, than picking one of the antag datums at random.

					// Traitors - the only antags in `.antag_datums` at the time of writing.
					for(var/_A in mind.antag_datums)
						var/datum/antagonist/A = _A
						if(!A.show_in_orbit)
							continue
						var/antag_serialized = serialized.Copy()
						antag_serialized["antag"] = A.name
						antagonists += list(antag_serialized)

					for(var/team_type in GLOB.antagonist_teams)
						var/datum/team/team = GLOB.antagonist_teams[team_type]
						if(team.need_antag_hud)
							other_antags += list("[team.name] — ([team.alife_members_count()])" = (mind in team.members))

				for(var/antag_name in other_antags)
					var/is_antag = other_antags[antag_name]
					if(!is_antag)
						continue
					var/list/antag_serialized = serialized.Copy()
					antag_serialized["antag"] = antag_name
					antagonists += list(antag_serialized)

		else
			if(length(orbiters) >= 0.2 * length_of_ghosts) // If a bunch of people are orbiting an object, like the nuke disk.
				highlights += list(serialized)
			misc += list(serialized)

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["highlights"] = highlights
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	return data
