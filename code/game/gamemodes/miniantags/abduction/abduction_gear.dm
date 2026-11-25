#define COMBAT_COOLDOWN 10 SECONDS
//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "Жилет, оснащённый продвинутой технологией скрытности. Имеет два режима — боевой и скрытный."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "magnets=7;biotech=4;powerstorage=4;abductor=4"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 70, ACID = 70)
	actions_types = list(/datum/action/item_action/hands_free/activate)
	allowed = list(/obj/item/abductor, /obj/item/melee/baton, /obj/item/gun/energy, /obj/item/restraints/handcuffs)
	sprite_sheets = null
	var/mode = VEST_STEALTH
	var/stealth_active = 0
	COOLDOWN_DECLARE(combat_cooldown)
	var/datum/icon_snapshot/disguise
	var/stealth_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, BIO = 15, FIRE = 70, ACID = 70)
	var/combat_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, FIRE = 90, ACID = 90)

/obj/item/clothing/suit/armor/abductor/vest/get_ru_names()
	return alist(
		NOMINATIVE = "жилет агента",
		GENITIVE = "жилета агента",
		DATIVE = "жилету агента",
		ACCUSATIVE = "жилет агента",
		INSTRUMENTAL = "жилетом агента",
		PREPOSITIONAL = "жилете агента",
	)

/obj/item/clothing/suit/armor/abductor/vest/Initialize(mapload)
	. = ..()
	stealth_armor = getArmor(arglist(stealth_armor))
	combat_armor = getArmor(arglist(combat_armor))

/obj/item/clothing/suit/armor/abductor/vest/Destroy()
	stealth_armor = null
	combat_armor = null
	return ..()

/obj/item/clothing/suit/armor/abductor/vest/proc/toggle_nodrop()
	var/prev_has = HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(prev_has)
		REMOVE_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(ismob(loc))
		to_chat(loc, span_notice("Ваш жилет теперь [prev_has ? "разблокирован" : "заблокирован"]."))

/obj/item/clothing/suit/armor/abductor/vest/update_icon_state()
	switch(mode)
		if(VEST_STEALTH)
			icon_state = "vest_stealth"
		if(VEST_COMBAT)
			icon_state = "vest_combat"

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
	update_icon(UPDATE_ICON_STATE)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_worn_oversuit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/armor/abductor/vest/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_CLOTH_OUTER) //we only give the mob the ability to activate the vest if he's actually wearing it.
		return TRUE

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = TRUE
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(M), M.dir)
		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.cut_overlays()
		M.add_overlay(disguise.overlays)
		M.update_held_items()

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(M), M.dir)
		M.name_override = null
		M.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()
	return REFLECT_NOTHING

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click(mob/user, datum/action/action, leftclick)
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(!COOLDOWN_FINISHED(src, combat_cooldown))
			to_chat(loc, span_warning("Боевой инъектор всё ещё перезаряжаются."))
			return
		var/mob/living/carbon/human/M = loc
		M.adjustStaminaLoss(-75)
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.SetKnockdown(0)
		COOLDOWN_START(src, combat_cooldown, COMBAT_COOLDOWN)

/obj/item/clothing/suit/armor/abductor/Destroy()
	for(var/obj/machinery/abductor/console/C in SSmachines.get_by_type(/obj/machinery/abductor/console))
		if(C.vest == src)
			C.vest = null
			break
	return ..()

#undef COMBAT_COOLDOWN

/obj/item/abductor
	icon = 'icons/obj/abductor.dmi'
	abstract_type = /obj/item/abductor

/obj/item/proc/AbductorCheck(user)
	if(isabductor(user))
		return TRUE
	to_chat(user, span_warning("Вы не можете понять, как это работает!"))
	return FALSE

/obj/item/abductor/proc/ScientistCheck(user)
	if(!AbductorCheck(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	var/datum/species/abductor/S = H.dna.species
	if(S.scientist)
		return TRUE
	to_chat(user, span_warning("Вы не обучены пользоваться этим!"))
	return FALSE

/obj/item/abductor/gizmo
	name = "science tool"
	desc = "Двухрежимный инструмент для извлечения образцов и сканирования внешности. Сканирование можно проводить через камеры."
	icon_state = "gizmo_scan"
	item_state = "gizmo"
	origin_tech = "engineering=7;magnets=4;bluespace=4;abductor=3"
	var/mode = GIZMO_SCAN
	var/mob/living/marked = null
	var/obj/machinery/abductor/console/console

/obj/item/abductor/gizmo/get_ru_names()
	return alist(
		NOMINATIVE = "инструмент учёного",
		GENITIVE = "инструмента учёного",
		DATIVE = "инструменту учёного",
		ACCUSATIVE = "инструмент учёного",
		INSTRUMENTAL = "инструментом учёного",
		PREPOSITIONAL = "инструменте учёного",
	)

/obj/item/abductor/gizmo/update_icon_state()
	switch(mode)
		if(GIZMO_SCAN)
			icon_state = "gizmo_scan"
		if(GIZMO_MARK)
			icon_state = "gizmo_mark"

/obj/item/abductor/gizmo/attack_self(mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, span_warning("Устройство не подключено к консоли!"))
		return

	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
	else
		mode = GIZMO_SCAN
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("Вы переключаете устройство в режим [mode == GIZMO_SCAN ? "СКАНИРОВАНИЯ" : "МЕТКИ"]"))

/obj/item/abductor/gizmo/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ScientistCheck(user))
		return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
	if(!console)
		to_chat(user, span_warning("Устройство не подключено к консоли!"))
		return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/abductor/gizmo/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(proximity_flag)
		return
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, span_warning("Устройство не подключено к консоли!"))
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		console.AddSnapshot(target)
		to_chat(user, span_notice("Вы сканируете [target.declent_ru(ACCUSATIVE)] и добавляете [target.declent_ru(ACCUSATIVE)] в базу данных."))

/obj/item/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	if(marked == target)
		to_chat(user, span_warning("Этот образец уже помечен!"))
		return
	if(ishuman(target))
		if(isabductor(target))
			marked = target
			to_chat(user, span_notice("Вы помечаете [target.declent_ru(ACCUSATIVE)] для последующего извлечения."))
		else
			prepare(target,user)
	else
		prepare(target,user)

