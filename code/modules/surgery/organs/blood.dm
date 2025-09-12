// MARK: Blood System

/obj/item/organ/external/proc/suppress_bloodloss(mob/living/user, mob/living/carbon/human/target, amount, duration)
	var/calculated_bleeding = max(0, bleeding_amount - bleedsuppress)
	if(calculated_bleeding <= 0)
		return
	var/suppress_amount = calculated_bleeding
	if(calculated_bleeding > amount)
		suppress_amount = amount
		balloon_alert(user, "кровотечение перевязано")
	else
		balloon_alert(user, "кровотечение ослаблено")
	bleedsuppress += suppress_amount
	addtimer(CALLBACK(src, PROC_REF(resume_bleeding), target, suppress_amount), duration)

/obj/item/organ/external/proc/resume_bleeding(mob/living/carbon/human/target, amount)
	bleedsuppress = max(bleedsuppress - amount, 0)
	if(target.stat != DEAD && (bleeding_amount - bleedsuppress) > 0)
		to_chat(target, span_warning("Повязка полностью пропиталась кровью и больше не ослабляет кровотечение."))


/obj/item/organ/external/proc/heal_bleeding(mob/living/user, mob/living/carbon/human/target, bleeding_heal_amount, brute_damage)
	bleeding_amount = max(0, bleeding_amount - bleeding_heal_amount)
	if(brute_damage > 0)
		target.apply_damage(brute_damage, def_zone = src)
	if(!bleeding_amount)
		balloon_alert(user, "кровотечение остановлено")
		return
	balloon_alert(user, "кровотечение ослаблено")

/mob/living/carbon/human/has_bleeding()
	return bleed_rate > 0

/mob/living/carbon/human/has_heavy_bleeding()
	return bleed_rate >= HEAVY_BLEEDING_RATE

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()
	if(HAS_TRAIT(src, TRAIT_GODMODE) || HAS_TRAIT(src, TRAIT_NO_BLOOD))
		bleed_rate = 0
		return
	// cryosleep or husked people do not pump the blood.
	if(bodytemperature < TCRYO || HAS_TRAIT(src, TRAIT_NO_CLONE))
		return
	// regenerate blood VERY slowly
	if(!HAS_TRAIT(src, TRAIT_NO_BLOOD_RESTORE) && blood_volume < BLOOD_VOLUME_NORMAL)
		AdjustBlood(BLOOD_REGENERATION)
	apply_current_blood_level_effect()
	calculate_current_bleeding()

/mob/living/carbon/human/proc/apply_current_blood_level_effect()
	switch(blood_volume)
		if(BLOOD_VOLUME_PALE to BLOOD_VOLUME_SAFE)
			apply_damage(BLOOD_OKAY_DAMAGE, dna.species.blood_damage_type, spread_damage = TRUE, forced = TRUE)

		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_PALE)
			apply_damage(BLOOD_OKAY_DAMAGE, dna.species.blood_damage_type, spread_damage = TRUE, forced = TRUE)
			if(prob(5))
				var/symptom = pick("слабость",
					"лёгкое головокружение",
					"небольшую тошноту")
				to_chat(src, span_warning("Вы чувствуете [symptom]."))

		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			apply_damage(BLOOD_BAD_DAMAGE, dna.species.blood_damage_type, spread_damage = TRUE, forced = TRUE)
			if(prob(5))
				EyeBlurry(12 SECONDS)
				var/symptom = pick("сильную слабость",
					"сильное головокружение",
					"нарастающую тошноту",
					"спутанность сознания")
				to_chat(src, span_warning("Вы чувствуете [symptom]."))

		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			apply_damage(BLOOD_SURVIVE_DAMAGE, dna.species.blood_damage_type, spread_damage = TRUE, forced = TRUE)
			if(prob(15))
				Paralyse(rand(2 SECONDS, 6 SECONDS))
				var/symptom = pick("крайнюю слабость",
					"очень сильное головокружение",
					"невыносимую тошноту",
					"полную дезориентацию")
				to_chat(src, span_warning("Вы чувствуете [symptom]."))

		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			death()

