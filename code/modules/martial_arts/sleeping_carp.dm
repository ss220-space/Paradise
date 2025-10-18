//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	weight = 9
	name = "Спящий Карп"
	reroute_deflection = TRUE
	deflection_chance = 100
	can_deflect = TRUE
	no_guns = TRUE
	no_guns_message = "Использование подобного оружия обесчестит клан."
	has_explaination_verb = TRUE
	grab_speed = 2 SECONDS
	grab_resist_chances = list(
		MARTIAL_GRAB_AGGRESSIVE = 40,
		MARTIAL_GRAB_NECK = 10,
		MARTIAL_GRAB_KILL = 5,
	)
	combos = list(/datum/martial_combo/sleeping_carp/crashing_kick, /datum/martial_combo/sleeping_carp/keelhaul, /datum/martial_combo/sleeping_carp/gnashing_teeth)

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("бь[pluralize_ru(A.gender, "ёт", "ют")]", "пина[pluralize_ru(A.gender, "ет", "ют")]", "руб[pluralize_ru(A.gender, "ит", "ят")]", "забива[pluralize_ru(A.gender, "ет", "ют")]")
	D.visible_message(span_danger("[capitalize(A.declent_ru(NOMINATIVE))] [atk_verb] [D.declent_ru(ACCUSATIVE)]!"),
					span_userdanger("[A.declent_ru(NOMINATIVE)] [atk_verb] тебя!"))
	D.apply_damage(rand(10, 15), BRUTE, A.zone_selected)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>Ты фокусируешься и начинаешь вспоминать технику Спящего Карпа...</i></b>")

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary)
	. = ..()
	H.faction |= "carp"// :D
	to_chat(H, span_sciradio("Ты выучил древнюю технику Спящего Карпа! \
					Твои навыки рукопашного боя стали намного эффективнее, также ты теперь способен отражать пули и лазеры до тех пор пока хотя бы одна твоя рука свободна. \
					Однако, ты теперь не можешь пользоваться стрелковым оружием. \
					Ты можешь узнать больше о своей новоприобретенной технике, используя кнопку 'Информация о БИ' во вкладке 'Боевые Искусства'."))
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, span_warning("Овладев техникой Спящего Карпа, ты отвергаешь её наиболее жестокие учения. \
					Отражаемые тобой пули и лазеры будут направлены на землю."))

/datum/martial_art/the_sleeping_carp/remove(mob/living/carbon/human/H)
	. = ..()
	H.faction -= "carp"// :C

/datum/martial_art/the_sleeping_carp/try_deflect(mob/living/carbon/human/user)
	if(user.is_hands_free())
		deflection_chance = initial(deflection_chance)
	else if(!user.l_hand || !user.r_hand)
		deflection_chance = 50
	else if(length(user.reagents.addiction_list))
		deflection_chance = 0
	else
		deflection_chance = 0
	return ..()
