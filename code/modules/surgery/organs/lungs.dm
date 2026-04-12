/obj/item/organ/internal/lungs
	name = "lungs"
	desc = "Парный орган, отвечающий за газообмен между внешней средой и кровотоком организма гуманоида. Эти принадлежали человеку."
	gender = PLURAL
	icon_state = "lungs"
	slot = INTERNAL_ORGAN_LUNGS
	w_class = WEIGHT_CLASS_NORMAL

	//Breath damage
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent

	var/BZ_trip_balls_min = 1 //BZ gas
	var/BZ_brain_damage_min = 10 //Give people some room to play around without killing the station
	var/gas_stimulation_min = 0.002 // For, Pluoxium, Nitrium and Freon
	///Minimum amount of healium to make you unconscious for 4 seconds
	var/healium_para_min = 3
	///Minimum amount of healium to knock you down for good
	var/healium_sleep_min = 6
	///Minimum amount of helium to affect speech
	var/helium_speech_min = 5
	///Whether these lungs react negatively to miasma
	var/suffers_miasma = TRUE

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/tox_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/tox_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/tox_damage_type = TOX

	var/tritium_irradiation_moles_min = 1
	var/tritium_irradiation_moles_max = 15
	var/tritium_irradiation_probability_min = 10
	var/tritium_irradiation_probability_max = 60

	var/cold_message = ", что ваши дыхательные пути замораживаются"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_types = list(BURN = 1)

	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_types = list(BURN = 1)

/obj/item/organ/internal/lungs/get_ru_names()
	return list(
		NOMINATIVE = "лёгкие человека",
		GENITIVE = "лёгких человека",
		DATIVE = "лёгким человека",
		ACCUSATIVE = "лёгкие человека",
		INSTRUMENTAL = "лёгкими человека",
		PREPOSITIONAL = "лёгких человека",
	)

/obj/item/organ/internal/lungs/emp_act(severity)
	if(!is_robotic() || emp_proof)
		return
	if(emp_shielded(severity))
		return

	if(owner)
		var/losstime = 40 SECONDS
		if(HAS_TRAIT(owner, TRAIT_ADVANCED_CYBERIMPLANTS))
			losstime /= 2

		owner.LoseBreath(losstime)

/obj/item/organ/internal/lungs/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	for(var/thing in list("oxy", "tox", "co2", "nitro"))
		target.clear_alert("not_enough_[thing]")
		target.clear_alert("too_much_[thing]")

/obj/item/organ/internal/lungs/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	for(var/thing in list("oxy", "tox", "co2", "nitro"))
		M.clear_alert("not_enough_[thing]")
		M.clear_alert("too_much_[thing]")
	return ..()

/obj/item/organ/internal/lungs/on_life()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			owner.custom_emote(EMOTE_AUDIBLE, "отхаркива%(ет,ют)% кровь!")
			owner.bleed(1)
		if(prob(4))
			owner.custom_emote(EMOTE_VISIBLE, "задыха%(ет,ют)%ся!")
			owner.AdjustLoseBreath(10 SECONDS)

#define PLUOXIUM_O2_EFFICIENCY 8

