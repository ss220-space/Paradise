
//	var/turf/T | This was made 14th September 2013, and has no use at all. Its being removed

/obj/item/grenade/fauna_bomb
	name = "fauna bomb"
	desc = "Эксперементальная, многоразовая граната, создающая фауну агрессивную ко всем, кроме активировавшего гранату."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "bomb"
	item_state = "bomb"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	var/deliveryamt = 8
	var/amount = 3
	var/last_use = 0
	var/cooldown = 600
	var/mob/activator

/obj/item/grenade/fauna_bomb/attack_self(mob/user)
	if (last_use + cooldown > world.time)
		to_chat(user, "<span class='warning'>[src] is still recharging!</span>")
		return

	last_use = world.time
	activator = user
	return ..(user, FALSE)

/obj/item/grenade/fauna_bomb/prime()
	active = FALSE
	var/turf/T = get_turf(src)
	playsound(T, 'sound/items/rawr.ogg', 100, TRUE)
	var/faction = activator.name + "_fauna_bomb"
	activator.faction |= faction
	var/list/mob/living/simple_animal/mobs = list()

	var/mob/living/simple_animal/S = pick(/mob/living/simple_animal/hostile/asteroid/hivelord/legion, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/marrowweaver)

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/S1 = new S(get_turf(src))
		mobs.Add(S1)
		S1.set_anchor(activator, 10)
		S1.faction |= faction
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(S, pick(NORTH, SOUTH, EAST, WEST))

	if(prob(40))
		to_chat(activator, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

	sleep(600)
	for (var/mob/M in mobs)
		M.dust()

/datum/crafting_recipe/fauna_bomb
	name = "Fauna bomb"
	result = /obj/item/grenade/fauna_bomb
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/relict_priduction/pet_spray = 1,
				/obj/item/assembly/signaler/anomaly/pyro = 1,
				/obj/item/grenade/chem_grenade/adv_release = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