/obj/item/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user) > 1)
		to_chat(user, span_warning("Вам нужно находиться рядом с образцом, чтобы подготовить его к транспортировке!"))
		return
	to_chat(user, span_notice("Вы начинаете готовить [target.declent_ru(ACCUSATIVE)] к транспортировке..."))
	if(do_after(user, 10 SECONDS, target))
		marked = target
		to_chat(user, span_notice("Вы завершаете подготовку [target.declent_ru(GENITIVE)] к транспортировке."))

/obj/item/abductor/gizmo/Destroy()
	if(console)
		console.gizmo = null
	return ..()

/obj/item/abductor/silencer
	name = "abductor silencer"
	desc = "Компактное устройство для отключения средств связи."
	icon_state = "silencer"
	item_state = "silencer"
	origin_tech = "materials=4;programming=7;abductor=3"

/obj/item/abductor/silencer/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная глушилка",
		GENITIVE = "инопланетной глушилки",
		DATIVE = "инопланетной глушилке",
		ACCUSATIVE = "инопланетную глушилку",
		INSTRUMENTAL = "инопланетной глушилкой",
		PREPOSITIONAL = "инопланетной глушилке",
	)

/obj/item/abductor/silencer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isgrey(user) && !AbductorCheck(user))
		return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	radio_off(target, user)

/obj/item/abductor/silencer/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(proximity_flag)
		return
	if(!isgrey(user) && !AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/abductor/silencer/proc/radio_off(atom/target, mob/living/user)
	if(!(user in (viewers(7, target))))
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2, targloc))
		if(M == user)
			continue
		to_chat(user, span_notice("Вы глушите устройства связи [M.declent_ru(GENITIVE)]."))
		radio_off_mob(M)

/obj/item/abductor/silencer/proc/radio_off_mob(mob/living/carbon/human/M)
	var/list/all_items = M.get_all_contents()

	for(var/obj/item/radio/radio in all_items)
		radio.set_listening(FALSE) // Prevents the radio from buzzing due to the EMP, preserving possible stealthiness.
		radio.emp_act(EMP_HEAVY)

/obj/item/abductor/mind_device
	name = "mental interface device"
	desc = "Двухрежимный инструмент для прямого общения с разумными организмами. Позволяет отправить сообщение напрямую цели или отдать команду подопытному с имплантированной железой."
	icon_state = "mind_device_message"
	item_state = "silencer"
	var/mode = MIND_DEVICE_MESSAGE

/obj/item/abductor/mind_device/get_ru_names()
	return alist(
		NOMINATIVE = "устройство интерфейса мыслей",
		GENITIVE = "устройства интерфейса мыслей",
		DATIVE = "устройству интерфейса мыслей",
		ACCUSATIVE = "устройство интерфейса мыслей",
		INSTRUMENTAL = "устройством интерфейса мыслей",
		PREPOSITIONAL = "устройстве интерфейса мыслей",
	)

/obj/item/abductor/mind_device/update_icon_state()
	switch(mode)
		if(MIND_DEVICE_MESSAGE)
			icon_state = "mind_device_message"
		if(MIND_DEVICE_CONTROL)
			icon_state = "mind_device_control"

/obj/item/abductor/mind_device/attack_self(mob/user)
	if(!ScientistCheck(user))
		return

	if(mode == MIND_DEVICE_MESSAGE)
		mode = MIND_DEVICE_CONTROL
	else
		mode = MIND_DEVICE_MESSAGE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("Вы переключаете устройство в режим [mode == MIND_DEVICE_MESSAGE ? "СООБЩЕНИЯ" : "КОМАНДЫ"]"))

/obj/item/abductor/mind_device/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!ScientistCheck(user))
		return

	switch(mode)
		if(MIND_DEVICE_CONTROL)
			mind_control(target, user)
		if(MIND_DEVICE_MESSAGE)
			mind_message(target, user)

/obj/item/abductor/mind_device/proc/mind_control(atom/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/organ/internal/heart/gland/G = C.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(!istype(G))
			to_chat(user, span_warning("У вашей цели нет экспериментальной железы!"))
			return
		if(!G.mind_control_uses)
			to_chat(user, span_warning("Железа вашей цели истощена!"))
			return
		if(G.active_mind_control)
			to_chat(user, span_warning("Ваша цель уже находится под влиянием контроля мыслей!"))
			return

		var/command = tgui_input_text(user, "Введите команду, которую должна выполнить цель. Осталось использований: [G.mind_control_uses], длительность: [DisplayTimeText(G.mind_control_duration)]", "Введите команду")

		if(!command)
			return

		if(QDELETED(user) || user.get_active_hand() != src || loc != user)
			return

		if(QDELETED(G))
			return

		G.mind_control(command, user)
		to_chat(user, span_notice("Вы отправляете команду своей цели."))

/obj/item/abductor/mind_device/proc/mind_message(atom/target, mob/living/user)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(user, span_warning("Ваша цель мертва!"))
			return
		var/message = tgui_input_text(user, "Напишите сообщение для отправки в мозг цели.", "Введите сообщение")
		if(!message)
			return
		if(QDELETED(L) || L.stat == DEAD)
			return

		to_chat(L, "[span_italics("Вы слышите голос в своей голове:")] [span_abductor(message)]")
		to_chat(user, span_notice("Вы отправляете сообщение своей цели."))
		add_say_logs(user, message, L, "Mind device")

/obj/item/gun/energy/alien
	name = "alien pistol"
	desc = "Сложное оружие, стреляющее лучами высокоинтенсивной радиации."
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	restricted_species = list(/datum/species/abductor, /datum/species/grey)
	icon_state = "alienpistol"
	item_state = "alienpistol"
	origin_tech = "combat=4;magnets=7;powerstorage=3;abductor=3"
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	selfcharge = TRUE

/obj/item/gun/energy/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный пистолет",
		GENITIVE = "инопланетного пистолета",
		DATIVE = "инопланетному пистолету",
		ACCUSATIVE = "инопланетный пистолет",
		INSTRUMENTAL = "инопланетным пистолетом",
		PREPOSITIONAL = "инопланетном пистолете",
	)

