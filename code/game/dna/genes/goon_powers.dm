#define EAT_MOB_DELAY 300 // 30s

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name = "Sober"
	activation_messages = list("Вы чувствуете себя необычайно трезвым.")
	deactivation_messages = list("Вы чувствуете, что вам не помешает крепкий напиток.")
	traits_to_add = list(TRAIT_SOBER)


/datum/dna/gene/basic/sober/New()
	..()
	block = GLOB.soberblock


//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name = "Psy-Resist"
	desc = "Повышает эффективность работы секторов мозга, обычно связанных с мета-психическими энергиями."
	activation_messages = list("Ваш разум кажется закрытым.")
	deactivation_messages = list("Вы чувствуете себя незащищенным.")
	traits_to_add = list(TRAIT_PSY_RESIST)


/datum/dna/gene/basic/psychic_resist/New()
	..()
	block = GLOB.psyresistblock


/////////////////////////
// Stealth Enhancers
/////////////////////////

/datum/dna/gene/basic/stealth
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/stealth/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.alpha = initial(mutant.alpha)


// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/stealth/darkcloak
	name = "Cloak of Darkness"
	desc = "Позволяет субъекту излучать вокруг себя слабое свечение, создавая эффект маскировки."
	activation_messages = list("Вы начинаете исчезать в тени.")
	deactivation_messages = list("Вы становитесь полностью видимым.")
	activation_prob = 25


/datum/dna/gene/basic/stealth/darkcloak/New()
	..()
	block = GLOB.shadowblock


/datum/dna/gene/basic/stealth/darkcloak/OnMobLife(mob/living/mutant)
	var/turf/simulated/T = get_turf(mutant)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount() * 10
	if(light_available <= 2)
		mutant.alpha = round(mutant.alpha * 0.8)
	else
		mutant.alpha = initial(mutant.alpha)


//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/stealth/chameleon
	name = "Chameleon"
	desc = "Субъект обретает способность тонко изменять структуру света, чтобы оставаться невидимым до тех пор, пока он остается неподвижным."
	activation_messages = list("Вы чувствуете себя единым целым с окружающим миром.")
	deactivation_messages = list("Вы чувствуете себя необычайно заметным.")
	activation_prob = 25


/datum/dna/gene/basic/stealth/chameleon/New()
	..()
	block = GLOB.chameleonblock


/datum/dna/gene/basic/stealth/chameleon/OnMobLife(mob/living/mutant)
	if((world.time - mutant.last_movement) >= 30 && (mutant.mobility_flags & MOBILITY_MOVE) && !HAS_TRAIT(mutant, TRAIT_RESTRAINED))
		mutant.alpha -= 25
	else
		mutant.alpha = round(255 * 0.80)


/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/obj/effect/proc_holder/spell/spelltype


/datum/dna/gene/basic/grant_spell/activate(mob/living/mutant, flags)
	. = ..()
	mutant.AddSpell(new spelltype(null))


/datum/dna/gene/basic/grant_spell/deactivate(mob/living/mutant, flags)
	. = ..()
	for(var/obj/effect/proc_holder/spell/spell as anything in mutant.mob_spell_list)
		if(istype(spell, spelltype))
			mutant.RemoveSpell(spell)


/datum/dna/gene/basic/grant_verb
	var/verbtype


/datum/dna/gene/basic/grant_verb/activate(mob/living/mutant, flags)
	. = ..()
	add_verb(mutant, verbtype)


/datum/dna/gene/basic/grant_verb/deactivate(mob/living/mutant, flags)
	. = ..()
	remove_verb(mutant, verbtype)


// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Cryokinesis"
	desc = "Позволяет субъекту понижать температуру тела окружающих."
	activation_messages = list("Ваши кончики пальцев слегка покалывает от холода.")
	deactivation_messages = list("Ваши пальцы становятся теплее.")
	instability = GENE_INSTABILITY_MODERATE
	spelltype = /obj/effect/proc_holder/spell/cryokinesis


