// Atom x_act() procs signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
///from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///from base of atom/bullet_act(): (/obj/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
	/// if returned, forces nothing to happen when the atom is attacked by a blob
	#define COMPONENT_CANCEL_BLOB_ACT (1<<0)
///from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
///from base of atom/emag_act(): (/mob/user)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
///from base of atom/narsie_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
///from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
///from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM (1<<0)
/// from base of atom/on_teleported(): ()
#define COMSIG_ATOM_TELEPORT_ACT "atom_teleport_act"

/// Sent from [atom/proc/item_interaction], when this atom is left-clicked on by a mob with an item
/// Sent from the very beginning of the click chain, intended for generic atom-item interactions
/// Args: (mob/living/user, obj/item/tool, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_ITEM_INTERACTION "atom_item_interaction"
/// Sent from [atom/proc/item_interaction], when this atom is right-clicked on by a mob with an item
/// Sent from the very beginning of the click chain, intended for generic atom-item interactions
/// Args: (mob/living/user, obj/item/tool, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_ITEM_INTERACTION_SECONDARY "atom_item_interaction_secondary"
/// Sent from [atom/proc/item_interaction], to a mob clicking on an atom with an item
#define COMSIG_USER_ITEM_INTERACTION "user_item_interaction"
/// Sent from [atom/proc/item_interaction], to an item clicking on an atom
/// Args: (mob/living/user, atom/interacting_with, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ITEM_INTERACTING_WITH_ATOM "item_interacting_with_atom"
/// Sent from [atom/proc/item_interaction], to an item right-clicking on an atom
/// Args: (mob/living/user, atom/interacting_with, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY "item_interacting_with_atom_secondary"
/// Sent from [atom/proc/item_interaction], when this atom is right-clicked on by a mob with a tool
#define COMSIG_USER_ITEM_INTERACTION_SECONDARY "user_item_interaction_secondary"
///from base of atom/proc/tool_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
/// Sent from [atom/proc/item_interaction], when this atom is right-clicked on by a mob with a tool of a specific tool type
/// Args: (mob/living/user, obj/item/tool)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_SECONDARY_TOOL_ACT(tooltype) "tool_secondary_act_[tooltype]"
// Successful actions against an atom.
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"

/// Sent from [atom/proc/ranged_item_interaction], when this atom is left-clicked on by a mob with an item while not adjacent
#define COMSIG_ATOM_RANGED_ITEM_INTERACTION "atom_ranged_item_interaction"
/// Sent from [atom/proc/ranged_item_interaction], when this atom is right-clicked on by a mob with an item while not adjacent
#define COMSIG_ATOM_RANGED_ITEM_INTERACTION_SECONDARY "atom_ranged_item_interaction_secondary"
/// Sent from [atom/proc/ranged_item_interaction], when a mob is using this item while left-clicking on by an atom while not adjacent
#define COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM "ranged_item_interacting_with_atom"
/// Sent from [atom/proc/ranged_item_interaction], when a mob is using this item while right-clicking on by an atom while not adjacent
#define COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM_SECONDARY "ranged_item_interacting_with_atom_secondary"

/// Sent from [atom/proc/item_interaction], when this atom is used as a tool and an event occurs
#define COMSIG_ITEM_TOOL_ACTED "tool_item_acted"
///from base of atom/screwdriver_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"
///from base of atom/wrench_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WRENCH_ACT "atom_wrench_act"
///from base of atom/multitool_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_MULTITOOL_ACT "atom_multitool_act"
///from base of atom/welder_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WELDER_ACT "atom_welder_act"
///from base of atom/wirecutter_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_WIRECUTTER_ACT "atom_wirecutter_act"
///from base of atom/crowbar_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_CROWBAR_ACT "atom_crowbar_act"
///from base of atom/analyser_act(): (mob/living/user, obj/item/I)
#define COMSIG_ATOM_ANALYSER_ACT "atom_analyser_act"
/// Called when an atom is sharpened or dulled.
#define COMSIG_ATOM_UPDATE_SHARPNESS "atom_update_sharpness"
