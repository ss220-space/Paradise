/datum/action/cooldown/spell/blood_swell
	name = "Кровавый вал"
	desc = "Вы наполняете своё тело кровью, что делает вас очень устойчивым к оглушению и физическому урону, но не даёт использовать оружие дальнего боя."
	gain_desc = "Вы получили способность временно повышать свою сопротивляемость урону и оглушению."
	cooldown_time = 40 SECONDS
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "blood_swell"
	background_icon_state = "bg_vampire"
	var/required_blood = 15

/datum/action/cooldown/spell/blood_swell/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/blood_swell/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/caster = cast_on
	caster.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "Пока действует «Кровавый вал», все ваши атаки в ближнем бою наносят повышенный урон."

/datum/action/cooldown/spell/stomp
	name = "Ударная волна"
	desc = "Вы бьёте ногой по земле, посылая мощную ударную волну, отчего окружающие разлетаются в разные стороны. Не может быть применено, если ваши ноги скованы или обездвижены."
	gain_desc = "Вы получили способность отбрасывать людей назад, используя мощный топот."
	button_icon_state = "seismic_stomp"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	var/required_blood = 10
	var/max_range = 4

/datum/action/cooldown/spell/stomp/can_cast_spell(feedback)
	var/mob/living/carbon/user = owner
	return ..() && !user.legcuffed

/datum/action/cooldown/spell/stomp/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(owner)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, owner), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)

/datum/action/cooldown/spell/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
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

/datum/action/cooldown/spell/overwhelming_force
	name = "Неудержимая сила"
	desc = "При активации вы будете выбивать все шлюзы, на которые наткнётесь, если у вас нет доступа, а также отражать все обездвиживающие предметы."
	gain_desc = "Вы получили способность выбивать двери и отражать обездвиживающие предметы за небольшую кровавую плату."
	cooldown_time = 2 SECONDS
	button_icon_state = "OH_YEAAAAH"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE

/datum/action/cooldown/spell/overwhelming_force/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/overwhelming_force/cast(atom/cast_on)
	. = ..()
	if(!HAS_TRAIT_FROM(owner, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(owner, span_userdanger("ВЫ ЧУВСТВУЕТЕ СЕБЯ СИЛЬНЕЕ!"))
		ADD_TRAIT(owner, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		ADD_TRAIT(owner, TRAIT_DEFLECT_BOLAS, VAMPIRE_TRAIT)
		owner.status_flags &= ~CANPUSH
		owner.move_resist = MOVE_FORCE_STRONG

	else
		to_chat(owner, span_warning("Вы чувствуете себя слабее..."))
		REMOVE_TRAIT(owner, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		REMOVE_TRAIT(owner, TRAIT_DEFLECT_BOLAS, VAMPIRE_TRAIT)
		owner.move_resist = MOVE_FORCE_DEFAULT
		owner.status_flags |= CANPUSH

/datum/action/cooldown/spell/blood_rush
	name = "Кровавый драйв"
	desc = "Напитайте себя магией крови, чтобы увеличить скорость передвижения."
	gain_desc = "Вы получили способность временно перемещаться с большой скоростью."
	cooldown_time = 30 SECONDS
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN
	button_icon_state = "blood_rush"
	background_icon_state = "bg_vampire"
	var/required_blood = 10

/datum/action/cooldown/spell/blood_rush/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = cast_on
	to_chat(H, span_notice("Вы ощущаете прилив энергии!"))
	H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)

/datum/action/cooldown/spell/pointed/projectile/demonic_grasp
	name = "Демоническая хватка"
	desc = "Выстрелите сгустком демонической энергии, захватывая или отбрасывая цель в зависимости от вашего намерения: «ОБЕЗОРУЖИТЬ» — оттолкнуть, «СХВАТИТЬ» — притянуть."
	gain_desc = "Вы получили способность притягивать и отталкивать людей с помощью демонических отростков."
	cooldown_time = 15 SECONDS
	projectile_type = /obj/projectile/magic/demonic_grasp
	active_msg = span_notice_alt("Вы поднимаете руку, полную демонической энергии!")
	deactive_msg = span_notice_alt("Вы возвращаете себе энергию... пока что.")
	button_icon_state = "demonic_grasp"
	background_icon_state = "bg_vampire"
	active_background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	sound = 'sound/misc/exit_blood.ogg'
	var/required_blood = 10

/datum/action/cooldown/spell/pointed/projectile/demonic_grasp/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/obj/effect/temp_visual/demonic_grasp
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "demonic_grasp"
	duration = 3.5 SECONDS

/obj/effect/temp_visual/demonic_snare
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "immobilized"
	duration = 5 SECONDS

/datum/action/cooldown/spell/pointed/garg_charge
	name = "Рывок"
	desc = "Вы резко бросаетесь в выбранное направление, нанося огромный урон, оглушая и разрушая стены и другие объекты."
	gain_desc = "Теперь вы можете произвести рывок, нанося огромный урон и разрушая объекты."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	cooldown_time = 30 SECONDS
	button_icon_state = "vampire_charge"
	background_icon_state = "bg_vampire"
	active_background_icon_state = "bg_vampire"
	var/required_blood = 15

/datum/action/cooldown/spell/pointed/garg_charge/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/garg_charge/can_cast_spell(feedback)
	if(iscarbon(owner))
		var/mob/living/carbon/caster = owner
		return ..() && caster.body_position != LYING_DOWN
	return ..()

/datum/action/cooldown/spell/pointed/garg_charge/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		var/mob/living/L = owner
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(cast_on, cast_range, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))
