/obj/item/storage/pill_bottle/dice
	name = "dice pack"
	desc = "Мешочек с игральными костями внутри."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	can_hold = list(/obj/item/dice)
	allow_wrap = FALSE

/obj/item/storage/pill_bottle/dice/get_ru_names()
	return list(
		NOMINATIVE = "мешок игральных костей",
		GENITIVE = "мешка игральных костей",
		DATIVE = "мешку игральных костей",
		ACCUSATIVE = "мешок игральных костей",
		INSTRUMENTAL = "мешком игральных костей",
		PREPOSITIONAL = "мешке игральных костей",
	)

/obj/item/storage/pill_bottle/dice/populate_contents()
	var/special_die = pick("1", "2", "fudge", "00", "100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)


/obj/item/storage/box/dice
	name = "Коробка игральных костей"
	desc = "ЕЩЁ ОДНИ!? ДА БЛЯДЬ!"


/obj/item/storage/box/dice/populate_contents()
	new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)


/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] игра[PLUR_ET_YUT(user)] со смертью! Похоже, он[GEND_A_O_I(user)] пыта[PLUR_ET_YUT(user)]ся покончить жизнь самоубийством!"))
	return (OXYLOSS)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "dice"
	desc = "Кость с шестью гранями. Непримечательна и проста в обращении."
	gender = FEMALE
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY

	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/get_ru_names()
	return list(
		NOMINATIVE = "игральная кость",
		GENITIVE = "игральной кости",
		DATIVE = "игральной кости",
		ACCUSATIVE = "игральную кость",
		INSTRUMENTAL = "игральной костью",
		PREPOSITIONAL = "игральной кости",
	)


/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon(UPDATE_OVERLAYS)


/obj/item/dice/update_overlays()
	. = ..()
	. += "[icon_state][result]"


/obj/item/dice/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] играет со смертью! Похоже [user.p_theyre()] пытается покончить жизнь самоубийством!"))
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "Кость с одной гранью. Очень детерминировано!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "Кость с двумя гранями. Если монеты вас не достойны."
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "Кость с четырьмя гранями. По задротски - «чеснок»."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, 1, 4) //1d4 damage

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/fudge
	name = "Fudge-кость"
	desc = "Кость с шестью гранями, но только с тремя результатами. Это плюс или минус? Ваш разум опустел..."
	sides = 3
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "Кость с восемью гранями. Кажется… везучей."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "Кость с десятью гранями. Полезно для процентов."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "Кость с десятью гранями. Подходит для бросков d100 лучше мяча для гольфа."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "Кость с двенадцатью гранями. Похоже им никогда не пользовались..."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "Кость с двадцатью гранями. Именно такой чаще всего бросают в игровых мастеров."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "Игральная кость с сотней граней! Вряд ли развесовка выверена…"
	icon_state = "d100"
	sides = 100


/obj/item/dice/d100/update_overlays()
	return list()


