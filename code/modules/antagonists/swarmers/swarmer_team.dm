/**
 * Global proc to adjust metallic swarmer resource.
 *
 * Set use_modifier to TRUE if you want to use the team metal gather modifier.
 * Amount can be negative.
 */
/proc/adjust_swarmer_metallic_resources(amount, use_modifier = FALSE)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team || !team.swarmer_core) // Core is the storage
		return FALSE

	if(use_modifier) // Resource storage modifiers (used on swarmer metal gathering)
		amount *= team.metal_modifier

	if((team.metallic_resources + amount) < 0)
		return FALSE

	team.metallic_resources += amount
	return TRUE

/**
 * Global proc to adjust organic swarmer resource.
 * Amount can be negative.
 */
/proc/adjust_swarmer_organic_resources(amount)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team || !team.swarmer_core) // Core is the storage
		return FALSE

	if((team.organic_resources + amount) < 0)
		return FALSE

	team.organic_resources += amount
	return TRUE

/// Global proc to add an object to the swarmer team structure list.
/proc/add_object_to_swarmer_team_list(obj/object)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team)
		team = new

	LAZYADDASSOCLIST(team.swarmer_objects, object.type, object.UID())

/// Global proc to remove an object from the swarmer team structure list
/proc/remove_object_from_swarmer_team_list(obj/object)
	var/datum/team/swarmer_team/team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team)
		return

	LAZYREMOVEASSOC(team.swarmer_objects, object.type, object.UID())

/// How many metallic resources swarmers get on core init
#define METALLIC_START_RESOURCES 90
/// Metal modifier limit
#define METAL_MODIFIER_LIMIT 3
/// Limit of times a mob can be sent to an analyzer
#define ANALYZER_SEND_LIMIT 2

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
	/// Unlimited modifier of metal gatherings by swarmer used for calculations
	var/unlimited_metal_modifier = 0
	/// Main objective given to all swarmers
	var/datum/objective/swarmer_goal/swarmer_objective
	/// Have we made an announcement about mega-swarmer already or not
	var/mega_swarmer_announcement_made = FALSE
	/// Cooldown system for messages on core integrity change
	COOLDOWN_DECLARE(message_cooldown)
	/// Assoc lazylist of all swarmer structures in format: [key: type] -> [value: list(object uids of this type)]
	var/list/swarmer_objects
	/// Assoc lazylist of mob UIDs to times they have been in an analyzer
	var/list/analyzer_mob_list

/datum/team/swarmer_team/New(list/starting_members)
	..()
	RegisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED, PROC_REF(on_core_destroy))
	swarmer_objective = new(team_to_join = src)
	add_objective_to_members(swarmer_objective)

/datum/team/swarmer_team/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_GLOB_SWARMER_CORE_DESTROYED)
	on_core_destroy()
	QDEL_NULL(swarmer_objective)
	return ..()

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
 * Signal proc sent on swarmer core init
 *
 * Sets swarmer_core variable, adjusts required resources,
 * registers required core signals.
 */
/datum/team/swarmer_team/proc/on_core_init(obj/structure/swarmer/core/core)
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
 * Proc used in organic processing (not mobs)
 *
 * Tries to send an item to any processer one by one.
 * Returns processer bitflags (check swarmers.dm defines)
 */
/datum/team/swarmer_team/proc/try_process_organic(obj/item/item)
	if(!LAZYACCESS(swarmer_objects, /obj/structure/swarmer/organic_processer))
		return SWARMER_PROCESS_NONE

	for(var/processer_uid in swarmer_objects[/obj/structure/swarmer/organic_processer])
		var/obj/structure/swarmer/organic_processer/processer = locateUID(processer_uid)
		if(processer?.try_load_item(item))
			return SWARMER_PROCESS_FOUND

	return SWARMER_PROCESS_BUSY
/**
 * Proc used in organic analyzing (mobs)
 *
 * Tries to send a mob to any analyzer one by one.
 * Returns analyzer bitflags (check swarmers.dm defines)
 */
