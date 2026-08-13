
/obj/item/melee/sickly_blade
	name = "sickly blade"
	desc = "Болезненно-зелёный клинок в форме полумесяца, украшенный реалистичным декоративным глазом. \
			Возможно даже слишком реалистичным... Стоп, он что, моргнул?"
	gender = MALE
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"
	item_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	sharp = TRUE
	force = 26
	throwforce = 35
	armour_penetration = 20
	toolspeed = 0.375
	var/demolition_mod = 0.8
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атаковал", "разрезал", "разрубил", "искромсал", "рассек")
	var/after_use_message = ""
	/// Tracks how many times attack_self() is called so that breaking a blade while in an arena has to be intentional
	var/escape_attempts = 0
	/// Timer that resets your escape_attempts back to 0
	var/escape_timer


/obj/item/melee/sickly_blade/get_ru_names()
	return alist(
		NOMINATIVE = "серповидный клинок",
		GENITIVE = "серповидного клинка",
		DATIVE = "серповидному клинку",
		ACCUSATIVE = "серповидный клинок",
		INSTRUMENTAL = "серповидным клинком",
		PREPOSITIONAL = "серповидном клинке",
	)


/obj/item/melee/sickly_blade/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_HARVESTED_SOMEBODY, PROC_REF(on_harvest))
	AddComponent(/datum/component/cleave_attack)


/obj/item/melee/sickly_blade/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_HARVESTED_SOMEBODY)
	return ..()


/obj/item/melee/sickly_blade/proc/on_harvest(obj/item/source, mob/living/carbon/human/target, mob/harvester)
	SIGNAL_HANDLER
	if(!ishuman(target))
		return

	var/skintype = target.dna.species.skinned_type
	new skintype(get_turf(target))


/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!check_usability(user))
		return

	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
	if(our_heretic?.unlimited_blades)
		. += span_notice("Ваша аура пробудилась — Обитель больше не позволит вам ломать клинки.")
		return

	. += span_notice("Вы можете разбить клинок, чтобы телепортироваться в случайное, обычно безопасное место, <b>сжав его в руке</b>.")


/// Checks if the passed mob can use this blade without being stunned
/obj/item/melee/sickly_blade/proc/check_usability(mob/living/user)
	return IS_HERETIC_OR_MONSTER(user)


/obj/item/melee/sickly_blade/pre_attackby(atom/target, mob/living/user, modifiers)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return
	if(SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_PREATTACK, target, src) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/melee/sickly_blade/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE, list/attack_modifiers)
	if(!check_usability(user))
		to_chat(user, span_danger("Вы чувствуете, как нечто инородное вторгается в ваш разум!"))
		var/mob/living/carbon/human/human_user = user
		human_user.AdjustParalysis(5 SECONDS)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/mod = issilicon(target) ? get_current_demolition_mod(user) : 1
	if(mod == 1)
		return ..()
	var/old_force = force
	force = round(force * mod)
	. = ..()
	force = old_force


/obj/item/melee/sickly_blade/proc/get_current_demolition_mod(mob/user)
	return demolition_mod


/obj/item/melee/sickly_blade/attack_obj(obj/object, mob/living/user, list/modifiers)
	var/mod = get_current_demolition_mod(user)
	if(mod == 1)
		return ..()
	var/old_force = force
	force = round(force * mod)
	. = ..()
	force = old_force


/obj/item/melee/sickly_blade/attack_self(mob/user)
	if(!HAS_TRAIT(user, TRAIT_ELDRITCH_ARENA_PARTICIPANT))
		var/datum/antagonist/heretic/our_heretic = GET_HERETIC(user)
		if(our_heretic?.unlimited_blades)
			user.balloon_alert(user, UNLINT("Обитель не даёт сломать клинок!"))
			return

		if(!HAS_TRAIT(user, TRAIT_NO_TELEPORT))
			seek_safety(user)
			return

		user.balloon_alert(user, "не телепортироваться!")
		return

	user.balloon_alert(user, "не сбежать!")
	if(escape_attempts <= 2)
		escape_attempts++
		escape_timer = addtimer(CALLBACK(src, PROC_REF(reset_attempts)), 2 SECONDS, TIMER_STOPPABLE)
		return

	to_chat(user, span_purple(span_big("Трусливые овцы будут зарезаны!")))
	playsound(src, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 70, TRUE)
	var/mob/living/carbon/human/human = user
	var/obj/item/organ/external/to_remove = ishuman(user) ? human.get_organ(human.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND) : null
	to_remove?.dismember()
	deltimer(escape_timer)
	qdel(src)
	return


