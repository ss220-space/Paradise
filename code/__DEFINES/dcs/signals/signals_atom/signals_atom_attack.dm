// Atom attack signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
/// From base of [atom/proc/attacby_secondary()]: (/obj/item/weapon, /mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACKBY_SECONDARY "atom_attackby_secondary"
/// from /datum/component/cleave_attack/proc/hit_atoms_on_turf(): (atom/target, obj/item, mob/user)
#define COMSIG_ATOM_CLEAVE_ATTACK "atom_cleave_attack"
	// allows cleave attack to hit things it normally wouldn't
	#define ATOM_ALLOW_CLEAVE_ATTACK (1<<0)
/// from /datum/action/item_action/toggle_cleave_attack/Trigger
#define COMSIG_TOGGLE_CLEAVE_ATTACK "toggle_cleave_attack"
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
//from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
///from base of /obj/item//attack(): (/obj/item, /atom/source, params) sends singal on user who attacked source
#define COMSIG_ATOM_ATTACK "atom_attack"

// Attack signals. These should share the returned flags, to standardize the attack chain.
// The chain currently works like:
// tool_act -> pre_attackby -> target.attackby (item.attack) -> afterattack
// You can use these signal responses to cancel the attack chain at a certain point from most attack signal types.
	/// This response cancels the attack chain entirely. If sent early, it might cause some later effects to be skipped.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK (1<<1)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<2)
	///I dont know where and why it was used, but it was used in the same place with cancel chain and had the same value
	#define COMPONENT_NO_INTERACT (1<<3)

///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
	#define COMPONENT_NO_ATTACK_HAND (1<<0)								//works on all 3.

/// From base of [/atom/proc/attack_hand_secondary]: (mob/user, list/modifiers) - Called when the atom receives a secondary unarmed attack.
#define COMSIG_ATOM_ATTACK_HAND_SECONDARY "atom_attack_hand_secondary"

/// from base of atom/attack_robot(): (mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACK_ROBOT "atom_attack_robot"
/// from base of atom/attack_robot_secondary(): (mob/user)
#define COMSIG_ATOM_ATTACK_ROBOT_SECONDARY "atom_attack_robot_secondary"

