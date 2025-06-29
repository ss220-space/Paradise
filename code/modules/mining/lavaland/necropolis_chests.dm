//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "Он внимательно наблюдает за тобой."
	ru_names = list(
		NOMINATIVE = "сундук некрополя",
		GENITIVE = "сундука некрополя",
		DATIVE = "сундуку некрополя",
		ACCUSATIVE = "сундук некрополя",
		INSTRUMENTAL = "сундуком некрополя",
		PREPOSITIONAL = "сундуке некрополя"
	)
	icon_state = "necrocrate"
	icon_opened = "necrocrateopen"
	icon_closed = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "Он подозрительно наблюдает за тобой."

/obj/structure/closet/crate/necropolis/tendril/populate_contents()
	switch(rand(1, 32))
		if(1)
			new /obj/item/shared_storage(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(4)
			new /obj/item/organ/internal/cyberimp/arm/katana(src)
		if(5)
			new /obj/item/book_of_babel(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(8)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(13)
			new /obj/item/jacobs_ladder(src)
		if(14)
			new /obj/item/nullrod/scythe/talking(src)
		if(15)//select and spawn a random nullrod that a chaplain could choose from
			var/path = pick(subtypesof(/obj/item/nullrod))
			new path(src)
		if(16)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(17)
			new /obj/item/organ/internal/heart/gland/heals(src)
		if(18)
			new /obj/item/warp_cube/red(src)
		if(19)
			new /obj/item/wisp_lantern(src)
		if(20)
			new /obj/item/immortality_talisman(src)
		if(21)
			new /obj/item/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23, 24)
			switch(rand(1, 4))
				if(1)
					new /obj/item/clothing/suit/space/hardsuit/champion(src)
				if(2)
					new /obj/item/clothing/suit/space/hardsuit/champion/templar(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
				if(3)
					new /obj/item/clothing/suit/space/hardsuit/champion/templar/premium(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater(src)
				if(4)
					new /obj/item/clothing/suit/space/hardsuit/champion/inquisitor(src)
					new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
		if(25)
			new /obj/item/eflowers(src)
		if(26)
			new /obj/item/rune_scimmy(src)
		if(27)
			new /obj/item/dnainjector/midgit(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
		if(28)
			switch(rand(1, 4))
				if(1)
					new /obj/item/twohanded/kinetic_crusher/mega(src)
				if(2)
					new /obj/item/gun/energy/plasmacutter/shotgun/mega(src)
				if(3)
					new /obj/item/gun/energy/plasmacutter/adv/mega(src)
				if(4)
					new /obj/item/gun/energy/kinetic_accelerator/mega(src)
		if(29)
			new /obj/item/clothing/suit/hooded/clockrobe_fake(src)
			new /obj/item/clothing/gloves/clockwork_fake(src)
			new /obj/item/clothing/shoes/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)
		if(30)
			new /obj/item/clothing/suit/armor/clockwork_fake(src)
			new /obj/item/clothing/head/helmet/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)
		if(31)
			new /obj/item/spellbook/oneuse/goliath_dash(src)
		if(32)
			new /obj/item/spellbook/oneuse/watchers_look(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"
	ru_names = list(
		NOMINATIVE = "загадочный сундук",
		GENITIVE = "загадочного сундука",
		DATIVE = "загадочному сундуку",
		ACCUSATIVE = "загадочный сундук",
		INSTRUMENTAL = "загадочным сундуком",
		PREPOSITIONAL = "загадочном сундуке"
	)

/obj/structure/closet/crate/necropolis/puzzle/populate_contents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/New()
	. = ..()
	blueprint = new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	build_type = PROTOLATHE
	req_tech = null	// Unreachable by tech researching.

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	category = list("Mining")

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater
	category = list("Mining")

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts
	category = list("Mining")

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(MAT_METAL = 4000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_BLUESPACE = 4000)
	reagents_list = list("blood" = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty
	category = list("Mining")

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "Деревянный посох, размером с вашу руку. На нём змея вырезана. От него прям веет ответственностью и желанием помогать другим."
	ru_names = list(
		NOMINATIVE = "посох асклепия",
		GENITIVE = "посоха асклепия",
		DATIVE = "посоху асклепия",
		ACCUSATIVE = "посох асклепия",
		INSTRUMENTAL = "посохом асклепия",
		PREPOSITIONAL = "посохе асклепия"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "asclepius_dormant"
	item_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, span_warning("Резьба змеи, кажется, оживает на мгновение, прежде чем вернуться в свое спящее состояние, словно она находит вас недостойным её клятвы."))
		return
	var/mob/living/carbon/itemUser = user
	if(itemUser.l_hand == src)
		usedHand = 1
	if(itemUser.r_hand == src)
		usedHand = 0
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, span_warning("Вы не сможете нести ответственность более чем за один посох!"))
		return
	var/failText = span_warning("Змея недовольна вашей неполной клятвой и возвращается на жезл, застывая в деревянном обличье. Вы должны стоять неподвижно, принося клятву!")
	to_chat(itemUser, span_notice("Деревянная змея на жезле внезапно оживает и начинает сползать по вашей руке! Желание помогать другим становится невыносимо сильным..."))
	if(do_after(itemUser, 4 SECONDS, itemUser, max_interact_count = 1))
		itemUser.say("Клянусь Аполлоном врачом, Асклепием, всеми богами и богинями, беря их в свидетели, исполнять честно, соответственно моим силам и здравому смыслу, следующую клятву:")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду применять во благо больного все необходимые меры, воздерживаясь от причинения всякого вреда и несправедливости.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду предотвращать болезнь всякий раз, как смогу, поскольку предотвращение предпочтительнее, чем лечение.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я не выдам никому просимого у меня смертельного средства и не покажу пути для исполнения подобного замысла.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду уважать личную жизнь своих пациентов, поскольку их проблемы раскрываются мне не для того, чтобы о них мог узнать весь мир. Особенно с большой осторожностью я обязуюсь поступать в вопросах жизни и смерти. Если мне будет дано спасти жизнь — я выражу благодарность. Но также может оказаться в моей власти и лишение жизни, эта колоссальная ответственность должна встречаться с великим смирением и осознанием моей собственной бренности.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Я буду помнить, что остаюсь членом общества, но с особыми обязательствами ко всем моим собратьям, как к немощным, так и к здоровым телом и умом.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("Пока я не нарушаю эту клятву, да смогу я наслаждаться этим, заслуженно чтимым, искусством, пока я живу и меня вспоминают с любовью. Да буду я всегда действовать так, чтобы сохранить лучшие традиции моего призвания, и буду долго я испытывать радость исцеления тех, кто обращается за моей помощью.")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, span_notice("Змея, довольная вашей клятвой, намертво прирастает к вашему предплечью. Ваши мысли теперь вращаются только вокруг помощи другим, а вред - всего лишь смутное, греховное воспоминание..."))
	var/datum/status_effect/hippocraticOath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags |= DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))
	desc = "Короткий деревянный посох с мистической змеёй, намертво приросшей к вашему предплечью. Он излучает целительную энергию, распространяющуюся на вас и окружающих."
	icon_state = "asclepius_active"
	item_state = "asclepius_active"
	activated = TRUE


