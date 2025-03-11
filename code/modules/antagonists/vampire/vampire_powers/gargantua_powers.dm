/obj/effect/proc_holder/spell/vampire/self/blood_swell
	name = "Кровавый вал"
	desc = "Вы наполняете своё тело кровью, что делает вас очень устойчивым к оглушению и физическому урону, но не даёт использовать оружие дальнего боя."
	gain_desc = "Вы получили способность временно повышать свою сопротивляемость урону и оглушению."
	base_cooldown = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"


/obj/effect/proc_holder/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)


/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "Пока действует «Кровавый вал», все ваши атаки в ближнем бою наносят повышенный урон."


/obj/effect/proc_holder/spell/vampire/self/stomp
	name = "Ударная волна"
	desc = "Вы бьёте ногой по земле, посылая мощную ударную волну, отчего окружающие разлетаются в разные стороны. Не может быть применено, если ваши ноги скованы или обездвижены."
	gain_desc = "Вы получили способность отбрасывать людей назад, используя мощный топот."
	action_icon_state = "seismic_stomp"
	base_cooldown = 30 SECONDS
	required_blood = 25
	var/max_range = 4


/obj/effect/proc_holder/spell/vampire/self/stomp/can_cast(mob/living/carbon/user, charge_check, show_message)
	if(iscarbon(user) && user.legcuffed)
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/stomp/cast(list/targets, mob/user)
	var/turf/T = get_turf(user)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, user), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)


/obj/effect/proc_holder/spell/vampire/self/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
	// gets the two outermost turfs in a ring, we get two so people cannot "walk over" the shockwave
	var/list/targets = view(range, start_turf) - view(range - 2, start_turf)
	for(var/turf/simulated/floor/flooring in targets)
		if(prob(100 - (range * 20)))
			flooring.ex_act(EXPLODE_LIGHT)

	for(var/mob/living/L in targets)
		if(L in safe_targets)
			continue

		if(L.throwing) // no double hits
			continue

		if(!L.affects_vampire(user))
			continue

		if(L.move_resist > MOVE_FORCE_VERY_STRONG)
			continue

		var/throw_target = get_edge_target_turf(L, get_dir(start_turf, L))
		INVOKE_ASYNC(L, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 3, 4)
		L.Weaken(2 SECONDS)
		safe_targets += L

	var/new_range = range + 1
	if(new_range <= max_range)
		addtimer(CALLBACK(src, PROC_REF(hit_check), new_range, start_turf, user, safe_targets), 0.2 SECONDS)


/obj/effect/temp_visual/stomp
	icon = 'icons/effects/seismic_stomp_effect.dmi'
	icon_state = "stomp_effect"
	duration = 0.8 SECONDS
	pixel_y = -16
	pixel_x = -16


/obj/effect/temp_visual/stomp/Initialize(mapload)
	. = ..()
	var/matrix/M = matrix() * 0.5
	transform = M
	animate(src, transform = M * 8, time = duration, alpha = 0)


/obj/effect/proc_holder/spell/vampire/self/overwhelming_force
	name = "Неудержимая сила"
	desc = "При активации вы будете выбивать все шлюзы, на которые наткнётесь, если у вас нет доступа, а также отражать все обездвиживающие предметы."
	gain_desc = "Вы получили способность выбивать двери и отражать обездвиживающие предметы за небольшую кровавую плату."
	base_cooldown = 2 SECONDS
	action_icon_state = "OH_YEAAAAH"


/obj/effect/proc_holder/spell/vampire/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user, span_userdanger("ВЫ ЧУВСТВУЕТЕ СЕБЯ СИЛЬНЕЕ!"))
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG

	else
		to_chat(user, span_warning("Вы чувствуете себя слабее..."))
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH


/obj/effect/proc_holder/spell/vampire/self/blood_rush
	name = "Кровавый драйв"
	desc = "Напитайте себя магией крови, чтобы увеличить скорость передвижения."
	gain_desc = "Вы получили способность временно перемещаться с большой скоростью."
	base_cooldown = 30 SECONDS
	required_blood = 15
	action_icon_state = "blood_rush"