/datum/team/swarmer_team/proc/try_analyze_mob(mob/living/target)
	if(!LAZYACCESS(swarmer_objects, /obj/structure/swarmer/organic_analyzer))
		return SWARMER_ANALYZE_NONE

	var/target_uid = target.UID()
	if(LAZYACCESS(analyzer_mob_list, target_uid) >= ANALYZER_SEND_LIMIT)
		return SWARMER_ANALYZE_TOO_MUCH

	for(var/analyzer_uid in swarmer_objects[/obj/structure/swarmer/organic_analyzer])
		var/obj/structure/swarmer/organic_analyzer/analyzer = locateUID(analyzer_uid)
		if(analyzer?.try_load_mob(target))
			LAZYADDASSOC(analyzer_mob_list, target_uid, 1)
			return SWARMER_ANALYZE_FOUND

	return SWARMER_ANALYZE_BUSY

/**
 * Increases metal resource modifier
 * Arguments:
 * * adjust_amount: The amount to substract or add upon the modifier
 */
/datum/team/swarmer_team/proc/adjust_modifier(adjust_amount)
	unlimited_metal_modifier += adjust_amount
	metal_modifier = max(0, min(METAL_MODIFIER_LIMIT, unlimited_metal_modifier))

/// Helper proc to get the metal modifier limit
/datum/team/swarmer_team/proc/get_metal_modifier_limit()
	return METAL_MODIFIER_LIMIT

/**
 * Proc sent from mega-swarmer core spawn
 *
 * Completes swarmer objectives,
 * makes an announce to the station,
 * sets gamma code.
 */
/datum/team/swarmer_team/proc/on_mega_swarmer_spawn(mob/living/simple_animal/hostile/swarmer/mega/swarmer)
	if(mega_swarmer_announcement_made)
		return
	mega_swarmer_announcement_made = TRUE
	swarmer_objective.completed = TRUE
	GLOB.major_announcement.announce(
		message = "Обнаружено появление \"Мега-Свармера\" на борту станции [station_name()]. Экипаж должен любой ценой остановить его до того, как станция перейдёт под их полный контроль.",
		new_title = ANNOUNCE_CCMSG_RU,
		new_sound = 'sound/AI/commandreport.ogg'
	)
	// gamma level will be kept until roundend, since there would still be swarmers and more mega-swarmer can spawn
	addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_GAMMA), 5 SECONDS)

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
		addtimer(CALLBACK(src, PROC_REF(start_swarmers_destroying)), 0.1 SECONDS, TIMER_DELETE_ME)
		return

	destroy_swarmer_objects()

/// Destroys swarmer objects one-by-one with a delay
/datum/team/swarmer_team/proc/destroy_swarmer_objects()
	if(!LAZYLEN(swarmer_objects))
		return

	var/obj_type = swarmer_objects[1]
	var/list/obj_uids = swarmer_objects[obj_type]
	var/obj_uid = obj_uids[1]
	var/obj/obj = locateUID(obj_uid)
	if(obj) // not sure how that would happen but why not
		explosion(obj, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2)
		if(!QDELETED(obj))
			qdel(obj)

	LAZYREMOVEASSOC(swarmer_objects, obj_type, obj_uid) // extra safety
	addtimer(CALLBACK(src, PROC_REF(destroy_swarmer_objects)), 0.1 SECONDS, TIMER_DELETE_ME)

/// Returns the list used for choosing the hub to teleport to in tgui_input_list proc.
/// hub_to_ignore can be used to not include a certain hub
/datum/team/swarmer_team/proc/get_transport_hub_list(obj/structure/swarmer/transport_hub/hub_to_ignore)
	if(!LAZYACCESS(swarmer_objects, /obj/structure/swarmer/transport_hub))
		return

	var/list/potential_hubs = list()
	var/list/hub_names = list()
	var/list/duplicate_hub_count = list()
	for(var/hub_uid in swarmer_objects[/obj/structure/swarmer/transport_hub])
		var/obj/structure/swarmer/transport_hub/hub = locateUID(hub_uid)
		if(!hub || !hub.enabled)
			continue

		var/resultkey = hub.listkey
		if(resultkey in hub_names)
			duplicate_hub_count[resultkey]++
			resultkey = "[resultkey] ([duplicate_hub_count[resultkey]])"
		else
			hub_names += resultkey
			duplicate_hub_count[resultkey] = 1

		if(hub != hub_to_ignore)
			potential_hubs[resultkey] = hub

	return potential_hubs

/datum/team/swarmer_team/proc/on_nanobot_fabricator_init(obj/structure/swarmer/nanobot_fabricator/fabricator)
	return

#undef METALLIC_START_RESOURCES
#undef METAL_MODIFIER_LIMIT
#undef ANALYZER_SEND_LIMIT
