/// List that contains all swarmers mobs.
GLOBAL_LIST_EMPTY(swarmers)

/mob/living/simple_animal/hostile/swarmer
	name = "Swarmer"
	real_name = "Swarmer"
	desc = "Напишите баг-репорт, если увидили это."
	health = 35
	maxHealth = 35
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_old"
	icon_living = "swarmer_old"
	speak_emote = list("гудит")
	bubble_icon = "swarmer"
	mob_size = MOB_SIZE_SMALL
	melee_damage_type = STAMINA
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD)
	obj_damage = 0
	friendly = "щипает"
	faction = list(ROLE_SWARMER)
	AIStatus = AI_OFF
	wander = 0
	attacktext = "бьёт током"
	attack_sound = 'sound/effects/empulse.ogg'
	deathmessage = "взрывается с резким хлопком!"
	del_on_death = 1
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot, /obj/item/stack/ore/bluespace_crystal)
	light_color = LIGHT_COLOR_CYAN
	light_range = 3
	light_on = FALSE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	hud_type = /datum/hud/swarmer
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	move_force = MOVE_FORCE_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	/// Text used in core tgui and sent to client to tell about current class abilities
	var/swarmer_class_info = "Напишите баг-репорт, если увидили это."
	/// How much time does it take to dismantle a machine
	var/dismantle_speed = NORMAL_SWARMER_DISMANTLE_DELAY
	/// How many resources does it require to swap to this class from an existing one
	var/swap_resource_cost = 0
	/// Can swarmers swap to this type in core?
	var/can_swap_to = TRUE
	/// Reference to swarmer team
	var/datum/team/swarmer_team/team
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system
	/// Mmi inside contents if this swarmer is from a cyborg
	var/obj/item/mmi/mmi

/mob/living/simple_animal/hostile/swarmer/Initialize(mapload)
	. = ..()
	GLOB.swarmers += src
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	add_language(LANGUAGE_HIVE_SWARMER)
	updatename()
	RegisterSignal(src, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
	// Grants all required on-init actions to this type
	for(var/action_type in GLOB.swarmer_actions_by_type[type])
		var/datum/action/cooldown/swarmer/action = new action_type
		action.Grant(src)

/mob/living/simple_animal/hostile/swarmer/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = INFINITY, \
		minbodytemp = 0, \
	)
	AddComponent(\
		/datum/component/ghost_direct_control, \
		ban_type = ROLE_SWARMER, \
		poll_candidates = FALSE, \
		after_assumed_control = CALLBACK(src, PROC_REF(add_datum_if_not_exist)), \
	)

/// Adds antag datum and updates team variable
/mob/living/simple_animal/hostile/swarmer/proc/add_datum_if_not_exist()
	if(mind && !mind.has_antag_datum(/datum/antagonist/swarmer))
		mind.add_antag_datum(/datum/antagonist/swarmer, /datum/team/swarmer_team)
	team = GLOB.antagonist_teams[/datum/team/swarmer_team]

// mob/living is hardcoded to have medhud. So we change medhud to appear as diaghud
/mob/living/simple_animal/hostile/swarmer/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	holder.pixel_y = get_cached_height() - ICON_SIZE_Y
	holder.icon_state = "huddiag[RoundDiagBar(health / maxHealth)]"

// mob/living is hardcoded to have medhud. So we change medhud to appear as diaghud
/mob/living/simple_animal/hostile/swarmer/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	holder.pixel_y = get_cached_height() - ICON_SIZE_Y
	holder.icon_state = "hudstat"

/mob/living/simple_animal/hostile/swarmer/Destroy()
	GLOB.swarmers -= src
	QDEL_NULL(spark_system)
	UnregisterSignal(src, COMSIG_LIVING_UNARMED_ATTACK)
	team = null
	handle_mmi_on_destroy()
	return ..()

/// Proc used on destroy if we have a mmi inside
/mob/living/simple_animal/hostile/swarmer/proc/handle_mmi_on_destroy()
	if(!mmi || !mind)
		return
	mind.transfer_to(mmi.brainmob)
	mmi.forceMove(get_turf(src))
	addtimer(CALLBACK(mmi.brainmob, TYPE_PROC_REF(/mob, offer_ghostize)), 10 SECONDS, TIMER_DELETE_ME)
	mmi = null

/// Just some sparks on death.
/mob/living/simple_animal/hostile/swarmer/death(gibbed)
	spark_system.start()
	return ..()

/mob/living/simple_animal/hostile/swarmer/get_ru_names()
	return alist(
		NOMINATIVE = "свармер",
		GENITIVE = "свармера",
		DATIVE = "свармеру",
		ACCUSATIVE = "свармера",
		INSTRUMENTAL = "свармером",
		PREPOSITIONAL = "свармере"
	)

