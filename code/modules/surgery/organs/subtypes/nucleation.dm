//NUCLEATION ORGAN
/obj/item/organ/internal/nucleation
	species_type = /datum/species/nucleation
	name = "nucleation organ"
	icon = 'icons/obj/surgery.dmi'
	desc = "A crystalized human organ. <span class='danger'>It has a strangely iridescent glow.</span>"


/obj/item/organ/internal/nucleation/resonant_crystal
	name = "resonant crystal"
	icon_state = "resonant-crystal"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_RESONANT_CRYSTAL


/obj/item/organ/internal/nucleation/strange_crystal
	name = "strange crystal"
	icon_state = "strange-crystal"
	parent_organ_zone = BODY_ZONE_CHEST
	slot = INTERNAL_ORGAN_STRANGE_CRYSTAL


/obj/item/organ/internal/eyes/luminescent_crystal
	species_type = /datum/species/nucleation
	name = "luminescent eyes"
	icon_state = "crystal-eyes"
	light_color = "#1C1C00"


/obj/item/organ/internal/eyes/luminescent_crystal/New()
	set_light(2)
	..()


/obj/item/organ/internal/brain/crystal
	species_type = /datum/species/nucleation
	name = "crystallized brain"
	icon_state = "crystal-brain"

/obj/item/organ/internal/brain/crystal/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)
	..(target, special)
	var/datum/disease/virus/nuclefication/D = new()
	target.diseases += D
	var/datum/species/mob = target.dna.species
	mob.species_traits |= NO_SCAN
	D.affected_mob = target
	D.affected_mob.med_hud_set_status()