/obj/item/organ/internal/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_GODMODE) || HAS_TRAIT(H, TRAIT_NO_BREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(isspaceturf(H.loc))
			H.adjustOxyLoss(10)
		else
			H.adjustOxyLoss(5)

		if(safe_oxygen_min)
			H.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			H.throw_alert(ALERT_NOT_ENOUGH_TOX, /atom/movable/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			H.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
		return FALSE

	if(H.health < HEALTH_THRESHOLD_CRIT)
		return FALSE

	var/gas_breathed = 0

	//Partial pressures in our breath
	var/pluoxium_pp = breath.get_breath_partial_pressure(breath.pluoxium())
	var/O2_pp = breath.get_breath_partial_pressure(breath.oxygen()) + PLUOXIUM_O2_EFFICIENCY * pluoxium_pp
	var/N2_pp = breath.get_breath_partial_pressure(breath.nitrogen())
	var/Toxins_pp = breath.get_breath_partial_pressure(breath.toxins())
	var/CO2_pp = breath.get_breath_partial_pressure(breath.carbon_dioxide())
	var/SA_pp = breath.get_breath_partial_pressure(breath.sleeping_agent())
	var/bz_pp = breath.get_breath_partial_pressure(breath.bz())
	var/freon_pp = breath.get_breath_partial_pressure(breath.freon())
	var/halon_pp = breath.get_breath_partial_pressure(breath.halon())
	var/healium_pp = breath.get_breath_partial_pressure(breath.healium())
	var/helium_pp = breath.get_breath_partial_pressure(breath.helium())
	var/hypernob_pp = breath.get_breath_partial_pressure(breath.hypernoblium())
	var/miasma_pp = breath.get_breath_partial_pressure(breath.miasma())
	var/nitrium_pp = breath.get_breath_partial_pressure(breath.nitrium())
	var/trit_pp = breath.get_breath_partial_pressure(breath.tritium())
	var/zauker_pp = breath.get_breath_partial_pressure(breath.zauker())

	//-- OXY --//

	//Too much oxygen! //Yes, some species may not like it.
	if(safe_oxygen_max)
		if(O2_pp > safe_oxygen_max)
			var/ratio = (breath.oxygen() / safe_oxygen_max / safe_oxygen_max) * 10
			H.apply_damage(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type, spread_damage = TRUE, forced = TRUE)
			H.throw_alert(ALERT_TOO_MUCH_OXYGEN, /atom/movable/screen/alert/too_much_oxy)
		else
			H.clear_alert(ALERT_TOO_MUCH_OXYGEN)

	//Too little oxygen!
	if(safe_oxygen_min)
		if(O2_pp < safe_oxygen_min)
			gas_breathed = handle_too_little_breath(H, O2_pp, safe_oxygen_min, breath.oxygen())
			H.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
		else
			H.heal_damage_type(HUMAN_MAX_OXYLOSS, OXY)
			gas_breathed = breath.oxygen()
			H.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	//Exhale
	breath.set_oxygen(max(breath.oxygen() - gas_breathed, 0))
	breath.set_carbon_dioxide(breath.carbon_dioxide() + gas_breathed)
	gas_breathed = 0

	//-- Nitrogen --//

	//Too much nitrogen!
	if(safe_nitro_max)
		if(N2_pp > safe_nitro_max)
			var/ratio = (breath.nitrogen() / safe_nitro_max) * 10
			H.apply_damage(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type, spread_damage = TRUE, forced = TRUE)
			H.throw_alert(ALERT_TOO_MUCH_NITRO, /atom/movable/screen/alert/too_much_nitro)
		else
			H.clear_alert(ALERT_TOO_MUCH_NITRO)

	//Too little nitrogen!
	if(safe_nitro_min)
		if(N2_pp < safe_nitro_min)
			gas_breathed = handle_too_little_breath(H, N2_pp, safe_nitro_min, breath.nitrogen())
			H.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
		else
			H.heal_damage_type(HUMAN_MAX_OXYLOSS, OXY)
			gas_breathed = breath.nitrogen()
			H.clear_alert(ALERT_NOT_ENOUGH_NITRO)

	//Exhale
	breath.set_nitrogen(max(0, breath.nitrogen() - gas_breathed))
	breath.set_carbon_dioxide(breath.carbon_dioxide() + gas_breathed)
	gas_breathed = 0

	//-- CO2 --//

	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(safe_co2_max)
		if(CO2_pp > safe_co2_max)
			if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
				H.co2overloadtime = world.time
			else if(world.time - H.co2overloadtime > 120)
				H.Paralyse(6 SECONDS)
				H.apply_damage(HUMAN_MAX_OXYLOSS, co2_damage_type, spread_damage = TRUE, forced = TRUE) // Lets hurt em a little, let them know we mean business
				if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
					H.apply_damage(15, co2_damage_type, spread_damage = TRUE, forced = TRUE)
				H.throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
			if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
				H.emote("cough")

		else
			H.co2overloadtime = 0
			H.clear_alert(ALERT_TOO_MUCH_CO2)

	//Too little CO2!
	if(safe_co2_min)
		if(CO2_pp < safe_co2_min)
			gas_breathed = handle_too_little_breath(H, CO2_pp, safe_co2_min, breath.carbon_dioxide())
			H.throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
		else
			H.adjustOxyLoss(-HUMAN_MAX_OXYLOSS)
			gas_breathed = breath.carbon_dioxide()
			H.clear_alert(ALERT_NOT_ENOUGH_CO2)

	//Exhale
	breath.set_carbon_dioxide(max(0,  breath.carbon_dioxide() - gas_breathed))
	breath.set_oxygen(breath.oxygen() + gas_breathed)
	gas_breathed = 0

	//-- TOX --//

	//Too much toxins!
	if(safe_toxins_max)
		if(Toxins_pp > safe_toxins_max)
			var/ratio = (breath.toxins() / safe_toxins_max) * 10
			H.apply_damage(clamp(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type, spread_damage = TRUE, forced = TRUE)
			H.throw_alert(ALERT_TOO_MUCH_TOX, /atom/movable/screen/alert/too_much_tox)
		else
			H.clear_alert(ALERT_TOO_MUCH_TOX)

	//Too little toxins!
	if(safe_toxins_min)
		if(Toxins_pp < safe_toxins_min)
			gas_breathed = handle_too_little_breath(H, Toxins_pp, safe_toxins_min, breath.toxins())
			H.throw_alert(ALERT_NOT_ENOUGH_TOX, /atom/movable/screen/alert/not_enough_tox)
		else
			H.heal_damage_type(HUMAN_MAX_OXYLOSS, OXY)
			gas_breathed = breath.toxins()
			H.clear_alert(ALERT_NOT_ENOUGH_TOX)

	//Exhale
	breath.set_toxins(max(0, breath.toxins() - gas_breathed))
	breath.set_carbon_dioxide(breath.carbon_dioxide() + gas_breathed)
	gas_breathed = 0

	//-- TRACES --//

	if(breath.sleeping_agent())	// If there's some other shit in the air lets deal with it here.
		if(SA_pp > SA_para_min)
			H.Paralyse(6 SECONDS) // 6 seconds gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.AdjustSleeping(16 SECONDS, bound_lower = 0, bound_upper = 20 SECONDS)
		else if(SA_pp > 0.3)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))

	if(pluoxium_pp > 0)
		consume_pluoxium(H, breath, pluoxium_pp)

	if(bz_pp > 0)
		too_much_bz(H, breath, bz_pp)

	if(freon_pp > 0)
		too_much_freon(H, breath, freon_pp)

	if(halon_pp > 0)
		too_much_halon(H, breath, halon_pp)

	if(healium_pp > 0)
		consume_healium(H, breath, healium_pp)

	if(helium_pp > 0)
		consume_helium(H, breath, helium_pp)
	else
		lose_helium(H, breath)

	if(hypernob_pp > 0)
		consume_hypernoblium(H, breath, hypernob_pp)

	if(miasma_pp > 0)
		too_much_miasma(H, breath, miasma_pp)

	if(nitrium_pp > 0)
		too_much_nitrium(H, breath, nitrium_pp)

	if(trit_pp > 0)
		too_much_tritium(H, breath, trit_pp)

	if(zauker_pp > 0)
		too_much_zauker(H, breath, zauker_pp)

	handle_breath_temperature(breath, H)

	return TRUE

#undef PLUOXIUM_O2_EFFICIENCY

/// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
/obj/item/organ/internal/lungs/proc/consume_pluoxium(mob/living/carbon/breather, datum/gas_mixture/breath, pluoxium_pp)
	breath.set_pluoxium(0)
	// Metabolize to reagent.
	if(pluoxium_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/pluoxium)
		breather.reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

/// Too much funny gas, time to get brain damage
/obj/item/organ/internal/lungs/proc/too_much_bz(mob/living/carbon/breather, datum/gas_mixture/breath, bz_pp)
	breath.set_bz(0)
	if(bz_pp > BZ_trip_balls_min)
		breather.reagents.add_reagent(/datum/reagent/bz_metabolites, clamp(bz_pp, 1, 5))
	if(bz_pp > BZ_brain_damage_min && prob(33))
		breather.adjust_organ_loss(INTERNAL_ORGAN_BRAIN, 3, 150)

/// Breathing in refridgerator coolent, shit's caustic
/obj/item/organ/internal/lungs/proc/too_much_freon(mob/living/carbon/breather, datum/gas_mixture/breath, freon_pp)
	// Inhale Freon. Exhale nothing.
	breath.set_freon(0)
	if(freon_pp > gas_stimulation_min)
		breather.reagents.add_reagent(/datum/reagent/freon, 1)
	if(prob(freon_pp))
		to_chat(breather, span_alert("Your mouth feels like it's burning!"))
	if(freon_pp > 40)
		breather.emote("gasp")
		breather.adjustFireLoss(15)
		if(prob(freon_pp / 2))
			to_chat(breather, span_alert("Your throat closes up!"))
			breather.AdjustSilence(6 SECONDS, bound_upper = 6 SECONDS)
	else
		breather.adjustFireLoss(freon_pp / 4)

/// Breathing in halon, convert it to a reagent
/obj/item/organ/internal/lungs/proc/too_much_halon(mob/living/carbon/breather, datum/gas_mixture/breath, halon_pp)
	// Inhale Halon. Exhale nothing.
	breath.set_halon(0)
	// Metabolize to reagent.
	if(halon_pp > gas_stimulation_min)
		breather.adjustOxyLoss(5)
		breather.reagents.add_reagent(/datum/reagent/halon, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/halon)))

