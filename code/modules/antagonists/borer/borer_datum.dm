#define REPRODUCTIONS_TO_MATURE 3
#define REPRODUCTIONS_TO_ADULT 6
#define REPRODUCTIONS_TO_ELDER 10
#define HEAD_FOCUS_COST 9
#define TORSO_FOCUS_COST 15
#define HANDS_FOCUS_COST 5
#define LEGS_FOCUS_COST 10
#define SCALING_MAX_CHEM 355
#define SCALING_CHEM_GAIN 15
#define BORER_RANK_YOUNG /datum/borer_rank/young
#define BORER_RANK_MATURE /datum/borer_rank/mature
#define BORER_RANK_ADULT /datum/borer_rank/adult
#define BORER_RANK_ELDER /datum/borer_rank/elder

/datum/antagonist/borer
	name = "Cortical borer"
	show_in_roundend = FALSE
	job_rank = ROLE_BORER
	special_role = SPECIAL_ROLE_BORER
	var/mob/living/simple_animal/borer/user // our borer
	var/mob/living/carbon/human/host // our host
	var/mob/living/carbon/human/previous_host // previous host, used to del transferable effects from previous host.
	var/datum/borer_rank/borer_rank
	var/list/learned_focuses = list() // what focuses learned borer
	var/datum/borer_misc/change_host_and_scale/scaling = new // chemical scaling, gained when acquired unique host
	var/tick_interval = 1 SECONDS

/datum/antagonist/borer/apply_innate_effects(mob/living/simple_animal/borer/borer)
	. = ..()
	user = borer || owner.current
	if(QDELETED(user))
		qdel(src)
		return FALSE
	RegisterSignal(user, COMSIG_BORER_ENTERED_HOST, PROC_REF(entered_host))
	RegisterSignal(user, COMSIG_BORER_LEFT_HOST, PROC_REF(left_host))
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) 
	RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))
	sync()
	if(tick_interval != -1)
		tick_interval = world.time + tick_interval
	if(!(tick_interval > world.time))
		return FALSE
	if(user.stat != DEAD)
		START_PROCESSING(SSprocessing, src)
	return TRUE

/datum/antagonist/borer/proc/sync()
	borer_rank = user.borer_rank
	host = user.host
	previous_host = host
	parent_sync()
	return

/datum/antagonist/borer/proc/parent_sync()
	scaling?.parent = src
	borer_rank.parent = src
	for(var/datum/borer_focus/focus as anything in learned_focuses)
		focus.parent = src
	return

/datum/antagonist/borer/greet()
	var/list/messages = list()
	messages.Add(span_notice("Вы - Мозговой Червь!"))
	messages.Add("Забирайтесь в голову своей жертвы, используйте скрытность, убеждение и свои способности к управлению разумом, чтобы сохранить себя, своё потомство и своего носителя в безопасности и тепле.")
	messages.Add("Сахар сводит на нет ваши способности, избегайте его любой ценой!")
	messages.Add("Вы можете разговаривать со своими коллегами-борерами, используя '[get_language_prefix(LANGUAGE_HIVE_BORER)]'.")
	messages.Add("Воспроизведение себе подобных увеличивает количество эволюционных очков и позволяет перейти на следующий ранг.")
	messages.Add("Ваш текущий ранг - [borer_rank.rankname].")
	return messages
	
/datum/antagonist/borer/proc/entered_host()
	SIGNAL_HANDLER
	host = user.host
	if(pre_grant_movable_effect())
		previous_host = host

/datum/antagonist/borer/proc/left_host()
	SIGNAL_HANDLER
	host = null
	if(pre_remove_movable_effect())
		previous_host = host

/datum/antagonist/borer/proc/pre_grant_movable_effect()
	if(QDELETED(user) || QDELETED(host))
		return
		
	for(var/datum/borer_focus/focus as anything in learned_focuses)
		if(!focus.movable_granted)
			focus.movable_granted = TRUE
			if(!host.ckey)
				focus.is_catathonic = TRUE
			focus.grant_movable_effect()

	scaling?.grant_movable_effect()
	
	return

