/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Админордразин"
	id = "adminordrazine"
	description = "Это магия. Тут нечего объяснять."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_description = "админ абуза"

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.setCloneLoss(0, FALSE)
	M.setOxyLoss(0, FALSE)
	M.radiation = 0
	M.adjustBruteLoss(-5, FALSE)
	M.adjustFireLoss(-5, FALSE)
	M.adjustToxLoss(-5, FALSE)
	M.setBrainLoss(0, FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/organ as anything in H.internal_organs)
			organ.internal_receive_damage(-5)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
		H.remove_all_parasites()
	M.SetEyeBlind(0)
	M.CureNearsighted(FALSE)
	M.CureBlind(FALSE)
	M.CureMute()
	M.CureDeaf()
	M.CureEpilepsy()
	M.CureTourettes()
	M.CureCoughing()
	M.CureNervous()
	M.SetEyeBlurry(0)
	M.SetDisgust(0)
	M.SetWeakened(0)
	M.SetKnockdown(0)
	M.SetStunned(0)
	M.SetImmobilized(0)
	M.SetParalysis(0)
	M.SetSilence(0)
	M.SetHallucinate(0)
	M.SetDeaf(0)
	REMOVE_TRAITS_NOT_IN(M, list(ROUNDSTART_TRAIT))
	M.SetDizzy(0)
	M.SetDrowsy(0)
	M.SetStuttering(0)
	M.SetSlur(0)
	M.SetConfused(0)
	M.SetSleeping(0)
	M.SetJitter(0)
	for(var/thing in M.diseases)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
			continue
		D.cure(need_immunity = FALSE)
	..()
	return STATUS_UPDATE_ALL

/datum/reagent/medicine/adminordrazine/nanites
	name = "Наниты"
	id = "nanites"
	description = "Наномашины, способствующие быстрой регенерации клеточной структуры."
	taste_description = "наномашин, сынок"

/datum/reagent/admin_cleaner
	name = "WD-2381"
	color = "#da9eda"
	can_synth = FALSE
	description = "Супер-пузырьковое чистящее средство, предназначенное для очистки всех предметов. Или, ну, всего, что не прикручено. Или прикуручено, если уж на то пошло. Другими словами: если вы это видите, как вы это заполучили?"

/datum/reagent/admin_cleaner/organic
	name = "WD-2381-MOB"
	id = "admincleaner_mob"
	description = "Бутылочка со странными нанитами, мгновенно пожирающими тела, как живые, так и мёртвые, а также органы."

/datum/reagent/admin_cleaner/organic/reaction_mob(mob/living/M, method, volume, show_message)
	. = ..()
	if(method == REAGENT_TOUCH)
		M.dust()

/datum/reagent/admin_cleaner/organic/reaction_obj(obj/O, volume)
	if(is_organ(O))
		qdel(O)
	if(istype(O, /obj/effect/decal/cleanable/blood) || istype(O, /obj/effect/decal/cleanable/vomit))
		qdel(O)
	if(istype(O, /obj/item/mmi))
		qdel(O)

/datum/reagent/admin_cleaner/item
	name = "WD-2381-ITM"
	id = "admincleaner_item"
	description = "Бутылочка со странными нанитами, которые мгновенно пожирают предметы, оставляя всё остальное нетронутым."

/datum/reagent/admin_cleaner/item/reaction_obj(obj/O, volume)
	if(isitem(O) && !istype(O, /obj/item/grenade/clusterbuster/segment))
		qdel(O)

/datum/reagent/admin_cleaner/all
	name = "WD-2381-ALL"
	id = "admincleaner_all"
	description = "Невероятно опасный набор нанитов, созданный Уборщиками Синдиката, которые пожирают всё, к чему прикасаются."

/datum/reagent/admin_cleaner/all/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/grenade/clusterbuster/segment))
		// don't clear clusterbang segments
		// I'm allowed to make this hack because this is admin only anyway
		return
	if(!iseffect(O))
		qdel(O)

/datum/reagent/admin_cleaner/all/reaction_mob(mob/living/M, method, volume, show_message)
	. = ..()
	if(method == REAGENT_TOUCH)
		M.dust()

