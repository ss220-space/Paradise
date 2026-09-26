#define REMOTECAM_RANGE_FAR 7
#define REMOTECAM_RANGE_NEAR 2
#define REMOTECAM_ENERGY_USAGE_NEAR 30 //Normal components have 10, this is expensive to livestream footage
#define REMOTECAM_ENERGY_USAGE_FAR 80 //Far range vision should be expensive, crank this up 8 times
#define REMOTECAM_EMP_RESET 90 SECONDS

/**
 * № Remote Camera Component
 *
 * Attaches a camera for surveillance-on-the-go.
 */
/obj/item/circuit_component/remotecam
	display_name = "Абстрактная камера"
	desc = "Это абстрактный родительский тип — не используйте его напрямую!"
	category = "Entity"
	circuit_flags = CIRCUIT_NO_DUPLICATES

	/// Starts the cameraa
	var/datum/port/input/start
	/// Stops the program.
	var/datum/port/input/stop
	/// Camera range flag (near/far)
	var/datum/port/input/camera_range
	/// The network to use
	var/datum/port/input/network

	/// Allow camera range to be set or not
	var/camera_range_settable = TRUE
	/// Used only for the BCI shell type, as the COMSIG_MOVABLE_MOVED signal need to be assigned to the user mob, not the shell circuit
	var/camera_signal_move_override = FALSE

	/// Camera object
	var/obj/machinery/camera/shell_camera = null
	/// The shell storing the parent circuit
	var/atom/movable/shell_parent = null
	/// The shell's type (used for prefix naming)
	var/camera_prefix = "Камера"
	/// Camera random ID
	var/c_tag_random = 0

	/// Used to store the current process state
	var/current_camera_state = FALSE
	/// Used to store the current cameranet state
	var/current_cameranet_state = TRUE
	/// Used to store the camera emp state
	var/current_camera_emp = FALSE
	/// Used to store the camera emp timer id
	var/current_camera_emp_timer_id
	/// Used to store the last string used for the camera name
	var/current_camera_name = ""
	/// Used to store the current camera range setting (near/far)
	var/current_camera_range = 0
	/// Used to store the last string used for the camera network
	var/current_camera_network = ""

/obj/item/circuit_component/remotecam/Destroy()
	stop_process()
	remove_camera()
	shell_parent = null
	start = null
	stop = null
	camera_range = null
	network = null
	return ..()

/obj/item/circuit_component/remotecam/get_ui_notices()
	. = ..()
	if(camera_range_settable)
		. += create_ui_notice("Использование энергии для ближнего диапазона: [REMOTECAM_ENERGY_USAGE_NEAR] за [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")
		. += create_ui_notice("Использование энергии для дальнего диапазона: [REMOTECAM_ENERGY_USAGE_FAR] за [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")
		return

	. += create_ui_notice("Использование энергии пока активно: [current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR] за [DisplayTimeText(COMP_CLOCK_DELAY)]", "orange", "clock")

/obj/item/circuit_component/remotecam/populate_ports()
	start = add_input_port("Старт", PORT_TYPE_SIGNAL)
	stop = add_input_port("Стоп", PORT_TYPE_SIGNAL)

	if(camera_range_settable)
		camera_range = add_input_port("Дальность", PORT_TYPE_NUMBER, default = 0)

	network = add_input_port("Сеть", PORT_TYPE_STRING, default = "SS13")

	if(camera_range_settable)
		current_camera_range = camera_range.value

	c_tag_random = rand(1, 999)

/obj/item/circuit_component/remotecam/register_shell(atom/movable/shell)
	shell_parent = shell
	stop_process()

/obj/item/circuit_component/remotecam/unregister_shell(atom/movable/shell)
	stop_process()
	remove_camera()
	shell_parent = null