/obj/item/dice/d20/e20
	var/triggered = FALSE

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/target, datum/thrownthing/throwingdatum)
	diceroll(locateUID(thrownby))
	. = ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1 / (sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "ДВАДЦАТКА!"
	else if(sides == 20 && result == 1)
		comment = "М-да, невезуха."
	update_icon(UPDATE_OVERLAYS)
	if(initial(icon_state) == "d00")
		result = (result - 1) * 10
	if(length(special_faces) == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message(
			"[user] броса[PLUR_ET_YUT(user)] [src.name]. На [src.name] выпадает [result]. [comment]",
			span_notice("Вы бросили [src.name] и выпало [result]. [comment]"),
			span_italics("Вы слышите как катится [src.name], звучит как [fake_result].")
		)
	else if(!throwing) //Dice was thrown and is coming to rest
		visible_message(span_notice("[src.name] прекращает катиться, остановившись на [result]. [comment]"))

/obj/item/dice/d20/e20/diceroll(mob/user, thrown)
	if(triggered)
		return

	. = ..()

	if(result == 1)
		to_chat(user, span_danger("На вас упали камни и вы умерли."))
		user.gib()
		add_attack_logs(src, user, "detonated with a roll of [result], gibbing them!", ATKLOG_FEW)
	else
		triggered = TRUE
		visible_message(span_notice("Вы слышите тихий щелчок."))
		addtimer(CALLBACK(src, PROC_REF(boom), user, result), 4 SECONDS)

/obj/item/dice/d20/e20/proc/boom(mob/user, result)
	var/capped = FALSE
	var/actual_result = result
	if(result != 20)
		capped = TRUE
		result = min(result, GLOB.max_ex_light_range) // Apply the bombcap
	else // Rolled a nat 20, screw the bombcap
		result = 24

	var/turf/epicenter = get_turf(src)
	investigate_log("E20 detonated with a roll of [actual_result]. Triggered by: [key_name_log(user)]", INVESTIGATE_BOMB)
	add_game_logs("threw E20, detonating at [AREACOORD(epicenter)] with a roll of [actual_result].", user)
	add_attack_logs(user, src, "detonated with a roll of [actual_result]", ATKLOG_FEW)
	explosion(epicenter, devastation_range = round(result * 0.25), heavy_impact_range = round(result * 0.5), light_impact_range = round(result), flash_range = round(result * 1.5), adminlog = TRUE, ignorecap = capped, cause = (key_name(user)+" E20"))


// Die of Fate
/obj/item/dice/d20/fate
	name = "Die of Fate"
	desc = "Кубик с двадцатью гранями. От него исходит таинственная энергия. Использовать его может быть ОЧЕНЬ рисково."
	var/reusable = TRUE
	var/used = FALSE

/obj/item/dice/d20/fate/get_ru_names()
	return list(
		NOMINATIVE = "Игральная Кость Судьбы",
		GENITIVE = "Игральной Кости Судьбы",
		DATIVE = "Игральной Кости Судьбы",
		ACCUSATIVE = "Игральную Кость Судьбы",
		INSTRUMENTAL = "Игральной Костью Судьбы",
		PREPOSITIONAL = "Игральной Кости Судьбы"
	)

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "Кость с двадцатью гранями. Именно такой чаще всего бросают в игровых мастеров."

/obj/item/dice/d20/fate/stealth/get_ru_names()
	return list(
		NOMINATIVE = "игральная кость",
		GENITIVE = "игральной кости",
		DATIVE = "игральной кости",
		ACCUSATIVE = "игральную кость",
		INSTRUMENTAL = "игральной костью",
		PREPOSITIONAL = "игральной кости"
	)

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/one_use/stealth
	name = "d20"
	desc = "Кость с двадцатью гранями. Именно такой чаще всего бросают в игровых мастеров."

/obj/item/dice/d20/fate/one_use/stealth/get_ru_names()
	return list(
		NOMINATIVE = "игральная кость",
		GENITIVE = "игральной кости",
		DATIVE = "игральной кости",
		ACCUSATIVE = "игральную кость",
		INSTRUMENTAL = "игральной костью",
		PREPOSITIONAL = "игральной кости"
	)


/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "Кость с двадцатью гранями. Вы чувствуете, что бросать его ОЧЕНЬ плохая идея."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/cursed/get_ru_names()
	return list(
		NOMINATIVE = "проклятая Игральная Кость Судьбы",
		GENITIVE = "проклятой Игральной Кости Судьбы",
		DATIVE = "проклятой Игральной Кости Судьбы",
		ACCUSATIVE = "проклятую Игральную Кость Судьбы",
		INSTRUMENTAL = "проклятой Игральной Костью Судьбы",
		PREPOSITIONAL = "проклятой Игральной Кости Судьбы"
	)

/obj/item/dice/d20/fate/diceroll(mob/user)
	. = ..()
	if(!used)
		if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
			to_chat(user, span_warning("Магией этого кубика могут воспользоваться только простые люди!"))
			return

		if(!reusable)
			used = TRUE

		var/turf/T = get_turf(src)
		T.visible_message(span_userdanger("[capitalize(declent_ru(NOMINATIVE))] ярко вспыхива[PLUR_ET_YUT(src)]."))

		addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot, initial)
	. = ..()

	if(!ishuman(user) || !user.mind || (user.mind in SSticker.mode.wizards))
		to_chat(user, span_warning("Магией этого кубика могут воспользоваться только простые люди! Вы должны оставить его здесь."))
		user.drop_item_ground(src)

/obj/item/dice/d20/fate/proc/create_smoke(amount)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = amount, location = drop_location())
	smoke.start()

