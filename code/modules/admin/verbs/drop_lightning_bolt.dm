#define MODE_CKEY "По игроку"
#define MODE_POINTER "По указателю"
#define WARNING_MESSAGE span_warningbig("Вы чувствуете что-то неладное, в воздухе разливается металлический привкус и волосы встают дыбом...")
#define DEFAULT_DAMAGE 100
#define DEFAULT_RADIUS 3
#define DEFAULT_DELAY 3
#define SELECT_PLAYER_TEXT "NO_CKEY"

ADMIN_VERB(drop_lightning_bolt, R_EVENT, "Drop lightning bolt", "Вызвать молнию различной силы под вами.", ADMIN_CATEGORY_FUN)
	if(!SSticker?.mode)
		tgui_alert(user, "Нельзя вызывать молнии до начала раунда!", "Предупреждение")
		return

	var/datum/drop_lightning_bolt_ui/editor = new()
	editor.ui_interact(user.mob)

/datum/drop_lightning_bolt_ui
	/// Client of the admin using this interface
	var/client/client
	/// Mob targeted by CKEY mode
	var/mob/living/victim_mob
	/// Turf targeted by pointer mode
	var/turf/victim_turf
	/// Current targeting mode (MODE_CKEY or MODE_POINTER)
	var/mode
	/// Damage applied by the lightning
	var/damage = DEFAULT_DAMAGE
	/// Effect radius around target
	var/radius = DEFAULT_RADIUS
	/// Delay before strike in seconds
	var/delay = DEFAULT_DELAY
	var/list/players
	/// Whether pointer mode is active
	var/pointing = FALSE
	/// Optional reason shown to target
	var/reason

/datum/drop_lightning_bolt_ui/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/drop_lightning_bolt_ui/ui_interact(mob/user, datum/tgui/ui)
	client = user.client
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DropLightningBolt")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/drop_lightning_bolt_ui/ui_static_data(mob/user)
	. = ..()

	players = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(!player.ckey)
			continue

		var/display_name = player.real_name || player.name
		players[player.ckey] = "[display_name] | [player.ckey] "

	.["players"] = players

/datum/drop_lightning_bolt_ui/ui_data(mob/user)
	. = ..()

	.["damage"] = damage
	.["radius"] = radius
	.["delay"] = delay
	.["mode"] = mode
	.["ckey"] = victim_mob?.ckey || SELECT_PLAYER_TEXT
	.["pointing"] = pointing

/datum/drop_lightning_bolt_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE

	switch(action)
		if("pick_player")
			handle_player_selection(params["ckey"])
		if("set_mode")
			handle_mode_change(params["mode"])
		if("set_damage")
			damage = text2num(params["damage"]) || DEFAULT_DAMAGE
		if("set_radius")
			radius = text2num(params["radius"]) || DEFAULT_RADIUS
		if("set_delay")
			handle_delay_change(params["delay"])
		if("drop")
			prepare_bolt()
		if("set_pointing")
			handle_pointing_toggle(params["val"])
		else
			. = FALSE

/datum/drop_lightning_bolt_ui/ui_close(mob/user)
	disable_pointing()
	qdel(src)

/datum/drop_lightning_bolt_ui/Destroy(force)
	client = null
	victim_mob = null
	victim_turf = null
	return ..()

/**
 * Handles selection of player by CKEY
 *
 * Arguments:
 * * ckey - Player's CKEY to target
 */
/datum/drop_lightning_bolt_ui/proc/handle_player_selection(ckey)
	if(!ckey || ckey == SELECT_PLAYER_TEXT)
		victim_mob = null
		victim_turf = null
	else
		victim_mob = get_mob_by_ckey(ckey)
		victim_turf = null
		mode = MODE_CKEY

/**
 * Changes targeting mode
 *
 * Arguments:
 * * new_mode - MODE_CKEY or MODE_POINTER
 */
/datum/drop_lightning_bolt_ui/proc/handle_mode_change(new_mode)
	mode = new_mode
	disable_pointing()

/**
 * Updates strike delay
 *
 * Arguments:
 * * delay_param - New delay value in seconds
 */
/datum/drop_lightning_bolt_ui/proc/handle_delay_change(delay_param)
	var/new_delay = text2num(delay_param)
	if(isnull(new_delay))
		return

	delay = clamp(new_delay, 0, 1 MINUTES)

/**
 * Toggles pointer targeting mode
 *
 * Arguments:
 * * enable - TRUE to enable, FALSE to disable
 */
/datum/drop_lightning_bolt_ui/proc/handle_pointing_toggle(enable)
	pointing = enable

	if(!client)
		return

	if(pointing && !client.click_intercept)
		client.click_intercept = new /datum/click_intercept/lightning_bolt_dropper(client, src)
	else if(!pointing && client.click_intercept)
		QDEL_NULL(client.click_intercept)

