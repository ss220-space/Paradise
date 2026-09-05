/// How many metallic resources does it cost to make a barricade
#define SWARMER_BLOCKADE_COST 7
/// How many metallic resources does it cost to make a trap
#define SWARMER_TRAP_COST 3
/// How many metallic resources does it cost to make a transport hub
#define SWARMER_HUB_COST 15
/// How many metallic resources does it cost to make an organic processer
#define SWARMER_PROCESSER_COST 20
/// How many metallic resources does it cost to make an organic analyzer
#define SWARMER_ANALYZER_COST 20
/// How many metallic resources does it cost to make a repair station
#define SWARMER_REPAIR_STATION_COST 10
/// How many metallic resources does it cost to make a resource storage
#define SWARMER_STORAGE_COST 10
/// How many metallic resources does it cost to make a rapid fire turret
#define SWARMER_RAPID_TURRET_COST 20
/// How many metallic resources does it cost to make a sniper turret
#define SWARMER_SNIPER_TURRET_COST 25
/// How many metallic resources does it cost to make an ACP turret
#define SWARMER_ACP_COST 25
/// How many metallic resources does it cost to make a nanobot fabricator
#define SWARMER_NANOBOT_FABRICATOR_COST 250
/// How many metallic resources does it cost to move the core to a hub
#define SWARMER_CORE_MOVE_COST 100

/datum/action/cooldown/swarmer
	abstract_type = /datum/action/cooldown/swarmer
	name = "Свармер что-то"
	desc = "Напишите баг-репорт, если увидели это."
	button_icon = 'icons/mob/actions/actions_swarmer.dmi'
	/// How many metallic resources does it cost to do this action
	var/action_cost = 0

/datum/action/cooldown/swarmer/IsAvailable(feedback = FALSE)
	if(!isswarmer(owner))
		return FALSE
	return ..()

/// Updates description to include material cost.
/datum/action/cooldown/swarmer/New(Target, original = TRUE)
	. = ..()
	if(action_cost)
		desc = "[initial(desc)] Стоимость: [action_cost] металлических материал[DECL_CREDIT(action_cost)]."

/datum/action/cooldown/swarmer/build
	abstract_type = /datum/action/cooldown/swarmer/build
	cooldown_time = 3 SECONDS
	/// What do we build
	var/build_type = /obj/structure/swarmer
	/// How long does it take to build
	var/build_time = 0
	/// Does it require the user to type a keyword for the structure
	var/req_keyword = FALSE

/datum/action/cooldown/swarmer/build/Activate()
	. = ..()
	var/mob/living/user = owner

	var/turf/spawn_turf
	var/list/turfs_to_check
	var/obj/structure/swarmer/build_atom_prototype = build_type
	if(build_atom_prototype::bound_width > ICON_SIZE_X || build_atom_prototype::bound_height > ICON_SIZE_Y)
		var/occupied_turfs_width = ceil(build_atom_prototype::bound_width / ICON_SIZE_X)
		var/occupied_turfs_height = ceil(build_atom_prototype::bound_height / ICON_SIZE_Y)
		spawn_turf = get_offset_target_turf(get_turf(user), -floor(occupied_turfs_width / 2), 0)
		turfs_to_check = CORNER_BLOCK(spawn_turf, occupied_turfs_width, occupied_turfs_height)
	else
		spawn_turf = get_turf(user)
		turfs_to_check = list(spawn_turf)

	if(!default_build_checks(user, turfs_to_check))
		return

	if(!custom_build_checks(user, turfs_to_check))
		return

	if(!adjust_swarmer_metallic_resources(-action_cost))
		user.balloon_alert(user, "недостаточно ресурсов!")
		return

	if(!do_after(user, build_time, user, max_interact_count = 1))
		user.balloon_alert(user, "сбито!")
		adjust_swarmer_metallic_resources(action_cost) // Return spent resources
		return

	user.balloon_alert(user, "успех!")
	return new build_type(spawn_turf)

/// Default turf checks
/datum/action/cooldown/swarmer/build/proc/default_build_checks(mob/living/user, list/turfs_to_check)
	if(!length(turfs_to_check) || !user)
		return FALSE

	. = TRUE
	for(var/turf/target_turf as anything in turfs_to_check)
		if(!is_station_level(target_turf.z))
			user.balloon_alert(user, "вне станции!")
			return FALSE
		if(isspaceturf(target_turf))
			user.balloon_alert(user, "космос!")
			target_turf.balloon_alert(user, "здесь!")
			return FALSE
		if(iswallturf(target_turf))
			user.balloon_alert(user, "стена!")
			target_turf.balloon_alert(user, "здесь!")
			return FALSE
		if((locate(/obj/structure/swarmer) in target_turf))
			user.balloon_alert(user, "нельзя строить сверху существующего!")
			target_turf.balloon_alert(user, "здесь!")
			return FALSE
		if((locate(/obj/machinery/porta_turret/swarmer) in target_turf))
			user.balloon_alert(user, "нельзя строить сверху существующего!")
			target_turf.balloon_alert(user, "здесь!")
			return FALSE

