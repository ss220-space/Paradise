/mob/living/simple_animal/hostile/guardian/healer
	friendly = "heals"
	damage_transfer = 0.7
	melee_damage_lower = 5
	melee_damage_upper = 5
	armour_penetration = 100
	playstyle_string = "Будучи <b>Поддержкой</b>, вы можете переключить свои базовые атаки в режим исцеления. Кроме того, нажатие Alt-кнопки на соседнем мобе деформирует его к вашему маяку в блюспейс пространстве с небольшой задержкой."
	magic_fluff_string = "...и берете карту Главного Врача, мощную силу жизни... и смерти."
	tech_fluff_string = "Последовательность загрузки завершена. Медицинские модули активированы. Активированы модули блюпространства. Голопаразитный рой активирован."
	bio_fluff_string = "Ваш рой скарабеев завершает мутацию и оживает, способный залечивать раны и путешествовать через блюспейс."
	var/turf/simulated/floor/beacon
	var/beacon_cooldown = 0
	var/default_beacon_cooldown = 300 SECONDS
	var/toggle = FALSE
	var/heal_cooldown = 0

/mob/living/simple_animal/hostile/guardian/healer/sealhealer
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "шлёпает"
	speak_emote = list("лает", "рявкает")
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	flags = ADMIN_SPAWNED

/mob/living/simple_animal/hostile/guardian/healer/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/guardian_quickmend/spell = new
	spell.summoner = summoner
	AddSpell(spell)

/mob/living/simple_animal/hostile/guardian/healer/Destroy()
	beacon = null
	return ..()

/mob/living/simple_animal/hostile/guardian/healer/Life(seconds, times_fired)
	..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.show_to(src)

/mob/living/simple_animal/hostile/guardian/healer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(beacon_cooldown >= world.time)
		status_tab_data[++status_tab_data.len] = list("Перезарядка блюспейс маяка:", "[max(round((beacon_cooldown - world.time) * 0.1, 0.1), 0)] секунд[declension_ru(max(round((beacon_cooldown - world.time) * 0.1, 0.1), 0), "а", "ы", "")]")

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(toggle)
		if(loc == summoner)
			to_chat(src, span_danger("Нужно явить себя для лечения!"))
			return
		if(iscarbon(target))
			var/mob/living/carbon/c_target = target
			changeNext_move(CLICK_CD_MELEE)
			if(heal_cooldown <= world.time && !stat)
				var/update = NONE
				update |= c_target.heal_overall_damage(5, 5, updating_health = FALSE, affect_robotic = TRUE)
				update |= c_target.heal_damages(tox = 5, oxy = 5, clone = 5, brain = 5, updating_health = FALSE)
				if(update)
					c_target.updatehealth()
				heal_cooldown = world.time + 20
				if(c_target == summoner)
					med_hud_set_health()
					med_hud_set_status()
	else
		if(loc == summoner)
			return
		var/mob/living/L = target
		if(istype(L))
			L.adjustToxLoss(15)

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			hud_used.action_intent.icon_state = a_intent
			melee_damage_lower = 5
			melee_damage_upper = 5
			to_chat(src, span_danger("Вы переключились в боевой режим."))
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			hud_used.action_intent.icon_state = a_intent
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, span_danger("Вы переключились в режим исцеления."))
			toggle = TRUE
	else
		to_chat(src, span_danger("Нужно быть в хозяине для переключения режимов!"))