/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user, roll)
	switch(roll)
		if(1)
			//Damnation. This person never existed
			Damnation(user)
		if(2)
			//100 Brute damage and ripping organs off
			Butcher(user)
		if(3)
			//Swarm of creatures
			mob_swarm(user)
		if(4)
			//Destroy equipment, remove all genes and antag roles
			purify(user)
		if(5)
			//Cut speed
			slow(user)
		if(6)
			//Monkeying
			monkefy(user)
		if(7)
			//Fueltank Explosion
			explode(user)
		if(8)
			//Break bone
			break_bone(user)
		if(9)
			//random virus from disease outbreak
			infect(user)
		if(10)
			//Medal (will add later)
			medal(user)
		if(11)
			//Warm Donk pockets
			pockets(user)
		if(12)
			//5000 credits
			money(user)
		if(13)
			//Captain ID
			spare_id(user)
		if(14)
			//Revive
			revive(user)
		if(15)
			//Unica, 2 speedloaders and holster
			unica(user)
		if(16)
			//2 random one use spellbooks
			books()
		if(17)
			//Instrinct Resistance
			resistance(user)
		if(18)
			//Choose from 1 of 3 random syndie bundles
			random_bundle()
		if(19)
			//Coin that can summon servant
			magic_coin(user)
		if(20)
			//Free wizard!
			become_wizard(user)

/obj/item/dice/d20/fate/proc/Damnation(mob/living/carbon/human/damned)
	damned.visible_message(span_colossus("Damnatio memoriae."))
	playsound(damned, 'sound/magic/narsie_attack.ogg', 200, TRUE)
	var/datum/data/record/damned_sec_record = find_record("name", damned.real_name, GLOB.data_core.security)
	var/datum/data/record/damned_gen_record = find_record("name", damned.real_name, GLOB.data_core.general)
	var/datum/data/record/damned_med_record = find_record("name", damned.real_name, GLOB.data_core.medical)
	qdel(damned_sec_record)
	qdel(damned_gen_record)
	qdel(damned_med_record)
	for(var/obj/item/paper/contract/employment/contract as anything in GLOB.employmentContracts)
		if(contract.target != damned.mind)
			continue
		qdel(contract)
	damned.ghostize()
	damned.dust()
	SSticker.mode.victims.Remove(damned)
	for(var/datum/objective/obj as anything in GLOB.all_objectives)
		if(obj.target != damned.mind)
			continue
		obj.target = null
		obj.find_target(obj.existing_targets_blacklist())
		if(isnull(obj.target))
			qdel(obj)
			continue
		for(var/datum/mind/user in obj.get_owners())
			if(QDELETED(obj))
				to_chat(user, span_userdanger("Вам кажется, что вы что-то забыли!"))
				SEND_SOUND(user.current, sound('sound/ambience/alarm4.ogg'))
				continue
			var/list/messages = list()
			messages.Add(user.prepare_announce_objectives(FALSE))
			to_chat(user.current, chat_box_red(messages.Join("<br>")))
			SEND_SOUND(user.current, sound('sound/ambience/alarm4.ogg'))

