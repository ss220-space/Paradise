/**********************Mining drone**********************/
#define MINEDRONE_COLLECT 1
#define MINEDRONE_ATTACK 2

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "Инструкция на корпусе: Этот небольшой робот предназначен для помощи шахтёрам. Может быть настроен на поиск и сбор руды или защиту от фауны. Сканером можно дать команду на выгрузку руды. Полевой ремонт осуществляется сварочным аппаратом."
	ru_names = list(
		NOMINATIVE = "шахтёрский бот",
		GENITIVE = "шахтёрского бота",
		DATIVE = "шахтёрскому боту",
		ACCUSATIVE = "шахтёрский бот",
		INSTRUMENTAL = "шахтёрским ботом",
		PREPOSITIONAL = "шахтёрском боте"
	)
	gender = NEUTER
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANKNOCKDOWN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	faction = list("neutral")
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	move_to_delay = 10
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = 0
	check_friendly_fire = TRUE
	stop_automated_movement_when_pulled = TRUE
	attacktext = "сверлит"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	sentience_type = SENTIENCE_MINEBOT
	speak_emote = list("states")
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma,  /obj/item/stack/ore/uranium,    /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/tranquillite, /obj/item/stack/ore/glass,
						  /obj/item/stack/ore/titanium)
	healable = 0
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	del_on_death = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_on = FALSE
	weather_immunities = list(TRAIT_ASHSTORM_IMMUNE)
	var/mode = MINEDRONE_COLLECT
	var/mesons_active
	var/obj/item/gun/energy/kinetic_accelerator/minebot/stored_gun

	var/datum/action/innate/minedrone/toggle_light/toggle_light_action
	var/datum/action/innate/minedrone/toggle_meson_vision/toggle_meson_vision_action
	var/datum/action/innate/minedrone/toggle_mode/toggle_mode_action
	var/datum/action/innate/minedrone/dump_ore/dump_ore_action

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	stored_gun = new(src)
	toggle_light_action = new()
	toggle_light_action.Grant(src)
	toggle_meson_vision_action = new()
	toggle_meson_vision_action.Grant(src)
	toggle_mode_action = new()
	toggle_mode_action.Grant(src)
	dump_ore_action = new()
	dump_ore_action.Grant(src)

	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/mining_drone/emp_act(severity)
	adjustHealth(100 / severity)
	to_chat(src, span_userdanger("ВНИМАНИЕ: Обнаружен ЭМИ, системы повреждены!"))
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] яростно трещит и искрит!"))

/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	..()
	check_friendly_fire = 0

/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += span_warning("[genderize_ru(gender,"Он","Она","Оно","Они")] выгляд[pluralize_ru(gender,"ит","ят")] слегка помято.")
		else
			. += span_boldwarning("[genderize_ru(gender,"Он","Она","Оно","Они")] выгляд[pluralize_ru(gender,"ит","ят")] серьёзно повреждённо!")
	. += "[span_notice("Использование сканера на [genderize_ru(gender,"нём","нем","нём","них")] заставит [genderize_ru(gender,"его","её","его","их")] выгрузить руду. <b>[max(0, LAZYLEN(contents) - 1)] ед. руды.</b>")]"
	if(stored_gun && stored_gun.max_mod_capacity)
		. += "<b>[stored_gun.get_remaining_mod_capacity()]%</b> свободного места для модификации."
		for(var/A in stored_gun.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += span_notice("Установлен [M.declent_ru(NOMINATIVE)], занимающий <b>[M.cost]%</b> ёмкости.")


/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner))
		to_chat(user, span_notice("Вы приказываете [declent_ru(DATIVE)] выгрузить собранную руду."))
		DropOre()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/borg/upgrade/modkit))
		I.melee_attack_chain(user, stored_gun, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/mob/living/simple_animal/hostile/mining_drone/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	I.melee_attack_chain(user, stored_gun)

/mob/living/simple_animal/hostile/mining_drone/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(health == maxHealth)
		to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] не требует ремонта!"))
		return
	if(!I.tool_use_check(user, 1))
		return
	if(AIStatus != AI_OFF && AIStatus != AI_IDLE)
		to_chat(user, span_info("[capitalize(declent_ru(NOMINATIVE))] слишком активно двигается для ремонта!"))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 15, 1, volume = I.tool_volume) && health != maxHealth)
		adjustBruteLoss(-20)
		WELDER_REPAIR_SUCCESS_MESSAGE
	return

