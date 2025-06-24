//Stores several modifiers in a way that isn't cleared by changing species
/datum/physiology
	/// Multiplier to brute damage received.
	/// IE: A brute mod of 0.9 = 10% less brute damage.
	var/brute_mod = 1
	/// Multiplier to burn damage received
	var/burn_mod = 1
	/// Multiplier to toxin damage received
	var/tox_mod = 1
	/// Multiplier to oxygen damage received
	var/oxy_mod = 1
	/// Multiplier to clone (genetif) damage received
	var/clone_mod = 1
	/// Multiplier to stamina damage received
	var/stamina_mod = 1
	/// Multiplier to brain damage received
	var/brain_mod = 1

	/// Multiplier to damage taken from high / low pressure exposure, stacking with the brute modifier
	var/pressure_mod = 1
	/// Multiplier to damage taken from high temperature exposure, stacking with the burn modifier
	var/heat_mod = 1
	/// Multiplier to damage taken from low temperature exposure, stacking with the toxin modifier
	var/cold_mod = 1

	/// Flat damage reduction from taking damage
	/// Unlike the other modifiers, this is not a multiplier.
	/// IE: DR of 10 = 10% less damage.
	var/damage_resistance = 0

	/// Resistance to shocks
	var/siemens_coeff = 1
	/// How quickly germs are growing
	var/germs_growth_mod = 1

	/// Multiplier applied to all incapacitating effects (knockdown, stun, weaken, immobilized)
	var/stun_mod = 1
	/// Multiplied aplpied to just knockdowns, stacks with above multiplicatively
	var/knockdown_mod = 1

	/// Bleeding rate modifier
	var/bleed_mod = 1
	/// Hunger drain rate modifier
	var/hunger_mod = 1
	/// Fractures chance reduction/amplification
	var/bone_fragility = 1

	/// Modifies victim's chance to resist our grab, lower = harder
	var/grab_resist_mod = 1

	// Punch mods
	/// Flat damage addition/reduction to lowest possible punch damage
	var/punch_damage_low = 0
	/// Multiplicative modifier to lowest possible punch damage
	var/punch_damage_low_mod = 1
	/// Flat damage addition/reduction to highest possible punch damage
	var/punch_damage_high = 0
	/// Multiplicative modifier to highest possible punch damage
	var/punch_damage_high_mod = 1
	/// Flat damage addition/reduction to punch stun threshold, damage at which punches from this mob will stun
	var/punch_stun_threshold = 0
	/// Flat damage addition/reduction for punching objects
	var/punch_obj_damage = 0

	/// Multiplicative modifier for tail manipulations
	var/tail_strength_mod = 1

	/// Internal armor datum
	var/datum/armor/armor

	/// Strength level. Changes some parameters, such as melee damage. 2 - the same as old.
	var/strength = -1 // Changes in on_species_gain()
	/// Points of strength that this body already has. They are used to change the strength level.
	var/strength_points = 0


/datum/physiology/New()
	armor = new


#define REQ_STAMINA_FOR_STRENGTH_POINT		25
#define REQ_NUTRITION_FOR_STRENGTH_POINT 	25
#define MIN_NUTRITION_FOR_STRENGTH_CHANGE	NUTRITION_LEVEL_STARVING

/datum/physiology/proc/try_add_strength_points(mob/living/carbon/human/user, delta)
	if(user.nutrition < MIN_NUTRITION_FOR_STRENGTH_CHANGE)
		to_chat(user, span_warning("Вы слишком голодны!"))
		return FALSE

	if(user.getStaminaLoss() + delta * REQ_STAMINA_FOR_STRENGTH_POINT > MAX_STAMINA_LOSS)
		to_chat(user, span_warning("Вы слишком устали!"))
		return FALSE

	if(!user.dna.species.can_become_stronger)
		return TRUE

	user.adjustStaminaLoss(delta * REQ_STAMINA_FOR_STRENGTH_POINT)
	user.adjust_nutrition(-delta * REQ_NUTRITION_FOR_STRENGTH_POINT)

	var/has_steroids = user.reagents.has_reagent(/datum/reagent/steroids::id)
	var/has_protein = user.reagents.has_reagent(/datum/reagent/consumable/nutriment/protein::id)
	if(has_steroids)
		delta *= 2
	else if(has_protein)
		delta *= 1.3

	strength_points += delta
	try_upgrade_strength(user)
	if(strength >= user.get_max_strength_level())
		strength_points = 0

	return TRUE


/datum/physiology/proc/try_upgrade_strength(mob/living/carbon/human/user)
	if(strength >= user.get_max_strength_level())
		return

	if(strength_points < GLOB.strength_req_to_upgrade[strength])
		return

	strength_points -= GLOB.strength_req_to_upgrade[strength]
	strength++
	user.update_body(TRUE)

#undef REQ_STAMINA_FOR_STRENGTH_POINT
#undef REQ_NUTRITION_FOR_STRENGTH_POINT
#undef MIN_NUTRITION_FOR_STRENGTH_CHANGE
