/datum/orbit_menu
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

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
			var/ref = params["ref"]

			var/atom/movable/poi = (locate(ref) in GLOB.mob_list) || (locate(ref) in GLOB.poi_list)
			if(poi == null)
				. = TRUE
				return
			owner.ManualFollow(poi)
			. = TRUE
		if("refresh")
			update_static_data(owner, ui)
			. = TRUE

/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()
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

	var/list/pois = getpois(mobs_only = FALSE, skip_mindless = FALSE)
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

		serialized["ref"] = "\ref[M]"
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
					// Not-very-datumized antags follow
					// Associative list of antag name => whether this mind is this antag
					if(SSticker && SSticker.mode)
						other_antags += list(
							"Жертвы абдукторов — ([length(SSticker.mode.abductees)])" = (mind in SSticker.mode.abductees),
							"Абдукторы — ([length(SSticker.mode.abductors)])" = (mind in SSticker.mode.abductors),
							"Демоны — ([length(SSticker.mode.demons)])" = (mind in SSticker.mode.demons),
							"Ивент роли — ([length(SSticker.mode.eventmiscs)])" = (mind in SSticker.mode.eventmiscs),
							"Культисты [SSticker.cultdat.entity_name] — ([length(SSticker.mode.cult)])" = (mind in SSticker.mode.cult),
							"Ядерные оперативники — ([length(SSticker.mode.syndicates)])" = (mind in SSticker.mode.syndicates),
							"Культисты Ратвара — ([length(SSticker.mode.clockwork_cult)])" = (mind in SSticker.mode.clockwork_cult),
							"Революционеры — ([length(SSticker.mode.revolutionaries)])" = (mind in SSticker.mode.revolutionaries),
							"Главы революции — ([length(SSticker.mode.head_revolutionaries)])" = (mind in SSticker.mode.head_revolutionaries),
							"Рабы теней — ([length(SSticker.mode.shadowling_thralls)])" = (mind in SSticker.mode.shadowling_thralls),
							"Тени — ([length(SSticker.mode.shadows)])" = (mind in SSticker.mode.shadows),
							"Маги — ([length(SSticker.mode.wizards)])" = (mind in SSticker.mode.wizards),
							"Ученики магов — ([length(SSticker.mode.apprentices)])" = (mind in SSticker.mode.apprentices),
							"Торговцы — ([length(SSticker.mode.traders)])" = (mind in SSticker.mode.traders),
							"Морфы — ([length(SSticker.mode.morphs)])" = (mind in SSticker.mode.morphs),
							"Свармеры — ([length(SSticker.mode.swarmers)])" = (mind in SSticker.mode.swarmers),
							"Голопаразиты — ([length(SSticker.mode.guardians)])" = (mind in SSticker.mode.guardians),
							"Ревенанты — ([length(SSticker.mode.revenants)])" = (mind in SSticker.mode.revenants),
							"Воксы рейдеры — ([length(SSticker.mode.raiders)])" = (mind in SSticker.mode.raiders),
							"Супергерои — ([length(SSticker.mode.superheroes)])" = (mind in SSticker.mode.superheroes),
							"Суперзлодеи — ([length(SSticker.mode.supervillains)])" = (mind in SSticker.mode.supervillains),
							"Отряд Смерти — ([length(SSticker.mode.deathsquad)])" = (mind in SSticker.mode.deathsquad),
							"Хонксквад — ([length(SSticker.mode.honksquad)])" = (mind in SSticker.mode.honksquad),
							"Ударный Отряд Синдиката — ([length(SSticker.mode.sst)])" = (mind in SSticker.mode.sst),
							"Диверсионный Отряд Синдиката — ([length(SSticker.mode.sit)])" = (mind in SSticker.mode.sit),
						)

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
