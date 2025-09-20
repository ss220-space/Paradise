
/obj/item/melee/sickly_blade
	name = "серповидный клинок"
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
	//obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	sharp = TRUE
	force = 30
	throwforce = 35
	armour_penetration = 20
	//wound_bonus = 5
	//bare_wound_bonus = 15
	toolspeed = 0.375
	//demolition_mod = 0.8
	hitsound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 35
	//attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb = list("атакует", "режет", "рубит", "крамсает", "царапает", "разрывает", "сечёт")
	var/after_use_message = ""
	/// Tracks how many times attack_self() is called so that breaking a blade while in an arena has to be intentional
	var/escape_attempts = 0
	/// Timer that resets your escape_attempts back to 0
	var/escape_timer


/obj/item/melee/sickly_blade/get_ru_names()
	return list(
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


/obj/item/melee/sickly_blade/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_ITEM_HARVESTED_SOMEBODY)


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

	. += span_notice("Вы можете разбить клинок, чтобы телепортироваться в случайное, обычно безопасное место, <b>сжав его в руке</b>.")


/// Checks if the passed mob can use this blade without being stunned
/obj/item/melee/sickly_blade/proc/check_usability(mob/living/user)
	return IS_HERETIC_OR_MONSTER(user)


/obj/item/melee/sickly_blade/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE, list/attack_modifiers)
	if(check_usability(user))
		return ..()

	to_chat(user, span_danger("Вы чувствуете, как нечто инородное вторгается в ваш разум!"))
	var/mob/living/carbon/human/human_user = user
	human_user.AdjustParalysis(5 SECONDS)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/melee/sickly_blade/attack_self(mob/user)
	if(!HAS_TRAIT(user, TRAIT_ELDRITCH_ARENA_PARTICIPANT))
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
	var/obj/item/organ/external/to_remove = human.get_organ(human.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	to_remove.dismember()
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
		playsound(src, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
		qdel(src)
		return

	if(do_teleport(user, safe_turf))
		to_chat(user, span_warning("После разбивания [declent_ru(GENITIVE)], вы чувствуете, как по вашему телу проходит поток энергии. [after_use_message]"))
	else
		to_chat(user, span_warning("Вы разбиваете [declent_ru(ACCUSATIVE)], но ваша мольба остается без ответа."))

	playsound(src, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)


/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity, list/attack_modifiers)
	if(!ismob(target))
		return

	if(proximity)
		SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)
		return

	SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, target, src)


// Path of Rust's blade
/obj/item/melee/sickly_blade/rust
	name = "ржавый клинок"
	desc = "Этот серповидный клинок обветшал и покрывается ржавчиной. \
			Он всё ещё опасен, способный разрывать плоть ржавыми зазубринами."
	icon_state = "rust_blade"
	item_state = "rust_blade"
	after_use_message = "Ржавые Холмы слышат ваш зов..."


/obj/item/melee/sickly_blade/rust/get_ru_names()
	return list(
		NOMINATIVE = "ржавый клинок",
		GENITIVE = "ржавого клинка",
		DATIVE = "ржавому клинку",
		ACCUSATIVE = "ржавый клинок",
		INSTRUMENTAL = "ржавым клинком",
		PREPOSITIONAL = "ржавом клинке",
	)


// Path of Ash's blade
/obj/item/melee/sickly_blade/ash
	name = "клинок пепла"
	desc = "Полурасплавленный и необработанный, кусок металла, покрытый в пеплом и шлаком. \
			Незаконченный, он выглядит как нечто большее, чем он есть."
	icon_state = "ash_blade"
	item_state = "ash_blade"
	after_use_message = "Ночной Дозорный слышит ваш зов..."
	resistance_flags = FIRE_PROOF


/obj/item/melee/sickly_blade/ash/get_ru_names()
	return list(
		NOMINATIVE = "клинок пепла",
		GENITIVE = "клинка пепла",
		DATIVE = "клинку пепла",
		ACCUSATIVE = "клинок пепла",
		INSTRUMENTAL = "клинком пепла",
		PREPOSITIONAL = "клинке пепла",
	)


