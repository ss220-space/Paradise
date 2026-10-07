/datum/action/cooldown/spell/umbrae_cloak
	name = "Покров тьмы"
	desc = "Включает или выключает маскировку в темноте. Если вы замаскированы и находитесь в темноте, то ваша скорость увеличивается."
	gain_desc = "Теперь вы можете маскировать себя во тьме, становясь почти невидимым и чрезвычайно проворным."
	button_icon_state = "vampire_cloak"
	background_icon_state = "bg_vampire"
	cooldown_time = 2 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE

/datum/action/cooldown/spell/umbrae_cloak/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/umbrae_cloak/Grant(mob/grant_to)
	. = ..()
	var/datum/antagonist/vampire/V = grant_to?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return

	name = "[initial(name)] ([V.iscloaking ? "Деактивировать" : "Активировать"])"
	build_all_button_icons()

/datum/action/cooldown/spell/umbrae_cloak/after_cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/V = owner?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return

	name = "[initial(name)] ([V.iscloaking ? "Деактивировать" : "Активировать"])"
	build_all_button_icons()

/datum/action/cooldown/spell/umbrae_cloak/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	V.iscloaking = !V.iscloaking
	if(ishuman(owner))
		var/mob/living/carbon/human/caster = owner
		if(V.iscloaking)
			caster.physiology.burn_mod *= 1.3
			owner.RegisterSignal(owner, COMSIG_LIVING_IGNITED, TYPE_PROC_REF(/mob/living, update_vampire_cloak))
		else
			owner.UnregisterSignal(owner, COMSIG_LIVING_IGNITED)
			caster.physiology.burn_mod /= 1.3

	to_chat(owner, span_notice("Теперь вы будете <b>[V.iscloaking ? "скрыты" : "видимы"]</b> в темноте."))

/mob/living/proc/update_vampire_cloak()
	SIGNAL_HANDLER
	var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
	V.handle_vampire_cloak()

/datum/action/cooldown/spell/pointed/shadow_snare
	name = "Теневая ловушка"
	desc = "Вы вызываете ловушку на земле. Когда её пересекут, она ослепит цель, погасит все имеющиеся у неё источники света и захватит её в капкан."
	gain_desc = "Вы получили способность вызывать ловушку, которая ослепит, захватит в капкан и выключит свет любому, кто пересечет ее."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	button_icon_state = "shadow_snare"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	cooldown_time = 10 SECONDS
	var/required_blood = 15

/datum/action/cooldown/spell/pointed/shadow_snare/cast(atom/cast_on)
	. = ..()
	var/turf/target = get_turf(cast_on)
	new /obj/item/restraints/legcuffs/beartrap/shadow_snare(target)

/datum/action/cooldown/spell/pointed/shadow_snare/create_new_handler()
	var/datum/spell_handler/vampire/handler = new
	handler.required_blood = required_blood
	name = "[initial(name)] ([required_blood])"
	build_all_button_icons()
	return handler

/obj/item/restraints/legcuffs/beartrap/shadow_snare
	name = "shadow snare"
	desc = "Почти прозрачная ловушка, которая тает в тени."
	alpha = 60
	armed = TRUE
	anchored = TRUE
	breakout_time = 5 SECONDS
	item_flags = DROPDEL

/obj/item/restraints/legcuffs/beartrap/shadow_snare/get_ru_names()
	return alist(
			NOMINATIVE = "теневая ловушка",
			GENITIVE = "теневой ловушки",
			DATIVE = "теневой ловушке",
			ACCUSATIVE = "теневую ловушку",
			INSTRUMENTAL = "теневой ловушкой",
			PREPOSITIONAL = "теневой ловушке",
		)

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
		update_integrity(obj_integrity - 50)

	if(obj_integrity <= 0)
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] исчезает."))
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
		span_danger("[user] навод[PLUR_IT_YAT(user)] [I] на [declent_ru(ACCUSATIVE)], и она исчезает!"),
		span_danger("Наведите [I] на [declent_ru(ACCUSATIVE)], и она исчезнет!"),
	)
	qdel(src)

/datum/action/cooldown/spell/soul_anchor
	name = "Теневой якорь"
	desc = "Вы вызываете затемнённый якорь после задержки, повторное заклинание телепортирует вас обратно к якорю. Вы будете вынуждены вернуться назад через 2 минуты, если не произнесли повторное заклинание."
	gain_desc = "Вы получили способность сохранять точку в пространстве и телепортироваться к ней по своему желанию. Если в течение 2 минут вы самостоятельно не телепортируетесь обратно в эту точку, вас телепортирует автоматически."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 130 SECONDS
	button_icon_state = "shadow_anchor"
	background_icon_state = "bg_vampire"
	var/obj/structure/shadow_anchor/anchor
	var/required_blood = 20
	/// Are we making an anchor?
	var/making_anchor = FALSE
	/// Holds a reference to the timer until the caster is forced to recall
	var/timer

/datum/action/cooldown/spell/soul_anchor/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood, FALSE)
	return handler

/datum/action/cooldown/spell/soul_anchor/before_cast(atom/cast_on)
	. = ..()
	if(!anchor)
		cooldown_time = 0
		return
	cooldown_time = initial(cooldown_time)