/obj/item/melee/sickly_blade/proc/reset_attempts()
	escape_attempts = 0
	deltimer(escape_timer)


/// Attempts to teleport the passed mob to somewhere safe on the station, if they can use the blade.
/obj/item/melee/sickly_blade/proc/seek_safety(mob/user)
	if(!do_after(user, 0.5 SECONDS, src, timed_action_flags = DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_TARGET_LOC_CHANGE | DA_IGNORE_LYING))
		return

	var/turf/safe_turf = find_safe_turf(zlevels = z/*, extended_safety_checks = TRUE*/)
	if(!check_usability(user))
		to_chat(user, span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)]."))
		playsound(src, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 70, TRUE)
		qdel(src)
		return

	if(do_teleport(user, safe_turf, ignore_bluespace_interference = TRUE, no_effects = TRUE))
		to_chat(user, span_warning("После разбивания [declent_ru(GENITIVE)], вы чувствуете, как по вашему телу проходит поток энергии. [after_use_message]"))
	else
		to_chat(user, span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)], но ваша мольба остается без ответа."))

	playsound(src, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 70, TRUE)
	qdel(src)


/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity, list/attack_modifiers)
	if(!ismob(target))
		return

	if(proximity)
		SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)
		return

	SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, target, src)


/obj/item/melee/sickly_blade/rust
	name = "rust blade"
	desc = "Этот серповидный клинок обветшал и покрылся ржавчиной. \
			Он всё ещё опасен, способный разрывать плоть ржавыми зазубринами."
	icon_state = "rust_blade"
	item_state = "rust_blade"
	after_use_message = "Ржавые Холмы слышат ваш зов..."


/obj/item/melee/sickly_blade/rust/get_ru_names()
	return alist(
		NOMINATIVE = "ржавый клинок",
		GENITIVE = "ржавого клинка",
		DATIVE = "ржавому клинку",
		ACCUSATIVE = "ржавый клинок",
		INSTRUMENTAL = "ржавым клинком",
		PREPOSITIONAL = "ржавом клинке",
	)


/obj/item/melee/sickly_blade/ash
	name = "ash blade"
	desc = "Полурасплавленный и необработанный кусок металла, покрытый пеплом и шлаком. \
			Незаконченный, он тем не менее выглядит как нечто большее, чем он есть."
	icon_state = "ash_blade"
	item_state = "ash_blade"
	after_use_message = "Ночной Дозорный слышит ваш зов..."
	resistance_flags = FIRE_PROOF


/obj/item/melee/sickly_blade/ash/get_ru_names()
	return alist(
		NOMINATIVE = "клинок пепла",
		GENITIVE = "клинка пепла",
		DATIVE = "клинку пепла",
		ACCUSATIVE = "клинок пепла",
		INSTRUMENTAL = "клинком пепла",
		PREPOSITIONAL = "клинке пепла",
	)


/obj/item/melee/sickly_blade/flesh
	name = "flesh blade"
	desc = "Полумесяц, рожденный из изуродованной плоти существа. \
			Он постоянно чувствует боль и стремится передать свои страдания другим."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"
	after_use_message = "Маршал слышит ваш зов..."


/obj/item/melee/sickly_blade/flesh/get_ru_names()
	return alist(
		NOMINATIVE = "кровавый клинок",
		GENITIVE = "кровавого клинка",
		DATIVE = "кровавому клинку",
		ACCUSATIVE = "кровавый клинок",
		INSTRUMENTAL = "кровавым клинком",
		PREPOSITIONAL = "кровавом клинке",
	)


