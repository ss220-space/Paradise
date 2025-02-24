/datum/antagonist/terror_spider
	name = "Terror Spider"
	roundend_category = "terror spiders"
	job_rank = ROLE_TERROR_SPIDER
	special_role = SPECIAL_ROLE_TERROR_SPIDER
	wiki_page_name = "Terror_Spider"
	russian_wiki_name = "Паук_Ужаса"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Паук Ужаса"
	var/datum/team/terror_spiders/terror_team
	var/spider_category = TERROR_OTHER
	var/spider_intro_text = "Если ты это видишь, это баг."

/datum/antagonist/terror_spider/on_gain()
	if(!isterrorspider(owner.current))
		stack_trace("This antag datum cannot be attached to a mob of this type.")
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider = owner.current
	spider_intro_text = spider.spider_intro_text
	terror_team = team
	. = ..()

/datum/antagonist/terror_spider/apply_innate_effects(mob/living/mob_override)
	. = ..()
	reg_spider_signals()

/datum/antagonist/terror_spider/remove_innate_effects(mob/living/mob_override)
	. = ..()
	unreg_spider_signals()

/datum/antagonist/terror_spider/proc/reg_spider_signals()
	RegisterSignal(owner, COMSIG_EMPRESS_EGG_LAYED, PROC_REF(on_empress_egg_layed))
	return

/datum/antagonist/terror_spider/proc/unreg_spider_signals()
	UnregisterSignal(owner, COMSIG_EMPRESS_EGG_LAYED)
	return

/datum/antagonist/terror_spider/proc/on_empress_egg_layed()
	SIGNAL_HANDLER
	return

/datum/antagonist/terror_spider/give_objectives()
	if(!terror_team.other_target)
		terror_team.other_target = new
		terror_team.other_target.owner = team
		terror_team.other_target.generate_text(terror_team)
	add_objective(terror_team.other_target)
	terror_team.other_target.check_completion()

/datum/antagonist/terror_spider/roundend_report_header()
	return

/datum/antagonist/terror_spider/greet()
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы - Паук Ужаса!</center>"))
	messages.Add("<center>Работайте сообща, помогайте своим братьям и сёстрам, саботируйте станцию, убивайте экипаж, превратите это место в своё гнездо!</center>")
	messages.Add(span_big("<center>[spider_intro_text]</center><br>"))
	SEND_SOUND(owner.current, sound('sound/ambience/antag/terrorspider.ogg'))
	return messages

/datum/antagonist/terror_spider/main_spider
	var/datum/objective/spider_get_power/power_objective
	var/datum/action/innate/terrorspider/lay_empress_egg/egg_action

/datum/antagonist/terror_spider/main_spider/reg_spider_signals()
	. = ..()
	RegisterSignal(owner, COMSIG_SPIDER_CAN_LAY, PROC_REF(add_egg_power))
	RegisterSignal(owner, COMSIG_TERROR_SPIDER_DIED, PROC_REF(on_terror_spider_died))

/datum/antagonist/terror_spider/main_spider/unreg_spider_signals()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_SPIDER_CAN_LAY, COMSIG_TERROR_SPIDER_DIED))

/datum/antagonist/terror_spider/main_spider/proc/on_terror_spider_died()
	SIGNAL_HANDLER
	terror_team.on_major_spider_died(owner, spider_category)
	unreg_spider_signals()

/datum/antagonist/terror_spider/main_spider/on_empress_egg_layed()
	. = ..()
	if(owner?.current)
		egg_action?.Remove(owner.current)
		QDEL_NULL(egg_action)

/datum/antagonist/terror_spider/main_spider/add_owner_to_gamemode()
	. = ..()
	terror_team.on_major_spider_created(owner, spider_category)

/datum/antagonist/terror_spider/main_spider/give_objectives()
	if(!terror_team.lay_eggs_target)
		terror_team.lay_eggs_target = new
		terror_team.lay_eggs_target.owner = team
		terror_team.lay_eggs_target.generate_text()
	add_objective(terror_team.lay_eggs_target)
	power_objective = terror_team.lay_eggs_target
	check_target()


/datum/antagonist/terror_spider/main_spider/remove_owner_from_gamemode()
	. = ..()
	var/list/spiders = terror_team.main_spiders[spider_category]
	spiders -= owner

/datum/antagonist/terror_spider/main_spider/proc/check_target()
	if(power_objective?.check_completion() && !terror_team.empress_egg)
		add_egg_power()

/datum/antagonist/terror_spider/main_spider/proc/add_egg_power()
	SIGNAL_HANDLER
	if(owner?.current && !egg_action && !terror_team.empress_egg)
		egg_action = new
		egg_action.spider_team = WEAKREF(team)
		egg_action.Grant(owner.current)
	return

/datum/antagonist/terror_spider/main_spider/empress
	antag_menu_name = "Императрица Ужаса"

/datum/antagonist/terror_spider/main_spider/empress/check_target()
	return

/datum/antagonist/terror_spider/main_spider/empress/give_objectives()
	return

/datum/antagonist/terror_spider/main_spider/defiler
	spider_category = TERROR_DEFILER
	special_role = SPECIAL_ROLE_TERROR_DEFILER
	antag_menu_name = "Осквернитель Ужаса"

/datum/antagonist/terror_spider/main_spider/defiler/give_objectives()
	if(!terror_team.infect_target)
		terror_team.infect_target = new
		terror_team.infect_target.owner = team
		terror_team.infect_target.generate_text()
	add_objective(terror_team.infect_target)
	power_objective = terror_team.infect_target
	check_target()

/datum/antagonist/terror_spider/main_spider/queen
	spider_category = TERROR_QUEEN
	special_role = SPECIAL_ROLE_TERROR_QUEEN
	antag_menu_name = "Королева Ужаса"

/datum/antagonist/terror_spider/main_spider/princess
	spider_category = TERROR_PRINCESS
	special_role = SPECIAL_ROLE_TERROR_PRINCESS
	antag_menu_name = "Принцесса Ужаса"

/datum/antagonist/terror_spider/main_spider/prince
	spider_category = TERROR_PRINCE
	special_role = SPECIAL_ROLE_TERROR_PRINCE
	antag_menu_name = "Принц Ужаса"
	var/total_targets_count = 0

/datum/antagonist/terror_spider/main_spider/prince/finalize_antag()
	. = ..()
	terror_team.check_announce()

/datum/antagonist/terror_spider/main_spider/prince/reg_spider_signals()
	. = ..()
	RegisterSignal(owner, COMSIG_HUMAN_EATEN, PROC_REF(increment_target))

/datum/antagonist/terror_spider/main_spider/prince/unreg_spider_signals()
	. = ..()
	UnregisterSignal(owner, COMSIG_HUMAN_EATEN)

/datum/antagonist/terror_spider/main_spider/prince/proc/increment_target()
	SIGNAL_HANDLER
	total_targets_count++
	check_target()

/datum/antagonist/terror_spider/main_spider/prince/check_target()
	if(power_objective.check_completion(total_targets_count, team))
		add_egg_power()

/datum/antagonist/terror_spider/main_spider/prince/give_objectives()
	var/datum/game_mode/mode = SSticker?.mode
	if(!mode)
		return
	if(!terror_team.prince_target)
		terror_team.prince_target= new
		terror_team.prince_target.owner = team
		terror_team.prince_target.generate_text()
	add_objective(terror_team.prince_target)
	power_objective = terror_team.prince_target
	check_target()
