GLOBAL_ALIST_EMPTY(dice_rolls)

/datum/dice_roll
	var/number = 0

/datum/dice_roll/proc/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	return

/datum/dice_roll/damnation
	number = 1

/datum/dice_roll/damnation/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_colossus("Damnatio memoriae."))
	playsound(user, 'sound/magic/narsie_attack.ogg', 200, TRUE)
	delete_records(user)
	delete_from_objectives(user)
	user.ghostize()
	user.dust()

/datum/dice_roll/damnation/proc/delete_records(mob/living/carbon/human/user)
	var/datum/data/record/user_sec_record = find_record("name", user.real_name, GLOB.data_core.security)
	var/datum/data/record/user_gen_record = find_record("name", user.real_name, GLOB.data_core.general)
	var/datum/data/record/user_med_record = find_record("name", user.real_name, GLOB.data_core.medical)
	qdel(user_sec_record)
	qdel(user_gen_record)
	qdel(user_med_record)
	for(var/obj/item/paper/contract/employment/contract as anything in GLOB.employmentContracts)
		if(!contract)
			return
		if(contract.target != user.mind)
			continue
		LAZYREMOVE(GLOB.employmentContracts, contract)
		qdel(contract)

/datum/dice_roll/damnation/proc/delete_from_objectives(mob/living/carbon/human/delete_target)
	SSticker.mode.victims.Remove(delete_target)
	for(var/datum/objective/obj as anything in GLOB.all_objectives)
		if(obj.owner != delete_target.mind)
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
	if(is_sacrifice_target(delete_target.mind))
		if(!SSticker.mode.cult_objs.find_new_sacrifice_target())
			SSticker.mode.cult_objs.ready_to_summon()

/datum/dice_roll/butcher
	number = 2

/datum/dice_roll/butcher/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	var/obj/item/organ/external/body = user.get_organ(BODY_ZONE_CHEST)
	body.droplimb()
	user.adjustBruteLoss(100, def_zone = BODY_ZONE_CHEST)
	if(ismachineperson(user))
		user.visible_message(
			span_userdanger("Корпус [user.declent_ru(GENITIVE)] разваливается на части, и [GEND_HIS_HER(user)] компоненты вываливаются наружу!"),
			span_userdanger("Ваши компоненты отваливаются от вашего корпуса прямо на глазах!"),
			span_userdanger("Вы слышите звук вываливающихся запчастей и разрывающихся проводов.")
		)
		return ..()
	user.visible_message(
		span_userdanger("Тонкая красная линия появляется на груди [user], и спустя мгновение [GEND_HIS_HER(user)] органы вываливаются наружу!"),
		span_userdanger("Ваши органы вываливаются из вас прямо на глазах!"),
		span_userdanger("Вы слышите звук вываливающихся органов.")
	)

/datum/dice_roll/mob_swarm
	number = 3

/datum/dice_roll/mob_swarm/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
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

/datum/dice_roll/purify
	number = 4

/datum/dice_roll/purify/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] очистившим[PLUR_I(user)]ся!"))
	for(var/obj/item/item in user)
		if(is_organ(item))
			continue
		qdel(item)
	user.mind.remove_all_antag_datums()
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		if(!LAZYIN(user.dna.default_blocks, gene.block))
			user.force_gene_block(gene.block, FALSE)


/datum/dice_roll/slow
	number = 5

/datum/dice_roll/slow/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] начал[GEND_A_O_I(user)] двигаться медленнее!"))
	user.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)
	. = ..()

/datum/dice_roll/monkefy
	number = 6

/datum/dice_roll/monkefy/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] превраща[PLUR_ET_YUT(user)]ся в обезьяну!"))
	if(ismachineperson(user))
		user.set_species(/datum/species/human)
	user.monkeyize()

/datum/dice_roll/explode
	number = 7

/datum/dice_roll/explode/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("Рядом с [user.declent_ru(INSTRUMENTAL)] происходит взрыв!"))
	explosion(get_turf(user), devastation_range = -1, heavy_impact_range = 0, light_impact_range = 2, flame_range = 2, cause = src)

/datum/dice_roll/break_bone
	number = 8

/datum/dice_roll/break_bone/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	var/obj/item/organ/external/limb = pick(user.bodyparts)
	if(!limb)
		return
	if(ismachineperson(user))
		limb.droplimb()
		to_chat(user, span_userdanger("Вы чувствуете, как ваш[GEND_A_E_I(limb)] [GLOB.body_zone[limb.limb_zone][NOMINATIVE]] треска[PLUR_ET_YUT(limb)]ся и отрыва[PLUR_ET_YUT(limb)]ся!"))
		return
	limb.fracture()
	to_chat(user, span_userdanger("Вы чувствуете, как ваш[GEND_A_E_I(limb)] [GLOB.body_zone[limb.limb_zone][NOMINATIVE]] треска[PLUR_ET_YUT(limb)]ся и лома[PLUR_ET_YUT(limb)]ся!"))

