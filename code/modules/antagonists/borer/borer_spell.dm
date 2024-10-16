/obj/effect/proc_holder/spell/borer_infest
	name = "Infest"
	desc = "Infest a suitable humanoid host."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "infest"
	action_background_icon_state = "bg_alien"
	selection_activated_message = span_notice("Вы приготовились заразить жертву. <B>Left-click чтобы применить способность!</B>")
	selection_deactivated_message = span_notice("Вы прекратили свои попытки заразить жертву.")
	need_active_overlay = TRUE
	human_req = FALSE
	var/infesting = FALSE

/obj/effect/proc_holder/spell/borer_infest/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/borer_infest/can_cast(mob/living/user, charge_check = TRUE, show_message = FALSE)

	if (is_ventcrawling(user) || !src || user.stat || infesting)
		return FALSE

	. = ..()

/obj/effect/proc_holder/spell/borer_infest/valid_target(mob/living/carbon/human/target, user)
	return istype(target) && target.stat != DEAD && !ismachineperson(target)

/obj/effect/proc_holder/spell/borer_infest/cast(list/targets, mob/living/simple_animal/borer/user)
	var/mob/living/carbon/human/target = targets[1]

	if(!target)
		return

	infesting = TRUE
	to_chat(user, "Вы подползаете к [target] и начинаете искать [genderize_ru(target.gender,"его","её","его","их" )] слуховой проход...")

	if(!do_after(user, 5 SECONDS, target, NONE))
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

/obj/effect/proc_holder/spell/borer_dominate
	name = "Dominate Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "genetic_cryo"
	action_background_icon_state = "bg_alien"
	selection_activated_message = span_notice("Вы приготовились поразить жертву. <B>Left-click чтобы применить способность!</B>")
	selection_deactivated_message = span_notice("Вы решили дать своей жертве шанс. Пока что.")
	need_active_overlay = TRUE
	human_req = FALSE

/obj/effect/proc_holder/spell/borer_dominate/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 3
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/borer_dominate/can_cast(mob/living/user, charge_check = TRUE, show_message = FALSE)

	if (is_ventcrawling(user) || !src || user.stat)
		return FALSE
	. = ..()

/obj/effect/proc_holder/spell/borer_dominate/valid_target(mob/living/carbon/human/target, user)
	return istype(target) && target.stat != DEAD

/obj/effect/proc_holder/spell/borer_dominate/cast(list/targets, mob/living/simple_animal/borer/user)
	var/mob/living/carbon/human/target = targets[1]

	if(target.has_brain_worms())
		to_chat(user, span_warning("Вы не можете позволить себе сделать это с тем, кто уже заражён.."))
		return

	to_chat(user, span_warning("Вы пронзили разум [target] пси-потоком, парализуя [genderize_ru(target.gender,"его","её","его","их" )] конечности волной первородного ужаса!"))
	to_chat(target, span_warning("Вы чувствуете, как на вас наваливается жуткое чувство страха, леденящее конечности и заставляющее сердце бешено колотиться."))
	target.Weaken(6 SECONDS)

/obj/effect/proc_holder/spell/borer_force_say
	name = "Speak as host"
	desc = "Force your host to say something."

	base_cooldown = 15

	clothes_req = FALSE
	human_req = FALSE

	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_background_icon_state = "bg_alien"
	action_icon_state = "god_transmit"
	need_active_overlay = TRUE

	var/evo_cost = 0.3

/obj/effect/proc_holder/spell/borer_force_say/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/borer_force_say/can_cast(mob/living/simple_animal/borer/user, charge_check = TRUE, show_message = FALSE)
	if (user.stat || user.host?.stat)
		return FALSE

	if(user.antag_datum.evo_points < evo_cost)
		to_chat(user, "Вам требуется еще [evo_cost - user.antag_datum.evo_points] очков эволюции для подчинения голосовых связок хозяина.")
		return FALSE

	. = ..()

/obj/effect/proc_holder/spell/borer_force_say/cast(list/targets, mob/living/simple_animal/borer/user)
	var/force_say_content = tgui_input_text(user, "Content:", "Host forcesay")

	if(!force_say_content)
		return

	if(user.controlling || user.stat || user.host?.stat || user.antag_datum.evo_points < evo_cost) // we really need that double check
		return

	user.host.say(force_say_content)
	user.antag_datum.evo_points -= evo_cost
	
	add_attack_logs(user, user.host, "Forcesaid: [force_say_content]")
