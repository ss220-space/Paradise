// ---------- ACTIONS FOR ALL SPIDERS
/datum/action/innate/terrorspider
	background_icon_state = "bg_terror"

/datum/action/innate/terrorspider/web
	name = "Паутина"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "stickyweb1"

/datum/action/innate/terrorspider/web/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.Web()

/datum/action/innate/terrorspider/wrap
	name = "Завернуть"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "cocoon_large1"

/datum/action/innate/terrorspider/wrap/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.FindWrapTarget()
	user.DoWrap()

// ---------- GREEN ACTIONS

/datum/action/innate/terrorspider/greeneggs
	name = "Отложить зелёные яйца"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/terrorspider/greeneggs/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/healer/user = owner
	user.DoLayGreenEggs()

// ---------- KNIGHT ACTIONS
/datum/action/innate/terrorspider/knight/defaultm
	name = "Default"
	button_icon = 'icons/mob/terrorspider.dmi'
	button_icon_state = "terror_princess1"

/datum/action/innate/terrorspider/knight/defaultm/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/knight/user = owner
	user.activate_mode(0)

/datum/action/innate/terrorspider/knight/attackm
	name = "Ярость"
	button_icon_state = "attack"

/datum/action/innate/terrorspider/knight/attackm/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/knight/user = owner
	user.activate_mode(1)

/datum/action/innate/terrorspider/knight/defencem
	name = "Кератоз"
	button_icon_state = "defence"

/datum/action/innate/terrorspider/knight/defencem/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/knight/user = owner
	user.activate_mode(2)

// ---------- BOSS ACTIONS

/datum/action/innate/terrorspider/ventsmash
	name = "Сломать вентиляцию"
	button_icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	button_icon_state = "map_vent"

/datum/action/innate/terrorspider/ventsmash/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.DoVentSmash()

/datum/action/innate/terrorspider/remoteview
	name = "Удалённое зрение"
	button_icon = 'icons/obj/eyes.dmi'
	button_icon_state = "heye"

/datum/action/innate/terrorspider/remoteview/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/user = owner
	user.DoRemoteView()

// ---------- QUEEN ACTIONS

/datum/action/innate/terrorspider/queen/queennest
	name = "Гнездо"
	button_icon = 'icons/mob/terrorspider.dmi'
	button_icon_state = "terror_queen"

/datum/action/innate/terrorspider/queen/queennest/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.NestPrompt()

/datum/action/innate/terrorspider/queen/queensense
	name = "Чувство улья"
	button_icon_state = "mindswap"

/datum/action/innate/terrorspider/queen/queensense/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.DoHiveSense()

/datum/action/innate/terrorspider/queen/queeneggs
	name = "Отложить королевские яйца"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "eggs"

/datum/action/innate/terrorspider/queen/queeneggs/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/user = owner
	user.LayQueenEggs()

// ---------- EMPRESS

/datum/action/innate/terrorspider/queen/empress/empresserase
	name = "Уничтожить выводок"
	button_icon = 'icons/effects/blood.dmi'
	button_icon_state = "mgibbl1"

/datum/action/innate/terrorspider/queen/empress/empresserase/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/user = owner
	user.EraseBrood()

/datum/action/innate/terrorspider/queen/empress/empresslings
	name = "Паучки императрицы"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "spiderling"

/datum/action/innate/terrorspider/queen/empress/empresslings/Activate()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/user = owner
	user.EmpressLings()

// ---------- WEB

/mob/living/simple_animal/hostile/poison/terror_spider/proc/Web()
	if(!web_type)
		return
	if(!isturf(loc))
		to_chat(src, span_danger("Паутину можно плести только стоя на полу."))
		return
	var/turf/mylocation = loc
	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает выделять липкое вещество."))
	playsound(src.loc, 'sound/creatures/terrorspiders/web.ogg', 50, TRUE)
	if(do_after(src, delay_web, loc))
		if(loc != mylocation)
			return
		else if(isspaceturf(loc))
			to_chat(src, span_danger("Паутину невозможно плести в космосе."))
		else
			var/obj/structure/spider/terrorweb/terrorweb = locate() in get_turf(src)
			if(terrorweb)
				to_chat(src, span_danger("Здесь уже есть паутина."))
			else
				var/obj/structure/spider/terrorweb/terrorweb_new = new web_type(loc)
				terrorweb_new.creator_ckey = ckey

/obj/structure/spider/terrorweb
	name = "terror web"
	desc = "Вязкая и липкая паутина."
	max_integrity = 20 // two welders, or one laser shot (15 for the normal spider webs)
	creates_cover = TRUE
	icon_state = "stickyweb1"
	var/creator_ckey = null

/obj/structure/spider/terrorweb/get_ru_names()
	return alist(
		NOMINATIVE = "паутина Ужаса",
		GENITIVE = "паутины Ужаса",
		DATIVE = "паутине Ужаса",
		ACCUSATIVE = "паутину Ужаса",
		INSTRUMENTAL = "паутиной Ужаса",
		PREPOSITIONAL = "паутине Ужаса",
	)

/obj/structure/spider/terrorweb/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "stickyweb2"