// enchanced flowers
#define COOLDOWN_SUMMON (1 MINUTES)

/obj/item/eflowers
	name ="enchanted flowers"
	desc = "Очаровательный букет, делающий носителя дружелюбным в глазах фауны. Сожмите букет, чтобы призвать приручённых существ. Не призывает мегафауну. <b>Для приручения мегафауны требуется 35 контактов.</b>"
	ru_names = list(
		NOMINATIVE = "зачарованные цветы",
		GENITIVE = "зачарованных цветов",
		DATIVE = "зачарованным цветам",
		ACCUSATIVE = "зачарованные цветы",
		INSTRUMENTAL = "зачарованными цветами",
		PREPOSITIONAL = "зачарованных цветах"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "eflower"
	var/next_summon = 0
	var/list/summons = list()
	attack_verb = list("коснулся", "погладил", "провёл")

/obj/item/eflowers/attack_self(mob/user)
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(next_summon > world.time)
		to_chat(user, span_warning("Вы пока не можете этого сделать!"))
		return
	if(is_station_level(T.z) && !A.outdoors)
		to_chat(user, span_warning("Кажется, призывать фауну в помещении – плохая идея."))
		return
	user.visible_message(span_warning("[user] протягивает букет, призывая союзников!"))
	for(var/mob/m in summons)
		m.forceMove(T)
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	next_summon = world.time + COOLDOWN_SUMMON

/obj/item/eflowers/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/mob/living/simple_animal/M = target
	if(istype(M))
		if(M.client)
			to_chat(user, span_warning("[capitalize(M.declent_ru(NOMINATIVE))] слишком умён для приручения!"))
			return
		if(M.stat)
			to_chat(user, span_warning("[capitalize(M.declent_ru(NOMINATIVE))] мёртв!"))
			return
		if(M.faction == user.faction)
			to_chat(user, span_warning("[capitalize(M.declent_ru(NOMINATIVE))] уже на вашей стороне!"))
			return
		if(M.sentience_type == SENTIENCE_BOSS)
			var/datum/status_effect/taming/G = M.has_status_effect(STATUS_EFFECT_TAMING)
			if(!G)
				M.apply_status_effect(STATUS_EFFECT_TAMING, user)
			else
				G.add_tame(G.tame_buildup)
				if(ISMULTIPLE(G.tame_crit-G.tame_amount, 5))
					to_chat(user, span_notice("Требуется ещё [G.tame_crit-G.tame_amount] контактов, чтобы [M.declent_ru(NOMINATIVE)] принял вашу доброту!"))
			return
		if(M.sentience_type != SENTIENCE_ORGANIC)
			to_chat(user, span_warning("[capitalize(M.declent_ru(ACCUSATIVE))] невозможно приручить!"))
			return
		if(!do_after(user, 1.5 SECONDS, M))
			return
		M.visible_message(span_notice("[capitalize(M.declent_ru(NOMINATIVE))] выглядит умиротворённым после контакта с букетом!"))
		M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
		M.drop_loot()
		M.loot = list()
		M.faction = user.faction
		summons |= M
	..()

//Runite Scimitar. Some weird runescape reference
/obj/item/rune_scimmy
	name = "rune scimitar"
	desc = "Изогнутый меч из неизвестного металла. При взгляде на него возникает потустороннее желание продать его за \"30k\", что бы это ни значило."
	ru_names = list(
		NOMINATIVE = "рунический ятаган",
		GENITIVE = "рунического ятагана",
		DATIVE = "руническому ятагану",
		ACCUSATIVE = "рунический ятаган",
		INSTRUMENTAL = "руническим ятаганом",
		PREPOSITIONAL = "руническом ятагане"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "rune_scimmy"
	force = 28
	slot_flags = ITEM_SLOT_BELT
	damtype = BRUTE
	sharp = TRUE
	hitsound = 'sound/weapons/rs_slash.ogg'
	attack_verb = list("плс'л","атк'л","руб'л")

/obj/item/organ/internal/cyberimp/arm/katana
	name = "dark shard"
	desc = "Зловещий металлический осколок, окутанный тёмной энергией."
	ru_names = list(
		NOMINATIVE = "тёмный осколок",
		GENITIVE = "тёмного осколка",
		DATIVE = "тёмному осколку",
		ACCUSATIVE = "тёмный осколок",
		INSTRUMENTAL = "тёмным осколком",
		PREPOSITIONAL = "тёмном осколке"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana_organ"
	status = NONE
	item_flags = NO_PIXEL_RANDOM_DROP
	contents = newlist(/obj/item/cursed_katana)

/obj/item/organ/internal/cyberimp/arm/katana/prepare_eat()
	return

/obj/item/organ/internal/cyberimp/arm/katana/attack_self(mob/living/carbon/user, modifiers)
	. = ..()
	to_chat(user, span_warning("Масса поднимается по вашей руке и проникает внутрь!"))
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(user_death))

	user.drop_item_ground(src, force = TRUE, silent = TRUE)
	insert(user)

/obj/item/organ/internal/cyberimp/arm/katana/emp_act() //Organic, no emp stuff
	return

/obj/item/organ/internal/cyberimp/arm/katana/Retract()
	var/obj/item/cursed_katana/katana = active_item
	if(!katana || katana.shattered)
		return FALSE
	if(!katana.drew_blood)
		to_chat(owner, span_userdanger("[capitalize(katana.declent_ru(NOMINATIVE))] жадно атакует вас!"))
		playsound(owner, 'sound/misc/demon_attack1.ogg', 50, TRUE)
		owner.apply_damage(25, BRUTE, parent_organ_zone, TRUE)
	katana.drew_blood = FALSE
	katana.clean_blood()
	return ..()

/obj/item/organ/internal/cyberimp/arm/katana/Extend()
	for(var/obj/item/cursed_katana/katana in contents)
		if(katana.shattered)
			to_chat(owner, span_warning("Ваша проклятая катана ещё не восстановилась!"))
			return FALSE
	return ..()

/obj/item/organ/internal/cyberimp/arm/katana/proc/user_death(mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(user_death_async), user)

/obj/item/organ/internal/cyberimp/arm/katana/proc/user_death_async(mob/user)
	remove(user)
	user.visible_message(
		span_warning("[user] обращается в прах, его душа затягивается в [declent_ru(ACCUSATIVE)]!"),
		span_userdanger("Вы чувствуете, как ваше тело рассыпается в прах, а душа втягивается в [declent_ru(ACCUSATIVE)]!")
	)
	forceMove(get_turf(user))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, dust)), 1 SECONDS)