/// Sleeping gas with healing properties.
/obj/item/organ/internal/lungs/proc/consume_healium(mob/living/carbon/breather, datum/gas_mixture/breath, healium_pp)
	breath.set_healium(0)
	// Euphoria side-effect.
	if(healium_pp > gas_stimulation_min)
		if(prob(15))
			to_chat(breather, span_alert("Your head starts spinning and your lungs burn!"))
			breather.emote("gasp")
	// Stun/Sleep side-effects.
	if(healium_pp > healium_para_min && !breather.IsSleeping() && prob(30))
		breather.Sleeping(rand(3 SECONDS, 5 SECONDS))
	// Metabolize to reagent when concentration is high enough.
	if(healium_pp > healium_sleep_min)
		breather.reagents.add_reagent(/datum/reagent/healium, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/healium)))

/// Activates helium speech when partial pressure gets high enough
/obj/item/organ/internal/lungs/proc/consume_helium(mob/living/carbon/breather, datum/gas_mixture/breath, helium_pp)
	breath.set_helium(0)
	if(helium_pp > helium_speech_min)
		RegisterSignal(breather, COMSIG_MOB_SAY, PROC_REF(handle_helium_speech), override = TRUE)
	else
		UnregisterSignal(breather, COMSIG_MOB_SAY)