/obj/item/dice/d20/fate/proc/Butcher(mob/living/carbon/human/butchered)
	var/obj/item/organ/external/body = butchered.get_organ(BODY_ZONE_CHEST)
	body.droplimb()
	butchered.adjustBruteLoss(100, def_zone = BODY_ZONE_CHEST)
	if(ismachineperson(butchered))
		butchered.visible_message(
			span_userdanger("Корпус [butchered] разваливается на части, и [GEND_HIS_HER(butchered)] компоненты вываливаются наружу!"),
			span_userdanger("Вы не успели ничего осознать, как ваши части вывалились наружу."),
			span_userdanger("Вы слышите звук вываливающихся запчастей и разрывающихся проводов.")
		)
		return
	butchered.visible_message(
		span_userdanger("Тонкая красная линия появляется на груди [butchered], и спустя мгновение [GEND_HIS_HER(butchered)] органы вываливаются наружу!"),
		span_userdanger("Вы не успели ничего осознать, как ваши органы вывалились наружу."),
		span_userdanger("Вы слышите звук вываливающихся органов.")
	)

/obj/item/dice/d20/fate/proc/mob_swarm(mob/living/carbon/human/swarmed)
	src.visible_message(span_userdanger("На месте кубика появился портал, из которого выходят адские отродья!"))
	var/spawned_hounds = 0
	var/spawned_t_hounds = 0
	var/list/spawned_turfs = list()
	var/list/turfs_around = list()
	var/turf/turf_to_spawn
	var/mob/living/simple_animal/hostile/hellhound/hound

	for(var/turf/turf_around in range(3, swarmed))
		LAZYADD(turfs_around, turf_around)

	while(spawned_hounds < 5 || spawned_t_hounds < 2)
		turf_to_spawn = pick(turfs_around)
		if(turf_to_spawn in spawned_turfs)
			continue
		LAZYADD(spawned_turfs, turf_to_spawn)
		if(spawned_t_hounds < 2)
			hound = new /mob/living/simple_animal/hostile/hellhound/tear(turf_to_spawn)
			hound.faction = list("rift")
			spawned_t_hounds++
			continue
		hound = new /mob/living/simple_animal/hostile/hellhound(turf_to_spawn)
		spawned_hounds++
		hound.faction = list("rift")
	swarmed.Weaken(2 SECONDS)

/obj/item/dice/d20/fate/proc/purify(mob/living/carbon/human/purified)
	purified.visible_message(span_userdanger("[purified] выгляд[PLUR_IT_YAT(purified)] очистившим[PLUR_I(purified)]ся!"))
	for(var/obj/item/I in purified)
		if(istype(I, /obj/item/organ))
			continue
		qdel(I)
	purified.mind.remove_all_antag_datums()
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(!LAZYIN(purified.dna.default_blocks, gene.block))
			purified.force_gene_block(gene.block, FALSE)

/obj/item/dice/d20/fate/proc/slow(mob/living/carbon/human/slowed)
	slowed.visible_message(span_userdanger("[slowed] начал[GEND_A_O_I(slowed)] двигаться медленнее!"))
	slowed.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)

/obj/item/dice/d20/fate/proc/monkefy(mob/living/carbon/human/monkeyed)
	monkeyed.visible_message(span_userdanger("[monkeyed] превраща[PLUR_ET_YUT(monkeyed)]ся в обезьяну!"))
	monkeyed.monkeyize()

/obj/item/dice/d20/fate/proc/explode(mob/living/carbon/human/center)
	center.visible_message(span_userdanger("Рядом с [center] происходит взрыв!"))
	explosion(get_turf(center), devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flame_range = 2, cause = src)

/obj/item/dice/d20/fate/proc/break_bone(mob/living/carbon/human/target)
	var/obj/item/organ/external/limb = pick(target.bodyparts)
	limb.fracture()
	to_chat(target, span_userdanger("Вы чувствуете, как ваша [GLOB.body_zone[limb.limb_zone][NOMINATIVE]] трескается и ломается!"))

