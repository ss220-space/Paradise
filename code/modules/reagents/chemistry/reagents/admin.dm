/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	process_flags = ORGANIC | SYNTHETIC	//Adminbuse knows no bounds!
	can_synth = FALSE
	taste_description = "admin abuse"

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
			organ.receive_damage(-5, FALSE)
		for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
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
	name = "Nanites"
	id = "nanites"
	description = "Nanomachines that aid in rapid cellular regeneration."
	taste_description = "nanomachines, son"