/**
 * Disables pointer mode
 *
 * Cleans up click interception if active.
 */
/datum/drop_lightning_bolt_ui/proc/disable_pointing()
	pointing = FALSE
	if(client?.click_intercept)
		QDEL_NULL(client.click_intercept)

/**
 * Initiates lightning strike
 *
 * Validates target, warns players, and schedules the bolt.
 *
 * Returns:
 * TRUE if strike was scheduled, FALSE on error.
 */
/datum/drop_lightning_bolt_ui/proc/prepare_bolt()
	if(!validate_target())
		to_chat(usr, span_warning("Ошибка: не выбрана цель или режим!"))
		return FALSE

	var/turf/target_turf = get_target_turf()
	if(!target_turf)
		return FALSE

	warn_players(target_turf)
	addtimer(CALLBACK(src, PROC_REF(drop_bolt), target_turf), delay SECONDS)
	return TRUE

/**
 * Validates current target selection
 *
 * Returns:
 * TRUE if target is valid for current mode, FALSE otherwise.
 */
/datum/drop_lightning_bolt_ui/proc/validate_target()
	if(!mode)
		return FALSE

	if(mode == MODE_CKEY)
		return !!victim_mob

	else if(mode == MODE_POINTER)
		return !!victim_turf || !!victim_mob

	return FALSE

/**
 * Gets target turf based on mode
 *
 * Returns:
 * Target turf for the lightning strike.
 */
/datum/drop_lightning_bolt_ui/proc/get_target_turf()
	if(mode == MODE_CKEY && victim_mob)
		return get_turf(victim_mob)

	else if(mode == MODE_POINTER)
		return victim_turf || (victim_mob && get_turf(victim_mob))

/**
 * Warns players in affected area
 *
 * Arguments:
 * * target_turf - Center of warning area
 */
/datum/drop_lightning_bolt_ui/proc/warn_players(turf/target_turf)
	if(radius > 1)
		for(var/mob/living/living_mob in range(radius, target_turf))
			to_chat(living_mob, WARNING_MESSAGE)
	else if(victim_mob)
		to_chat(victim_mob, WARNING_MESSAGE)

/**
 * Executes lightning strike
 *
 * Arguments:
 * * target_turf - Where to strike
 */
/datum/drop_lightning_bolt_ui/proc/drop_bolt(turf/target_turf)
	target_turf = get_target_turf()
	if(!target_turf)
		return

	admin_drop_lightning_bolt(
		target_turf = target_turf,
		damage = damage,
		radius = radius,
		delay = 0,
		reason = reason,
		specific_victim = victim_mob,
		admin_user = usr,
		warn_players = FALSE
	)

/**
 * Click interceptor for pointer targeting
 */
/datum/click_intercept/lightning_bolt_dropper
	/// Parent UI datum
	var/datum/drop_lightning_bolt_ui/dropper
	/// Mouse icon when button is not pressed
	var/static/icon/mouse_up_icon = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'
	/// Mouse icon when button is pressed
	var/static/icon/mouse_down_icon = 'icons/effects/mouse_pointers/supplypod_pickturf_down.dmi'

/datum/click_intercept/lightning_bolt_dropper/New(client/owner, datum/drop_lightning_bolt_ui/admin)
	..()
	dropper = admin
	if(!holder)
		qdel(src)
		return

	holder.mouse_up_icon = mouse_up_icon
	holder.mouse_down_icon = mouse_down_icon
	holder.mouse_override_icon = mouse_up_icon
	holder.mouse_pointer_icon = holder.mouse_override_icon

/datum/click_intercept/lightning_bolt_dropper/Destroy()
	if(holder)
		holder.mouse_up_icon = null
		holder.mouse_down_icon = null
		holder.mouse_override_icon = null
		holder.mouse_pointer_icon = initial(holder.mouse_pointer_icon)
	dropper = null
	return ..()

/datum/click_intercept/lightning_bolt_dropper/InterceptClickOn(mob/user, params, atom/object)
	if(!dropper?.pointing)
		return FALSE

	if(is_screen_atom(object))
		return FALSE

	select_target(object)
	prepare_lightning_for_target(user)
	user.face_atom(object)
	return TRUE

/**
 * Updates target based on clicked atom
 *
 * Arguments:
 * * object - Clicked atom to target
 */
/datum/click_intercept/lightning_bolt_dropper/proc/select_target(atom/object)
	if(ismob(object))
		dropper.victim_mob = object
		dropper.victim_turf = null
		dropper.mode = MODE_POINTER
	else
		dropper.victim_turf = get_turf(object)
		dropper.victim_mob = null
		dropper.mode = MODE_POINTER