/datum/dice_roll/infect
	number = 9

/datum/dice_roll/infect/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	var/virus_type = pick(
		/datum/disease/virus/anxiety,
		/datum/disease/virus/beesease,
		/datum/disease/virus/brainrot,
		/datum/disease/virus/cold,
		/datum/disease/virus/flu,
		/datum/disease/virus/fluspanish,
		/datum/disease/virus/fake_gbs,
		/datum/disease/virus/loyalty,
		/datum/disease/virus/lycan,
		/datum/disease/virus/magnitis,
		/datum/disease/virus/pierrot_throat,
		/datum/disease/virus/pierrot_throat/advanced,
		/datum/disease/virus/tuberculosis,
		/datum/disease/virus/babylonian_fever,
	)
	var/datum/disease/virus/new_virus = new virus_type()
	if(new_virus.Contract(user, is_carrier = TRUE))
		to_chat(user, span_danger("На секунду вам становится трудно дышать!"))
		return ..()
	to_chat(user, span_notice("Фух... Кажется, пронесло."))

/datum/dice_roll/medal
	number = 10

/datum/dice_roll/medal/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	var/medal = new /obj/item/clothing/accessory/medal/gold/nothing_award
	user.put_in_hands(medal)
	user.visible_message(span_userdanger("НИЧЕГО НИКОГДА НЕ ПРОИСХОДИТ!"))

/datum/dice_roll/pockets
	number = 11

/datum/dice_roll/pockets/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	to_chat(user, span_notice("Наконец-то, ваши старания признали."))
	var/box = new /obj/item/storage/box/warmdonkpockets
	user.put_in_hands(box)

/datum/dice_roll/money
	number = 12

/datum/dice_roll/money/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	to_chat(user, span_boldnotice("ДЖЕКПОТ!!!"))
	var/case = new /obj/item/storage/secure/briefcase/syndie
	user.put_in_hands(case)

/datum/dice_roll/spare_id
	number = 13

/datum/dice_roll/spare_id/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	to_chat(user, span_boldnotice("Теперь я капитан этой посудины!"))
	var/id = new /obj/item/card/id/captains_spare
	user.put_in_hands(id)

/datum/dice_roll/revive
	number = 14

/datum/dice_roll/revive/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_boldnotice("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] полностью здоров[GEND_YM_OI_YM_YMI(user)]"))
	user.revive()

/datum/dice_roll/unica
	number = 15

/datum/dice_roll/unica/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	to_chat(user, span_boldnotice("Пиу-пау!"))
	var/box = new /obj/item/storage/box/unica_kit
	user.put_in_hands(box)

/datum/dice_roll/books
	number = 16

/datum/dice_roll/books/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("Две магические книги падают на пол!"))
	create_smoke(2, dice.loc)
	new /obj/item/spellbook/oneuse/random(dice.loc)
	new /obj/item/spellbook/oneuse/random(dice.loc)

/datum/dice_roll/resistance
	number = 17

/datum/dice_roll/resistance/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("[user.declent_ru(NOMINATIVE)] выгляд[PLUR_IT_YAT(user)] очень крепко!"))
	user.physiology.brute_mod *= 0.5
	user.physiology.burn_mod *= 0.5

/datum/dice_roll/random_bundle
	number = 18

/datum/dice_roll/random_bundle/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("Появился подозрительный радио маяк!"))
	new /obj/item/beacon/syndicate/bundle/magical(dice.loc)
	create_smoke(2, dice.loc)

/datum/dice_roll/magic_coin
	number = 19

/datum/dice_roll/magic_coin/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("В руках у [user.declent_ru(GENITIVE)] появляется странная монета!"))
	var/coin = new /obj/item/coin/magic
	user.put_in_hands(coin)

/datum/dice_roll/become_wizard
	number = 20

/datum/dice_roll/become_wizard/activate(mob/living/carbon/human/user, obj/item/dice/d20/fate/dice)
	user.visible_message(span_userdanger("Потоки магической энергии вылетают из [dice.declent_ru(GENITIVE)] в сторону [user.declent_ru(GENITIVE)]!"))
	user.mind.make_Wizard()

/datum/dice_roll/proc/create_smoke(amount, location)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = amount, location = location)
	smoke.start()
