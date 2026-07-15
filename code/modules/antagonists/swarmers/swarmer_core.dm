/// How often does the swarmer core shock on getting melee hit
#define SHOCK_COOLDOWN 3 SECONDS
/// How much does the healing aura component heal
#define HEALING_AURA_AMOUNT 2
/// What is the range of healing aura component
#define HEALING_AURA_RANGE 5

/obj/structure/swarmer/core
	name = "swarmer core"
	desc = "Главное сооружение \"Свармеров\", которое являются связующим для всех остальных сооружений и созданий."
	icon_state = "swarmer_core"
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 600
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 100, FIRE = 100, ACID = 100)
	speed_process = TRUE
	/// Used in TGUI on class selection, contains information about all subtypes of /mob/living/.../swarmer
	var/static/list/selection_classes
	/// Cooldown declaration used for shock cooldown on melee hits
	COOLDOWN_DECLARE(shock_cooldown)
	/// How much burn damage we deal on getting hit
	var/burn_damage = 15
	/// How much stamina damage we deal on getting hit
	var/stamina_damage = 20
	/// Spark system used on melee reactions
	var/datum/effect_system/spark_spread/spark_system
	/// How many organic resources we had on last swarmer spawn
	var/last_swarmer_spawn_value = 0
	/// How many organic resources we had on last mega-swarmer spawn
	var/last_mega_swarmer_spawn_value = 0
	/// Reference to swarmer team datum
	var/datum/team/swarmer_team/team

/obj/structure/swarmer/core/get_ru_names()
	return alist(
		NOMINATIVE = "ядро \"Свармеров\"",
		GENITIVE = "ядра \"Свармеров\"",
		DATIVE = "ядру \"Свармеров\"",
		ACCUSATIVE = "ядро \"Свармеров\"",
		INSTRUMENTAL = "ядром \"Свармеров\"",
		PREPOSITIONAL = "ядре \"Свармеров\""
	)

/obj/structure/swarmer/core/Initialize(mapload)
	. = ..()
	team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team)
		team = new // Create team if there isn't one
	if(team.swarmer_core) // This would only happen on shitspawn
		qdel(team.swarmer_core) // Will cause a chain reaction and delete src as well
		return
	SEND_SIGNAL(team, COMSIG_SWARMER_CORE_INITIALIZED, src)
	for(var/ddir in GLOB.alldirs)
		new /obj/structure/swarmer/blockade(get_step(src, ddir))
	if(!selection_classes)
		generate_class_selection()
	spark_system = new
	spark_system.set_up(3, 0, src)
	spark_system.attach(src)
	START_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, shock_cooldown, SHOCK_COOLDOWN)

/obj/structure/swarmer/core/ComponentInitialize()
	AddComponent( \
		/datum/component/aura_healing, \
		range = HEALING_AURA_RANGE, \
		simple_heal = HEALING_AURA_AMOUNT, \
		limit_to_trait = TRAIT_HEALS_FROM_SWARMER_CORES, \
		healing_color = COLOR_BLUE, \
	)

/obj/structure/swarmer/core/Destroy(force)
	team = null
	STOP_PROCESSING(SSfastprocess, src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SWARMER_CORE_DESTROYED)
	QDEL_NULL(spark_system)
	return ..()

// Begin react damage procs //
/obj/structure/swarmer/core/attack_hand(mob/living/user)
	. = ..()
	if(!.)
		return .

	user.apply_damages(burn = burn_damage, stamina = stamina_damage)
	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return .
	COOLDOWN_START(src, shock_cooldown, SHOCK_COOLDOWN)
	if(user.electrocute_act(rand(5, 20), src))
		spark_system.start()

/obj/structure/swarmer/core/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!. || !isliving(user))
		return .

	var/mob/living/target = user
	target.apply_damages(burn = burn_damage, stamina = stamina_damage)
	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return .
	COOLDOWN_START(src, shock_cooldown, SHOCK_COOLDOWN)
	if(target.electrocute_act(rand(5, 20), src))
		spark_system.start()

/obj/structure/swarmer/core/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0)
	. = ..()
	if(!. || !isliving(user))
		return .
	var/mob/living/target = user
	target.apply_damage(burn_damage, BURN)
	if(!COOLDOWN_FINISHED(src, shock_cooldown))
		return .
	COOLDOWN_START(src, shock_cooldown, SHOCK_COOLDOWN)
	if(target.electrocute_act(rand(5, 20), src))
		spark_system.start()
// End react damage procs //

/// Spawns swarmers based on organic materials value.
/obj/structure/swarmer/core/process(seconds_per_tick)
	if((team.organic_resources - last_swarmer_spawn_value) < SWARMER_SPAWN_VALUE)
		return

	if((team.organic_resources - last_mega_swarmer_spawn_value) < MEGA_SWARMER_SPAWN_VALUE)
		last_swarmer_spawn_value = team.organic_resources
		INVOKE_ASYNC(src, PROC_REF(spawn_swarmer_from_ghost))
		return

	last_mega_swarmer_spawn_value = team.organic_resources
	INVOKE_ASYNC(src, PROC_REF(spawn_mega_swarmer_from_ghost))