/obj/item/circuit_component/remotecam/input_received(datum/port/input/port)
	if(!shell_parent || !shell_camera)
		return

	update_camera_name()
	update_camera_network()

	if(COMPONENT_TRIGGERED_BY(start, port))
		start_process()
		cameranet_add()
		current_camera_state = TRUE

	if(!COMPONENT_TRIGGERED_BY(stop, port))
		return

	stop_process()
	close_camera() //Instantly turn off the camera
	current_camera_state = FALSE

/**
 * Initializes the camera
 */
/obj/item/circuit_component/remotecam/proc/init_camera()
	shell_camera.desc = "Эта камера — часть схемы. Если вы видите это описание, сообщите о баге!"
	shell_camera.use_power = NO_POWER_USE
	shell_camera.start_active = TRUE
	shell_camera.internal_light = FALSE
	current_camera_name = ""

	if(camera_range_settable)
		current_camera_range = camera_range.value

	current_cameranet_state = TRUE
	current_camera_emp = FALSE
	current_camera_network = ""
	close_camera()
	update_camera_range()
	update_camera_name()
	update_camera_network()

	if(current_camera_state)
		start_process()
		update_camera_location()
	else
		cameranet_remove() //Remove camera from global cameranet until user activates the camera first

	if(!camera_signal_move_override)
		RegisterSignal(shell_parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

	RegisterSignal(shell_parent, COMSIG_ATOM_EMP_ACT, PROC_REF(set_camera_emp))

/**
 * Remove the camera
 */
/obj/item/circuit_component/remotecam/proc/remove_camera()
	if(!shell_camera)
		return

	if(!camera_signal_move_override)
		UnregisterSignal(shell_parent, COMSIG_MOVABLE_MOVED)

	UnregisterSignal(shell_parent, COMSIG_ATOM_EMP_ACT)

	if(current_camera_emp)
		deltimer(current_camera_emp_timer_id)
		current_camera_emp = FALSE

	cameranet_add() //Readd camera to cameranet before deleting camera
	QDEL_NULL(shell_camera)

/**
 * Close the camera state (only if it's already active)
 */
/obj/item/circuit_component/remotecam/proc/close_camera()
	if(!shell_camera?.status)
		return

	shell_camera.toggle_cam(null, 0)

/**
 * Set the camera range
 */
/obj/item/circuit_component/remotecam/proc/update_camera_range()
	shell_camera.setViewRange(current_camera_range > 0 ? REMOTECAM_RANGE_FAR : REMOTECAM_RANGE_NEAR)

/**
 * Updates the camera network
 */
/obj/item/circuit_component/remotecam/proc/update_camera_network()
	if(!network.value || network.value == "")
		shell_camera.network = list("SS13")
		current_camera_network = ""
		return

	if(current_camera_network == network.value)
		return

	current_camera_network = network.value
	var/new_net_name = sanitize(current_camera_network)

	new_net_name = new_net_name ? new_net_name : "SS13"

	shell_camera.network = list("[new_net_name]")

/**
 * Updates the camera name
 */
/obj/item/circuit_component/remotecam/proc/update_camera_name()
	if(!parent || !parent.display_name || parent.display_name == "")
		shell_camera.c_tag = "[camera_prefix]: немаркированная №[c_tag_random]"
		current_camera_name = ""
		return

	if(current_camera_name == parent.display_name)
		return

	current_camera_name = parent.display_name
	var/new_cam_name = reject_bad_name(current_camera_name, allow_numbers = TRUE)

	new_cam_name = new_cam_name ? new_cam_name : "немаркированная"

	shell_camera.c_tag = "[camera_prefix]: [new_cam_name] №[c_tag_random]"

/**
 * Update the chunk for the camera (if enabled)
 */
/obj/item/circuit_component/remotecam/proc/update_camera_location(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	if(!current_camera_state || !current_cameranet_state)
		return

	GLOB.cameranet.updatePortableCamera(shell_camera, 0.5 SECONDS)

/**
 * Add camera from global cameranet
 */
/obj/item/circuit_component/remotecam/proc/cameranet_add()
	if(current_cameranet_state)
		return

	GLOB.cameranet.cameras += shell_camera
	GLOB.cameranet.addCamera(shell_camera)
	current_cameranet_state = TRUE

/**
 * Remove camera from global cameranet
 */
/obj/item/circuit_component/remotecam/proc/cameranet_remove()
	if(!current_cameranet_state)
		return

	GLOB.cameranet.removeCamera(shell_camera)
	GLOB.cameranet.cameras -= shell_camera
	current_cameranet_state = FALSE

/**
 * Set the camera as emp'd
 */
/obj/item/circuit_component/remotecam/proc/set_camera_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(current_camera_emp)
		return

	if(!prob(150 / severity))
		return

	current_camera_emp = TRUE
	close_camera()
	current_camera_emp_timer_id = addtimer(CALLBACK(src, PROC_REF(remove_camera_emp)), REMOTECAM_EMP_RESET, TIMER_STOPPABLE)
	for(var/mob/player as anything in GLOB.player_list)
		if(player.client?.eye != shell_camera)
			continue

		player.reset_perspective(null)
		to_chat(player, span_warning("Экран разрывается помехами!"))

/**
 * Restore emp'd camera
 */
/obj/item/circuit_component/remotecam/proc/remove_camera_emp()
	current_camera_emp = FALSE

/**
 * Adds the component to the SSclock_component process list
 *
 * Starts draining cell per second while camera is active
 */
/obj/item/circuit_component/remotecam/proc/start_process()
	START_PROCESSING(SSclock_component, src)

/**
 * Removes the component to the SSclock_component process list
 *
 * Stops draining cell per second
 */
/obj/item/circuit_component/remotecam/proc/stop_process()
	STOP_PROCESSING(SSclock_component, src)

/**
 * Handle power usage and camera state updating
 *
 * This is the generic abstract proc - subtypes with specialized logic should use their own copy of process()
 */
/obj/item/circuit_component/remotecam/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
	//Camera is currently emp'd
	if(current_camera_emp)
		close_camera()
		return

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return

	if(camera_range_settable)
		//If the camera range has changed, update camera range
		if(!camera_range.value != !current_camera_range)
			current_camera_range = camera_range.value
			update_camera_range()
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.status)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/bci
	display_name = "ИМК камера"
	desc = "Оцифровывает зрение пользователя для мобильного видеонаблюдения. \
			Для работы оцифровщика необходимо наличие полностью работоспособного зрения. \
			Диапазон действия камеры может быть ближним или дальним. Поле \"Сеть\" используется для настройки сети камер."
	category = "BCI"
	camera_prefix = "ИМК"
	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci)

	/// BCIs are organs, and thus the signal must be assigned ONLY when the shell has been installed in a mob - otherwise the camera will never update position
	camera_signal_move_override = TRUE

	/// Store the BCI owner as a variable, so we can remove the move signal if the user was gibbed/destroyed while the BCI is still installed
	var/mob/living/carbon/bciuser = null