/// Lose helium high pitched voice
/obj/item/organ/internal/lungs/proc/lose_helium(mob/living/carbon/breather, datum/gas_mixture/breath)
	UnregisterSignal(breather, COMSIG_MOB_SAY)

/// React to speach while hopped up on the high pitched voice juice
/obj/item/organ/internal/lungs/proc/handle_helium_speech(mob/living/carbon/breather, message, verb = "говор[PLUR_IT_YAT(src)]", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	SIGNAL_HANDLER
	return COMPONENT_SMALL_SPEECH

/// Gain hypernob effects if we have enough of the stuff
/obj/item/organ/internal/lungs/proc/consume_hypernoblium(mob/living/carbon/breather, datum/gas_mixture/breath, hypernob_pp)
	breath.set_hypernoblium(0)
	if(hypernob_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/hypernoblium)
		breather.reagents.add_reagent(/datum/reagent/hypernoblium, max(0, 1 - existing))

/// Breathing in the stink gas
/obj/item/organ/internal/lungs/proc/too_much_miasma(mob/living/carbon/breather, datum/gas_mixture/breath, miasma_pp)
	// Inhale Miasma. Exhale nothing.
	breath.set_miasma(0)
	// Miasma side effects
	switch(miasma_pp)
		if(0.25 to 5)
			// At lower pp, give out a little warning
			if(prob(5))
				to_chat(breather, span_notice("There is an unpleasant smell in the air."))
		if(5 to 15)
			//At somewhat higher pp, warning becomes more obvious
			if(prob(15))
				to_chat(breather, span_warning("You smell something horribly decayed inside this room."))
		if(15 to 30)
			//Small chance to vomit. By now, people have internals on anyway
			if(prob(5))
				to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
				breather.vomit()
		if(30 to INFINITY)
			//Higher chance to vomit. Let the horror start
			if(prob(15))
				to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
				breather.vomit()

	// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
	// Then again, this is a purely hypothetical scenario and hardly reachable
	breather.AdjustDisgust(0.1 * miasma_pp)


// Breathe in nitrium. It's helpful, but has nasty side effects
/obj/item/organ/internal/lungs/proc/too_much_nitrium(mob/living/carbon/breather, datum/gas_mixture/breath, nitrium_pp)
	breath.set_nitrium(0)
	if(prob(20))
		breather.emote("burp")

	// Random chance to inflict side effects increases with pressure.
	if((prob(nitrium_pp) && (nitrium_pp > 15)))
		// Nitrium side-effect.

		breather.adjust_organ_loss(INTERNAL_ORGAN_BRAIN, nitrium_pp * 0.1)
		to_chat(breather, span_notice("You feel a burning sensation in your chest"))
	// Metabolize to reagents.
	if(nitrium_pp > 5)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_low_metabolization)
		breather.reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, max(0, 2 - existing))
	if(nitrium_pp > 10)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_high_metabolization)
		breather.reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, max(0, 2 - existing))

