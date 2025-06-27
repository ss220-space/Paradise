/datum/martial_art/judo
	name = "Корпоративное Дзюдо"
	has_explaination_verb = TRUE
	no_baton = TRUE
	combos = list(
		/datum/martial_combo/judo/discombobulate,
		/datum/martial_combo/judo/eyepoke,
		/datum/martial_combo/judo/judothrow,
		/datum/martial_combo/judo/armbar,
		/datum/martial_combo/judo/wheelthrow,
		/datum/martial_combo/judo/goldenblast
	)
	weight = 8
	no_baton_reason = span_warning("Из-за занятий дзюдо у вас не получается крепко держать дубинку!")
	can_horizontally_grab = FALSE

//Corporate Judo Belt

/obj/item/storage/belt/security/judobelt
	name = "Пояс Корпоративного Дзюдо"
	ru_names = list(
		NOMINATIVE = "Пояс Корпоративного Дзюдо",
		GENITIVE = "Пояса Корпоративного Дзюдо",
		DATIVE = "Поясу Корпоративного Дзюдо",
		ACCUSATIVE = "Пояс Корпоративного Дзюдо",
		INSTRUMENTAL = "Поясом Корпоративного Дзюдо",
		PREPOSITIONAL = "Поясе Корпоративного Дзюдо",
	)
	desc = "Позволяет вам использовать Корпоративное Дзюдо. \
			По статистике собранной независимым исследователем, \
			владеющие этим поясом на 40% чаще покупают продукцию Мистера Чанга."
	icon = 'icons/obj/clothing/belts.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	icon_state = "judobelt"
	item_state = "judo"
	gender = MALE
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 3
	max_combined_w_class = 7
	var/datum/martial_art/judo/style


/obj/item/storage/belt/security/judobelt/Initialize(mapload)
	. = ..()
	style = new()


/obj/item/storage/belt/security/judobelt/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return

	if(slot != ITEM_SLOT_BELT)
		return

	var/mob/living/carbon/human/human = user
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(human, span_warning("Корпоративное Дзюдо может ранить других людей. Сама мысль об этом вызывает у вас отвращение!"))
		return

	style.teach(human, TRUE)
	to_chat(human, span_userdanger("Наниты в поясе наделяют вас навыками Корпоративного Дзюдо!"))
	to_chat(human, span_danger("Вы можете найти комбинации во вкладке \"Боевые искусства\"."))


/obj/item/storage/belt/security/judobelt/dropped(mob/user)
	..()
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user
	if(human.get_item_by_slot(ITEM_SLOT_BELT) != src)
		return

	style.remove(human)
	to_chat(user, span_sciradio("Вы внезапно осознаете, что не знаете как использовать Корпоративное Дзюдо..."))


//Increased harm damage
/datum/martial_art/judo/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	MARTIAL_ARTS_ACT_CHECK
	var/picked_hit_type = pick("ловко бьёт", "встаёт в стойку и резко бьёт", "проводит неожиданную атаку против")
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.apply_damage(10, BRUTE)
	playsound(get_turf(defender), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.visible_message(span_danger("[attacker] [picked_hit_type] [defender]!"), \
					span_userdanger("[attacker] [picked_hit_type] вас!"))
	add_attack_logs(attacker, defender, "Melee attacked with [src]")
	return TRUE


/datum/martial_art/judo/explaination_header(user)
	to_chat(user, "<b><i>Вы знаете Корпоративное Дзюдо.</i></b>")


/datum/martial_art/judo/explaination_footer(user)
	to_chat(user, "<b>Ваши удары руками в среднем примерно в два раза сильнее, чем у обычных представителей вашей расы.</b>")
