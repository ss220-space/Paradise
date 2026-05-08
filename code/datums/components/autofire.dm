/datum/component/automatedfire/autofire
	///The current fire mode of the shooter
	var/fire_mode
	///Delay between two shots when in full auto
	var/auto_fire_shot_delay
	///Delay between two burst shots
	var/burstfire_shot_delay
	///Delay between two volley of burst
	var/auto_burst_fire_shot_delay
	///How many bullets are fired in burst mode
	var/burst_shots_to_fire
	///Count the shots fired when bursting
	var/shots_fired = 0
	///If the shooter is currently shooting
	var/shooting = FALSE
	///If TRUE, the shooter will reset its references at the end of the burst
	var/have_to_reset_at_burst_end = FALSE
	///If we are in a burst
	var/bursting = FALSE
	///Callback to set bursting mode on the parent
	var/datum/callback/callback_bursting
	///Callback to ask the parent to reset its firing vars
	var/datum/callback/callback_reset_fire
	///Callback to ask the parent to fire
	var/datum/callback/callback_fire
	///windup autofire vars
	///Whether the delay between shots increases over time, simulating a spooling weapon
	var/windup_autofire = FALSE
	///the reduction to shot delay for windup
	var/current_windup_reduction = 0
	///the percentage of autfire_shot_delay that is added to current_windup_reduction
	var/windup_autofire_reduction_multiplier = 0.3
	///How high of a reduction that current_windup_reduction can reach
	var/windup_autofire_cap = 0.3
	///How long it takes for weapons that have spooled-up to reset back to the original firing speed
	var/windup_spindown = 3 SECONDS
	///Timer for tracking the spindown reset timings
	var/timerid

/datum/component/automatedfire/autofire/Initialize(auto_fire_shot_delay = 0.3 SECONDS, auto_burst_fire_shot_delay, burstfire_shot_delay, burst_shots_to_fire = 3, fire_mode = GUN_FIREMODE_SEMIAUTO, datum/callback/callback_bursting, datum/callback/callback_reset_fire, datum/callback/callback_fire, windup_autofire, windup_autofire_reduction_multiplier, windup_autofire_cap, windup_spindown)
	. = ..()

	RegisterSignal(parent, COMSIG_GUN_TOGGLE_FIREMODE, PROC_REF(modify_fire_mode))
	RegisterSignal(parent, COMSIG_GUN_AUTOFIREDELAY_MODIFIED, PROC_REF(modify_fire_shot_delay))
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOTS_TO_FIRE_MODIFIED, PROC_REF(modify_burst_shots_to_fire))
	RegisterSignal(parent, COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED, PROC_REF(modify_burstfire_shot_delay))
	RegisterSignal(parent, COMSIG_GUN_AUTO_BURST_SHOT_DELAY_MODIFIED, PROC_REF(modify_autoburstfire_shot_delay))
	RegisterSignal(parent, COMSIG_GUN_FIRE, PROC_REF(initiate_shot))
	RegisterSignal(parent, COMSIG_GUN_STOP_FIRE, PROC_REF(stop_firing))

	src.auto_fire_shot_delay = auto_fire_shot_delay
	src.burstfire_shot_delay = burstfire_shot_delay
	src.burst_shots_to_fire = burst_shots_to_fire
	src.auto_burst_fire_shot_delay = auto_burst_fire_shot_delay
	src.fire_mode = fire_mode
	src.callback_bursting = callback_bursting
	src.callback_reset_fire = callback_reset_fire
	src.callback_fire = callback_fire

	if(!windup_autofire)
		return

	src.windup_autofire = windup_autofire
	src.windup_autofire_reduction_multiplier = windup_autofire_reduction_multiplier
	src.windup_autofire_cap = windup_autofire_cap
	src.windup_spindown = windup_spindown

/datum/component/automatedfire/autofire/Destroy(force, silent)
	callback_fire = null
	callback_reset_fire = null
	callback_bursting = null
	return ..()

///Setter for fire mode
/datum/component/automatedfire/autofire/proc/modify_fire_mode(datum/source, mob/user, _fire_mode)
	SIGNAL_HANDLER
	fire_mode = _fire_mode

///Setter for auto fire shot delay
/datum/component/automatedfire/autofire/proc/modify_fire_shot_delay(datum/source, _auto_fire_shot_delay)
	SIGNAL_HANDLER
	auto_fire_shot_delay = _auto_fire_shot_delay