/// Makes a ghost poll for basic swarmer spawn
/obj/structure/swarmer/core/proc/spawn_swarmer_from_ghost()
	var/image/poll_source = image('icons/mob/swarmer.dmi', "swarmer_combat")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите сыграть за Свармера?", ROLE_SWARMER, TRUE, poll_time = 15 SECONDS, source = poll_source)
	if(!length(candidates)) // Makes a spawner if no-one wanted to
		new /obj/effect/mob_spawn/swarmer(get_step(loc, pick(GLOB.alldirs)))
		return
	var/turf/spawn_loc = get_turf(src)
	if(isnull(spawn_loc))
		return

	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/mob/living/simple_animal/hostile/swarmer/basic/swarmer = new(spawn_loc)
	swarmer.possess_by_player(selected.key)
	swarmer.add_datum_if_not_exist()

	message_admins("[ADMIN_LOOKUPFLW(swarmer)] has been made into Swarmer (core spawn).")
	log_game("[key_name(swarmer)] was spawned as Swarmer by the core.")

/// Makes a ghost poll for mega swarmer spawn
/obj/structure/swarmer/core/proc/spawn_mega_swarmer_from_ghost()
	var/image/poll_source = image('icons/mob/swarmer.dmi', "swarmer_mega")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите сыграть за Мега-Свармера?", ROLE_SWARMER, TRUE, poll_time = 30 SECONDS, source = poll_source)
	if(!length(candidates)) // Someone must pick that anyway
		INVOKE_ASYNC(src, PROC_REF(spawn_mega_swarmer_from_ghost))
		return
	var/turf/spawn_loc = get_turf(src)
	if(isnull(spawn_loc))
		return

	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/mob/living/simple_animal/hostile/swarmer/mega/swarmer = new(spawn_loc)
	swarmer.possess_by_player(selected.key)
	swarmer.add_datum_if_not_exist()

	SEND_SIGNAL(team, COMSIG_MEGA_SWARMER_CORE_SPAWN)
	message_admins("[ADMIN_LOOKUPFLW(swarmer)] has been made into Mega-Swarmer (core spawn).")
	log_game("[key_name(swarmer)] was spawned as Mega-Swarmer by the core.")

/// Core is only movable with an ability
/obj/structure/swarmer/core/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(FALSE)
	swarmer.balloon_alert(swarmer, "это нельзя открутить!")

/// Core is not destroyable by swarmers
/obj/structure/swarmer/core/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(FALSE)
	swarmer.balloon_alert(swarmer, "это нельзя уничтожить!")

/// Begin swarmer core tgui code ///
/obj/structure/swarmer/core/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	. = ..()
	if(!.)
		return
	ui_interact(swarmer)

/obj/structure/swarmer/core/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SwarmerCore", "Выбор класса")
		ui.open()

/obj/structure/swarmer/core/ui_data(mob/user)
	var/list/data = list()
	data["organic_resources"] = team.organic_resources
	data["cheaper_swap"] = !is_basicswarmer(user)
	data["current_class_path"] = user.type
	return data

/obj/structure/swarmer/core/ui_static_data(mob/user)
	var/list/data = list()
	data["organic_goal"] = MEGA_SWARMER_SPAWN_VALUE
	data["classes"] = selection_classes
	return data

/obj/structure/swarmer/core/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("select_class")
			var/confirm = tgui_alert(ui.user, "Вы уверены, что хотите выбрать данный класс?", "Выбор класса", list("Да", "Нет"))
			if(confirm == "Нет")
				return
			var/swarmer_path = text2path(params["class"])
			var/swap_cost = params["cost"]
			var/mob/living/simple_animal/hostile/swarmer/old_swarmer = ui.user
			swap_cost = is_basicswarmer(old_swarmer) ? swap_cost : round(swap_cost / 2)// swarmer classes cost less on non-basic swap
			if(!adjust_swarmer_metallic_resources(-swap_cost))
				ui.user.balloon_alert(ui.user, "недостаточно ресурсов!")
				return
			spark_system.start()
			var/mob/living/simple_animal/hostile/swarmer/new_swarmer = new swarmer_path(get_turf(old_swarmer))
			// Handle mmi transfer to new swarmer
			if(old_swarmer.mmi)
				old_swarmer.mmi.forceMove(new_swarmer)
				new_swarmer.mmi = old_swarmer.mmi
				old_swarmer.mmi = null
			// Adjust health based on old swarmer health
			new_swarmer.health *= old_swarmer.health / old_swarmer.maxHealth
			old_swarmer.mind.transfer_to(new_swarmer)
			new_swarmer.balloon_alert(new_swarmer, "успех!")
			add_conversion_logs(old_swarmer, "Converted in core into [new_swarmer.name].")
			qdel(old_swarmer)

/// Generates classes selection array in TGUI
/obj/structure/swarmer/core/proc/generate_class_selection()
	for(var/path in subtypesof(/mob/living/simple_animal/hostile/swarmer))
		var/mob/living/simple_animal/hostile/swarmer/swarmer = path
		if(swarmer::can_swap_to == FALSE)
			continue
		var/list/new_class = list(
			"name" = swarmer::name,
			"desc" = swarmer::desc,
			"icon" = swarmer::icon,
			"icon_state" = swarmer::icon_state,
			"path" = path,
			"additional_info" = swarmer::swarmer_class_info,
			"cost" = swarmer::swap_resource_cost,
		)
		selection_classes += list(new_class)

/// End swarmer core tgui code ///

#undef SHOCK_COOLDOWN
#undef HEALING_AURA_AMOUNT
#undef HEALING_AURA_RANGE
