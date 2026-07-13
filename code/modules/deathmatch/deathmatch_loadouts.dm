/datum/outfit/deathmatch_loadout //remember that fun > balance
	name = ""
	shoes = /obj/item/clothing/shoes/color/black // im not doing this on all of them
	/// Name shown in the UI
	var/display_name = ""
	/// Description shown in the UI
	var/desc = ":KILL:"
	/// If defined, using this outfit sets the targets species to it
	var/datum/species/species_override
	/// This outfit will grant these spells if applied
	var/list/spells_to_add = list()
	/// This outfit will grant these mutations if applied
	var/list/mutations_to_add = list()


/datum/outfit/deathmatch_loadout/naked
	name = "Deathmatch: Naked"
	display_name = "Без одежды"
	desc = "Голые космонавтики жаждут устроить кровавую баню."
	shoes = null