/datum/dna/gene/basic/grant_spell/cryo/New()
	..()
	block = GLOB.cryoblock


/obj/effect/proc_holder/spell/cryokinesis
	name = "Cryokinesis"
	desc = "Понижает температуру тела выбранного гуманоида."
	base_cooldown = 120 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message	= span_notice("Ваш разум становится холодным. Нажмите на цель, чтобы произнести заклинание.")
	selection_deactivated_message = span_notice("Ваш разум возвращается в нормальное состояние.")

	var/list/compatible_mobs = list(/mob/living/carbon/human)

	action_icon_state = "genetic_cryo"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/cryokinesis/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.allowed_type = /mob/living/carbon
	T.click_radius = 0
	T.try_auto_target = FALSE // Give the clueless geneticists a way out and to have them not target themselves
	T.selection_type = SPELL_SELECTION_RANGE
	T.include_user = TRUE
	return T


/obj/effect/proc_holder/spell/cryokinesis/cast(list/targets, mob/user = usr)

	var/mob/living/carbon/C = targets[1]

	if(HAS_TRAIT(C, TRAIT_RESIST_COLD))
		C.visible_message(span_warning("Облако мелких ледяных кристаллов окутывает [C.name], но почти мгновенно исчезает!"))
		return
	var/handle_suit = FALSE
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = TRUE
				if(H.internal)
					H.visible_message(span_warning("[user] распыля[pluralize_ru(user, "ет", "ют")] облако мелких ледяных кристаллов, сковывая [H]!"),
									span_notice("[user] распыля[pluralize_ru(user, "ет", "ют")] облако мелких кристалликов льда на визор вашего [H.head]."))
				else
					H.visible_message(span_warning("[user] распыля[pluralize_ru(user, "ет", "ют")] облако мелких кристаллов льда, поглощая [H]!"),
									span_warning("[user] распыля[pluralize_ru(user, "ет", "ют")] облако мелких ледяных кристаллов, которые покрывают визор вашего [H.head] и попадают в вентиляционные отверстия!"))

					H.adjust_bodytemperature(-100)
				add_attack_logs(user, C, "Cryokinesis")
	if(!handle_suit)
		C.adjust_bodytemperature(-200)
		C.ExtinguishMob()

		C.visible_message(span_warning("[user] распыля[pluralize_ru(user, "ет", "ют")] облако мелких ледяных кристаллов, поглощая [C]!"))
		add_attack_logs(user, C, "Cryokinesis- NO SUIT/INTERNALS")


/obj/effect/self_deleting
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	icon = null
	desc = ""
	//layer = 15


/obj/effect/self_deleting/New(atom/location, icon/I, duration = 20, oname = "something")
	. = ..()
	name = oname
	loc=location
	icon = I
	QDEL_IN(src, duration)

///////////////////////////////////////////////////////////////////////////////////////////


// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Matter Eater"
	desc = "Позволяет без вреда для здоровья есть практически что-угодно."
	activation_messages = list("Вы чувствуете голод.")
	deactivation_messages = list("Вы больше не чувствуете себя таким голодным.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/eat


/datum/dna/gene/basic/grant_spell/mattereater/New()
	..()
	block = GLOB.eatblock


/obj/effect/proc_holder/spell/eat
	name = "Eat"
	desc = "Ешьте всё подряд!"

	base_cooldown = 30 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_eat"


/obj/effect/proc_holder/spell/eat/create_new_targeting()
	return new /datum/spell_targeting/matter_eater


/obj/effect/proc_holder/spell/eat/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	. = ..()
	if(!.)
		return
	var/can_eat = TRUE
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.head && (C.head.flags_cover & HEADCOVERSMOUTH)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSMOUTH) && !C.wear_mask.up))
			if(show_message)
				balloon_alert(C, "рот чем-то закрыт!")
			can_eat = FALSE
	return can_eat