/obj/item/melee/sickly_blade/flesh/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/blood_walk,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)
/*
	AddComponent(
		/datum/component/bloody_spreader,\
		blood_dna = list("Alien DNA" = get_blood_type(BLOOD_TYPE_XENO)),\
	)*/


/obj/item/melee/sickly_blade/void
	name = "void blade"
	desc = "Этот клинок выкован не из металла — \
			это настоящее воплощение пустоты и хаоса."
	icon_state = "void_blade"
	item_state = "void_blade"
	after_use_message = "Аристократ слышит ваш зов..."


/obj/item/melee/sickly_blade/void/get_ru_names()
	return alist(
		NOMINATIVE = "клинок пустоты",
		GENITIVE = "клинка пустоты",
		DATIVE = "клинку пустоты",
		ACCUSATIVE = "клинок пустоты",
		INSTRUMENTAL = "клинком пустоты",
		PREPOSITIONAL = "клинке пустоты",
	)


/obj/item/melee/sickly_blade/dark
	name = "dark blade"
	desc = "Клинок доблестного воина, расколотый и исцарапанный. \
			Отметины на серебре навеки связывают его с его темным предназначением."
	icon_state = "dark_blade"
	base_icon_state = "dark_blade"
	item_state = "dark_blade"
	after_use_message = "Чемпион слышит ваш зов..."
	///If our blade is currently infused with the mansus grasp
	var/infused = FALSE
	/// Force multiplier vs objects/mechs/silicons once the wielder has Empowered Blades (tg's demolition_mod = 2.5).
	var/demolition_bonus = 2.5


/obj/item/melee/sickly_blade/dark/get_ru_names()
	return alist(
		NOMINATIVE = "повреждённый клинок",
		GENITIVE = "повреждённого клинка",
		DATIVE = "повреждённому клинку",
		ACCUSATIVE = "повреждённый клинок",
		INSTRUMENTAL = "повреждённым клинком",
		PREPOSITIONAL = "повреждённом клинке",
	)


/obj/item/melee/sickly_blade/dark/afterattack(atom/target, mob/user, proximity, list/attack_modifiers)
	. = ..()
	if(!proximity || !infused || target == user || !isliving(target))
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/living_target = target
	if(!heretic_datum)
		return

	var/datum/heretic_knowledge/limited_amount/starting/base_blade/mark_to_apply = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_blade)
	if(!mark_to_apply)
		return

	mark_to_apply.create_mark(user, living_target)

	for(var/obj/item/melee/sickly_blade/dark/to_infuse in user.get_all_contents_type(/obj/item/melee/sickly_blade/dark))
		to_infuse.infused = FALSE
		to_infuse.update_appearance(UPDATE_ICON)

	user.update_held_items()

	if(!check_behind(user, living_target))
		return
	living_target.AdjustParalysis(1.5 SECONDS)
	living_target.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	living_target.balloon_alert(user, "удар в спину!")
	playsound(living_target, 'sound/weapons/guillotine.ogg', 100, TRUE)


/obj/item/melee/sickly_blade/dark/dropped(mob/user, silent)
	. = ..()
	if(!infused)
		return

	infused = FALSE
	update_appearance(UPDATE_ICON)


/obj/item/melee/sickly_blade/dark/update_icon_state()
	. = ..()
	if(infused)
		icon_state = base_icon_state + "_infused"
		item_state = base_icon_state + "_infused"
		return

	icon_state = base_icon_state
	item_state = base_icon_state


/// Returns TRUE if the wielder is a heretic who has learned Empowered Blades.
/obj/item/melee/sickly_blade/dark/proc/wielder_has_empowered_blades(mob/user)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	return !isnull(heretic_datum?.get_knowledge(/datum/heretic_knowledge/blade_upgrade/blade))


/obj/item/melee/sickly_blade/dark/get_current_demolition_mod(mob/user)
	return wielder_has_empowered_blades(user) ? demolition_bonus : demolition_mod


