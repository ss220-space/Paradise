#define RAISE_FIRE_COUNT 3
#define RAISE_FIRE_TIME 3

/datum/hallucination/fire
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// Are we currently burning our mob?
	var/active = TRUE
	/// What stage of fire are we in?
	var/stage = 0

	/// What icon file to use for our hallucinator
	var/fire_icon = 'icons/mob/OnFire.dmi'
	/// What icon state to use for our hallucinator
	var/fire_icon_state = "human_fire"
	/// Our fire overlay we generate
	var/image/fire_overlay

	/// When should we do our next action of the hallucination?
	var/next_action = 0
	/// How many times do we apply stamina damage to our mob?
	var/times_to_lower_stamina
	/// Are we currently fake-clearing our hallucinated fire?
	var/fire_clearing = FALSE
	/// Are the stages going up or down?
	var/increasing_stages = TRUE
	/// How long have we spent on fire?
	var/time_spent = 0

/datum/hallucination/fire/proc/make_overlay()
	var/image/new_overlay = image(fire_icon, hallucinator, fire_icon_state, ABOVE_MOB_LAYER)
	new_overlay.appearance_flags = RESET_COLOR
	return new_overlay

/datum/hallucination/fire/start()
	fire_overlay = make_overlay()
	if(!fire_overlay)
		return FALSE

	hallucinator.client?.images |= fire_overlay
	to_chat(hallucinator, span_userdanger("Вы горите!"))
	hallucinator.throw_alert("fire", /atom/movable/screen/alert/fire, override = TRUE)
	times_to_lower_stamina = rand(5, 10)
	addtimer(CALLBACK(src, PROC_REF(start_expanding)), 2 SECONDS)
	return TRUE

/datum/hallucination/fire/Destroy()
	hallucinator.clear_alert("fire", clear_override = TRUE)
	hallucinator.clear_alert("temp", clear_override = TRUE)
	if(fire_overlay)
		hallucinator.client?.images -= fire_overlay
		fire_overlay = null

	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/hallucination/fire/proc/start_expanding()
	if(QDELETED(src))
		return

	START_PROCESSING(SSfastprocess, src)

/datum/hallucination/fire/process(seconds_per_tick)
	if(QDELETED(src))
		return

	time_spent += seconds_per_tick

	if(fire_clearing)
		next_action -= seconds_per_tick
		if(next_action < 0)
			stage -= 1
			update_temp()
			next_action += 3

	else if(increasing_stages)
		var/new_stage = min(round(time_spent / RAISE_FIRE_TIME), RAISE_FIRE_COUNT)
		if(stage != new_stage)
			stage = new_stage
			update_temp()

			if(stage == RAISE_FIRE_COUNT)
				increasing_stages = FALSE

	else if(times_to_lower_stamina)
		next_action -= seconds_per_tick
		if(next_action < 0)
			hallucinator.adjustStaminaLoss(15)
			next_action += 2
			times_to_lower_stamina -= 1

	else
		clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		hallucinator.clear_alert("temp", clear_override = TRUE)
		if(!active)
			qdel(src)
	else
		hallucinator.clear_alert("temp", clear_override = TRUE)
		hallucinator.throw_alert("temp", /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return

	active = FALSE
	hallucinator.clear_alert("fire", clear_override = TRUE)
	if(fire_overlay)
		hallucinator.client?.images -= fire_overlay
		fire_overlay = null
	fire_clearing = TRUE
	next_action = 0

#undef RAISE_FIRE_COUNT
#undef RAISE_FIRE_TIME
