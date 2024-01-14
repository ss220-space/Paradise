/datum/component/slime_defender
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/mob/living/simple_animal/slime/slime

/datum/component/slime_defender/Initialize(new_slime)
	if(!isslime(new_slime))
		return COMPONENT_INCOMPATIBLE
	slime = new_slime

/datum/component/slime_defender/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(bullet_act))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attack_by))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(item_attack))
	RegisterSignal(parent, COMSIG_SIMPLE_ANIMAL_ATTACKEDBY, PROC_REF(attack_animal))
	RegisterSignal(parent, COMSIG_CARBON_HITBY, PROC_REF(hitby))


/datum/component/slime_defender/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ITEM_ATTACK,
		COMSIG_SIMPLE_ANIMAL_ATTACKEDBY,
		COMSIG_CARBON_HITBY))


/datum/component/slime_defender/proc/bullet_act(mob/target, obj/item/projectile/P, def_zone)
	revenge(P?.firer)

/datum/component/slime_defender/proc/attack_hand(mob/user)
	revenge(user)

/datum/component/slime_defender/proc/attack_by(mob/target, mob/user)
	revenge(user)

/datum/component/slime_defender/proc/item_attack(mob/target, mob/some_mob, mob/living/user)
	revenge(user)

/datum/component/slime_defender/proc/attack_animal(mob/target, mob/living/simple_animal/M)
	revenge(M)

/datum/component/slime_defender/proc/hitby(mob/target, atom/movable/AM, datum/thrownthing/throwingdatum)
	revenge(throwingdatum?.thrower)

/datum/component/slime_defender/proc/revenge(target)
	if(isliving(target) && target != parent)
		slime.set_new_target(target, SLIME_BEHAVIOR_ATTACK, slime.age_state.patience * 2)