/// Proc for custom checks based on what is being built, returns TRUE on default
/datum/action/cooldown/swarmer/build/proc/custom_build_checks(mob/living/user, list/turfs_to_check)
	return TRUE

/datum/action/cooldown/swarmer/build/barricade
	name = "Создать баррикаду"
	desc = "Создаёт баррикаду, через которую могут проходить \"Свармеры\", и пролетать их лазеры."
	button_icon_state = "swarmer_barricade"
	build_type = /obj/structure/swarmer/blockade
	action_cost = SWARMER_BLOCKADE_COST
	build_time = SWARMER_FAST_BUILD_DELAY

/datum/action/cooldown/swarmer/build/trap
	name = "Создать ловушку"
	desc = "Создаёт ловушку, которая будет оглушать всех, кроме \"Свармеров\"."
	button_icon_state = "swarmer_trap"
	build_type = /obj/structure/swarmer/trap
	action_cost = SWARMER_TRAP_COST
	build_time = SWARMER_FAST_BUILD_DELAY

/// Trap is built immediately for rover swarmers, and instead has cooldown
/datum/action/cooldown/swarmer/build/trap/Grant(mob/granted_to)
	. = ..()
	if(is_roverswarmer(granted_to))
		cooldown_time = build_time
		build_time = 0

/datum/action/cooldown/swarmer/build/transport_hub
	name = "Создать Хаб"
	desc = "Создаёт Хаб, между которыми смогут перемещаться все \"Свармеры\"."
	button_icon_state = "swarmer_hub"
	build_type = /obj/structure/swarmer/transport_hub
	action_cost = SWARMER_HUB_COST
	build_time = SWARMER_SLOW_BUILD_DELAY

/datum/action/cooldown/swarmer/build/transport_hub/Activate()
	. = ..() // Returns built hub
	if(!.)
		return
	var/keyword = tgui_input_text(owner, "Пожалуйста, введите название для постройки.", "Ввод названия")
	if(!keyword)
		return
	var/obj/structure/swarmer/transport_hub/hub = .
	hub.listkey = "[keyword] ([hub.listkey])"

/datum/action/cooldown/swarmer/build/processer
	name = "Создать переработчик органики"
	desc = "Обрабатывает неживую материю."
	button_icon_state = "swarmer_processor"
	build_type = /obj/structure/swarmer/organic_processer
	action_cost = SWARMER_PROCESSER_COST
	build_time = SWARMER_NORMAL_BUILD_DELAY

/datum/action/cooldown/swarmer/build/analyzer
	name = "Создать анализатор органики"
	desc = "Обрабатывает живую и металлическую материю."
	button_icon_state = "swarmer_analyzer"
	build_type = /obj/structure/swarmer/organic_analyzer
	action_cost = SWARMER_ANALYZER_COST
	build_time = SWARMER_NORMAL_BUILD_DELAY

/datum/action/cooldown/swarmer/build/repair_station
	name = "Создать станцию починки"
	desc = "Быстрая починка для \"Свармеров\"."
	button_icon_state = "swarmer_repair"
	build_type = /obj/structure/swarmer/repair_station
	action_cost = SWARMER_REPAIR_STATION_COST
	build_time = SWARMER_NORMAL_BUILD_DELAY

/datum/action/cooldown/swarmer/build/storage
	name = "Создать хранилище для ресурсов"
	desc = "Ускоряет ручной сбор материалов."
	button_icon_state = "swarmer_storage"
	build_type = /obj/structure/swarmer/resource_storage
	action_cost = SWARMER_STORAGE_COST
	build_time = SWARMER_FAST_BUILD_DELAY

// Check if we have hit the metal modifier limit, and warn the user that building a new one wont do much
/datum/action/cooldown/swarmer/build/storage/custom_build_checks(mob/living/user, list/turfs_to_check)
	var/datum/team/swarmer_team/swarmer_team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(swarmer_team.metal_modifier < swarmer_team.get_metal_modifier_limit())
		return TRUE

	var/choice = tgui_alert(user, "Предупреждение! Лимит модификатора сбора ресурсов уже достигнут, постройка нового хранилища ничего не даст, \
		однако послужит защитой, если сломают другое хранилище. Продолжить стройку?", "Постройка хранилища", list("Да", "Нет"))
	if(choice == "Да")
		return TRUE

	return FALSE

/datum/action/cooldown/swarmer/build/rapid_turret
	name = "Создать штурмовую турель"
	desc = "Турель, стреляющая залпами лучей."
	button_icon_state = "swarmer_rapid_turret"
	build_type = /obj/machinery/porta_turret/swarmer/turret
	action_cost = SWARMER_RAPID_TURRET_COST
	build_time = SWARMER_NORMAL_BUILD_DELAY