// Path of Flesh's blade
/obj/item/melee/sickly_blade/flesh
	name = "кровавый клинок"
	desc = "Полумесяц, рожденный из изуродованной плоти существа. \
			Он постоянно чувствует боль и стремится передать свои страдания другим."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"
	after_use_message = "Маршал слышит ваш зов..."


/obj/item/melee/sickly_blade/flesh/get_ru_names()
	return list(
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


// Path of Void's blade
/obj/item/melee/sickly_blade/void
	name = "клинок пустоты"
	desc = "Этот клинок, не состоит из какого-либо материала. \
			Это настоящее воплощение пустоты и хаоса."
	icon_state = "void_blade"
	item_state = "void_blade"
	after_use_message = "Аристократ слышит ваш зов..."


/obj/item/melee/sickly_blade/void/get_ru_names()
	return list(
		NOMINATIVE = "клинок пустоты",
		GENITIVE = "клинка пустоты",
		DATIVE = "клинку пустоты",
		ACCUSATIVE = "клинок пустоты",
		INSTRUMENTAL = "клинком пустоты",
		PREPOSITIONAL = "клинке пустоты",
	)


// Path of the Blade's... blade.
// Opting for /dark instead of /blade to avoid "sickly_blade/blade".
/obj/item/melee/sickly_blade/dark
	name = "повреждённый клинок"
	desc = "Клинок доблестного война, расколотый и разорванный. \
			Царапины на серебре навеки связывают его с темной целью."
	icon_state = "dark_blade"
	base_icon_state = "dark_blade"
	item_state = "dark_blade"
	after_use_message = "Чемпион слышит ваш зов..."
	///If our blade is currently infused with the mansus grasp
	var/infused = FALSE


/obj/item/melee/sickly_blade/dark/get_ru_names()
	return list(
		NOMINATIVE = "повреждённый клинок",
		GENITIVE = "повреждённого клинка",
		DATIVE = "повреждённому клинку",
		ACCUSATIVE = "повреждённый клинок",
		INSTRUMENTAL = "повреждённым клинком",
		PREPOSITIONAL = "повреждённом клинке",
	)


/obj/item/melee/sickly_blade/dark/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!infused || target == user || !isliving(target))
		return

	var/datum/antagonist/heretic/heretic_datum = isheretic(user)
	var/mob/living/living_target = target
	if(!heretic_datum)
		return

	//Apply our heretic mark
	var/datum/heretic_knowledge/mark/blade_mark/mark_to_apply = heretic_datum.get_knowledge(/datum/heretic_knowledge/mark/blade_mark)
	if(!mark_to_apply)
		return

	mark_to_apply.create_mark(user, living_target)

	//Remove the infusion from any blades we own (and update their sprite)
	for(var/obj/item/melee/sickly_blade/dark/to_infuse in user.get_all_contents_type(/obj/item/melee/sickly_blade/dark))
		to_infuse.infused = FALSE
		to_infuse.update_appearance(UPDATE_ICON)

	//user.update_held_items()

	if(!check_behind(user, living_target))
		return
	// We're officially behind them, apply effects
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


// Path of Cosmos's blade
/obj/item/melee/sickly_blade/cosmic
	name = "космический клинок"
	desc = "Частица небесного резонанса, оформившаяся в клинок сотканный из звёздного света. \
			Радужный изгнанник, прокладывающий сияющие тропы, отчаянно стремящийся к единению."
	icon_state = "cosmic_blade"
	item_state = "cosmic_blade"
	after_use_message = "Звёздный Глашатай слышит ваш зов..."


/obj/item/melee/sickly_blade/cosmic/get_ru_names()
	return list(
		NOMINATIVE = "космический клинок",
		GENITIVE = "космического клинка",
		DATIVE = "космическому клинку",
		ACCUSATIVE = "космический клинок",
		INSTRUMENTAL = "космическим клинком",
		PREPOSITIONAL = "космическом клинке",
	)


// Path of Knock's blade
/obj/item/melee/sickly_blade/lock
	name = "клинок - ключ"
	desc = "И клинок и ключ. Ключ от чего? \
			Какие великие врата он открывает?"
	icon_state = "key_blade"
	item_state = "key_blade"
	after_use_message = "Стюарды слышат ваш зов..."
	tool_behaviour = TOOL_CROWBAR
	usesound = 'sound/items/crowbar.ogg'
	toolspeed = 1.3