/obj/item/paper/abductor
	name = "Dissection Guide"
	icon_state = "alienpaper_words"
	default_raw_text = "<b>Dissection for Dummies</b><br> \
	<br> \
	1. Добудьте свежий образец.<br> \
	2. Положите образец на операционный стол.<br> \
	3. Приложите скальпель к груди, готовясь к экспериментальному вскрытию.<br> \
	4. Приложите скальпель к торсу образца.<br> \
	5. Зажмите кровотечения на торсе образца гемостатом.<br> \
	6. Оттяните кожу торса образца ретрактором.<br> \
	7. Пропилите торс образца пилой.<br> \
	8. Снова приложите ретрактор к торсу образца.<br> \
	9. Поищите руками в торсе образца, чтобы удалить лишние органы.<br> \
	10. Вставьте заменяющую железу (возьмите одну из хранилища желёз).<br> \
	11. Нанесите костяной гель, чтобы восстановить грудную клетку.<br> \
	12. Используйте костоправ, чтобы завершить восстановление грудной клетки.<br> \
	13. Ещё раз нанесите костяной гель, чтобы восстановить грудную клетку.<br> \
	14. Прижгите торс пациента.<br> \
	15. Подумайте о том, чтобы одеть образец обратно, чтобы не нарушать среду обитания.<br> \
	16. Поместите образец в аппарат для экспериментов.<br> \
	17. Выберите один из вариантов эксперимента. Цель будет проанализирована и телепортирована в выбранную точку сброса.<br> \
	18. Вы получите один кредит снабжения, а субъект будет засчитан в вашу квоту.<br> \
	<br> \
	Поздравляем! Теперь вы обучены инвазивным ксенобиологическим исследованиям!"

/obj/item/paper/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "руководство по вскрытию",
		GENITIVE = "руководства по вскрытию",
		DATIVE = "руководству по вскрытию",
		ACCUSATIVE = "руководство по вскрытию",
		INSTRUMENTAL = "руководством по вскрытию",
		PREPOSITIONAL = "руководстве по вскрытию",
	)

/obj/item/paper/abductor/update_icon_state()
	return

/obj/item/paper/abductor/click_alt()
	return NONE

#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/melee/baton/abductor
	name = "advanced baton"
	desc = "Дубинка с четырьмя режимами для обезвреживания и сдерживания образцов."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wonderprodStun"
	item_state = "wonderprod"
	origin_tech = "materials=4;combat=4;biotech=7;abductor=4"
	force = 7
	affect_cyborg = TRUE
	affect_bots = TRUE
	cooldown = 0 SECONDS
	stamina_damage = 0
	knockdown_time = 14 SECONDS
	allows_stun_in_harm = TRUE
	on_stun_sound = 'sound/weapons/egloves.ogg'
	actions_types = list(/datum/action/item_action/toggle_mode)
	var/mode = BATON_STUN

/obj/item/melee/baton/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "продвинутая дубинка",
		GENITIVE = "продвинутой дубинки",
		DATIVE = "продвинутой дубинке",
		ACCUSATIVE = "продвинутую дубинку",
		INSTRUMENTAL = "продвинутой дубинкой",
		PREPOSITIONAL = "продвинутой дубинке",
	)

/obj/item/melee/baton/abductor/get_stun_description(mob/living/target, mob/living/user)
	return // chat messages are handled in their own procs.

/obj/item/melee/baton/abductor/get_cyborg_stun_description(mob/living/target, mob/living/user)
	return // same as above.

/obj/item/melee/baton/abductor/attack_self(mob/living/user)
	. = ..()
	toggle(user)

/obj/item/melee/baton/abductor/proc/toggle(mob/living/user = usr)
	if(!isgrey(user) && !AbductorCheck(user))
		return
	mode = (mode + 1) % BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "оглушение"
		if(BATON_SLEEP)
			txt = "усыпление"
		if(BATON_CUFF)
			txt = "связывание"
		if(BATON_PROBE)
			txt = "зондирование"

	var/is_stun_mode = (mode == BATON_STUN)
	var/is_stun_or_sleep = (mode == BATON_STUN) || (mode == BATON_SLEEP)

	affect_cyborg = is_stun_mode
	affect_bots = is_stun_mode
	log_stun_attack = is_stun_mode // other modes have their own log entries.
	skip_harm_attack = !is_stun_or_sleep
	stun_animation = is_stun_or_sleep
	on_stun_sound = is_stun_or_sleep ? 'sound/weapons/egloves.ogg' : null

	to_chat(user, span_notice("Вы переключаете дубинку в режим: [txt]."))
	update_icon(UPDATE_ICON_STATE)

/obj/item/melee/baton/abductor/update_icon_state()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"
	update_equipped_item(update_speedmods = FALSE)

/obj/item/melee/baton/abductor/examine(mob/user)
	. = ..()
	if(!isgrey(user) && !AbductorCheck(user))
		return .
	switch(mode)
		if(BATON_STUN)
			. += span_warning("Дубинка находится в режиме оглушения.")
		if(BATON_SLEEP)
			. += span_warning("Дубинка находится в режиме усыпления.")
		if(BATON_CUFF)
			. += span_warning("Дубинка находится в режиме связывания.")
		if(BATON_PROBE)
			. += span_warning("Дубинка находится в режиме зондирования.")

/obj/item/melee/baton/abductor/baton_attack(mob/target, mob/living/user)
	if(!isgrey(user) && !AbductorCheck(user))
		return BATON_ATTACK_DONE
	return ..()

/obj/item/melee/baton/abductor/baton_effect(mob/living/carbon/target, mob/living/user, stun_override)
	switch(mode)
		if(BATON_STUN)
			StunAttack(target, user)
		if(BATON_SLEEP)
			SleepAttack(target,user)
		if(BATON_CUFF)
			CuffAttack(target,user)
		if(BATON_PROBE)
			ProbeAttack(target,user)

/obj/item/melee/baton/abductor/proc/StunAttack(mob/living/carbon/target, mob/living/user)
	target.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] оглуша[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]!"),
		span_userdanger("[DECLENT_RU_CAP(user, NOMINATIVE)] оглуша[PLUR_ET_YUT(user)] вас с помощью [declent_ru(GENITIVE)]!"),
	)
	target.AdjustJitter(40 SECONDS, bound_upper = 40 SECONDS)
	target.AdjustStuttering(16 SECONDS, bound_upper = 16 SECONDS)
	target.AdjustConfused(10 SECONDS, bound_upper = 10 SECONDS)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	if(iscarbon(target))
		target.shock_internal_organs(33)
	target.Weaken(knockdown_time)

