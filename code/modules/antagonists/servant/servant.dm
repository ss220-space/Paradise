/datum/antagonist/servant
	name = "Magic servant"
	job_rank = ROLE_WIZARD
	special_role = SPECIAL_ROLE_SERVANT
	give_objectives = FALSE
	antag_menu_name = "Магический слуга"
	var/mob/living/carbon/human/serve_to
	var/in_owner = TRUE

/datum/antagonist/servant/New(var/mob/living/target)
	. = ..()
	serve_to = target

/datum/antagonist/servant/on_gain()
	var/datum/objective/serve/serve_obj= new(serve_to)
	objectives += serve_obj
	check_if_in_owner()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(serve_to, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(owner.current, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(owner.current, COMSIG_MOB_DEATH, PROC_REF(die))

/datum/antagonist/servant/proc/check_if_in_owner()
	if(owner.current.loc == serve_to)
		in_owner = TRUE
		ADD_TRAIT(owner.current, TRAIT_NO_BREATH, MAGIC_TRAIT)
	else
		in_owner = FALSE
		REMOVE_TRAIT(owner.current, TRAIT_NO_BREATH, MAGIC_TRAIT)

/datum/antagonist/servant/process(seconds_per_tick)
	if(!in_owner)
		return
	owner.current.heal_overall_damage(5, 5)
	owner.current.adjustOxyLoss(-5)
	owner.current.adjustToxLoss(-5)
	owner.current.adjustBrainLoss(-5)
	owner.current.AdjustBlood(10)
	owner.current.adjustBodyTemp(BODYTEMP_NORMAL)
	if(owner.current.health == 100)
		owner.current.heal_overall_damage(0, 0, internal = TRUE)

/datum/antagonist/servant/proc/check_range()
	SIGNAL_HANDLER

	if(serve_to in range(12, owner.current))
		return
	owner.current.forceMove(serve_to)
	to_chat(owner.current, span_warningbig("Вы ушли слишком далеко от вашего хозяина!"))
	check_if_in_owner()

/datum/antagonist/servant/Destroy(force)
	UnregisterSignal(serve_to, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner.current, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner.current, COMSIG_MOB_DEATH)
	var/datum/action/summon_servant/summon_action = locate() in serve_to.actions
	qdel(summon_action)
	. = ..()

/datum/antagonist/servant/proc/die()
	for(var/obj/item/item in owner.current.contents)
		owner.current.drop_item_ground(item)
	if(serve_to.stat != DEAD)
		to_chat(owner.current, span_userdanger("Ваша физическая оболочка уничтожена, но жизненная энергия мастера сможет восстановить её через время."))
		to_chat(serve_to, span_userdanger("Физическая оболочка вашего слуги уничтожена, но ваша жизненная энергия сможет восстановить её через время."))
		var/client/died_servant = owner.current.client
		new /datum/servant_revive(serve_to, died_servant)
	to_chat(serve_to, span_userdanger("Умирая, вы чувствуете как связь с вашим слугой теряется."))
	owner.current.dust()
	qdel(src)
