/datum/action/innate/start_evolve_to_empress
	name = "ОШИБКА"
	desc = "Начать процесс эволюции в Императрицу."
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "queen_evolve"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND
	var/datum/weakref/xeno_team

/datum/action/innate/start_evolve_to_empress/New(Target)
	. = ..()
	name = "Эволюционировать ([TO_EMPRESS_EVOLVE_COST])"

/datum/action/innate/start_evolve_to_empress/Activate()
	. = ..()
	var/mob/living/carbon/alien/humanoid/queen/queen = owner
	var/datum/team/xenomorph/team = xeno_team.resolve()

	if(queen.stat)
		return

	if(!istype(queen))
		to_chat(owner, span_warning("Данное действие может выполнить только королева ксеноморфов."))
		return

	if(tgui_alert(queen, "Вы действительно хотите начать эволюцию? После начала вы не сможете что-либо делать, пока процесс эволюции не завершится.", "Подтверждение", list("Да", "Нет")) != "Да")
		return

	if(!queen.use_plasma_spell(TO_EMPRESS_EVOLVE_COST, queen))
		queen.balloon_alert(queen, "не хватает плазмы!")
		return

	playsound_xenobuild(queen)
	var/mob/dead/observer/ghost = queen.ghostize(TRUE)
	ghost.can_reenter_corpse = FALSE

	queen.icon = 'icons/mob/alien.dmi'
	queen.icon_state = "alienq_s"
	queen.pixel_x = 0

	var/turf/alienturf = get_turf(queen)
	var/list/alien_walls = list()
	for(var/turf/simulated/floor/turf in RANGE_TURFS(1, alienturf))
		if(turf == alienturf)
			continue
		alien_walls += new /obj/structure/alien/resin/wall/empress_cocon(turf)

	alien_walls += new /obj/structure/alien/weeds/node(alienturf)
	team.evolve_start(get_area(alienturf))
	addtimer(CALLBACK(src, PROC_REF(after_evolve), alien_walls, ghost, queen), TO_EMPRESS_EVOLVE_TIME)
	Remove(queen)


/datum/action/innate/start_evolve_to_empress/proc/after_evolve(list/alien_walls, mob/dead/observer/ghost, mob/living/carbon/alien/humanoid/queen/queen)
	if(QDELETED(queen))
		return

	if(isnull(queen?.stat) || queen.stat == DEAD)
		return

	ghost.can_reenter_corpse = TRUE
	ghost.reenter_corpse()

	var/mob/living/carbon/alien/new_xeno = new /mob/living/carbon/alien/humanoid/empress/large(get_turf(queen))
	queen.mind.transfer_to(new_xeno)
	SEND_SIGNAL(new_xeno.mind, COMSIG_ALIEN_EVOLVE, queen.type, new_xeno.type)
	QDEL_LIST(alien_walls)
	qdel(queen)



/obj/structure/alien/resin/wall/empress_cocon
	max_integrity = 700
	explosion_block = 100

/obj/structure/alien/resin/wall/empress_cocon/ex_act(severity)
	return

