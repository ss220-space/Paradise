// MARK: Balloons
/obj/item/toy/waterballoon
	name = "water balloon"
	desc = "Полупрозрачный воздушный шарик. В нём ничего нет."
	icon = 'icons/obj/toys/balloons.dmi'
	icon_state = "balloon_red-e"
	item_state = "waterballoon-e"

/obj/item/toy/waterballoon/get_ru_names()
	return alist(
		NOMINATIVE = "шарик",
		GENITIVE = "шарика",
		DATIVE = "шарику",
		ACCUSATIVE = "шарик",
		INSTRUMENTAL = "шариком",
		PREPOSITIONAL = "шарике",
	)

/obj/item/toy/waterballoon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	create_reagents(10)

/obj/item/toy/waterballoon/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/toy/waterballoon/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!istype(target, /obj/structure/reagent_dispensers))
		return

	var/obj/structure/reagent_dispensers/dispencer = target
	if(dispencer.reagents.total_volume <= 0)
		to_chat(user, span_warning("[DECLENT_RU_CAP(dispencer, NOMINATIVE)] пустой."))
		return
	else if(reagents.total_volume >= 10)
		to_chat(user, span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] полный."))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	target.reagents.trans_to(src, 10)
	to_chat(user, span_notice("Вы наполняете шарик из [target.declent_ru(GENITIVE)]."))
	desc = "Полупрозрачный воздушный шарик, внутри которого плещется какая-то жидкость."
	update_icon(UPDATE_ICON_STATE)

/obj/item/toy/waterballoon/attackby(obj/item/item, mob/user, params)
	if(!isglassreagentcontainer(item) && !istype(item, /obj/item/reagent_containers/food/drinks/drinkingglass))
		return ..()

	add_fingerprint(user)

	if(!item.reagents || item.reagents.total_volume < 1)
		to_chat(user, span_warning("[DECLENT_RU_CAP(item, NOMINATIVE)] пуст!"))
		return ATTACK_CHAIN_PROCEED

	if(item.reagents.has_reagent(/datum/reagent/acid/facid, 1) || item.reagents.has_reagent(/datum/reagent/acid, 1))
		to_chat(user, span_warning("Кислота прожигает шарик!"))
		item.reagents.reaction(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	desc = "Полупрозрачный воздушный шарик, внутри которого плещется какая-то жидкость."
	to_chat(user, span_notice("Вы наполняете шарик из [item.declent_ru(GENITIVE)]."))
	item.reagents.trans_to(src, 10)
	update_icon(UPDATE_ICON_STATE)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/toy/waterballoon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		balloon_burst(hit_atom)

/obj/item/toy/waterballoon/proc/balloon_burst(atom/hit_atom)
	if(reagents.total_volume < 1)
		return

	visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] лопается!"),
		"Вы слышите хлопок и всплеск."
	)
	reagents.reaction(get_turf(hit_atom))
	for(var/atom/A in get_turf(hit_atom))
		reagents.reaction(A)
	icon_state = "burst"
	addtimer(CALLBACK(src, PROC_REF(delete_balloon)), 0.5 SECONDS)

/obj/item/toy/waterballoon/proc/delete_balloon()
	if(src)
		qdel(src)

/obj/item/toy/waterballoon/update_icon_state()
	if(reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "waterballoon"
	else
		icon_state = "balloon_red-e"
		item_state = "waterballoon-e"
	return ..()

#define BALLOON_COLORS list("red", "blue", "green", "yellow", "orange", "purple")

/obj/item/toy/balloon
	name = "balloon"
	desc = "Праздничный шарик. Использованные блюспейс технологии позволили ему парить при любых условиях."
	icon = 'icons/obj/toys/balloons.dmi'
	icon_state = "balloon"
	item_state = "balloon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	var/random_color = TRUE
	/// the string describing the name of balloon's current colour.
	var/current_color

/obj/item/toy/balloon/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик",
		GENITIVE = "воздушного шарика",
		DATIVE = "воздушному шарику",
		ACCUSATIVE = "воздушный шарик",
		INSTRUMENTAL = "воздушным шариком",
		PREPOSITIONAL = "воздушном шарике",
	)

