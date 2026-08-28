/// Your mother shows up to scold you.
/datum/hallucination/your_mother
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL

	var/obj/effect/client_image_holder/hallucination/your_mother/mother

/datum/hallucination/your_mother/Destroy()
	if(!QDELETED(mother))
		GLOB.move_manager.stop_looping(mother)
		mother = null
	return ..()

/datum/hallucination/your_mother/start()
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	var/list/spawn_locs = list()
	for(var/turf/simulated/floor/floor in view(hallucinator, 4))
		if(floor.density)
			continue
		spawn_locs += floor

	if(!length(spawn_locs))
		return FALSE
	var/turf/spawn_loc = pick(spawn_locs)
	mother = new(spawn_loc, hallucinator, src)
	GLOB.move_manager.move_to(mother, hallucinator, 1, rand(2, 4)) // legacy
	point_at(hallucinator)
	talk("[capitalize(hallucinator.real_name)]!!!!")
	var/list/scold_lines = list(
		pick("Убери в своей комнате!", "Опять в игрушки играешься?", "Иди помойся!", "Ты снова в компьютере сидишь?!", "Я не для того тебя растила, чтобы ты в космонавтиков играл!", "Опять в своих космонавтиков играешь!", "Ты обещал \"Еще одну смену\" два часа назад!", "Вынеси мусор!", "Ты почему за девочку играешь?", "Кто этот ящер, который с тобой ходил? Опять плохая компания?"),
		pick("Я так расстроена!", "Мне стыдно за тебя перед соседями!", "Ты хоть понимаешь, сколько я на тебя потратила?", "Соседский сын уже юристом выучился, а ты только КЗ какое-то знаешь!", "Что за \"донат\"? Почему с моей карты списание?!", "Мне уже внуков пора, а ты в космонавтиков играешь!"),
		pick("Вот придёт отец — он тебе задаст!", "Я всё расскажу отцу!", "Я админу твоему позвоню, он со мной поговорит!"),
	)
	var/delay = 4 SECONDS
	for(var/line in scold_lines)
		addtimer(CALLBACK(src, PROC_REF(talk), line), delay)
		delay += 3 SECONDS
	addtimer(CALLBACK(src, PROC_REF(exit)), delay + 4 SECONDS)
	return TRUE

/datum/hallucination/your_mother/proc/point_at(atom/target)
	var/turf/tile = get_turf(target)
	if(!tile)
		return

	var/obj/visual = image('icons/mob/screen_gen.dmi', mother.loc, "arrow", FLY_LAYER)
	animate(visual, pixel_x = (tile.x - mother.x) * ICON_SIZE_X, pixel_y = (tile.y - mother.y) * ICON_SIZE_Y, time = 3, easing = QUAD_EASING|EASE_OUT)

	hallucinator.client?.images |= visual
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_arrow_image), hallucinator, visual), 2.5 SECONDS)

/// Removes the arrow visual from the hallucinator's client after it is done showing.
/proc/remove_arrow_image(mob/hallucinator, obj/visual)
	if(QDELETED(hallucinator))
		return
	hallucinator.client?.images -= visual

/datum/hallucination/your_mother/proc/talk(text)
	hallucinator.create_chat_message(mother, text, list("sans-serif"), null)
	to_chat(hallucinator, span_italics("<b>[mother.name]</b> говорит: \"[text]\""))
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, mother, hallucinator, text, mother.tts_seed, TRUE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM)

/datum/hallucination/your_mother/proc/exit()
	qdel(src)

/obj/effect/client_image_holder/hallucination/your_mother
	gender = FEMALE
	image_icon = 'icons/mob/human.dmi'
	image_state = "mother"
	name = "Ваша мать"
	desc = "Она недовольна."
	tts_seed = "Grelod"
