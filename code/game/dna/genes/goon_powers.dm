#define EAT_MOB_DELAY 30 SECONDS

// WAS: /datum/bioEffect/alcres
/datum/dna/gene/basic/sober
	name = "Трезвость"
	activation_messages = list("Вы чувствуете себя необычайно трезвым.")
	deactivation_messages = list("Вы чувствуете, что вам не помешает крепкий напиток.")
	traits_to_add = list(TRAIT_SOBER)

/datum/dna/gene/basic/sober/New()
	..()
	block = GLOB.soberblock

//WAS: /datum/bioEffect/psychic_resist
/datum/dna/gene/basic/psychic_resist
	name = "Пси-защита"
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

// WAS: /datum/bioEffect/darkcloak
/datum/dna/gene/basic/darkcloak
	name = "Плащ тьмы"
	desc = "Позволяет субъекту излучать вокруг себя слабое свечение, создавая эффект маскировки."
	activation_messages = list("Вы начинаете исчезать в тени.")
	deactivation_messages = list("Вы становитесь полностью видимым.")
	activation_prob = 25
	instability = GENE_INSTABILITY_MODERATE

/datum/dna/gene/basic/darkcloak/New()
	..()
	block = GLOB.shadowblock

/datum/dna/gene/basic/darkcloak/OnMobLife(mob/living/mutant)
	var/turf/simulated/T = get_turf(mutant)
	if(!istype(T))
		return
	var/light_available = T.get_lumcount() * 10
	if(light_available <= 2)
		mutant.alpha_multiply(0.8, ALPHA_SOURCE_SHADOW_CLOAK)
	else
		mutant.alpha_set(1, ALPHA_SOURCE_SHADOW_CLOAK)

/datum/dna/gene/basic/darkcloak/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.alpha_set(1, ALPHA_SOURCE_SHADOW_CLOAK)

//WAS: /datum/bioEffect/chameleon
/datum/dna/gene/basic/chameleon
	name = "Хамелеон"
	desc = "Субъект обретает способность тонко изменять структуру света, чтобы оставаться невидимым до тех пор, пока он остается неподвижным."
	activation_messages = list("Вы чувствуете себя единым целым с окружающим миром.")
	deactivation_messages = list("Вы чувствуете себя необычайно заметным.")
	activation_prob = 25
	instability = GENE_INSTABILITY_MODERATE

/datum/dna/gene/basic/chameleon/New()
	..()
	block = GLOB.chameleonblock

/datum/dna/gene/basic/chameleon/OnMobLife(mob/living/mutant)
	if((world.time - mutant.last_movement) >= 30 && (mutant.mobility_flags & MOBILITY_MOVE) && !HAS_TRAIT(mutant, TRAIT_RESTRAINED))
		mutant.alpha_add(standartize_alpha(-25), ALPHA_SOURCE_CHAMELEON)
	else
		mutant.alpha_set(0.80, ALPHA_SOURCE_CHAMELEON)

/datum/dna/gene/basic/chameleon/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.alpha_set(1, ALPHA_SOURCE_CHAMELEON)

/////////////////////////////////////////////////////////////////////////////////////////

/datum/dna/gene/basic/grant_spell
	var/spelltype

/datum/dna/gene/basic/grant_spell/activate(mob/living/mutant, flags)
	. = ..()
	mutant.AddSpell(new spelltype)

/datum/dna/gene/basic/grant_spell/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.RemoveSpell(spelltype)

// WAS: /datum/bioEffect/cryokinesis
/datum/dna/gene/basic/grant_spell/cryo
	name = "Криокинез"
	desc = "Позволяет субъекту понижать температуру тела окружающих."
	activation_messages = list("Ваши кончики пальцев слегка покалывает от холода.")
	deactivation_messages = list("Ваши пальцы становятся теплее.")
	instability = GENE_INSTABILITY_MODERATE
	spelltype = /datum/action/cooldown/spell/pointed/cryokinesis

/datum/dna/gene/basic/grant_spell/cryo/New()
	..()
	block = GLOB.cryoblock

/datum/action/cooldown/spell/pointed/cryokinesis
	name = "Cryokinesis"
	desc = "Понижает температуру тела выбранного гуманоида."
	cooldown_time = 120 SECONDS
	spell_requirements = NONE
	cast_range = 10
	active_msg = span_notice_alt("Ваш разум становится холодным. Нажмите на цель, чтобы произнести заклинание.")
	deactive_msg = span_notice_alt("Ваш разум возвращается в нормальное состояние.")
	button_icon_state = "genetic_cryo"

