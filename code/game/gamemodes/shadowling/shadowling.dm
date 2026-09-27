/*

SHADOWLING: A gamemode based on previously-run events

Aliens called shadowlings are on the station.
These shadowlings can 'enthrall' crew members and enslave them.
They also burn in the light but heal rapidly whilst in the dark.
The game will end under two conditions:
	1. The shadowlings die
	2. The emergency shuttle docks at CentCom

Shadowling strengths:
	- The dark
	- Hard vacuum (They are not affected by it)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Lasers (Lasers are concentrated light and do more damage)
	- Flashbangs (High stun and high burn damage; if the light stuns humans, you bet your ass it'll hurt the shadowling very much!)

Shadowlings start off disguised as normal crew members, and they only have two abilities: Hatch and Enthrall.
They can still enthrall and perhaps complete their objectives in this form.
Hatch will, after a short time, cast off the human disguise and assume the shadowling's true identity.
They will then assume the normal shadowling form and gain their abilities.

The shadowling will seem OP, and that's because it kinda is. Being restricted to the dark while being alone most of the time is extremely difficult and as such the shadowling needs powerful abilities.
Made by Xhuis

*/

/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	required_players = 30
	required_enemies = 2
	recommended_enemies = 2
	protected_jobs = list(JOB_TITLE_LAWYER)

	var/list/datum/mind/pre_shadows = list()

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>The current game mode is - Shadowling!</b>")
	to_chat(world, "<b>There are alien [span_deadsay("shadowlings")] on the station. Crew: Kill the shadowlings before they can eat or enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>")

/datum/game_mode/shadowling/pre_setup()
	var/list/datum/mind/possible_shadowlings = get_players_for_role(ROLE_SHADOWLING)

	if(!length(possible_shadowlings))
		return 0

	var/shadowlings = max(3, round(num_players()/14))

	while(shadowlings)
		var/datum/mind/shadow = pick(possible_shadowlings)
		pre_shadows += shadow
		possible_shadowlings -= shadow
		shadow.restricted_roles = get_restricted_roles()
		shadowlings--

	var/datum/team/shadowling/shadowling_team = get_shadowling_team()
	shadowling_team.sets_round_result = TRUE

	..()
	return 1

/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in pre_shadows)
		add_game_logs("has been selected as a Shadowling.", shadow.current)
		shadow.add_antag_datum(/datum/antagonist/shadowling)
	..()

/datum/game_mode/proc/greet_shadow(datum/mind/shadow)
	var/list/messages = list()
	messages.Add("<b>В настоящее время ты замаскирован под члена экипажа [station_name()].</b>")
	messages.Add("<b>В твоём текущем состоянии у тебя есть две способности: Раскрытие и Телепатическая сеть тенелингов. '[get_language_prefix(LANGUAGE_HIVE_SHADOWLING)]'.</b>")
	messages.Add("<b>Любые другие тенелинги — твои союзники. Ты должен помогать им, как и они будут помогать тебе..</b>")
	return messages

/datum/objective/enthrall
	needs_target = FALSE
	antag_menu_name = "Возвышение"

/datum/objective/enthrall/New(text, datum/team/team_to_join)
	..()
	var/datum/team/shadowling/shadowlings = get_shadowling_team()
	explanation_text = "Возвышайтесь до своей истинной формы, для этого используйте способность Ascend. Для возвышения необходимо [shadowlings.required_thralls] рабов, когда ты раскроешь свою форму используй Rapid Re-Hatch, чтобы разблокировать новые способности."

/datum/objective/enthrall/check_completion()
	var/datum/team/shadowling/shadowlings = get_shadowling_team()
	return shadowlings.ascended

/datum/game_mode/proc/finalize_shadowling(datum/mind/shadow_mind)
	shadow_mind.AddSpell(new /datum/action/cooldown/spell/shadowling_hatch)
	shadow_mind.current.add_language(LANGUAGE_HIVE_SHADOWLING)

/datum/game_mode/proc/add_thrall(datum/mind/new_thrall_mind)
	if(!istype(new_thrall_mind) || new_thrall_mind.has_antag_datum(/datum/antagonist/shadowling_thrall))
		return 0
	if(!new_thrall_mind.add_antag_datum(/datum/antagonist/shadowling_thrall))
		return 0
	add_conversion_logs(new_thrall_mind.current, "Became a Shadow thrall")

	var/datum/team/shadowling/shadowlings = get_shadowling_team()
	var/thralls = get_thralls()
	var/victory_threshold = shadowlings.required_thralls

	for(var/mob/shadowling in GLOB.alive_mob_list)
		if(!is_shadow(shadowling))
			continue
		if(thralls < victory_threshold)
			to_chat(shadowling, span_shadowling("Ты чувствуешь нового раба под твоей волей. Тебе нужно [victory_threshold] рабов, но у тебя есть только [thralls] живых рабов."))
		else
			to_chat(shadowling, span_shadowling("<b>Тебе хватает сил для трансформации в истинную форму.</b>"))

	shadowlings.try_announce_victory_warning()
	return 1