/obj/item/melee/baton/abductor/proc/SleepAttack(mob/living/target, mob/living/user)
	if(INCAPACITATED_IGNORING(target, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB))
		target.visible_message(
			span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] усыпля[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]!"),
			span_userdanger("Вас внезапно одолевает сильная сонливость!"),
		)
		playsound(src, on_stun_sound, 50, TRUE, -1)
		target.Sleeping(2 MINUTES)
		add_attack_logs(user, target, "put to sleep with [src]")
		return

	target.AdjustDrowsy(2 SECONDS)
	to_chat(user, span_warning("Усыпление полностью работает только на оглушённых образцах!"))
	target.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] пыта[PLUR_ET_YUT(user)]ся усыпить [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]!"),
		span_userdanger("Вас внезапно одолевает сонливость!"),
	)
/obj/item/melee/baton/abductor/proc/CuffAttack(mob/living/carbon/target, mob/living/user)
	if(!iscarbon(target))
		return
	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		to_chat(user, span_warning("У [target.declent_ru(GENITIVE)] нет рук!"))
		return
	if(target.handcuffed)
		to_chat(user, span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] уже в наручниках!"))
		return
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	target.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] начина[PLUR_ET_YUT(user)] сковывать [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]!"),
		span_userdanger("[DECLENT_RU_CAP(user, NOMINATIVE)] начина[PLUR_ET_YUT(user)] формировать энергетическое поле вокруг ваших рук!"),
	)
	if(do_after(user, 3 SECONDS, target, NONE))
		if(target.handcuffed || !target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
			return
		target.apply_restraints(new /obj/item/restraints/handcuffs/cable/zipties/used(null), ITEM_SLOT_HANDCUFFED, TRUE)
		to_chat(user, span_notice("Вы сковываете [target.declent_ru(ACCUSATIVE)]."))
		add_attack_logs(user, target, "handcuffed ([src])")
	else
		to_chat(user, span_warning("Вам не удалось сковать [target.declent_ru(ACCUSATIVE)]!"))

/obj/item/melee/baton/abductor/proc/ProbeAttack(mob/living/carbon/human/target, mob/living/user)
	target.visible_message(
		span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] зондиру[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]!"),
		span_userdanger("[DECLENT_RU_CAP(user, NOMINATIVE)] зондиру[PLUR_ET_YUT(user)] вас!"),
	)

	var/species = span_warning("Неизвестный вид")
	var/helptext = span_warning("Вид непригоден для экспериментов.")

	if(ishuman(target))
		species = span_notice("<b>[target.dna.species.name]</b>")
		if(ischangeling(target))
			species = span_warning("Генокрад")
		if(target.get_int_organ(/obj/item/organ/internal/heart/gland))
			helptext = span_warning("Обнаружена экспериментальная железа!")
		else
			if(target.get_organ_slot(INTERNAL_ORGAN_HEART))
				helptext = span_notice("Субъект пригоден для экспериментов.")
			else
				helptext = span_warning("Субъект непригоден для экспериментов.")

	to_chat(user, "[span_notice("Результат зондирования:")] [species]")
	to_chat(user, "[helptext]")

#undef BATON_STUN
#undef BATON_SLEEP
#undef BATON_CUFF
#undef BATON_PROBE
#undef BATON_MODES

/obj/item/restraints/handcuffs/energy
	name = "hard-light energy field"
	desc = "Поле твёрдого света, сковывающее руки."
	icon_state = "cuff_white" // Needs sprite
	breakout_time = 450
	trashtype = /obj/item/restraints/handcuffs/energy/used
	origin_tech = "materials=4;magnets=5;abductor=2"

/obj/item/restraints/handcuffs/energy/get_ru_names()
	return alist(
		NOMINATIVE = "энергетическое поле твёрдого света",
		GENITIVE = "энергетического поля твёрдого света",
		DATIVE = "энергетическому полю твёрдого света",
		ACCUSATIVE = "энергетическое поле твёрдого света",
		INSTRUMENTAL = "энергетическим полем твёрдого света",
		PREPOSITIONAL = "энергетическом поле твёрдого света",
	)

/obj/item/restraints/handcuffs/energy/used
	desc = "энергетический разряд"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/used/dropped(mob/user, slot, silent = FALSE)
	user.visible_message(span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)], сковывающее [user.declent_ru(ACCUSATIVE)], разрывается с энергетическим разрядом!"), \
							span_userdanger("[DECLENT_RU_CAP(user, NOMINATIVE)], сковывающее [user.declent_ru(ACCUSATIVE)], разрывается с энергетическим разрядом!"))
	do_sparks(4, FALSE, user.loc)
	return ..()

/obj/item/radio/headset/abductor
	name = "alien headset"
	desc = "Продвинутая инопланетная гарнитура для прослушивания связи человеческих космических станций. Зачем у неё микрофон? Никто не знает."
	item_flags = BANGPROTECT_MINOR
	origin_tech = "magnets=2;abductor=3"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "abductor_headset"
	item_state = "abductor_headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная гарнитура",
		GENITIVE = "инопланетной гарнитуры",
		DATIVE = "инопланетной гарнитуре",
		ACCUSATIVE = "инопланетную гарнитуру",
		INSTRUMENTAL = "инопланетной гарнитурой",
		PREPOSITIONAL = "инопланетной гарнитуре",
	)

/obj/item/radio/headset/abductor/Initialize(mapload)
	. = ..()
	make_syndie() // Why the hell is this a proc why cant it just be a subtype

/obj/item/radio/headset/abductor/screwdriver_act()
	return // Stops humans from disassembling abductor headsets.

/obj/item/scalpel/alien
	name = "alien scalpel"
	desc = "Сияющий острый нож из серебристо-зелёного металла."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/scalpel/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный скальпель",
		GENITIVE = "инопланетного скальпеля",
		DATIVE = "инопланетному скальпелю",
		ACCUSATIVE = "инопланетный скальпель",
		INSTRUMENTAL = "инопланетным скальпелем",
		PREPOSITIONAL = "инопланетном скальпеле",
	)

/obj/item/hemostat/alien
	name = "alien hemostat"
	desc = "Вы такого раньше не видели."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/hemostat/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный гемостат",
		GENITIVE = "инопланетного гемостата",
		DATIVE = "инопланетному гемостату",
		ACCUSATIVE = "инопланетный гемостат",
		INSTRUMENTAL = "инопланетным гемостатом",
		PREPOSITIONAL = "инопланетном гемостате",
	)