/datum/antagonist/borer/proc/pre_remove_movable_effect()
	if(QDELETED(user) || QDELETED(previous_host))
		return

	for(var/datum/borer_focus/focus as anything in learned_focuses)
		if(focus.movable_granted)
			focus.movable_granted = FALSE
			focus.remove_movable_effect()
			focus.is_catathonic = FALSE // now we can set it manually without checks.

	return

/datum/antagonist/borer/Destroy(force)
	UnregisterSignal(user, COMSIG_BORER_ENTERED_HOST)
	UnregisterSignal(user, COMSIG_BORER_LEFT_HOST)
	UnregisterSignal(user, COMSIG_MOB_DEATH)
	UnregisterSignal(user, COMSIG_LIVING_REVIVE)
	pre_remove_movable_effect()
	STOP_PROCESSING(SSprocessing, src)
	QDEL_NULL(borer_rank)
	QDEL_NULL(learned_focuses)
	QDEL_NULL(scaling)
	user = null
	host = null
	previous_host = null
	return ..()

/datum/antagonist/borer/proc/on_mob_death()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/borer/proc/on_mob_revive()
	SIGNAL_HANDLER
	if(tick_interval > world.time)
		START_PROCESSING(SSprocessing, src)

/datum/antagonist/borer/process(seconds_per_tick)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(QDELETED(user))
		qdel(src)
		return
	if(tick_interval != -1 && tick_interval <= world.time)
		var/tick_length = initial(tick_interval)
		for(var/datum/borer_focus/focus as anything in learned_focuses)
			focus.tick(tick_length / (1 SECONDS))
		borer_rank.tick(tick_length / (1 SECONDS))
		tick_interval = world.time + tick_length
		if(QDELING(src))
			return

/datum/borer_misc // category for small datums.
	var/datum/antagonist/borer/parent
	var/movable_granted = FALSE

/datum/borer_misc/Destroy(force)
	parent = null
	return ..()

/datum/borer_misc/proc/grant_movable_effect()
	return

/datum/borer_misc/change_host_and_scale
	var/list/used_UIDs = list()

/datum/borer_misc/change_host_and_scale/grant_movable_effect()
	if(parent.user.max_chems >= SCALING_MAX_CHEM)
		qdel(src)
		return

	if(parent.host.ckey && !LAZYIN(parent.host.UID(), used_UIDs))
		parent.user.max_chems += SCALING_CHEM_GAIN
		used_UIDs += parent.host.UID()

	return TRUE

/datum/borer_misc/change_host_and_scale/Destroy(force)
	LAZYNULL(used_UIDs)
	return ..()

/datum/borer_rank
	var/rankname = "Error"
	var/required_reproductions = null // how many reproductions we need to gain new rank
	var/datum/antagonist/borer/parent
	var/mob/living/simple_animal/borer/owner
	
/datum/borer_rank/Destroy(force)
	parent = null
	owner = null
	return ..()

/datum/borer_rank/proc/update_rank()
	switch(owner.borer_rank)
		if(BORER_RANK_YOUNG)
			owner.borer_rank = new BORER_RANK_MATURE(owner)
		if(BORER_RANK_MATURE)
			owner.borer_rank = new BORER_RANK_ADULT(owner)
		if(BORER_RANK_ADULT)
			owner.borer_rank = new BORER_RANK_ELDER(owner)
	return TRUE

/datum/borer_rank/New(mob/living/simple_animal/borer/borer)
	owner = borer
	parent = borer.antag_datum
	on_apply()

/datum/borer_rank/proc/on_apply()
	return

/datum/borer_rank/proc/tick(seconds_between_ticks)
	return

/datum/borer_rank/young
	rankname = "Young"
	required_reproductions = REPRODUCTIONS_TO_MATURE 

