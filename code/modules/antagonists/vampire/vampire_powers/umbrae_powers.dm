/obj/effect/proc_holder/spell/vampire/self/cloak
	name = "Покров тьмы"
	desc = "Включает или выключает маскировку в темноте. Если вы замаскированы и находитесь в темноте, то ваша скорость увеличивается."
	gain_desc = "Теперь вы можете маскировать себя во тьме, становясь почти невидимым и чрезвычайно проворным."
	action_icon_state = "vampire_cloak"
	base_cooldown = 2 SECONDS


/obj/effect/proc_holder/spell/vampire/self/cloak/update_vampire_spell_name(mob/user = usr)
	var/datum/antagonist/vampire/V = user?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return

	var/new_name = "[initial(name)] ([V.iscloaking ? "Деактивировать" : "Активировать"])"
	name = new_name
	action?.name = new_name
	action?.UpdateButtonIcon()


/obj/effect/proc_holder/spell/vampire/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	V.iscloaking = !V.iscloaking
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(V.iscloaking)
			H.physiology.burn_mod *= 1.3
			user.RegisterSignal(user, COMSIG_LIVING_IGNITED, TYPE_PROC_REF(/mob/living, update_vampire_cloak))
		else
			user.UnregisterSignal(user, COMSIG_LIVING_IGNITED)
			H.physiology.burn_mod /= 1.3

	update_vampire_spell_name(user)
	to_chat(user, span_notice("Теперь вы будете <b>[V.iscloaking ? "скрыты" : "видимы"]</b> в темноте."))


/mob/living/proc/update_vampire_cloak()
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
	V.handle_vampire_cloak()


/obj/effect/proc_holder/spell/vampire/shadow_snare
	name = "Теневая ловушка"
	desc = "Вы вызываете ловушку на земле. Когда её пересекут, она ослепит цель, погасит все имеющиеся у неё источники света и захватит её в капкан."
	gain_desc = "Вы получили способность вызывать ловушку, которая ослепит, захватит в капкан и выключит свет любому, кто пересечет ее."
	base_cooldown = 10 SECONDS
	required_blood = 20
	action_icon_state = "shadow_snare"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/shadow_snare/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /turf/simulated
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/vampire/shadow_snare/cast(list/targets, mob/user)
	var/turf/target = targets[1]
	new /obj/item/restraints/legcuffs/beartrap/shadow_snare(target)


/obj/item/restraints/legcuffs/beartrap/shadow_snare
	name = "shadow snare"
	desc = "Почти прозрачная ловушка, которая тает в тени."
	ru_names = list(
        NOMINATIVE = "теневая ловушка",
        GENITIVE = "теневой ловушки",
        DATIVE = "теневой ловушке",
        ACCUSATIVE = "теневую ловушку",
        INSTRUMENTAL = "теневой ловушкой",
        PREPOSITIONAL = "теневой ловушке"
    )
	alpha = 60
	armed = TRUE
	anchored = TRUE
	breakouttime = 5 SECONDS
	item_flags = DROPDEL


/obj/item/restraints/legcuffs/beartrap/shadow_snare/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/restraints/legcuffs/beartrap/shadow_snare/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/restraints/legcuffs/beartrap/shadow_snare/process()
	var/turf/T = get_turf(src)
	var/lighting_count = T.get_lumcount() * 10
	if(lighting_count > 2)
		obj_integrity -= 50

	if(obj_integrity <= 0)
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] исчезает."))
		qdel(src)