/obj/item/retractor/alien
	name = "alien retractor"
	desc = "Вы не уверены, что хотите, чтобы завеса была приоткрыта."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/retractor/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный ретрактор",
		GENITIVE = "инопланетного ретрактора",
		DATIVE = "инопланетному ретрактору",
		ACCUSATIVE = "инопланетный ретрактор",
		INSTRUMENTAL = "инопланетным ретрактором",
		PREPOSITIONAL = "инопланетном ретракторе",
	)

/obj/item/circular_saw/alien
	name = "alien saw"
	desc = "Неужели инопланетяне тоже теряют это и им приходится искать инопланетный топорик?"
	icon = 'icons/obj/abductor.dmi'
	item_state = "alien_saw"
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/circular_saw/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная пила",
		GENITIVE = "инопланетной пилы",
		DATIVE = "инопланетной пиле",
		ACCUSATIVE = "инопланетную пилу",
		INSTRUMENTAL = "инопланетной пилой",
		PREPOSITIONAL = "инопланетной пиле",
	)

/obj/item/surgicaldrill/alien
	name = "alien drill"
	desc = "Возможно, инопланетные хирурги наконец нашли применение дрели."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/surgicaldrill/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная дрель",
		GENITIVE = "инопланетной дрели",
		DATIVE = "инопланетной дрели",
		ACCUSATIVE = "инопланетную дрель",
		INSTRUMENTAL = "инопланетной дрелью",
		PREPOSITIONAL = "инопланетной дрели",
	)

/obj/item/cautery/alien
	name = "alien cautery"
	desc = "Зачем бескровным инопланетянам инструмент для остановки кровотечения? Если только..."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/cautery/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный прижигатель",
		GENITIVE = "инопланетного прижигателя",
		DATIVE = "инопланетному прижигателю",
		ACCUSATIVE = "инопланетный прижигатель",
		INSTRUMENTAL = "инопланетным прижигателем",
		PREPOSITIONAL = "инопланетном прижигателе",
	)

/obj/item/bonegel/alien
	name = "alien bone gel"
	desc = "Пахнет скотчем."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonegel/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный костяной гель",
		GENITIVE = "инопланетного костяного геля",
		DATIVE = "инопланетному костяному гелю",
		ACCUSATIVE = "инопланетный костяной гель",
		INSTRUMENTAL = "инопланетным костяным гелем",
		PREPOSITIONAL = "инопланетном костяном геле",
	)

/obj/item/FixOVein/alien
	name = "alien FixOVein"
	desc = "Бескровные инопланетяне точно знают, как остановить внутреннее кровотечение... правда?"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/FixOVein/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный гель для сосудов",
		GENITIVE = "инопланетного геля для сосудов",
		DATIVE = "инопланетному гелю для сосудов",
		ACCUSATIVE = "инопланетный гель для сосудов",
		INSTRUMENTAL = "инопланетным гелем для сосудов",
		PREPOSITIONAL = "инопланетном геле для сосудов",
	)

/obj/item/bonesetter/alien
	name = "alien bone setter"
	desc = "Вы не уверены, хотите ли знать, есть ли у инопланетян кости."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonesetter/alien/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный костоправ",
		GENITIVE = "инопланетного костоправа",
		DATIVE = "инопланетному костоправу",
		ACCUSATIVE = "инопланетный костоправ",
		INSTRUMENTAL = "инопланетным костоправом",
		PREPOSITIONAL = "инопланетном костоправе",
	)

/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Похищай со стилем — шипастым стилем. Предотвращает цифровое отслеживание."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	blockTracking = 1
	origin_tech = "materials=7;magnets=4;abductor=3"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

/obj/item/clothing/head/helmet/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "шлем агента",
		GENITIVE = "шлема агента",
		DATIVE = "шлему агента",
		ACCUSATIVE = "шлем агента",
		INSTRUMENTAL = "шлемом агента",
		PREPOSITIONAL = "шлеме агента",
	)

// Operating Table / Beds / Lockers

/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "Выглядит похоже на земные устройства. Неужели инопланетяне крадут наши технологии?"
	icon = 'icons/obj/abductor.dmi'
	buildstacktype = /obj/item/stack/sheet/mineral/abductor

/obj/structure/bed/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "устройство для отдыха",
		GENITIVE = "устройства для отдыха",
		DATIVE = "устройству для отдыха",
		ACCUSATIVE = "устройство для отдыха",
		INSTRUMENTAL = "устройством для отдыха",
		PREPOSITIONAL = "устройстве для отдыха",
	)

/obj/structure/table_frame/abductor
	name = "alien table frame"
	desc = "Прочный каркас стола из инопланетного сплава."
	icon_state = "alien_frame"
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1
	density = TRUE

/obj/structure/table_frame/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный каркас стола",
		GENITIVE = "инопланетного каркаса стола",
		DATIVE = "инопланетному каркасу стола",
		ACCUSATIVE = "инопланетный каркас стола",
		INSTRUMENTAL = "инопланетным каркасом стола",
		PREPOSITIONAL = "инопланетном каркасе стола",
	)

/obj/structure/table_frame/abductor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/alien_material = istype(I, /obj/item/stack/sheet/mineral/abductor)
	if(alien_material || istype(I, /obj/item/stack/sheet/mineral/silver))
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/mineral = I
		if(mineral.get_amount() < 1)
			to_chat(user, span_warning("Вам нужен один лист [mineral.declent_ru(GENITIVE)], чтобы сделать это!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы начинаете добавлять [mineral.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]..."))
		if(!do_after(user, 5 SECONDS * mineral.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(mineral) || !mineral.use(1))
			return ATTACK_CHAIN_PROCEED
		var/obj/new_table
		if(alien_material)
			new_table = new /obj/structure/table/abductor(loc)
		else
			new_table = new /obj/machinery/optable/abductor(loc)
		to_chat(user, span_notice("Вы завершили строительство [new_table.declent_ru(GENITIVE)]."))
		transfer_fingerprints_to(new_table)
		new_table.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/structure/table/abductor
	name = "alien table"
	desc = "Продвинутая технология плоских поверхностей в действии!"
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	icon_state = "alien_table"
	can_be_flipped = FALSE
	buildstack = /obj/item/stack/sheet/mineral/abductor
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1
	base_icon_state = "alien_table"
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_TABLES
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_TABLES
	frame = /obj/structure/table_frame/abductor

/obj/structure/table/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный стол",
		GENITIVE = "инопланетного стола",
		DATIVE = "инопланетному столу",
		ACCUSATIVE = "инопланетный стол",
		INSTRUMENTAL = "инопланетным столом",
		PREPOSITIONAL = "инопланетном столе",
	)

