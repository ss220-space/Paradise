// Fish flopping

#define PAUSE_BETWEEN_PHASES 15
#define PAUSE_BETWEEN_FLOPS 2
#define FLOP_COUNT 2
#define FLOP_DEGREE 20
#define FLOP_SINGLE_MOVE_TIME 1.5
#define JUMP_X_DISTANCE 5
#define JUMP_Y_DISTANCE 6
/// This animation should be applied to actual parent atom instead of vc_object.
/proc/flop_animation(atom/movable/animation_target)
	var/pause_between = PAUSE_BETWEEN_PHASES + rand(1, 5) //randomized a bit so fish are not in sync
	animate(animation_target, time = pause_between, loop = -1)
	//move nose down and up
	for(var/_ in 1 to FLOP_COUNT)
		var/matrix/up_matrix = matrix()
		up_matrix.Turn(FLOP_DEGREE)
		var/matrix/down_matrix = matrix()
		down_matrix.Turn(-FLOP_DEGREE)
		animate(transform = down_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = up_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = matrix(), time = FLOP_SINGLE_MOVE_TIME, loop = -1, easing = BOUNCE_EASING | EASE_IN)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
	//bounce up and down
	animate(time = pause_between, loop = -1, flags = ANIMATION_PARALLEL)
	var/jumping_right = FALSE
	var/up_time = 3 * FLOP_SINGLE_MOVE_TIME / 2
	for(var/_ in 1 to FLOP_COUNT)
		jumping_right = !jumping_right
		var/x_step = jumping_right ? JUMP_X_DISTANCE/2 : -JUMP_X_DISTANCE/2
		animate(time = up_time, pixel_y = JUMP_Y_DISTANCE , pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_IN)
		animate(time = up_time, pixel_y = -JUMP_Y_DISTANCE, pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_OUT)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
#undef PAUSE_BETWEEN_PHASES
#undef PAUSE_BETWEEN_FLOPS
#undef FLOP_COUNT
#undef FLOP_DEGREE
#undef FLOP_SINGLE_MOVE_TIME
#undef JUMP_X_DISTANCE
#undef JUMP_Y_DISTANCE

// actual fish

GLOBAL_LIST_INIT(deep_fish, subtypesof(/obj/item/lavaland_fish/deep_water))

GLOBAL_LIST_INIT(shore_fish, subtypesof(/obj/item/lavaland_fish/shoreline))

/obj/item/lavaland_fish
	name = "generic lavaland fish"
	desc = "Вау, она такая... невпечатляющая!"
	ru_names = list(
		NOMINATIVE = "рыба",
		GENITIVE = "рыбы",
		DATIVE = "рыбе",
		ACCUSATIVE = "рыбу",
		INSTRUMENTAL = "рыбой",
		PREPOSITIONAL = "рыбе",
	)
	gender = MALE
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "ash_crab"

	lefthand_file = 'icons/mob/inhands/lavaland/fish_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_righthand.dmi'
	item_state = "ash_crab"

	resistance_flags = LAVA_PROOF | FIRE_PROOF
	throwforce = 5
	force = 10
	attack_verb = list("охлестал", "ударил", "стукнул", "опозорил")
	hitsound = 'sound/weapons/bite.ogg'

	/// If this fish should do the flopping animation
	var/do_flop_animation = TRUE
	var/flopping = FALSE

	/// Favourite bait. Using this will add more chance to catch this fish
	var/favorite_bait = null

	/// List of items you get after butchering it
	var/list/butcher_loot = list()

/obj/item/lavaland_fish/shoreline // all this subtypes used in actual fishing
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/lavaland_fish/deep_water
	w_class = WEIGHT_CLASS_BULKY

/obj/item/lavaland_fish/Initialize(mapload)
	. = ..()
	if(do_flop_animation)
		RegisterSignal(src, COMSIG_ATOM_TEMPORARY_ANIMATION_START, PROC_REF(on_temp_animation))
	START_PROCESSING(SSobj, src)

/obj/item/lavaland_fish/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/lavaland_fish/proc/fucking_dies()
	do_flop_animation = FALSE
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(src, COMSIG_ATOM_TEMPORARY_ANIMATION_START)
	stop_flopping()

