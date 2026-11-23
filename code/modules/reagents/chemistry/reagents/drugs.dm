/datum/reagent/lithium
	name = "Литий"
	id = "lithium"
	description = "Химический элемент."
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "металла"
	chemfiresupp = TRUE
	intensitymod = 0.15
	burncolor = "#ff356f"
	burncolormod = 5
	properties = list(PROPERTY_OXIDIZING = 1)

/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if((M.mobility_flags & MOBILITY_MOVE) && !HAS_TRAIT(M, TRAIT_RESTRAINED))
			step(M, pick(GLOB.cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	return ..()

/datum/reagent/lsd
	name = "Диэтиламид лизергиновой кислоты"
	id = "lsd"
	description = "Сильнодействующее галлюциногенное вещество, также известное как \"ЛСД\". Чуваааак."
	reagent_state = LIQUID
	color = "#0000D8"
	taste_description = "магического путешествия"

/datum/reagent/lsd/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	M.AdjustHallucinate(10 SECONDS)
	M.last_hallucinator_log = "LSD"
	return ..() | update_flags

/datum/reagent/space_drugs
	name = "Космо-дурь"
	id = "space_drugs"
	description = "Запрещенное химическое соединение, используемое в качестве наркотика."
	reagent_state = LIQUID
	color = "#9087A2"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	addiction_chance = 15
	addiction_threshold = 10
	heart_rate_decrease = 1
	taste_description = "синтетического кайфа"

/datum/reagent/space_drugs/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if((M.mobility_flags & MOBILITY_MOVE) && !HAS_TRAIT(M, TRAIT_RESTRAINED))
			step(M, pick(GLOB.cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	return ..() | update_flags

/datum/reagent/psilocybin
	name = "Псилоцибин"
	id = "psilocybin"
	description = "Сильный психотропный препарат, получаемый из некоторых видов грибов."
	color = "#E700E7" // rgb: 231, 0, 231
	taste_description = "видений"

/datum/reagent/psilocybin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(60 SECONDS)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(2 SECONDS)
			M.Dizzy(10 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(2 SECONDS)
			M.Jitter(20 SECONDS)
			M.Dizzy(20 SECONDS)
			M.Druggy(70 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(2 SECONDS)
			M.Jitter(40 SECONDS)
			M.Dizzy(40 SECONDS)
			M.Druggy(80 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/nicotine
	name = "Никотин"
	id = "nicotine"
	description = "Немного уменьшает время оглушения. При передозировке отравляет и сбивает дыхание."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 35
	addiction_chance = 3
	addiction_threshold = 160
	minor_addiction = TRUE
	heart_rate_increase = 1
	taste_description = "спокойствия"

/datum/reagent/nicotine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/smoke_message = pick("Вы чувствуете себя расслабленным.", "Вы чувствуете умиротворение.", "Вы чувствуете себя менее напряжённо.", "Вы чувствуете себя спокойнее.")
	M.AdjustParalysis(-2 SECONDS)
	M.AdjustStunned(-2 SECONDS)
	M.AdjustWeakened(-2 SECONDS)
	if(prob(5))
		to_chat(M, span_notice("[smoke_message]"))
	return ..() | update_flags

/datum/reagent/nicotine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message(span_warning("[M] выгляд[PLUR_IT_YAT(M)] нервн[GEND_YM_OI_YM_YMI(M)]!"))
			M.AdjustConfused(30 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			M.Jitter(20 SECONDS)
			M.emote("twitch_s")
		else if(effect <= 4)
			M.visible_message(span_warning("[M] в поту!"))
			M.adjust_bodytemperature(rand(15,30))
			update_flags |= M.adjustToxLoss(3, FALSE)
		else if(effect <= 7)
			update_flags |= M.adjustToxLoss(4, FALSE)
			M.emote("twitch")
			M.Jitter(20 SECONDS)
	else if(severity == 2)
		if(effect <= 2)
			M.emote("gasp")
			to_chat(M, span_warning("Вам трудно дышать!"))
			update_flags |= M.adjustOxyLoss(15, FALSE)
			update_flags |= M.adjustToxLoss(3, FALSE)
			M.Stun(2 SECONDS)
		else if(effect <= 4)
			to_chat(M, span_warning("Вы чувствуете себя отвратно!"))
			M.emote("drool")
			M.Jitter(20 SECONDS)
			update_flags |= M.adjustToxLoss(5, FALSE)
			M.Weaken(2 SECONDS)
			M.AdjustConfused(66 SECONDS)
		else if(effect <= 7)
			M.emote("collapse")
			to_chat(M, span_warning("Ваше сердце едва ли не выскакивает из груди!"))
			SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
			M.Paralyse(10 SECONDS)
			M.Jitter(60 SECONDS)
			update_flags |= M.adjustToxLoss(6, FALSE)
			update_flags |= M.adjustOxyLoss(20, FALSE)
	return list(effect, update_flags)

/datum/reagent/nicotine/handle_addiction(mob/living/M, consumption_rate)
	if(HAS_TRAIT(M, TRAIT_BADASS))
		return

	return ..()

/datum/reagent/moonlin
	name = "Мунлин"
	id = "moonlin"
	description = "Гранулированный порошок, состоящий из мелких белых кристаллов, который добывают из растения \"Мунлайт\", растущего на побережьях и в дельтах рек Адомая."
	reagent_state = LIQUID
	color = "#5ec3cc" // rgb: 96, 165, 132
	drink_icon = "moonlight_d"
	drink_name = "Мунлин"
	drink_desc = "Странный напиток с белыми кристаллами! Будьте внимательны, если вы таяран!"
	overdose_threshold = 20
	addiction_chance = 20
	addiction_threshold = 15
	shock_reduction = 30
	minor_addiction = TRUE
	heart_rate_increase = 1
	taste_description = "мятного онемения во рту"

/datum/reagent/moonlin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/smoke_message = pick("Вы чувствуете себя оцепеневшим.", "Вы чувствуете себя спокойным.")
	if(prob(5))
		to_chat(M, span_notice("[smoke_message]"))
	M.AdjustJitter(-50 SECONDS)
	switch(current_cycle)
		if(1 to 35)
			if(prob(7))
				M.emote("yawn")
		if(36 to 70)
			M.Drowsy(20 SECONDS)
		if(71 to INFINITY)
			M.Paralyse(20 SECONDS)
			M.Drowsy(20 SECONDS)
	return ..() | update_flags

/datum/reagent/moonlin/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message(span_warning("[M] выгляд[PLUR_IT_YAT(M)] нервн[GEND_YM_OI_YM_YMI(M)]!"))
			M.AdjustConfused(35 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			M.Jitter(20 SECONDS)
			M.emote("twitch_s")
		else if(effect <= 4)
			M.visible_message(span_warning("[M] в поту!"))
			M.adjust_bodytemperature(rand(15,30))
			update_flags |= M.adjustToxLoss(3, FALSE)
		else if(effect <= 7)
			update_flags |= M.adjustToxLoss(4, FALSE)
			M.emote("twitch")
			M.Jitter(20 SECONDS)
	else if(severity == 2)
		if(effect <= 2)
			M.emote("gasp")
			to_chat(M, span_warning("Вам трудно дышать!"))
			update_flags |= M.adjustToxLoss(3, FALSE)
			M.Stun(2 SECONDS)
		else if(effect <= 4)
			to_chat(M, span_warning("Вы чувствуете себя отвратно!"))
			M.emote("drool")
			M.Jitter(20 SECONDS)
			update_flags |= M.adjustToxLoss(4, FALSE)
			M.Weaken(2 SECONDS)
			M.AdjustConfused(66 SECONDS)
		else if(effect <= 7)
			M.emote("collapse")
			to_chat(M, span_warning("Ваше сердце едва ли не выскакивает из груди!"))
			SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
			M.Paralyse(10 SECONDS)
			M.Jitter(60 SECONDS)
			update_flags |= M.adjustToxLoss(4, FALSE)
	return list(effect, update_flags)
/datum/reagent/crank
	name = "Крэнк"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	taste_description = "bitterness"

/datum/reagent/crank/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustParalysis(-4 SECONDS)
	M.AdjustStunned(-4 SECONDS)
	M.AdjustWeakened(-4 SECONDS)
	M.AdjustKnockdown(-4 SECONDS)
	if(prob(15))
		M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
	if(prob(8))
		to_chat(M, span_notice("Вы чувствуете себя отлично!"))
		M.reagents.add_reagent(/datum/reagent/methamphetamine, rand(1,2))
		M.emote(pick("laugh", "giggle"))
	if(prob(6))
		to_chat(M, span_notice("Вы чувствуете тепло!"))
		M.adjust_bodytemperature(rand(1,10))
	if(prob(4))
		to_chat(M, span_notice("Вы чувствуете себя хреново!"))
		update_flags |= M.adjustToxLoss(1, FALSE)
		M.AdjustJitter(60 SECONDS)
		M.emote(pick("groan", "moan"))
	return ..() | update_flags

/datum/reagent/crank/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message(span_warning("[M] выгляд[PLUR_ET_YUT(M)] потерянно!"))
			M.AdjustConfused(40 SECONDS)
			M.Jitter(40 SECONDS)
			M.emote("scream")
		else if(effect <= 4)
			M.visible_message(span_warning("[M] в поту!"))
			M.adjust_bodytemperature(rand(5,30))
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.adjustToxLoss(1, FALSE)
			M.Stun(4 SECONDS)
		else if(effect <= 7)
			M.Jitter(60 SECONDS)
			M.emote("grumble")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] поте[PLUR_ET_YUT(M)] как свинья!"))
			M.adjust_bodytemperature(rand(20,100))
			update_flags |= M.adjustToxLoss(5, FALSE)
			M.Stun(6 SECONDS)
		else if(effect <= 4)
			M.visible_message(span_warning("[M] тряс[PLUR_YOT_YUT(M)]ся как эпилептик!"))
			M.Jitter(200 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(8, FALSE)
			M.Weaken(6 SECONDS)
			M.AdjustConfused(50 SECONDS)
			M.emote("scream")
			M.reagents.add_reagent(/datum/reagent/jagged_crystals, 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message(span_warning("[M] нервно скреб[PLUR_YOT_YUT(M)] свою кожу!"))
			M.Jitter(20 SECONDS)
			update_flags |= M.adjustBruteLoss(5, FALSE)
			M.emote("twitch_s")
	return list(effect, update_flags)

/datum/reagent/krokodil
	name = "Дезоморфин"
	id = "krokodil"
	description = "Кустарно произведённый наркотик, популярный в бедных секторах СССП."
	reagent_state = LIQUID
	color = "#0264B4"
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 10
	taste_description = "дешёвой советской дури"

/datum/reagent/krokodil/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-80 SECONDS)
	if(prob(25))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	if(prob(15))
		M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
	if(prob(10))
		to_chat(M, span_notice("Вы чувствуете себя спокойным!"))
		M.adjust_bodytemperature(-1)
		M.emote("smile")
	if(prob(5))
		to_chat(M, span_notice("Вы чувствуете себя слишком спокойным!"))
		M.emote(pick("yawn", "drool"))
		M.Stun(2 SECONDS)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustBrainLoss(1, FALSE)
		M.adjust_bodytemperature(-20)
	if(prob(2))
		to_chat(M, span_warning("Ваша кожа сухая как пустыня! Она трескается!"))
		update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/krokodil/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message(span_warning("[M] выгляд[PLUR_IT_YAT(M)] потерянно!"))
			M.Stun(6 SECONDS)
			M.emote("drool")
		else if(effect <= 4)
			M.emote("shiver")
			M.adjust_bodytemperature(-40)
		else if(effect <= 7)
			to_chat(M, span_warning("Ваша кожа сухая как пустыня! Она трескается!"))
			update_flags |= M.adjustBruteLoss(5, FALSE)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.emote("cry")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] кача[PLUR_ET_YUT(M)]ся и вал[PLUR_IT_YAT(M)]ся на землю!"))
			update_flags |= M.adjustToxLoss(3, FALSE)
			update_flags |= M.adjustBrainLoss(3, FALSE)
			M.Weaken(16 SECONDS)
			M.emote("faint")
		else if(effect <= 4)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.visible_message(span_warning("С [M] падают куски сгнившей кожи!"))
				update_flags |= H.adjustBruteLoss(25, FALSE)
				H.emote("scream")
				H.ChangeToHusk()
				H.emote("faint")
		else if(effect <= 7)
			M.emote("shiver")
			M.adjust_bodytemperature(-70)
	return list(effect, update_flags)

/datum/reagent/methamphetamine
	name = "Метамфетамин"
	id = "methamphetamine"
	description = "Метамфетамин — психоактивное вещество, стимулирующее работу головного мозга и всей нервной системы. Это синтетический препарат, представленный в виде белого кристаллического порошка."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	heart_rate_increase = 1
	taste_description = "бодрости"
	tags = REAGENT_TAG_ANTI_STUN
	chemdesc = "Ускоряет передвижение, бодрит и помогает легче справляться с оглушениями разного рода. Повреждает мозг."
	chemuse = 50

/datum/reagent/methamphetamine/on_mob_add(mob/living/user)
	. = ..()
	if(user.dna && (user.dna.species.reagent_tag & ORGANIC))
		user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/methamphetamine/on_mob_life(mob/living/user)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		user.emote(pick("twitch_s","blink_r","shiver"))
	if(current_cycle >= 25)
		user.AdjustJitter(10 SECONDS)
	user.AdjustDrowsy(-20 SECONDS)
	user.AdjustParalysis(-4 SECONDS)
	user.AdjustStunned(-4 SECONDS)
	user.AdjustWeakened(-4 SECONDS)
	user.AdjustKnockdown(-4 SECONDS)
	update_flags |= user.adjustStaminaLoss(-7, FALSE)
	user.SetSleeping(0)
	if(prob(50))
		update_flags |= user.adjustBrainLoss(1, FALSE)
	if(!(user.dna && (user.dna.species.reagent_tag & ORGANIC)))
		user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	return ..() | update_flags

/datum/reagent/methamphetamine/on_mob_delete(mob/living/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/methamphetamine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message(span_warning("Ноги [M] заплетаются!"))
			M.AdjustConfused(40 SECONDS)
			M.Weaken(8 SECONDS)
		else if(effect <= 4)
			M.visible_message(span_warning("[M] маш[PLUR_ET_UT(M)] руками во все стороны, роняя предметы в руках!"))
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 7)
			M.emote("laugh")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message(span_warning("[M] маш[PLUR_ET_UT(M)] руками во все стороны, роняя предметы в руках!"))
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 4)
			M.visible_message(span_warning("[M] кача[PLUR_ET_YUT(M)]ся и вал[PLUR_IT_YAT(M)]ся на землю!"))
			M.Jitter(20 SECONDS)
			M.Weaken(20 SECONDS)
		else if(effect <= 7)
			M.emote("laugh")
	return list(effect, update_flags)

/datum/reagent/bath_salts
	name = "Соль для ванн"
	id = "bath_salts"
	description = "На самом деле это не соли для купания в ванной, а синтетические наркотики, которые часто маскируют под соли для ванн и прочие бытовые вещества, чтобы упроситить распространение."
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_chance = 15
	addiction_threshold = 5
	shock_reduction = 60
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "нереальной бодрости"
	tags = REAGENT_TAG_ANTI_STUN

/datum/reagent/bath_salts/on_mob_add(mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		user.physiology.punch_damage_low += 5
		user.physiology.punch_damage_high += 5

/datum/reagent/bath_salts/on_mob_life(mob/living/M)
	var/check = rand(0,100)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-8, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.internal_receive_damage(0.2)
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.SetKnockdown(0)
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		if(check < 8 && head_organ.h_style != "Very Long Beard")
			head_organ.h_style = "Very Long Hair"
			head_organ.f_style = "Very Long Beard"
			H.update_hair()
			H.update_fhair()
			H.visible_message(span_warning("[H] выгляд[PLUR_IT_YAT(H)] ДИКО!"))
	if(check < 30)
		M.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))
		M.Druggy(30 SECONDS)
	if(check < 5)
		M.emote(pick("howl", "growl"))
	else if(check < 24)
		to_chat(M, span_userdanger("Они идут за вами!!!"))
	else if(check < 28)
		to_chat(M, span_userdanger("ОНИ УЖЕ БЛИЗКО!!!"))
	return ..() | update_flags

/datum/reagent/bath_salts/on_mob_delete(mob/living/carbon/human/user)
	. = ..()
	if(ishuman(user))
		user.physiology.punch_damage_low -= 5
		user.physiology.punch_damage_high -= 5

/datum/reagent/bath_salts/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		to_chat(M, span_danger("<font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>КАК ЖЕ ЭТО ОХУЕННО!!!</font>"))
		SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
		M.emote("faint")
		M.adjustToxLoss(volume)
		M.adjustBrainLoss(volume * 2)
	else
		to_chat(M, span_notice("Вы чувствуете себя соленоватым."))

/datum/reagent/bath_salts/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-16, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.internal_receive_damage(1.8)
	return list(0, update_flags)

/datum/reagent/jenkem
	name = "Дженкем"
	id = "jenkem"
	description = "Дженкем — это тюремный наркотик, изготовленный путем брожения фекалий в растворе мочи. Крайне отвратительно."
	reagent_state = LIQUID
	color = "#644600"
	addiction_chance = 5
	addiction_threshold = 5
	taste_description = "тушёного говна с мочой"

/datum/reagent/jenkem/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Dizzy(10 SECONDS)
	if(prob(10))
		M.emote(pick("twitch_s","drool","moan"))
		update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/aranesp
	name = "Аранесп"
	id = "aranesp"
	description = "Запрещенный препарат, повышающий работоспособность. Побочные эффекты могут включать боль в груди, судороги, отеки, головную боль, лихорадку и так далее..."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "горечи"

/datum/reagent/aranesp/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-9, FALSE)
	if(prob(90))
		update_flags |= M.adjustToxLoss(1, FALSE)
	if(prob(5))
		M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_s"))
	var/high_message = pick("бодрость", "заряд бодрости", "силу", "непобедимость", "скорость", "энергию")
	if(prob(8))
		to_chat(M, span_notice("Вы чувствуете [high_message]!"))
	if(prob(5))
		to_chat(M, span_danger("У вас перехватило дыхание."))
		update_flags |= M.adjustOxyLoss(15, FALSE)
		M.Stun(2 SECONDS)
		M.AdjustLoseBreath(2 SECONDS)
	return ..() | update_flags

/datum/reagent/thc
	name = "Тетрагидроканнабинол"
	id = "thc"
	description = "Мягкое психоактивное вещество, добываемое из растения конопли."
	reagent_state = LIQUID
	color = "#0FBE0F"
	taste_description = "охренненого кайфа"

/datum/reagent/thc/on_mob_life(mob/living/M)
	M.AdjustStuttering(rand(0, 6 SECONDS))
	if(prob(5))
		M.emote(pick("laugh","giggle","smile"))
	if(prob(5))
		to_chat(M, span_notice("[pick("Вам хочется есть.", "Вам холодно.", "Вам тепло.", "У вас крутит живот.")]"))
	if(prob(4))
		M.Confused(20 SECONDS)
	if(volume >= 50 && prob(25))
		if(prob(10))
			M.Drowsy(20 SECONDS)
	return ..()

/datum/reagent/cbd
	name = "Каннабидиол"
	id = "cbd"
	description = "Непсихоактивный фитоканнабиноид, добываемый из растения конопли."
	reagent_state = LIQUID
	color = "#00e100"
	taste_description = "расслабления"

/datum/reagent/cbd/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		M.emote(pick("hsigh", "yawn"))
	if(prob(5))
		to_chat(M, span_notice("[pick("Вы чувствуете умиротворение.", "Вам легко дышать.", "Вы очень спокойны.", "Вы чувствуете себя классно.")]"))
	if(prob(10))
		M.AdjustConfused(-10 SECONDS)
		M.SetWeakened(0, FALSE)
		M.SetKnockdown(0, FALSE)
	if(volume >= 70 && prob(25))
		if(M.reagents.get_reagent_amount(/datum/reagent/thc) <= 20)
			M.Drowsy(20 SECONDS)
	if(prob(25))
		update_flags |= M.adjustBruteLoss(-2, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-2, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/fliptonium
	name = "Крутений"
	id = "fliptonium"
	description = "Туда-сюда, влево-вправо, вперёд-назад!"
	reagent_state = LIQUID
	color = "#A42964"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 15
	process_flags = ORGANIC | SYNTHETIC // Flipping for everyone!
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 10
	taste_description = "кувырков"
	chemdesc = "Вызывает неконтролируемое вращение."
	chemuse = 50

/datum/reagent/fliptonium/on_mob_life(mob/living/user)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle == 5)
		user.SpinAnimation(speed = 11, loops = -1, parallel = FALSE)
	if(current_cycle == 10)
		user.SpinAnimation(speed = 10, loops = -1, parallel = FALSE)
	if(current_cycle == 15)
		user.SpinAnimation(speed = 9, loops = -1, parallel = FALSE)
	if(current_cycle == 20)
		user.SpinAnimation(speed = 8, loops = -1, parallel = FALSE)
	if(current_cycle == 25)
		user.SpinAnimation(speed = 7, loops = -1, parallel = FALSE)
	if(current_cycle == 30)
		user.SpinAnimation(speed = 6, loops = -1, parallel = FALSE)
	if(current_cycle == 40)
		user.SpinAnimation(speed = 5, loops = -1, parallel = FALSE)
	if(current_cycle == 50)
		user.SpinAnimation(speed = 4, loops = -1, parallel = FALSE)

	user.AdjustDrowsy(-12 SECONDS)
	user.AdjustParalysis(-3 SECONDS)
	user.AdjustStunned(-3 SECONDS)
	user.AdjustWeakened(-3 SECONDS)
	update_flags |= user.adjustStaminaLoss(-1.5, FALSE)
	user.SetSleeping(0)
	return ..() | update_flags

/datum/reagent/fliptonium/reaction_mob(mob/living/user, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST || method == REAGENT_TOUCH)
		user.SpinAnimation(speed = 12, loops = -1, parallel = FALSE)
	..()

/datum/reagent/fliptonium/on_mob_delete(mob/living/user)
	. = ..()
	user.SpinAnimation(speed = 12, loops = -1, parallel = FALSE)

/datum/reagent/fliptonium/overdose_process(mob/living/user, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			user.visible_message(span_warning("Ноги [user] заплетаются!"))
			user.AdjustConfused(66 SECONDS)
			user.Weaken(4 SECONDS)
		else if(effect <= 4)
			user.visible_message(span_warning("[user] маш[PLUR_ET_UT(user)] руками во все стороны, роняя предметы в руках!"))
			user.drop_l_hand()
			user.drop_r_hand()
		else if(effect <= 7)
			user.emote("laugh")
	else if(severity == 2)
		if(effect <= 2)
			user.visible_message(span_warning("[user] маш[PLUR_ET_UT(user)] руками во все стороны, роняя предметы в руках!"))
			user.drop_l_hand()
			user.drop_r_hand()
		else if(effect <= 4)
			user.visible_message(span_warning("[user] кача[PLUR_ET_YUT(user)]ся и вал[PLUR_IT_YAT(user)]ся на землю!"))
			user.Jitter(10 SECONDS)
			user.Weaken(10 SECONDS)
		else if(effect <= 7)
			user.emote("laugh")
	return list(effect, update_flags)

/datum/reagent/rotatium //Rotatium. Fucks up your rotation and is hilarious
	name = "Ротатий"
	id = "rotatium"
	description = "Крутящаяся туда-сюда странного цвета жидкость. Нарушает чувство координации употребившего."
	reagent_state = LIQUID
	color = "#AC88CA" //RGB: 172, 136, 202
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	taste_description = "spinning"

/datum/reagent/rotatium/on_mob_life(mob/living/carbon/M)
	if(M.hud_used)
		if(current_cycle >= 20 && current_cycle % 20 == 0)
			var/atom/movable/plane_master_controller/pm_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
			var/rotation = min(round(current_cycle / 20), 89) // By this point the player is probably puking and quitting anyway
			for(var/atom/movable/screen/plane_master/pm_iterator as anything in pm_controller.get_planes())
				animate(pm_iterator, transform = matrix(rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING, loop = -1)
				animate(transform = matrix(-rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING)
	return ..()

/datum/reagent/rotatium/on_mob_delete(mob/living/M)
	if(M?.hud_used)
		var/atom/movable/plane_master_controller/pm_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		for(var/atom/movable/screen/plane_master/pm_iterator as anything in pm_controller.get_planes())
			animate(pm_iterator, transform = matrix(), time = 5, easing = QUAD_EASING)
	..()

//////////////////////////////
//		   laughter         //
//////////////////////////////

/datum/reagent/consumable/laughter
	name = "Смехотвор"
	description = "Некоторые говорят, что это лучшее лекарство, но последние исследования доказали, что это не так."
	id = "laughter"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	addiction_chance = 15
	addiction_threshold = 20
	color = "#FF4DD2"
	taste_description = "смеха"
	reagent_state = LIQUID

/datum/reagent/consumable/laughter/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/chance = rand(1,200)
	switch(volume)
		if(0 to 9)
			switch(chance)
				if(1 to 20)
					M.emote(pick("giggle", "smile"))
				if(30 to 35)
					to_chat(M, span_notice("ХЕХЕХЕ! У вас не получается не улыбаться!"))
		if(10 to 19)
			switch(chance)
				if(1 to 20)
					M.emote(pick("laugh", "giggle", "smile"))
				if(30 to 35)
					to_chat(M, span_notice("Вы чувствуете себя классно! ХАХАХАХ!"))
				if(40 to 55)
					M.say(pick(list("Ааххаха!", "Ххаахах!")))
		if(20 to 39)
			switch(chance)
				if(1 to 20)
					M.emote(pick("laugh", "giggle", "smile", "grin"))
				if(30 to 33)
					to_chat(M, span_notice("Просто оборжаться! ХАХАХАХА!"))
				if(40 to 55)
					M.say(pick(list("Ааххааахахаха!", "Уааххаахаха!", "Иииххихихии!", "Оооххохохох!", "Кьяяхахаха!", "Ваахахахах!")))
		if(40 to 69)
			switch(chance)
				if(1 to 20)
					M.emote(pick("laugh", "giggle", "smile", "grin"))
				if(30 to 35)
					to_chat(M, span_notice("ХАХАХАХ! Вы не можете не смеяться!"))
				if(40 to 50)
					M.say(pick(list("АААААААХАХАХАХ!", "ИХИХИХИХИХИХХИХИ!", "УАААААХАХАХ!", "МЬЯХАХАХАХАХАХАХАА!", "НЬЯЯЯХАХАХАХАХА!")))
		if(70 to INFINITY)
			switch(chance)
				if(1 to 25)
					M.emote(pick("laugh", "cry", "smile", "grin"))
				if(30 to 35)
					M.say(pick(list("ААААААХХАААА!!!", "ЫАААААЫЫЫААААА!!!", "УАААААХАХАХАААААА!!!", "КХХХАААААААААААААА!!!")))
				if(40 to 49)
					M.say(pick(list("УАААААХАХАХ!!!", "КХХХААААААААА!!!", "АХАХАХАХ ААААА АХАХАХАХА!!!")))
				if(50 to 55)
					M.Weaken(4 SECONDS)
					M.Jitter(10 SECONDS)
					M.emote(pick("laugh"))
				if(60 to 69)
					M.adjust_bodytemperature(rand(1, 5))
					M.vomit()
					update_flags |= M.adjustBrainLoss(rand(1, 5))
				if(70 to 74)
					to_chat(M, span_warning("Вы умираете от смеха. Буквально."))
	return ..() | update_flags

/datum/reagent/consumable/laughter/addiction_act_stage4(mob/living/carbon/M)
	var/chance = rand(1,1000)
	switch(chance)
		if(1 to 80)
			to_chat(M, span_notice("[name], хотя бы неможко..."))
			M.emote(pick("twitch", "sigh", "cry", "groan"))
		if(81 to 160)
			to_chat(M, span_notice("Ваша жизнь теперь кажется такой унылой..."))
			M.AdjustEyeBlind(16 SECONDS)
			M.emote(pick("twitch", "sigh", "cry", "groan"))
		if(161 to 240)
			M.emote("whimper")
			M.Jitter(10 SECONDS)
		if(241 to 320)
			M.emote("cry")
			M.Jitter(6 SECONDS)
		if(321 to 370)
			to_chat(M, span_warning("Вы чувствуете себя депрессивным."))
			M.emote(pick("twitch", "sigh", "cry", "sniff"))
		if(371 to 420)
			to_chat(M, span_warning("[name], как же он вам нужен..."))
			M.emote(pick("twitch", "sigh", "cry", "sniff"))
		if(421 to 470)
			to_chat(M, span_warning("[name], он РЕАЛЬНО вам нужен прямо сейчас!"))
			M.emote(pick("twitch", "sigh", "cry", "sniff"))
	return STATUS_UPDATE_NONE

/datum/reagent/consumable/laughter/addiction_act_stage5(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/chance = rand(1,1600)
	switch(chance)
		if(1 to 50)
			to_chat(M, span_notice("[name], хотя бы неможко..."))
		if(51 to 100)
			M.emote(pick("whimper", "glare", "cry", "sniff"))
			M.Jitter(10 SECONDS)
		if(101 to 150)
			to_chat(M, span_notice("Ваша жизнь потеряла все краски..."))
			M.EyeBlind(16 SECONDS)
			update_flags |= M.adjustBrainLoss(rand(1, 7))
		if(151 to 200)
			to_chat(M, span_warning("Ваш живот ужасно болит..."))
			M.visible_message(span_warning("[M] складыва[PLUR_ET_YUT(M)]ся пополам от боли!"))
			M.Weaken(6 SECONDS)
		if(201 to 280)
			M.emote(pick("twitch", "glare", "cry", "groan"))
			M.Jitter(10 SECONDS)
		if(281 to 330)
			to_chat(M, span_warning("Вам по-настоящему грустно! Найдите чем развлечь себя!"))
			M.emote(pick("twitch", "sigh", "cry"))
			update_flags |= M.adjustBrainLoss(rand(1, 5))
		if(331 to 380)
			to_chat(M, span_warning("[name], да вы жить без этого не сможете!"))
			M.emote(pick("twitch", "sigh", "cry", "groan"))
		if(381 to 420)
			to_chat(M, span_warning("[name], вы готовы убить хоть за небольшую дозу!"))
			M.emote(pick("twitch", "sigh", "cry", "groan"))
			update_flags |= M.adjustBrainLoss(rand(1, 5))
	return update_flags

//////////////////////////////
//		Synth-Drugs			//
//////////////////////////////

//Ultra-Lube: Meth
/datum/reagent/lube/ultra
	name = "Ультра-смазка"
	id = "ultralube"
	description = "Ультра-смазка — это улучшенная смазка, которая вызывает у синтетиков эффект, подобный метамфетамину, за счет резкого снижения внутреннего трения и повышения охлаждающей способности."
	color = "#1BB1FF"
	process_flags = SYNTHETIC
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "стекломоя"

/datum/reagent/lube/ultra/on_mob_add(mob/living/user)
	. = ..()
	if(user.dna && (user.dna.species.reagent_tag & SYNTHETIC))
		user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/ultra_lube)

/datum/reagent/lube/ultra/on_mob_life(mob/living/user)
	var/update_flags = STATUS_UPDATE_NONE
	var/high_message = pick("Вы чувствуете, как жужжат ваши сервоприводы!", "Вам нужно разогнаться!", "Вы чувствуете себя так, будто вас только что разогнали!")
	if(prob(1) && prob(1))
		high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
	if(prob(5))
		to_chat(user, span_notice("[high_message]"))
	user.AdjustParalysis(-4 SECONDS)
	user.AdjustStunned(-4 SECONDS)
	user.AdjustWeakened(-4 SECONDS)
	user.AdjustKnockdown(-4 SECONDS)
	update_flags |= user.adjustStaminaLoss(-7, FALSE)
	user.Jitter(6 SECONDS)
	update_flags |= user.adjustBrainLoss(0.5, FALSE)
	if(prob(5))
		user.emote(pick("twitch", "shiver"))
	if(!(user.dna && (user.dna.species.reagent_tag & SYNTHETIC)))
		user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ultra_lube)
	return ..() | update_flags

/datum/reagent/lube/ultra/on_mob_delete(mob/living/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/ultra_lube)

/datum/reagent/lube/ultra/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(prob(20))
		M.emote("ping")
	if(prob(33))
		M.visible_message(span_warning("[M] маш[PLUR_ET_UT(M)] руками во все стороны, роняя предметы в руках!"))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_from_active_hand()
	if(prob(50))
		update_flags |= M.adjustFireLoss(10, FALSE)
	update_flags |= M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1), FALSE)
	return list(effect, update_flags)

//Surge: Krokodil
/datum/reagent/surge
	name = "Всплеск"
	id = "surge"
	description = "Сверхпроводящий гель, который перегружает процессоры синтетиков, вызывая эффект, схожий с действием опиатов на органиков."
	reagent_state = LIQUID
	color = "#6DD16D"
	process_flags = SYNTHETIC
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	taste_description = "силикона"

/datum/reagent/surge/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	var/high_message = pick("Вы чувствуете себя спокойно.", "Вы чувствуете себя собранным.", "Вы чувствуете, что вам нужно расслабиться.")
	if(prob(1))
		if(prob(1))
			high_message = "01010100010100100100000101001110010100110100001101000101010011100100010001000101010011100100001101000101."
	if(prob(5))
		to_chat(M, span_notice("[high_message]"))
	return ..() | update_flags

/datum/reagent/surge/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	//Hit them with the same effects as an electrode!
	M.Weaken(10 SECONDS)
	M.Jitter(40 SECONDS)
	M.Stuttering(10 SECONDS)
	if(prob(10))
		to_chat(M, span_danger("Ваши процессоры перегружаются, вызывая короткое замыкание!"))
		playsound(get_turf(M), 'sound/effects/eleczap.ogg', 75, TRUE)
		//Lightning effect for electrical discharge visualization
		var/icon/I=new('icons/obj/zap.dmi',"lightningend")
		I.Turn(-135)
		var/obj/effect/overlay/beam/B = new(get_turf(M))
		B.pixel_x = rand(-20, 0)
		B.pixel_y = rand(-20, 0)
		B.icon = I
		update_flags |= M.adjustFireLoss(rand(1,5) / 2, FALSE)
		update_flags |= M.adjustBruteLoss(rand(1,5) / 2, FALSE)
	return list(0, update_flags)

//surge+, used in supercharge implants
/datum/reagent/surge_plus
	name = "Всплеск+"
	id = "surge_plus"
	description = "Сверхпроводящий гель, который перегружает процессоры синтетиков, вызывая эффект, схожий с действием бензодиазепинамов на органиков."
	reagent_state = LIQUID
	color = "#28b581"

	process_flags = SYNTHETIC
	overdose_threshold = 30
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 5
	taste_description = "взякого силикона"

/datum/reagent/surge_plus/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustParalysis(-8 SECONDS)
	M.AdjustStunned(-8 SECONDS)
	M.AdjustWeakened(-8 SECONDS)
	M.AdjustKnockdown(-8 SECONDS)
	update_flags |= M.adjustStaminaLoss(-25, FALSE)
	if(prob(5))
		var/high_message = pick("Вы чувствуете себя спокойно.", "Вы чувствуете себя собранным.", "Вы чувствуете, что вам нужно расслабиться.")
		if(prob(10))
			high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
		to_chat(M, span_notice("[high_message]"))

	return ..() | update_flags

/datum/reagent/surge_plus/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]
	M.Jitter(40 SECONDS)
	M.Stuttering(10 SECONDS)
	if(prob(5))
		to_chat(M, span_notice("Ваши процессоры перегреваются!")) // synth fever
		M.adjust_bodytemperature(30 * recent_consumption)
		M.Confused(2 SECONDS * recent_consumption)
	if(prob(10))
		to_chat(M, span_danger("Ваши процессоры перегружаются, вызывая короткое замыкание!"))
		playsound(get_turf(M), 'sound/effects/eleczap.ogg', 75, TRUE)
		var/icon/I = new('icons/obj/zap.dmi', "lightningend")
		I.Turn(-135)
		var/obj/effect/overlay/beam/B = new(get_turf(M))
		B.pixel_x = rand(-20, 0)
		B.pixel_y = rand(-20, 0)
		B.icon = I
		update_flags |= M.adjustFireLoss(rand(1, 5))
		update_flags |= M.adjustBruteLoss(rand(1, 5))
	return list(0, update_flags)

	//Servo Lube, supercharge
/datum/reagent/lube/combat
	name = "Боевая смазка"
	id = "combatlube"
	description = "Боевая смазка — это улучшенная смазка, которая вызывает у синтетиков эффекты, многократно превосходящие аналогичные у \"Ультра-смазки\" за счёт резкого снижения внутреннего трения и повышения охлаждающей способности."
	process_flags = SYNTHETIC
	overdose_threshold = 30
	addiction_chance = 1
	addiction_chance_additional = 20

/datum/reagent/lube/combat/on_mob_add(mob/living/user)
	. = ..()
	if(user.dna && (user.dna.species.reagent_tag & SYNTHETIC))
		user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/combat_lube)

/datum/reagent/lube/combat/on_mob_life(mob/living/user)
	user.SetSleeping(0)
	user.SetDrowsy(0)

	var/high_message = pick("Вы чувствуете, как жужжат ваши сервоприводы!", "Вам нужно разогнаться!", "Вы чувствуете себя так, будто вас только что разогнали!")
	if(prob(10))
		high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
	if(prob(5))
		to_chat(user, span_notice("[high_message]"))
	if(!(user.dna && (user.dna.species.reagent_tag & SYNTHETIC)))
		user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/combat_lube)
	return ..()

/datum/reagent/lube/combat/on_mob_delete(mob/living/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/combat_lube)

/datum/reagent/lube/combat/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(prob(20))
		M.emote("ping")
	if(prob(33))
		M.visible_message(span_warning("[M] маш[PLUR_ET_UT(M)] руками во все стороны, роняя предметы в руках!"))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_from_active_hand()
	update_flags |= M.adjustFireLoss(5, FALSE)
	update_flags |= M.adjustBrainLoss(3, FALSE)
	return list(effect, update_flags)

/datum/reagent/crack
	name = "Крэк"
	id = "crack"
	description = "Кристаллизованная версия кокаина, потребляемая путем курения."
	reagent_state = LIQUID
	color = "#f0f0f0"
	overdose_threshold = 20
	addiction_chance = 15
	addiction_threshold = 5
	taste_description = "неприятной горечи с примесью бедности"
	shock_reduction = 100
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	tags = REAGENT_TAG_ANTI_STUN

/datum/reagent/crack/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-3, FALSE)
	if(prob(15))
		M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
	if(prob(50))
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.SetKnockdown(0)
	if(prob(50))
		update_flags |= M.adjustHeartLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/crack/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-0.4, FALSE)
	update_flags |= M.adjustHeartLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/crack/reaction_temperature(exposed_temperature, exposed_volume)
	if((exposed_temperature >= 350) && (volume >= 10))
		if(holder)
			for(var/i = 0, i < round(volume/10,1),i++)
				new /obj/item/crack_crystal(get_turf(holder.my_atom))
			holder.del_reagent(type)

