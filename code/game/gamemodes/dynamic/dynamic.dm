GLOBAL_VAR(dynamic_forced_tier)
GLOBAL_LIST_EMPTY(dynamic_queued_rulesets)
GLOBAL_LIST_EMPTY(dynamic_disabled_rulesets)

/datum/game_mode/dynamic
	name = "dynamic"
	config_tag = "dynamic"
	required_players = 10
	required_enemies = 1
	var/datum/dynamic_tier/current_tier
	var/list/datum/dynamic_ruleset/executed_rulesets = list()
	var/list/rulesets_to_spawn = list()
	COOLDOWN_DECLARE(midround_cooldown)
	COOLDOWN_DECLARE(latejoin_cooldown)

/datum/game_mode/dynamic/Destroy(force)
	QDEL_LIST(executed_rulesets)
	QDEL_NULL(current_tier)
	return ..()

/datum/game_mode/dynamic/announce()
	to_chat(world, "<b>Текущий режим игры — Динамический!</b>")
	to_chat(world, "<b>Никто не знает, что именно ждёт станцию в эту смену. Будьте готовы ко всему.</b>")

/datum/game_mode/dynamic/pre_setup()
	var/population_size = num_players()
	pick_tier(population_size)

	for(var/datum/dynamic_ruleset/roundstart/ruleset as anything in pick_rulesets(DYNAMIC_ROUNDSTART, /datum/dynamic_ruleset/roundstart, population_size))
		executed_rulesets += ruleset
		for(var/datum/mind/selected as anything in ruleset.selected_minds)
			add_game_logs("has been selected for [ruleset.config_tag]", selected.current)

	if(!length(executed_rulesets))
		add_game_logs("Dynamic: no roundstart ruleset could be prepared.")

	return TRUE

/datum/game_mode/dynamic/post_setup()
	to_chat(world, get_advisory_report())
	for(var/datum/dynamic_ruleset/ruleset as anything in executed_rulesets)
		ruleset.execute()
	COOLDOWN_START(src, midround_cooldown, current_tier.get_time_threshold(DYNAMIC_MIDROUND))
	COOLDOWN_START(src, latejoin_cooldown, current_tier.get_time_threshold(DYNAMIC_LATEJOIN))
	return ..()

/datum/game_mode/dynamic/process()
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return PROCESS_KILL
	if(rulesets_to_spawn[DYNAMIC_MIDROUND] <= 0 || !COOLDOWN_FINISHED(src, midround_cooldown))
		return
	COOLDOWN_START(src, midround_cooldown, current_tier.get_execution_cooldown(DYNAMIC_MIDROUND))
	try_spawn_midround()

/datum/game_mode/dynamic/latespawn(mob/player)
	if(!player.mind)
		return
	if(try_spawn_queued_latejoin(player.mind))
		return
	if(rulesets_to_spawn[DYNAMIC_LATEJOIN] <= 0 || !COOLDOWN_FINISHED(src, latejoin_cooldown))
		return
	try_spawn_latejoin(player.mind)

/datum/game_mode/dynamic/proc/pick_tier(population_size)
	var/list/tier_weights = list()
	var/list/weight_overrides = CONFIG_GET(keyed_list/dynamic_tier_weights)
	var/list/min_pop_overrides = CONFIG_GET(keyed_list/dynamic_tier_min_pop)
	for(var/datum/dynamic_tier/tier_type as anything in subtypesof(/datum/dynamic_tier))
		var/tier_min_pop = tier_type::min_pop
		if(tier_type::config_tag in min_pop_overrides)
			tier_min_pop = min_pop_overrides[tier_type::config_tag]
		if(population_size < tier_min_pop)
			continue
		var/tier_weight = tier_type::weight
		if(tier_type::config_tag in weight_overrides)
			tier_weight = weight_overrides[tier_type::config_tag]
		if(tier_weight <= 0)
			continue
		tier_weights[tier_type] = tier_weight

	var/picked_tier = GLOB.dynamic_forced_tier || pick_weight_classic(tier_weights) || /datum/dynamic_tier/greenshift
	current_tier = new picked_tier

	for(var/category in list(DYNAMIC_ROUNDSTART, DYNAMIC_MIDROUND, DYNAMIC_LATEJOIN))
		rulesets_to_spawn[category] = current_tier.get_ruleset_count(category, population_size)

	add_game_logs("Dynamic: tier [current_tier.name], population [population_size], rulesets \
		[rulesets_to_spawn[DYNAMIC_ROUNDSTART]]/[rulesets_to_spawn[DYNAMIC_MIDROUND]]/[rulesets_to_spawn[DYNAMIC_LATEJOIN]]")

