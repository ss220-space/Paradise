/// Reagents
/// Source: /datum/reagents/proc/add_reagent (datum/reagents, reagent_id, amount, data, reagtemp, no_react, chem_temp)
#define COMSIG_EARLY_REAGENT_ADDED "reagent_early_added"
	#define COMPONENT_PREVENT_ADD_REAGENT (1<<0)
///from base of atom/expose_reagents(): (/list, /datum/reagents, chemholder, volume_modifier)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
