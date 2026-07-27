/datum/heretic_knowledge/void_cloak
	drafting_tier = 1
	name = "Плащ Пустоты"
	desc = "Позволяет преобразовать осколок стекла, простыню и любой предмет верхней одежды чтобы создать \
			Плащ Пустоты. Пока капюшон опущен, плащ служит источником фокуса. \
			Он также обеспечивает хорошую броню и \
			имеет карманы, в которые можно положить один из ваших клинков или различные ритуальные \
			принадлежности (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова — хранительница вещей не вполне практичных, но по крайней мере теоретичных. \
				На удивление, многие вещи являются таковыми."

	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/suits.dmi'
	research_tree_icon_state = "void_cloak"


/datum/heretic_knowledge/medallion
	drafting_tier = 1
	name = "Глаза Пепла" // It should be like colour of eyes, but I think this sounds better.
	desc = "Позволяет преобразовать пару глаз, свечу и осколок стекла в Потусторонний Медальон. \
			Потусторонний Медальон дарует вам термальное зрение, пока вы его носите, а также служит источником фокуса."
	gain_text = "Пронзительный взгляд вёл их сквозь обыденность. Ни тьма, ни страх не могли их остановить."

	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"


/datum/heretic_knowledge/essence
	drafting_tier = 1
	name = "Ритуал Священника"
	desc = "Позволяет превратить резервуар с водой и осколок стекла во флакон с эссенцией потустороннего. \
			Эссенцию потустороннего можно выпить для мощного исцеления или отравить ей язычников."
	gain_text = "Это старый рецепт. Мне его шепнула Сова. \
				Созданная Жрецом жидкость, которая находится перед вами, но при этом никогда не существовавшая."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1


	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"


/datum/heretic_knowledge/phylactery
	drafting_tier = 1
	name = "Проклятая Филактерия"
	desc = "Позволяет создать филактерию, \
			способную мгновенно набирать кровь даже с большого расстояния."
	transmute_text = "Преобразуйте лист стекла и мак."
	notice = "Цель филактерии может почувствовать укол."
	gain_text = "Настойка, принявшая форму кровососущего паразита. \
				Выбрала ли она эту форму сама, или это юмор больного разума, \
				создавшего это мерзкое орудие, — лучше не пытаться понять."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/food/snacks/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"


/datum/heretic_knowledge/crucible
	drafting_tier = 1
	name = "Котёл Страданий"
	desc = "Позволяет создать Котёл Страданий.<br>\
			Котёл Страданий варит мощные, но временные зелья. После каждого использования \
			его содержимое какое-то время восстанавливается — процесс можно ускорить, \
			подпитывая котёл частями тел и органами. \
			<br>&bull; Варево Души Котла: позволяет проходить сквозь стены. По окончании действия возвращает вас туда, где вы выпили зелье. \
			<br>&bull; Варево Заката и Рассвета: позволяет видеть сквозь стены. \
			<br>&bull; Варево Раненого Солдата: постепенно лечит вас. Чем тяжелее ваши раны (переломы, порезы), тем быстрее лечение."
	transmute_text = "Преобразуйте бак воды и стол."
	gain_text = "Это просто мучение. Мне не удалось вызвать фигуру Аристократа, \
				но благодаря вниманию Жреца я наткнулся на другой рецепт..."

	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1

	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "crucible"


/datum/heretic_knowledge/eldritch_coin
	drafting_tier = 1
	name = "Жуткая Монета"
	desc = "Позволяет преобразовать лист плазмы и алмаз в Жуткую Монету. \
			Монета будет открывать или закрывать ближайшие шлюзы при выпадении \"Еретика\" и переключать их болты \
			при выпадении \"Клинка\". Если вставить монету в шлюз, она будет уничтожена \
			и сожжёт его электронику, что сделает шлюз открытым навсегда, если только он не был заблокирован."
	gain_text = "Обитель — сборище всевозможных грехов. Но жадность играет здесь особую роль."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"


/obj/item/coin/eldritch
	name = "eldritch coin"
	desc = "Удивительно тяжёлая, богато украшенная монета. Рисунки на гранях постоянно меняются."
	gender = FEMALE
	icon_state = "coin_heretic"
	sideslist = list("heretic", "blade")
	/// The range at which airlocks are effected.
	var/airlock_range = 5


