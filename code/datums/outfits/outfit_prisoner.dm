/datum/outfit/prisoner
	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/orange

/datum/outfit/prisoner/plasmamen
	uniform =/obj/item/clothing/under/plasmaman
	head = /obj/item/clothing/head/helmet/space/plasmaman
	belt = /obj/item/tank/internals/plasmaman/belt/full
	mask = /obj/item/clothing/mask/breath

/datum/outfit/prisoner/plasmamen/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/tank/internals/tank = H.belt
	tank.toggle_internals(H)

/datum/outfit/prisoner/vox
	mask = /obj/item/clothing/mask/breath/vox
	belt = /obj/item/tank/internals/emergency_oxygen/double/vox

/datum/outfit/prisoner/vox/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/tank/internals/tank = H.belt
	tank.toggle_internals(H)