/datum/reagent/cocaine
	name = "Кокаин"
	id = "cocaine"
	description = "Всемирно известный препарат, оказывающий сильное воздействие на нервную систему употребившего."
	reagent_state = LIQUID
	color = "#f0f0f0"
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	taste_description = "легкой горечи, переходящей в чувство онемения"
	shock_reduction = 140
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	tags = REAGENT_TAG_ANTI_STUN

/datum/reagent/cocaine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		M.emote(pick("twitch_s","blink_r","shiver"))
	if(current_cycle >= 25)
		M.AdjustJitter(10 SECONDS)
	update_flags |= M.adjustStaminaLoss(-5, FALSE)
	M.SetParalysis(0)
	M.SetStunned(0)
	M.SetWeakened(0)
	M.SetKnockdown(0)
	if(prob(25))
		update_flags |= M.adjustHeartLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/cocaine/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(50))
		update_flags |= M.adjustHeartLoss(1, FALSE)
	M.AdjustConfused(2 SECONDS)
	if(prob(25))
		M.emote("sneeze")
	if(prob(10))
		M.emote("collapse")
	M.emote("tremble")
	return list(0, update_flags)

/datum/reagent/cocaine/reaction_temperature(exposed_temperature, exposed_volume)
	if((exposed_temperature >= 350) && (volume >= 10))
		if(holder)
			for(var/i = 0, i < round(volume/10,1),i++)
				new /obj/item/coca_packet(get_turf(holder.my_atom))
			holder.del_reagent(type)

