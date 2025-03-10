//This file contains xenoborg specic weapons.

/obj/item/melee/energy/alien_claws
	name = "energy claws"
	desc = "A set of alien energy claws."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-laser-claws"
	icon_state_on = "borg-laser-claws"
	force = 15
	force_on = 15
	throwforce = 5
	throwforce_on = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	w_class_on = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "полоснул", "пронзил", "поранил", "порезал")
	attack_verb_on = list()

//Bottles for borg liquid squirters. PSSH PSSH
/obj/item/reagent_containers/spray/alien
	name = "liquid synthesizer"
	desc = "squirts alien liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-default"

/obj/item/reagent_containers/spray/alien/smoke
	name = "smoke synthesizer"
	desc = "squirts smokey liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-smoke"

/obj/item/reagent_containers/spray/alien/smoke/afterattack(atom/A, mob/user, proximity, params)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(amount = 5, location = user.loc)
	smoke.start()
	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 2)
	user.changeNext_move(delay)

	var/mob/living/silicon/robot/Robot = user
	Robot.cell.use(250) // take energy from borg

/obj/item/reagent_containers/spray/alien/acid
	name = "acid synthesizer"
	desc = "squirts burny liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-acid"
	list_reagents = list("facid" = 125, "sacid" = 125)

/obj/item/reagent_containers/spray/alien/stun
	name = "paralytic toxin synthesizer"
	desc = "squirts viagra."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-stun"

/obj/item/reagent_containers/spray/alien/stun/afterattack(atom/A, mob/user, proximity, params)
	var/datum/reagents/reagents_list = new (250)
	reagents_list.add_reagent("blob_cryogenic_poison", 250) // new blow reagent because old was deleted
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	smoke.set_up(range = 3, location = user.loc, carry = reagents_list, silent = TRUE)
	playsound(user.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.start(TRUE)
	user.changeNext_move(delay)

	var/mob/living/silicon/robot/Robot = user
	Robot.cell.use(250) // take energy from borg


/obj/item/flash/cyborg/alien
	name = "eye flash"
	desc = "Useful for taking pictures, making friends and flash-frying chips."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-flash"
