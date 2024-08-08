
//	var/turf/T | This was made 14th September 2013, and has no use at all. Its being removed

/obj/item/grenade/fauna_bomb
	name = "fauna bomb"
	desc = "Эксперементальная, многоразовая граната, создающая фауну агрессивную ко всем, кроме активировавшего гранату."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "banana"
	item_state = "flashbang"
	var/deliveryamt = 8
	var/amount = 3
	var/list/mobs = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/marrowweaver)
	var/last_use = 0
	var/cooldown = 600

/obj/item/grenade/fauna_bomb/attack_self(mob/user)
	if (last_use + cooldown < world.time)
		to_chat(user, "<span class='warning'>[src] is still recharging!</span>")
		return
	last_use = world.time
	return ..()

/obj/item/grenade/fauna_bomb/prime(mob/user)
	var/turf/T = get_turf(src)
	playsound(T, 'sound/items/rawr.ogg', 100, TRUE)
	var/faction = user.name + "_fauna_bomb"
	user.faction |= faction

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/S = pick(mobs)
		S = new S(get_turf(src))
		S.faction |= faction
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(S, pick(NORTH, SOUTH, EAST, WEST))

	if(prob(40))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

/datum/crafting_recipe/tuned_anomalous_teleporter
	name = "Tuned anomalous teleporter"
	result = /obj/item/tuned_anomalous_teleporter
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/relict_priduction/pet_spray = 1,
				/obj/item/assembly/signaler/anomaly/pyro = 1,
				/obj/item/grenade/chem_grenade/adv_release = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