GAME_VERB_DESC(/mob/living/simple_animal/hostile/guardian/healer, Beacon, "Установить БС-маяк", "Пометьте пол как ваш маяк, позволяя телепортировать цели на него. Ваш маяк не будет работать в небезопасных атмосферных условиях.", VERB_CATEGORY_GUARDIAN)
	if(beacon_cooldown < world.time)
		var/turf/beacon_loc = get_turf(loc)
		if(isfloorturf(beacon_loc))
			var/turf/simulated/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace receiving pad"
			F.desc = "A receiving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			to_chat(src, span_danger("Маяк установлен! Вы можете телепортировать на него вещи и людей, нажав Alt+ЛКМ"))
			if(beacon)
				beacon.ChangeTurf(/turf/simulated/floor/plating)
			beacon = F
			beacon_cooldown = world.time + default_beacon_cooldown

	else
		to_chat(src, span_danger("Ваша сила на перезарядке! Нужно дождаться ещё [max(round((beacon_cooldown - world.time)*0.1, 0.1), 0)] секунд, пока вы сможете переставить маяк."))

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(loc == summoner)
		to_chat(src, span_danger("Вы должны явить себя для телепортации вещей!"))
		return
	if(!beacon)
		to_chat(src, span_danger("Вам нужно установить маяк чтобы телепортировать вещи!"))
		return
	if(!Adjacent(A))
		to_chat(src, span_danger("Вам нужно быть рядом с целью!"))
		return
	if(A.anchored)
		to_chat(src, span_danger("Цель прикреплена к полу. Телепортация невозможна."))
		return
	to_chat(src, span_danger("Вы начинаете телепортировать [A]"))
	if(do_after(src, 5 SECONDS, A, NONE))
		if(!A.anchored)
			if(!beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				to_chat(src, span_danger("Вам нужно установить маяк чтобы телепортировать вещи!"))
				return
			var/turf/T = beacon
			if(T.is_safe())
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(A))
				do_teleport(A, beacon, 0)
				investigate_log("[key_name_log(src)] teleported [key_name_log(A)] to [COORD(beacon)].", INVESTIGATE_TELEPORTATION)
				new /obj/effect/temp_visual/guardian/phase(get_turf(A))
				return
			to_chat(src, span_danger("Маячок не в безопасном месте, нужен кислород для хозяина."))
			return
	else
		to_chat(src, span_danger("Вам нужно стоять смирно!"))

/datum/action/cooldown/spell/guardian_quickmend
	name = "Быстрое исцеление"
	desc = "Проверяет хозяина на наличие травм. Если таковые есть, лечит случайную из них. Шанс срабатывания 50%."
	button_icon_state = "heal"
	cooldown_time = 35 SECONDS
	spell_requirements = NONE
	var/chance_to_mend = 50
	var/cast_time = 50
	var/list/possible_cures = list("bleedings","fractures","infections","embedded","damaged_organs")
	var/mob/living/carbon/human/summoner = null

/datum/action/cooldown/spell/guardian_quickmend/Remove(mob/living/remove_from)
	. = ..()
	summoner = null

/datum/action/cooldown/spell/guardian_quickmend/is_valid_target(atom/cast_on)
	return target == summoner

/datum/action/cooldown/spell/guardian_quickmend/cast(atom/cast_on)
	. = ..()
	to_chat(owner, "Проверка ран хозяина..")
	if(do_after(owner, cast_time, summoner))
		if(prob(chance_to_mend))
			var/list/injures[] = list()
			injures["bleedings"] = summoner.check_internal_bleedings() + summoner.check_arterial_bleedings()
			injures["fractures"] = summoner.check_fractures()
			injures["infections"] =  summoner.check_infections()
			injures["embedded"] = summoner.check_limbs_with_embedded_objects()
			injures["damaged_organs"] = summoner.check_damaged_organs()

			var/list/available_cures = list()
			for(var/injure in injures)
				if((injures[injure]).len > 0)
					available_cures.Add(injure)
			if(!length(available_cures))
				reset_spell_cooldown()
				return FALSE
			var/random_cure = pick(available_cures)
			to_chat(owner, "Найдена травма. Попытка исцеления..")
			switch(random_cure)
				if("bleedings")
					var/obj/item/organ/external/limb = pick(injures["bleedings"])
					limb.stop_internal_bleeding()
					limb.stop_arterial_bleeding()
					limb.stop_bleeding()
					to_chat(owner, "Кровотечение остановлено.")
					return TRUE
				if("fractures")
					var/obj/item/organ/external/limb = pick(injures["fractures"])
					limb.mend_fracture()
					to_chat(owner, "Перелом зафиксирован.")
					return TRUE
				if("infections")
					var/obj/item/organ/internal/organ = pick(injures["infections"])
					organ.germ_level = 0
					to_chat(owner, "Очищено тело хозяина от инфекции.")
					return TRUE
				if("embedded")
					var/obj/item/organ/external/limb = safepick(injures["embedded"])
					var/obj/item/item = safepick(limb?.embedded_objects)
					limb?.remove_embedded_object(item)
					to_chat(owner, "Удалось вытащить застрявший предмет.")
					return TRUE
				if("damaged_organs")
					var/obj/item/organ/internal/organ = pick(injures["damaged_organs"])
					organ.damage = 0
					to_chat(owner, "Восстановлен поврежденный орган.")
					return TRUE
		else
			to_chat(owner, "Проверка окончилась неудачей.")
			return TRUE
	else
		to_chat(owner, "Нужно стоять смирно!")
		reset_spell_cooldown()
		return FALSE
