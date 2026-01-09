/datum/dice_roll
	var/mob/living/carbon/human/user
	var/rolled
	var/obj/item/dice/d20/fate/dice

/datum/dice_roll/New(who_used, rolled_value, fate_dice)
	. = ..()
	user = who_used
	rolled = rolled_value
	dice = fate_dice
	roll_dice()

/datum/dice_roll/proc/roll_dice()
	switch(rolled)
		if(1)
			//Damnation. This person never existed
			damnation()
		if(2)
			//100 Brute damage and ripping organs off
			butcher()
		if(3)
			//Swarm of creatures
			mob_swarm()
		if(4)
			//Destroy equipment, remove all genes and antag roles
			purify()
		if(5)
			//Cut speed
			slow()
		if(6)
			//Monkeying
			monkefy()
		if(7)
			//Fueltank Explosion
			explode()
		if(8)
			//Break bone
			break_bone()
		if(9)
			//random virus from disease outbreak
			infect()
		if(10)
			//Medal (will add later)
			medal()
		if(11)
			//Warm Donk pockets
			pockets()
		if(12)
			//5000 credits
			money()
		if(13)
			//Captain ID
			spare_id()
		if(14)
			//Revive
			revive()
		if(15)
			//Unica, 2 speedloaders and holster
			unica()
		if(16)
			//2 random one use spellbooks
			books()
		if(17)
			//Instrinct Resistance
			resistance()
		if(18)
			//Choose from 1 of 3 random syndie bundles
			random_bundle()
		if(19)
			//Coin that can summon servant
			magic_coin()
		if(20)
			//Free wizard!
			become_wizard()
	qdel(src)

/datum/dice_roll/proc/damnation()
	user.visible_message(span_colossus("Damnatio memoriae."))
	playsound(user, 'sound/magic/narsie_attack.ogg', 200, TRUE)
	delete_records()
	delete_from_objectives()
	user.ghostize()
	user.dust()

/datum/dice_roll/proc/delete_records()
	var/datum/data/record/user_sec_record = find_record("name", user.real_name, GLOB.data_core.security)
	var/datum/data/record/user_gen_record = find_record("name", user.real_name, GLOB.data_core.general)
	var/datum/data/record/user_med_record = find_record("name", user.real_name, GLOB.data_core.medical)
	qdel(user_sec_record)
	qdel(user_gen_record)
	qdel(user_med_record)
	for(var/obj/item/paper/contract/employment/contract as anything in GLOB.employmentContracts)
		if(contract.target != user.mind)
			continue
		qdel(contract)

/datum/dice_roll/proc/delete_from_objectives()
	SSticker.mode.victims.Remove(user)
	for(var/datum/objective/obj as anything in GLOB.all_objectives)
		if(obj.owner != user.mind)
			continue
		obj.owner = null
		obj.find_target(obj.existing_targets_blacklist())
		if(isnull(obj.owner))
			qdel(obj)
			continue
		for(var/datum/mind/user in obj.get_owners())
			to_chat(user, span_userdanger("Вам кажется, что вы что-то забыли..."))
			SEND_SOUND(user.current, sound('sound/ambience/alarm4.ogg'))
			var/list/messages = list()
			messages.Add(user.prepare_announce_objectives(FALSE))
			to_chat(user.current, chat_box_red(messages.Join("<br>")))
			SEND_SOUND(user.current, sound('sound/ambience/alarm4.ogg'))
	if(is_sacrifice_target(user.mind))
		if(!SSticker.mode.cult_objs.find_new_sacrifice_target())
			SSticker.mode.cult_objs.ready_to_summon()

/datum/dice_roll/proc/butcher()
	var/obj/item/organ/external/body = user.get_organ(BODY_ZONE_CHEST)
	body.droplimb()
	user.adjustBruteLoss(100, def_zone = BODY_ZONE_CHEST)
	if(ismachineperson(user))
		user.visible_message(
			span_userdanger("Корпус [user.declent_ru(GENITIVE)] разваливается на части, и [GEND_HIS_HER(user)] компоненты вываливаются наружу!"),
			span_userdanger("Ваши компоненты отваливаются от вашего корпуса прямо на глазах!"),
			span_userdanger("Вы слышите звук вываливающихся запчастей и разрывающихся проводов.")
		)
		return
	user.visible_message(
		span_userdanger("Тонкая красная линия появляется на груди [user], и спустя мгновение [GEND_HIS_HER(user)] органы вываливаются наружу!"),
		span_userdanger("Ваши органы вываливаются из вас прямо на глазах!"),
		span_userdanger("Вы слышите звук вываливающихся органов.")
	)

