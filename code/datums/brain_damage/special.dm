#define BEEPSKY_SPAWN_RANGE 12

/datum/brain_trauma/special
	abstract_type = /datum/brain_trauma/special

/datum/brain_trauma/special/godwoken
	name = "Godwoken Syndrome"
	desc = "Устами пациента изредка и против его воли вещает древний бог."
	scan_desc = "богоодержимость"
	gain_text = span_notice_alt("Вы чувствуете в своей голове присутствие высшей силы...")
	lose_text = span_warning_alt("Божественное присутствие покидает вашу голову, потеряв к вам интерес.")

/datum/brain_trauma/special/godwoken/on_gain()
	if(owner.mind)
		owner.mind.isholy = TRUE
	return ..()

/datum/brain_trauma/special/godwoken/on_lose(silent)
	if(owner.mind && owner.mind.assigned_role != JOB_TITLE_CHAPLAIN)
		owner.mind.isholy = FALSE
	return ..()

/datum/brain_trauma/special/godwoken/on_life()
	if(!prob(4))
		return

	if(prob(33) && (owner.IsStunned() || owner.IsWeakened() || owner.IsKnockdown()))
		speak("god_unstun", TRUE)
	else if(prob(60) && owner.health <= HEALTH_THRESHOLD_CRIT)
		speak("god_heal", TRUE)
	else if(prob(30) && owner.a_intent == INTENT_HARM)
		speak("god_aggressive")
	else
		speak("god_neutral", prob(25))

/datum/brain_trauma/special/godwoken/proc/speak(phrase_key, include_owner = FALSE)
	var/message = pick_list_replacements(BRAIN_DAMAGE_FILE, phrase_key)
	if(!message)
		return

	var/datum/language/previous_default = owner.default_language
	owner.default_language = GLOB.all_languages[LANGUAGE_ANGEL]
	owner.say(uppertext(message), ignore_speech_problems = TRUE, ignore_atmospherics = TRUE)
	owner.default_language = previous_default
	voice_of_god(message, owner, power_multiplier = 2.5, include_speaker = include_owner)

/datum/brain_trauma/special/bluespace_prophet
	name = "Bluespace Prophecy"
	desc = "Пациент чувствует колебания блюспейса вокруг себя, и тот открывает ему проходы, которых не видит никто другой."
	scan_desc = "блюспейс-настройка"
	gain_text = span_notice_alt("Вокруг вас пульсирует блюспейс...")
	lose_text = span_warning_alt("Слабая пульсация блюспейса стихает.")
	COOLDOWN_DECLARE(portal_cooldown)

/datum/brain_trauma/special/bluespace_prophet/on_life()
	if(!COOLDOWN_FINISHED(src, portal_cooldown))
		return

	COOLDOWN_START(src, portal_cooldown, 10 SECONDS)
	var/list/turf/possible_turfs = list()
	for(var/turf/candidate as anything in RANGE_TURFS(8, owner))
		if(candidate.density)
			continue

		var/clear = TRUE
		for(var/obj/blocker in candidate)
			if(blocker.density)
				clear = FALSE
				break
		if(clear)
			possible_turfs += candidate

	if(!length(possible_turfs))
		return

	var/turf/first_turf = pick(possible_turfs)
	possible_turfs -= (possible_turfs & range(first_turf, 3))
	if(!length(possible_turfs))
		return

	var/obj/effect/client_image_holder/bluespace_stream/first = new(first_turf, owner)
	var/obj/effect/client_image_holder/bluespace_stream/second = new(pick(possible_turfs), owner)
	first.linked_to = second
	second.linked_to = first

/obj/effect/client_image_holder/bluespace_stream
	name = "bluespace stream"
	desc = "Вы видите скрытую тропу сквозь блюспейс..."
	image_icon = 'icons/effects/effects.dmi'
	image_state = "bluestream"
	image_layer = ABOVE_MOB_LAYER
	var/obj/effect/client_image_holder/bluespace_stream/linked_to

