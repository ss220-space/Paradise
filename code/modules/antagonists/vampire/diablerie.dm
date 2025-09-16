/// Amount of total blood required for BOTH vampires to have for successful diablerie act
#define DIABLERIE_REQUIRED_BLOOD_TOTAL 150

#define DIABLERIE_COUNT_MAX 4
/// Cooldown duration reduction applied to all vampire spells on every level, max is 0.2, which is 20% CDR
#define DIABLERIE_COOLDOWN_REDUCTION 0.05
#define DIABLERIE_SUCKING_AMOUNT 5
#define DIABLERIE_LEVEL_ONE 1
#define DIABLERIE_LEVEL_TWO 2
#define DIABLERIE_LEVEL_THREE 3
#define DIABLERIE_LEVEL_FOUR 4
/**
 * "Diablerie" thing is entirely World of Darkness reference. In simple terms, 'diablerie' is the act of a vampire
 * killing another vampire by draining all of their blood, thereby taking their soul and becoming more powerful.
 * The word "diablerie" comes from French "diable" + "erie", which means something like "devilish practice"
 */
/datum/diablerie
	/// Reference to vampire antagonist datum, owner of this diablerie datum
	var/datum/antagonist/vampire/vampire_datum
	///
	var/mob/living/carbon/human/vampire
	/// Amount of times we performed diablerie on someone, limit is DIABLERIE_COUNT_MAX
	var/diablerie_count = 0
	var/static/list/diablerie_levels = (
		/datum/diablerie_level/level_one,
		/datum/diablerie_level/level_two,
		/datum/diablerie_level/level_three,
		/datum/diablerie_level/level_four,
	)
	var/vampire_see_invisible



/datum/diablerie/New(vampire_datum)
	src.vampire_datum = vampire_datum
	vampire = vampire_datum.owner.current
	vampire_see_invisible = vampire.see_invisible
	. = ..()


/datum/diablerie/Destroy(force)
	vampire_datum.diablerie = null
	vampire_datum = null
	vampire = null
	return ..()


/datum/diablerie/proc/increase_diablerie_level()
	if(diablerie_count >= DIABLERIE_COUNT_MAX)
		return

	diablerie_count++
	var/datum/diablerie_level/diablerie_level = diablerie_levels[diablerie_count]
	diablerie_level.gain()
	apply_additional_bonuses()


/datum/diablerie_level/proc/gain()


/// Upgrades glare charges to 3, CDR here is 5%, sucking 35 units of blood per cycle
/datum/diablerie_level/level_one/gain
	var/obj/effect/proc_holder/spell/vampire/rejuvenate/rejuvenate = locate() in vampire_datum.powers
	rejuvenate.cooldown_handler.change_cooldowns(new_max_charges = 2)
	ADD_TRAIT(vampire, TRAIT_NO_BREATH, VAMPIRE_TRAIT)


/datum/diablerie_level/level_two/gain
	var/obj/effect/proc_holder/spell/vampire/glare/glare = locate() in vampire_datum.powers
	glare.cooldown_handler.change_cooldowns(new_max_charges = 3)

/datum/diablerie_level/level_three/gain

/datum/diablerie_level/level_four/gain

if(forced_diablerie_level > DIABLERIE_COUNT_MAX)
	forced_diablerie_level = DIABLERIE_COUNT_MAX
while(diablerie_count < forced_diablerie_level)
	increase_diablerie_level() // make DEFINES for levels

/gain
/remove
/on_gain
/on_remove


/**
 * Every diablerie level increases amount of blood sucked from victim per cycle by [DIABLERIE_SUCKING_AMOUNT]
 * and applies [DIABLERIE_COOLDOWN_REDUCTION] bonus on every active spell vampire has
 */
/datum/diablerie_level/proc/apply_additional_bonuses()
	vampire_datum.sucking_amount += DIABLERIE_SUCKING_AMOUNT
	for(var/obj/effect/proc_holder/spell/power in vampire_datum.powers)
		power.cooldown_handler.change_cooldowns(recharge_duration =) // check this out later, maybe round it and store somewhere
		// to accumulate bonus for properly rounding DIABLERIE_COOLDOWN_REDUCTION * diablerie_count)


/datum/diablerie_level/proc/setup_diablerie_aura()
	var/mutable_appearance/diablerie_aura = new(vampire)
	diablerie_aura.icon = 'icons/effect/vampire_effects/diablerie_aura.dmi'
	diablerie_aura.invisibility = INVISIBILITY_VAMPIRE_AURA
	vampire.see_invisible = SEE_INVISIBLE_VAMPIRE_AURA
