//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	name = "Спящий Карп"
	weight = 9
	deflection_chance = 100
	reroute_deflection = TRUE
	no_guns = TRUE
	no_guns_message = "Будь как карп. Карпы не стреляют из пушек. CARP!"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/sleeping_carp/crashing_kick, /datum/martial_combo/sleeping_carp/keelhaul, /datum/martial_combo/sleeping_carp/gnashing_teeth)

/datum/martial_art/the_sleeping_carp/can_use(mob/living/carbon/human/H)
	if(H.reagents && length(H.reagents.addiction_list))
		return FALSE
	return ..()

/datum/martial_art/the_sleeping_carp/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("кусает", "пинает", "ломает", "бьет", "крушит")
	var/bonus_damage = rand(10, 15)
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>",
					  "<span class='userdanger'>[A] [atk_verb] тебя!</span>")
	if(atk_verb == "кусает")
		playsound(get_turf(D), 'sound/weapons/bite.ogg', 50, 1, -1)
	if(atk_verb == "крушит")
		playsound(get_turf(D), 'sound/weapons/pierce.ogg', 50, 1, -1)
	if(atk_verb == "пинает")
		playsound(get_turf(D), 'sound/weapons/genhit3.ogg', 50, 1, -1)
	if(atk_verb == "ломает" || atk_verb == "бьет")
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.apply_damage(bonus_damage, BRUTE, A.zone_selected)
	objective_damage(A, D, bonus_damage, BRUTE)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>Вы уходите в себя и вспоминаете учение Спящего Карпа...</i></b>")

/datum/martial_art/the_sleeping_carp/teach(mob/living/carbon/human/H, make_temporary)
	. = ..()
	if(!.)
		return FALSE
	H.faction |= "carp"// :D
	to_chat(H, "<span class='sciradio'>Вы изучили древнее боевое искусство Спящего Карпа! \
					Рукопашный бой стал намного эффективнее, а в режиме броска вы теперь можете отклонять любые снаряды, направленные в вашу сторону. \
					Однако вы также не можете использовать любое дальнобойное оружие. \
					Узнать больше о своем новом искусстве можно с помощью кнопки Show info на вкладке Martual Arts.</span>")
	H.RegisterSignal(H, COMSIG_CARBON_THROWN_ITEM_CAUGHT, TYPE_PROC_REF(/mob/living/carbon, throw_mode_on))

/datum/martial_art/the_sleeping_carp/remove(mob/living/carbon/human/H)
	. = ..()
	if(!.)
		return FALSE
	H.faction -= "carp"// :C
	H.UnregisterSignal(H, COMSIG_CARBON_THROWN_ITEM_CAUGHT)

/datum/martial_art/the_sleeping_carp/explaination_footer(user)
	to_chat(user, "<b><i>Кроме того, если при стрельбе в вас включен режим броска, вы переходите в режим активной обороны, в котором блокируете и отклоняете все выпущенные в вас снаряды!</i></b>")

/datum/martial_art/the_sleeping_carp/explaination_notice(user)
	to_chat(user, "<b><i>Шаги комбо могут быть произведены только пустой активной рукой!</i></b>")

/datum/martial_art/the_sleeping_carp/try_deflect(mob/user)
	return user.in_throw_mode && ..() // in case an admin wants to var edit carp to have less deflection chance