/obj/effect/client_image_holder/bluespace_stream/Initialize(mapload, list/mobs_which_see_us)
	. = ..()
	QDEL_IN(src, 30 SECONDS)

/obj/effect/client_image_holder/bluespace_stream/generate_image()
	. = ..()
	apply_wibbly_filters(.)

/obj/effect/client_image_holder/bluespace_stream/Destroy(force)
	if(!QDELETED(linked_to))
		qdel(linked_to)
	linked_to = null
	return ..()

/obj/effect/client_image_holder/bluespace_stream/attack_tk(mob/user)
	to_chat(user, span_warning("Поток отторгает ваш разум, а бурлящие вокруг него энергии блюспейса рвут телекинетическую хватку!"))

/obj/effect/client_image_holder/bluespace_stream/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!(user in who_sees_us) || QDELETED(linked_to))
		return

	to_chat(user, span_notice("Вы пытаетесь поймать течение блюспейса..."))
	if(!do_after(user, 2 SECONDS, src))
		return

	var/turf/source_turf = get_turf(src)
	var/turf/destination_turf = get_turf(linked_to)
	new /obj/effect/temp_visual/bluespace_fissure(source_turf)
	new /obj/effect/temp_visual/bluespace_fissure(destination_turf)

	var/slip_in_message = pick(
		"как-то боком соскальзывает вбок и исчезает",
		"шагает в невидимое измерение",
		"замирает, а затем гаснет, выпадая из реальности",
		"втягивается в невидимую воронку и пропадает из виду",
	)
	var/slip_out_message = pick(
		"беззвучно проявляется",
		"выпрыгивает из пустоты",
		"выходит из невидимой двери",
		"выскальзывает из складки пространства",
	)

	user.visible_message(span_warning("[user] [slip_in_message]."), ignored_mobs = user)
	if(do_teleport(user, destination_turf))
		user.visible_message(span_warning("[user] [slip_out_message]."), span_notice("...и находите путь на ту сторону."))
	else
		user.visible_message(span_warning("[user] [slip_out_message] ровно на том же месте."), span_notice("...и оказываетесь там же, откуда начали?"))

/obj/effect/temp_visual/bluespace_fissure
	name = "bluespace fissure"
	icon_state = "bluestream_fade"
	duration = 0.9 SECONDS

/obj/effect/temp_visual/bluespace_fissure/Initialize(mapload)
	. = ..()
	apply_wibbly_filters(src)

/datum/brain_trauma/special/quantum_alignment
	name = "Quantum Alignment"
	desc = "Пациент вопреки всякой вероятности постоянно спонтанно запутывается с окружающим, вызывая пространственные аномалии."
	scan_desc = "квантовая сцепленность"
	gain_text = span_notice_alt("Вы чувствуете слабую связь со всем вокруг...")
	lose_text = span_warning_alt("Вы больше не чувствуете связи с окружающим.")
	var/atom/linked_target
	var/returning = FALSE
	COOLDOWN_DECLARE(snapback_cooldown)

/datum/brain_trauma/special/quantum_alignment/on_lose(silent)
	linked_target = null
	return ..()

/datum/brain_trauma/special/quantum_alignment/on_life()
	if(linked_target)
		if(QDELETED(linked_target))
			linked_target = null
			return
		if(!returning && COOLDOWN_FINISHED(src, snapback_cooldown))
			start_snapback()
		return

	if(prob(4))
		try_entangle()

/datum/brain_trauma/special/quantum_alignment/proc/try_entangle()
	if(ismob(owner.pulling))
		entangle(owner.pulling)
		return

	for(var/mob/living/victim in oview(1, owner))
		if(owner.Adjacent(victim))
			entangle(victim)
			return

	if(isobj(owner.pulling))
		entangle(owner.pulling)
		return

	for(var/obj/item/held in list(owner.get_active_hand(), owner.get_inactive_hand()))
		if(!HAS_TRAIT(held, TRAIT_NODROP))
			entangle(held)
			return

	entangle(get_turf(owner))