/mob/living/simple_animal/hostile/mining_drone/death(gibbed)
	DropOre(0)
	if(stored_gun)
		stored_gun.deattach_modkits()
	deathmessage = "разлетается на куски!"
	. = ..()

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		toggle_mode()
		switch(mode)
			if(MINEDRONE_COLLECT)
				to_chat(M, span_info("[capitalize(declent_ru(NOMINATIVE))] переведён в режим поиска и сбора руды."))
			if(MINEDRONE_ATTACK)
				to_chat(M, span_info("[capitalize(declent_ru(NOMINATIVE))] переведён в режим атаки на опасную фауну."))
		return
	..()


/mob/living/simple_animal/hostile/mining_drone/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(istype(mover, /obj/projectile/kinetic))
		var/obj/projectile/kinetic/projectile = mover
		if(projectile.kinetic_gun)
			for(var/obj/item/borg/upgrade/modkit/minebot_passthrough/MK in projectile.kinetic_gun.get_modkits())
				return TRUE

	if(istype(mover, /obj/projectile/destabilizer))
		return TRUE



/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_COLLECT
	vision_range = 9
	search_objects = 2
	wander = TRUE
	ranged = FALSE
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	to_chat(src, span_info("Активирован режим сбора. Теперь можно собирать рассыпанную руду."))

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_ATTACK
	vision_range = 7
	search_objects = 0
	wander = FALSE
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 1
	icon_state = "mining_drone_offense"
	to_chat(src, span_info("Активирован боевой режим. Теперь доступна дистанционная атака."))

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/stack/ore) && mode == MINEDRONE_COLLECT)
		CollectOre()
		return
	if(isliving(target))
		SetOffenseBehavior()
	return ..()

/mob/living/simple_animal/hostile/mining_drone/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	stored_gun.afterattack(A, src) //of the possible options to allow minebots to have KA mods, would you believe this is the best?

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	for(var/obj/item/stack/ore/O in range(1, src))
		O.forceMove(src)

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre(message = 1)
	if(!contents.len)
		if(message)
			to_chat(src, span_warning("Попытка выгрузки руды: хранилище пусто."))
		return
	if(message)
		to_chat(src, span_notice("Вы выгружаете собранную руду."))
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(drop_location())


/mob/living/simple_animal/hostile/mining_drone/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0 && mode != MINEDRONE_ATTACK)
		SetOffenseBehavior()


/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	switch(mode)
		if(MINEDRONE_ATTACK)
			SetCollectBehavior()
		else
			SetOffenseBehavior()

//Actions for sentient minebots

/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	background_icon_state = "bg_default"

/datum/action/innate/minedrone/toggle_light
	name = "Переключить фонарик"
	button_icon_state = "mech_lights_off"


/datum/action/innate/minedrone/toggle_light/Activate()
	owner.set_light_on(!owner.light_on)
	to_chat(owner, span_notice("Вы [owner.light_on ? "включили" : "выключили"] фонарик."))


/datum/action/innate/minedrone/toggle_meson_vision
	name = "Переключить мезонное зрение"
	button_icon_state = "meson"
	var/sight_flags = SEE_TURFS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/user = owner
	var/is_active = user.sight & SEE_TURFS

	if(is_active)
		UnregisterSignal(user, COMSIG_MOB_UPDATE_SIGHT)
		user.update_sight()
	else
		RegisterSignal(user, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))
		user.update_sight()

	to_chat(user, span_notice("Вы [!is_active ? "включили" : "выключили"] мезонное зрение.</span>"))

/datum/action/innate/minedrone/toggle_meson_vision/proc/update_user_sight(mob/living/user)
	user.add_sight(sight_flags)
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

/datum/action/innate/minedrone/toggle_mode
	name = "Переключить режим"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/minedrone/toggle_mode/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.toggle_mode()

/datum/action/innate/minedrone/dump_ore
	name = "Сбросить руду"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.DropOre()


/**********************Minebot Upgrades**********************/

//Melee

/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "Апгрейд для шахтёрского бота."
	ru_names = list(
		NOMINATIVE = "модуль ближнего боя для шахтёрского бота",
		GENITIVE = "модуля ближнего боя для шахтёрского бота",
		DATIVE = "модулю ближнего боя для шахтёрского бота",
		ACCUSATIVE = "модуль ближнего боя для шахтёрского бота",
		INSTRUMENTAL = "модулем ближнего боя для шахтёрского бота",
		PREPOSITIONAL = "модуле ближнего боя для шахтёрского бота"
	)
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'

