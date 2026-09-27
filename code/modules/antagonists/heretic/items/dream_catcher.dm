#define DREAM_MODE_PROWL "prowl"
#define DREAM_MODE_DUEL "duel"

#define DREAM_POSSESSION_TIME (2 MINUTES)

/obj/item/clothing/head/dream_catcher
	name = "Dream Catcher"
	desc = "Плетёный обруч из костяных спиц и волоса, натянутый на череп. Сквозь его сеть \
			чужие сны выглядят как двери, которые кто-то забыл запереть."
	icon_state = "dream_catcher"
	flags_cover = HEADCOVERSEYES
	var/mode = DREAM_MODE_PROWL
	var/possession_duration = DREAM_POSSESSION_TIME
	var/datum/weakref/prowler_ref
	var/datum/weakref/ridden_ref
	var/datum/weakref/captive_ref
	var/release_timer
	var/datum/action/innate/dream_wake/wake_action
	var/datum/dream_duel/ongoing_duel


/obj/item/clothing/head/dream_catcher/get_ru_names()
	return alist(
		NOMINATIVE = "ловец снов",
		GENITIVE = "ловца снов",
		DATIVE = "ловцу снов",
		ACCUSATIVE = "ловца снов",
		INSTRUMENTAL = "ловцом снов",
		PREPOSITIONAL = "ловце снов",
	)


/obj/item/clothing/head/dream_catcher/Destroy()
	end_possession()
	QDEL_NULL(ongoing_duel)
	return ..()


/obj/item/clothing/head/dream_catcher/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot != ITEM_SLOT_HEAD)
		return
	if(!IS_HERETIC(user))
		return
	RegisterSignal(user, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_wearer_sleep), override = TRUE)
	if(mode == DREAM_MODE_DUEL)
		INVOKE_ASYNC(src, PROC_REF(challenge), user)


/obj/item/clothing/head/dream_catcher/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_LIVING_STATUS_SLEEP)


/obj/item/clothing/head/dream_catcher/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	. += span_hierophant("Режим: [mode == DREAM_MODE_PROWL ? "охота во сне" : "вызов на дуэль"].")


/obj/item/clothing/head/dream_catcher/attack_self(mob/user)
	if(!IS_HERETIC(user))
		to_chat(user, span_warning("Сеть путается в ваших пальцах и не желает слушаться."))
		return

	var/static/list/dream_modes = list(
		DREAM_MODE_PROWL = image('icons/mob/actions/actions_ecult.dmi', "dream_prowl"),
		DREAM_MODE_DUEL = image('icons/mob/actions/actions_ecult.dmi', "dream_duel"),
	)

	var/picked = show_radial_menu(user, src, dream_modes, require_near = TRUE, tooltips = TRUE)
	if(!picked || !user.is_in_hands(src))
		return

	mode = picked
	balloon_alert(user, mode == DREAM_MODE_PROWL ? "охота во сне" : "вызов на дуэль")
	to_chat(user, span_hierophant("Наденьте обруч, чтобы пустить сеть в ход."))


/obj/item/clothing/head/dream_catcher/proc/on_wearer_sleep(mob/living/wearer, amount)
	SIGNAL_HANDLER

	if(amount <= 0 || mode != DREAM_MODE_PROWL || prowler_ref || ongoing_duel)
		return
	if(!IS_HERETIC(wearer))
		return

	INVOKE_ASYNC(src, PROC_REF(begin_possession), wearer)


/obj/item/clothing/head/dream_catcher/proc/find_sleeper(mob/living/prowler)
	var/list/candidates = list()
	var/prowler_z = prowler.z
	for(var/mob/living/sleeper as anything in GLOB.mob_living_list)
		if(sleeper == prowler || !sleeper.ckey || !sleeper.mind || sleeper.stat == DEAD)
			continue
		if(sleeper.z != prowler_z || !sleeper.IsSleeping())
			continue
		if(IS_HERETIC_OR_MONSTER(sleeper) || HAS_TRAIT(sleeper, TRAIT_MIND_TEMPORARILY_GONE))
			continue

		candidates += sleeper

	return length(candidates) ? pick(candidates) : null