/datum/brain_trauma/special/quantum_alignment/proc/entangle(atom/target)
	to_chat(owner, span_notice("Вы начинаете чувствовать сильную связь с [target]."))
	linked_target = target
	COOLDOWN_START(src, snapback_cooldown, rand(45 SECONDS, 10 MINUTES))

/datum/brain_trauma/special/quantum_alignment/proc/start_snapback()
	if(QDELETED(linked_target))
		linked_target = null
		return

	to_chat(owner, span_warning("Ваша связь с [linked_target] внезапно становится невыносимо сильной... вас тянет к ней!"))
	owner.playsound_local(get_turf(owner), 'sound/magic/lightning_chargeup.ogg', 75, FALSE)
	returning = TRUE
	addtimer(CALLBACK(src, PROC_REF(snapback)), 10 SECONDS, TIMER_DELETE_ME)

/datum/brain_trauma/special/quantum_alignment/proc/snapback()
	returning = FALSE
	if(QDELETED(linked_target))
		to_chat(owner, span_notice("Связь резко обрывается, и вместе с ней исчезает притяжение."))
		linked_target = null
		return

	to_chat(owner, span_warning("Вас протаскивает сквозь пространство-время!"))
	do_teleport(owner, get_turf(linked_target))
	owner.playsound_local(get_turf(owner), 'sound/magic/repulse.ogg', 100, FALSE)
	linked_target = null

/datum/brain_trauma/special/psychotic_brawling
	name = "Violent Psychosis"
	desc = "Пациент дерётся совершенно непредсказуемо — от попыток помочь противнику до ударов чудовищной силы."
	scan_desc = "буйный психоз"
	gain_text = span_warning_alt("Вас ведёт...")
	lose_text = span_notice_alt("Вы снова чувствуете себя уравновешенным.")
	var/datum/martial_art/psychotic_brawling/psychotic_brawling

/datum/brain_trauma/special/psychotic_brawling/on_gain()
	. = ..()
	if(!ishuman(owner))
		return
	psychotic_brawling = new
	psychotic_brawling.teach(owner)

/datum/brain_trauma/special/psychotic_brawling/on_lose(silent)
	if(psychotic_brawling && ishuman(owner))
		psychotic_brawling.remove(owner)
	QDEL_NULL(psychotic_brawling)
	return ..()

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	name = "Chemical Violent Psychosis"
	known_trauma = FALSE

/datum/brain_trauma/special/tenacity
	name = "Tenacity"
	desc = "Пациент психологически не реагирует на боль и увечья и держится на ногах намного дольше обычного человека."
	scan_desc = "травматическая нейропатия"
	gain_text = span_warning_alt("Вы внезапно перестаёте чувствовать боль.")
	lose_text = span_warning_alt("Вы понимаете, что снова чувствуете боль.")

