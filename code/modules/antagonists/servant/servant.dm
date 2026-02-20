#define MAX_DISTANCE 12
/datum/antagonist/servant
	name = "Magic servant"
	job_rank = ROLE_WIZARD
	special_role = SPECIAL_ROLE_SERVANT
	give_objectives = FALSE
	antag_menu_name = "Магический слуга"
	var/mob/living/carbon/human/serve_to
	var/in_owner = TRUE
	var/datum/action/summon_servant/summon_action = new
	var/datum/action/servant_self_summon/self_summon_action = new


/datum/antagonist/servant/New(var/mob/living/target)
	. = ..()
	serve_to = target

/datum/antagonist/servant/on_gain()
	self_summon_action.master = serve_to
	summon_action.servant = owner.current
	self_summon_action.Grant(owner.current)
	summon_action.Grant(serve_to)
	var/datum/objective/serve/serve_obj = new(serve_to)
	objectives += serve_obj
	check_if_in_owner()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	RegisterSignal(serve_to, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(owner.current, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(owner.current, COMSIG_MOB_DEATH, PROC_REF(die))
	RegisterSignal(serve_to, COMSIG_MOB_DEATH, PROC_REF(kick))

/datum/antagonist/servant/proc/check_if_in_owner()
	if(owner.current.loc == serve_to)
		in_owner = TRUE
		ADD_TRAIT(owner.current, TRAIT_NO_BREATH, MAGIC_TRAIT)
		return
	in_owner = FALSE
	REMOVE_TRAIT(owner.current, TRAIT_NO_BREATH, MAGIC_TRAIT)

/datum/antagonist/servant/proc/heal()
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

	if(get_dist(serve_to, owner.current) <= MAX_DISTANCE)
		return
	owner.current.forceMove(serve_to)
	to_chat(owner.current, span_warningbig("Вы ушли слишком далеко от вашего хозяина!"))
	check_if_in_owner()

/datum/antagonist/servant/Destroy(force)
	UnregisterSignal(serve_to, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner.current, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(owner.current, COMSIG_MOB_DEATH)
	UnregisterSignal(serve_to, COMSIG_MOB_DEATH)
	qdel(self_summon_action)
	qdel(summon_action)
	. = ..()

/datum/antagonist/servant/proc/die()
	SIGNAL_HANDLER

	for(var/obj/item/item in owner.current.contents)
		owner.current.drop_item_ground(item)
	if(serve_to.stat != DEAD)
		to_chat(owner.current, span_userdanger("Ваша физическая оболочка уничтожена, но жизненная энергия мастера сможет восстановить её через время."))
		to_chat(serve_to, span_userdanger("Физическая оболочка вашего слуги уничтожена, но ваша жизненная энергия сможет восстановить её через время."))
		var/client/died_servant = owner.current.client
		new /datum/servant_revive(serve_to, died_servant)
	else
		new /obj/item/coin/magic(serve_to.loc)
	owner.current.dust()
	qdel(src)

/datum/antagonist/servant/proc/kick()
	SIGNAL_HANDLER

	if(in_owner)
		owner.current.forceMove(serve_to.loc)

#undef MAX_DISTANCE