/obj/item/lavaland_fish/attackby(obj/item/I, mob/living/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	var/sharpness = is_sharp(I)
	if(sharpness && user.a_intent == INTENT_HELP && do_flop_animation)
		fucking_dies()
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] больше не двигается.."))
	if(sharpness && user.a_intent == INTENT_HARM)
		to_chat(user, span_notice("Вы начинаете разделывать [declent_ru(ACCUSATIVE)]..."))
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		if(do_after(user, I.has_speed_harvest ? 1 SECONDS : 6 SECONDS, src,) && Adjacent(I))
			check_special_harvest()
			harvest(user)
	return ..()

/obj/item/lavaland_fish/proc/harvest(mob/user)
	if(QDELETED(src))
		return
	for(var/path in butcher_loot)
		for(var/i in 1 to butcher_loot[path])
			new path(loc)
		butcher_loot.Remove(path)
	visible_message(span_notice("[user] успешно разделыва[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."))
	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	gibs(loc)
	qdel(src)

/// Starts flopping animation
/obj/item/lavaland_fish/proc/start_flopping()
	if(flopping)  //Requires update_transform/animate_wrappers to be less restrictive.
		return
	flopping = TRUE
	flop_animation(src)

/// Stops flopping animation
/obj/item/lavaland_fish/proc/stop_flopping()
	if(flopping)
		flopping = FALSE
		animate(src, transform = matrix()) //stop animation

/// Refreshes flopping animation after temporary animation finishes
/obj/item/lavaland_fish/proc/on_temp_animation(datum/source, animation_duration)
	if(animation_duration > 0)
		addtimer(CALLBACK(src, PROC_REF(refresh_flopping)), animation_duration)

/obj/item/lavaland_fish/proc/refresh_flopping()
	if(flopping)
		flop_animation(src)

/obj/item/lavaland_fish/proc/check_special_harvest()
	return

/obj/item/lavaland_fish/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(do_flop_animation)
		start_flopping()

/obj/item/lavaland_fish/shoreline/ash_crab
	name = "ash crab"
	desc = "Небольшое всеядное ракообразное, обладающее на удивление крепким панцирем. Данный вид имеет интересную привычку поедать мелкие предметы, которые они находят. Лавовые крабы наиболее часто являются объектом охоты как для другой \"морской\" фауны, так и для местных племён в связи с крепким панцирем, используемым в качестве заточки, съедобным мясом и интересными находками в его желудке."
	ru_names = list(
		NOMINATIVE = "пепельный рак",
		GENITIVE = "пепельного рака",
		DATIVE = "пепельному раку",
		ACCUSATIVE = "пепельного рака",
		INSTRUMENTAL = "пепельным раком",
		PREPOSITIONAL = "пепельном раке",
	)
	icon_state = "ash_crab"
	item_state = "ash_crab"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater
	butcher_loot = list(
		/obj/item/whetstone/crab_shell = 1,
		/obj/item/reagent_containers/food/snacks/lavaland/soft_meat = 1,
		/obj/effect/spawner/random_spawners/lavaland_random_loot = 1,
		)

/obj/item/lavaland_fish/shoreline/dead_horseman
	name = "dead horseman"
	desc = "Небольших размеров рыба, питающаяся преимущественно кровавыми пиявками, зарытыми в пепле. Получила своё название из-за своего характерного внешнего вида - голова всадника внешне напоминает гуманоидный череп. Ценится местными племенами в первую очередь из-за селезёнки, содержащей в себе частицы киновари и используемой для создания коричневого красителя."
	ru_names = list(
		NOMINATIVE = "мёртвый всадник",
		GENITIVE = "мёртвого всадника",
		DATIVE = "мёртвому всаднику",
		ACCUSATIVE = "мёртвого всадника",
		INSTRUMENTAL = "мёртвым всадником",
		PREPOSITIONAL = "мёртвом всаднике",
	)
	icon_state = "dead_horseman"
	item_state = "dead_horseman"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach
	butcher_loot = list(
		/obj/effect/spawner/random_spawners/forty_pc_skull = 1,
		/obj/item/reagent_containers/food/snacks/lavaland/soft_meat = 1,
		/obj/item/lavaland_dye/cinnabar = 1,
		)