/datum/brain_trauma/special/tenacity/on_gain()
	owner.add_traits(list(TRAIT_NO_PAIN, TRAIT_NO_PAIN_HUD, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/special/tenacity/on_lose(silent)
	owner.remove_traits(list(TRAIT_NO_PAIN, TRAIT_NO_PAIN_HUD, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT), TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/special/death_whispers
	name = "Functional Cerebral Necrosis"
	desc = "Мозг пациента застрял в состоянии функциональной клинической смерти, из-за чего он изредка ловит ясные галлюцинации, которые обычно принимают за голоса мёртвых."
	scan_desc = "хронический функциональный некроз"
	gain_text = span_warning_alt("Внутри вас всё будто умерло.")
	lose_text = span_notice_alt("Вы снова чувствуете себя живым.")
	var/whispering = FALSE

/datum/brain_trauma/special/death_whispers/on_life()
	if(!whispering && prob(2))
		start_whispering()

/datum/brain_trauma/special/death_whispers/on_lose(silent)
	if(whispering)
		cease_whispering()
	return ..()

/datum/brain_trauma/special/death_whispers/proc/start_whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	whispering = TRUE
	addtimer(CALLBACK(src, PROC_REF(cease_whispering)), rand(5 SECONDS, 30 SECONDS), TIMER_DELETE_ME)

/datum/brain_trauma/special/death_whispers/proc/cease_whispering()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	whispering = FALSE

/datum/brain_trauma/special/existential_crisis
	name = "Existential Crisis"
	desc = "Пациент едва держится за реальность, из-за чего временами перестаёт существовать."
	scan_desc = "экзистенциальный кризис"
	gain_text = span_warning_alt("Вы чувствуете себя менее настоящим.")
	lose_text = span_notice_alt("Вы снова чувствуете себя чем-то основательным.")
	var/obj/effect/nonexistence/veil
	COOLDOWN_DECLARE(crisis_cooldown)

/datum/brain_trauma/special/existential_crisis/on_life()
	if(veil || !COOLDOWN_FINISHED(src, crisis_cooldown) || !isturf(owner.loc))
		return

	if(prob(3))
		fade_out()

/datum/brain_trauma/special/existential_crisis/on_lose(silent)
	if(veil)
		fade_in()
	return ..()

/datum/brain_trauma/special/existential_crisis/proc/fade_out()
	veil = new(get_turf(owner))
	to_chat(owner, span_warning(pick(
		"А существуете ли вы вообще?",
		"Быть или не быть...",
		"Зачем существовать?",
		"Вы попросту растворяетесь.",
		"Вы перестаёте держаться за реальность.",
		"Вы на мгновение перестаёте мыслить. Следовательно, вас нет.",
	)))
	owner.forceMove(veil)
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(fade_in)), rand(5 SECONDS, 45 SECONDS), TIMER_DELETE_ME)

/datum/brain_trauma/special/existential_crisis/proc/fade_in()
	QDEL_NULL(veil)
	to_chat(owner, span_notice("Вы возвращаетесь в реальность."))
	COOLDOWN_START(src, crisis_cooldown, 1 MINUTES)

/obj/effect/nonexistence
	name = "non-existence"
	desc = "Существование — всего лишь состояние ума."
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE

/obj/effect/nonexistence/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SECLUDED_LOCATION, INNATE_TRAIT)

/obj/effect/nonexistence/Destroy()
	for(var/atom/movable/thing in contents)
		thing.forceMove(get_turf(src))
	return ..()

/obj/effect/nonexistence/relaymove(mob/living/user, direction)
	return

/obj/effect/nonexistence/AllowDrop()
	return TRUE

/datum/brain_trauma/special/beepsky
	name = "Criminal"
	desc = "Пациент убеждён, что он преступник и что за ним идёт правосудие."
	scan_desc = "криминальное мышление"
	gain_text = span_warning_alt("Правосудие идёт за вами.")
	lose_text = span_notice_alt("Вам отпустили все ваши прегрешения.")
	random_gain = FALSE
	known_trauma = FALSE
	var/obj/effect/client_image_holder/securitron/securitron

/datum/brain_trauma/special/beepsky/Destroy()
	QDEL_NULL(securitron)
	return ..()

/datum/brain_trauma/special/beepsky/on_gain()
	create_securitron()
	return ..()

/datum/brain_trauma/special/beepsky/on_lose(silent)
	QDEL_NULL(securitron)
	return ..()

/datum/brain_trauma/special/beepsky/proc/create_securitron()
	QDEL_NULL(securitron)
	var/turf/spawn_turf = locate(owner.x + pick(-BEEPSKY_SPAWN_RANGE, BEEPSKY_SPAWN_RANGE), owner.y + pick(-BEEPSKY_SPAWN_RANGE, BEEPSKY_SPAWN_RANGE), owner.z)
	if(!spawn_turf)
		return
	securitron = new(spawn_turf, owner)