/datum/reagent/matedecoca
	name = "Мате де Кока"
	id = "matedecoca"
	description = "Чай из кокаина. Особенно интересный напиток."
	reagent_state = LIQUID
	color = "#8acca7"
	overdose_threshold = 40
	addiction_chance = 2
	addiction_threshold = 5
	taste_description = "приятной горечи"
	shock_reduction = 50
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	drink_icon = "matedecoca"
	drink_name = "кружка Мате де Кока"
	drink_desc = "Чай из кокаина. Особенно интересный напиток."

/datum/reagent/matedecoca/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		M.AdjustJitter(5 SECONDS)
	M.AdjustDrowsy(-20 SECONDS)
	M.AdjustParalysis(-3 SECONDS)
	M.AdjustStunned(-3 SECONDS)
	M.AdjustWeakened(-3 SECONDS)
	M.AdjustKnockdown(-3 SECONDS)
	M.SetSleeping(0)
	return ..() | update_flags

/datum/reagent/matedecoca/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(25))
		M.fakevomit()
		M.emote("tremble")
	return list(0, update_flags)

/datum/reagent/pervitin
	name = "Первитин"
	id = "pervitin"
	description = "Первитин — мощный стимулятор, синтезируемый из метамфетамина. Вызывает эйфорию и прилив сил, но чрезвычайно быстро формирует зависимость и разрушает мозг."
	reagent_state = LIQUID
	color = "#8c7ba0"
	overdose_threshold = 20
	addiction_chance = 30
	addiction_threshold = 5
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	heart_rate_increase = 1
	taste_description = "бодрости"
	chemdesc = "Ускоряет работу руками. Вызывает зависимость, при передозировке разрушает мозг и сердце."

