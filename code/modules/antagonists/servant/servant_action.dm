/datum/action/summon_servant
	name = "Вызвать слугу"
	desc = "Вызывает вашегу слугу к вам или отзывает его."
	button_icon_state = "summons"
	var/datum/weakref/serv_datum_ref
	var/datum/antagonist/servant/serv_datum
	var/mob/living/carbon/human/servant

/datum/action/summon_servant/Grant(mob/user)
	. = ..()
	if(!servant.mind.has_antag_datum(/datum/antagonist/servant))
		log_runtime(EXCEPTION("Can't grant servant summon spell without servant datum on target"), src)
		qdel(src)
	serv_datum_ref = WEAKREF(servant.mind.has_antag_datum(/datum/antagonist/servant, FALSE))

/datum/action/summon_servant/Trigger(mob/clicker, trigger_flags)
	. = ..()
	serv_datum = serv_datum_ref?.resolve()
	if(isnull(serv_datum))
		return
	if(serv_datum.in_owner)
		servant.forceMove(owner.loc)
	else
		servant.forceMove(owner)
	serv_datum.check_if_in_owner()
	servant.reset_perspective()

/datum/action/servant_self_summon
	name = "Вернуться к мастеру"
	desc = "Перемещает вас к мастеру."
	button_icon_state = "summons"
	var/datum/weakref/serv_datum_ref
	var/datum/antagonist/servant/serv_datum
	var/mob/living/carbon/human/master

/datum/action/servant_self_summon/Grant(mob/user)
	. = ..()
	if(!owner.mind.has_antag_datum(/datum/antagonist/servant))
		log_runtime(EXCEPTION("Can't grant servant self summon spell without servant datum on owner"), src)
		qdel(src)
	serv_datum_ref = WEAKREF(owner.mind.has_antag_datum(/datum/antagonist/servant, FALSE))

/datum/action/servant_self_summon/Trigger(mob/clicker, trigger_flags)
	. = ..()
	serv_datum = serv_datum_ref?.resolve()
	if(isnull(serv_datum))
		return
	if(serv_datum.in_owner)
		owner.forceMove(master.loc)
	else
		owner.forceMove(master)
	serv_datum.check_if_in_owner()
	owner.reset_perspective()