/obj/item/toy/balloon/long
	name = "long balloon"
	desc = "Воздушный шарик, идеальный для скручивания в различные формы. Использованные блюспейс технологии позволили ему парить при любых условиях."
	icon_state = "balloon_long"
	w_class = WEIGHT_CLASS_NORMAL
	/// Combinations of balloon colours to make specific animals.
	var/static/list/balloon_combos = list(
		list("red", "blue") = /obj/item/toy/balloon_animal/guy,
		list("red", "green") = /obj/item/toy/balloon_animal/nukie,
		list("red", "yellow") = /obj/item/toy/balloon_animal/clown,
		list("red", "orange") = /obj/item/toy/balloon_animal/cat,
		list("red", "purple") = /obj/item/toy/balloon_animal/fly,
		list("blue", "green") = /obj/item/toy/balloon_animal/podguy,
		list("blue", "yellow") = /obj/item/toy/balloon_animal/ai,
		list("blue", "orange") = /obj/item/toy/balloon_animal/dog,
		list("blue", "purple") = /obj/item/toy/balloon_animal/xeno,
		list("green", "yellow") = /obj/item/toy/balloon_animal/banana,
		list("green", "orange") = /obj/item/toy/balloon_animal/lizard,
		list("green", "purple") = /obj/item/toy/balloon_animal/slime,
		list("yellow", "orange") = /obj/item/toy/balloon_animal/moth,
		list("yellow", "purple") = /obj/item/toy/balloon_animal/lamp, // tg shit, change later
		list("orange", "purple") = /obj/item/toy/balloon_animal/plasmaman,
	)

/obj/item/toy/balloon/long/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!istype(attacking_item, /obj/item/toy/balloon/long))
		return ..()

	var/obj/item/toy/balloon/long/hit_by = attacking_item

	if(hit_by.current_color == current_color)
		balloon_alert(user, "нужен другой цвет!")
		return ATTACK_CHAIN_BLOCKED

	visible_message(
		span_notice("[user.name] начинает скручивать шарики вместе!"),
		blind_message = span_hear("Вы слышите как кто-то скручивает шарики вместе."),
		vision_distance = 3,
		ignored_mobs = user,
	)

	for(var/list/pair_of_colors in balloon_combos)
		if((hit_by.current_color == pair_of_colors[1] && current_color == pair_of_colors[2]) || (current_color == pair_of_colors[1] && hit_by.current_color == pair_of_colors[2]))
			var/path_to_spawn = balloon_combos[pair_of_colors]
			user.put_in_hands(new path_to_spawn)
			break
	qdel(hit_by)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/balloon/attackby(obj/item/attack_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attack_item, /obj/projectile/bullet/reusable/foam_dart) && ismonkey(user))
		pop_balloon(monkey_pop = TRUE)
	else
		return ..()

/obj/item/toy/balloon/hitby(atom/movable/hit_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	var/mob/thrower = throwingdatum?.thrower
	if(ismonkey(thrower) && istype(hit_atom, /obj/projectile/bullet/reusable/foam_dart))
		pop_balloon(monkey_pop = TRUE)
	else
		return ..()

/obj/item/toy/balloon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	var/mob/thrower = throwingdatum?.thrower
	if(ismonkey(thrower) && istype(AM, /obj/projectile/bullet/reusable/foam_dart))
		pop_balloon(monkey_pop = TRUE)
	else
		return ..()

/obj/item/toy/balloon/bullet_act(obj/projectile/proj)
	if((istype(proj, /obj/projectile/bullet/sniper) || istype(proj, /obj/projectile/bullet/reusable/foam_dart)) && ismonkey(proj.firer))
		pop_balloon(monkey_pop = TRUE)
	return ..()

/obj/item/toy/balloon/proc/pop_balloon(monkey_pop = FALSE)
	playsound(src, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 50, vary = TRUE)
	if(monkey_pop) // Monkeys make money from popping bloons
		new /obj/item/coin/iron(get_turf(src))
	qdel(src)

/obj/item/toy/balloon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	if(!random_color)
		return
	current_color = pick(BALLOON_COLORS)
	update_appearance()

/obj/item/toy/balloon/update_name(updates)
	. = ..()
	name = "[current_color ? "[current_color] ":null][initial(name)]"

/obj/item/toy/balloon/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, current_color))
		update_appearance()