/obj/item/melee/sickly_blade/cosmic
	name = "cosmic blade"
	desc = "Частица небесного резонанса, оформившаяся в клинок, сотканный из звёздного света. \
			Радужный изгнанник, прокладывающий сияющие тропы, отчаянно стремящийся к единению."
	icon_state = "cosmic_blade"
	item_state = "cosmic_blade"
	after_use_message = "Звёздный Наблюдатель слышит ваш зов..."


/obj/item/melee/sickly_blade/cosmic/get_ru_names()
	return alist(
		NOMINATIVE = "космический клинок",
		GENITIVE = "космического клинка",
		DATIVE = "космическому клинку",
		ACCUSATIVE = "космический клинок",
		INSTRUMENTAL = "космическим клинком",
		PREPOSITIONAL = "космическом клинке",
	)


/obj/item/melee/sickly_blade/lock
	name = "lock-blade"
	desc = "И клинок, и ключ. Ключ от чего? \
			Какие великие врата он открывает?"
	icon_state = "key_blade"
	item_state = "key_blade"
	after_use_message = "Стюарды слышат ваш зов..."
	tool_behaviour = TOOL_CROWBAR
	usesound = 'sound/items/crowbar.ogg'
	toolspeed = 1.3


/obj/item/melee/sickly_blade/lock/get_ru_names()
	return alist(
		NOMINATIVE = "клинок-ключ",
		GENITIVE = "клинка-ключа",
		DATIVE = "клинку-ключу",
		ACCUSATIVE = "клинок-ключ",
		INSTRUMENTAL = "клинком-ключом",
		PREPOSITIONAL = "клинке-ключе",
	)


/obj/item/melee/sickly_blade/moon
	name = "moon blade"
	desc = "Железный клинок, отражающий правду земли: однажды все присоединяются к параду. \
			Параду, приносящему радость, вызывающему улыбки на лицах людей, хотят они того или нет."
	icon_state = "moon_blade"
	item_state = "moon_blade"
	after_use_message = "Луна слышит ваш зов..."


/obj/item/melee/sickly_blade/moon/get_ru_names()
	return alist(
		NOMINATIVE = "лунный клинок",
		GENITIVE = "лунного клинка",
		DATIVE = "лунному клинку",
		ACCUSATIVE = "лунный клинок",
		INSTRUMENTAL = "лунным клинком",
		PREPOSITIONAL = "лунном клинке",
	)


/obj/item/melee/sickly_blade/moon/proc/update_pacifism_force(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(istype(human_user.neck, /obj/item/clothing/neck/heretic_focus/moon_amulet))
			force = 0
			return
	force = initial(force)


/obj/item/melee/sickly_blade/moon/equipped(mob/user, slot)
	. = ..()
	update_pacifism_force(user)


/obj/item/melee/sickly_blade/moon/dropped(mob/user)
	. = ..()
	force = initial(force)


/obj/item/melee/sickly_blade/bluespace
	name = "bluespace blade"
	desc = "Клинок, лезвие которого наполовину ушло в изнанку пространства. Там, где должен быть металл, \
			тянется цианово-синий разрыв, а сама рукоять иногда отстаёт от руки."
	icon_state = "bluespace_blade"
	base_icon_state = "bluespace_blade"
	item_state = "bluespace_blade"
	after_use_message = "Изнанка слышит ваш зов..."
	COOLDOWN_DECLARE(displacement_cooldown)


/obj/item/melee/sickly_blade/bluespace/Initialize(mapload)
	. = ..()
	qdel(GetComponent(/datum/component/cleave_attack))


/obj/item/melee/sickly_blade/bluespace/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс-клинок",
		GENITIVE = "блюспейс-клинка",
		DATIVE = "блюспейс-клинку",
		ACCUSATIVE = "блюспейс-клинок",
		INSTRUMENTAL = "блюспейс-клинком",
		PREPOSITIONAL = "блюспейс-клинке",
	)


/obj/item/melee/sickly_blade/bluespace/examine(mob/user)
	. = ..()
	if(!wielder_can_displace(user))
		return

	. += span_notice("Правым кликом по существу можно сместить предмет в его руке, а по лежащему предмету — его самого.")


