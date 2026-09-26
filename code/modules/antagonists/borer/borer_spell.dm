/datum/action/cooldown/spell/pointed/borer_infest
	name = "Infest"
	desc = "Infest a suitable humanoid host."
	spell_requirements = NONE
	button_icon_state = "infest"
	background_icon_state = "bg_alien"
	background_icon_state_active = "bg_alien"
	active_msg = span_notice_alt("Вы приготовились заразить жертву. <b>Left-click чтобы применить способность!</b>")
	deactive_msg = span_notice_alt("Вы прекратили свои попытки заразить жертву.")
	cast_range = 1
	var/infesting = FALSE
	var/cast_time = 5 SECONDS

/datum/action/cooldown/spell/pointed/borer_infest/can_cast_spell(feedback)
	if(!isborer(owner))
		return FALSE
	var/mob/living/simple_animal/borer/user = owner
	if(is_ventcrawling(user) || !src || user.stat || infesting)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/borer_infest/is_valid_target(atom/cast_on)
	var/mob/living/carbon/human/target = cast_on
	return istype(target) && target.stat != DEAD && !ismachineperson(target) && !isdevilantag(target)

/datum/action/cooldown/spell/pointed/borer_infest/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	var/mob/living/simple_animal/borer/user = owner
	if(!target)
		return

	infesting = TRUE
	to_chat(user, "Вы подползаете к [target] и начинаете искать [GEND_HIS_HER(target)] слуховой проход...")

	if(!do_after(user, cast_time, target, NONE))
		to_chat(user, "Как только [target] отходит, вы срываетесь и падаете на пол.")
		infesting = FALSE
		return

	if(target.has_brain_worms())
		to_chat(user, span_warning("[target] уже заражён!"))
		infesting = FALSE
		return

	infesting = FALSE
	user.host = target
	add_attack_logs(user, user.host, "Infested as borer")
	target.borer = user
	user.forceMove(target)
	user.host.status_flags |= PASSEMOTES

	user.RemoveBorerActions()
	user.RemoveBorerSpells()
	user.GrantInfestActions()

	to_chat(user, span_boldnotice("Вы можете анализировать здоровье носителя при помощи Left-click."))
	SEND_SIGNAL(user, COMSIG_BORER_ENTERED_HOST)

/datum/action/cooldown/spell/pointed/borer_dominate
	name = "Dominate Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	button_icon_state = "genetic_cryo"
	background_icon_state = "bg_alien"
	background_icon_state_active = "bg_alien"
	active_msg = span_notice_alt("Вы приготовились поразить жертву. <b>Left-click чтобы применить способность!</b>")
	deactive_msg = span_notice_alt("Вы решили дать своей жертве шанс. Пока что.")
	cast_range = 3
	var/weaken_time = 6 SECONDS

/datum/action/cooldown/spell/pointed/borer_dominate/can_cast_spell(feedback)
	var/mob/living/simple_animal/borer/user = owner
	if(!istype(user)|| is_ventcrawling(user) || user.stat)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/borer_dominate/is_valid_target(atom/cast_on)
	var/mob/living/carbon/human/target = cast_on
	return istype(target) && target.stat != DEAD

/datum/action/cooldown/spell/pointed/borer_dominate/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	if(target.has_brain_worms())
		to_chat(owner, span_warning("Вы не можете позволить себе сделать это с тем, кто уже заражён.."))
		return

	to_chat(owner, span_warning("Вы пронзили разум [target] пси-потоком, парализуя [GEND_HIS_HER(target)] конечности волной первородного ужаса!"))
	to_chat(target, span_warning("Вы чувствуете, как на вас наваливается жуткое чувство страха, леденящее конечности и заставляющее сердце бешено колотиться."))
	target.Weaken(weaken_time)

/datum/action/cooldown/spell/borer_force_say
	name = "Speak as host"
	desc = "Force your host to say something."
	cooldown_time = 15
	spell_requirements = NONE
	check_flags = NONE
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"
	button_icon_state = "god_transmit"

/datum/action/cooldown/spell/borer_force_say/can_cast_spell(feedback)
	var/mob/living/simple_animal/borer/user = owner
	if(!istype(user) || user.stat || user.host?.stat)
		return FALSE
	return ..()

/datum/action/cooldown/spell/borer_force_say/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/borer/user = owner
	var/force_say_content = tgui_input_text(user, "Content:", "Host forcesay")

	if(!force_say_content)
		return

	if(user.controlling || user.stat || user.host?.stat) // we really need that double check
		return

	user.host.say(force_say_content)
	add_attack_logs(user, user.host, "Forcesaid: [force_say_content]")

/datum/action/cooldown/spell/borer_force_say/get_caster_from_target(atom/target)
	return target