/obj/item/dice/d20/fate/proc/infect(mob/living/carbon/human/infected)
	var/virus_type = pick(
		1; /datum/disease/virus/anxiety,
		1; /datum/disease/virus/beesease,
		1; /datum/disease/virus/brainrot,
		1; /datum/disease/virus/cold,
		1; /datum/disease/virus/flu,
		1; /datum/disease/virus/fluspanish,
		1; /datum/disease/virus/fake_gbs,
		1; /datum/disease/virus/loyalty,
		1; /datum/disease/virus/lycan,
		1; /datum/disease/virus/magnitis,
		1; /datum/disease/virus/pierrot_throat,
		1; /datum/disease/virus/pierrot_throat/advanced,
		1; /datum/disease/virus/tuberculosis,
		1; /datum/disease/virus/wizarditis,
		1; /datum/disease/virus/babylonian_fever
	)
	var/datum/disease/virus/D = new virus_type()
	if(D.Contract(infected, is_carrier = TRUE))
		to_chat(infected, span_danger("На секунду вам становится трудно дышать"))

/obj/item/dice/d20/fate/proc/medal(mob/living/carbon/human/awarded)
	var/medal = new /obj/item/clothing/accessory/medal/gold/nothing_award
	awarded.put_in_hands(medal)
	awarded.visible_message(span_userdanger("ALWAYS BET ON NOTHING."))

/obj/item/dice/d20/fate/proc/pockets(mob/living/carbon/human/gifted)
	to_chat(gifted, span_notice("Наконец то, ваши старания признали."))
	var/box = new /obj/item/storage/box/warmdonkpockets
	gifted.put_in_hands(box)

/obj/item/dice/d20/fate/proc/money(mob/living/carbon/human/gifted)
	to_chat(gifted, span_boldnotice("ДЖЕКПОТ!!!"))
	var/case = new /obj/item/storage/secure/briefcase/syndie
	gifted.put_in_hands(case)

/obj/item/dice/d20/fate/proc/spare_id(mob/living/carbon/human/gifted)
	to_chat(gifted, span_boldnotice("Теперь я капитан этой посудины!"))
	var/id = new /obj/item/card/id/captains_spare
	gifted.put_in_hands(id)

/obj/item/dice/d20/fate/proc/revive(mob/living/carbon/human/revived)
	revived.visible_message(span_boldnotice("[revived] выгляд[PLUR_IT_YAT(revived)] полностью здоров[GEND_YM_OI_YM_YMI(revived)]"))
	revived.revive()

//IDK where to put this so it will be here
/obj/item/storage/box/unica_kit
	icon_state = "box_hos"

/obj/item/storage/box/unica_kit/populate_contents()
	new /obj/item/gun/projectile/revolver/mateba(src)
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/item/dice/d20/fate/proc/unica(mob/living/carbon/human/gifted)
	to_chat(gifted, span_boldnotice("Пиу-пау!"))
	var/box = new /obj/item/storage/box/unica_kit
	gifted.put_in_hands(box)

/obj/item/dice/d20/fate/proc/books()
	src.visible_message(span_userdanger("Две магические книги упали на пол!"))
	create_smoke(2)
	new /obj/item/spellbook/oneuse/random(loc)
	new /obj/item/spellbook/oneuse/random(loc)

/obj/item/dice/d20/fate/proc/resistance(mob/living/carbon/human/user)
	user.visible_message(span_userdanger("[user] выгляд[PLUR_IT_YAT(user)] очень крепко!"))
	user.physiology.brute_mod *= 0.5
	user.physiology.burn_mod *= 0.5

/obj/item/dice/d20/fate/proc/random_bundle()
	src.visible_message(span_userdanger("Появился подозрительный радио маяк!"))
	new /obj/item/beacon/syndicate/bundle/magical(loc)
	create_smoke(2)

/obj/item/dice/d20/fate/proc/magic_coin(mob/living/carbon/human/gifted)
	gifted.visible_message(span_userdanger("В руках у [gifted] появилась странная монета!"))
	var/coin = new /obj/item/coin/magic
	gifted.put_in_hands(coin)

/obj/item/dice/d20/fate/proc/become_wizard(mob/living/carbon/human/wizard)
	wizard.visible_message(span_userdanger("Потоки магической энергии вылетают из [declent_ru(GENITIVE)] в сторону [wizard]!"))
	wizard.mind.make_Wizard()