/obj/item/melee/sickly_blade/bluespace/proc/wielder_can_displace(mob/user)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	return !isnull(heretic_datum?.get_knowledge(/datum/heretic_knowledge/blade_upgrade/bluespace))


/obj/item/melee/sickly_blade/bluespace/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	update_appearance(UPDATE_ICON)
	user.update_held_items()


/obj/item/melee/sickly_blade/bluespace/dropped(mob/user, silent = FALSE)
	. = ..()
	update_appearance(UPDATE_ICON)


/obj/item/melee/sickly_blade/bluespace/update_icon_state()
	. = ..()
	if(ismob(loc) && wielder_can_displace(loc))
		icon_state = base_icon_state + "_shattered"
		item_state = icon_state
		return

	icon_state = base_icon_state
	item_state = base_icon_state


/obj/item/melee/sickly_blade/bluespace/pre_attack_secondary(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(try_displace(target, user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()


/obj/item/melee/sickly_blade/bluespace/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(try_displace(interacting_with, user))
		return ITEM_INTERACT_SUCCESS
	return ..()


/obj/item/melee/sickly_blade/bluespace/proc/try_displace(atom/target, mob/living/user)
	if(!wielder_can_displace(user))
		return FALSE

	var/obj/item/displaced = target
	if(isliving(target) && target != user)
		var/mob/living/victim = target
		displaced = victim.get_active_hand()

	if(!isitem(displaced) || displaced == src)
		return FALSE

	if(!COOLDOWN_FINISHED(src, displacement_cooldown))
		balloon_alert(user, "изнанка ещё не готова!")
		return TRUE

	COOLDOWN_START(src, displacement_cooldown, 15 SECONDS)
	displaced.AddComponent(/datum/component/displaced_item, 4 SECONDS, block_pickup = TRUE)
	displaced.balloon_alert_to_viewers("предмет смещён")
	return TRUE


/obj/item/melee/sickly_blade/cursed
	name = "cursed blade"
	desc = "Тёмный клинок, обречённый вечно кровоточить. В постоянной борьбе между тьмой и \
			сверхъестественным он вынужден признать любого владельца своим хозяином. \
			С роговицы глаза на его рукояти капает кровь, но пронзительный взгляд всё равно неотрывно \
			устремлён на вас."
	force = 25
	throwforce = 15
	icon_state = "cursed_blade"
	item_state = "cursed_blade"


/obj/item/melee/sickly_blade/cursed/get_ru_names()
	return alist(
		NOMINATIVE = "проклятый клинок",
		GENITIVE = "проклятого клинка",
		DATIVE = "проклятому клинку",
		ACCUSATIVE = "проклятый клинок",
		INSTRUMENTAL = "проклятым клинком",
		PREPOSITIONAL = "проклятом клинке",
	)


/obj/item/melee/sickly_blade/cursed/Initialize(mapload)
	. = ..()

	/*var/examine_text = {"Allows the scribing of blood runes of the cult of Nar'Sie.
	The combination of eldritch power and Nar'Sie's might allows for vastly increased rune drawing speed,
	alongside the vicious strength of the blade being more powerful than usual.\n
	<b>It can also be shattered in-hand by cultists (via right-click), teleporting them to relative safety.<b>"}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text), turfs_that_boost_us = /turf) // Always fast to draw!
*/

/obj/item/melee/sickly_blade/cursed/click_alt(mob/user)
	seek_safety(user, TRUE)


/obj/item/melee/sickly_blade/cursed/seek_safety(mob/user, secondary_attack = FALSE)
	if(iscultist(user) && !secondary_attack)
		return FALSE

	return ..()


/obj/item/melee/sickly_blade/cursed/check_usability(mob/living/user)
	if(IS_HERETIC_OR_MONSTER(user) || iscultist(user))
		return TRUE

	if(prob(15))
		to_chat(user, span_cultlarge(pick("\"Нетронутый разум? Забавно.\"", "\"Полагаю, не стоит и пытаться тебя остановить.\"", "\"Валяй, мне всё равно.\"", "\"Скоро твоя душа будет моей!\"")))
		user.apply_damage(5, BURN, user.get_active_hand())
		playsound(src, 'sound/weapons/sear.ogg', 25, TRUE)
		to_chat(user, span_danger("Ваша рука шипит."))
		return TRUE

	if(!prob(15))
		return TRUE

	to_chat(user, span_big(span_purple("ДВ'НАФХ'НАХОР УН'ЕНАХ'УМГ ЕПГОКА АХ НАФЛ МГЕМПГАХ'ЕХУЕ")))
	to_chat(user, span_danger("Ужасные, непонятные высказывания заполоняют ваш разум!"))
	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 15)
	return TRUE


/obj/item/melee/sickly_blade/brass
	name = "brass blade"
	desc = "Клинок, перекованный в латунь до последнего волокна. Вместо глаза в его рукоять вживлён \
			тлеющий багровый камень, а по кромке без устали проворачиваются крохотные шестерни, \
			отсчитывая время, оставшееся его владельцу."
	force = 25
	throwforce = 15
	icon_state = "clock_blade"
	item_state = "cursed_blade"


/obj/item/melee/sickly_blade/brass/get_ru_names()
	return alist(
		NOMINATIVE = "латунный клинок",
		GENITIVE = "латунного клинка",
		DATIVE = "латунному клинку",
		ACCUSATIVE = "латунный клинок",
		INSTRUMENTAL = "латунным клинком",
		PREPOSITIONAL = "латунном клинке",
	)


/obj/item/melee/sickly_blade/brass/click_alt(mob/user)
	seek_safety(user, TRUE)


/obj/item/melee/sickly_blade/brass/seek_safety(mob/user, secondary_attack = FALSE)
	if(isclocker(user) && !secondary_attack)
		return FALSE

	return ..()


/obj/item/melee/sickly_blade/brass/check_usability(mob/living/user)
	if(IS_HERETIC_OR_MONSTER(user) || isclocker(user))
		return TRUE

	if(prob(15))
		to_chat(user, span_clocklarge(pick("\"Ещё одна шестерня в моём механизме.\"", "\"Смазка не бывает лишней.\"", "\"Твоё время сочтено, но пока можешь взять его.\"", "\"Работай, раз уж взялся.\"")))
		user.apply_damage(5, BURN, user.get_active_hand())
		playsound(src, 'sound/weapons/sear.ogg', 25, TRUE)
		to_chat(user, span_danger("Ваша рука шипит."))
		return TRUE

	if(!prob(15))
		return TRUE

	to_chat(user, span_big(span_purple("ТИК ТАК ТИК ТАК ТИК ТАК")))
	to_chat(user, span_danger("Грохот исполинских шестерён заполоняет ваш разум!"))
	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 15)
	return TRUE


/obj/item/melee/sickly_blade/cursed/equipped(mob/user, slot)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		after_use_message = "Обитель слышит ваш зов..."

	else if(iscultist(user))
		after_use_message = "[SSticker.cultdat?.entity_name] слышит ваш зов..."

	else
		after_use_message = null


/obj/item/melee/sickly_blade/cursed/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM || iswallturf(interacting_with))
		return NONE

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!heretic_datum)
		return NONE

	heretic_datum.try_draw_rune(user, interacting_with, drawing_time = 14 SECONDS)
	return ITEM_INTERACT_BLOCKING


/obj/item/melee/sickly_blade/training
	name = "training blade"
	desc = "Клинок, дарованный из жалости тем, кто не может принять истину. \
			Пусть он станет благословением в то короткое время, что он рядом с вами."
	force = 17
	armour_penetration = 0


/obj/item/melee/sickly_blade/training/get_ru_names()
	return alist(
		NOMINATIVE = "несовершенный клинок",
		GENITIVE = "несовершенного клинка",
		DATIVE = "несовершенному клинку",
		ACCUSATIVE = "несовершенный клинок",
		INSTRUMENTAL = "несовершенным клинком",
		PREPOSITIONAL = "несовершенном клинке",
	)


/obj/item/melee/sickly_blade/training/check_usability(mob/living/user)
	return TRUE