/mob/living/carbon/human/proc/calculate_current_bleeding()
	//not calculate bleeding for fake dath
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return
	var/current_bleed = 0
	var/internal_bleeding_rate = 0
	// calculate total bleeding from bodyparts
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.is_robotic())
			continue
		if(bodypart.has_internal_bleeding())
			internal_bleeding_rate += BODYPART_INTERNAL_BLEEDING
		if(bodypart.bleeding_amount > 0)
			bodypart.bleeding_amount = max(0, bodypart.bleeding_amount - BLEEDING_DECREASE)
			if(bodypart.bleedsuppress > bodypart.bleeding_amount)
				bodypart.bleedsuppress = bodypart.bleeding_amount
		var/bodypart_bleeding = max(bodypart.bleeding_amount - bodypart.bleedsuppress * BRUISE_PACK_SUPPRESS_BLEEDING_MOD, 0)
		bodypart_bleeding = bodypart_bleeding * BLEEDING_MODIFIER * bodypart.bleeding_mod
		current_bleed += bodypart_bleeding
		var/embedded_length = LAZYLEN(bodypart.embedded_objects)
		if(embedded_length && bodypart.bleedsuppress > 0)
			current_bleed += EMBEDDED_ITEM_BLEEDING * embedded_length
		if(bodypart.open)
			current_bleed += OPEN_BODYPART_BLEEDING
	// calculate bleed rate with regenretion and current bleed
	var/prev_bleed_rate = bleed_rate
	bleed_rate = current_bleed
	//manage alert
	if(prev_bleed_rate <= 0 && bleed_rate > 0)
		throw_alert(ALERT_BLEEDING, /atom/movable/screen/alert/bleeding)
	if(prev_bleed_rate > 0 && bleed_rate <= 0)
		clear_alert(ALERT_BLEEDING)
	// calculate addition bleeding from reagents
	var/additional_bleed_mod = 1
	var/heparin_amount = reagents.get_reagent_amount("heparin")
	if(heparin_amount > 0)
		additional_bleed_mod += round(clamp((heparin_amount / 20), 0, 1) * 0.75, 0.05) //heparin worsens existing bleeding
	var/traneksam_amount = reagents.get_reagent_amount("traneksam_acid")
	if(traneksam_amount > 0)
		additional_bleed_mod -= round(clamp((traneksam_amount / 10), 0, 1) * 0.75, 0.05) //traneksam acid suppress existing bleeding
	// apply internal bleeding
	if(internal_bleeding_rate)
		bleed_internal(internal_bleeding_rate * additional_bleed_mod)
	// apply bleeding
	if(bleed_rate && !bleedsuppress)
		bleed(bleed_rate * additional_bleed_mod)


/// Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt)
	if(!blood_volume)
		return FALSE

	. = TRUE

	AdjustBlood(-amt)

	if(!isturf(loc)) //Blood loss still happens in locker, floor stays clean
		return .

	if(amt >= 10)
		add_splatter_floor(loc)

	else
		add_splatter_floor(loc, small_drip = TRUE)


/mob/living/carbon/human/bleed(amt)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	amt *= physiology.bleed_mod
	. = ..()
	if(!. || !HAS_TRAIT(src, TRAIT_EXOTIC_BLOOD))
		return .
	var/datum/reagent/blood_reagent = GLOB.chemical_reagents_list[get_blood_id()]
	if(!istype(blood_reagent) || !isturf(loc))
		return .
	blood_reagent.reaction_turf(loc, amt * EXOTIC_BLEED_MULTIPLIER, dna.species.blood_color)


/mob/living/carbon/proc/bleed_internal(amt)
	if(!blood_volume)
		return FALSE

	. = TRUE

	AdjustBlood(-amt)

	if(prob(10 * amt)) // +5% chance per internal bleeding site that we'll cough up blood on a given tick.
		custom_emote(EMOTE_AUDIBLE, "кашля%(ет, ют)% кровью!")
		add_splatter_floor(loc, small_drip = TRUE)
		return .

	// +2.5% chance per internal bleeding site that we'll cough up blood on a given tick.
	// Must be bleeding internally in more than one place to have a chance at this.
	if(amt >= 1 && prob(5 * amt))
		vomit(mode = VOMIT_BLOOD)


/mob/living/carbon/human/bleed_internal(amt)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	amt *= physiology.bleed_mod
	. = ..()
	if(!. || !HAS_TRAIT(src, TRAIT_EXOTIC_BLOOD))
		return .
	var/datum/reagent/blood_reagent = GLOB.chemical_reagents_list[get_blood_id()]
	if(!istype(blood_reagent) || !isturf(loc))
		return .
	blood_reagent.reaction_turf(loc, amt * EXOTIC_BLEED_MULTIPLIER, dna.species.blood_color)