/obj/structure/spider/terrorweb/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(checkpass(mover))
		return TRUE

	if(istype(mover, /mob/living/simple_animal/hostile/poison/giant_spider) || isterrorspider(mover))
		return TRUE

	if(istype(mover, /obj/projectile/terrorspider))
		return TRUE

	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.body_position == LYING_DOWN)
			return TRUE

		if(prob(80))
			to_chat(mover, span_danger("Вы на мгновение застреваете в [declent_ru(PREPOSITIONAL)]."))
			living_mover.Weaken(2 SECONDS) // 2 seconds, wow
			living_mover.Slowed(10 SECONDS)
			if(iscarbon(mover))
				web_special_ability(mover)
			return TRUE

		return FALSE

	if(isprojectile(mover))
		return prob(20)

/obj/structure/spider/terrorweb/bullet_act(obj/projectile/Proj)
	if(Proj.damage_type != BRUTE && Proj.damage_type != BURN)
		visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] невосприимчива к [Proj.declent_ru(DATIVE)]!"), projectile_message = TRUE)
		// Webs don't care about disablers, tasers, etc. Or toxin damage. They're organic, but not alive.
		return
	..()

/obj/structure/spider/terrorweb/proc/web_special_ability(mob/living/carbon/C)
	return

// ---------- WRAP

/mob/living/simple_animal/hostile/poison/terror_spider/proc/mobIsWrappable(mob/living/M)
	if(!istype(M))
		return FALSE
	if(M.stat != DEAD)
		return FALSE
	if(M.anchored)
		return FALSE
	if(!Adjacent(M))
		return FALSE
	if(isterrorspider(M))
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/proc/FindWrapTarget()
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/living in oview(1,src))
			if(!mobIsWrappable(living))
				continue
			choices += living
		for(var/obj/obj in oview(1,src))
			if(Adjacent(obj) && !obj.anchored)
				if(!istype(obj, /obj/structure/spider))
					choices += obj
		if(length(choices))
			cocoon_target = tgui_input_list(src, "Что вы хотите замотать в кокон?", "", choices)
		else
			to_chat(src, span_danger("Рядом нет ничего, что можно было бы завернуть в кокон."))

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoWrap()
	if(cocoon_target && busy != SPINNING_COCOON)
		if(cocoon_target.anchored)
			cocoon_target = null
			return
		busy = SPINNING_COCOON
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает выделять липкое вещество вокруг [cocoon_target.declent_ru(GENITIVE)]."))
		playsound(src.loc, 'sound/creatures/terrorspiders/wrap.ogg', 120, TRUE)
		stop_automated_movement = 1
		GLOB.move_manager.stop_looping(src)
		if(do_after(src, 4 SECONDS, cocoon_target.loc))
			if(busy == SPINNING_COCOON)
				if(cocoon_target && isturf(cocoon_target.loc) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/cocoon = new(cocoon_target.loc)
					var/large_cocoon = 0
					cocoon.pixel_x = cocoon_target.pixel_x
					cocoon.pixel_y = cocoon_target.pixel_y
					for(var/obj/obj in cocoon.loc)
						if(!obj.anchored)
							if(isitem(obj))
								obj.loc = cocoon
							else if(ismachinery(obj))
								obj.loc = cocoon
								large_cocoon = 1
							else if(isstructure(obj) && !istype(obj, /obj/structure/spider)) // can't wrap spiderlings/etc
								obj.loc = cocoon
								large_cocoon = 1
					for(var/mob/living/living in cocoon.loc)
						if(!mobIsWrappable(living))
							continue
						if(iscarbon(living))
							apply_status_effect(STATUS_EFFECT_TERROR_FOOD_REGEN)
							fed++
							visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] втыкает хоботок в [living.declent_ru(ACCUSATIVE)] и высасывает вязкое вещество."))
							to_chat(src, span_notice("Вы начинаете быстро восстанавливаться!"))
							if(living.mind && ishuman(living))
								SEND_SIGNAL(mind, COMSIG_HUMAN_EATEN)
						else
							visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] заматывает [living.declent_ru(ACCUSATIVE)] в паутину."))
						large_cocoon = 1
						last_cocoon_object = 0
						living.forceMove(cocoon)
						cocoon.pixel_x = living.pixel_x
						cocoon.pixel_y = living.pixel_y
						break
					if(large_cocoon)
						cocoon.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		cocoon_target = null
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoVentSmash()
	var/valid_target = FALSE
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent_pump in range(1, get_turf(src)))
		if(vent_pump.welded)
			valid_target = TRUE
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/vent_scrubber in range(1, get_turf(src)))
		if(vent_scrubber.welded)
			valid_target = TRUE
	if(!valid_target)
		to_chat(src, span_warning("Рядом нет заваренного вентиляционного отверстия или скраббера!"))
		return
	playsound(get_turf(src), 'sound/creatures/terrorspiders/ventbreak.ogg', 75, FALSE)
	if(do_after(src, 4.3 SECONDS, loc))
		for(var/obj/machinery/atmospherics/unary/vent_pump/vent_pump in range(1, get_turf(src)))
			if(vent_pump.welded)
				vent_pump.set_welded(FALSE)
				forceMove(vent_pump.loc)
				vent_pump.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] выбивает приваренную крышку [vent_pump.declent_ru(GENITIVE)]!"))
				return
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/vent_scrubber in range(1, get_turf(src)))
			if(vent_scrubber.welded)
				vent_scrubber.set_welded(FALSE)
				forceMove(vent_scrubber.loc)
				vent_scrubber.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] выбивает приваренную крышку [vent_scrubber.declent_ru(GENITIVE)]!"))
				return
		to_chat(src, span_danger("Поблизости нет заваренного вентиляционного отверстия или скраббера."))