/obj/machinery/optable/abductor
	name = "alien operating table"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	no_icon_updates = 1 //no icon updates for this; it's static.
	injected_reagents = list(/datum/reagent/medicine/corazone, /datum/reagent/medicine/spaceacillin)
	reagent_target_amount = 31 //the patient needs at least 30u of spaceacillin to prevent necrotization.
	inject_amount = 10

/obj/machinery/optable/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный операционный стол",
		GENITIVE = "инопланетного операционного стола",
		DATIVE = "инопланетному операционному столу",
		ACCUSATIVE = "инопланетный операционный стол",
		INSTRUMENTAL = "инопланетным операционным столом",
		PREPOSITIONAL = "инопланетном операционном столе",
	)

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Содержит секреты вселенной."
	icon_state = "abductor"
	material_drop = /obj/item/stack/sheet/mineral/abductor
	material_drop_amount = 1

/obj/structure/closet/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный шкафчик",
		GENITIVE = "инопланетного шкафчика",
		DATIVE = "инопланетному шкафчику",
		ACCUSATIVE = "инопланетный шкафчик",
		INSTRUMENTAL = "инопланетным шкафчиком",
		PREPOSITIONAL = "инопланетном шкафчике",
	)

/obj/structure/door_assembly/door_assembly_abductor
	name = "alien airlock assembly"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	base_name = "alien airlock"
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/abductor
	material_type = /obj/item/stack/sheet/mineral/abductor
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный незавершенный шлюз",
		GENITIVE = "инопланетного незавершенного шлюза",
		DATIVE = "инопланетному незавершенному шлюзу",
		ACCUSATIVE = "инопланетный незавершенный шлюз",
		INSTRUMENTAL = "инопланетным незавершенным шлюзом",
		PREPOSITIONAL = "инопланетном незавершенном шлюзе",
	)

/obj/item/reagent_containers/applicator/abductor
	name = "alien mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Выполнено из прочного инопланетного материала."
	origin_tech = "materials=2;biotech=3;abductor=2"
	icon_state = "alien_mender_empty"
	item_state = "alien_mender"
	icon = 'icons/obj/abductor.dmi'
	greyscale_config = null
	greyscale_colors = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_belt = null
	ignore_flags = TRUE
	obj_flags = parent_type::obj_flags|EMAGGED
	var/base_icon = "alien_mender_brute"

/obj/item/reagent_containers/applicator/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный авто-мендер",
		GENITIVE = "инопланетного авто-мендера",
		DATIVE = "инопланетному авто-мендеру",
		ACCUSATIVE = "инопланетный авто-мендер",
		INSTRUMENTAL = "инопланетным авто-мендером",
		PREPOSITIONAL = "инопланетном авто-мендере",
	)

/obj/item/reagent_containers/applicator/abductor/update_icon_state()
	var/reag_pct = round((reagents.total_volume / volume) * 100)
	switch(reag_pct)
		if(51 to 100)
			icon_state = "[base_icon]_full[applying ? "_active" : ""]"
		if(1 to 50)
			icon_state = "[base_icon][applying ? "_active" : ""]"
		if(0)
			icon_state = "[base_icon][applying ? "_empty" : ""]"

/obj/item/reagent_containers/applicator/abductor/brute
	name = "alien brute mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия — для заживления механических повреждений. Выполнено из прочного инопланетного материала."
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 200)

/obj/item/reagent_containers/applicator/abductor/brute/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный авто-мендер (Мех. Повреждения)",
		GENITIVE = "инопланетного авто-мендера (Мех. Повреждения)",
		DATIVE = "инопланетному авто-мендеру (Мех. Повреждения)",
		ACCUSATIVE = "инопланетный авто-мендер (Мех. Повреждения)",
		INSTRUMENTAL = "инопланетным авто-мендером (Мех. Повреждения)",
		PREPOSITIONAL = "инопланетном авто-мендере (Мех. Повреждения)",
	)

/obj/item/reagent_containers/applicator/abductor/burn
	name = "alien burn mender"
	desc = "Небольшое электронное устройство, предназначенное для местного применения лекарственных препаратов. Эта версия — для заживления термических повреждений. Выполнено из прочного инопланетного материала."
	base_icon = "alien_mender_burn"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 200)

/obj/item/reagent_containers/applicator/abductor/burn/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный авто-мендер (Терм. Повреждения)",
		GENITIVE = "инопланетного авто-мендера (Терм. Повреждения)",
		DATIVE = "инопланетному авто-мендеру (Терм. Повреждения)",
		ACCUSATIVE = "инопланетный авто-мендер (Терм. Повреждения)",
		INSTRUMENTAL = "инопланетным авто-мендером (Терм. Повреждения)",
		PREPOSITIONAL = "инопланетном авто-мендере (Терм. Повреждения)",
	)

/obj/item/reagent_containers/applicator/abductor/industrial //пока виталя не отрефакторил менднеры будет находиться в абдукторсих итемах ибо тут код по лучше
	name = "industrial auto-mender"
	desc = "Прототип улучшенного авто-мендера, созданного компанией \"Вита-пром\" как альтернатива стандартным мендерам \"Нанотрейзен\". \
	Обладает увеличенным объёмом хранилища веществ и возможностью пробивать плотные материалы. Не попал в серийное производство из-за сложности и дороговизны, но всё ещё встречается на рынке в качестве единичных экземплеров."
	volume = 500
	list_reagents = list(/datum/reagent/medicine/synthflesh = 500)
	icon_state = "mender2_empty"
	item_state = "mender2"
	base_icon = "mender2"
	obj_flags = parent_type::obj_flags & ~EMAGGED