/datum/action/cooldown/spell/soul_anchor/cast(atom/cast_on)
	. = ..()
	if(making_anchor) // second cast, but we are impatient
		owner.balloon_alert(owner, "якорь не готов!")
		return

	if(!making_anchor && !anchor) // first cast, setup the anchor
		var/turf/anchor_turf = get_turf(owner)
		making_anchor = TRUE
		if(do_after(owner, 5 SECONDS, owner, ALL)) // no checks, cant fail
			make_anchor(owner, anchor_turf)
			making_anchor = FALSE
			return

	if(anchor) // second cast, teleport us back
		recall(owner)

/datum/action/cooldown/spell/soul_anchor/proc/make_anchor(mob/user, turf/anchor_turf)
	anchor = new(anchor_turf)
	timer = addtimer(CALLBACK(src, PROC_REF(recall), user), 2 MINUTES, TIMER_STOPPABLE)

/datum/action/cooldown/spell/soul_anchor/proc/recall(mob/user)
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

/proc/shadow_to_animation(turf/start_turf, turf/end_turf, mob/user)
	var/x_difference = end_turf.x - start_turf.x
	var/y_difference = end_turf.y - start_turf.y
	var/distance = MAGNITUDE(x_difference, y_difference) // pythag baby

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
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	alpha = 120
	color = "#545454"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/shadow_anchor/get_ru_names()
	return alist(
			NOMINATIVE = "теневой якорь",
			GENITIVE = "теневого якоря",
			DATIVE = "теневому якорю",
			ACCUSATIVE = "теневой якорь",
			INSTRUMENTAL = "теневым якорем",
			PREPOSITIONAL = "теневом якоре",
		)

/datum/action/cooldown/spell/pointed/dark_passage
	name = "Шаг в тень"
	desc = "Вы телепортируетесь на указанную площадку."
	gain_desc = "Вы получили способность совершать молниеносный бросок на небольшое расстояние в сторону указанной площадки."
	cooldown_time = 15 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "dark_passage"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	school = SCHOOL_SANGUINE
	sound = 'sound/magic/teleport_app.ogg'
	var/required_blood = 20

/datum/action/cooldown/spell/pointed/dark_passage/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/dark_passage/cast(atom/cast_on)
	. = ..()
	var/turf/target = get_turf(cast_on)
	new /obj/effect/temp_visual/vamp_mist_out(get_turf(owner))
	owner.forceMove(target)
	new /obj/effect/temp_visual/vamp_mist_in(get_turf(owner))

/obj/effect/temp_visual/vamp_mist_out
	duration = 2 SECONDS
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist"

/obj/effect/temp_visual/vamp_mist_in
	icon = 'icons/mob/mob.dmi'
	icon_state = "mist_reappear"

/datum/action/cooldown/spell/aoe/vamp_extinguish
	name = "Погасить"
	desc = "Вы гасите любой источник света в области вокруг себя."
	gain_desc = "Вы получили способность гасить ближайшие источники света."
	cooldown_time = 30 SECONDS
	button_icon_state = "vampire_extinguish"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	targeting_type = /datum/aoe_targeting/turfs

/datum/action/cooldown/spell/aoe/vamp_extinguish/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/aoe/vamp_extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/turf/victim_turf = victim
	victim_turf.extinguish_light(force = TRUE)
	for(var/atom/atom in victim_turf.contents)
		atom.extinguish_light(force = TRUE)

/datum/action/cooldown/spell/pointed/shadow_boxing
	name = "Бой с тенью"
	desc = "Нацельтесь на кого-нибудь, чтобы ваша тень избила его. Чтобы это сработало, вы должны находиться в пределах двух тайлов."
	gain_desc = "Теперь вы можете заставить свою тень сражаться бок о бок с вами."
	cooldown_time = 30 SECONDS
	button_icon_state = "shadow_boxing"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 2
	var/target_UID
	var/required_blood = 30

/datum/action/cooldown/spell/pointed/shadow_boxing/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/shadow_boxing/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/shadow_boxing/cast(atom/cast_on)
	. = ..()
	var/mob/living/target = cast_on
	target.apply_status_effect(STATUS_EFFECT_SHADOW_BOXING, owner)

/datum/action/cooldown/spell/eternal_darkness
	name = "Вечная тьма"
	desc = "При включении вы окутываете пространство вокруг себя темнотой и медленно понижаете температуру тела находящихся рядом гуманоидов."
	gain_desc = "Вы обрели способность окутывать всё вокруг себя тьмой. Только сильнейший свет сможет пронзить вашу нечестивую силу."
	button_icon_state = "eternal_darkness"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/required_blood = 5
	var/shroud_power = -4

/datum/action/cooldown/spell/eternal_darkness/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood, FALSE)
	return handler

/datum/action/cooldown/spell/eternal_darkness/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V.get_ability(/datum/vampire_passive/eternal_darkness))
		V.force_add_ability(/datum/vampire_passive/eternal_darkness)
		owner.set_light(6, shroud_power, COLOR_VOID_PURPLE)
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

	for(var/turf/turf as anything in RANGE_TURFS(4, get_turf(owner)))
		turf.extinguish_light(force = TRUE)
		for(var/atom/atom as anything in turf.contents)
			atom.extinguish_light(force = TRUE)

	V.bloodusable = max(V.bloodusable - 5, 0)

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)

/datum/vampire_passive/xray
	gain_desc = "Теперь вы можете видеть сквозь стены, если вы не заметили."

