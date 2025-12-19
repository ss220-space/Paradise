/obj/item/storage/backpack/ninja
	name = "High-tech backpack"
	desc = "Looks just like that one pack from da movie about ninjas and stuff!"
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "backpack_ninja_green"
	item_state = "backpack_ninja_green"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/storage/backpack/ninja/populate_contents()
	new /obj/item/storage/firstaid/crew/ninja(src)
	new /obj/item/tank/internals/emergency_oxygen/ninja(src)

/obj/item/storage/firstaid/crew/ninja

/obj/item/storage/firstaid/crew/ninja/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/charcoal(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/sanguinius(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/zagustin(src)
	new /obj/item/stack/medical/bruise_pack/military(src)