/obj/item/clothing/head/dream_catcher/proc/begin_possession(mob/living/prowler)
	var/mob/living/ridden = find_sleeper(prowler)
	if(!ridden)
		to_chat(prowler, span_warning("Сеть ловит только вашу собственную темноту — сегодня никто больше не спит."))
		return

	var/prowler_key = prowler.ckey
	if(!prowler_key)
		return

	var/mob/living/captive_brain/dreamer/captive = new(ridden)
	captive.name = ridden.name
	captive.real_name = ridden.real_name
	captive.possess_by_player(ridden.ckey)

	ridden.possess_by_player(prowler_key)
	ADD_TRAIT(ridden, TRAIT_DREAMT_EYES, UID())
	ridden.SetSleeping(0)

	prowler_ref = WEAKREF(prowler)
	ridden_ref = WEAKREF(ridden)
	captive_ref = WEAKREF(captive)

	RegisterSignal(ridden, COMSIG_LIVING_DEATH, PROC_REF(on_ridden_lost))
	RegisterSignal(ridden, COMSIG_QDELETING, PROC_REF(on_ridden_lost))
	RegisterSignal(prowler, COMSIG_LIVING_DEATH, PROC_REF(on_ridden_lost))

	wake_action = new(src)
	wake_action.Grant(ridden)

	playsound(ridden, 'sound/magic/mindswap.ogg', 40, TRUE)
	add_attack_logs(prowler, ridden, "Possessed via Dream Catcher")
	to_chat(ridden, span_hypnophrase("Вы просыпаетесь в чужом теле. Оно послушно вам, но ненадолго."))
	to_chat(captive, span_userdanger("Вы всё ещё здесь, за собственными глазами — но руки вас больше не слушаются."))

	release_timer = addtimer(CALLBACK(src, PROC_REF(end_possession)), possession_duration, TIMER_STOPPABLE)


/obj/item/clothing/head/dream_catcher/proc/on_ridden_lost(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(end_possession))


/datum/action/innate/dream_wake
	name = "Проснуться"
	desc = "Покинуть чужое тело и вернуться в собственный сон."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "dream_prowl"


/datum/action/innate/dream_wake/Activate()
	var/obj/item/clothing/head/dream_catcher/catcher = target
	if(!istype(catcher))
		return
	INVOKE_ASYNC(catcher, TYPE_PROC_REF(/obj/item/clothing/head/dream_catcher, end_possession))


/obj/item/clothing/head/dream_catcher/proc/end_possession()
	var/mob/living/prowler = prowler_ref?.resolve()
	var/mob/living/ridden = ridden_ref?.resolve()
	var/mob/living/captive_brain/dreamer/captive = captive_ref?.resolve()

	prowler_ref = null
	ridden_ref = null
	captive_ref = null
	deltimer(release_timer)
	release_timer = null
	QDEL_NULL(wake_action)

	if(ridden)
		UnregisterSignal(ridden, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
		REMOVE_TRAIT(ridden, TRAIT_DREAMT_EYES, UID())
	if(prowler)
		UnregisterSignal(prowler, COMSIG_LIVING_DEATH)

	var/borrowed_key = ridden?.ckey
	if(prowler && borrowed_key)
		prowler.possess_by_player(borrowed_key)
		to_chat(prowler, span_hypnophrase("Сон отпускает вас, и вы падаете обратно в собственную голову."))

	if(captive)
		if(ridden && captive.ckey)
			ridden.possess_by_player(captive.ckey)
			to_chat(ridden, span_notice("Тело снова ваше."))
		qdel(captive)


/obj/item/clothing/head/dream_catcher/proc/challenge(mob/living/user)
	if(ongoing_duel || prowler_ref)
		to_chat(user, span_warning("Сеть уже держит чей-то сон."))
		return

	var/list/candidates = list()
	var/user_z = user.z
	for(var/mob/living/carbon/human/target in GLOB.mob_living_list)
		if(target == user || !target.ckey || !target.mind || target.stat == DEAD)
			continue
		if(target.z != user_z || HAS_TRAIT(target, TRAIT_MIND_TEMPORARILY_GONE))
			continue

		candidates[target.real_name] = target

	if(!length(candidates))
		to_chat(user, span_warning("Вам некого позвать в этот сон."))
		return

	var/picked = tgui_input_list(user, "Чей сон вы разделите?", "Ловец Снов", candidates)
	if(!picked || loc != user)
		return

	var/mob/living/carbon/human/challenged = candidates[picked]
	if(QDELETED(challenged) || challenged.stat == DEAD || !ishuman(user))
		return

	ongoing_duel = new(src, user, challenged)
	if(QDELETED(ongoing_duel))
		ongoing_duel = null
		return
	RegisterSignal(ongoing_duel, COMSIG_QDELETING, PROC_REF(on_duel_over))


/obj/item/clothing/head/dream_catcher/proc/on_duel_over(datum/source)
	SIGNAL_HANDLER
	ongoing_duel = null


/mob/living/captive_brain/dreamer
	name = "sleeping mind"
	real_name = "sleeping mind"


/mob/living/captive_brain/dreamer/say(message, verb, sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE, ignore_emotes = FALSE)
	if(client?.handle_spam_prevention(message, MUTE_IC))
		return

	message = trim(sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN)))
	if(!message)
		return

	add_say_logs(src, message)
	var/mob/living/ridden = loc
	to_chat(src, "Вы беззвучно шепчете, \"[message]\"")
	if(isliving(ridden))
		to_chat(ridden, span_hypnophrase("<i>Запертый разум шепчет, \"[message]\"</i>"))

	for(var/mob/observer in GLOB.dead_mob_list)
		if(isobserver(observer))
			to_chat(observer, "<i>Thought-speech, <b>[src]</b>: [message]</i>")