/datum/brain_trauma/special/beepsky/on_life()
	if(QDELETED(securitron) || !securitron.loc || securitron.z != owner.z)
		if(prob(30))
			create_securitron()
		return

	if(get_dist(owner, securitron) >= 10 && prob(20))
		create_securitron()
		return

	if(owner.stat != CONSCIOUS)
		if(prob(20))
			owner.playsound_local(get_turf(securitron), 'sound/voice/biamthelaw.ogg', 50)
		return

	if(get_dist(owner, securitron) <= 1)
		owner.playsound_local(get_turf(owner), 'sound/weapons/egloves.ogg', 50)
		owner.visible_message(
			span_warning("[DECLENT_RU_CAP(owner, NOMINATIVE)] дёрга[PLUR_ET_YUT(owner)]ся, словно от удара током."),
			span_userdanger("Вы чувствуете кулак ЗАКОНА."),
		)
		owner.adjustStaminaLoss(rand(40, 70))
		QDEL_NULL(securitron)
		return

	if(prob(20) && get_dist(owner, securitron) <= 8)
		owner.playsound_local(get_turf(securitron), 'sound/voice/bcriminal.ogg', 40)

/obj/effect/client_image_holder/securitron
	name = "Securitron"
	desc = "ЗАКОН уже близко."
	image_icon = 'icons/obj/aibots.dmi'
	image_state = "secbot-c"

/obj/effect/client_image_holder/securitron/Initialize(mapload, list/mobs_which_see_us)
	. = ..()
	name = pick("Officer Beepsky", "Officer Johnson", "Officer Pingsky")
	START_PROCESSING(SSfastprocess, src)

/obj/effect/client_image_holder/securitron/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/client_image_holder/securitron/process()
	if(prob(40))
		return

	var/mob/victim = pick(who_sees_us)
	forceMove(get_step_towards(src, victim))
	if(!prob(5))
		return

	var/warning = "Нарушение десятого уровня!"
	to_chat(victim, "[span_name("[name]")] заявляет: [span_robot("«[warning]»")]")
	if(victim.client?.prefs?.toggles2 & PREFTOGGLE_2_RUNECHAT)
		victim.create_chat_message(src, warning, list("robot"))

/datum/brain_trauma/special/ptsd
	name = "Combat PTSD"
	desc = "Пациент переживает посттравматическое расстройство после боевого опыта: его накрывают флешбэки и слуховые галлюцинации."
	scan_desc = "посттравматическое расстройство"
	gain_text = span_warning_alt("Вас швыряет обратно в хаос прошлого! Взрывы! Выстрелы!")
	lose_text = span_notice_alt("Отголоски прошлого стихают, и в голове проясняется.")
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	random_gain = FALSE
	COOLDOWN_DECLARE(flashback_cooldown)

/datum/brain_trauma/special/ptsd/on_life()
	if(owner.stat != CONSCIOUS || !COOLDOWN_FINISHED(src, flashback_cooldown))
		return

	COOLDOWN_START(src, flashback_cooldown, rand(10 SECONDS, 10 MINUTES))
	owner.hallucinate_living(pick("battle", "sounds"))

/datum/brain_trauma/special/primal_instincts
	name = "Feral Instincts"
	desc = "Разум пациента застревает в первобытном состоянии, и временами он действует не рассудком, а инстинктом."
	scan_desc = "одичание"
	gain_text = span_warning_alt("Ваши зрачки расширяются, и думать становится тяжелее.")
	lose_text = span_notice_alt("В голове проясняется, и вы снова владеете собой.")
	var/feral = FALSE
	var/aggressive = FALSE

/datum/brain_trauma/special/primal_instincts/on_lose(silent)
	if(feral)
		calm_down()
	return ..()