/obj/item/restraints/legcuffs/beartrap/shadow_snare/triggered(mob/living/carbon/victim)
	if(!armed || !iscarbon(victim))
		return

	if(!victim.affects_vampire()) // no parameter here so holy always protects
		return

	if(victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return

	victim.extinguish_light()
	victim.EyeBlind(20 SECONDS)
	STOP_PROCESSING(SSobj, src) // won't wither away once you are trapped

	. = ..()

	if(loc != victim && !QDELETED(src)) // if it fails to latch onto someone for whatever reason, delete itself, we don't want unarmed ones lying around.
		qdel(src)


/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_hand(mob/user)
	triggered(user)


/obj/item/restraints/legcuffs/beartrap/shadow_snare/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		to_chat(user, span_userdanger("Ловушка посылает обратную связь с помощью психического сигнала!"))
		C.EyeBlind(20 SECONDS)


/obj/item/restraints/legcuffs/beartrap/shadow_snare/attackby(obj/item/I, mob/user, params)
	var/obj/item/flash/flash = I
	if(!istype(flash) || !flash.try_use_flash(user))
		return ..()
	. |= ATTACK_CHAIN_BLOCKED_ALL
	user.do_attack_animation(src)
	user.visible_message(
		span_danger("[user] навод[pluralize_ru(user.gender, "ит", "ят")] [I] на [declent_ru(ACCUSATIVE)], и она исчезает!"),
		span_danger("Наведите [I] на [declent_ru(ACCUSATIVE)], и она исчезнет!"),
	)
	qdel(src)


/obj/effect/proc_holder/spell/vampire/soul_anchor
	name = "Теневой якорь"
	desc = "Вы вызываете затемнённый якорь после задержки, повторное заклинание телепортирует вас обратно к якорю. Вы будете вынуждены вернуться назад через 2 минуты, если не произнесли повторное заклинание."
	gain_desc = "Вы получили способность сохранять точку в пространстве и телепортироваться к ней по своему желанию. Если в течение 2 минут вы самостоятельно не телепортируетесь обратно в эту точку, вас телепортирует автоматически."
	required_blood = 30
	centcom_cancast = FALSE
	base_cooldown = 130 SECONDS
	action_icon_state = "shadow_anchor"
	should_recharge_after_cast = FALSE
	deduct_blood_on_cast = FALSE
	var/obj/structure/shadow_anchor/anchor
	/// Are we making an anchor?
	var/making_anchor = FALSE
	/// Holds a reference to the timer until the caster is forced to recall
	var/timer


/obj/effect/proc_holder/spell/vampire/soul_anchor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/vampire/soul_anchor/cast(list/targets, mob/user)
	if(making_anchor) // second cast, but we are impatient
		balloon_alert(user, "якорь не готов!")
		return

	if(!making_anchor && !anchor) // first cast, setup the anchor
		var/turf/anchor_turf = get_turf(user)
		making_anchor = TRUE
		if(do_after(user, 5 SECONDS, user, ALL)) // no checks, cant fail
			make_anchor(user, anchor_turf)
			making_anchor = FALSE
			return

	if(anchor) // second cast, teleport us back
		recall(user)


/obj/effect/proc_holder/spell/vampire/soul_anchor/proc/make_anchor(mob/user, turf/anchor_turf)
	anchor = new(anchor_turf)
	timer = addtimer(CALLBACK(src, PROC_REF(recall), user), 2 MINUTES, TIMER_STOPPABLE)
	should_recharge_after_cast = TRUE


/obj/effect/proc_holder/spell/vampire/soul_anchor/proc/recall(mob/user)
	if(timer)
		deltimer(timer)
		timer = null

	var/turf/start_turf = get_turf(user)
	var/turf/end_turf = get_turf(anchor)
	QDEL_NULL(anchor)
	if(end_turf.z != start_turf.z)
		return
	if(!is_teleport_allowed(end_turf.z))
		return

	user.forceMove(end_turf)

	if(end_turf.z == start_turf.z)
		shadow_to_animation(start_turf, end_turf, user)

	var/datum/spell_handler/vampire/V = custom_handler
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/blood_cost = V.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost
	addtimer(VARSET_CALLBACK(src, should_recharge_after_cast, FALSE), 1 SECONDS) // this is needed so that the spell handler knows we casted it properly


/proc/shadow_to_animation(turf/start_turf, turf/end_turf, mob/user)
	var/x_difference = end_turf.x - start_turf.x
	var/y_difference = end_turf.y - start_turf.y
	var/distance = sqrt(x_difference ** 2 + y_difference ** 2) // pythag baby

	var/obj/effect/immortality_talisman/effect = new(start_turf)
	effect.dir = user.dir
	effect.can_destroy = TRUE

	var/animation_time = distance
	animate(effect, time = animation_time, alpha = 0, pixel_x = x_difference * 32, pixel_y = y_difference * 32) //each turf is 32 pixels long
	QDEL_IN(effect, animation_time)


// an indicator that shows where the vampire will land
/obj/structure/shadow_anchor
	name = "shadow anchor"
	desc = "При взгляде на эту штуку вам становится не по себе..."
	ru_names = list(
        NOMINATIVE = "теневой якорь",
        GENITIVE = "теневого якоря",
        DATIVE = "теневому якорю",
        ACCUSATIVE = "теневой якорь",
        INSTRUMENTAL = "теневым якорем",
        PREPOSITIONAL = "теневом якоре"
    )
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	alpha = 120
	color = "#545454"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE


/obj/effect/proc_holder/spell/vampire/dark_passage
	name = "Шаг в тень"
	desc = "Вы телепортируетесь на указанную площадку."
	gain_desc = "Вы получили способность совершать молниеносный бросок на небольшое расстояние в сторону указанной площадки."
	base_cooldown = 15 SECONDS
	required_blood = 30
	centcom_cancast = FALSE
	action_icon_state = "dark_passage"
	sound = 'sound/magic/teleport_app.ogg'
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/dark_passage/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.allowed_type = /turf/simulated
	return T


/obj/effect/proc_holder/spell/vampire/dark_passage/cast(list/targets, mob/user)
	var/turf/target = get_turf(targets[1])
	new /obj/effect/temp_visual/vamp_mist_out(get_turf(user))
	user.forceMove(target)
	new /obj/effect/temp_visual/vamp_mist_in(get_turf(user))


/obj/effect/temp_visual/vamp_mist_out
	duration = 2 SECONDS
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist"


/obj/effect/temp_visual/vamp_mist_in
	duration = 1 SECONDS
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist_reappear"


/obj/effect/proc_holder/spell/vampire/vamp_extinguish
	name = "Погасить"
	desc = "Вы гасите любой источник света в области вокруг себя."
	gain_desc = "Вы получили способность гасить ближайшие источники света."
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_extinguish"
	create_attack_logs = FALSE
	create_custom_logs = TRUE


/obj/effect/proc_holder/spell/vampire/vamp_extinguish/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new
	return T


/obj/effect/proc_holder/spell/vampire/vamp_extinguish/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()


/obj/effect/proc_holder/spell/vampire/shadow_boxing
	name = "Бой с тенью"
	desc = "Нацельтесь на кого-нибудь, чтобы ваша тень избила его. Чтобы это сработало, вы должны находиться в пределах двух тайлов."
	gain_desc = "Теперь вы можете заставить свою тень сражаться бок о бок с вами."
	base_cooldown = 30 SECONDS
	action_icon_state = "shadow_boxing"
	required_blood = 50
	need_active_overlay = TRUE
	var/target_UID


/obj/effect/proc_holder/spell/vampire/shadow_boxing/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /mob/living
	T.range = 2
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/vampire/shadow_boxing/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	target.apply_status_effect(STATUS_EFFECT_SHADOW_BOXING, user)


/obj/effect/proc_holder/spell/vampire/self/eternal_darkness
	name = "Вечная тьма"
	desc = "При включении вы окутываете пространство вокруг себя темнотой и медленно понижаете температуру тела находящихся рядом гуманоидов."
	gain_desc = "Вы обрели способность окутывать всё вокруг себя тьмой. Только сильнейший свет сможет пронзить вашу нечестивую силу."
	base_cooldown = 10 SECONDS
	action_icon_state = "eternal_darkness"
	required_blood = 5
	var/shroud_power = -4


/obj/effect/proc_holder/spell/vampire/self/eternal_darkness/cast(list/targets, mob/user)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/target = targets[1]
	if(!V.get_ability(/datum/vampire_passive/eternal_darkness))
		V.force_add_ability(/datum/vampire_passive/eternal_darkness)
		target.set_light(6, shroud_power, "#AAD84B")
	else
		for(var/datum/vampire_passive/eternal_darkness/E in V.powers)
			V.remove_ability(E)


/datum/vampire_passive/eternal_darkness
	gain_desc = "Вы окружаете себя неестественной тьмой, замораживая окружающих."


/datum/vampire_passive/eternal_darkness/New()
	..()
	START_PROCESSING(SSobj, src)


/datum/vampire_passive/eternal_darkness/Destroy(force)
	owner.remove_light()
	STOP_PROCESSING(SSobj, src)
	return ..()


/datum/vampire_passive/eternal_darkness/process()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)

	for(var/mob/living/L in view(6, owner))
		if(L.affects_vampire(owner))
			L.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT)

	V.bloodusable = max(V.bloodusable - 5, 0)

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)


/datum/vampire_passive/xray
	gain_desc = "Теперь вы можете видеть сквозь стены, если вы не заметили."