///Setter for the number of shot in a burst
/datum/component/automatedfire/autofire/proc/modify_burst_shots_to_fire(datum/source, _burst_shots_to_fire)
	SIGNAL_HANDLER
	burst_shots_to_fire = _burst_shots_to_fire

///Setter for burst shot delay
/datum/component/automatedfire/autofire/proc/modify_burstfire_shot_delay(datum/source, _burstfire_shot_delay)
	SIGNAL_HANDLER
	burstfire_shot_delay = _burstfire_shot_delay

///Setter for autoburst shot delay
/datum/component/automatedfire/autofire/proc/modify_autoburstfire_shot_delay(datum/source, _auto_burst_fire_shot_delay)
	SIGNAL_HANDLER
	auto_burst_fire_shot_delay = _auto_burst_fire_shot_delay

///Insert the component in the bucket system if it was not in already
/datum/component/automatedfire/autofire/proc/initiate_shot()
	SIGNAL_HANDLER
	if(shooting)//if we are already shooting, it means the shooter is still on cooldown
		if(bursting) //something went wrong due to lag
			hard_reset()
		return
	shooting = TRUE
	process_shot()

///Remove the component from the bucket system if it was in
/datum/component/automatedfire/autofire/proc/stop_firing()
	SIGNAL_HANDLER
	if(!shooting)
		return
	///We are burst firing, we can't clean the state now. We will do it when the burst is over
	if(bursting)
		have_to_reset_at_burst_end = TRUE
		return
	shooting = FALSE
	shots_fired = 0

///Hard reset the autofire, happens when the shooter fall/is thrown, at the end of a burst or when it runs out of ammunition
/datum/component/automatedfire/autofire/proc/hard_reset()
	callback_reset_fire?.Invoke() //resets the gun
	shots_fired = 0
	have_to_reset_at_burst_end = FALSE
	if(bursting)
		bursting = FALSE
		callback_bursting?.Invoke(FALSE)
	shooting = FALSE

///Ask the shooter to fire and schedule the next shot if need
/datum/component/automatedfire/autofire/process_shot()
	if(!shooting)
		return
	if(next_fire > world.time)//This mean duplication somewhere, we abort now
		return
	if(!(callback_fire?.Invoke() & AUTOFIRE_CONTINUE))//reset fire if we want to stop
		hard_reset()
		return
	switch(fire_mode)
		if(GUN_FIREMODE_BURSTFIRE)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				callback_bursting.Invoke(FALSE)
				bursting = FALSE
				stop_firing()
				if(have_to_reset_at_burst_end)//We failed to reset because we were bursting, we do it now
					callback_reset_fire.Invoke()
					have_to_reset_at_burst_end = FALSE
				return
			callback_bursting.Invoke(TRUE)
			bursting = TRUE
			next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOBURST)
			shots_fired++
			if(shots_fired == burst_shots_to_fire)
				next_fire = world.time + auto_burst_fire_shot_delay
				shots_fired = 0
				callback_bursting.Invoke(FALSE)
				bursting = FALSE
				if(have_to_reset_at_burst_end)//We failed to reset because we were bursting, we do it now
					callback_reset_fire.Invoke()
					stop_firing()
					have_to_reset_at_burst_end = FALSE
			else
				callback_bursting.Invoke(TRUE)
				bursting = TRUE
				next_fire = world.time + burstfire_shot_delay
		if(GUN_FIREMODE_AUTOMATIC)
			var/next_delay = auto_fire_shot_delay
			if(windup_autofire)
				next_delay = clamp(next_delay - current_windup_reduction,  auto_fire_shot_delay * windup_autofire_cap, auto_fire_shot_delay)
				current_windup_reduction = current_windup_reduction +  auto_fire_shot_delay * windup_autofire_reduction_multiplier
				timerid = addtimer(CALLBACK(src, PROC_REF(windup_reset), FALSE), windup_spindown, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
			next_fire = world.time + next_delay
		if(GUN_FIREMODE_SEMIAUTO)
			return
	schedule_shot()

/// Reset for our windup, resetting everything back to initial values after a variable set amount of time (determined by var/windup_spindown).
/datum/component/automatedfire/autofire/proc/windup_reset(deltimer)
	current_windup_reduction = initial(current_windup_reduction)
	if(deltimer && timerid)
		deltimer(timerid)