/datum/reagent/pervitin/on_mob_add(mob/living/user)
	. = ..()
	user.next_move_modifier /= 1.5

/datum/reagent/pervitin/overdose_start(mob/living/M)
	M.next_move_modifier *= 0.75

/datum/reagent/pervitin/overdose_end(mob/living/M)
	M.next_move_modifier /= 0.75

/datum/reagent/pervitin/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	update_flags |= M.adjustBrainLoss(2, FALSE)
	update_flags |= M.adjustHeartLoss(1, FALSE)
	if(prob(40))
		M.emote("bshake")
	return list(overdose_info[REAGENT_OVERDOSE_EFFECT], update_flags)

/datum/reagent/pervitin/on_mob_delete(mob/living/user)
	if(overdosed)
		user.next_move_modifier /= 0.75
	user.next_move_modifier *= 1.5
	return ..()

#define MEPHEDRONE_SCREEN_FILTER "mephedrone_screen_filter"
#define MEPHEDRONE_SCREEN_BLUR "mephedrone_screen_blur"

#define MEPHEDRONE_BLUR_EFFECT "mephedrone_dodge_blur"
#define MEPHEDRONE_OVERDOSE_BLUR_EFFECT "mephedrone_overdose_blur"
#define CONSTANT_DOSE_DEATH_LIMIT 300
#define CONSTANT_DOSE_SAFE_LIMIT 30

