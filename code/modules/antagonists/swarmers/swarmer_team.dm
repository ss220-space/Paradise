/**
 * Global proc to adjust metallic swarmer resource.
 *
 * Set use_modifier to TRUE if you want to use the team metal gather modifier.
 * Returns FALSE if amount was negative and the result is smaller than zero.
 * Returns TRUE otherwise.
 */
/proc/adjust_swarmer_metallic_resources(amount, use_modifier = FALSE)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team.swarmer_core) // Core is the storage
		return FALSE
	if(use_modifier) // Resource storage modifiers (used on swarmer metal gathering)
		amount *= team.metal_modifier
	if(team.metallic_resources + amount < 0)
		return FALSE
	team.metallic_resources = max(team.metallic_resources + amount, 0) // extra precaution
	return TRUE

/**
 * Global proc to adjust organic swarmer resource.
 *
 * Returns FALSE if amount was negative and the result is smaller than zero.
 * Returns TRUE otherwise.
 */
/proc/adjust_swarmer_organic_resources(amount)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team.swarmer_core) // Core is the storage
		return FALSE
	if(team.organic_resources + amount < 0)
		return FALSE
	team.organic_resources = max(team.organic_resources + amount, 0) // extra precaution
	return TRUE

/// How many metallic resources swarmers get on core init
#define METALLIC_START_RESOURCES 90
/// Delay between destroying swarmer mobs/structures on core destroy
#define DESTROY_DELAY 0.1 SECONDS

/datum/team/swarmer_team
	name = "Свармеры"
	antag_datum_type = /datum/antagonist/swarmer
	need_antag_hud = FALSE
	/// Reference to our swarmer core.
	var/obj/structure/swarmer/core/swarmer_core
	/// Amount of inorganic resources we currently have
	var/metallic_resources = 0
	/// Amount of organic resources we currently have
	var/organic_resources = 0
	/// Modifier of metal gatherings by swarmers (not structures)
	var/metal_modifier = 1
	/// Main objective given to all swarmers
	var/datum/objective/swarmer_goal/swarmer_objective
	/// Have we made an announcement about mega-swarmer already or not
	var/made_announcement = FALSE
	/// Cooldown system for messages on core integrity change
	COOLDOWN_DECLARE(message_cooldown)

/datum/team/swarmer_team/New(list/starting_members)
	..()
	RegisterSignal(src, COMSIG_SWARMER_CORE_INITIALIZED, PROC_REF(on_core_init))
	RegisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED, PROC_REF(on_core_destroy))
	RegisterSignal(src, COMSIG_SWARMER_TRY_PROCESS_ORGANIC_ITEM, PROC_REF(try_process_organic))
	RegisterSignal(src, COMSIG_SWARMER_TRY_ANALYZE_MOB, PROC_REF(try_analyze_mob))
	RegisterSignal(src, COMSIG_SWARMER_STORAGE_INITIALIZED, PROC_REF(increase_modifier))
	RegisterSignal(src, COMSIG_SWARMER_STORAGE_DESTROYED, PROC_REF(decrease_modifier))
	RegisterSignal(src, COMSIG_MEGA_SWARMER_CORE_SPAWN, PROC_REF(on_mega_swarmer_spawn))
	swarmer_objective = new(team_to_join = src)
	add_objective_to_members(swarmer_objective)

/datum/team/swarmer_team/Destroy(force)
	if(swarmer_core) // signals registered on core init
		UnregisterSignal(swarmer_core, COMSIG_OBJ_INTEGRITY_CHANGED)
		UnregisterSignal(swarmer_core, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src, COMSIG_SWARMER_CORE_INITIALIZED)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED)
	UnregisterSignal(src, COMSIG_SWARMER_TRY_PROCESS_ORGANIC_ITEM)
	UnregisterSignal(src, COMSIG_SWARMER_TRY_ANALYZE_MOB)
	UnregisterSignal(src, COMSIG_SWARMER_STORAGE_INITIALIZED)
	UnregisterSignal(src, COMSIG_SWARMER_STORAGE_DESTROYED)
	UnregisterSignal(src, COMSIG_MEGA_SWARMER_CORE_SPAWN)
	QDEL_NULL(swarmer_objective)
	return ..()

