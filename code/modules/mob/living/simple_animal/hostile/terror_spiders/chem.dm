#define DEFAULT_EGGS_SPAWN_VOLUME 5
// Terror Spider, Black, Deadly Venom

/datum/reagent/terror_black_toxin
	name = "Яд Вдовы Ужаса"
	id = "terror_black_toxin"
	description = "Невероятно токсичный яд, который впрыскивает Вдова Ужаса."
	can_synth = FALSE
	color = "#cc00ff"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/terror_black_toxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume < 30)
		// bitten once, die very slowly. Easy to survive a single bite - just go to medbay.
		// total damage: 1/tick, human health 150 until crit, = 150 ticks, = 300 seconds = 5 minutes to get to medbay.
		update_flags |= M.adjustToxLoss(1, FALSE)
		M.EyeBlurry(6 SECONDS)
	else if(volume < 60)
		// bitten twice, die slowly. Get to medbay.
		// total damage: 2/tick, human health 150 until crit, = 75 ticks, = 150 seconds = 2.5 minutes to get some medical treatment.
		update_flags |= M.adjustToxLoss(2, FALSE)
		M.EyeBlurry(6 SECONDS)
	else if(volume < 90)
		// bitten thrice, die quickly, severe muscle cramps make movement very difficult. Even calling for help probably won't save you.
		// total damage: 4, human health 150 until crit, = 37.5 ticks, = 75s = 1m15s until death
		update_flags |= M.adjustToxLoss(4, FALSE)
		M.EyeBlurry(12 SECONDS)
		M.Confused(12 SECONDS)
	else
		// bitten 4 or more times, whole body goes into shock/death
		// total damage: 8, human health 150 until crit, = 18.75 ticks, = 37s until death
		update_flags |= M.adjustToxLoss(8, FALSE)
		M.EyeBlurry(12 SECONDS)
		M.Paralyse(10 SECONDS)
	return ..() | update_flags

/datum/reagent/organ_spawner
	name = "Вы не должны видеть этого"
	id = "spawner_template"
	description = "Пациент, да у вас чужой"
	can_synth = FALSE //stop arbuze

	var/obj/item/organ/internal/organ_type
	var/need_volume_to_inject = DEFAULT_EGGS_SPAWN_VOLUME

/datum/reagent/organ_spawner/on_mob_life(mob/living/target)
	if(!organ_type)
		return ..()

	organ_inject(target)
	return ..()

/datum/reagent/organ_spawner/proc/organ_inject(mob/living/target)
	if(volume < need_volume_to_inject)
		return

	if(!iscarbon(target))
		return

	if(target.get_int_organ(organ_type))
		return

	new organ_type(target)

/datum/reagent/organ_spawner/terror_eggs
	name = "Яйца паука ужаса"
	id = "terror_eggs"
	description = "Стремительно растущие паучьи яйца."
	color = "#6b336b"
	taste_mult = 0
	organ_type = /obj/item/organ/internal/body_egg/terror_eggs

/datum/reagent/organ_spawner/terror_eggs/phantom
	id = "terror_phantom_eggs"
	organ_type = /obj/item/organ/internal/body_egg/terror_eggs/phantom

#undef DEFAULT_EGGS_SPAWN_VOLUME