// Mephedrone drug, makes the takers of it faster and able to dodge bullets while in their system, to potentially bad side effects
/datum/reagent/mephedrone
	name = "Мефедрон"
	id = "mephedrone"
	description = "Наркотик, изначально разработанный плутонянами для себя, чтобы помогать им во время рейдов. \
		Не получил широкого распространения из-за последующей дереализации и проблем с сердцем. \
		Можно намеренно превысить дозу, чтобы усилить эффект наркотика."
	reagent_state = LIQUID
	color = "#c22a44"
	taste_description = "телевизионные помехи"
	metabolization_rate = 0.375 * REAGENTS_METABOLISM
	overdose_threshold = 15
	addiction_chance = 3
	addiction_threshold = 20 //High chance so higher threshold
	shock_reduction = 40 // Slight shock reduction to assist with damage / disablers
	process_flags = ORGANIC | SYNTHETIC
	/// Keeps track of how many chemicals we are delaying the changeling by.
	var/changeling_chemical_tracker = 0

/datum/reagent/mephedrone/on_mob_add(mob/living/carbon/user)
	. = ..()
	user.add_movespeed_modifier(/datum/movespeed_modifier/reagent/mephedrone)
	ADD_TRAIT(user, TRAIT_NOKNOCKDOWNSLOWDOWN, id)
	user.next_move_modifier /= 1.5 // For the duration of this you move and attack faster

	user.sound_environment_override = SOUND_ENVIRONMENT_DIZZY

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	RegisterSignal(user, COMSIG_MOB_HUD_CREATED, PROC_REF(no_hud_cheese))

	if(!user.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = user.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]

	var/static/list/col_filter_green = list(0.66,0,0,0, 0,1,0,0, 0,0,0.66,0, 0,0,0,1)

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_FILTER, 10, color_matrix_filter(col_filter_green, FILTER_COLOR_RGB))

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))

	if(!IS_CHANGELING(user) || HAS_TRAIT(user, TRAIT_MEPHEDRONE_ADAPTED))
		return
	var/datum/antagonist/changeling/cling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	cling.chem_recharge_slowdown += 1
	changeling_chemical_tracker += 1

