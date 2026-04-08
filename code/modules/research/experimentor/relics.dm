/obj/item/relict_production
	name = "perfect mix"
	desc = "Странный объект без эффекта и иконки. Щитспавн онли."
	icon_state = ""
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "bluespace=3;materials=3"
	var/cooldown = 5 SECONDS
	COOLDOWN_DECLARE(relict_production_cooldown)

/obj/item/relict_production/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, relict_production_cooldown))
		to_chat(user, span_notice("[src] is not ready yet."))
		return FALSE
	COOLDOWN_START(src, relict_production_cooldown, cooldown)
	return TRUE

/obj/item/relict_production/perfect_mix
	desc = "Странный объект из которого можно бесконечно заполнять емкости какой-то жидкостью."
	icon_state = "beaker"
	item_state = "beaker"
	icon = 'icons/obj/weapons/techrelic.dmi'
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	origin_tech = "materials=4;bluespace=3"
	var/datum/reagent/inner_reagent
	var/transfer = 10

/obj/item/relict_production/perfect_mix/Initialize(mapload)
	. = ..()
	inner_reagent = pick(/datum/reagent/uranium, /datum/reagent/plasma, /datum/reagent/consumable/capsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/space_cleaner, /datum/reagent/consumable/drink/coffee, pick(/datum/reagent/consumable/drink/non_alcoholic_beer, /datum/reagent/consumable/ethanol/beer))

/obj/item/relict_production/perfect_mix/afterattack(atom/target, mob/user, proximity)
	if(isglassreagentcontainer(target))
		var/obj/item/reagent_containers/glass/beaker = target
		beaker.reagents.add_reagent(inner_reagent.id, transfer)
		to_chat(user, span_notice("You have poured 10 units of content into this."))
	else
		to_chat(user, span_notice("You can't pour [src]'s content into this."))

/obj/item/relict_production/strange_teleporter
	name = "strange teleporter"
	desc = "Странный объект телепортирующий вас при активации."
	icon_state = "prox-multitool2"
	origin_tech = "materials=4;bluespace=4"
	cooldown = 10 SECONDS

/obj/item/relict_production/strange_teleporter/attack_self(mob/user)
	if(!..())
		return
	to_chat(user, span_notice("[src] begins to vibrate!"))
	addtimer(CALLBACK(src, PROC_REF(teleport), user), rand(1 SECONDS, 3 SECONDS))

/obj/item/relict_production/strange_teleporter/proc/teleport(mob/user)
	var/turf/userturf = get_turf(user)

	if(loc != user || !is_teleport_allowed(userturf.z))
		return

	visible_message(span_notice("The [src] twists and bends, relocating itself!"))
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 5, location = get_turf(user))
	smoke.start()
	do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')
	smoke = new
	smoke.set_up(amount = 5, location = get_turf(user))
	smoke.start()

/obj/item/relict_production/pet_spray
	name = "pet spray"
	desc = "Странный объект создающий враждебных существ."
	icon_state = "armor-igniter-analyzer"
	origin_tech = "biotech=5"
	cooldown = 60 SECONDS

/obj/item/relict_production/pet_spray/attack_self(mob/user)
	if(!..())
		return
	var/message = span_danger("[src] begins to shake, and in the distance the sound of rampaging animals arises!")
	visible_message(message)
	to_chat(user, message)
	var/amount = rand(1, 3)
	var/list/possible_mobs = list(
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/pet/dog/corgi
	)
	var/mob/to_spawn = pick(possible_mobs)

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/animal
		animal = new to_spawn(get_turf(src))
		animal.faction |= "petSpraySummon"
		animal.gold_core_spawnable = HOSTILE_SPAWN
		animal.low_priority_targets += user.UID()
		if(prob(50))
			continue
		for(var/j in 1 to rand(1, 3))
			step(animal, pick(NORTH, SOUTH, EAST, WEST))

	if(!prob(60))
		return

	to_chat(user, span_warning("[src] falls apart!"))
	qdel(src)

/obj/item/relict_production/rapid_dupe
	name = "rapid dupe"
	desc = "Странный объект создающий другие странные объекты при контакте с аномалиями."
	icon_state = "shock_kit"
	origin_tech = "materials=5"

//////////////////////////////////SPECIAL ITEMS////////////////////////////////////////

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon_state = "shock_kit"
	icon = 'icons/obj/assemblies.dmi'
	origin_tech = "combat=1;plasmatech=1;powerstorage=1;materials=1"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc

/obj/item/relic/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	icon_state = pick("shock_kit", "armor-igniter-analyzer", "infra-igniter0","infra-igniter1", "radio-multitool", "prox-radio1", "radio-radio", "timer-multitool0", "radio-igniter-tank")
	realName = "[pick("broken", "twisted", "spun", "improved", "silly", "regular", "badly made")] [pick("device", "object", "toy", "suspicious tech", "gear")]"