/datum/action/cooldown/swarmer/build/sniper_turret
	name = "Создать снайперскую турель"
	desc = "Турель, стреляющая сильным, пробивающим лучом."
	button_icon_state = "swarmer_sniper_turret"
	build_type = /obj/machinery/porta_turret/swarmer/sniper
	action_cost = SWARMER_SNIPER_TURRET_COST
	build_time = SWARMER_SLOW_BUILD_DELAY

/datum/action/cooldown/swarmer/build/acp_turret
	name = "Создать установку ACP"
	desc = "Турель, бьющая целей по области, накладывая дебаффы."
	button_icon_state = "swarmer_acp"
	build_type = /obj/structure/swarmer/acp_turret
	action_cost = SWARMER_ACP_COST
	build_time = SWARMER_NORMAL_BUILD_DELAY

/datum/action/cooldown/swarmer/build/nanobot_fabricator
	name = "Создать фабрикатор наноботов"
	desc = "Для постройки требуются ванометрические батареи в видимости нескольких тайлов. Является финальной конструкцией \"Свармеров\"."
	build_type = /obj/structure/swarmer/nanobot_fabricator
	action_cost = SWARMER_NANOBOT_FABRICATOR_COST
	build_time = SWARMER_SLOW_BUILD_DELAY

// Action for moving the core to any available transport hub
/datum/action/cooldown/swarmer/move_core
	name = "Переместить ядро"
	desc = "Перемещает ядро на выбранный \"Хаб\", при этом уничтожая его."
	button_icon_state = "swarmer_core_swap"
	cooldown_time = 1 MINUTES
	action_cost = SWARMER_CORE_MOVE_COST
	/// How long does it take to move the core
	var/core_move_delay = 25 SECONDS
	/// Radius of the forcefield
	var/forcefield_radius = 2
	/// How long the forcefield lasts
	var/forcefield_duration = 5 SECONDS

/datum/action/cooldown/swarmer/move_core/Activate()
	. = ..()
	var/mob/living/simple_animal/hostile/swarmer/swarmer_owner = owner
	var/obj/structure/swarmer/core/core = swarmer_owner.team.swarmer_core
	if(!core || !in_range(core, swarmer_owner))
		owner.balloon_alert(swarmer_owner, "далеко от ядра!")
		return

	var/list/potential_hubs = get_hub_list()
	if(!length(potential_hubs))
		owner.balloon_alert(owner, "отсутствуют другие хабы!")
		return

	var/input_hub_key = tgui_input_list(owner, "Выберите хаб для телепорта ядра.", "Выбор хаба", potential_hubs) //we know what key they picked
	var/obj/structure/swarmer/transport_hub/actual_selected_hub = potential_hubs[input_hub_key] //what hub does that key correspond to?
	if(!core.Adjacent(owner) || !actual_selected_hub)
		return

	if(!adjust_swarmer_metallic_resources(-action_cost))
		owner.balloon_alert(owner, "недостаточно ресурсов!")
		return

	if(!do_after(owner, core_move_delay, core, max_interact_count = 1))
		owner.balloon_alert(owner, "нельзя двигаться!")
		adjust_swarmer_metallic_resources(action_cost) // Return spent resources
		return

	owner.balloon_alert(owner, "успешно телепортировано!")
	do_sparks(4, TRUE, core)
	var/turf/target_turf = get_turf(actual_selected_hub)
	core.forceMove(target_turf)
	qdel(actual_selected_hub)
	swarmer_shield_around_turf(target_turf, forcefield_radius, forcefield_duration)

/// Used to get a list of all active transport hubs
/datum/action/cooldown/swarmer/move_core/proc/get_hub_list()
	var/list/potential_hubs = list()
	var/list/hub_names = list()
	var/list/duplicate_hub_count = list()
	for(var/obj/structure/swarmer/transport_hub/hub in GLOB.swarmer_objects)
		if(!hub.enabled)
			continue
		var/resultkey = hub.listkey
		if(resultkey in hub_names)
			duplicate_hub_count[resultkey]++
			resultkey = "[resultkey] ([duplicate_hub_count[resultkey]])"
		else
			hub_names += resultkey
			duplicate_hub_count[resultkey] = 1
		potential_hubs[resultkey] = hub
	return potential_hubs

#undef SWARMER_BLOCKADE_COST
#undef SWARMER_TRAP_COST
#undef SWARMER_HUB_COST
#undef SWARMER_PROCESSER_COST
#undef SWARMER_ANALYZER_COST
#undef SWARMER_REPAIR_STATION_COST
#undef SWARMER_STORAGE_COST
#undef SWARMER_RAPID_TURRET_COST
#undef SWARMER_SNIPER_TURRET_COST
#undef SWARMER_ACP_COST
#undef SWARMER_NANOBOT_FABRICATOR_COST