/datum/reagent/mephedrone/on_mob_delete(mob/living/carbon/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/mephedrone)
	REMOVE_TRAIT(user, TRAIT_NOKNOCKDOWNSLOWDOWN, id)
	var/overdosed = (type in user.reagents.overdose_list())
	user.next_move_modifier *= (overdosed ? 1.5 * 1.25 : 1.5)

	user.sound_environment_override = NONE

	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	if(overdosed)
		UnregisterSignal(user, COMSIG_ATOM_PREHIT)

	if(IS_CHANGELING(user))
		var/datum/antagonist/changeling/cling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		cling.chem_recharge_slowdown -= changeling_chemical_tracker
		changeling_chemical_tracker = 0

	if(current_cycle < CONSTANT_DOSE_SAFE_LIMIT) // Anything less than this and you'll come out fiiiine, aside from a big hit of stamina damage
		user.visible_message(
			span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] внезапно замедля[PLUR_ET_YUT(user)]ся, сбросив свою нечеловеческую скорость, и возвраща[PLUR_ET_YUT(user)]ся с сильным кровотечением из носа!"),
			span_danger("Вы внезапно замедляетесь обратно до нормальной скорости, а из вашего носа хлещет кровь!"))
		user.adjustStaminaLoss(current_cycle * 2)
	else // Much longer than that however, and you're not gonna have a good day
		user.visible_message(
			span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] внезапно сбрасыва[PLUR_ET_YUT(user)] нечеловеческую скорость, откашливаясь брызгами крови!"),
			span_danger("Возвращаясь к нормальной скорости, вы откашливаете тревожное количество крови. Такое ощущение, будто по вам проехал погрузчик."))
		user.custom_emote(EMOTE_VISIBLE,  "кашля%(ет, ют)% кровью!")
		user.bleed(25)
		user.apply_damage(max(current_cycle * 2 / 3, 60), STAMINA)
		user.Knockdown((current_cycle * 2 / 15) SECONDS) // a minute is a 4 second knockdown, 2 is 8, etc
		if(!HAS_TRAIT(user, TRAIT_MEPHEDRONE_ADAPTED) || current_cycle >= CONSTANT_DOSE_DEATH_LIMIT) //If you are going infinite with mito and you run out, you deserve this even with an implant
			if(ishuman(user))
				var/mob/living/carbon/human/human_user = user
				var/obj/item/organ/internal/our_heart = human_user.get_organ_slot(INTERNAL_ORGAN_HEART)
				if(our_heart)
					our_heart.internal_receive_damage(0.15 * current_cycle * 2, TRUE)
				else
					handle_heartless(user, 0.15 * current_cycle * 2)


	if(!user.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = user.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]

	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_FILTER)
	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_BLUR)