/**
 * Signal proc sent on swarmer core init
 *
 * Sets swarmer_core variable, adjusts required resources,
 * registers required core signals.
 */
/datum/team/swarmer_team/proc/on_core_init(datum/source, obj/core)
	SIGNAL_HANDLER
	swarmer_core = core
	metallic_resources = METALLIC_START_RESOURCES
	RegisterSignal(swarmer_core, COMSIG_OBJ_INTEGRITY_CHANGED, PROC_REF(on_core_integrity_changed))
	RegisterSignal(swarmer_core, COMSIG_MOVABLE_MOVED, PROC_REF(on_core_moved))

/**
 * Signal proc sent on swarmer core destroy
 *
 * Sets resource vars to initial values, cleans
 * the core reference, unregisters some core based signals.
 */
/datum/team/swarmer_team/proc/on_core_destroy(datum/source)
	SIGNAL_HANDLER
	if(!swarmer_core) // Happens if someone shitspawned a second core with an existing core
		return
	UnregisterSignal(swarmer_core, COMSIG_OBJ_INTEGRITY_CHANGED)
	UnregisterSignal(swarmer_core, COMSIG_MOVABLE_MOVED)
	swarmer_core = null
	metallic_resources = 0
	organic_resources = 0
	INVOKE_ASYNC(src, PROC_REF(start_swarmers_destroying))

/**
 * Signal proc sent on swarmer core integrity change
 *
 * Sends a huge message in chat to all members on core being damaged with a cooldown.
 */
/datum/team/swarmer_team/proc/on_core_integrity_changed(datum/source, old_value, new_value)
	SIGNAL_HANDLER
	if(new_value >= old_value)
		return
	if(!COOLDOWN_FINISHED(src, message_cooldown))
		return

	COOLDOWN_START(src, message_cooldown, 3 SECONDS)
	var/area/core_area = get_area(swarmer_core)
	var/locname = initial(core_area.name)
	for(var/datum/mind/swarmer_mind as anything in members)
		var/mob/living/target = swarmer_mind?.current
		if(!target)
			continue
		target.balloon_alert(target, "повреждение ядра!")
		to_chat(target, span_swarmerboldlarge("Внимание: Обнаружено повреждение ядра! Местоположение: [locname]."))

/**
 * Signal proc sent on swarmer core being moved
 *
 * Sends a huge message in chat to all members on core being moved.
 */