/// Radioactive, green gas. Toxin damage, and a radiation chance
/obj/item/organ/internal/lungs/proc/too_much_tritium(mob/living/carbon/breather, datum/gas_mixture/breath, trit_pp)
	var/gas_breathed = breath.tritium()
	breath.set_tritium(0)
	var/moles_visible = MOLES_GAS_VISIBLE
	// Tritium side-effects.
	if(gas_breathed > moles_visible)
		var/ratio = gas_breathed * 15
		breather.adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
	// If you're breathing in half an atmosphere of radioactive gas, you fucked up.
	if((trit_pp > tritium_irradiation_moles_min) && SSradiation.can_irradiate_basic(breather))
		var/lerp_scale = min(tritium_irradiation_moles_max, trit_pp - tritium_irradiation_moles_min) / (tritium_irradiation_moles_max - tritium_irradiation_moles_min)
		var/chance = LERP(tritium_irradiation_probability_min, tritium_irradiation_probability_max, lerp_scale)
		if(prob(chance))
			breather.AddComponent(/datum/component/irradiated)

/// Really toxic stuff, very much trying to kill you
/obj/item/organ/internal/lungs/proc/too_much_zauker(mob/living/carbon/breather, datum/gas_mixture/breath, zauker_pp)
	breath.set_zauker(0)
	// Metabolize to reagent.
	if(zauker_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/zauker)
		breather.reagents.add_reagent(/datum/reagent/zauker, max(0, 1 - existing))

/obj/item/organ/internal/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)

/obj/item/organ/internal/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature()

	if(!HAS_TRAIT(H, TRAIT_RESIST_COLD)) // COLD DAMAGE
		var/CM = abs(H.dna.species.coldmod * H.physiology.cold_mod)
		var/TC = 0
		if(breath_temperature < cold_level_3_threshold)
			TC = cold_level_3_damage
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			TC = cold_level_2_damage
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			TC = cold_level_1_damage
		if(TC)
			for(var/D in cold_damage_types)
				H.apply_damage(TC * CM * cold_damage_types[D], D, spread_damage = TRUE, forced = TRUE)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("Вы чувствуете[cold_message]!"))

	if(!HAS_TRAIT(H, TRAIT_RESIST_HEAT)) // HEAT DAMAGE
		var/HM = abs(H.dna.species.heatmod * H.physiology.heat_mod)
		var/TH = 0
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			TH = heat_level_1_damage
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			TH = heat_level_2_damage
		if(breath_temperature > heat_level_3_threshold)
			TH = heat_level_3_damage
		if(TH)
			for(var/D in heat_damage_types)
				H.apply_damage(TH * HM * heat_damage_types[D], D, spread_damage = TRUE, forced = TRUE)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("Вы чувствуете, что ваши дыхательные пути пылают!"))