/// Leaves an afterimage behind the mob when they move
/datum/reagent/mephedrone/proc/on_movement(mob/living/carbon/user, atom/old_loc)
	SIGNAL_HANDLER
	if(HAS_TRAIT(user, TRAIT_IMMOBILIZED)) //No, dead people floating through space do not need afterimages
		return NONE
	var/overdosed = (type in user.reagents.overdose_list())
	new /obj/effect/temp_visual/decoy/mephedrone_afterimage(old_loc, user, overdosed ? 1.25 SECONDS : 0.75 SECONDS)

/// Tries to dodge incoming bullets if we aren't disabled for any reasons
/datum/reagent/mephedrone/proc/dodge_bullets(mob/living/carbon/human/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(HAS_TRAIT(source, TRAIT_IMMOBILIZED))
		return NONE
	source.visible_message(
		span_danger("[DECLENT_RU_CAP(source, NOMINATIVE)] без усилий уклоня[PLUR_ET_YUT(source)]ся от [hitting_projectile.declent_ru(GENITIVE)]!"),
		span_userdanger("Вы без усилий уклоняетесь от [hitting_projectile.declent_ru(GENITIVE)]!"),
	)
	playsound(source, SFX_BULLET_MISS_ALT, 75, TRUE)
	source.add_filter(MEPHEDRONE_BLUR_EFFECT, 2, gauss_blur_filter(5))
	addtimer(CALLBACK(source, TYPE_PROC_REF(/datum, remove_filter), MEPHEDRONE_BLUR_EFFECT), 0.5 SECONDS)
	return ATOM_PREHIT_FAILURE

/// So. If a person changes up their hud settings (Changing their ui theme), the visual effects for this reagent will break, and they will be able to see easily. This 3 part proc waits for the plane controlers to be setup, and over 2 other procs, rengages the visuals
/datum/reagent/mephedrone/proc/no_hud_cheese(mob/living/carbon/user)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(no_hud_cheese_2), user), 2 SECONDS) //Calling it instantly will not work, need to give it a moment