/mob/living/simple_animal/hostile/swarmer/proc/updatename()
	real_name = "[name] [rand(100,999)]-[pick(GLOB.greek_letters)]"
	name = real_name

/mob/living/simple_animal/hostile/swarmer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Металлические ресурсы: ", team.metallic_resources)
	status_tab_data[++status_tab_data.len] = list("Органические ресурсы: ", team.organic_resources)
	if(team.swarmer_core)
		status_tab_data[++status_tab_data.len] = list("Здоровье ядра: ", "[team.swarmer_core.obj_integrity]/[team.swarmer_core.max_integrity]")

/// Swarmers get damaged on emp
/mob/living/simple_animal/hostile/swarmer/emp_act()
	..()
	adjustHealth(SWARMER_EMP_DAMAGE, forced = TRUE)

/// Swarmer projectiles pass through swarmers
/mob/living/simple_animal/hostile/swarmer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(is_swarmerprojectile(mover))
		return TRUE

/// Handles dealing actual damage to cyborgs and animals.
/mob/living/simple_animal/hostile/swarmer/AttackingTarget()
	. = ..()
	if(isswarmer(target))
		return

	if(issilicon(target) || isanimal(target))
		var/mob/living/difficult_target = target
		var/damage = rand(melee_damage_lower, melee_damage_upper)
		difficult_target.apply_damage(damage, BURN)

/**
 * Unarmed_Attack signal proc
 *
 * Used to handle the following:
 * Swarmer acts on non-living beings
 * Sending organic stuff to the organic processer
 * Repairing other swarmers
 */
/mob/living/simple_animal/hostile/swarmer/proc/on_unarmed_attack(datum/source, atom/movable/atom, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	handle_swarmer_act(atom, proximity_flag, modifiers)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Handles swarmer_act and its return values, with some extra checks in separate procs
/mob/living/simple_animal/hostile/swarmer/proc/handle_swarmer_act(atom/movable/atom, proximity_flag, list/modifiers)
	var/swarmer_act_result = atom.swarmer_act(src)
	if(swarmer_act_result & SWARMER_ACT_POSSIBLE)
		handle_possible_swarmer_act(atom, swarmer_act_result, proximity_flag, modifiers)
		return

	if((swarmer_act_result & ~SWARMER_ACT_IMPOSSIBLE) == swarmer_act_result)
		CRASH("Swarmer act was called without either of the two main flags. Atom called on: [atom.type], act return value: [swarmer_act_result].")

	handle_impossible_swarmer_act(atom, swarmer_act_result, proximity_flag, modifiers)

/// Handles impossible swarmer acts. Look for impossible values in atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/user).
/mob/living/simple_animal/hostile/swarmer/proc/handle_impossible_swarmer_act(atom/movable/atom, swarmer_act_result, proximity_flag, list/modifiers)
	if(swarmer_act_result == SWARMER_ACT_IMPOSSIBLE)
		return balloon_alert(src, "нельзя!")

	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_OVERRIDE)
		return

	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_DEFAULT)
		if(!right_click_attack_chain(atom, modifiers))
			OnUnarmedAttack(atom, proximity_flag, modifiers)
		return

	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_ENERGY)
		return balloon_alert(src, "повредит электроэнергию!")
	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_LIVING)
		return balloon_alert(src, "повредит жизни экипажа!")
	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_ATMOS)
		return balloon_alert(src, "повредит системе воздуха!")
	if(swarmer_act_result & SWARMER_ACT_IMPOSSIBLE_REASON_TEAM)
		return balloon_alert(src, "повредит команде!")