/obj/item/mine_bot_upgrade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user, proximity, params)
	if(!istype(M) || !proximity)
		return
	upgrade_bot(M, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		to_chat(user, "[capitalize(declent_ru(NOMINATIVE))] уже имеет боевой модуль!")
		return
	M.melee_damage_lower += 7
	M.melee_damage_upper += 7
	to_chat(user, "Вы вставляете [declent_ru(ACCUSATIVE)].")
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"
	ru_names = list(
		NOMINATIVE = "модуль брони для шахтёрского бота",
		GENITIVE = "модуля брони для шахтёрского бота",
		DATIVE = "модулю брони для шахтёрского бота",
		ACCUSATIVE = "модуль брони для шахтёрского бота",
		INSTRUMENTAL = "модулем брони для шахтёрского бота",
		PREPOSITIONAL = "модуле брони для шахтёрского бота"
	)

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		to_chat(user, "[capitalize(declent_ru(NOMINATIVE))] уже имеет усиленный корпус!")
		return
	M.maxHealth += 45
	M.updatehealth()
	qdel(src)

//AI

/obj/item/slimepotion/sentience/mining
	name = "minebot AI upgrade"
	desc = "Может использоваться для наделения шахтёрских ботов самосознанием."
	ru_names = list(
		NOMINATIVE = "модуль ИИ для шахтёрского бота",
		GENITIVE = "модуля ИИ для шахтёрского бота",
		DATIVE = "модулю ИИ для шахтёрского бота",
		ACCUSATIVE = "модуль ИИ для шахтёрского бота",
		INSTRUMENTAL = "модулем ИИ для шахтёрского бота",
		PREPOSITIONAL = "модуле ИИ для шахтёрского бота"
	)
	icon_state = "door_electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	sentience_type = SENTIENCE_MINEBOT
	origin_tech = "programming=6"
	var/base_health_add = 5 //sentient minebots are penalized for beign sentient; they have their stats reset to normal plus these values
	var/base_damage_add = 1 //this thus disables other minebot upgrades
	var/base_speed_add = 1
	var/base_cooldown_add = 10 //base cooldown isn't reset to normal, it's just added on, since it's not practical to disable the cooldown module

/obj/item/slimepotion/sentience/mining/after_success(mob/living/user, mob/living/simple_animal/SM)
	if(istype(SM, /mob/living/simple_animal/hostile/mining_drone))
		var/mob/living/simple_animal/hostile/mining_drone/M = SM
		M.maxHealth = initial(M.maxHealth) + base_health_add
		M.melee_damage_lower = initial(M.melee_damage_lower) + base_damage_add
		M.melee_damage_upper = initial(M.melee_damage_upper) + base_damage_add
		M.move_to_delay = initial(M.move_to_delay) + base_speed_add
		if(M.stored_gun)
			M.stored_gun.overheat_time += base_cooldown_add
		if(M.mind)
			M.mind.offstation_role = TRUE

/**********************Mining drone cube**********************/

/obj/item/mining_drone_cube
	name = "mining drone cube"
	desc = "Сжатый шахтёрский дрон, готовый к развёртыванию. Просто нажмите кнопку для активации!"
	ru_names = list(
		NOMINATIVE = "куб шахтёрского бота",
		GENITIVE = "куба шахтёрского бота",
		DATIVE = "кубу шахтёрского бота",
		ACCUSATIVE = "куб шахтёрского бота",
		INSTRUMENTAL = "кубом шахтёрского бота",
		PREPOSITIONAL = "кубе шахтёрского бота"
	)
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/aibots.dmi'
	icon_state = "minedronecube"
	item_state = "electronic"

/obj/item/mining_drone_cube/attack_self(mob/user)
	user.visible_message(
		span_warning("[capitalize(declent_ru(NOMINATIVE))] раскрывается в полнофункционального шахтёрского бота!"),
		span_warning("Вы нажимаете центральную кнопку на [declent_ru(PREPOSITIONAL)]. Устройство внезапно раскрывается в полнофункционального шахтёрского бота!")
	)
	new /mob/living/simple_animal/hostile/mining_drone(get_turf(src))
	qdel(src)

#undef MINEDRONE_COLLECT
#undef MINEDRONE_ATTACK