/datum/action/cooldown/spell/pointed/cryokinesis/is_valid_target(atom/cast_on)
	return ..() && iscarbon(cast_on)

/datum/action/cooldown/spell/pointed/cryokinesis/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/C = cast_on

	if(HAS_TRAIT(C, TRAIT_RESIST_COLD))
		C.visible_message(span_warning("Облако мелких ледяных кристаллов окутывает [C.name], но почти мгновенно исчезает!"))
		return
	var/handle_suit = FALSE
	if(!ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			if(istype(H.wear_suit, /obj/item/clothing/suit/space))
				handle_suit = TRUE
				if(H.internal)
					H.visible_message(span_warning("[owner] распыля[PLUR_ET_YUT(owner)] облако мелких ледяных кристаллов, сковывая [H]!"),
									span_notice("[owner] распыля[PLUR_ET_YUT(owner)] облако мелких кристалликов льда на визор вашего [H.head]."))
				else
					H.visible_message(span_warning("[owner] распыля[PLUR_ET_YUT(owner)] облако мелких кристаллов льда, поглощая [H]!"),
									span_warning("[owner] распыля[PLUR_ET_YUT(owner)] облако мелких ледяных кристаллов, которые покрывают визор вашего [H.head] и попадают в вентиляционные отверстия!"))

					H.adjust_bodytemperature(-100)
				add_attack_logs(owner, C, "Cryokinesis")
	if(!handle_suit)
		C.adjust_bodytemperature(-200)
		C.ExtinguishMob()

		C.visible_message(span_warning("[owner] распыля[PLUR_ET_YUT(owner)] облако мелких ледяных кристаллов, поглощая [C]!"))
		add_attack_logs(owner, C, "Cryokinesis- NO SUIT/INTERNALS")

///////////////////////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/mattereater
/datum/dna/gene/basic/grant_spell/mattereater
	name = "Пожиратель материи"
	desc = "Позволяет без вреда для здоровья есть практически что-угодно."
	activation_messages = list("Вы чувствуете голод.")
	deactivation_messages = list("Вы больше не чувствуете себя таким голодным.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /datum/action/cooldown/spell/list_target/eat

/datum/dna/gene/basic/grant_spell/mattereater/New()
	..()
	block = GLOB.eatblock

/datum/action/cooldown/spell/list_target/eat
	name = "Eat"
	desc = "Ешьте всё подряд!"
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	button_icon_state = "genetic_eat"
	choose_target_message = "Choose the target of your hunger"
	target_radius = 1
	var/list/types_allowed = list(
		/obj/item,
		/mob/living/carbon/human,
		/mob/living/carbon/alien/larva,
		/mob/living/simple_animal/pet,
		/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/lizard,
		/mob/living/simple_animal/cow,
		/mob/living/simple_animal/spiderbot
	)
	var/list/own_blacklist = list(
		/obj/item/organ,
		/obj/item/implant
	)

/datum/action/cooldown/spell/list_target/eat/get_list_targets(atom/center, target_radius)
	var/list/possible_targets = list()

	for(var/atom/movable/atom in range(target_radius, center))
		if((atom in owner) && is_type_in_list(atom, own_blacklist))
			continue
		if(is_type_in_list(atom, types_allowed))
			if(isitem(atom))
				var/obj/item/item = atom
				if(item.item_flags & ABSTRACT)
					continue
			if(isanimal(atom))
				var/mob/living/simple_animal/animal = atom
				if(!animal.gold_core_spawnable)
					continue
			possible_targets += atom

	return possible_targets

/datum/action/cooldown/spell/list_target/eat/proc/doHeal(mob/user)
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

/datum/action/cooldown/spell/list_target/eat/cast(atom/cast_on)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		if((C.head && (C.head.flags_cover & HEADCOVERSMOUTH)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSMOUTH) && !C.wear_mask.up))
			owner.balloon_alert(owner, "рот чем-то закрыт!")
			return

	var/atom/movable/the_item = cast_on
	if(ishuman(the_item))
		var/mob/living/carbon/human/H = the_item
		var/obj/item/organ/external/limb = H.get_organ(owner.zone_selected)
		if(!istype(limb))
			to_chat(owner, span_warning("Вы не можете съесть эту часть тела!"))
			reset_spell_cooldown()
			return FALSE

		if(istype(limb,/obj/item/organ/external/head))
			// Bullshit, but prevents being unable to clone someone.
			to_chat(owner, span_warning("Вы пытаетесь засунуть голову в свой рот, но у вас ничего не получается!"))
			reset_spell_cooldown()
			return FALSE

		if(ischest(limb))
			// Bullshit, but prevents being able to instagib someone.
			to_chat(owner, span_warning("Вы пытаетесь уместить туловище у себя во рту, но у вас ничего не получается!"))
			reset_spell_cooldown()
			return FALSE

		owner.visible_message(span_danger("[owner] приближа[PLUR_ET_YUT(owner)]ся к [the_item] и начина[PLUR_ET_YUT(owner)] поглощать [limb.name]!"))
		var/oldloc = H.loc
		if(!do_after(owner, EAT_MOB_DELAY, H, NONE))
			owner.balloon_alert(owner, "вас прервали")
		else
			if(!limb || !H)
				return
			if(H.loc != oldloc)
				to_chat(owner, span_danger("Вы упустили [limb]!"))
				return
			owner.visible_message(span_danger("[owner] [pick("отрыва[PLUR_ET_YUT(owner)]","откусыва[PLUR_ET_YUT(owner)]")] [limb] от [the_item]!"))
			playsound(owner.loc, 'sound/items/eatfood.ogg', 50, FALSE)
			limb.droplimb(0, DROPLIMB_SHARP)
			doHeal(owner)
	else
		owner.visible_message(span_danger("[owner] [pick("съеда[PLUR_ET_YUT(owner)]","поглоща[PLUR_ET_YUT(owner)]")] [the_item]."))
		playsound(owner.loc, 'sound/items/eatfood.ogg', 50, FALSE)
		qdel(the_item)
		doHeal(owner)

////////////////////////////////////////////////////////////////////////

//WAS: /datum/bioEffect/jumpy
/datum/dna/gene/basic/grant_spell/jumpy
	name = "Прыгучесть"
	desc = "Позволяет субъекту совершать прыжки на большие расстояния."
	//cooldown = 30
	activation_messages = list("Вы чувствуете силу в своих ногах.")
	deactivation_messages = list("Вы чувствуете, как сила уходит из ваших ног.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /datum/action/cooldown/spell/leap

/datum/dna/gene/basic/grant_spell/jumpy/New()
	..()
	block = GLOB.jumpblock

/datum/action/cooldown/spell/leap
	name = "Jump"
	desc = "Прыгайте на огромные расстояния!"
	cooldown_time = 6 SECONDS
	spell_requirements = NONE
	button_icon_state = "genetic_jump"

/datum/action/cooldown/spell/leap/can_cast_spell(feedback)
	return ..() && !HAS_TRAIT_FROM(owner, TRAIT_MOVE_FLYING, SPELL_LEAP_TRAIT)


/datum/action/cooldown/spell/leap/cast(atom/cast_on)
	. = ..()
	var/failure = FALSE
	var/mob/living/user = cast_on
	if(ismob(user.loc) || user.incapacitated(IGNORE_RESTRAINTS) || user.buckled)
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

		user.visible_message(span_danger("[user.name] дела[PLUR_ET_YUT(user)] огромный скачок!"))
		playsound(user.loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
		if(failure)
			user.Weaken(10 SECONDS)
			user.visible_message(span_warning("[user] пыта[PLUR_ET_YUT(user)]ся отпрыгнуть, но снова оказыва[PLUR_ET_YUT(user)]ся прижатым[PLUR_I(user)] к земле!"),
							span_warning("Вы пытаетесь отпрыгнуть в сторону, но внезапно оказываетесь прижаты к земле!"),
							span_notice("Вы слышите, как напрягаются мощные мышцы, и внезапно раздается грохот, когда тело падает на пол."))
			return FALSE
		var/prevLayer = user.layer
		var/old_pixel_x = user.pixel_x
		var/old_pixel_y = user.pixel_y
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
			user.visible_message(span_danger("[user.name] пада[PLUR_ET_YUT(user)] на землю под весом своего тела!"))
			user.AdjustWeakened(20 SECONDS)

		user.layer = prevLayer
		user.pixel_x = old_pixel_x
		user.pixel_y = old_pixel_y

	if(isobj(user.loc))
		var/obj/container = user.loc
		to_chat(user, span_warning("Вы прыгаете и ударяетесь головой о внутреннюю часть [container]! АЙ!"))
		user.AdjustParalysis(6 SECONDS)
		user.AdjustWeakened(10 SECONDS)
		container.visible_message(span_danger("[user.loc] изда[PLUR_ET_YUT(user)] громкий стук и немного дребезжит."))
		playsound(user.loc, 'sound/effects/bang.ogg', 50, TRUE)
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
	name = "Полиморфизм"
	desc = "Позволяет субъекту изменять свою внешность, чтобы подражать другим."

	spelltype = /datum/action/cooldown/spell/pointed/polymorph
	//cooldown = 1800
	activation_messages = list("Вы как-то не очень похожи на себя.")
	deactivation_messages = list("Вы уверены в своей идентичности.")
	instability = GENE_INSTABILITY_MODERATE

/datum/dna/gene/basic/grant_spell/polymorph/New()
	..()
	block = GLOB.polymorphblock

/datum/action/cooldown/spell/pointed/polymorph
	name = "Polymorph"
	desc = "Подражайте внешности других!"
	cooldown_time = 3 MINUTES
	spell_requirements = NONE
	active_msg = span_notice_alt("Ваше тело становится нестабильным.")
	deactive_msg = span_notice_alt("Ваше тело возвращается в норму.")
	cast_range = 10
	button_icon_state = "genetic_poly"

/datum/action/cooldown/spell/pointed/polymorph/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/polymorph/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	owner.visible_message(span_warning("Тело [owner] смещается и деформируется."))

	spawn(1 SECONDS)
		if(target && owner)
			playsound(owner.loc, 'sound/goonstation/effects/gib.ogg', 50, TRUE)
			var/mob/living/carbon/human/H = owner
			H.UpdateAppearance(target.dna.UI)
			H.real_name = target.real_name
			H.name = target.name

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/empath
/datum/dna/gene/basic/grant_spell/empath
	name = "Эмпатические мысли"
	desc = "Субъект получает возможность читать мысли других людей, чтобы получить определённую информацию."

	spelltype = /datum/action/cooldown/spell/list_target/empath
	activation_messages = list("Вы вдруг стали замечать в окружающих больше, чем раньше.")
	deactivation_messages = list("Вы больше не способны чувствовать намерения других.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_EMPATHY)

/datum/dna/gene/basic/grant_spell/empath/New()
	..()
	block = GLOB.empathblock

/datum/action/cooldown/spell/list_target/empath
	name = "Read Mind"
	desc = "Читайте мысли других людей, чтобы получить информацию."
	cooldown_time = 18 SECONDS
	spell_requirements = NONE
	button_icon_state = "genetic_empath"
	target_radius = 10
	targeting_type = /datum/aoe_targeting/human

/datum/action/cooldown/spell/list_target/empath/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	if(!istype(target))
		to_chat(owner, span_warning("Вы можете использовать это только на других органических существах."))
		return

	if(target.dna?.GetSEState(GLOB.psyresistblock))
		to_chat(owner, span_warning("Вы не можете заглянуть в разум [target.name]!"))
		return

	if(target.stat == DEAD)
		to_chat(owner, span_warning("Вы не можете прочитать мысли мёртвого существа."))
		return
	if(target.health < 0)
		to_chat(owner, span_warning("[target.name] в предсмертном состоянии, а [GEND_HIS_HER(target)] мысли слишком спутаны, чтобы их прочитать."))
		return

	to_chat(owner, span_notice("Чтение мыслей <b>[target.name]:</b>"))

	var/pain_condition = target.health / target.maxHealth
	// lower health means more pain
	var/list/randomthoughts = list("о перекусе","о будущем","о прошлом","о деньгах",
	"о своей причёске","о дальнейших планах","о работе","о космосе","о чём-то забавном","о чём-то грустном",
	"о чём-то раздражающем","о каком-то радостном событии","о всякой ерунде","об ошибках прошлого")
	var/thoughts = "думает [pick(randomthoughts)]"

	if(target.fire_stacks)
		pain_condition -= 0.5
		thoughts = "поглощен[GEND_A_O_Y(target)] огнем"

	switch(pain_condition)
		if(0.81 to INFINITY)
			to_chat(owner, span_notice("<b>Состояние</b>: [target.name] чувству[PLUR_ET_YUT(target)] себя хорошо."))
		if(0.61 to 0.8)
			to_chat(owner, span_notice("<b>Состояние</b>: [target.name] испытыва[PLUR_ET_YUT(target)] слабую боль."))
		if(0.41 to 0.6)
			to_chat(owner, span_notice("<b>Состояние</b>: [target.name] испытыва[PLUR_ET_YUT(target)] умеренную боль."))
		if(0.21 to 0.4)
			to_chat(owner, span_notice("<b>Состояние</b>: [target.name] испытыва[PLUR_ET_YUT(target)] сильную боль."))
		else
			to_chat(owner, span_notice("<b>Состояние</b>: [target.name] испытыва[PLUR_ET_YUT(target)] мучительную боль."))
			thoughts = "дума[PLUR_ET_YUT(target)] о том, что [GEND_HIS_HER(target)] скоро настигнет смерть"

	switch(target.a_intent)
		if(INTENT_HELP)
			to_chat(owner, span_notice("<b>Настроение</b>: Вы улавливаете благожелательные мысли, исходящие от [target.name]."))
		if(INTENT_DISARM)
			to_chat(owner, span_notice("<b>Настроение</b>: Вы улавливаете опасливые мысли, исходящие от [target.name]."))
		if(INTENT_GRAB)
			to_chat(owner, span_notice("<b>Настроение</b>: Вы улавливаете враждебные мысли, исходящие от [target.name]."))
		if(INTENT_HARM)
			to_chat(owner, span_notice("<b>Настроение</b>: Вы улавливаете жестокие мысли, исходящие от [target.name]."))
			for(var/mob/living/L in view(7, target))
				if(target)
					continue
				thoughts = "дума[PLUR_ET_YUT(target)] о том, чтобы ударить [L.name]"
				break
		else
			to_chat(owner, span_notice("<b>Настроение</b>: Вы улавливаете странные мысли, исходящие от [target.name]."))

	if(ishuman(target))
		var/list/numbers = list()
		var/mob/living/carbon/human/H = target
		if(H.mind && H.mind.initial_account)
			numbers += H.mind.initial_account.account_number
			numbers += H.mind.initial_account.remote_access_pin
		if(length(numbers)>0)
			to_chat(owner, span_notice("<b>Числа</b>: Вы чувствуете, что [length(numbers) > 1 ? "числа" : "число"] [english_list(numbers)] [length(numbers) > 1 ? "являются важными" : "является важным"] для [target.name]."))
	to_chat(owner, span_notice("<b>Мысли</b>: [target.name] сейчас [thoughts]."))

	if(HAS_TRAIT(target, TRAIT_EMPATHY))
		to_chat(target, span_warning("Вы чувствуете, что [owner.name] читает ваши мысли."))
	else if(prob(5) || target.mind?.assigned_role == JOB_TITLE_CHAPLAIN)
		to_chat(target, span_warning("Вы чувствуете, что кто-то вторгается в ваши мысли..."))

////////////////////////////////////////////////////////////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/basic/strong
	name = "Сила"
	desc = "Повышает способность субъекта наращивать и удерживать тяжелую мускулатуру."
	activation_messages = list("Вы чувствуете, что ваши мышцы в тонусе!")
	deactivation_messages = list("Вы чувствуете себя хилым и слабым.")
	instability = GENE_INSTABILITY_MINOR

/datum/dna/gene/basic/strong/New()
	..()
	block = GLOB.strongblock

/datum/dna/gene/basic/strong/can_activate(mob/living/carbon/human/mutant, flags)
	if(!ishuman(mutant))
		return FALSE

	if(HAS_TRAIT_FROM(mutant, TRAIT_WEAK_MUSCULS, DNA_TRAIT))
		return FALSE

	if(!HASBIT(SEND_SIGNAL(mutant, COMSIG_CAN_CHANGE_STRENGTH), COMPONENT_CAN_CHANGE_STRENGTH))
		return FALSE

	return ..()

/datum/dna/gene/basic/strong/activate(mob/living/carbon/human/mutant, flags)
	. = ..()
	ADD_TRAIT(mutant, TRAIT_STRONG_MUSCLES, DNA_TRAIT)
	SEND_SIGNAL(mutant, COMSIG_STRENGTH_BORDER_UPDATE)
	mutant.update_body(TRUE)

/datum/dna/gene/basic/strong/deactivate(mob/living/carbon/human/mutant, flags)
	. = ..()
	REMOVE_TRAIT(mutant, TRAIT_STRONG_MUSCLES, DNA_TRAIT)
	SEND_SIGNAL(mutant, COMSIG_STRENGTH_BORDER_UPDATE)
	mutant.update_body(TRUE)

#undef EAT_MOB_DELAY