/obj/effect/proc_holder/spell/eat/proc/doHeal(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/should_update_health = FALSE
		var/update_damage_icon = NONE
		for(var/name in H.bodyparts_by_name)
			var/obj/item/organ/external/affecting = null
			if(!H.bodyparts_by_name[name])
				continue
			affecting = H.bodyparts_by_name[name]
			if(!isexternalorgan(affecting))
				continue
			var/brute_was = affecting.brute_dam
			update_damage_icon |= affecting.heal_damage(4, updating_health = FALSE)
			if(affecting.brute_dam != brute_was)
				should_update_health = TRUE
		if(should_update_health)
			H.updatehealth("[name] heal")
		if(update_damage_icon)
			H.UpdateDamageIcon()


/obj/effect/proc_holder/spell/eat/cast(list/targets, mob/user = usr)
	if(!targets.len)
		balloon_alert(user, "слишком далеко")
		return

	var/atom/movable/the_item = targets[1]
	if(ishuman(the_item))
		var/mob/living/carbon/human/H = the_item
		var/obj/item/organ/external/limb = H.get_organ(user.zone_selected)
		if(!istype(limb))
			to_chat(user, span_warning("Вы не можете съесть эту часть тела!"))
			revert_cast()
			return FALSE

		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(user, span_warning("Вы пытаетесь засунуть голову в свой рот, но у вас ничего не получается!"))
			revert_cast()
			return FALSE

		if(istype(limb,/obj/item/organ/external/chest))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(user, span_warning("Вы пытаетесь уместить туловище у себя во рту, но у вас ничего не получается!"))
			revert_cast()
			return FALSE

		user.visible_message(span_danger("[user] приближа[pluralize_ru(user, "ет", "ют")]ся к [the_item] и начина[pluralize_ru(user, "ет", "ют")] поглощать [limb.name]!"))
		var/oldloc = H.loc
		if(!do_after(user, EAT_MOB_DELAY, H, NONE))
			balloon_alert(user, "вас прервали")
		else
			if(!limb || !H)
				return
			if(H.loc != oldloc)
				to_chat(user, span_danger("Вы упустили [limb]!"))
				return
			user.visible_message(span_danger("[user] [pick("отрыва[pluralize_ru(user, "ет", "ют")]","откусыва[pluralize_ru(user, "ет", "ют")]")] [limb] от [the_item]!"))
			playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
			limb.droplimb(0, DROPLIMB_SHARP)
			doHeal(user)
	else
		user.visible_message(span_danger("[user] [pick("съеда[pluralize_ru(user, "ет", "ют")]","поглоща[pluralize_ru(user, "ет", "ют")]")] [the_item]."))
		playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
		qdel(the_item)
		doHeal(user)


////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Jumpy"
	desc = "Позволяет субъекту совершать прыжки на большие расстояния."
	//cooldown = 30
	activation_messages = list("Вы чувствуете силу в своих ногах.")
	deactivation_messages = list("Вы чувствуете, как сила уходит из ваших ног.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/leap


/datum/dna/gene/basic/grant_spell/jumpy/New()
	..()
	block = GLOB.jumpblock


/obj/effect/proc_holder/spell/leap
	name = "Jump"
	desc = "Прыгайте на огромные расстояния!"

	base_cooldown = 6 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_jump"


/obj/effect/proc_holder/spell/leap/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/leap/cast(list/targets, mob/living/user = usr)
	var/failure = FALSE
	if(ismob(user.loc) || user.incapacitated(INC_IGNORE_RESTRAINED) || user.buckled)
		to_chat(user, span_warning("Вы не можете прыгнуть прямо сейчас!"))
		return
	var/turf/turf_to_check = get_turf(user)
	if(user.can_z_move(DOWN, turf_to_check))
		to_chat(user, span_warning("Вам не от чего оттолкнуться!"))
		return

	if(isturf(user.loc))
		if(HAS_TRAIT(user, TRAIT_RESTRAINED))//Why being pulled while cuffed prevents you from moving
			var/mob/living/puller = user.pulledby
			if(puller && !puller.stat && (puller.mobility_flags & MOBILITY_MOVE) && user.Adjacent(puller))
				failure = TRUE
			else if(puller)
				puller.stop_pulling()

		user.visible_message(span_danger("[user.name] дела[pluralize_ru(user, "ет", "ют")] огромный скачок!"))
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
		if(failure)
			user.Weaken(10 SECONDS)
			user.visible_message(span_warning("[user] пыта[pluralize_ru(user, "ет", "ют")]ся отпрыгнуть, но снова оказыва[pluralize_ru(user, "ет", "ют")]ся прижатым[pluralize_ru(user, "", "и")] к земле!"),
							span_warning("Вы пытаетесь отпрыгнуть в сторону, но внезапно оказываетесь прижаты к земле!"),
							span_notice("Вы слышите, как напрягаются мощные мышцы, и внезапно раздается грохот, когда тело падает на пол."))
			return FALSE
		var/prevLayer = user.layer
		user.layer = LOW_LANDMARK_LAYER

		ADD_TRAIT(user, TRAIT_MOVE_FLYING, SPELL_LEAP_TRAIT)

		for(var/i=0, i<10, i++)
			step(user, user.dir)
			if(i < 5) user.pixel_y += 8
			else user.pixel_y -= 8
			sleep(1)
		REMOVE_TRAIT(user, TRAIT_MOVE_FLYING, SPELL_LEAP_TRAIT)

		if(!(user.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && !user.currently_z_moving) // in case he could fly after
			var/turf/pitfall = get_turf(user)
			pitfall?.zFall(user)

		else if(HAS_TRAIT(user, TRAIT_FAT) && prob(66))
			user.visible_message(span_danger("[user.name] пада[pluralize_ru(user, "ет", "ют")] на землю под весом своего тела!"))
			//playsound(user.loc, 'zhit.wav', 50, 1)
			user.AdjustWeakened(20 SECONDS)

		user.layer = prevLayer

	if(isobj(user.loc))
		var/obj/container = user.loc
		to_chat(user, span_warning("Вы прыгаете и ударяетесь головой о внутреннюю часть [container]! АЙ!"))
		user.AdjustParalysis(6 SECONDS)
		user.AdjustWeakened(10 SECONDS)
		container.visible_message(span_danger("[user.loc] изда[pluralize_ru(user, "ет", "ют")] громкий стук и немного дребезжит."))
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0


////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/polymorphism

/datum/dna/gene/basic/grant_spell/polymorph
	name = "Polymorphism"
	desc = "Позволяет субъекту изменять свою внешность, чтобы подражать другим."

	spelltype = /obj/effect/proc_holder/spell/polymorph
	//cooldown = 1800
	activation_messages = list("Вы как-то не очень похожи на себя.")
	deactivation_messages = list("Вы уверены в своей идентичности.")
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/grant_spell/polymorph/New()
	..()
	block = GLOB.polymorphblock


/obj/effect/proc_holder/spell/polymorph
	name = "Polymorph"
	desc = "Подражайте внешности других!"
	base_cooldown = 3 MINUTES

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	selection_activated_message	= span_notice("Ваше тело становится нестабильным.")
	selection_deactivated_message = span_notice("Ваше тело возвращается в норму.")

	action_icon_state = "genetic_poly"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/polymorph/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.click_radius = -1
	T.range = 1
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/polymorph/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message(span_warning("Тело [user] смещается и деформируется."))

	spawn(1 SECONDS)
		if(target && user)
			playsound(user.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
			var/mob/living/carbon/human/H = user
			H.UpdateAppearance(target.dna.UI)
			H.real_name = target.real_name
			H.name = target.name

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_spell/empath
	name = "Empathic Thought"
	desc = "Субъект получает возможность читать мысли других людей, чтобы получить определённую информацию."

	spelltype = /obj/effect/proc_holder/spell/empath
	activation_messages = list("Вы вдруг стали замечать в окружающих больше, чем раньше.")
	deactivation_messages = list("Вы больше не способны чувствовать намерения других.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_EMPATHY)


/datum/dna/gene/basic/grant_spell/empath/New()
	..()
	block = GLOB.empathblock


/obj/effect/proc_holder/spell/empath
	name = "Read Mind"
	desc = "Читайте мысли других людей, чтобы получить информацию."
	base_cooldown = 18 SECONDS
	clothes_req = FALSE
	human_req = TRUE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_empath"


/obj/effect/proc_holder/spell/empath/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living/carbon
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/empath/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/M in targets)
		if(!iscarbon(M))
			to_chat(user, span_warning("Вы можете использовать это только на других органических существах."))
			return

		if(M.dna?.GetSEState(GLOB.psyresistblock))
			to_chat(user, span_warning("Вы не можете заглянуть в разум [M.name]!"))
			return

		if(M.stat == 2)
			to_chat(user, span_warning("Вы не можете прочитать мысли мёртвого существа."))
			return
		if(M.health < 0)
			to_chat(user, span_warning("[M.name] в предсмертном состоянии, а [genderize_ru(M.gender, "его", "её", "его", "их")] мысли слишком спутаны, чтобы их прочитать."))
			return

		to_chat(user, span_notice("Чтение мыслей <b>[M.name]:</b>"))

		var/pain_condition = M.health / M.maxHealth
		// lower health means more pain
		var/list/randomthoughts = list("о перекусе","о будущем","о прошлом","о деньгах",
		"о своей причёске","о дальнейших планах","о работе","о космосе","о чём-то забавном","о чём-то грустном",
		"о чём-то раздражающем","о каком-то радостном событии","о всякой ерунде","об ошибках прошлого")
		var/thoughts = "думает [pick(randomthoughts)]"

		if(M.fire_stacks)
			pain_condition -= 0.5
			thoughts = "поглощ[pluralize_ru(M.gender, "ён", "ены")] огнем"

		if(M.radiation)
			pain_condition -= 0.25

		switch(pain_condition)
			if(0.81 to INFINITY)
				to_chat(user, span_notice("<b>Состояние</b>: [M.name] чувству[pluralize_ru(M.gender, "ет", "ют")] себя хорошо."))
			if(0.61 to 0.8)
				to_chat(user, span_notice("<b>Состояние</b>: [M.name] испытыва[pluralize_ru(M.gender, "ет", "ют")] слабую боль."))
			if(0.41 to 0.6)
				to_chat(user, span_notice("<b>Состояние</b>: [M.name] испытыва[pluralize_ru(M.gender, "ет", "ют")] умеренную боль."))
			if(0.21 to 0.4)
				to_chat(user, span_notice("<b>Состояние</b>: [M.name] испытыва[pluralize_ru(M.gender, "ет", "ют")] сильную боль."))
			else
				to_chat(user, span_notice("<b>Состояние</b>: [M.name] испытыва[pluralize_ru(M.gender, "ет", "ют")] мучительную боль."))
				thoughts = "дума[pluralize_ru(M.gender, "ет", "ют")] о том, что [genderize_ru(M.gender, "его", "её", "его", "их")] скоро настигнет смерть"

		switch(M.a_intent)
			if(INTENT_HELP)
				to_chat(user, span_notice("<b>Настроение</b>: Вы улавливаете благожелательные мысли, исходящие от [M.name]."))
			if(INTENT_DISARM)
				to_chat(user, span_notice("<b>Настроение</b>: Вы улавливаете опасливые мысли, исходящие от [M.name]."))
			if(INTENT_GRAB)
				to_chat(user, span_notice("<b>Настроение</b>: Вы улавливаете враждебные мысли, исходящие от [M.name]."))
			if(INTENT_HARM)
				to_chat(user, span_notice("<b>Настроение</b>: Вы улавливаете жестокие мысли, исходящие от [M.name]."))
				for(var/mob/living/L in view(7,M))
					if(L == M)
						continue
					thoughts = "дума[pluralize_ru(M.gender, "ет", "ют")] о том, чтобы ударить [L.name]"
					break
			else
				to_chat(user, span_notice("<b>Настроение</b>: Вы улавливаете странные мысли, исходящие от [M.name]."))

		if(ishuman(M))
			var/numbers[0]
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.initial_account)
				numbers += H.mind.initial_account.account_number
				numbers += H.mind.initial_account.remote_access_pin
			if(numbers.len>0)
				to_chat(user, span_notice("<b>Числа</b>: Вы чувствуете, что [numbers.len > 1 ? "числа" : "число"] [english_list(numbers)] [numbers.len > 1 ? "являются важными" : "является важным"] для [M.name]."))
		to_chat(user, span_notice("<b>Мысли</b>: [M.name] сейчас [thoughts]."))

		if(HAS_TRAIT(M, TRAIT_EMPATHY))
			to_chat(M, span_warning("Вы чувствуете, что [user.name] читает ваши мысли."))
		else if(prob(5) || M.mind?.assigned_role == JOB_TITLE_CHAPLAIN)
			to_chat(M, span_warning("Вы чувствуете, что кто-то вторгается в ваши мысли..."))


////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/basic/strong
	name = "Strong"
	desc = "Повышает способность субъекта наращивать и удерживать тяжелую мускулатуру."
	activation_messages = list("Вы чувствуете, что ваши мышцы в тонусе!")
	deactivation_messages = list("Вы чувствуете себя хилым и слабым.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_GENE_STRONG)


/datum/dna/gene/basic/strong/New()
	..()
	block = GLOB.strongblock


/datum/dna/gene/basic/strong/can_activate(mob/living/mutant, flags)
	if(!ishuman(mutant) || HAS_TRAIT(mutant, TRAIT_GENE_WEAK))
		return FALSE
	return ..()


/datum/dna/gene/basic/strong/activate(mob/living/carbon/human/mutant, flags)
	. = ..()
	RegisterSignal(mutant, COMSIG_HUMAN_SPECIES_CHANGED, PROC_REF(on_species_change))
	add_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/deactivate(mob/living/carbon/human/mutant, flags)
	. = ..()
	UnregisterSignal(mutant, COMSIG_HUMAN_SPECIES_CHANGED)
	remove_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/proc/on_species_change(mob/living/carbon/human/mutant, datum/species/old_species)
	SIGNAL_HANDLER

	if(old_species.name != mutant.dna.species.name)
		remove_strong_modifiers(mutant, old_species)
		add_strong_modifiers(mutant)


/datum/dna/gene/basic/strong/proc/add_strong_modifiers(mob/living/carbon/human/mutant)
	mutant.physiology.tail_strength_mod *= 1.25
	switch(mutant.dna.species.name)
		if(SPECIES_VULPKANIN, SPECIES_DRASK, SPECIES_UNATHI)
			mutant.physiology.grab_resist_mod *= 1.1
			mutant.physiology.punch_damage_low += 1
			mutant.physiology.punch_damage_high += 2
		if(SPECIES_HUMAN)
			mutant.physiology.grab_resist_mod *= 1.25
			mutant.physiology.punch_damage_low += 3
			mutant.physiology.punch_damage_high += 4
		else
			mutant.physiology.grab_resist_mod *= 1.15
			mutant.physiology.punch_damage_low += 2
			mutant.physiology.punch_damage_high += 3


/datum/dna/gene/basic/strong/proc/remove_strong_modifiers(mob/living/carbon/human/mutant, datum/species/species)
	if(!species)
		species = mutant.dna.species
	mutant.physiology.tail_strength_mod /= 1.25
	switch(species.name)
		if(SPECIES_VULPKANIN, SPECIES_DRASK, SPECIES_UNATHI)
			mutant.physiology.grab_resist_mod /= 1.1
			mutant.physiology.punch_damage_low -= 1
			mutant.physiology.punch_damage_high -= 2
		if(SPECIES_HUMAN)
			mutant.physiology.grab_resist_mod /= 1.25
			mutant.physiology.punch_damage_low -= 3
			mutant.physiology.punch_damage_high -= 4
		else
			mutant.physiology.grab_resist_mod /= 1.15
			mutant.physiology.punch_damage_low -= 2
			mutant.physiology.punch_damage_high -= 3