/// This part of the anticheese sets up the basic visual effects normally setup when the reagent gets into your system.
/datum/reagent/mephedrone/proc/no_hud_cheese_2(mob/living/carbon/user) //Basically if you change the UI you would remove the visuals. This fixes that.
	var/atom/movable/plane_master_controller/game_plane_master_controller = user.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_FILTER)
	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_BLUR)

	var/static/list/col_filter_green = list(0.66,0,0,0, 0,1,0,0, 0,0,0.66,0, 0,0,0,1)

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_FILTER, 10, color_matrix_filter(col_filter_green, FILTER_COLOR_RGB))

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))

	var/overdosed = (type in user.reagents.overdose_list())
	if(overdosed)
		addtimer(CALLBACK(src, PROC_REF(no_hud_cheese_3), user), 1 SECONDS) //still needs a moment

///This part sets up the OD visual effects.
/datum/reagent/mephedrone/proc/no_hud_cheese_3(mob/living/carbon/user)
	var/atom/movable/plane_master_controller/game_plane_master_controller = user?.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	var/list/col_filter_ourple = list(1,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1)

	for(var/filter in game_plane_master_controller.get_filters(MEPHEDRONE_SCREEN_FILTER))
		animate(filter, loop = -1, color = col_filter_ourple, time = 4 SECONDS, easing = BOUNCE_EASING)

/datum/reagent/mephedrone/on_mob_life(mob/living/carbon/user)
	. = ..()

	if(!ishuman(user))
		return
	var/heart_damage = 0.1
	if(user.reagents.has_reagent(/datum/reagent/methamphetamine)) //We want people to use something other than meth, since meths downside is knockdowns / be orginal
		heart_damage = 1.1
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/internal/our_heart = human_user.get_organ_slot(INTERNAL_ORGAN_HEART)
	if(our_heart)
		our_heart.internal_receive_damage(heart_damage, TRUE)
	else
		handle_heartless(user, heart_damage)

/datum/reagent/mephedrone/overdose_start(mob/living/user)

	RegisterSignal(user, COMSIG_ATOM_PREHIT, PROC_REF(dodge_bullets))

	user.next_move_modifier /= 1.25 // Overdosing makes you a liiitle faster but you know has some really bad consequences
	if(IS_CHANGELING(user))
		var/datum/antagonist/changeling/cling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		cling.chem_recharge_slowdown += 1
		changeling_chemical_tracker += 1

	if(!user.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = user?.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]

	var/list/col_filter_ourple = list(1,0,0,0, 0,0.5,0,0, 0,0,1,0, 0,0,0,1)

	for(var/filter in game_plane_master_controller.get_filters(MEPHEDRONE_SCREEN_FILTER))
		animate(filter, loop = -1, color = col_filter_ourple, time = 4 SECONDS, easing = BOUNCE_EASING)
	return ..()


/datum/reagent/mephedrone/overdose_end(mob/living/user)
	UnregisterSignal(user, COMSIG_ATOM_PREHIT)

	user.next_move_modifier *= 1.25

	if(IS_CHANGELING(user))
		var/datum/antagonist/changeling/cling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling_chemical_tracker > 0) //Just in case this gets called somehow after on_remove is done
			cling.chem_recharge_slowdown -= 1
			changeling_chemical_tracker -= 1

	if(!user.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = user.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME] //Restart the base filters.

	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_FILTER)

	game_plane_master_controller.remove_filter(MEPHEDRONE_SCREEN_BLUR)

	var/static/list/col_filter_green = list(0.66,0,0,0, 0,1,0,0, 0,0,0.66,0, 0,0,0,1)

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_FILTER, 10, color_matrix_filter(col_filter_green, FILTER_COLOR_RGB))

	game_plane_master_controller.add_filter(MEPHEDRONE_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))


/datum/reagent/mephedrone/overdose_process(mob/living/carbon/user, severity)

	if(!ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/obj/item/organ/internal/our_heart = human_user.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(our_heart)
			our_heart.internal_receive_damage(0.9, TRUE)
		else
			handle_heartless(user, 0.9)


	if(prob(5))
		user.custom_emote(EMOTE_VISIBLE, "кашля%(ет, ют)% кровью!")
		user.bleed(5)

	if(prob(10))
		user.add_filter(MEPHEDRONE_OVERDOSE_BLUR_EFFECT, 2, phase_filter(8))
		addtimer(CALLBACK(user, TYPE_PROC_REF(/datum, remove_filter), MEPHEDRONE_OVERDOSE_BLUR_EFFECT), 0.5 SECONDS)

	var/update_flags = STATUS_UPDATE_NONE
	user.Jitter(2.2 SECONDS) // Slowly will build up over time due to low process rate
	update_flags |= user.adjustToxLoss(1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

//This proc is for IPCS, skeletons, golems, and people with corazone. IPCS are treated lightly, power loss and brute on OD. Used to be brain damage but new brain damage is much deadlier and ipcs would fall asleep in the middle of using the drug
//IPC brute damage scales over time. Endleslly running an OD on this will not work well. Theoretically they could run a low dose well, but over 10 minutes will make them explode on wear off.
//Otherwise, the user hallucinates a bunch, and as well takes stamina damage. This will block passive stamina regen, and most likely require antistun drugs to use as well

/datum/reagent/mephedrone/proc/handle_heartless(mob/living/carbon/user, damage_input)
	if(!ismachineperson(user))
		user.Hallucinate(damage_input * 50 SECONDS)
		user.apply_damage(damage_input * 3, STAMINA)
	if(damage_input >= 0.9) //This is the input from the OD
		user.adjustBruteLoss((1 + (current_cycle * (damage_input + 0.1) / 100)), TRUE) //Yes, this means an IPC on this drug for 10+ minutes, that has it wear off, will instantly lego. That is funny.
		user.adjust_nutrition(-damage_input * 3.75) // I don't think they should have to charge like twice in the middle of combat. Still will need to charge after however!
	else
		user.adjust_nutrition(-damage_input * 15)

/// This filter proc makes a visual effect where the object is split into fragments, with vertical lines cut out of them. It will appear as 2 seperate things are made of the one object that was cut out
/proc/phase_filter(size)
	. = list("type" = "wave")
	.["x"] = 1
	if(!isnull(size))
		.["size"] = size

// Temp visual that changes color for that bootleg sandevistan effect
/obj/effect/temp_visual/decoy/mephedrone_afterimage
	duration = 0.75 SECONDS
	/// The color matrix it should be at spawn
	var/list/matrix_start = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0.1,0.4,0)
	/// The color matrix it should be by the time it despawns
	var/list/matrix_end = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1, 0,0.5,0,0)

/obj/effect/temp_visual/decoy/mephedrone_afterimage/Initialize(mapload, atom/mimiced_atom, our_duration = 0.75 SECONDS)
	duration = our_duration
	. = ..()
	color = matrix_start
	animate(src, color = matrix_end, time = duration, easing = EASE_OUT)
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

#undef MEPHEDRONE_SCREEN_FILTER
#undef MEPHEDRONE_SCREEN_BLUR

#undef MEPHEDRONE_BLUR_EFFECT
#undef MEPHEDRONE_OVERDOSE_BLUR_EFFECT
#undef CONSTANT_DOSE_DEATH_LIMIT
#undef CONSTANT_DOSE_SAFE_LIMIT
