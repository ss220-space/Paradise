/*
 * Reagents created and used by ninja's suit only.
 */

/*
 * Chiyurizine
 * A reagent that can heal almost anything, but is very slow to metabolise, and risky if you overdose it.
 * It "rewinds" your body to a healthy state and makes you younger. it even has a veeery small chance to rewind itself,
 * to start the healing cycle again. But if you overdose... You are going to become old, suffer from time paradoxes rewinding your position
 * and from many annoing debuffs like slowness and confusion. If you survive until it turns you 100 years old. You will play a forced game of dice with death.
 * For the last chance to survive.
 */
/datum/reagent/medicine/chiyurizine
	name = "Чиюризин"
	id = "chiyurizine"
	description = "Мощный экспериментальный состав, способный стремительно восстановить ткани после широкого спектра повреждений. Частое использование приводит к быстрому старению. Очень быстрому."
	reagent_state = LIQUID
	color = "#55ff63"
	can_synth = FALSE
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	harmless = FALSE
	overdose_threshold = 30
	taste_description = "неумолимого течения времени"
	var/turf/last_random_turf //For overdose teleports
	var/can_work = FALSE //Can metabolise only if it was added in a dose equal to overdose_threshold-5 or more
	var/obj/effect/temp_visual/ninja_rend/rend = null//Unharmfull trap for playing with time

/datum/reagent/medicine/chiyurizine/on_mob_life(mob/living/our_mob)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume >= overdose_threshold-5)
		can_work = TRUE
	if(!can_work)
		volume = 0.1
	if(prob(5) && !rend)
		rend = new(get_turf(our_mob))
		rend.GetOccupant(our_mob)
		addtimer(CALLBACK(src, PROC_REF(clearRend)), rend.duration)
	if(prob(25))
		last_random_turf = get_turf(our_mob)
	//We don't tolerate ANY other reagent.
	for(var/datum/reagent/R in our_mob.reagents.reagent_list)
		if(R != src)
			our_mob.reagents.remove_reagent(R.id,5)
	switch(current_cycle)
		if(1 to 20)
			if(prob(10))
				to_chat(our_mob, span_notice("Вы чувствуете, будто бы время оборачивается вспять!"))
				our_mob.emote("giggle")
			// Anti-Drunk
			our_mob.SetSlur(0)
			our_mob.AdjustDrunk(-8 SECONDS)
			our_mob.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 8, 0, 1)
			//Basic damage types
			update_flags |= our_mob.adjustBruteLoss(-5, FALSE, affect_robotic = FALSE)
			update_flags |= our_mob.adjustFireLoss(-5, FALSE, affect_robotic = FALSE)
			update_flags |= our_mob.adjustOxyLoss(-5, FALSE)
			update_flags |= our_mob.adjustToxLoss(-5, FALSE)
			//Eyes and ears
			our_mob.AdjustEyeBlurry(-2 SECONDS)
			our_mob.AdjustDeaf(-2 SECONDS)
			//Clone and brain
			update_flags |= our_mob.adjustBrainLoss(-5, FALSE)
			update_flags |= our_mob.adjustCloneLoss(-5, FALSE)
			//Other helpfull things
			our_mob.AdjustLoseBreath(-10 SECONDS, bound_lower = 10 SECONDS)
			our_mob.AdjustParalysis(-2 SECONDS)
			our_mob.AdjustWeakened(-2 SECONDS)
		if(20 to 40)
			//Human only effects
			if(ishuman(our_mob))
				var/mob/living/carbon/human/mob_human = our_mob
				if(prob(10))
					to_chat(mob_human, span_notice("Вы чувствуете мощный прилив сил, а ваше тело начинает стремительно исцеляться."))
					mob_human.Jitter(40 SECONDS)
				// Regrow limbs
				if(current_cycle == 30)
					to_chat(mob_human, span_notice("Ваше тело восстанавливается..."))
					mob_human.check_and_regenerate_organs()
				// Embedded objects
				mob_human.remove_all_embedded_objects()
				// Organs
				for(var/obj/item/organ/internal/internal_organ as anything in mob_human.internal_organs)
					if(prob(20))
						internal_organ.rejuvenate()
						internal_organ.internal_receive_damage(-5)
				// Bones
				for(var/obj/item/organ/external/external_organ as anything in mob_human.bodyparts)
					if(prob(20))
						external_organ.rejuvenate()
				//Eyes and Ears internal damage
				var/obj/item/organ/internal/eyes/our_eyes = mob_human.get_int_organ(/obj/item/organ/internal/eyes)
				if(istype(our_eyes))
					our_eyes.heal_internal_damage(5, robo_repair = TRUE)
				var/obj/item/organ/internal/ears/our_ears = mob_human.get_int_organ(/obj/item/organ/internal/ears)
				if(istype(our_ears))
					our_ears.heal_internal_damage(-5)
					if(our_ears.damage < 25 && prob(30))
						mob_human.SetDeaf(0)
				//ALL viruses
				for(var/thing in mob_human.diseases)
					var/datum/disease/our_disease = thing
					our_disease.cure(0)
				//Genes(resets them like mutadone)
				for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
					if(!LAZYIN(mob_human.dna.default_blocks, gene.block))
						mob_human.force_gene_block(gene.block, FALSE)
				mob_human.dna.struc_enzymes = mob_human.dna.struc_enzymes_original

		if(40 to INFINITY)
			if(ishuman(our_mob))
				var/mob/living/carbon/human/mob_human = our_mob
				if(mob_human.age > 20 && prob(50))
					if(!overdosed)
						to_chat(mob_human, span_notice("Вы чувствуете себя моложе чем были!"))
						mob_human.age--
					if(prob(1))	// A very little chance to start the healing process again.
						current_cycle = 1
						to_chat(mob_human, span_notice("У вас возникает ощущение, что вещество внутри вас обновляет... себя?"))
	return ..() | update_flags