/obj/item/organ/internal/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("salbutamol", 5)
	return S

/obj/item/organ/internal/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "Электронное устройство, имитирующее работу органических лёгких. Функционально не имеет никаких отличий от органического аналога, кроме производственных затрат."
	icon_state = "lungs-c"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	var/species_state = "человек"
	pickup_sound = 'sound/items/handling/pickup/component_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/component_drop.ogg'

/obj/item/organ/internal/lungs/cybernetic/get_ru_names()
	return list(
		NOMINATIVE = "кибернетические лёгкие",
		GENITIVE = "кибернетических лёгких",
		DATIVE = "кибернетическим лёгким",
		ACCUSATIVE = "кибернетические лёгкие",
		INSTRUMENTAL = "кибернетическими лёгкими",
		PREPOSITIONAL = "кибернетических лёгких",
	)

/obj/item/organ/internal/lungs/cybernetic/examine(mob/user)
	. = ..()
	. += span_notice("Конфигурация параметров дыхания: [species_state].")

/obj/item/organ/internal/lungs/cybernetic/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(species_state)
		if("человек") // from human to vox
			safe_oxygen_min = 0
			safe_oxygen_max = safe_toxins_max
			safe_nitro_min = 16
			oxy_damage_type = TOX
			to_chat(user, span_notice("Вы меняете конфигурацию [declent_ru(GENITIVE)]. Выбранный режим - \"вокс\"."))
			species_state = "вокс"
		if("вокс") // from vox to plasmamen
			safe_oxygen_max = initial(safe_oxygen_max)
			safe_toxins_min = 16
			safe_toxins_max = 0
			safe_nitro_min = initial(safe_nitro_min)
			oxy_damage_type = OXY
			to_chat(user, span_notice("Вы меняете конфигурацию [declent_ru(GENITIVE)]. Выбранный режим - \"плазмолюд\"."))
			species_state = "плазмолюд"
		if("плазмолюд") // from plasmamen to human
			safe_oxygen_min = initial(safe_oxygen_min)
			safe_toxins_min = initial(safe_toxins_min)
			safe_toxins_max = initial(safe_toxins_max)
			to_chat(user, span_notice("Вы меняете конфигурацию [declent_ru(GENITIVE)]. Выбранный режим - \"человек\"."))
			species_state = "человек"

/obj/item/organ/internal/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "Продвинутая версия кибернетических лёгких. Оснащены системой фильтрации, удаляющей токсины и углекислый газ из поступаемого воздуха. Очень уязвимы к ЭМИ."
	icon_state = "lungs-c-u"
	origin_tech = "biotech=5"

	safe_toxins_max = 20
	safe_co2_max = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/internal/lungs/cybernetic/upgraded/get_ru_names()
	return list(
		NOMINATIVE = "улучшенные кибернетические лёгкие",
		GENITIVE = "улучшенных кибернетических лёгких",
		DATIVE = "улучшенным кибернетическим лёгким",
		ACCUSATIVE = "улучшенные кибернетические лёгкие",
		INSTRUMENTAL = "улучшенными кибернетическими лёгкими",
		PREPOSITIONAL = "улучшенных кибернетических лёгких",
	)

/obj/item/organ/internal/lungs/cybernetic/upgraded/insert(mob/living/carbon/human/target, special)
	. = ..()

	if(HAS_TRAIT(target, TRAIT_ADVANCED_CYBERIMPLANTS))
		target.physiology.oxy_mod -= 0.5
		ADD_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

/obj/item/organ/internal/lungs/cybernetic/upgraded/remove(mob/living/carbon/human/target, special)
	if(HAS_TRAIT_FROM(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src)))
		target.physiology.oxy_mod += 0.5
		REMOVE_TRAIT(target, TRAIT_CYBERIMP_IMPROVED, UNIQUE_TRAIT_SOURCE(src))

	. = ..()