/datum/game_mode/proc/remove_thrall(datum/mind/thrall_mind, kill = 0)
	if(!istype(thrall_mind) || !thrall_mind.has_antag_datum(/datum/antagonist/shadowling_thrall) || !isliving(thrall_mind.current))
		return 0 //If there is no mind, the mind isn't a thrall, or the mind's mob isn't alive, return
	var/datum/antagonist/shadowling_thrall/thrall = thrall_mind.has_antag_datum(/datum/antagonist/shadowling_thrall)
	thrall.silent = TRUE
	thrall_mind.remove_antag_datum(/datum/antagonist/shadowling_thrall)
	add_conversion_logs(thrall_mind.current, "De-shadow thralled")
	if(kill && ishuman(thrall_mind.current)) //If dethrallization surgery fails, kill the mob as well as dethralling them
		var/mob/living/carbon/human/H = thrall_mind.current
		H.visible_message(span_warning("[H] резко дергается и падает неподвижно."), \
							span_userdanger("Пронзительный белый свет заполняет твой разум, ты забываешь, как был рабом."))
		H.death()
		return 1
	var/mob/living/M = thrall_mind.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] издает короткий сигнал."))
		to_chat(M, span_userdanger("Тебя превратили в робота! Ты больше не раб! Как бы ты ни старался, ты не можешь вспомнить ничего о том, как был рабом."))
	else
		M.visible_message(span_big("[M] looks like [M.p_their()] mind is [M.p_their()] own again!"), \
						span_userdanger("Пронзительный белый свет заполняет твой разум, ты забываешь, как был рабом."))
	return 1

/*
	GAME FINISH CHECKS
*/

/datum/game_mode/shadowling/check_finished()
	var/shadows_alive = 0 //and then shadowling was kill
	for(var/datum/mind/shadow in get_antag_minds(/datum/antagonist/shadowling)) //but what if shadowling was not kill?
		if(!ishuman(shadow.current) && !istype(shadow.current,/mob/living/simple_animal/ascendant_shadowling))
			continue
		if(shadow.current.stat == DEAD)
			continue
		shadows_alive++
		if(shadow.special_role == SPECIAL_ROLE_SHADOWLING && CONFIG_GET(number/shadowling_max_age))
			if(ishuman(shadow.current))
				var/mob/living/carbon/human/H = shadow.current
				if(!isshadowling(H))
					for(var/datum/action/cooldown/spell/shadowling_hatch/hatch_ability in shadow.spell_list)
						hatch_ability.cycles_unused++
						if(prob(20) && hatch_ability.cycles_unused > CONFIG_GET(number/shadowling_max_age))
							var/shadow_nag_messages = list("Ты едва можешь терпеть эту низшую форму!», «Желание стать чем-то большим непреодолимо!», «Ты чувствуешь жгучую страсть освободиться от этой оболочки и обрести божественность».!")
							H.take_overall_damage(0, 3)
							to_chat(H, span_userdanger("[pick(shadow_nag_messages)]"))
							SEND_SOUND(H, sound('sound/weapons/sear.ogg'))

	if(shadows_alive)
		return ..()

	var/datum/team/shadowling/shadowlings = get_shadowling_team()
	shadowlings.wiped_out = TRUE //but shadowling was kill :(
	return 1

/datum/game_mode/proc/remove_shadowling(datum/mind/ling_mind)
	var/datum/antagonist/shadowling/ling = ling_mind.has_antag_datum(/datum/antagonist/shadowling)
	if(!ling)
		return 0
	ling.silent = TRUE
	ling_mind.remove_antag_datum(/datum/antagonist/shadowling)
	add_conversion_logs(ling_mind.current, "Deshadowlinged")
	var/mob/living/M = ling_mind.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip."))
		to_chat(M, span_userdanger("Тебя превратили в робота! Ты больше не тенелинг! Как бы ты ни старался, ты не можешь вспомнить ничего о том времени, когда ты был им..."))
	else
		M.visible_message(
			span_big("[M] кричит и корчится!"), \
			span_userdanger("СВЕТ-- ТВОЙ РАЗУМ-- <i>ГОРИТ--</i>")
		)
		spawn(30)
			if(!M || QDELETED(M))
				return
			M.visible_message(
				span_warning("[M] внезапно раздувается и взрывается!"), \
				span_warning(span_bold("AAAAAAAAA[span_fontsize3("AAAAAAAAAAAAA")][span_fontsize4("AAAAAAAAAAAA.....")]"))
			)
			playsound(M, 'sound/magic/disintegrate.ogg', 100, TRUE)
			M.gib()