/obj/item/lavaland_fish/shoreline/shellfish
	name = "shellfish"
	desc = "Одна из самых больших рыб, встречающихся у берегов Лазис Ардакса. Практически всё её тело, включая голову, покрыто багряными хрящевыми пластинами, достаточно крепкими, чтобы защищаться от большинства хищников. Внутри самой рыбы, рядом с сердцем, находится специализированный орган, собираемый местными племенами для ведения сельского хозяйства."
	ru_names = list(
		NOMINATIVE = "лавовый панцирник", //there is actual fish - панцирник, so our little different
		GENITIVE = "лавового панцирника",
		DATIVE = "лавовому панцирнику",
		ACCUSATIVE = "лавового панцирника",
		INSTRUMENTAL = "лавовым панцирником",
		PREPOSITIONAL = "лавовом панцирнике",
	)
	icon_state = "shellfish"
	item_state = "shellfish"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	butcher_loot = list(
		/obj/item/stack/sheet/cartilage_plate = 2,
		/obj/item/conductive_organ = 1,
		/obj/item/lavaland_dye/crimson = 1,
		)

/obj/item/lavaland_fish/deep_water/bottom_eel
	name = "bottom eel"
	desc = "Эта длинная склизская рыба обитает на огромной глубине, питаясь преимущественно личинками и другой мелкой рыбой. Для защиты от других хищников, эта рыба имеет бритвенно-острый хвост, который местные племена приспосабливают в качестве наконечника для копья."
	ru_names = list(
		NOMINATIVE = "донный угорь",
		GENITIVE = "донного угря",
		DATIVE = "донному угрю",
		ACCUSATIVE = "донного угря",
		INSTRUMENTAL = "донным угрём",
		PREPOSITIONAL = "донном угре",
	)
	icon_state = "bottom_eel"
	item_state = "bottom_eel"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater
	butcher_loot = list(
		/obj/item/reagent_containers/food/snacks/lavaland/eel_filet = 1,
		/obj/item/kitchen/knife/combat/survival/bone/eel = 1,
		/obj/item/lavaland_dye/indigo = 1,
		)

/obj/item/lavaland_fish/deep_water/red_devourer
	name = "red devourer"
	desc = "Массивная рыба кроваво-красного окраса со множеством острых зубов внутри её пасти. Данная рыба печально известна среди племён своей агрессивностью, от чего погибло множество молодых охотников. В желудках этих рыб можно частенько найти останки менее удачливых рыбаков."
	ru_names = list(
		NOMINATIVE = "красный пожиратель",
		GENITIVE = "красного пожирателя",
		DATIVE = "красному пожирателю",
		ACCUSATIVE = "красного пожирателя",
		INSTRUMENTAL = "красным пожирателем",
		PREPOSITIONAL = "красном пожирателе",
	)
	icon_state = "red_devourer"
	item_state = "red_devourer"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach
	butcher_loot = list(
		/obj/item/stack/sheet/razor_sharp_teeth = 1,
		/obj/item/stack/sheet/bone = 1,
		/obj/item/reagent_containers/food/snacks/bait/random = 2,
		/obj/effect/spawner/random_spawners/lavaland_random_loot = 2,
		/obj/item/lavaland_dye/crimson = 1,
		)

/obj/item/lavaland_fish/deep_water/magma_hammerhead
	name = "magma hammerhead"
	desc = "Огромная глубоководная рыба тёмного окраса с характерной головой, отдалённо напоминающей молот. Несмотря на угрожающий внешний вид, данный тип рыб преимущественно охотится на мелких ракообразных, придавливая их своем \"молотом\" ко дну и раздавливая их панцирь. По краям их головы находятся странноватые сгустки, синергирующие с регенеративными ядрами."
	ru_names = list(
		NOMINATIVE = "магмовая акула-молот",
		GENITIVE = "магмовой акулы-молота",
		DATIVE = "магмовой акуле-молоту",
		ACCUSATIVE = "магмовую акулу-молот",
		INSTRUMENTAL = "магмовой акулой-молотом",
		PREPOSITIONAL = "магмовой акуле-молоте",
	)
	gender = FEMALE
	icon_state = "magma_hammerhead"
	item_state = "magma_hammerhead"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	butcher_loot = list(
		/obj/item/hivelordstabilizer/molten_mass = 2,
		/obj/item/lavaland_dye/cinnabar = 1,
		)