/datum/borer_rank/mature
	rankname = "Mature"
	required_reproductions = REPRODUCTIONS_TO_ADULT 

/datum/borer_rank/adult
	rankname = "Adult"
	required_reproductions = REPRODUCTIONS_TO_ELDER

/datum/borer_rank/elder
	rankname = "Elder"

/datum/borer_rank/young/on_apply()
	owner.update_transform(0.5) // other ranks should be gained and processed only with antag datum
	return TRUE

/datum/borer_rank/mature/on_apply()
	parent.user.update_transform(2)
	parent.user.maxHealth += 5
	return TRUE

/datum/borer_rank/adult/on_apply()
	parent.user.maxHealth += 5
	return TRUE

/datum/borer_rank/elder/on_apply()
	parent.user.maxHealth += 10
	return TRUE

/datum/borer_rank/young/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.1)

/datum/borer_rank/mature/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.15)

/datum/borer_rank/adult/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.2)
	if(parent.host?.stat != DEAD && !parent.user.sneaking)
		parent.user.chemicals += 0.2

/datum/borer_rank/elder/tick(seconds_between_ticks)
	parent.user.adjustHealth(-0.3)
	if(parent.host?.stat != DEAD)
		parent.host?.heal_overall_damage(0.4, 0.4)
		parent.user.chemicals += 0.3

/datum/borer_focus
	var/bodypartname = "Focus"
	var/cost = 0
	var/datum/antagonist/borer/parent
	var/movable_granted = FALSE
	var/is_catathonic = FALSE // Ckey isn't a constant value. So, check only on this.

/datum/borer_focus/New(mob/living/simple_animal/borer/borer)
	parent = borer.antag_datum
	parent?.pre_grant_movable_effect()

/datum/borer_focus/proc/tick(seconds_between_ticks)
	return

/datum/borer_focus/proc/grant_movable_effect()
	return

/datum/borer_focus/proc/remove_movable_effect()
	return

/datum/borer_focus/Destroy(force)
	parent = null
	return ..()

/datum/borer_focus/head
	bodypartname = "Head focus"
	cost = HEAD_FOCUS_COST
	
/datum/borer_focus/torso
	bodypartname = "Body focus"
	cost = TORSO_FOCUS_COST
	var/obj/item/organ/internal/heart/linked_organ
	
/datum/borer_focus/hands
	bodypartname = "Hands focus"
	cost = HANDS_FOCUS_COST
	
/datum/borer_focus/legs
	bodypartname = "Legs focus"
	cost = LEGS_FOCUS_COST
	
/datum/borer_focus/head/grant_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brain_mod *= 0.85
		parent.host.physiology.hunger_mod *= 0.75
		parent.host.stam_regen_start_modifier *= 0.875
		return TRUE
	parent.host.physiology.brain_mod *= 0.7
	parent.host.physiology.hunger_mod *= 0.5
	parent.host.stam_regen_start_modifier *= 0.75
	return TRUE

/datum/borer_focus/head/remove_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brain_mod /= 0.85
		parent.host.physiology.hunger_mod /= 0.75
		parent.host.stam_regen_start_modifier /= 0.875
		return TRUE
	parent.previous_host.physiology.brain_mod /= 0.7
	parent.previous_host.physiology.hunger_mod /= 0.3
	parent.previous_host.stam_regen_start_modifier /= 0.75
	return TRUE

/datum/borer_focus/head/tick(seconds_between_ticks)
	if(!parent.user.controlling && parent.host?.stat != DEAD)
		parent.host?.adjustBrainLoss(-1)
			
/datum/borer_focus/torso/grant_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brute_mod *= 0.9
		return TRUE
	parent.host.physiology.brute_mod *= 0.8
	return TRUE

/datum/borer_focus/torso/remove_movable_effect()
	if(!is_catathonic)
		parent.host.physiology.brute_mod /= 0.9
		return TRUE
	parent.previous_host.physiology.brute_mod /= 0.8
	return TRUE