/datum/game_mode/dynamic/allow_antag_events()
	return current_tier.tier != DYNAMIC_TIER_GREEN

/datum/game_mode/dynamic/proc/get_advisory_report()
	var/shown_tier = current_tier.tier
	if(shown_tier == DYNAMIC_TIER_GREEN)
		return current_tier.advisory_report
	if(prob(ADVISORY_REPORT_WRONG_TIER_CHANCE))
		shown_tier = pick(list(DYNAMIC_TIER_LOW, DYNAMIC_TIER_LOWMEDIUM, DYNAMIC_TIER_MEDIUMHIGH, DYNAMIC_TIER_HIGH) - current_tier.tier)
	else if(prob(ADVISORY_REPORT_NEAR_TIER_CHANCE))
		shown_tier = clamp(current_tier.tier + pick(-1, 1), DYNAMIC_TIER_LOW, DYNAMIC_TIER_HIGH)

	for(var/datum/dynamic_tier/tier_type as anything in subtypesof(/datum/dynamic_tier))
		if(tier_type::tier == shown_tier)
			return tier_type::advisory_report
	return current_tier.advisory_report

/datum/game_mode/dynamic/proc/get_weighted_rulesets(ruleset_family, population_size)
	. = list()
	for(var/ruleset_type in subtypesof(ruleset_family))
		if(ruleset_type in GLOB.dynamic_disabled_rulesets)
			continue
		var/datum/dynamic_ruleset/ruleset = new ruleset_type
		var/ruleset_weight = ruleset.get_weight(population_size, current_tier.tier)
		for(var/datum/dynamic_ruleset/executed as anything in executed_rulesets)
			if(current_tier.tier != DYNAMIC_TIER_HIGH && (ruleset.ruleset_flags & RULESET_HIGH_IMPACT) && (executed.ruleset_flags & RULESET_HIGH_IMPACT))
				ruleset_weight = 0
				break
			if(!istype(executed, ruleset_type))
				continue
			if(!ruleset.repeatable)
				ruleset_weight = 0
				break
			ruleset_weight -= ruleset.repeatable_weight_decrease
		if(ruleset_weight <= 0)
			qdel(ruleset)
			continue
		.[ruleset] = ruleset_weight

/datum/game_mode/dynamic/proc/pick_rulesets(category, ruleset_family, population_size)
	. = take_queued_rulesets(ruleset_family, population_size)
	if(length(.))
		rulesets_to_spawn[category] = max(rulesets_to_spawn[category] - length(.), 0)
		return

	var/list/weighted_rulesets = get_weighted_rulesets(ruleset_family, population_size)

	while(rulesets_to_spawn[category] > 0 && length(weighted_rulesets))
		var/datum/dynamic_ruleset/roundstart/picked = pick_weight_classic(weighted_rulesets)
		var/picked_weight = weighted_rulesets[picked]
		weighted_rulesets -= picked

		if(picked.solo && length(.))
			qdel(picked)
			continue

		if(!picked.prepare_execution(population_size))
			add_game_logs("Dynamic: [picked.config_tag] was picked, but did not run - [picked.log_data]")
			qdel(picked)
			continue

		rulesets_to_spawn[category]--
		. += picked

		if(picked.solo)
			break

		if(current_tier.tier != DYNAMIC_TIER_HIGH && (picked.ruleset_flags & RULESET_HIGH_IMPACT))
			for(var/datum/dynamic_ruleset/other as anything in weighted_rulesets.Copy())
				if(!(other.ruleset_flags & RULESET_HIGH_IMPACT))
					continue
				weighted_rulesets -= other
				qdel(other)

		if(!picked.repeatable)
			continue

		var/repeat_weight = picked_weight - picked.repeatable_weight_decrease
		if(repeat_weight > 0)
			weighted_rulesets[new picked.type] = repeat_weight

	QDEL_LIST(weighted_rulesets)