/datum/brain_trauma/special/primal_instincts/on_life()
	if(owner.stat != CONSCIOUS)
		return

	if(!feral)
		if(prob(3))
			go_feral()
		return

	if(aggressive)
		owner.a_intent = INTENT_HARM

	if(prob(25))
		drop_tools()

	if(prob(10))
		owner.emote(aggressive ? "scream" : "chuckle")

/datum/brain_trauma/special/primal_instincts/proc/go_feral()
	feral = TRUE
	aggressive = prob(75)
	owner.add_language(LANGUAGE_MONKEY_HUMAN)
	drop_tools()
	to_chat(owner, span_warning("Вас захлёстывает желание поддаться первобытным инстинктам..."))
	add_game_logs("became controlled by primal instincts ([aggressive ? "aggressive" : "docile"])", owner)
	addtimer(CALLBACK(src, PROC_REF(calm_down)), rand(20 SECONDS, 40 SECONDS), TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

/datum/brain_trauma/special/primal_instincts/proc/calm_down()
	feral = FALSE
	aggressive = FALSE
	owner.remove_language(LANGUAGE_MONKEY_HUMAN)
	to_chat(owner, span_green("Позыв отступает."))

/datum/brain_trauma/special/primal_instincts/proc/drop_tools()
	for(var/obj/item/held in list(owner.get_active_hand(), owner.get_inactive_hand()))
		if(HAS_TRAIT(held, TRAIT_NODROP))
			continue
		owner.drop_item_ground(held)
		owner.balloon_alert(owner, "руки не слушаются!")

/datum/brain_trauma/special/axedoration
	name = "Axe Delusions"
	desc = "Пациент считает своим священным долгом оберегать пожарный топор и видит связанные с ним галлюцинации."
	scan_desc = "привязанность к предмету"
	gain_text = span_notice_alt("Вы чувствуете, что оберегать пожарный топор — один из главных ваших долгов.")
	lose_text = span_warning_alt("Вы будто утратили своё чувство долга.")
	resilience = TRAUMA_RESILIENCE_ABSOLUTE
	random_gain = FALSE
	known_trauma = FALSE
	var/static/list/talk_lines = list(
		"Я горжусь тобой.",
		"Я верю в тебя!",
		"Я тебе мешаю?",
		"Восхваляй меня!",
		"Огонь жжёт.",
		"Мы справились!",
		"Мама, моё тело противно мне.",
		"Между нами есть зазор, где кончаюсь я и начинаешься ты.",
		"Смирись.",
	)
	var/static/list/hurt_lines = list(
		"Ай!",
		"Ой!",
		"Ак!",
		"Жжётся!",
		"Хватит!",
		"Аргх!",
		"Прошу!",
		"Прекрати это!",
		"Довольно!",
		"А!",
	)

/datum/brain_trauma/special/axedoration/on_gain()
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequip))
	RegisterSignal(owner, COMSIG_MOB_EXAMINING, PROC_REF(on_examine))
	if(GLOB.bridge_axe)
		RegisterSignal(GLOB.bridge_axe, COMSIG_QDELETING, PROC_REF(on_axe_destroyed))
		RegisterSignal(GLOB.bridge_axe, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_axe_attack))
	return ..()

/datum/brain_trauma/special/axedoration/on_lose(silent)
	UnregisterSignal(owner, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EXAMINING))
	if(GLOB.bridge_axe)
		UnregisterSignal(GLOB.bridge_axe, list(COMSIG_QDELETING, COMSIG_ITEM_AFTERATTACK))
	return ..()

