/// Your mother shows up to scold you.
/// - НЕТ В 1984: `/datum/component/leash` — мама просто стоит и ругается, не следует за целью;
// должно быть. Например в старой версии файла галлюцинации была галлюцинация с мартышкой, которая преследовала игрока и кусала, нанося урон по выносливости. Если это не подоходит - нужно создать этот компонент.
// Так же мне не нравится реализация talk. Должно казаться, что это пишет другой игрок, то есть нужно использовать не to_chat, а say, чтобы над спрайтом "мамы" появлялось сообщение.
/datum/hallucination/your_mother
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL

	var/obj/effect/client_image_holder/hallucination/your_mother/mother

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
	point_at(hallucinator)
	talk("[capitalize(hallucinator.real_name)]!!!!")
	var/list/scold_lines = list(
		pick("Убери в своей комнате!", "Иди помойся!", "Ты снова в компьютере сидишь?!", "Сколько можно говорить — помой посуду!", "Я не для того тебя растила, чтобы ты в космосе играл!", "А ну быстро спать!", "Опять в своих космонавтиков играешь!"),
		pick("Я так расстроена!", "Мне стыдно за тебя перед соседями!", "Ты хоть понимаешь, сколько я на тебя потратила?"),
		pick("Вот придёт отец — он тебе задаст!", "Я всё расскажу отцу!", "Будешь знать, как не слушаться!", "Это я ещё мягко с тобой!"),
	)
	var/delay = 2 SECONDS
	for(var/line in scold_lines)
		addtimer(CALLBACK(src, PROC_REF(talk), line), delay)
		delay += 2 SECONDS
	addtimer(CALLBACK(src, PROC_REF(exit)), delay + 4 SECONDS)
	return TRUE

/datum/hallucination/your_mother/proc/point_at(atom/target)
	var/turf/tile = get_turf(target)
	if(!tile)
		return

	var/obj/visual = image('icons/mob/screen_gen.dmi', mother.loc, "arrow", FLY_LAYER)

	// INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), visual, list(hallucinator.client), 2.5 SECONDS) ///proc/flick_overlay_global: undefined type path
	animate(visual, pixel_x = (tile.x - mother.x) * ICON_SIZE_X, pixel_y = (tile.y - mother.y) * ICON_SIZE_Y, time = 1.7, easing = QUAD_EASING|EASE_OUT)

/datum/hallucination/your_mother/proc/talk(text)
	to_chat(hallucinator, span_mind_control("<b>Ваша мать:</b> [text]"))

/datum/hallucination/your_mother/proc/exit()
	qdel(src)

/obj/effect/client_image_holder/hallucination/your_mother
	gender = FEMALE
	image_icon = 'icons/mob/human.dmi'
	image_state = "lizard_f_s" // Заглушка
	name = "Ваша мать"
	desc = "Она недовольна."
	image_layer = MOB_LAYER