/obj/item/circuit_component/remotecam/drone
	display_name = "Удаленная камера"
	desc = "Снимает окружающую обстановку для мобильного видеонаблюдения. \
			Диапазон действия камеры может быть ближним или дальним. Поле \"Сеть\" используется для настройки сети камеры."
	camera_prefix = "Drone"

/obj/item/circuit_component/remotecam/airlock
	display_name = "Камера-глазок"
	desc = "Камера-глазок, которая снимает происходящее с обеих сторон шлюза. \
			Сетевое поле используется для организации сети камер."
	camera_prefix = "Airlock"

	/// Hardcode camera to near range
	camera_range_settable = FALSE

/obj/item/circuit_component/remotecam/polaroid
	display_name = "Дополнение к потоковой передачи камеры"
	desc = "Передаёт изображение с камеры-полароида в виде цифрового потока для мобильного видеонаблюдения. \
			Видеопоток с камеры не будет работать, если она хранится в контейнере, например, в рюкзаке или коробке. \
			Поле \"Сеть\" используется для настройки сети камеры."
	camera_prefix = "Polaroid"

	/// Hardcode camera to near range
	camera_range_settable = FALSE

/obj/item/circuit_component/remotecam/bci/register_shell(atom/movable/shell)
	. = ..()
	if(!is_bci(shell_parent))
		return

	shell_camera = new(shell_parent)
	init_camera()
	RegisterSignal(shell_parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell_parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))
	var/obj/item/organ/internal/cyberimp/brain/bci/bci = shell_parent

	if(!bci.owner) //If somehow the camera was added while shell is already installed inside a mob, assign signals
		return

	if(bciuser) //This should never happen... But if it does, unassign move signal from old mob
		UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

	bciuser = bci.owner
	RegisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

