/datum/team/clockwork_cult
	name = "Культисты Ратвара"
	antag_datum_type = /datum/antagonist/clockwork
	var/datum/clockwork_objectives/clocker_objs = new
	var/power_reveal = FALSE
	var/crew_reveal = FALSE
	var/power_reveal_number
	var/crew_reveal_number
	var/reveal_percent

/datum/team/clockwork_cult/Destroy(force = FALSE)
	QDEL_NULL(clocker_objs)
	return ..()

/proc/get_clockwork_cult_team()
	RETURN_TYPE(/datum/team/clockwork_cult)
	return GLOB.antagonist_teams[/datum/team/clockwork_cult]

/datum/team/clockwork_cult/proc/clockwork_threshold_check()
	var/players = length(GLOB.player_list)
	var/clockers = get_clockers()
	if(players >= CLOCK_POPULATION_THRESHOLD)
		reveal_percent = CLOCK_CREW_REVEAL_HIGH
		clocker_objs.power_goal = CLOCK_BASIC_POWER_GOAL + length(GLOB.player_list) * CLOCK_POWER_PER_CREW_HIGH
		crew_reveal_number = round(CLOCK_CREW_REVEAL_HIGH * (players - clockers), 1)
	else
		reveal_percent = CLOCK_CREW_REVEAL_LOW
		clocker_objs.power_goal = CLOCK_BASIC_POWER_GOAL + length(GLOB.player_list) * CLOCK_POWER_PER_CREW_LOW
		crew_reveal_number = round(CLOCK_CREW_REVEAL_LOW * (players - clockers), 1)
	power_reveal_number = round(clocker_objs.power_goal * CLOCK_POWER_REVEAL_RATIO)
	add_game_logs("Clockwork Cult power/crew reveal numbers: [power_reveal_number]/[clocker_objs.clocker_goal].")

/datum/team/clockwork_cult/proc/get_clockers(separate = FALSE)
	var/clockers = 0
	var/constructs = 0
	for(var/datum/mind/member as anything in members)
		if(ishuman(member.current) && !member.madeby_sentience_potion)
			clockers++
		else if(ismarauder(member.current) && isclocker(member.current))
			constructs++
	if(separate)
		return list(clockers, constructs)
	return clockers + constructs

/datum/team/clockwork_cult/proc/check_power_reveal()
	if(power_reveal || GLOB.clockwork_power < power_reveal_number)
		return
	power_reveal = TRUE
	for(var/datum/mind/member as anything in members)
		if(!member.current)
			continue
		if(!ishuman(member.current))
			powered_borgs(member.current)
			continue
		SEND_SOUND(member.current, sound('sound/hallucinations/i_see_you2.ogg'))
		to_chat(member.current, span_clocklarge("The veil begins to stutter in fear as the power of Ratvar grows, your hands begin to glow..."))
		addtimer(CALLBACK(src, PROC_REF(powered), member.current), 20 SECONDS)

/datum/team/clockwork_cult/proc/check_clock_reveal()
	if(crew_reveal)
		return
	if(get_clockers() < crew_reveal_number && GLOB.heart.curse_dial)
		return
	for(var/datum/mind/member as anything in members)
		if(!member.current)
			continue
		SEND_SOUND(member.current, sound('sound/hallucinations/im_here1.ogg'))
		if(!ishuman(member.current))
			continue
		to_chat(member.current, span_clocklarge("Your cult gets bigger as the clocked harvest approaches - you cannot hide your true nature for much longer!"))
		addtimer(CALLBACK(src, PROC_REF(clocked), member.current), 20 SECONDS)
	GLOB.major_announcement.announce("На вашей станции обнаружена внепространственная активность, связанная с Заводным культом Ратвара. Данные свидетельствуют о том, что в ряды культа обращено около [reveal_percent * 100]% экипажа станции. Служба безопасности получает право свободно применять летальную силу против культистов. Прочий персонал должен быть готов защищать себя и свои рабочие места от нападений культистов (в том числе используя летальную силу в качестве крайней меры самообороны), но не должен выслеживать культистов и охотиться на них. Погибшие члены экипажа должны быть оживлены и деконвертированы, как только ситуация будет взята под контроль.",
										ANNOUNCE_CCPARANORMAL_RU,
										SSstation.announcer.get_rand_report_sound()
		)
	log_game("Clockwork cult reveal. Powergame allowed.")
	crew_reveal = TRUE

/datum/team/clockwork_cult/proc/powered(mob/living/carbon/human/clocker)
	if(!ishuman(clocker) || !isclocker(clocker))
		return
	ADD_TRAIT(clocker, TRAIT_CLOCK_HANDS, CLOCK_TRAIT)
	clocker.update_worn_gloves()

/datum/team/clockwork_cult/proc/powered_borgs(mob/living/silicon/robot/clocker)
	if(!isrobot(clocker))
		return
	clocker.update_icons()

/datum/team/clockwork_cult/proc/clocked(mob/living/carbon/human/clocker)
	if(!ishuman(clocker) || !isclocker(clocker))
		return
	new /obj/effect/temp_visual/ratvar/sparks(get_turf(clocker), clocker.dir)
	SEND_SIGNAL(clocker, COMSIG_MOB_HALO_GAINED)

/datum/team/clockwork_cult/declare_completion()
	if(!length(members))
		return

	if(sets_round_result)
		if(clocker_objs.clock_status == RATVAR_HAS_RISEN)
			SSticker.mode_result = "clockwork cult win - cult win"
		else if(clocker_objs.clock_status == RATVAR_HAS_FALLEN)
			SSticker.mode_result = "clockwork cult draw - ratvar died, nobody wins"
		else
			SSticker.mode_result = "clockwork cult loss - staff stopped the cult"

	var/list/text = list("<b>The clockers' objectives were:</b>")
	text += "[clocker_objs.obj_demand.explanation_text] - [clocker_objs.obj_demand.check_completion() ? "<font color='green'><b>Success!</b></font>" : "<font color='red'>Fail.</font>"]"

	if(clocker_objs.clock_status >= RATVAR_NEEDS_SUMMONING)
		text += "[clocker_objs.obj_summon.explanation_text] - [clocker_objs.obj_summon.check_completion() ? "<font color='green'><b>Success!</b></font>" : "<font color='red'>Fail.</font>"]"

	return text.Join("<br>")
