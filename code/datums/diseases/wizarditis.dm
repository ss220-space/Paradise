/datum/disease/wizarditis
	name = "Визардис"
	max_stages = 4
	spread_text = "Аэрогенный"
	cure_text = "The Manly Dorf"
	cures = list("manlydorf")
	cure_chance = 100
	agent = "Ринсвиндий обыкновенный"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	desc = "Поговаривают, что этот вирус — причина существования Федерации Космических Волшебников. Поражённые им субъекты выказывают признаки деменции, выкрикивают невразумительные предложения и несут околесицу. На поздних стадиях субъекты иногда ощущают внутреннюю силу и, цитата, <i>«способность управлять силами самого космоса!»</i>. Глоток крепкого мужественного спирта обычно возвращает их в нормальное состояние."
	severity = HARMFUL
	required_organs = list(/obj/item/organ/external/head)

/*
BIRUZ BENNAR
SCYAR NILA - teleport
NEC CANTIO - dis techno
EI NATH - shocking grasp
AULIE OXIN FIERA - knock
TARCOL MINTI ZHERI - forcewall
STI KALY - blind
*/

/datum/disease/wizarditis/stage_act()
	..()

	switch(stage)
		if(2)
			if(prob(1)&&prob(50))
				affected_mob.say(pick("Ты не пройдёшь!", "Экспеллиармус!", "Мерлинова борода!", "Ты познаешь всю мощь Тёмной стороны!"))
			if(prob(1)&&prob(50))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете [pick("что у вас недостаточно маны", "что ветра магии иссякли", "сильное желание призвать фамильяра")].</span>")


		if(3)
			if(prob(1)&&prob(50))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(1)&&prob(50))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете [pick("как магия бурлит в венах","что эта локация даёт вам +1 ИНТ","сильное желание призвать фамильяра")].</span>")

		if(4)

			if(prob(1))
				affected_mob.say(pick("NEC CANTIO!","AULIE OXIN FIERA!","STI KALY!","EI NATH!"))
				return
			if(prob(1)&&prob(50))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете [pick("могучую волну чистой мощи, образующуюся внутри вас","что эта локация даёт вам +2 ИНТ и +1 МДР","сильное желание телепортироваться")].</span>")
				spawn_wizard_clothes(50)
			if(prob(1)&&prob(1))
				teleport()
	return



/datum/disease/wizarditis/proc/spawn_wizard_clothes(chance = 0)
	if(istype(affected_mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = affected_mob
		if(prob(chance))
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.unEquip(H.head))
					qdel(H.head)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), slot_head)
			return
		if(prob(chance))
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.unEquip(H.wear_suit))
					qdel(H.wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), slot_wear_suit)
			return
		if(prob(chance))
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(!H.unEquip(H.shoes))
					qdel(H.shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
			return
	else
		var/mob/living/carbon/H = affected_mob
		if(prob(chance))
			if(!istype(H.r_hand, /obj/item/twohanded/staff))
				H.drop_r_hand()
				H.put_in_r_hand( new /obj/item/twohanded/staff(H) )
			return
	return



/datum/disease/wizarditis/proc/teleport()
	var/list/theareas = get_areas_in_range(80, affected_mob)
	for(var/area/space/S in theareas)
		theareas -= S

	if(!theareas||!theareas.len)
		return

	var/area/thearea = pick(theareas)

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(T.z != affected_mob.z) continue
		if(T.name == "space") continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	if(!L)
		return

	affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!")
	affected_mob.loc = pick(L)

	return