/obj/item/reagent_containers/applicator/abductor/industrial/get_ru_names()
	return alist(
		NOMINATIVE = "продвинутый авто-мендер",
		GENITIVE = "продвинутого авто-мендера",
		DATIVE = "продвинутому авто-мендеру",
		ACCUSATIVE = "продвинутый авто-мендер",
		INSTRUMENTAL = "продвинутым авто-мендером",
		PREPOSITIONAL = "продвинутом авто-мендере",
	)

/obj/item/reagent_containers/cup/bottle/abductor
	name = "alien bottle"
	desc = "Прочная бутылка, сделанная из инопланетного материала."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=4"
	icon_state = "alien_bottle"
	item_state = "alien_bottle"
	volume = 50

/obj/item/reagent_containers/cup/bottle/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка",
		GENITIVE = "инопланетной бутылки",
		DATIVE = "инопланетной бутылке",
		ACCUSATIVE = "инопланетную бутылку",
		INSTRUMENTAL = "инопланетной бутылкой",
		PREPOSITIONAL = "инопланетной бутылке",
	)

/obj/item/reagent_containers/cup/bottle/abductor/rezadone
	name = "rezadone bottle"
	list_reagents = list(/datum/reagent/medicine/rezadone = 50)

/obj/item/reagent_containers/cup/bottle/abductor/rezadone/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка (Резадон)",
		GENITIVE = "инопланетной бутылки (Резадон)",
		DATIVE = "инопланетной бутылке (Резадон)",
		ACCUSATIVE = "инопланетную бутылку (Резадон)",
		INSTRUMENTAL = "инопланетной бутылкой (Резадон)",
		PREPOSITIONAL = "инопланетной бутылке (Резадон)",
	)

/obj/item/reagent_containers/cup/bottle/abductor/epinephrine
	name = "epinephrine bottle"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/cup/bottle/abductor/epinephrine/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка (Эпинефрин)",
		GENITIVE = "инопланетной бутылки (Эпинефрин)",
		DATIVE = "инопланетной бутылке (Эпинефрин)",
		ACCUSATIVE = "инопланетную бутылку (Эпинефрин)",
		INSTRUMENTAL = "инопланетной бутылкой (Эпинефрин)",
		PREPOSITIONAL = "инопланетной бутылке (Эпинефрин)",
	)

/obj/item/reagent_containers/cup/bottle/abductor/salgu
	name = "saline-glucose solution bottle"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 50)

/obj/item/reagent_containers/cup/bottle/abductor/salgu/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка (Физиологический раствор)",
		GENITIVE = "инопланетной бутылки (Физиологический раствор)",
		DATIVE = "инопланетной бутылке (Физиологический раствор)",
		ACCUSATIVE = "инопланетную бутылку (Физиологический раствор)",
		INSTRUMENTAL = "инопланетной бутылкой (Физиологический раствор)",
		PREPOSITIONAL = "инопланетной бутылке (Физиологический раствор)",
	)

/obj/item/reagent_containers/cup/bottle/abductor/oculine
	name = "oculine bottle"
	list_reagents = list(/datum/reagent/medicine/oculine = 50)

/obj/item/reagent_containers/cup/bottle/abductor/oculine/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка (Окулин)",
		GENITIVE = "инопланетной бутылки (Окулин)",
		DATIVE = "инопланетной бутылке (Окулин)",
		ACCUSATIVE = "инопланетную бутылку (Окулин)",
		INSTRUMENTAL = "инопланетной бутылкой (Окулин)",
		PREPOSITIONAL = "инопланетной бутылке (Окулин)",
	)

/obj/item/reagent_containers/cup/bottle/abductor/pen_acid
	name = "pentetic acid bottle"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 50)

/obj/item/reagent_containers/cup/bottle/abductor/pen_acid/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная бутылка (Пентетовая кислота)",
		GENITIVE = "инопланетной бутылки (Пентетовая кислота)",
		DATIVE = "инопланетной бутылке (Пентетовая кислота)",
		ACCUSATIVE = "инопланетную бутылку (Пентетовая кислота)",
		INSTRUMENTAL = "инопланетной бутылкой (Пентетовая кислота)",
		PREPOSITIONAL = "инопланетной бутылке (Пентетовая кислота)",
	)

/obj/item/healthanalyzer/abductor
	name = "alien health analyzer"
	desc = "Ручной сканер тела, способный определить жизненные показатели субъекта. Выполнен из прочного инопланетного материала."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=4;biotech=4;abductor=2"
	advanced = TRUE
	icon_state = "alien_hscanner"
	item_state = "alien_hscanner"
	theme = "abductor"

/obj/item/healthanalyzer/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный анализатор здоровья",
		GENITIVE = "инопланетного анализатора здоровья",
		DATIVE = "инопланетному анализатору здоровья",
		ACCUSATIVE = "инопланетный анализатор здоровья",
		INSTRUMENTAL = "инопланетным анализатором здоровья",
		PREPOSITIONAL = "инопланетном анализаторе здоровья",
	)

/obj/item/storage/firstaid_abductor
	name = "alien medkit"
	desc = "Набор с продвинутыми инопланетными лекарствами. Держите подальше от инопланетных детей."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien_medkit"
	item_state = "alien_medkit"
	throw_range = 8

/obj/item/storage/firstaid_abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная аптечка",
		GENITIVE = "инопланетной аптечки",
		DATIVE = "инопланетной аптечке",
		ACCUSATIVE = "инопланетную аптечку",
		INSTRUMENTAL = "инопланетной аптечкой",
		PREPOSITIONAL = "инопланетной аптечке",
	)

/obj/item/storage/firstaid_abductor/populate_contents()
	new /obj/item/reagent_containers/applicator/abductor/brute(src)
	new /obj/item/reagent_containers/applicator/abductor/burn(src)
	new /obj/item/reagent_containers/cup/bottle/abductor/rezadone(src)
	new /obj/item/reagent_containers/cup/bottle/abductor/epinephrine(src)
	new /obj/item/reagent_containers/cup/bottle/abductor/salgu(src)
	new /obj/item/reagent_containers/cup/bottle/abductor/oculine(src)
	new /obj/item/reagent_containers/cup/bottle/abductor/pen_acid(src)