/**
 * Prepares and schedules lightning strike for current target
 *
 * Arguments:
 * * user - Admin user who triggered the lightning
 */
/datum/click_intercept/lightning_bolt_dropper/proc/prepare_lightning_for_target(mob/user)
	if(!dropper.validate_target())
		to_chat(user, span_warning("Error: no target or mode selected!"))
		return FALSE

	// Capture current target values locally before they change
	var/turf/target_turf = dropper.get_target_turf()
	var/mob/living/target_mob = dropper.victim_mob
	var/damage = dropper.damage
	var/radius = dropper.radius
	var/delay = dropper.delay
	var/reason = dropper.reason

	if(!target_turf)
		return FALSE

	// Warn players at the captured location
	if(radius > 1)
		for(var/mob/living/living_mob in range(radius, target_turf))
			to_chat(living_mob, WARNING_MESSAGE)
	else if(target_mob)
		to_chat(target_mob, WARNING_MESSAGE)

	// Schedule lightning with captured values
	if(delay > 0)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(admin_drop_lightning_bolt),
			target_turf, damage, radius, 0, reason, target_mob, user, FALSE), delay SECONDS)
	else
		admin_drop_lightning_bolt(
			target_turf = target_turf,
			damage = damage,
			radius = radius,
			delay = 0,
			reason = reason,
			specific_victim = target_mob,
			admin_user = user,
			warn_players = FALSE
		)

	return TRUE

/**
 * Drops a lightning bolt at the specified location
 *
 * Arguments:
 * * target_turf - Turf where the lightning will strike
 * * damage - Damage to apply
 * * radius - Effect radius
 * * delay - Delay before strike in seconds
 * * reason - Reason shown to target
 * * specific_victim - Specific target (for reason message)
 * * admin_user - Admin who called the lightning (for logs)
 * * warn_players - Whether to warn players in advance
 */
/proc/admin_drop_lightning_bolt(
	turf/target_turf,
	damage = DEFAULT_DAMAGE,
	radius = DEFAULT_RADIUS,
	delay = 0,
	reason = null,
	mob/living/specific_victim = null,
	mob/admin_user = null,
	warn_players = TRUE
)
	if(!target_turf)
		CRASH("Attempted to drop lightning bolt without a target_turf")

	if(warn_players)
		if(radius > 1)
			for(var/mob/living/living_mob in range(radius, target_turf))
				to_chat(living_mob, WARNING_MESSAGE)
		else if(specific_victim)
			to_chat(specific_victim, WARNING_MESSAGE)

	if(delay > 0)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_execute_lightning_bolt), target_turf, damage, radius, reason, specific_victim, admin_user), delay SECONDS)
	else
		_execute_lightning_bolt(target_turf, damage, radius, reason, specific_victim, admin_user)

/**
 * Internal proc for executing lightning strike
 *
 * Arguments:
 * * target_turf - The turf where the lightning strikes
 * * damage - Amount of burn damage to apply
 * * radius - Area of effect around the target
 * * reason - Optional reason shown to specific_victim
 * * specific_victim - Optional mob to receive the reason message
 * * admin_user - Admin mob that triggered the lightning (for logging)
 */
/proc/_execute_lightning_bolt(
	turf/target_turf,
	damage,
	radius,
	reason,
	mob/living/specific_victim,
	mob/admin_user
)
	// Visual effect
	new /obj/effect/temp_visual/thunderbolt/fancy(target_turf, damage <= 10)

	// Apply damage
	for(var/mob/living/living_mob in range(radius, target_turf))
		if(isobserver(living_mob))
			continue

		living_mob.Jitter(10 SECONDS)
		living_mob.apply_damage(damage, BURN)
		living_mob.updatehealth("admin lightning bolt")

	// Show reason message to specific victim
	if(reason && specific_victim)
		to_chat(specific_victim, span_userdanger("Молния бьёт вас из пустоты! Боги наказали вас за [reason]!"))

	if(admin_user)
		log_admin("[key_name(admin_user)] dropped lightning bolt at [target_turf] with damage=[damage], radius=[radius]")
		message_admins("[key_name_admin(admin_user)] dropped lightning bolt at [ADMIN_COORDJMP(target_turf)] with damage=[damage], radius=[radius]")

#undef MODE_CKEY
#undef MODE_POINTER
#undef WARNING_MESSAGE
#undef DEFAULT_DAMAGE
#undef DEFAULT_RADIUS
#undef DEFAULT_DELAY
#undef SELECT_PLAYER_TEXT