/datum/dice_roll/proc/mob_swarm()
	user.visible_message(span_userdanger("На месте [dice.declent_ru(GENITIVE)] появился портал, из которого выходят адские отродья!"))
	var/spawned_hounds = 0
	var/spawned_t_hounds = 0
	var/list/turfs_around = list()
	var/turf/turf_to_spawn
	var/mob/living/simple_animal/hostile/hellhound/hound

	for(var/turf/simulated/turf in range(user, 3))
		turfs_around |= turf

	shuffle(turfs_around)
	while((spawned_hounds < 5 || spawned_t_hounds < 2) && turfs_around.len)
		turf_to_spawn = pop(turfs_around)
		if(spawned_t_hounds < 2)
			hound = new /mob/living/simple_animal/hostile/hellhound/tear(turf_to_spawn)
			hound.faction = list("rift")
			spawned_t_hounds++
			continue
		hound = new /mob/living/simple_animal/hostile/hellhound(turf_to_spawn)
		spawned_hounds++
		hound.faction = list("rift")
	user.Weaken(2 SECONDS)

/datum/dice_roll/proc/purify()
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] очистившим[PLUR_I(user)]ся!"))
	for(var/obj/item/I in user)
		if(istype(I, /obj/item/organ))
			continue
		qdel(I)
	user.mind.remove_all_antag_datums()
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(!LAZYIN(user.dna.default_blocks, gene.block))
			user.force_gene_block(gene.block, FALSE)

/datum/dice_roll/proc/slow()
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] начал[GEND_A_O_I(user)] двигаться медленнее!"))
	user.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)

/datum/dice_roll/proc/monkefy()
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] превраща[PLUR_ET_YUT(user)]ся в обезьяну!"))
	user.monkeyize()

/datum/dice_roll/proc/explode()
	user.visible_message(span_userdanger("Рядом с [user.declent_ru(INSTRUMENTAL)] происходит взрыв!"))
	explosion(get_turf(user), devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flame_range = 2, cause = src)

/datum/dice_roll/proc/break_bone()
	var/obj/item/organ/external/limb = pick(user.bodyparts)
	limb.fracture()
	to_chat(user, span_userdanger("Вы чувствуете, как ваш[GEND_A_E_I(limb)] [GLOB.body_zone[limb.limb_zone][NOMINATIVE]] треска[PLUR_ET_YUT(limb)]ся и лома[PLUR_ET_YUT(limb)]ся!"))

/datum/dice_roll/proc/infect()
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
		1; /datum/disease/virus/babylonian_fever
	)
	var/datum/disease/virus/D = new virus_type()
	if(D.Contract(user, is_carrier = TRUE))
		to_chat(user, span_danger("На секунду вам становится трудно дышать!"))

/datum/dice_roll/proc/medal()
	var/medal = new /obj/item/clothing/accessory/medal/gold/nothing_award
	user.put_in_hands(medal)
	user.visible_message(span_userdanger("НИЧЕГО НИКОГДА НЕ ПРОИСХОДИТ!"))

/datum/dice_roll/proc/pockets()
	to_chat(user, span_notice("Наконец-то, ваши старания признали."))
	var/box = new /obj/item/storage/box/warmdonkpockets
	user.put_in_hands(box)

/datum/dice_roll/proc/money()
	to_chat(user, span_boldnotice("ДЖЕКПОТ!!!"))
	var/case = new /obj/item/storage/secure/briefcase/syndie
	user.put_in_hands(case)

/datum/dice_roll/proc/spare_id()
	to_chat(user, span_boldnotice("Теперь я капитан этой посудины!"))
	var/id = new /obj/item/card/id/captains_spare
	user.put_in_hands(id)

/datum/dice_roll/proc/revive()
	user.visible_message(span_boldnotice("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] полностью здоров[GEND_YM_OI_YM_YMI(user)]"))
	user.revive()

/datum/dice_roll/proc/unica()
	to_chat(user, span_boldnotice("Пиу-пау!"))
	var/box = new /obj/item/storage/box/unica_kit
	user.put_in_hands(box)

/datum/dice_roll/proc/books()
	user.visible_message(span_userdanger("Две магические книги падают на пол!"))
	create_smoke(2)
	new /obj/item/spellbook/oneuse/random(dice.loc)
	new /obj/item/spellbook/oneuse/random(dice.loc)

/datum/dice_roll/proc/resistance()
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] очень крепко!"))
	user.physiology.brute_mod *= 0.5
	user.physiology.burn_mod *= 0.5

/datum/dice_roll/proc/random_bundle()
	user.visible_message(span_userdanger("Появился подозрительный радио маяк!"))
	new /obj/item/beacon/syndicate/bundle/magical(dice.loc)
	create_smoke(2)

/datum/dice_roll/proc/magic_coin()
	user.visible_message(span_userdanger("В руках у [user.declent_ru(GENITIVE)] появляется странная монета!"))
	var/coin = new /obj/item/coin/magic
	user.put_in_hands(coin)

/datum/dice_roll/proc/become_wizard()
	user.visible_message(span_userdanger("Потоки магической энергии вылетают из [dice.declent_ru(GENITIVE)] в сторону [user.declent_ru(GENITIVE)]!"))
	user.mind.make_Wizard()

/datum/dice_roll/proc/create_smoke(amount)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = amount, location = dice.loc)
	smoke.start()
