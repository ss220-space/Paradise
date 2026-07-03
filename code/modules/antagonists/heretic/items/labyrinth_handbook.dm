/obj/effect/forcefield/wizard/heretic
	name = "страницы карты лабиринта"
	desc = "Множество листов бумаги летающих в воздухе, отпугивающих язычников с невероятной силой."
	gender = PLURAL
	// The base /obj/effect/forcefield inherits effects.dmi from /obj/effect, which has no "lintel" frame,
	// so without this override the barrier renders completely invisible.
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "lintel"
	lifetime = 15 SECONDS


/obj/effect/forcefield/wizard/heretic/get_ru_names()
	return alist(
		NOMINATIVE = "страницы карты лабиринта",
		GENITIVE = "страниц карты лабиринта",
		DATIVE = "страницам карты лабиринта",
		ACCUSATIVE = "страницы карты лабиринта",
		INSTRUMENTAL = "страницами карты лабиринта",
		PREPOSITIONAL = "страницах карты лабиринта",
	)


/obj/effect/forcefield/wizard/heretic/Destroy(force)
	for(var/i = 0; i < rand(5, 9); i++)
		var/atom/paper = new /obj/item/paper(get_turf(src))
		paper.fire_act()

	. = ..()


/obj/effect/forcefield/wizard/heretic/Bumped(mob/living/bumpee)
	. = ..()
	if(!istype(bumpee) || IS_HERETIC_OR_MONSTER(bumpee))
		return

	var/throwtarget = get_edge_target_turf(loc, get_dir(loc, get_step_away(bumpee, loc)))
	bumpee.throw_at(throwtarget, 10, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
	visible_message(span_danger("[declent_ru(NOMINATIVE)] отталкивают [bumpee.declent_ru(ACCUSATIVE)] окружая бумажным штормом!"))


///A heretic item that spawns a barrier at the clicked turf, 3 uses
/obj/item/heretic_labyrinth_handbook
	name = "справочник по лабиринту"
	desc = "Книга, содержащая законы и правила Лабиринта. Её страницы извиваются и дёргаются, пытаясь вырваться наружу."
	gender = MALE
	icon = 'icons/obj/library.dmi'
	icon_state = "heretichandbook"
	force = 10
	damtype = BURN
	item_state = "book"
	throw_speed = 1
	throw_range = 5
	//attack_verb_continuous = list("bashes", "curses")
	attack_verb = list("бьёт", "проклинает")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/drop/book_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/book_pickup.ogg'
	///what type of barrier do we spawn when used
	var/barrier_type = /obj/effect/forcefield/wizard/heretic
	/// Current charges remaining
	var/charges = 5
	/// Max possible amount of charges
	var/max_charges = 5
	/// List that contains each running recharge timer
	var/list/charge_timers = list()
	/// How long before a spent charge is restored
	var/charge_time = 15 SECONDS


/obj/item/heretic_labyrinth_handbook/get_ru_names()
	return alist(
		NOMINATIVE = "справочник по лабиринту",
		GENITIVE = "справочника по лабиринту",
		DATIVE = "справочнику по лабиринту",
		ACCUSATIVE = "справочник по лабиринту",
		INSTRUMENTAL = "справочником по лабиринту",
		PREPOSITIONAL = "справочнике по лабиринту",
	)


/obj/item/heretic_labyrinth_handbook/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	. += span_purple("Создаёт барьер на любой плитке в поле зрения, через который можете пройти только вы. Действует 15 секунд.")
	. += span_purple("Осталось <b>[charges]</b> [charges == 1 ? "заряд" : "зарядов"]. Заряды восстанавливаются со временем.")


/obj/item/heretic_labyrinth_handbook/afterattack(atom/interacting_with, mob/user, proximity, params, status)
	. = ..()
	if(!isheretic(user))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			to_chat(human_user, span_userdanger("Ваш разум горит, когда вы начинаете читать книгу, \
													головная боль нарастает, будто ваш мозг охвачен пламенем!"))
			human_user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 30, 190)
			human_user.drop_item_ground(src)

		return ATTACK_CHAIN_BLOCKED

	if(charges <= 0)
		user.balloon_alert(user, "нет зарядов!")
		return ATTACK_CHAIN_BLOCKED

	var/turf/turf_target = get_turf(interacting_with)
	if(locate(barrier_type) in turf_target)
		user.balloon_alert(user, "барьер уже есть!")
		return ATTACK_CHAIN_BLOCKED

	turf_target.visible_message(span_warning("Вихрь из страниц материализуется!"))
	new /obj/effect/temp_visual/paper_scatter(turf_target)
	playsound(turf_target, 'sound/magic/smoke.ogg', 30)
	new barrier_type(turf_target, user)
	charges--
	// The handbook is never consumed - each spent charge regenerates on its own timer.
	charge_timers += addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_STOPPABLE)
	return ATTACK_CHAIN_SUCCESS


/obj/item/heretic_labyrinth_handbook/proc/recharge()
	charges = min(charges + 1, max_charges)


//fancy effects
/obj/effect/temp_visual/paper_scatter
	name = "клочки бумаги"
	desc = "Кусочки бумаги, разлетающиеся по ветру."
	layer = ABOVE_NORMAL_TURF_LAYER
	icon_state = "paper_scatter"
	duration = 0.5 SECONDS
	randomdir = FALSE