/datum/game_mode/dynamic/proc/try_spawn_midround()
	var/population_size = num_station_players()
	var/list/weighted_rulesets = get_weighted_rulesets(/datum/dynamic_ruleset/midround, population_size)
	var/datum/dynamic_ruleset/midround/picked = pick_weight_classic(weighted_rulesets)
	if(!picked)
		add_game_logs("Dynamic: no midround ruleset available.")
		QDEL_LIST(weighted_rulesets)
		return FALSE

	weighted_rulesets -= picked
	QDEL_LIST(weighted_rulesets)

	if(!picked.prepare_execution(population_size))
		add_game_logs("Dynamic: midround [picked.config_tag] did not run - [picked.log_data]")
		qdel(picked)
		return FALSE

	rulesets_to_spawn[DYNAMIC_MIDROUND]--
	executed_rulesets += picked
	picked.execute()
	for(var/datum/mind/selected as anything in picked.selected_minds)
		message_admins("Dynamic: [ADMIN_LOOKUPFLW(selected.current)] has been selected for [picked.config_tag].")
		add_game_logs("has been selected for [picked.config_tag]", selected.current)
	return TRUE

/datum/game_mode/dynamic/proc/try_spawn_latejoin(datum/mind/joiner)
	var/population_size = num_station_players()
	var/list/weighted_rulesets = get_weighted_rulesets(/datum/dynamic_ruleset/latejoin, population_size)
	while(length(weighted_rulesets))
		var/datum/dynamic_ruleset/latejoin/picked = pick_weight_classic(weighted_rulesets)
		weighted_rulesets -= picked
		picked.joiner = joiner
		if(!picked.prepare_execution(population_size))
			qdel(picked)
			continue

		rulesets_to_spawn[DYNAMIC_LATEJOIN]--
		COOLDOWN_START(src, latejoin_cooldown, current_tier.get_execution_cooldown(DYNAMIC_LATEJOIN))
		executed_rulesets += picked
		picked.execute()
		message_admins("Dynamic: [ADMIN_LOOKUPFLW(joiner.current)] has been selected for [picked.config_tag].")
		add_game_logs("has been selected for [picked.config_tag]", joiner.current)
		break

	QDEL_LIST(weighted_rulesets)

/datum/game_mode/dynamic/proc/take_queued_rulesets(ruleset_family, population_size)
	. = list()
	for(var/ruleset_type in GLOB.dynamic_queued_rulesets.Copy())
		if(!ispath(ruleset_type, ruleset_family))
			continue
		GLOB.dynamic_queued_rulesets -= ruleset_type
		var/datum/dynamic_ruleset/ruleset = new ruleset_type
		if(!ruleset.prepare_execution(population_size))
			add_game_logs("Dynamic: queued [ruleset.config_tag] did not run - [ruleset.log_data]")
			qdel(ruleset)
			continue
		. += ruleset

/datum/game_mode/dynamic/proc/try_spawn_queued_latejoin(datum/mind/joiner)
	var/population_size = num_station_players()
	for(var/ruleset_type in GLOB.dynamic_queued_rulesets.Copy())
		if(!ispath(ruleset_type, /datum/dynamic_ruleset/latejoin))
			continue
		var/datum/dynamic_ruleset/latejoin/queued = new ruleset_type
		queued.joiner = joiner
		if(!queued.prepare_execution(population_size))
			qdel(queued)
			continue
		GLOB.dynamic_queued_rulesets -= ruleset_type
		executed_rulesets += queued
		queued.execute()
		message_admins("Dynamic: [ADMIN_LOOKUPFLW(joiner.current)] has been selected for queued [queued.config_tag].")
		add_game_logs("has been selected for [queued.config_tag]", joiner.current)
		return TRUE
	return FALSE

/datum/game_mode/dynamic/proc/force_ruleset(ruleset_type, mob/admin)
	var/datum/dynamic_ruleset/forced = new ruleset_type
	if(!forced.prepare_execution(num_station_players()))
		to_chat(admin, span_warning("Правило [forced.config_tag] не запустилось: [forced.log_data]."))
		qdel(forced)
		return FALSE

	executed_rulesets += forced
	forced.execute()
	for(var/datum/mind/selected as anything in forced.selected_minds)
		message_admins("Dynamic: [ADMIN_LOOKUPFLW(selected.current)] has been selected for forced [forced.config_tag].")
		add_game_logs("has been selected for [forced.config_tag]", selected.current)
	return TRUE