/datum/reagent/medicine/chiyurizine/overdose_process(mob/living/our_mob, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(our_mob))
		var/mob/living/carbon/human/mob_human = our_mob
		if(mob_human.age >= 100)//Critical age. You either die, or get a last chance to live.
			mob_human.adjustOxyLoss(10, FALSE)
			var/fate = roll("1d6")
			to_chat(mob_human, span_boldwarning("Вам кажется, что вы играете в кости с самой смертью!"))
			switch(fate)
				if(1)
					mob_human.age = 99
					mob_human.adjustOxyLoss(500, FALSE)
					volume = 0.2
					to_chat(mob_human, span_boldwarning("Две единицы! Вам становится трудно дышать..."))
				if(2 to 4)
					to_chat(mob_human, span_boldwarning("Ваша судьба не определена... Ещё бросок..."))
				if(6)
					mob_human.age = 90
					current_cycle = 1
					volume = 5
					to_chat(mob_human, span_boldwarning("Две шестёрки! Похоже, в этот раз смерть обошла вас стороной."))
		if(mob_human.age >= 50)
			mob_human.change_hair_color(colour = "#ffffff")
			mob_human.change_hair_gradient(color = "#808080")
		if(prob(clamp(100-mob_human.age, 10, 100)))
			to_chat(our_mob, span_warning("Вы стремительно стареете!"))
			mob_human.age = mob_human.age + pick(1,2,3)
		if(prob(50))
			if(prob(25))
				var/phrase = pick("Боль в спине убивает вас!", "Вы так устали...",
					"Существование - это боль!", "Вы медленно умираешь...",
					"Чёрт...", "У вас такие тонкие пальцы...")
				to_chat(our_mob, span_warning(phrase))
			mob_human.emote("moan")
			mob_human.adjustBruteLoss(0.5, FALSE)
		if(prob(20))
			mob_human.Slowed(4 SECONDS)
			mob_human.Confused(20 SECONDS)
			mob_human.EyeBlurry(4 SECONDS)
		if(prob(10) && last_random_turf && istype(mob_human.loc, /turf) && !rend)
			mob_human.visible_message(span_info("[mob_human] vanished!"), span_warning("Вы переместились в знакомое место..."))
			new /obj/effect/temp_visual/gravpush(get_turf(mob_human))
			playsound(get_turf(mob_human), 'sound/magic/timeparadox2.ogg', 100, 1, -1)
			mob_human.forceMove(last_random_turf)
		if(prob(2))
			mob_human.Drowsy(20 SECONDS)
		if(prob(1))
			mob_human.EyeBlind(20 SECONDS)
			our_mob.adjustBrainLoss(5, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/chiyurizine/proc/clearRend()
	rend = null
