/datum/martial_combo/mr_chang/stunning_discounts
	name = "Сногсшибательные скидки!"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_GRAB)
	explaination_text = "Бросок через плечо. Цель не сможет встать в течение следующих четырех секунд."

/datum/martial_combo/mr_chang/stunning_discounts/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	var/mob/living/carbon/human/T = target
	if(!istype(T))
		return MARTIAL_COMBO_FAIL

	if(target.body_position == LYING_DOWN)
		return MARTIAL_COMBO_FAIL

	user.visible_message(span_warning("[user] броса[pluralize_ru(user.gender,"ет", "ют")] [target] через плечо!"))
	target.forceMove(user.loc)
	target.Knockdown(4 SECONDS)
	user.SpinAnimation(10,1)
	target.SpinAnimation(10,1)
	add_attack_logs(user, target, "Melee attacked with martial-art [src]: Stunning discounts!", ATKLOG_ALL)
	var/msg = pick("Сногсшиб+ательные ск+идки!", "От ск+идок кр+угом голов+а!", "Предлож+ение — хоть стой, хоть п+адай!", \
				"Пол тоже прода+ётся!", "С вас 350000 кред+итов!", "Вы за это запл+атите!")
	user.say(msg)

	var/sound = pick('sound/weapons/mr_chang/mr_chang_1.mp3', 'sound/weapons/mr_chang/mr_chang_2.mp3', \
					'sound/weapons/mr_chang/mr_chang_3.mp3', 'sound/weapons/mr_chang/mr_chang_4.mp3', \
					'sound/weapons/mr_chang/mr_chang_5.mp3')
	playsound(get_turf(user), sound, 50, TRUE, -1)
	return MARTIAL_COMBO_DONE