/obj/effect/proc_holder/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, span_notice("Вы ощущаете прилив энергии!"))
		H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)


/obj/effect/proc_holder/spell/fireball/demonic_grasp
	name = "Демоническая хватка"
	desc = "Выстрелите сгустком демонической энергии, захватывая или отбрасывая цель в зависимости от вашего намерения: «ОБЕЗОРУЖИТЬ» — оттолкнуть, «СХВАТИТЬ» — притянуть."
	gain_desc = "Вы получили способность притягивать и отталкивать людей с помощью демонических отростков."
	base_cooldown = 15 SECONDS
	fireball_type = /obj/projectile/magic/demonic_grasp

	selection_activated_message		= span_notice("Вы поднимаете руку, полную демонической энергии!")
	selection_deactivated_message	= span_notice("Вы возвращаете себе энергию... пока что.")

	action_icon_state = "demonic_grasp"

	school = "vampire"
	action_background_icon_state = "bg_vampire"
	invocation_type = "none"
	invocation = null
	sound = 'sound/misc/exit_blood.ogg'
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/fireball/demonic_grasp/after_spell_init()
	update_vampire_spell_name()


/obj/effect/proc_holder/spell/fireball/demonic_grasp/update_icon_state()
	return


/obj/effect/proc_holder/spell/fireball/demonic_grasp/create_new_handler()
	var/datum/spell_handler/vampire/V = new()
	V.required_blood = 10
	return V


/obj/projectile/magic/demonic_grasp
	name = "demonic grasp"
	ru_names = list(
            NOMINATIVE = "демоническая хватка",
            GENITIVE = "демонической хватки",
            DATIVE = "демонической хватке",
            ACCUSATIVE = "демоническую хватку",
            INSTRUMENTAL = "демонической хваткой",
            PREPOSITIONAL = "демонической хватке"
        )
	// parry this you filthy casual
	reflectability = REFLECTABILITY_NEVER
	icon_state = null


/obj/projectile/magic/demonic_grasp/pixel_move(trajectory_multiplier)
	. = ..()
	new /obj/effect/temp_visual/demonic_grasp(loc)


/obj/projectile/magic/demonic_grasp/on_hit(mob/living/target, blocked, hit_zone)
	. = ..()
	if(!istype(target) || !firer || !target.affects_vampire(firer))
		return

	var/target_turf = get_turf(target)
	target.Immobilize(5 SECONDS)
	playsound(target_turf, 'sound/misc/demon_attack1.ogg', 50, TRUE)
	new /obj/effect/temp_visual/demonic_grasp(target_turf)

	var/throw_target
	switch(firer.a_intent)
		if(INTENT_DISARM)
			throw_target = get_edge_target_turf(target, get_dir(firer, target))
			target.throw_at(throw_target, 2, 5, spin = FALSE, callback = CALLBACK(src, PROC_REF(create_snare), target)) // shove away
		if(INTENT_GRAB)
			throw_target = get_step(firer, get_dir(firer, target))
			target.throw_at(throw_target, 2, 5, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(create_snare), target)) // pull towards
		else
			create_snare(target)


/obj/projectile/magic/demonic_grasp/proc/create_snare(mob/living/target)
	new /obj/effect/temp_visual/demonic_snare(get_turf(target))


/obj/effect/temp_visual/demonic_grasp
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "demonic_grasp"
	duration = 3.5 SECONDS


/obj/effect/temp_visual/demonic_snare
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "immobilized"
	duration = 5 SECONDS


/obj/effect/proc_holder/spell/vampire/charge
	name = "Рывок"
	desc = "Вы резко бросаетесь в выбранное направление, нанося огромный урон, оглушая и разрушая стены и другие объекты."
	gain_desc = "Теперь вы можете произвести рывок, нанося огромный урон и разрушая объекты."
	required_blood = 30
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_charge"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/vampire/charge/can_cast(mob/living/user, charge_check, show_message)
	if(user.body_position == LYING_DOWN)
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