/datum/borer_focus/torso/tick(seconds_between_ticks)
	if(parent.host?.stat != DEAD)
		linked_organ = parent.host?.get_int_organ(/obj/item/organ/internal/heart)
		if(linked_organ)
			parent.host?.set_heartattack(FALSE)

/datum/borer_focus/torso/Destroy(force)
	linked_organ = null
	return ..()
		
/datum/borer_focus/hands/grant_movable_effect()
	parent.host.add_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.host.physiology.punch_damage_low += 7
	parent.host.physiology.punch_damage_high += 5
	parent.host.next_move_modifier *= 0.75
	return TRUE

/datum/borer_focus/hands/remove_movable_effect()
	parent.previous_host.remove_actionspeed_modifier(/datum/actionspeed_modifier/borer_arm_focus)
	parent.previous_host.physiology.punch_damage_low -= 7
	parent.previous_host.physiology.punch_damage_high -= 5	
	parent.previous_host.next_move_modifier /= 0.75
	return TRUE
	
/datum/borer_focus/legs/grant_movable_effect()
	if(!is_catathonic)
		parent.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE
	parent.host.add_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE

/datum/borer_focus/legs/remove_movable_effect()
	if(!is_catathonic)
		parent.previous_host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus/lesser)
		return TRUE
	parent.previous_host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_focus)
	return TRUE

//borer roundstart reagents located at GLOB.borer_reagents.
/datum/reagent
	var/chemdesc // borer special chemical description.
	var/chemuse = 30
	var/quantity = 10

/datum/reagent/capulettium_plus
	chemdesc = "Silences and masks pulse."
	
/datum/reagent/medicine/charcoal
	chemdesc = "Slowly heals toxin damage, also slowly removes other chemicals."
	
/datum/reagent/medicine/epinephrine
	chemdesc = "Stabilizes critical condition and slowly heals suffocation damage."
	
/datum/reagent/fliptonium
	chemdesc = "Causes uncontrollable flipping."
	chemuse = 50
	
/datum/reagent/medicine/hydrocodone
	chemdesc = "An extremely strong painkiller."
	
/datum/reagent/medicine/mannitol
	chemdesc = "Heals brain damage."
	
/datum/reagent/methamphetamine
	chemdesc = "Reduces stun times and increases stamina. Deals small amounts of brain damage."
	chemuse = 50
	
/datum/reagent/medicine/mitocholide
	chemdesc = "Heals internal organ damage."
	
/datum/reagent/medicine/salbutamol
	chemdesc = "Heals suffocation damage."
	
/datum/reagent/medicine/salglu_solution
	chemdesc = "Slowly heals brute and burn damage, also slowly restores blood."

/datum/reagent/medicine/spaceacillin
	chemdesc = "Slows progression of diseases and fights infections."

/datum/action/innate/borer
	background_icon_state = "bg_alien"
	var/mob/living/simple_animal/borer/borer
	var/mob/living/carbon/human/host
	var/host_req = FALSE
	var/docile_message = span_notice("<font color='blue'>Вы слишком обессилели для этого.</font>")
	var/stat_message = "Вы не можете сделать этого в вашем нынешнем состоянии."
	var/chem_cost = 0
	
/datum/action/innate/borer/Grant(mob/user)
	. = ..()
	if(ishuman(user))
		host = user
		borer = host.has_brain_worms()
	if(isborer(user))
		borer = user

/datum/action/innate/borer/IsAvailable()
	if(!borer)
		return FALSE
	if(borer.stat) // No AB_CHECK_CONSCIOUS, we should do something even host is dead.
		to_chat(usr, stat_message)
		return FALSE
	if(borer.docile)
		to_chat(borer, docile_message)
		return FALSE
	if(host_req && !borer.host)
		return FALSE
	if(borer.chemicals < chem_cost && borer.chemicals >= 0)
		to_chat(usr, "Вам требуется еще [chem_cost - borer.chemicals] химикатов для использования способности.")
		return FALSE
	. = ..()

