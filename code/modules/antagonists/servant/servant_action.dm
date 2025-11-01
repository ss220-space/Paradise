/datum/action/summon_servant
	name = "Вызвать слугу"
	desc = "Вызывает вашегу слугу к вам или отзывает его."
	button_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "summons"
	var/datum/antagonist/servant/serv_datum
	var/mob/living/carbon/human/servant

/datum/action/summon_servant/Grant(mob/user)
	. = ..()
	if(!servant.mind.has_antag_datum(/datum/antagonist/servant))
		log_runtime(EXCEPTION("Can't grant servant summon spell without servant datum on target"), src)
		qdel(src)
	serv_datum = servant.mind.has_antag_datum(/datum/antagonist/servant, FALSE)

/datum/action/summon_servant/Trigger(left_click)
	. = ..()
	if(serv_datum.in_owner)
		servant.forceMove(owner.loc)
	else
		servant.forceMove(owner)
	serv_datum.check_if_in_owner()
	servant.reset_perspective()

/datum/action/servant_self_summon
	name = "Вернуться к мастеру"
	desc = "Перемещает вас к мастеру."
	button_icon = 'icons/obj/wizard.dmi'
	button_icon_state = "summons"
	var/datum/antagonist/servant/serv_datum
	var/mob/living/carbon/human/master

/datum/action/servant_self_summon/Grant(mob/user)
	. = ..()
	if(!owner.mind.has_antag_datum(/datum/antagonist/servant))
		log_runtime(EXCEPTION("Can't grant servant self summon spell without servant datum on owner"), src)
		qdel(src)
	serv_datum = owner.mind.has_antag_datum(/datum/antagonist/servant, FALSE)

/datum/action/servant_self_summon/Trigger(left_click)
	. = ..()
	if(serv_datum.in_owner)
		owner.forceMove(master.loc)
	else
		owner.forceMove(master)
	serv_datum.check_if_in_owner()
	owner.reset_perspective()