/mob/living/captive_brain/dreamer/say_understands(mob/other, datum/language/speaking = null)
	var/mob/living/ridden = loc
	if(!isliving(ridden))
		return FALSE
	return ridden.say_understands(other, speaking)


/mob/living/captive_brain/dreamer/resist()
	to_chat(src, span_warning("Вы бьётесь изнутри, но чужой сон держит крепко."))


/datum/dream_duel
	var/obj/item/clothing/head/dream_catcher/catcher
	var/datum/weakref/challenger_body_ref
	var/datum/weakref/defender_body_ref
	var/mob/living/carbon/human/challenger_dream
	var/mob/living/carbon/human/defender_dream
	var/datum/turf_reservation/reservation
	var/datum/lazy_template/dream_arena/arena
	var/list/spawn_points = list()
	var/challenger_ckey
	var/defender_ckey
	var/duel_timer
	var/finished = FALSE


/datum/dream_duel/New(obj/item/clothing/head/dream_catcher/catcher, mob/living/carbon/human/challenger, mob/living/carbon/human/defender)
	src.catcher = catcher
	challenger_body_ref = WEAKREF(challenger)
	defender_body_ref = WEAKREF(defender)

	challenger.visible_message(span_warning("[DECLENT_RU_CAP(challenger, NOMINATIVE)] оседает, будто провалившись в сон посреди шага."))
	defender.visible_message(span_warning("[DECLENT_RU_CAP(defender, NOMINATIVE)] оседает, будто провалившись в сон посреди шага."))
	to_chat(defender, span_hypnophrase("Чужая рука вытягивает вас из вашего собственного сна."))

	arena = new()
	RegisterSignal(arena, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_arena_loaded))
	reservation = arena.lazy_load()
	if(!reservation)
		qdel(src)
		return


/datum/dream_duel/Destroy(force)
	if(!finished)
		finish(null)
	catcher = null
	challenger_dream = null
	defender_dream = null
	arena = null
	spawn_points.Cut()
	return ..()


/datum/dream_duel/proc/on_arena_loaded(datum/lazy_template/source, list/atoms)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_LAZY_TEMPLATE_LOADED)
	for(var/thing in atoms)
		if(istype(thing, /obj/effect/landmark/dream_duel_spawn))
			spawn_points += thing

	INVOKE_ASYNC(src, PROC_REF(start))


/datum/dream_duel/proc/start()
	var/mob/living/carbon/human/challenger = challenger_body_ref?.resolve()
	var/mob/living/carbon/human/defender = defender_body_ref?.resolve()
	if(length(spawn_points) < 2 || QDELETED(challenger) || QDELETED(defender))
		qdel(src)
		return

	challenger_ckey = challenger.ckey
	defender_ckey = defender.ckey
	challenger_dream = build_dreamer(challenger, spawn_points[1])
	defender_dream = build_dreamer(defender, spawn_points[2])
	QDEL_LIST(spawn_points)

	if(!challenger_dream || !defender_dream)
		qdel(src)
		return

	RegisterSignals(challenger_dream, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING, COMSIG_MOB_GHOSTIZE), PROC_REF(on_dreamer_down))
	RegisterSignals(defender_dream, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING, COMSIG_MOB_GHOSTIZE), PROC_REF(on_dreamer_down))

	to_chat(challenger_dream, span_hypnophrase("Сон стал ареной. Только один проснётся целым."))
	to_chat(defender_dream, span_hypnophrase("Сон стал ареной. Только один проснётся целым."))

	duel_timer = addtimer(CALLBACK(src, PROC_REF(finish)), DREAM_POSSESSION_TIME, TIMER_STOPPABLE)


/datum/dream_duel/proc/build_dreamer(mob/living/carbon/human/sleeper, obj/effect/landmark/spawn_point)
	sleeper.SetSleeping(DREAM_POSSESSION_TIME)
	sleeper.add_traits(list(TRAIT_DREAMT_EYES, TRAIT_MIND_TEMPORARILY_GONE), UID())

	var/mob/living/carbon/human/dreamer = new(get_turf(spawn_point))
	sleeper.dna.transfer_identity(dreamer)
	dreamer.real_name = sleeper.real_name
	dreamer.name = sleeper.real_name
	dreamer.add_traits(list(TRAIT_TEMPORARY_BODY, TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), INNATE_TRAIT)
	dreamer.put_in_hands(new /obj/item/melee/sickly_blade/training(dreamer))
	dreamer.possess_by_player(sleeper.ckey)
	return dreamer


