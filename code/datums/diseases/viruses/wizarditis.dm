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
	severity = DISEASE_SEVERITY_HARMFUL
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
	var/mob/living/carbon/human/human = affected_mob
	switch(pick("head", "robe", "sandal", "staff"))

		if("head")
			if(!istype(human.head, /obj/item/clothing/head/wizard))
				if(!human.drop_item_ground(human.head))
					qdel(human.head)
				human.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(human), ITEM_SLOT_HEAD)
				return

		if("robe")
			if(!istype(human.wear_suit, /obj/item/clothing/suit/wizrobe))
				if(!human.drop_item_ground(human.wear_suit))
					qdel(human.wear_suit)
				human.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(human), ITEM_SLOT_CLOTH_OUTER)
				return

		if("sandal")
			if(!istype(human.shoes, /obj/item/clothing/shoes/sandal))
				if(!human.drop_item_ground(human.shoes))
					qdel(human.shoes)
				human.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(human), ITEM_SLOT_FEET)
				return

		if("staff")
			if(!istype(human.r_hand, /obj/item/twohanded/staff))
				human.drop_r_hand()
				human.put_in_r_hand(new /obj/item/twohanded/staff(human))
				return

/datum/disease/virus/wizarditis/proc/teleport()
	var/list/theareas = get_areas_in_range(80, affected_mob)
	for(var/area/space/space in theareas)
		theareas -= space

	for(var/ar in theareas)
		var/area/zone = ar
		if(zone.tele_proof)
			theareas -= zone

	if(!theareas||!length(theareas))
		return

	var/area/thearea = pick(theareas)

	var/list/L = list()
	for(var/turf/turf in get_area_turfs(thearea.type))
		if(turf.z != affected_mob.z) continue
		if(turf.name == "space") continue
		if(!turf.density)
			var/clear = 1
			for(var/obj/obj in turf)
				if(obj.density)
					clear = 0
					break
			if(clear)
				L+=turf

	if(!L)
		return

	var/turf/target_turf = pick(L)

	if(is_teleport_allowed(target_turf.z))
		affected_mob.say("SCYAR NILA [uppertext(thearea.name)]!")
		affected_mob.forceMove(target_turf)

	return