/obj/item/organ/internal/cyberimp/arm/katana/remove(mob/living/carbon/M, special)
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	. = ..()

#define ATTACK_STRIKE "Удар рукоятью"
#define ATTACK_SLICE "Широкий взмах"
#define ATTACK_DASH "Рывок"
#define ATTACK_CUT "Подрез сухожилий"
#define ATTACK_HEAL "Тёмное исцеление"
#define ATTACK_SHATTER "Разрушение"

/obj/item/cursed_katana
	name = "cursed katana"
	desc = "Катана, некогда сдерживавшая ужасное существо, была разрушена. Однако даже после этого её фрагменты, в которых заключена сущность, вновь объединились, чтобы найти нового хозяина."
	ru_names = list(
		NOMINATIVE = "проклятая катана",
		GENITIVE = "проклятой катаны",
		DATIVE = "проклятой катане",
		ACCUSATIVE = "проклятую катану",
		INSTRUMENTAL = "проклятой катаной",
		PREPOSITIONAL = "проклятой катане"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "cursed_katana"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	armour_penetration = 15
	block_chance = 50
	block_type = MELEE_ATTACKS
	sharp = TRUE
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("атаковал", "ударил", "порезал", "покромсал", "разрезал", "рубанул")
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/shattered = FALSE
	var/drew_blood = FALSE
	var/static/list/combo_list = list(
		ATTACK_STRIKE = list(COMBO_STEPS = list(HARM_SLASH, HARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(strike)),
		ATTACK_SLICE = list(COMBO_STEPS = list(DISARM_SLASH, HARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(slice)),
		ATTACK_DASH = list(COMBO_STEPS = list(HARM_SLASH, DISARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(dash)),
		ATTACK_CUT = list(COMBO_STEPS = list(DISARM_SLASH, DISARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(cut)),
		ATTACK_HEAL = list(COMBO_STEPS = list(HARM_SLASH, DISARM_SLASH, HARM_SLASH, DISARM_SLASH), COMBO_PROC = PROC_REF(heal)),
		ATTACK_SHATTER = list(COMBO_STEPS = list(DISARM_SLASH, HARM_SLASH, DISARM_SLASH, HARM_SLASH), COMBO_PROC = PROC_REF(shatter)),
		)

/obj/item/cursed_katana/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/combo_attacks, \
		combos = combo_list, \
		max_combo_length = 4, \
		reset_message = span_notice("принята небоевая стойка"), \
		can_attack_callback = CALLBACK(src, PROC_REF(can_combo_attack)) \
	)


/obj/item/cursed_katana/examine(mob/user)
	. = ..()
	. += drew_blood ? ("[span_notice("Она насытилось... пока что.")]") : (span_danger("Она не успокоится, пока не отведает крови."))


/obj/item/cursed_katana/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(can_combo_attack(user, target))
		drew_blood = TRUE
		if(ishostile(target))
			user.changeNext_move(CLICK_CD_RAPID)
	return ..()

/obj/item/cursed_katana/proc/can_combo_attack(mob/user, mob/living/target)
	return target.stat != DEAD && target != user

/obj/item/cursed_katana/proc/strike(mob/living/target, mob/user)
	user.visible_message(
		span_warning("[user] бь[pluralize_ru(user.gender,"ёт","ют")] [target.declent_ru(ACCUSATIVE)] рукоятью [declent_ru(GENITIVE)]!"),
		span_notice("Вы бьёте рукоятью по [target.declent_ru(DATIVE)]!")
	)
	to_chat(target, span_userdanger("[user] ударил вас рукоятью!"))
	playsound(src, 'sound/weapons/genhit3.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_throw_impact))
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 5, 3, user, FALSE, callback = CALLBACK(target, TYPE_PROC_REF(/datum, UnregisterSignal), target, COMSIG_MOVABLE_IMPACT))
	target.apply_damage(17, BRUTE, BODY_ZONE_CHEST)
	to_chat(target, span_userdanger("[user] ударил[pluralize_ru(user.gender,"","и")] вас рукоятью!"))
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

/obj/item/cursed_katana/proc/strike_throw_impact(mob/living/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	source.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	if(ishostile(source))
		var/mob/living/simple_animal/hostile/target = source
		target.ranged_cooldown = world.time + 5 SECONDS
	else if(iscarbon(source))
		var/mob/living/carbon/target = source
		target.AdjustConfused(8 SECONDS)
	return NONE

/obj/item/cursed_katana/proc/slice(mob/living/target, mob/user)
	user.visible_message(
		span_warning("[user] соверша[pluralize_ru(user.gender,"ет","ют")] широкий взмах!"),
		span_notice("Вы совершаете широкий взмах!")
	)
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	var/turf/user_turf = get_turf(user)
	var/dir_to_target = get_dir(user_turf, get_turf(target))
	var/static/list/cursed_katana_slice_angles = list(0, -45, 45, -90, 90) //so that the animation animates towards the target clicked and not towards a side target
	for(var/iteration in cursed_katana_slice_angles)
		var/turf/T = get_step(user_turf, turn(dir_to_target, iteration))
		user.do_attack_animation(T, ATTACK_EFFECT_CLAW)
		for(var/mob/living/additional_target in T)
			if(user.Adjacent(additional_target) && additional_target.density)
				additional_target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
				to_chat(additional_target, span_userdanger("[user] поразил[pluralize_ru(user.gender,"","и")] вас взмахом!"))
	target.apply_damage(5, BRUTE, BODY_ZONE_CHEST, TRUE)

/obj/item/cursed_katana/proc/heal(mob/living/target, mob/living/user)
	user.visible_message(
		span_warning("[user] позволя[pluralize_ru(user.gender,"ет","ют")] [declent_ru(DATIVE)] насытиться кровью [target.declent_ru(GENITIVE)]!"),
		span_warning("Вы позволяете [declent_ru(DATIVE)] насытиться кровью [target.declent_ru(GENITIVE)], исцеляя себя ценой его жизни!")
	)
	target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
	user.apply_status_effect(STATUS_EFFECT_SHADOW_MEND)

/obj/item/cursed_katana/proc/cut(mob/living/target, mob/user)
	user.visible_message(
		span_warning("[user] подреза[pluralize_ru(user.gender,"ет","ют")] сухожилия [target.declent_ru(GENITIVE)]!"),
		span_notice("Вы подрезаете сухожилия [target.declent_ru(GENITIVE)]!")
	)
	to_chat(target, span_userdanger("[user] подрезал[pluralize_ru(user.gender,"","и")] ваши сухожилия!"))
	target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/weapons/rapierhit.ogg', 50, TRUE)
	var/datum/status_effect/saw_bleed/bloodletting/A = target.has_status_effect(STATUS_EFFECT_BLOODLETTING)
	if(!A)
		target.apply_status_effect(STATUS_EFFECT_BLOODLETTING)
	else
		A.add_bleed(6)


/obj/item/cursed_katana/proc/dash(mob/living/target, mob/user)
	var/turf/dash_target = get_turf(target)
	var/turf/user_turf = get_turf(user)
	if(!is_teleport_allowed(dash_target.z)) //No teleporting at CC
		to_chat(user, span_userdanger("Сюда невозможно совершить рывок!"))
		return
	user.visible_message(
		span_warning("[user] стремительно пронза[pluralize_ru(user.gender,"ет","ют")] [target.declent_ru(ACCUSATIVE)]!"),
		span_notice("Вы стремительно пронзаете [target.declent_ru(ACCUSATIVE)]!")
	)
	to_chat(target, span_userdanger("[user] пронза[pluralize_ru(user.gender,"ет","ют")] вас!"))
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	target.apply_damage(17, BRUTE, BODY_ZONE_CHEST, TRUE)
	for(var/distance in 1 to 9)
		var/turf/current_dash_target = dash_target
		current_dash_target = get_step(current_dash_target, user.dir)
		if(current_dash_target.is_blocked_turf(TRUE))
			break
		dash_target = current_dash_target
		for(var/mob/living/additional_target in dash_target) //Slash through every mob you cut through
			additional_target.apply_damage(15, BRUTE, BODY_ZONE_CHEST, TRUE)
			to_chat(additional_target, span_userdanger("[user] порезал[pluralize_ru(user.gender,"","и")] вас!"))
	user_turf.Beam(dash_target, icon_state = "warp_beam", time = 0.3 SECONDS, maxdistance = INFINITY)
	user.forceMove(dash_target)

/obj/item/cursed_katana/proc/shatter(mob/living/target, mob/user)
	user.visible_message(
		span_warning("[user] разбивает [declent_ru(ACCUSATIVE)] о [target.declent_ru(GENITIVE)]!"),
		span_notice("Вы разбиваете [declent_ru(ACCUSATIVE)] о [target.declent_ru(GENITIVE)]!")
	)
	to_chat(target, span_userdanger("[user] разбивает [declent_ru(ACCUSATIVE)] о вас!"))
	target.apply_damage((ishostile(target) ? 75 : 35), BRUTE, BODY_ZONE_CHEST, TRUE)
	target.Weaken(3 SECONDS)
	target.apply_damage(60, STAMINA) //Takes 4 hits to do, breaks your weapon. Perfectly fine.
	user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/internal/cyberimp/arm/katana/O in H.internal_organs)
			if(O.active_item == src)
				O.Retract()
	shattered = TRUE
	addtimer(CALLBACK(src, PROC_REF(coagulate), user), 45 SECONDS)

/obj/item/cursed_katana/proc/coagulate(mob/user)
	if(QDELETED(user))
		return
	to_chat(user, span_notice("[capitalize(declent_ru(NOMINATIVE))] восстанавливается!"))
	shattered = FALSE
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)

#undef ATTACK_STRIKE
#undef ATTACK_SLICE
#undef ATTACK_DASH
#undef ATTACK_CUT
#undef ATTACK_HEAL
#undef ATTACK_SHATTER