/obj/item/toy/balloon/update_icon_state()
	. = ..()
	var/new_icon = "[initial(icon_state)][current_color ? "_[current_color]":null]"
	item_state = new_icon
	icon_state = "[new_icon][isturf(loc) ? null : "_storage"]"

/obj/item/toy/balloon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	update_appearance()

/obj/item/toy/balloon/corgi
	name = "corgi balloon"
	desc = "Воздушный шарик в форме головы корги. Для хороших мальчиков круглый год."
	icon_state = "corgi"
	item_state = "corgi"
	random_color = FALSE

/obj/item/toy/balloon/corgi/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик-корги",
		GENITIVE = "воздушного шарика-корги",
		DATIVE = "воздушному шарику-корги",
		ACCUSATIVE = "воздушный шарик-корги",
		INSTRUMENTAL = "воздушным шариком-корги",
		PREPOSITIONAL = "воздушном шарике-корги",
	)

/obj/item/toy/balloon/heart
	name = "heart balloon"
	desc = "Воздушный шарик в форме сердца. Как мило!"
	icon_state = "heart"
	item_state = "heart"
	random_color = FALSE

/obj/item/toy/balloon/heart/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик-сердце",
		GENITIVE = "воздушного шарика-сердца",
		DATIVE = "воздушному шарику-сердцу",
		ACCUSATIVE = "воздушный шарик-сердце",
		INSTRUMENTAL = "воздушным шариком-сердцем",
		PREPOSITIONAL = "воздушном шарике-сердце",
	)

/obj/item/toy/balloon/syndicate
	name = "syndicate balloon"
	desc = "Этикетка на задней стороне гласит: \"Смерть НТ!11!\"."
	icon_state = "syndballoon"
	item_state = "syndballoon"
	random_color = FALSE

/obj/item/toy/balloon/syndicate/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик синдиката",
		GENITIVE = "воздушного шарика синдиката",
		DATIVE = "воздушному шарику синдиката",
		ACCUSATIVE = "воздушный шарик синдиката",
		INSTRUMENTAL = "воздушным шариком синдиката",
		PREPOSITIONAL = "воздушном шарике синдиката",
	)

/obj/item/toy/balloon/contractor
	name = "contractor balloon"
	desc = "Черно-золотой шар, который носят только легендарные агенты \"Синдиката\"."
	gender = MALE
	icon_state = "contractorballoon"
	item_state = "contractorballoon"
	random_color = FALSE

/obj/item/toy/balloon/contractor/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик контрактника",
		GENITIVE = "воздушного шарика контрактника",
		DATIVE = "воздушному шарику контрактника",
		ACCUSATIVE = "воздушный шарик контрактника",
		INSTRUMENTAL = "воздушным шариком контрактника",
		PREPOSITIONAL = "воздушном шарике контрактника",
	)

/obj/item/toy/balloon/arrest
	name = "arreyst balloon"
	desc = "Полунадутый воздушный шар с изображением бойз-бэнда \"Арестанты\", популярного около десяти лет назад и прославившегося тем, что высмеивал красные комбинезоны как немодные."
	icon_state = "arrestballoon"
	item_state = "arrestballoon"
	random_color = FALSE

/obj/item/toy/balloon/arrest/get_ru_names()
	return alist(
		NOMINATIVE = "воздушный шарик \"В розыске\"",
		GENITIVE = "воздушного шарика \"В розыске\"",
		DATIVE = "воздушному шарику \"В розыске\"",
		ACCUSATIVE = "воздушный шарик \"В розыске\"",
		INSTRUMENTAL = "воздушным шариком \"В розыске\"",
		PREPOSITIONAL = "воздушном шарике \"В розыске\"",
	)

#undef BALLOON_COLORS

// MARK: Balloon animals
/obj/item/toy/balloon_animal
	abstract_type = /obj/item/toy/balloon_animal
	name = "balloon animal"
	desc = "You shouldn't have this."
	icon = 'icons/obj/toys/balloons.dmi'
	item_state = "balloon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'