/obj/item/lavaland_fish/deep_water/blind_reaper
	name = "blind reaper"
	desc = "Самая маленькая представительница глубоководных рыб Лазис Ардакса, она привлекает к себе внимание не только небольшим размером, но и огромным костным наростом на голове, напоминающем лезвие циркулярной пилы. Данный вид, будучи лишённым зрения, использует своё лезвие в качестве биологического сонара, что помогает ей ориентироваться на огромных лавовых глубинах."
	ru_names = list(
		NOMINATIVE = "ослеплённый жнец",
		GENITIVE = "ослеплённого жнеца",
		DATIVE = "ослеплённому жнецу",
		ACCUSATIVE = "ослеплённого жнеца",
		INSTRUMENTAL = "ослеплённым жнецом",
		PREPOSITIONAL = "ослеплённом жнеце",
	)
	icon_state = "blind_reaper"
	item_state = "blind_reaper"
	throwforce = 20
	force = 10
	hitsound = 'sound/weapons/circsawhit.ogg'
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/ash_eater
	butcher_loot = list(
		/obj/item/circular_saw_blade = 1,
		/obj/item/reagent_containers/food/snacks/lavaland/predator_meat = 1,
		/obj/item/lavaland_dye/indigo = 1,
		)


/obj/item/lavaland_fish/deep_water/herald_of_carnage
	name = "herald of carnage"
	desc = "Эта массивная рыба, имеющая в своей пасти сотни бритвенно острых зубов, признана высшим хищником среди всего подводного мира Лазис Ардакса. Её массивные зелёные глаза используются в качестве украшения для самых прославленных охотников среди местных племён. В её желудке достаточно часто находят останки других рыб. И не только рыб."
	ru_names = list(
		NOMINATIVE = "вестник резни",
		GENITIVE = "вестника резни",
		DATIVE = "вестнику резни",
		ACCUSATIVE = "вестника резни",
		INSTRUMENTAL = "вестником резни",
		PREPOSITIONAL = "вестнике резни",
	)
	icon_state = "herald_of_carnage"
	item_state = "herald_of_carnage"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/bloody_leach
	butcher_loot = list(
		/obj/item/stack/sheet/razor_sharp_teeth = 2,
		/obj/item/stack/sheet/bone = 2,
		/obj/item/reagent_containers/food/snacks/lavaland/predator_meat = 1,
		/obj/effect/spawner/random_spawners/lavaland_random_loot = 3,
		/obj/item/lavaland_dye/mint = 1,
		)

/obj/item/lavaland_fish/deep_water/sulfuric_tramp
	name = "sulfuric tramp"
	desc = "Данный вид рыб никогда не был зафиксирован ни в одной исследовательской работе по изучению фауны Лазис Ардакса - это инвазивный вид, попавший в лавовые реки в результате крушения контрабандистского судна, перевозившего фауну с неизвестной кислотной планеты. Судя по всему, эти рыбы нашли свою нишу в пищевой цепи."
	ru_names = list(
		NOMINATIVE = "сернистый странник",
		GENITIVE = "сернистого странника",
		DATIVE = "сернистому страннику",
		ACCUSATIVE = "сернистого странника",
		INSTRUMENTAL = "сернистым странником",
		PREPOSITIONAL = "сернистом страннике",
	)
	icon_state = "sulfuric_tramp"
	item_state = "sulfuric_tramp"
	favorite_bait = /obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	butcher_loot = list(
		/obj/item/t_scanner/adv_mining_scanner/bleary_eye = 1,
		/obj/item/acid_bladder = 1,
		/obj/item/lavaland_dye/amber = 1,
		)

/obj/item/lavaland_fish/deep_water/sulfuric_tramp/check_special_harvest()
	var/location = get_turf(src)
	var/datum/reagents/reagents_list = new (500)
	reagents_list.add_reagent("sacid", 2450)

	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(reagents_list, location, TRUE)
	smoke.start(2)