/mob/living/proc/AdjustBlood(amount = 0)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_BLOOD_ADJUST, amount) & COMPONENT_PREVENT_BLOODLOSS)
		return FALSE

	blood_volume = max(round(blood_volume + amount, DAMAGE_PRECISION), 0)
	SEND_SIGNAL(src, COMSIG_LIVING_BLOOD_ADJUSTED, amount)

	return TRUE

/mob/living/carbon/human/AdjustBlood(amount = 0, bleed_mode_affect = FALSE)
	if(bleed_mode_affect)
		amount *= physiology.bleed_mod

	return ..(amount)

/mob/living/proc/setBlood(amount)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_EARLY_SET_BLOOD, amount) & COMPONENT_PREVENT_BLOODLOSS)
		return FALSE

	blood_volume = max(round(amount, DAMAGE_PRECISION), 0)
	SEND_SIGNAL(src, COMSIG_LIVING_SET_BLOOD, amount)

	return TRUE

/mob/living/proc/restore_blood()
	setBlood(initial(blood_volume))

/mob/living/carbon/human/restore_blood()
	setBlood(BLOOD_VOLUME_NORMAL)
	bleed_rate = 0

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	AdjustBlood(-amount)

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_data["diseases"])
			for(var/datum/disease/virus/V in blood_data["diseases"])
				if(V.spread_flags < BLOOD)
					continue
				V.Contract(C)
		if(blood_id == C.get_blood_id() && !HAS_TRAIT(C, TRAIT_NO_BLOOD_RESTORE))//both mobs have the same blood substance
			if(blood_id == "blood") //normal blood
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)) || !(blood_data["blood_species"] == C.dna.species.blood_species))
					C.reagents.add_reagent("toxin", amount * 0.5)
					return 1

			C.setBlood(min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_NORMAL))
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1

/// Returns the color of the mob's blood.
/mob/living/proc/get_blood_color()
	var/bloodcolor = BLOOD_COLOR_RED
	var/list/b_data = get_blood_data(get_blood_id())
	if(b_data)
		bloodcolor = b_data["blood_color"] || BLOOD_COLOR_RED
	return bloodcolor

/mob/living/carbon/alien/get_blood_color()
	return BLOOD_COLOR_XENO

/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/human/get_blood_data(blood_id)
	var/blood_data = list()
	if(blood_id in GLOB.diseases_carrier_reagents)
		blood_data["diseases"] = list()
		for(var/datum/disease/D in diseases)
			blood_data["diseases"] += D.Copy()
		if(LAZYLEN(resistances))
			blood_data["resistances"] = resistances.Copy()

	switch(blood_id)
		if("blood")
			blood_data["donor"] = src
			blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
			var/list/temp_chem = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				temp_chem[R.id] = R.volume
			blood_data["trace_chem"] = list2params(temp_chem)
			if(mind)
				blood_data["mind"] = mind
			if(ckey)
				blood_data["ckey"] = ckey
			if(!suiciding && !HAS_TRAIT(src, TRAIT_NO_SCAN))
				blood_data["cloneable"] = 1
			blood_data["blood_type"] = copytext(src.dna.blood_type, 1, 0)
			blood_data["blood_species"] = dna.species.blood_species
			blood_data["gender"] = gender
			blood_data["real_name"] = real_name
			blood_data["blood_color"] = dna.species.blood_color
			blood_data["factions"] = faction
			blood_data["dna"] = dna.Clone()

		if("slimejelly")
			blood_data["colour"] = dna.species.blood_color
			blood_data["blood_color"] = dna.species.blood_color

		if("cryoxadone")
			blood_data["blood_color"] = dna.species.blood_color

	return blood_data


//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return ""


/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return "blood"
	return ""


/mob/living/carbon/human/get_blood_id()
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return ""
	if(HAS_TRAIT(src, TRAIT_EXOTIC_BLOOD))	//some races may bleed water..or kethcup..
		return dna.species.exotic_blood
	return "blood"


// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return
	switch(bloodtype)
		if("A-")
			return list("A-", "O-")
		if("A+")
			return list("A-", "A+", "O-", "O+")
		if("B-")
			return list("B-", "O-")
		if("B+")
			return list("B-", "B+", "O-", "O+")
		if("AB-")
			return list("A-", "B-", "O-", "AB-")
		if("AB+")
			return list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+")
		if("O-")
			return list("O-")
		if("O+")
			return list("O-", "O+")

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	var/static/list/acceptable_blood = list("blood", "cryoxadone", "slimejelly")
	var/check_blood = get_blood_id()
	if(!check_blood || !(check_blood in acceptable_blood))//is it blood or welding fuel?
		return
	if(!T)
		T = get_turf(src)
	if(!T || T.density || isopenspaceturf(T) && !GET_TURF_BELOW(T))
		return

	var/list/temp_blood_DNA
	var/list/b_data = get_blood_data(check_blood)

	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.overlays |= pick(drop.random_icon_states)
				drop.transfer_mob_blood_dna(src)
				drop.basecolor = b_data["blood_color"]
				drop.update_icon()
			else
				temp_blood_DNA = list()
				temp_blood_DNA |= drop.blood_DNA.Copy() //we transfer the dna from the drip to the splatter
				qdel(drop)
		else
			drop = new(T)
			drop.transfer_mob_blood_dna(src)
			drop.basecolor = b_data["blood_color"]
			drop.update_icon()
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in T
	var/list/bloods = get_atoms_of_type(T, B, TRUE, 0, 0) //Get all the non-projectile-splattered blood on this turf (not pixel-shifted).
	if(shift_x || shift_y)
		bloods = get_atoms_of_type(T, B, TRUE, shift_x, shift_y) //Get all the projectile-splattered blood at these pixels on this turf (pixel-shifted).
		B = locate() in bloods
	if(!B)
		B = new(T)
	if(B.bloodiness < MAX_SHOE_BLOODINESS) //add more blood, up to a limit
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.blood_DNA |= temp_blood_DNA
	B.pixel_x = (shift_x)
	B.pixel_y = (shift_y)
	B.update_icon()
	if(shift_x || shift_y)
		B.off_floor = TRUE
		B.layer = BELOW_MOB_LAYER //So the blood lands ontop of things like posters, windows, etc.


/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	if(!T)
		T = get_turf(src)

	var/obj/effect/decal/cleanable/blood/xeno/splatter/B = locate() in T
	var/list/bloods = get_atoms_of_type(T, B, TRUE, 0, 0) //The more the better.
	if(shift_x || shift_y)
		bloods = get_atoms_of_type(T, B, TRUE, shift_x, shift_y)
		B = locate() in bloods
	if(!B)
		B = new(T)

	B.blood_DNA["UNKNOWN DNA"] = "X*"
	B.pixel_x = (shift_x)
	B.pixel_y = (shift_y)
	if(shift_x || shift_y)
		B.off_floor = TRUE
		B.layer = BELOW_MOB_LAYER

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	if(!T)
		T = get_turf(src)

	var/obj/effect/decal/cleanable/blood/oil/streak/O = locate() in T
	var/list/oils = get_atoms_of_type(T, O, TRUE, 0, 0) //Don't let OSHA catch wind of this.
	if(shift_x || shift_y)
		oils = get_atoms_of_type(T, O, TRUE, shift_x, shift_y)
		O = locate() in oils
	if(!O)
		O = new(T)

	O.pixel_x = (shift_x)
	O.pixel_y = (shift_y)
	if(shift_x || shift_y)
		O.off_floor = TRUE
		O.layer = BELOW_MOB_LAYER

/mob/living/silicon/robot/cogscarab/add_splatter_floor(turf/T, small_drip, shift_x, shift_y)
	if(!T)
		T = get_turf(src)

	var/obj/effect/decal/cleanable/blood/clock/streak/oil = locate() in T
	var/list/oils = get_atoms_of_type(T, oil, TRUE, 0, 0)
	if(shift_x || shift_y)
		oils = get_atoms_of_type(T, oil, TRUE, shift_x, shift_y)
		oil = locate() in oils
	if(!oil)
		oil = new(T)

	oil.pixel_x = (shift_x)
	oil.pixel_y = (shift_y)
	if(shift_x || shift_y)
		oil.off_floor = TRUE
		oil.layer = BELOW_MOB_LAYER
