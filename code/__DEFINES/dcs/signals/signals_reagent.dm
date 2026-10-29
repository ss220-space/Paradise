/// Source: /datum/reagents/proc/add_reagent (datum/reagents, reagent_id, amount, data, reagtemp, no_react, chem_temp)
#define COMSIG_EARLY_REAGENT_ADDED "reagent_early_added"
	#define COMPONENT_PREVENT_ADD_REAGENT (1<<0)
///from base of atom/expose_reagents(): (/list, /datum/reagents, chemholder, volume_modifier)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"

/// sent when reagents are transfered from a cup, to something refillable (atom/transfer_to)
#define COMSIG_REAGENTS_CUP_TRANSFER_TO "reagents_cup_transfer_to"
/// sent when reagents are transfered from some reagent container, to a cup (atom/transfer_from)
#define COMSIG_REAGENTS_CUP_TRANSFER_FROM "reagents_cup_transfer_from"