/datum/team/swarmer_team/proc/on_core_moved(datum/source, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	var/area/core_area = get_area(swarmer_core)
	var/locname = initial(core_area.name)
	for(var/datum/mind/swarmer_mind as anything in members)
		var/mob/living/target = swarmer_mind?.current
		if(!target)
			continue
		target.balloon_alert(target, "перемещение ядра!")
		to_chat(target, span_swarmerboldlarge("Внимание: Обнаружено перемещение ядра! Новое местоположение: [locname]."))

/**
 * Signal proc used in organic processing (not mobs)
 *
 * Sends signals to organic processers one by one, if there are any, until
 * any signal returns TRUE.
 *
 * Returns TRUE, if any sent signal has return TRUE.
 * Returns FALSE otherwise.
 */
/datum/team/swarmer_team/proc/try_process_organic(datum/source, obj/item)
	SIGNAL_HANDLER
	for(var/obj/structure/swarmer/organic_processer/processer in GLOB.swarmer_objects)
		if(SEND_SIGNAL(processer, COMSIG_SWARMER_PROCESS_ORGANIC_ITEM_CHECK, item) & TRUE)
			return TRUE
	return FALSE

/**
 * Signal proc used in organic analyzing (mobs)
 *
 * Sends signals to organic analyzers one by one, if there are any, until
 * any signal returns TRUE.
 *
 * Returns TRUE, if any sent signal has return TRUE.
 * Returns FALSE otherwise.
 */
/datum/team/swarmer_team/proc/try_analyze_mob(datum/source, mob/living/target)
	SIGNAL_HANDLER
	for(var/obj/structure/swarmer/organic_analyzer/analyzer in GLOB.swarmer_objects)
		if(SEND_SIGNAL(analyzer, COMSIG_SWARMER_ANALYZE_MOB_CHECK, target) & TRUE)
			return TRUE
	return FALSE

/**
 * Signal proc from resource storage
 *
 * Increases metal resource modifier by [SWARMER_STORAGE_MODIFIER].
 * Has a limit of [SWARMER_STORAGE_MODIFIER_LIMIT]
 */
/datum/team/swarmer_team/proc/increase_modifier(datum/source)
	SIGNAL_HANDLER
	metal_modifier = min(metal_modifier + SWARMER_STORAGE_MODIFIER, SWARMER_STORAGE_MODIFIER_LIMIT)

/**
 * Signal proc from resource storage
 *
 * Decreases metal resource modifier by [SWARMER_STORAGE_MODIFIER].
 * Has a limit of 1.
 */
/datum/team/swarmer_team/proc/decrease_modifier(datum/source)
	SIGNAL_HANDLER
	metal_modifier = max(metal_modifier - SWARMER_STORAGE_MODIFIER, 1)

/**
 * Signal proc from mega-swarmer core spawn
 *
 * Completes swarmer objectives,
 * makes an announce to the station,
 * sets gamma code.
 */
/datum/team/swarmer_team/proc/on_mega_swarmer_spawn(datum/source, mob/swarmer)
	SIGNAL_HANDLER
	if(made_announcement)
		return
	made_announcement = TRUE
	swarmer_objective.completed = TRUE
	GLOB.major_announcement.announce(
		message = "Обнаружено появление \"Мега-Свармера\" на борту станции [station_name()]. Экипаж должен любой ценой остановить его до того, как станция перейдёт под их полный контроль.",
		new_title = ANNOUNCE_CCMSG_RU,
		new_sound = 'sound/AI/commandreport.ogg'
	)
	// gamma level will be kept until rounend, since there would still be swarmers and more mega-swarmer can spawn
	addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_GAMMA), 5 SECONDS)

/datum/team/swarmer_team/declare_completion()
	var/list/text = list()
	if(swarmer_objective.completed)
		text += span_fontsize3("<br><br><b>Победа \"Свармеров\"!</b>")
		text += "<br><b>Свармеры смогли создать Мега-Свармера! Экипаж не смог остановить их до того, как они накопят достаточно ресурсов.</b>"
	else
		text += span_fontsize3("<br><br><b>Поражение \"Свармеров\"!</b>")
		text += "<br><b>Свармеры не сумели создать Мега-Свармера! Экипаж остановил их до того, как они накопят достаточно ресурсов.</b>"
	return text.Join("")

/**
 * Proc used to start swarmer destroying on core destruction
 *
 * Starts with mobs, and then starts destroying objects
 * Exists to optimize mass destroying with effects
 */
/datum/team/swarmer_team/proc/start_swarmers_destroying()
	if(length(GLOB.swarmers))
		var/mob/swarmer = GLOB.swarmers[1]
		explosion(swarmer, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2)
		if(!QDELETED(swarmer))
			qdel(swarmer)
		addtimer(CALLBACK(src, PROC_REF(start_swarmers_destroying)), DESTROY_DELAY, TIMER_DELETE_ME)
		return

	destroy_swarmer_objects()

/// Destroys swarmer objects one-by-one with a delay
/datum/team/swarmer_team/proc/destroy_swarmer_objects()
	if(!length(GLOB.swarmer_objects))
		return

	var/obj/swarmer_obj = GLOB.swarmer_objects[1]
	explosion(swarmer_obj, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2)
	if(!QDELETED(swarmer_obj))
		qdel(swarmer_obj)
	addtimer(CALLBACK(src, PROC_REF(destroy_swarmer_objects)), DESTROY_DELAY, TIMER_DELETE_ME)

#undef METALLIC_START_RESOURCES
#undef DESTROY_DELAY