/datum/brain_trauma/special/axedoration/on_life()
	if(owner.stat != CONSCIOUS)
		return

	if(!GLOB.bridge_axe)
		if(prob(1))
			to_chat(owner, span_warning("Я не справился со своим долгом..."))
			owner.AdjustJitter(5 SECONDS)
			owner.AdjustStuttering(5 SECONDS)
			if(prob(40))
				owner.vomit()
		return

	if(!prob(3))
		return

	var/atom/axe_location = get_axe_location()
	if(isliving(axe_location))
		if(axe_location == owner)
			axe_says(pick(talk_lines))
			return
		var/mob/living/axe_holder = axe_location
		if(axe_holder.mind?.assigned_role in GLOB.command_positions)
			to_chat(owner, span_notice("Надеюсь, топор в надёжных руках..."))
			return
		to_chat(owner, span_warning("Вас начинают одолевать дурные предчувствия..."))
		return

	if(istype(axe_location, /area/station/command))
		to_chat(owner, span_notice("Вы чувствуете облегчение..."))
		return

	to_chat(owner, span_warning("Вас начинают одолевать дурные предчувствия..."))

/datum/brain_trauma/special/axedoration/proc/on_axe_destroyed(datum/source)
	SIGNAL_HANDLER

	to_chat(owner, span_danger("Вы ощущаете великое возмущение силы."))
	owner.AdjustJitter(15 SECONDS)
	owner.AdjustStuttering(15 SECONDS)

/datum/brain_trauma/special/axedoration/proc/on_axe_attack(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER

	if(user == owner)
		axe_says(pick(hurt_lines))

/datum/brain_trauma/special/axedoration/proc/on_equip(datum/source, obj/item/picked_up, slot)
	SIGNAL_HANDLER

	if(!istype(picked_up, /obj/item/twohanded/fireaxe))
		return

	owner.AdjustJitter(3 SECONDS)
	if(picked_up == GLOB.bridge_axe)
		to_chat(owner, span_hypnophrase("Он у меня. Пора вернуть его на место."))
		return

	ADD_TRAIT(picked_up, TRAIT_NODROP, TRAUMA_TRAIT)
	to_chat(owner, span_warning("...Это не тот, за которым я присматриваю."))
	owner.Immobilize(2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(throw_faker), picked_up), 2 SECONDS, TIMER_DELETE_ME)

/datum/brain_trauma/special/axedoration/proc/throw_faker(obj/item/faker)
	REMOVE_TRAIT(faker, TRAIT_NODROP, TRAUMA_TRAIT)
	if(QDELETED(faker) || QDELETED(owner) || faker.loc != owner)
		return

	to_chat(owner, span_warning("Сгинь."))
	owner.drop_item_ground(faker)
	faker.throw_at(get_edge_target_turf(owner, owner.dir), faker.throw_range, faker.throw_speed, owner)

/datum/brain_trauma/special/axedoration/proc/on_unequip(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER

	if(dropped_item != GLOB.bridge_axe)
		return

	if(!istype(new_location, /obj/structure/closet/fireaxecabinet))
		to_chat(owner, span_warning("Стоит ли мне и правда оставлять его здесь?"))
		return

	if(istype(get_area(new_location), /area/station/command))
		to_chat(owner, span_green("Ах! Вернулся туда, где ему и место!"))
		return

	to_chat(owner, span_warning("Оставить его вне командного отсека? Уверен ли я в этом?"))

/datum/brain_trauma/special/axedoration/proc/on_examine(mob/source, atom/examined, list/examine_strings)
	SIGNAL_HANDLER

	if(!istype(examined, /obj/item/twohanded/fireaxe))
		return

	if(examined == GLOB.bridge_axe)
		examine_strings += span_notice("Это тот самый топор, который я поклялся оберегать.")
	else
		examine_strings += span_warning("Это подделка, фальшивый топор, созданный дурачить массы.")

/datum/brain_trauma/special/axedoration/proc/axe_says(message)
	to_chat(owner, span_hypnophrase("[span_name("[GLOB.bridge_axe]")] говорит: «[message]»"))

/datum/brain_trauma/special/axedoration/proc/get_axe_location()
	if(!GLOB.bridge_axe)
		return

	var/atom/axe_loc = GLOB.bridge_axe.loc
	while(axe_loc && !ismob(axe_loc) && !isarea(axe_loc))
		axe_loc = axe_loc.loc
	return axe_loc

#undef BEEPSKY_SPAWN_RANGE