/obj/item/coin/eldritch/Initialize(mapload)
	. = ..()
	icon_state = "coin_heretic"


/obj/item/coin/eldritch/get_ru_names()
	return alist(
		NOMINATIVE = "жуткая монета",
		GENITIVE = "жуткой монеты",
		DATIVE = "жуткой монете",
		ACCUSATIVE = "жуткую монету",
		INSTRUMENTAL = "жуткой монетой",
		PREPOSITIONAL = "жуткой монете",
	)


/obj/item/coin/eldritch/attack_self(mob/user)
	var/mob/living/living_user = user
	if(!IS_HERETIC(user))
		living_user.adjustBruteLoss(5)
		return

	if(cooldown >= world.time - 15)
		return
	var/coinflip = pick(sideslist)
	cooldown = world.time
	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)
	if(!do_after(user, 1.5 SECONDS, src))
		return
	var/static/list/ru_coinflip = list(
		"heretic" = "Еретик",
		"blade" = "Клинок",
	)
	user.visible_message(
		span_notice("[user] подбрасыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]. Выпало: [span_bold(ru_coinflip[coinflip])]."),
		span_notice("Вы подбросили [declent_ru(ACCUSATIVE)]. Выпало: [span_bold(ru_coinflip[coinflip])]."),
		span_notice("Слышен звон монеты."),
	)
	on_result_act(coinflip)


/obj/item/coin/eldritch/proc/on_result_act(coinflip)
	switch(coinflip)
		if("heretic")
			for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, get_turf(src)))
				if(target_airlock.density)
					target_airlock.open()
					continue

				target_airlock.close()

		if("blade")
			for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, get_turf(src)))
				if(target_airlock.locked)
					target_airlock.unlock()
					continue

				target_airlock.lock()


/obj/item/coin/eldritch/melee_attack_chain(mob/living/user, atom/interacting_with, params)
	if(!is_airlock(interacting_with))
		return ..()

	if(!IS_HERETIC(user))
		user.adjustBruteLoss(5)
		user.adjustFireLoss(5)
		user.drop_from_active_hand()
		return ATTACK_CHAIN_BLOCKED_ALL

	var/obj/machinery/door/airlock/target_airlock = interacting_with
	to_chat(user, span_warning("Вы вставляете [declent_ru(ACCUSATIVE)] в шлюз."))
	target_airlock.emag_act(user, src)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/// Кодекс Истязания: lets heretics rush influences stealthily, or build a codex to take what's left
/// for more points - a tradeoff between speed/stealth and power, with strip searches as the downside.
/datum/heretic_knowledge/codex_cicatrix
	drafting_tier = 1
	is_shop_only = TRUE
	name = "Кодекс Истязания"
	desc = "Позволяет трансмутировать книгу, любую уникальную ручку (не обычную) и любой предмет на ваш выбор из туши (животного или человека), кожи или шкуры, чтобы создать Кодекс Истязания. \
			Кодекс Истязания можно использовать для получения дополнительных знаний при поглощении раскола реальности. \
			Кроме этого его можно использовать для более удобного рисования и удаления рун трансмутации, а также в качестве источника фокуса при сотворении заклинаний."
	gain_text = "Потусторонние силы оставляют фрагменты знаний и силы повсюду. Кодекс Истязания — одно из доказательств. \
				На кожанных страницах находятся знания, открывающие путь к Обители."
	required_atoms = list(
		list(/obj/item/toy/eldritch_book, /obj/item/book) = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide) = 1,
	)
	banned_atom_types = list(/obj/item/pen)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 4 // Low ritual priority, as it's an optional boon.
	var/static/list/non_mob_bindings = typecacheof(list(/obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide, /mob/living/simple_animal/mouse))
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "book"


/datum/heretic_knowledge/codex_cicatrix/parse_required_item(atom/item_path, number_of_things)
	if(item_path == /obj/item/pen)
		return "особый вид ручки"

	return ..()


/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE

		else if(!isliving(thingy))
			continue

		var/mob/living/body = thingy
		if(body.stat != DEAD)
			continue

		selected_atoms += body
		return TRUE

	user.balloon_alert(user, "нет трупа!")
	return FALSE