/datum/action/innate/borer/Remove(mob/user)
	. = ..()
	borer = null
	host = null
	
/datum/action/innate/borer/Destroy(force)
	borer = null
	host = null
	return ..()	
	
/datum/action/innate/borer/talk_to_host
	name = "Converse with Host"
	desc = "Send a silent message to your host."
	button_icon_state = "alien_whisper"
	host_req = TRUE

/datum/action/innate/borer/talk_to_host/Activate()
	borer = owner
	borer.Communicate()

/datum/action/innate/borer/toggle_hide
	name = "Toggle Hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	borer = owner
	borer.hide_borer()
	button_icon_state = "borer_hiding_[borer.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Converse with Borer"
	desc = "Communicate mentally with your borer."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	borer.host = owner
	borer.host.borer_comm()

/datum/action/innate/borer/talk_to_brain
	name = "Converse with Trapped Mind"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	borer.host = owner
	borer.host.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "borer_brain"
	host_req = TRUE

/datum/action/innate/borer/take_control/Activate()
	borer = owner
	borer.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Release Control"
	desc = "Release control of your host's body."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	borer.host = owner
	borer.host.release_control()

/datum/action/innate/borer/leave_body
	name = "Release Host"
	desc = "Slither out of your host."
	button_icon_state = "borer_leave"
	host_req = TRUE
	stat_message = "Вы не можете покинуть носителя в вашем текущем состоянии."

/datum/action/innate/borer/leave_body/Activate()
	borer = owner
	borer.release_host()

/datum/action/innate/borer/make_chems
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	button_icon_state = "fleshmend"
	host_req = TRUE
	stat_message = "Вы не можете производить химикаты в вашем нынешнем состоянии."

/datum/action/innate/borer/make_chems/Activate()
	borer = owner
	borer.secrete_chemicals()

/datum/action/innate/borer/focus_menu
	name = "Focus menu"
	desc = "Reinforce your host."
	button_icon_state = "human_form"
	host_req = TRUE
	stat_message = "Вы не можете приобрести фокус в вашем нынешнем состоянии."

/datum/action/innate/borer/focus_menu/Activate()
	borer = owner
	borer.focus_menu()

/datum/action/innate/borer/make_larvae
	name = "Reproduce"
	desc = "Spawn several young."
	button_icon_state = "borer_reproduce"
	chem_cost = 100

/datum/action/innate/borer/make_larvae/Activate()
	borer.host = owner
	borer.chemicals -= chem_cost
	borer.host.spawn_larvae()

/datum/action/innate/borer/torment
	name = "Torment Host"
	desc = "Punish your host with agony."
	button_icon_state = "blind"

/datum/action/innate/borer/torment/Activate()
	borer.host = owner
	borer.host.punish_host()

/datum/action/innate/borer/sneak_mode
	name = "Sneak mode"
	desc = "Hides your status from medical huds."
	button_icon_state = "chameleon_skin"
	chem_cost = 50

/datum/action/innate/borer/sneak_mode/Activate()
	borer.host = owner
	borer.chemicals -= chem_cost
	borer.host.sneak_mode()

#undef REPRODUCTIONS_TO_MATURE
#undef REPRODUCTIONS_TO_ADULT
#undef REPRODUCTIONS_TO_ELDER
#undef HEAD_FOCUS_COST
#undef TORSO_FOCUS_COST
#undef HANDS_FOCUS_COST
#undef LEGS_FOCUS_COST
#undef SCALING_MAX_CHEM
#undef SCALING_CHEM_GAIN
#undef BORER_RANK_YOUNG
#undef BORER_RANK_MATURE
#undef BORER_RANK_ADULT
#undef BORER_RANK_ELDER
