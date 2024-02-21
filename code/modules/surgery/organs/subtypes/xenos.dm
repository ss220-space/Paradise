/obj/item/organ/internal/xenos
	origin_tech = "biotech=5"
	icon_state = "xgibmid2"
	tough = TRUE
	sterile = TRUE
	/// List of all powers carbon will get from inserted organ.
	var/list/alien_powers


/**
 * This adds and removes alien spells upon addition, if a noncarbon tries to do this well... I blame adminbus
 */
/obj/item/organ/internal/xenos/insert(mob/living/carbon/user, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	if(length(alien_powers))
		for(var/power_to_add in alien_powers)
			user.AddSpell(new power_to_add)


/obj/item/organ/internal/xenos/remove(mob/living/carbon/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(length(alien_powers))
		for(var/power_to_remove in alien_powers)
			var/actual_spell = locate(power_to_remove) in user.mob_spell_list
			user.RemoveSpell(actual_spell)
	. = ..()


/obj/item/organ/internal/xenos/prepare_eat()
	var/obj/object = ..()
	object.reagents.add_reagent("sacid", 10)
	return object


//XENOMORPH ORGANS

/obj/item/organ/internal/xenos/plasmavessel
	name = "xeno plasma vessel"
	icon_state = "plasma"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=5;plasmatech=4"
	parent_organ_zone = BODY_ZONE_CHEST
	slot = INTERNAL_ORGAN_PLASMAVESSEL
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/plant_weeds, /obj/effect/proc_holder/spell/touch/alien_spell/transfer_plasma)
	/// Used as a marker for hud updates on Life(). Ridiculous initial value required to update hud on organ insertion.
	var/old_plasma_amount = 9999
	/// Current amount of plasma.
	var/stored_plasma = 0
	/// Maximum vessel capacity.
	var/max_plasma = 500
	/// Gained heal amount per Life() cycle, while on weeds.
	var/heal_rate = 7.5
	/// Gained passive heal amount per Life() cycle.
	var/passive_heal_rate = 1
	/// Gained plasma amount per Life() cycle.
	var/plasma_rate = 10


/obj/item/organ/internal/xenos/plasmavessel/queen
	name = "bloated xeno plasma vessel"
	icon_state = "plasma_large"
	origin_tech = "biotech=6;plasmatech=4"
	max_plasma = 750
	stored_plasma = 300
	plasma_rate = 30
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/plant_weeds/queen, /obj/effect/proc_holder/spell/touch/alien_spell/transfer_plasma)


/obj/item/organ/internal/xenos/plasmavessel/praetorian
	name = "huge xeno plasma vessel"
	icon_state = "plasma_large"
	max_plasma = 750
	stored_plasma = 100
	plasma_rate = 15


/obj/item/organ/internal/xenos/plasmavessel/drone
	name = "large xeno plasma vessel"
	icon_state = "plasma_large"
	max_plasma = 300
	stored_plasma = 200
	plasma_rate = 25


/obj/item/organ/internal/xenos/plasmavessel/sentinel
	name = "medium xeno plasma vessel"
	max_plasma = 200
	stored_plasma = 100
	plasma_rate = 25


/obj/item/organ/internal/xenos/plasmavessel/hunter
	name = "small xeno plasma vessel"
	icon_state = "plasma_tiny"
	max_plasma = 150
	stored_plasma = 100
	plasma_rate = 10


/obj/item/organ/internal/xenos/plasmavessel/larva
	name = "tiny xeno plasma vessel"
	icon_state = "plasma_tiny"
	max_plasma = 100
	alien_powers = list()



/obj/item/organ/internal/xenos/plasmavessel/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("plasma", stored_plasma/10)
	return S


/obj/item/organ/internal/xenos/plasmavessel/on_life()
	if(!owner)
		return
	if(owner.on_fire)
		return

	update_hud()

	var/heal_amt = passive_heal_rate
	var/plasma_amt = 0
	if(locate(/obj/structure/alien/weeds) in owner.loc)
		if(owner.health >= owner.maxHealth)
			plasma_amt = plasma_rate
		else
			heal_amt += heal_rate
			plasma_amt = plasma_rate/2
	else
		if(stored_plasma < 50)
			plasma_amt = plasma_rate/10

	if(!isalien(owner))
		heal_amt *= 0.2

	owner.adjust_alien_plasma(plasma_amt)
	owner.adjustBruteLoss(-heal_amt)
	owner.adjustFireLoss(-heal_amt)
	owner.adjustOxyLoss(-heal_amt)
	owner.adjustCloneLoss(-heal_amt)
	update_hud()


/obj/item/organ/internal/xenos/plasmavessel/proc/update_hud()
	if(old_plasma_amount != stored_plasma)
		old_plasma_amount = stored_plasma
		owner.update_plasma_display(owner)


/obj/item/organ/internal/xenos/acidgland
	name = "xeno acid gland"
	icon_state = "acid"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_ACIDGLAND
	origin_tech = "biotech=5;materials=2;combat=2"
	alien_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid)


/obj/item/organ/internal/xenos/acidgland/sentinel
	name = "medium xeno acid gland"
	alien_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/sentinel)


/obj/item/organ/internal/xenos/acidgland/praetorian
	name = "massive xeno acid gland"
	alien_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/praetorian)


/obj/item/organ/internal/xenos/acidgland/queen
	name = "royal xeno acid gland"
	alien_powers = list(/obj/effect/proc_holder/spell/touch/alien_spell/corrosive_acid/queen)


/obj/item/organ/internal/xenos/hivenode
	name = "xeno hive node"
	icon_state = "hivenode"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HIVENODE
	origin_tech = "biotech=5;magnets=4;bluespace=3"
	w_class = WEIGHT_CLASS_TINY
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/whisper)


/obj/item/organ/internal/xenos/hivenode/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M.faction |= "alien"
	M.add_language(LANGUAGE_XENOS)
	M.add_language(LANGUAGE_HIVE_XENOS)


/obj/item/organ/internal/xenos/hivenode/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.faction -= "alien"
	M.remove_language(LANGUAGE_XENOS)
	M.remove_language(LANGUAGE_HIVE_XENOS)
	. = ..()


/obj/item/organ/internal/xenos/neurotoxin
	name = "large xeno neurotoxin gland"
	icon_state = "neurotox"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_NEUROTOXIN_GLAND
	origin_tech = "biotech=5;combat=5"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/neurotoxin)

/obj/item/organ/internal/xenos/neurotoxin/sentinel
	name = "medium xeno neurotoxin gland"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/neurotoxin/sentinel)

/obj/item/organ/internal/xenos/resinspinner
	name = "xeno resin organ"//...there tiger....
	icon_state = "liver-x"
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	slot = INTERNAL_ORGAN_RESIN_SPINNER
	origin_tech = "biotech=5;materials=4"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/build_resin)


/obj/item/organ/internal/xenos/eggsac
	name = "xeno egg sac"
	icon_state = "eggsac"
	parent_organ_zone = BODY_ZONE_PRECISE_GROIN
	slot = INTERNAL_ORGAN_EGGSAC
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=6"
	alien_powers = list(/obj/effect/proc_holder/spell/alien_spell/plant_weeds/eggs)