/obj/item/circuit_component/remotecam/bci/unregister_shell(atom/movable/shell)
	if(!shell_camera)
		return ..()

	if(bciuser)
		UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
		bciuser = null

	UnregisterSignal(shell_parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	return ..()

/obj/item/circuit_component/remotecam/bci/Destroy()
	if(!shell_camera)
		return ..()

	if(bciuser)
		UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
		bciuser = null

	UnregisterSignal(shell_parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	return ..()

/obj/item/circuit_component/remotecam/bci/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	if(bciuser)
		return

	bciuser = owner
	RegisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))

/obj/item/circuit_component/remotecam/bci/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	if(!bciuser)
		return

	UnregisterSignal(bciuser, COMSIG_MOVABLE_MOVED, PROC_REF(update_camera_location))
	bciuser = null

/obj/item/circuit_component/remotecam/drone/register_shell(atom/movable/shell)
	. = ..()
	if(!is_circuit_drone(shell_parent))
		return

	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new(shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/airlock/register_shell(atom/movable/shell)
	. = ..()
	if(!is_airlock(shell_parent))
		return

	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new(shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/polaroid/register_shell(atom/movable/shell)
	. = ..()
	if(!is_camera(shell_parent))
		return

	current_camera_state = FALSE //Always reset camera state for built-in shell components
	shell_camera = new(shell_parent)
	init_camera()

/obj/item/circuit_component/remotecam/bci/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
	//Camera is currently emp'd
	if(current_camera_emp)
		close_camera()
		return

	var/obj/item/organ/internal/cyberimp/brain/bci/bci = shell_parent
	//If shell is not currently inside a head, or user is currently blind, or user is dead
	if(!bci.owner || !bci.owner.has_vision() || bci.owner.stat >= UNCONSCIOUS)
		close_camera()
		return

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(current_camera_range > 0 ? REMOTECAM_ENERGY_USAGE_FAR : REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//If owner is nearsighted, set camera range to short (if it wasn't already)
	if(HAS_TRAIT(bci.owner, TRAIT_NEARSIGHTED))
		if(current_camera_range)
			current_camera_range = 0
			update_camera_range()
	//Else if the camera range has changed, update camera range
	else if(!camera_range.value != !current_camera_range)
		current_camera_range = camera_range.value
		update_camera_range()
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.status)
		shell_camera.toggle_cam(null, 0)

/obj/item/circuit_component/remotecam/polaroid/process(seconds_per_tick)
	if(!shell_parent || !shell_camera)
		return PROCESS_KILL
	//Camera is currently emp'd
	if(current_camera_emp)
		close_camera()
		return

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	//If cell doesn't exist, or we ran out of power
	if(!cell?.use(REMOTECAM_ENERGY_USAGE_NEAR))
		close_camera()
		return
	//Set the camera state (if state has been changed)
	if(current_camera_state ^ shell_camera.status)
		shell_camera.toggle_cam(null, 0)

#undef REMOTECAM_RANGE_FAR
#undef REMOTECAM_RANGE_NEAR
#undef REMOTECAM_ENERGY_USAGE_NEAR
#undef REMOTECAM_ENERGY_USAGE_FAR
#undef REMOTECAM_EMP_RESET