/datum/dream_duel/proc/on_dreamer_down(mob/living/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(finish), source)


/datum/dream_duel/proc/finish(mob/living/loser_dream)
	if(finished)
		return
	finished = TRUE
	deltimer(duel_timer)

	var/mob/living/carbon/human/challenger = challenger_body_ref?.resolve()
	var/mob/living/carbon/human/defender = defender_body_ref?.resolve()
	var/mob/living/carbon/human/loser_body

	if(loser_dream == challenger_dream)
		loser_body = challenger
	else if(loser_dream == defender_dream)
		loser_body = defender

	wake_up(challenger, challenger_dream, challenger_ckey)
	wake_up(defender, defender_dream, defender_ckey)

	if(loser_body)
		loser_body.adjustBruteLoss(loser_body.health - HEALTH_THRESHOLD_CRIT + 5)
		loser_body.updatehealth()
		to_chat(loser_body, span_userdanger("Вы проиграли во сне — и просыпаетесь с этим проигрышем в теле."))

	clear_reservation()

	if(!QDELING(src))
		qdel(src)


/datum/dream_duel/proc/wake_up(mob/living/carbon/human/sleeper, mob/living/carbon/human/dreamer, dreamer_ckey)
	if(dreamer)
		UnregisterSignal(dreamer, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING, COMSIG_MOB_GHOSTIZE))

	if(QDELETED(sleeper))
		if(!QDELETED(dreamer))
			dreamer.ghostize()
	else
		sleeper.remove_traits(list(TRAIT_DREAMT_EYES, TRAIT_MIND_TEMPORARILY_GONE), UID())
		sleeper.SetSleeping(0)
		sleeper.possess_by_player(dreamer_ckey)
		to_chat(sleeper, span_hypnophrase("Сон отпускает вас, и вы возвращаетесь в собственное тело."))

	if(!QDELETED(dreamer))
		qdel(dreamer)


/datum/dream_duel/proc/clear_reservation()
	if(isnull(reservation) || isnull(arena))
		return
	for(var/turf/reserved as anything in reservation.reserved_turfs)
		reserved.empty()
	arena.reservations -= reservation
	QDEL_NULL(reservation)


/obj/effect/landmark/dream_duel_spawn
	name = "dream duel spawn"


/obj/structure/dream_pillar
	name = "sleeping monolith"
	desc = "Столб, который стоял здесь всегда, потому что кому-то приснилось, что он тут стоял."
	gender = MALE
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE


/obj/structure/dream_pillar/get_ru_names()
	return alist(
		NOMINATIVE = "спящий монолит",
		GENITIVE = "спящего монолита",
		DATIVE = "спящему монолиту",
		ACCUSATIVE = "спящий монолит",
		INSTRUMENTAL = "спящим монолитом",
		PREPOSITIONAL = "спящем монолите",
	)


/turf/simulated/floor/indestructible/dreamsand
	name = "dreamt ground"
	desc = "Земля, которую никто не потрудился доснить до конца."
	gender = FEMALE
	icon_state = "grass1"
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_TEMPERATE


/turf/simulated/floor/indestructible/dreamsand/get_ru_names()
	return alist(
		NOMINATIVE = "приснившаяся земля",
		GENITIVE = "приснившейся земли",
		DATIVE = "приснившейся земле",
		ACCUSATIVE = "приснившуюся землю",
		INSTRUMENTAL = "приснившейся землёй",
		PREPOSITIONAL = "приснившейся земле",
	)


/turf/simulated/wall/indestructible/dreamstone
	name = "edge of the dream"
	desc = "Дальше сон просто не был досмотрен."
	gender = MALE
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS


/turf/simulated/wall/indestructible/dreamstone/get_ru_names()
	return alist(
		NOMINATIVE = "край сна",
		GENITIVE = "края сна",
		DATIVE = "краю сна",
		ACCUSATIVE = "край сна",
		INSTRUMENTAL = "краем сна",
		PREPOSITIONAL = "крае сна",
	)


/area/centcom/dream_arena
	name = "Dream"
	icon = 'icons/area/eldritch_areas.dmi'
	icon_state = "heretic"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	area_flags = UNIQUE_AREA
	no_teleportlocs = TRUE
	tele_proof = TRUE
	base_lighting_alpha = 200
	base_lighting_color = "#6FE3D4"


/datum/lazy_template/dream_arena
	key = LAZY_TEMPLATE_KEY_DREAM_ARENA
	map_name = "dream_arena"

#undef DREAM_MODE_PROWL
#undef DREAM_MODE_DUEL
#undef DREAM_POSSESSION_TIME