/// Handles possible swarmer acts. Look for possible values in atom/proc/swarmer_act(mob/living/simple_animal/hostile/swarmer/user).
/mob/living/simple_animal/hostile/swarmer/proc/handle_possible_swarmer_act(atom/movable/atom, swarmer_act_result, proximity_flag, list/modifiers)
	if(swarmer_act_result == SWARMER_ACT_POSSIBLE)
		CRASH("Swarmer act returned only SWARMER_ACT_POSSIBLE flag, which should not happen. Atom: [atom.type].")

	var/datum/callback/action_cb
	if(swarmer_act_result & SWARMER_ACT_POSSIBLE_ACTION_DAMAGE)
		action_cb = CALLBACK(src, PROC_REF(damage_object), atom)
	else if(swarmer_act_result & SWARMER_ACT_POSSIBLE_ACTION_CONSUME)
		action_cb = CALLBACK(src, PROC_REF(extract_resources), atom)
	else if(swarmer_act_result & SWARMER_ACT_POSSIBLE_ACTION_DISMANTLE)
		action_cb = CALLBACK(src, PROC_REF(dismantle_machine), atom)
	else if(swarmer_act_result & SWARMER_ACT_POSSIBLE_ACTION_DESTROY)
		action_cb = CALLBACK(src, PROC_REF(destroy_object), atom)

	if(!action_cb)
		CRASH("Swarmer act returned SWARMER_ACT_POSSIBLE flag with none of the correct flag combinations. Atom: [atom.type], flag: [swarmer_act_result]")

	if(isitem(atom)) // we can skip all checks if this is an item
		return action_cb.Invoke()

	if(istype(atom, /obj/structure/lattice/catwalk)) // edge case for catwalks
		var/turf/atom_turf = atom.loc
		if(locate(/obj/structure/cable) in atom_turf)
			return balloon_alert(src, "нельзя, кабель!")
		return action_cb.Invoke()

	// now we check if its atmos important (blocks air flow)
	var/blocks_air = !atom.CanAtmosPass(NORTH) || !atom.CanAtmosPass(WEST) || !atom.CanAtmosPass(EAST) || !atom.CanAtmosPass(SOUTH)
	if(!blocks_air)
		return action_cb.Invoke()

	// and if we are, check if its space nearby or supermatter
	var/turf/atom_turf = get_turf(atom)
	for(var/turf/turf as anything in atom_turf.AdjacentTurfs(cardinal_only = TRUE))
		if(isspaceturf(turf) || istype(get_area(turf), /area/station/engineering/supermatter))
			return balloon_alert(src, "нельзя, опасная среда!")

	return action_cb.Invoke()

/**
 * Proc for organic processing.
 *
 * Handles do_after and sends COMSIG_SWARMER_TRY_PROCESS_ORGANIC_ITEM signal to the team.
 */
/mob/living/simple_animal/hostile/swarmer/proc/send_organic_processer_signal(obj/item, delay = 0)
	if(delay > 0)
		balloon_alert(src, "отправка...")
		var/atom/delay_target = item ? item : src // The item can be null intentionally
		if(!do_after(src, delay, delay_target))
			balloon_alert(src, "сбито!")
			return

	if(SEND_SIGNAL(team, COMSIG_SWARMER_TRY_PROCESS_ORGANIC_ITEM, item) & TRUE)
		balloon_alert(src, "успешно отправлено!")
		spark_system.start()
		return
	balloon_alert(src, "нету места для органики!")

/**
 * Proc used to disperse of mobs.
 *
 * Handles do_after and sends COMSIG_SWARMER_TRY_ANALYZE_MOB signal to the team.
 * If signal returns FALSE, we teleport the target randomly.
 * Used in CtrlClick proc.
 */
/mob/living/simple_animal/hostile/swarmer/proc/try_disperse(mob/living/target)
	balloon_alert(src, "отправка...")
	if(!do_after(src, SWARMER_SEND_ANALYZER_DELAY, target, max_interact_count = 1))
		balloon_alert(src, "сбито!")
		return
	spark_system.start()
	if(SEND_SIGNAL(team, COMSIG_SWARMER_TRY_ANALYZE_MOB, target) & TRUE)
		balloon_alert(src, "отправлено в анализатор!")
		return
	if(!iscarbon(target))
		balloon_alert(src, "нету места для органики!")
		return
	fail_disperse_teleport(target)

/**
 * Proc called if no free organic analyzers were found
 *
 * Puts restrains on target, adjust organic resources slightly
 * and teleports them randomly.
 */
/mob/living/simple_animal/hostile/swarmer/proc/fail_disperse_teleport(mob/living/carbon/target)
	var/turf/safe_turf = find_safe_turf(z)
	if(!safe_turf)
		balloon_alert(src, "нет мест для телепорта!")
		return
	if(!target.handcuffed)
		target.apply_restraints(new /obj/item/restraints/handcuffs/energy/used(null), ITEM_SLOT_HANDCUFFED, TRUE)
	target.Sleeping(10 SECONDS)
	balloon_alert(src, "случайно телепортировано!")
	playsound(src, 'sound/effects/sparks4.ogg', 50, TRUE)
	adjust_swarmer_organic_resources(SWARMER_ANALYZE_TELEPORT_GAIN)
	do_teleport(target, safe_turf)

/// Proc used to convert cyborgs to swarmers.
/mob/living/simple_animal/hostile/swarmer/proc/try_convert(mob/living/silicon/robot/target)
	if(!target.mind)
		balloon_alert(src, "не имеет разума!")
		return
	balloon_alert(src, "пересобираем...")
	if(!do_after(src, 15 SECONDS, target, max_interact_count = 1))
		balloon_alert(src, "сбито!")
		return
	var/mob/living/simple_animal/hostile/swarmer/combat/new_swarmer = new(get_turf(target))
	if(target.mmi)
		new_swarmer.mmi = target.mmi // Save a reference to mmi in src
		target.mmi.forceMove(new_swarmer) // Forcemove mmi into new swarmer
		target.mmi = null // Clean the reference to mmi in robot
	target.mind.transfer_to(new_swarmer)
	balloon_alert(src, "успех!")
	new_swarmer.spark_system.start()
	add_conversion_logs(target, "Converted into [new_swarmer.name].")
	qdel(target)