/obj/item/clothing/gloves/abductor_agent
	name = "high-tech insulated gloves"
	desc = "Похоже, эти перчатки защищают владельца от удара током."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gloves_agent"
	item_state = "abductor_gloves_agent"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/abductor_agent/get_ru_names()
	return alist(
		NOMINATIVE = "высокотехнологичные изолированные перчатки",
		GENITIVE = "высокотехнологичных изолированных перчаток",
		DATIVE = "высокотехнологичным изолированным перчаткам",
		ACCUSATIVE = "высокотехнологичные изолированные перчатки",
		INSTRUMENTAL = "высокотехнологичными изолированными перчатками",
		PREPOSITIONAL = "высокотехнологичных изолированных перчатках",
	)

/obj/item/clothing/gloves/abductor_science
	name = "high-tech science gloves"
	desc = "Высокотехнологичные стерильные перчатки, прочнее латекса."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gloves_science"
	item_state = "abductor_gloves_science"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	resistance_flags = NONE

/obj/item/clothing/gloves/abductor_science/get_ru_names()
	return alist(
		NOMINATIVE = "высокотехнологичные научные перчатки",
		GENITIVE = "высокотехнологичных научных перчаток",
		DATIVE = "высокотехнологичным научным перчаткам",
		ACCUSATIVE = "высокотехнологичные научные перчатки",
		INSTRUMENTAL = "высокотехнологичными научными перчатками",
		PREPOSITIONAL = "высокотехнологичных научных перчатках",
	)

/obj/item/mop/advanced/abductor
	name = "alien mop"
	desc = "Складная швабра, явно используемая инопланетянами для зачистки любых следов близкого контакта. Головка постоянно выделяет воду при проведении по поверхности, словно из ниоткуда."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "mop_abductor"
	mopcap = 100
	origin_tech = "materials=3;engineering=3;abductor=2"
	refill_rate = 50
	mopspeed = 10
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)

/obj/item/mop/advanced/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная швабра",
		GENITIVE = "инопланетной швабры",
		DATIVE = "инопланетной швабре",
		ACCUSATIVE = "инопланетную швабру",
		INSTRUMENTAL = "инопланетной шваброй",
		PREPOSITIONAL = "инопланетной швабре",
	)

/obj/item/soap/syndie/abductor
	name = "alien soap"
	desc = "Даже бескровным инопланетянам нужно смывать грязь. Пахнет порохом."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "soap_abductor"

/obj/item/soap/syndie/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетное мыло",
		GENITIVE = "инопланетного мыла",
		DATIVE = "инопланетному мылу",
		ACCUSATIVE = "инопланетное мыло",
		INSTRUMENTAL = "инопланетным мылом",
		PREPOSITIONAL = "инопланетном мыле",
	)

/obj/item/lightreplacer/bluespace/abductor
	name = "alien light replacer"
	desc = "Важно поддерживать работу всех загадочных огней на НЛО во время полёта над глухой провинцией."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "lightreplacer_abductor"
	origin_tech = "magnets=3;engineering=4;abductor=2"
	max_uses = 40
	uses = 20
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)

/obj/item/lightreplacer/bluespace/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный заменитель ламп",
		GENITIVE = "инопланетного заменителя ламп",
		DATIVE = "инопланетному заменителю ламп",
		ACCUSATIVE = "инопланетный заменитель ламп",
		INSTRUMENTAL = "инопланетным заменителем ламп",
		PREPOSITIONAL = "инопланетном заменителе ламп",
	)

/obj/item/melee/flyswatter/abductor
	name = "alien flyswatter"
	desc = "Для убийства инопланетных насекомых, очевидно."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "flyswatter_abductor"
	origin_tech = "abductor=1"
	force = 2 // Twice as powerful thanks to alien technology!
	throwforce = 2
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500, MAT_DIAMOND = 1000)

/obj/item/melee/flyswatter/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетная мухобойка",
		GENITIVE = "инопланетной мухобойки",
		DATIVE = "инопланетной мухобойке",
		ACCUSATIVE = "инопланетную мухобойку",
		INSTRUMENTAL = "инопланетной мухобойкой",
		PREPOSITIONAL = "инопланетной мухобойке",
	)

/obj/item/reagent_containers/spray/cleaner/safety/abductor	// Essentially an Advanced Space Cleaner, but abductor-themed. For the implant.
	name = "alien space cleaner"
	desc = "Инопланетный флакон-распылитель с не пенящимся космическим очистителем инопланетного бренда! Принимает только космический очиститель."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cleaner_abductor"
	volume = 500
	list_reagents = list(/datum/reagent/space_cleaner = 500)

/obj/item/reagent_containers/spray/cleaner/safety/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный космический очиститель",
		GENITIVE = "инопланетного космического очистителя",
		DATIVE = "инопланетному космическому очистителю",
		ACCUSATIVE = "инопланетный космический очиститель",
		INSTRUMENTAL = "инопланетным космическим очистителем",
		PREPOSITIONAL = "инопланетном космическом очистителе",
	)

/obj/item/storage/belt/janitor/abductor
	name = "alien janibelt"
	desc = "Пояс для хранения чистящих средств не от мира сего! Используется абдукторами для поддержания чистоты на своих кораблях."
	icon_state = "janibelt_abductor"
	item_state = "security"
	storage_slots = 7
	can_hold = list(
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/holosign_creator/janitor,
		/obj/item/melee/flyswatter,
		/obj/item/storage/bag/trash,
		/obj/item/door_remote/janikeyring,
		/obj/item/mop/advanced/abductor,
	)

/obj/item/storage/belt/janitor/abductor/get_ru_names()
	return alist(
		NOMINATIVE = "инопланетный пояс уборщика",
		GENITIVE = "инопланетного пояса уборщика",
		DATIVE = "инопланетному поясу уборщика",
		ACCUSATIVE = "инопланетный пояс уборщика",
		INSTRUMENTAL = "инопланетным поясом уборщика",
		PREPOSITIONAL = "инопланетном поясе уборщика",
	)

/obj/item/storage/belt/janitor/abductor/full/populate_contents()
	new /obj/item/mop/advanced/abductor(src)
	new /obj/item/soap/syndie/abductor(src)
	new /obj/item/lightreplacer/bluespace/abductor(src)
	new /obj/item/storage/bag/trash/bluespace(src)
	new /obj/item/melee/flyswatter/abductor(src)
	new /obj/item/reagent_containers/spray/cleaner/safety/abductor(src)
	new /obj/item/holosign_creator/janitor(src)