/obj/item/toy/balloon_animal/guy
	name = "balloon guy"
	desc = "Фигурка из воздушных шариков, изображающая обычного парня. Интересно, платит ли он налоги на воздушные шары? Вероятно, уклоняется от них."
	icon_state = "balloon_guy"

/obj/item/toy/balloon_animal/nukie
	name = "balloon nukie"
	desc = "Фигурка из воздушных шариков, изображающая ядерного оперативника \"Синдиката\". Возможно, она сделана чтобы умиротворить их и попросить о пощаде, ну, или подшутить над ними."
	icon_state = "balloon_nukie"

/obj/item/toy/balloon_animal/clown
	name = "balloon clown"
	desc = "Клоун из воздушных шариков, улыбающийся во весь рот."
	icon_state = "balloon_clown"

/obj/item/toy/balloon_animal/cat
	name = "balloon cat"
	desc = "Фигурка из воздушных шариков, изображающая кошку. Возможно она милее своих живых собратьев, но не располагает добротой и не такая пушистая."
	icon_state = "balloon_cat"

/obj/item/toy/balloon_animal/fly
	name = "balloon fly"
	desc = "Фигурка из воздушных шариков в форме мухи, жужжание не входит в комплект."
	icon_state = "balloon_fly"

/obj/item/toy/balloon_animal/podguy
	name = "balloon podguy"
	desc = "Фигурка из воздушных шариков, изображающая человека-растение, отдаленно напоминающего диону."
	icon_state = "balloon_podguy"

/obj/item/toy/balloon_animal/ai
	name = "balloon ai core"
	desc = "Несколько нереалистичное изображение ядра искусственного интеллекта станции, сделанное из воздушных шариков. Настоящий ИИ, вероятно, так бы не улыбался."
	icon_state = "balloon_ai"

/obj/item/toy/balloon_animal/dog
	name = "balloon dog"
	desc = "Фигурка из воздушных шариков, изображающая хорошего мальчика. Конечно, она не может сравниться с оригиналом, но попытка хорошая."
	icon_state = "balloon_dog"

/obj/item/toy/balloon_animal/xeno
	name = "balloon xeno"
	desc = "Фигурка жуткого ксеноморфа из воздушных шариков! Слишком мягкая, чтобы напугать кого-либо сама по себе!"
	icon_state = "balloon_xeno"

/obj/item/toy/balloon_animal/banana
	name = "balloon banana"
	desc = "Банан из воздушных шариков, на нём не подскользнуться. Зато он хорошо подходит для психологической войны."
	icon_state = "balloon_banana"

/obj/item/toy/balloon_animal/lizard
	name = "balloon lizard"
	desc = "Фигурка из воздушных шариков, изображающая ящерку. Один из первых видов, адаптировавшихся к культуре планеты клоунов. Возможно, потому что они от природы смешные?"
	icon_state = "balloon_lizard"

/obj/item/toy/balloon_animal/slime
	name = "balloon slime"
	desc = "Фигурка из воздушных шариков, изображающая единственного представителя слаймов в галактике, фиолетового цвета. Однажды слаймы пытались вторгнуться на планету клоунов, однако их быстро смыло плюющимися водой цветами."
	icon_state = "balloon_slime"

/obj/item/toy/balloon_animal/moth
	name = "balloon moth"
	desc = "Фигурка из воздушных шариков, изображающая распространенного представителя расы Ниан. Очень немногие из них решают поселиться на планете клоунов, но те, кто это делает, демонстрируют лучшие трюки с \"исчезновением трусов\"."
	icon_state = "balloon_moth"

/obj/item/toy/balloon_animal/lamp
	name = "balloon lamp"
	desc = "Фигурка лампочки, выполненная из воздушных шариков. Отдаленно напоминает эфириальную сущность с других планов бытия, но на самом деле это просто лампочка."
	icon_state = "balloon_lamp"

/obj/item/toy/balloon_animal/plasmaman
	name = "balloon plasmaman"
	desc = "Фигурка плазмамена, выполненная из воздушных шариков. Самый редкий представитель на планете клоунов, они появились совсем недавно благодаря активной торговле между клоунами и НТ."
	icon_state = "balloon_plasmaman"
