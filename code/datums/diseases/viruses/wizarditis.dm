/datum/disease/virus/wizarditis
	name = "Визардис"
	agent = "Ринсвиндий обыкновенный"
	desc = "Некоторые предполагают, что этот вирус является причиной существования Федерации Волшебников. Заражённые демонстрируют признаки слабоумия, выкрикивая странные фразы или полную бессмыслицу. На поздних стадиях заражённые иногда выражают чувство внутренней силы и, цитирую, 'способность управлять силами космоса!' Глоток крепкого, мужественного напитка обычно возвращает их в нормальное, человеческое состояние."
	max_stages = 4
	visibility_flags = HIDDEN_HUD
	spread_flags = AIRBORNE
	cures = list("manlydorf")
	cure_prob = 100
	permeability_mod = 0.75
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

/datum/disease/virus/wizarditis/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(5))
				affected_mob.say(pick("Ты не пройдёшь!", "Экспеллиармус!", "Клянусь бородой Мерлина!", "Чёртовы маглы!"))
			if(prob(3))
				to_chat(affected_mob, span_danger("Вы чувствуете, что [pick("вам не хватает маны", "ваши пальцы искрятся магией", "вам доступен 9-й уровень заклинаний")]."))


		if(3)
			if(prob(2))
				affected_mob.say(pick("NEC CANTIO!", "CLANG!", "STI KALY!", "TARCOL MINTI ZHERI!"))
			if(prob(6))
				to_chat(affected_mob, span_danger("Вы чувствуете, как [pick("магия бурлит в ваших жилах", "это место даёт вам +1 к интеллекту", "вам нужно срочно выучить новое заклинание")]."))

		if(4)
			if(prob(3))
				affected_mob.say(pick("NEC CANTIO!", "AULIE OXIN FIERA!", "DIRI CEL!", "EI NATH!"))
			if(prob(1))
				to_chat(affected_mob, span_danger("Вы чувствуете, как [pick("прилив чистой силы нарастает внутри вас", "это место даёт вам +2 к интеллекту и +1 к мудрости", "вам хочется телепортироваться")]."))
				spawn_wizard_clothes()
			if(prob(1))
				teleport()
	return



/datum/disease/virus/wizarditis/proc/spawn_wizard_clothes()
	var/mob/living/carbon/human/H = affected_mob
	switch(pick("head", "robe", "sandal", "staff"))

		if("head")
			if(!istype(H.head, /obj/item/clothing/head/wizard))
				if(!H.drop_item_ground(H.head))
					qdel(H.head)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), ITEM_SLOT_HEAD)
				return

		if("robe")
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!H.drop_item_ground(H.wear_suit))
					qdel(H.wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), ITEM_SLOT_CLOTH_OUTER)
				return

		if("sandal")
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				if(!H.drop_item_ground(H.shoes))
					qdel(H.shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_FEET)
				return

		if("staff")
			if(!istype(H.r_hand, /obj/item/twohanded/staff))
				H.drop_r_hand()
				H.put_in_r_hand(new /obj/item/twohanded/staff(H))
				return


/datum/disease/virus/wizarditis/proc/teleport()
	var/list/theareas = get_areas_in_range(80, affected_mob)
	for(var/area/space/S in theareas)
		theareas -= S

	for(var/ar in theareas)
		var/area/zone = ar
		if(zone.tele_proof)
			theareas -= zone

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

	var/turf/target_turf = pick(L)

	if(is_teleport_allowed(target_turf.z))
		affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!")
		affected_mob.forceMove(target_turf)

	return
