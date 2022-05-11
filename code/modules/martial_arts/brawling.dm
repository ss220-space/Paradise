/datum/martial_art/boxing
	name = "Бокс"

/datum/martial_art/boxing/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>При боксировании не получается обезоруживать!</span>")
	return 1

/datum/martial_art/boxing/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	to_chat(A, "<span class='warning'>При боксировании не получается хватать!</span>")
	return 1

/datum/martial_art/boxing/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("хуком слева","хуком справа","выкидным ударом","ударом снизу","ударом сверху","размашистым ударом","обманным ударом со сменой рук","ударом слева","ударом справа","прямым панчем","панчем снизу","панчем сверху")

	var/damage = rand(5, 8) + A.dna.species.punchdamagelow
	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		D.visible_message("<span class='warning'>[A] пыта[pluralize_ru(A.gender,"ется","ются")] ударить [D] [atk_verb]!</span>")
		add_attack_logs(A, D, "Melee attacked with [src] (miss/block)", ATKLOG_ALL)
		return 0


	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)

	D.visible_message("<span class='danger'>[A] попал в [D] [atk_verb]!</span>", \
								"<span class='userdanger'>[A] попал в [D] [atk_verb]!</span>")

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	add_attack_logs(A, D, "Melee attacked with [src]", ATKLOG_ALL)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)

		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] нокаутировал [D] мощным ударом в челюсть!</span>", \
								"<span class='userdanger'>[D] нокаутирован [A] мощным ударом в челюсть!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.Weaken(3)
			D.forcesay(GLOB.hit_appends)
		else if(D.lying)
			D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/drunk_brawling
	name = "Пьяная Драка"

/datum/martial_art/drunk_brawling/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(70))
		A.visible_message("<span class='warning'>[A] попытался ухватиться за [D], но не смог!</span>", \
							"<span class='warning'>Тебе не удалось ухватиться за [D]!</span>")
		return 1
	var/obj/item/grab/G = D.grabbedby(A,1)
	var/hit_name = pick ("уши", "волосы", "нос", "голову", "плечи", "руки", "бедра", "кисти", "ляхи", "шею")
	if(G)
		D.visible_message("<span class='danger'>[A] пьяно хватает [hit_name] [D]!</span>", \
								"<span class='userdanger'>[D] попал в пьяный захват [A]! Он схватил его [hit_name]!</span>")
	return 1

/datum/martial_art/drunk_brawling/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	add_attack_logs(A, D, "Melee attacked with [src]")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("джэбом", "апперкотом", "ударом сверху", "пьяно правым хуком", "еле устояв на ногах", "с помутнением в глазах", "обеими руками", "ударами обеими ногами", "ударом головы в шею", "с помощью неловкого сальто", "пьяным ударом ногой с размаха", "крученым ударом", "техникой пьяного мастера", "пьяно левым хуком", "небрежно махая руками", "пощечиной", "пьяно выругавшись, замахнув рукой!", "коленом в живот", "и укусил его", "лбом в лоб", "навалившись всей массой своего тела", "замахнувшись снизу", "замахнувшись сверху", "замахнувшись слева", "замахнувшись справа")

	var/damage = rand(0,6)

	if(prob(20))
		A.emote("burp") //шанс что во время драки "пьяный мастер" рыгнет
		A.adjustToxLoss(-1)
		if(prob(20)) //а также шанс обрыгаться
			A.vomit(15, 0, 0, 0, 1)
			A.adjustToxLoss(-3)
	else
		if(prob(20)) //даже без отрыжки есть шанс обрыгаться, но поменьше потери нитратов
			A.vomit(10, 0, 0, 0, 1)
			A.adjustToxLoss(-2)

	if(atk_verb == "апперкотом")
		if(prob(90))
			damage = 5
		else //10% chance to do a massive amount of damage
			damage = 14

	if(atk_verb == "техникой пьяного мастера") //"и укусил его!", "лбом в лоб",
		if(prob(80))
			damage = 4
			A.emote("scream")
			D.drop_item()
		else //20% шанс внести больше урона
			A.emote("scream")
			damage = 15

	if(atk_verb == "с помощью сальто" || atk_verb == "ударом ногой с размаха") //"и укусил его!", "лбом в лоб",
		if(prob(90))
			A.Weaken(2)
		else //10% шанс успешно провести прием
			A.emote("flip")
			D.apply_damage(10, BRUTE, "head") //часть урона в голову
			damage = 8 //часть урона в тело с шансом что он анулируется

	if(atk_verb == "ударом головы в шею")
		if(prob(90))
			A.Weaken(1)
			damage = 0
		else //10% шанс успешно провести прием
			D.emote("choke")
			damage = 5
			D.AdjustLoseBreath(3)

	if(atk_verb == "и укусил его")
		damage = 4
		D.drop_item()
		D.emote("scream")

	if(atk_verb == "лбом в лоб")
		A.emote("scream")
		D.emote("scream")
		if(prob(50))
			A.apply_damage(5, BRUTE, "head")
			D.apply_damage(10, BRUTE, "head")
		else //50% шанс внести столько же урона себе
			A.apply_damage(8, BRUTE, "head")
			D.apply_damage(8, BRUTE, "head")

	if(atk_verb == "коленом в живот")
		if(prob(70))
			D.apply_damage(5, BRUTE, "body")
			D.AdjustLoseBreath(1)
		else //30% что даже выбьет дыхалку
			D.AdjustLoseBreath(2)
			D.Weaken(1)
			D.apply_damage(8, BRUTE, "body")

	if(atk_verb == "обеими ногами")
		A.Weaken(2)

	if(atk_verb == "обеими руками")
		damage = 10

	if(atk_verb == "навалившись всей массой своего тела") //просто туша бросается в сторону оппонента
		var/atom/throw_target = get_edge_target_turf(A, D.dir)
		A.throw_at(throw_target, 1, 14, A)
		A.Weaken(3)
		D.Weaken(3)

	if(prob(50)) //большой шанс что всё-таки не будет урона по причине "пьян"
		damage = 0
		D.adjustStaminaLoss(rand(0, 15)) //но зато измотает противника пытающегося понять что это пьяное рудо вытворяет


	if(!damage)
		playsound(D.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		D.visible_message("<span class='warning'>[A] попытался ударить [D] [atk_verb]!</span>")
		return 1 //returns 1 so that they actually miss and don't switch to attackhand damage

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


	D.visible_message("<span class='danger'>[A] попал в [D] [atk_verb]!</span>", \
								"<span class='userdanger'>[A] попал в [D] [atk_verb]!</span>")

	D.apply_damage(damage, BRUTE, null, armor_block)
	D.apply_effect(damage, STAMINA, armor_block)
	if(D.getStaminaLoss() > 50)
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message("<span class='danger'>[A] нокаутировал [D] мощным пьяным ударом!</span>", \
								"<span class='userdanger'>[D] нокаутирован [A] мощным пьяным ударом!</span>")
			D.apply_effect(10,WEAKEN,armor_block)
			D.Paralyse(5)
			D.forcesay(GLOB.hit_appends)
		else if(D.lying)
			D.forcesay(GLOB.hit_appends)
	return 1