/obj/item/melee/sickly_blade/lock/get_ru_names()
	return list(
		NOMINATIVE = "клинок - ключ",
		GENITIVE = "клинка - ключа",
		DATIVE = "клинку - ключу",
		ACCUSATIVE = "клинок - ключ",
		INSTRUMENTAL = "клинком - ключом",
		PREPOSITIONAL = "клинке - ключе",
	)


// Path of Moon's blade
/obj/item/melee/sickly_blade/moon
	name = "лунный клинок"
	desc = "Железный клинок, отражающий правду земли: однажды все присоединяются к параду. \
			Параду, приносящему радость, вызывающему улыбки на лицах людей, хотят они того или нет."
	icon_state = "moon_blade"
	item_state = "moon_blade"
	after_use_message = "Луна слышит ваш зов..."


/obj/item/melee/sickly_blade/moon/get_ru_names()
	return list(
		NOMINATIVE = "лунный клинок",
		GENITIVE = "лунного клинка",
		DATIVE = "лунному клинку",
		ACCUSATIVE = "лунный клинок",
		INSTRUMENTAL = "лунным клинком",
		PREPOSITIONAL = "лунном клинке",
	)


// Path of Nar'Sie's blade
// What!? This blade is given to cultists as an altar item when they sacrifice a heretic.
// It is also given to the heretic themself if they sacrifice a cultist.
/obj/item/melee/sickly_blade/cursed
	name = "проклятый клинок"
	desc = "Тёмный клинок, обречённый вечно кровоточить. В постоянной борьбе между тьмой и \
			сверхъестественным он вынужден признать любого владельца своим хозяином. \
			С роговицы глаза на его рукояти капает кровь, но пронзительный взгляд всё равно неотрывно \
			устремлён на вас."
	force = 25
	throwforce = 15
	block_chance = 35
	//wound_bonus = 25
	//bare_wound_bonus = 15
	icon_state = "cursed_blade"
	item_state = "cursed_blade"


/obj/item/melee/sickly_blade/cursed/get_ru_names()
	return list(
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
		to_chat(user, span_danger("Ваша рука шипит.")) // Nar nar might not care but their essence still doesn't like you
		return TRUE

	if(!prob(15))
		return TRUE

	to_chat(user, span_big(span_purple("ДВ'НАФХ'НАХОР УН'ЕНАХ'УМГ ЕПГОКА АХ НАФЛ МГЕМПГАХ'ЕХУЕ")))
	to_chat(user, span_danger("Ужасные, непонятные высказывания заполоняют ваш разум!"))
	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 15) // This can kill you if you ignore it
	return TRUE


/obj/item/melee/sickly_blade/cursed/equipped(mob/user, slot)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		after_use_message = "Мансус слышит ваш зов..."

	else if(iscultist(user))
		after_use_message = "[SSticker.cultdat?.entity_name] слышит ваш зов..."

	else
		after_use_message = null


/obj/item/melee/sickly_blade/cursed/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return NONE

	// Can only carve runes with it if off combat mode.
	if(iswallturf(target) || user.a_intent == INTENT_HARM)
		return NONE

	heretic_datum.try_draw_rune(user, target, drawing_time = 14 SECONDS) // Faster than pen, slower than cicatrix
	return ATTACK_CHAIN_BLOCKED


// Weaker blade variant given to people so they can participate in the heretic arena spell
/obj/item/melee/sickly_blade/training
	name = "несовершенный клинок"
	desc = "Клинок, дарованный из жалости тем, кто не может принять истину. \
			Пусть он станет благословением в то короткое время, что он рядом с вами."
	force = 17
	armour_penetration = 0


/obj/item/melee/sickly_blade/training/get_ru_names()
	return list(
		NOMINATIVE = "несовершенный клинок",
		GENITIVE = "несовершенного клинка",
		DATIVE = "несовершенному клинку",
		ACCUSATIVE = "несовершенный клинок",
		INSTRUMENTAL = "несовершенным клинком",
		PREPOSITIONAL = "несовершенном клинке",
	)


/obj/item/melee/sickly_blade/training/check_usability(mob/living/user)
	return TRUE // If you can hold this, you can use it