/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()

	var/atom/movable/ripped_thing = body

	if(iscarbon(body))
		var/mob/living/carbon/human/human_body = body
		var/obj/item/organ/external/bodypart = pick(human_body.bodyparts)
		ripped_thing = bodypart

		human_body.apply_damage(25, BRUTE, bodypart, sharp = TRUE)
	else
		body.apply_damage(25, BRUTE, sharp = TRUE)

	var/obj/item/le_book = locate(/obj/item/book) in selected_atoms
	if(!le_book)
		le_book = locate(/obj/item/toy/eldritch_book) in selected_atoms

	playsound(body, 'sound/items/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	body.visible_message(span_danger("Раздается ужасный звук, когда кожа отделяется от [ripped_thing.declent_ru(GENITIVE)] и обретает жутковатый синий оттенок, становясь обложкой [le_book ? le_book.declent_ru(GENITIVE) : "книги"]!"))
	return ..()


/datum/heretic_knowledge/miraculous_mirror
	drafting_tier = 1
	is_shop_only = TRUE
	name = "Чудотворное Зеркало"
	desc = "Позволяет создать Чудотворное Зеркало.<br>\
			Чудотворное Зеркало позволяет вам свободно менять любые черты своей внешности. \
			Через него можно даже сменить расу, но при этом зеркало разобьётся. \
			Язычник, заглянувший в зеркало, впадёт в транс, и отражение изменит его по своей прихоти."
	transmute_text = "Преобразуйте пять слитков серебра и пару органических глаз."
	gain_text = "Я был несовершенен, слаб. Как я мог достичь столь великих свершений в столь жалком состоянии? \
				В каждом окне, мимо которого я проходил, я видел своё отражение — и всякий раз чувствовал жгучее желание измениться, стать лучше, начать заново."
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/mineral/silver = 5,
	)
	result_atoms = list(/obj/item/mounted/mirror/heretic)
	cost = 1
	research_tree_icon_path = 'icons/obj/watercloset.dmi'
	research_tree_icon_state = "magic_mirror"


/datum/heretic_knowledge/miraculous_mirror/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/organ/internal/eyes/eye in atoms)
		if(eye.is_robotic())
			atoms -= eye


/// Warren King's Welcome: lets heretics gain maintenance/external airlock access without relying on
/// a HoP or having to off some poor assistant, and brand nearby airlocks as their own.
/datum/heretic_knowledge/bookworm
	drafting_tier = 1
	name = "Приветствие короля Уоррена"
	desc = "Ставит клеймо на все принесённые ID-карты и ближайшие шлюзы.<br>\
			Заклеймённые ID-карты получают доступ к тех тоннелям, внешним шлюзам, а также к заклеймённым шлюзам.<br>\
			Заклеймённые шлюзы открываются только заклеймённой ID-картой."
	transmute_text = "Преобразуйте 10 кусков кабеля, лист бумаги и мультитул."
	gain_text = "Въевшись в кости пальцев, существо направляет мой гудящий, затуманенный разум к массивной двери. \
				Медленно свет танцует среди наползающей тьмы, покрывая зловонный променад бесконечными бликами. \
				Но король скоро получит свой фунт плоти. Даже здесь сборщик налогов получает свою долю. Ибо нужно кормить тысячи ртов."
	required_atoms = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/paper = 1,
		/obj/item/multitool = 1,
	)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "eldritch"


/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		selected_atoms += used_id
	var/obj/item/card/id/user_card = user.get_id_card()
	if(istype(user_card))
		selected_atoms |= user_card


/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/improved_id in selected_atoms)
		improved_id.access |= list(ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_HERETIC)
		selected_atoms -= improved_id
	for(var/obj/machinery/door/airlock/door in view(7, loc))
		door.req_access = list(ACCESS_HERETIC)
		door.wires?.cut(WIRE_AI_CONTROL)
		do_sparks(3, FALSE, door.loc)
		var/obj/effect/light_emitter/brand_light = new(door.loc)
		brand_light.set_light(1.75, 1.5, "#a95c68")
		QDEL_IN(brand_light, 1 SECONDS)
		playsound(door, 'sound/magic/castsummon.ogg', 20, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
		playsound(door, SFX_SPARKS, 33, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	return TRUE