/// Proc called in swarmer_act to adjust resources and destroy target
/mob/living/simple_animal/hostile/swarmer/proc/extract_resources(atom/movable/target)
	var/resource_gain = target.integrate_amount()
	if(isnull(resource_gain))
		CRASH("[target.type] swarmer_act uses consume return value, yet integrate_amount() proc returned null.")

	if(!resource_gain)
		balloon_alert(src, "не совместимо!")
		to_chat(src, span_warning("[target] не является совместимым с нашим переработчиком материалов."))
		stack_trace("[target] swarmer_act uses consume return value, yet ")
		return FALSE
	. = TRUE
	adjust_swarmer_metallic_resources(resource_gain, TRUE)
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)
	var/obj/effect/temp_visual/swarmer/integrate/integrate_effect = new(get_turf(target))
	integrate_effect.adjust_size(target)
	if(!isstack(target))
		qdel(target)
		return .
	var/obj/item/stack/stack_item = target
	stack_item.use(1)

/// Proc called in swarmer_act to damage target.
/mob/living/simple_animal/hostile/swarmer/proc/damage_object(atom/movable/target)
	var/obj/effect/temp_visual/swarmer/disintegration/disintegrate_effect = new(get_turf(target))
	disintegrate_effect.adjust_size(target)
	target.ex_act(EXPLODE_LIGHT) // This is what actually damages structures on swarmer_act
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)

/// Proc called in swarmer_act to destroy the target.
/mob/living/simple_animal/hostile/swarmer/proc/destroy_object(atom/movable/target)
	damage_object(target)
	qdel(target)

/mob/living/simple_animal/hostile/swarmer/electrocute_act(shock_damage, atom/source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	if(!(flags & SHOCK_TESLA))
		return FALSE
	return ..()

/// Proc called in swarmer_act to dismantle machinery.
/mob/living/simple_animal/hostile/swarmer/proc/dismantle_machine(obj/machinery/target)
	do_attack_animation(target)
	balloon_alert(src, "разбор...")
	var/obj/effect/temp_visual/swarmer/dismantle/dismantle_effect = new(get_turf(target))
	dismantle_effect.adjust_size(target)
	if(!do_after(src, dismantle_speed, target, max_interact_count = 1))
		return
	balloon_alert(src, "успех!")
	target.deconstruct(TRUE)

/// Proc used to toggle light on hud
/mob/living/simple_animal/hostile/swarmer/proc/toggle_light()
	if(!light_on && is_ventcrawling(src))
		to_chat(src, span_warning("Нельзя переключить свет в вентиляции!"))
		return
	set_light_on(!light_on)

/// Proc used to communicate with other swarmers
/mob/living/simple_animal/hostile/swarmer/proc/contact_swarmers()
	var/message = tgui_input_text(src, "Передайте сообщение другим \"Свармерам\"", "Канал \"Свармеров\"")
	if(!message)
		return

	message = span_swarmeritalic("<b>[name]:</b> [message]")
	relay_to_list_and_observers(message, GLOB.swarmers, src, MESSAGE_TYPE_RADIO)
	add_say_logs(src, message, language = "SWARMER")

/// Tries to send a mob to the processer, or teleport them randomly if none exist
/mob/living/attack_swarmer_secondary(mob/living/simple_animal/hostile/swarmer/user, list/modifiers)
	user.try_disperse(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Tries to convert a cyborg into a swarmer
/mob/living/silicon/robot/attack_swarmer_secondary(mob/living/simple_animal/hostile/swarmer/user, list/modifiers)
	user.try_convert(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/effect/temp_visual/swarmer
	icon = 'icons/effects/swarmer.dmi'
	layer = BELOW_MOB_LAYER

/// Use this proc to adjust size according to target.
/obj/effect/temp_visual/swarmer/proc/adjust_size(atom/target)
	pixel_x = target.pixel_x
	pixel_y = target.pixel_y
	pixel_z = target.pixel_z

/obj/effect/temp_visual/swarmer/Initialize(mapload)
	. = ..()
	playsound(loc, SFX_SPARKS, 100, TRUE)

/obj/effect/temp_visual/swarmer/disintegration
	icon_state = "disintegrate"

/obj/effect/temp_visual/swarmer/dismantle
	icon_state = "dismantle"
	duration = 25

/obj/effect/temp_visual/swarmer/integrate
	icon_state = "integrate"
	duration = 5
