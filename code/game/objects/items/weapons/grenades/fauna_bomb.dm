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
	COOLDOWN_DECLARE(fauna_bomb_cooldown)
	var/mob/activator
	origin_tech = "bluespace=4;biotech=5"

/obj/item/grenade/fauna_bomb/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, fauna_bomb_cooldown))
		to_chat(user, span_warning("[src] is still recharging!"))
		return

	COOLDOWN_START(src, fauna_bomb_cooldown, 60 SECONDS)
	activator = user
	return ..(user, FALSE)

/obj/item/grenade/fauna_bomb/prime()
	active = FALSE
	playsound(get_turf(src), 'sound/items/rawr.ogg', 100, TRUE)
	var/faction = activator.name + "_fauna_bomb"
	activator.faction |= faction
	var/list/mob/living/simple_animal/mobs = list()

	var/mob/living/simple_animal/spawn_mob_type = pick(/mob/living/simple_animal/hostile/asteroid/hivelord/legion, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/marrowweaver)

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/new_mob = new spawn_mob_type(get_turf(src))
		mobs.Add(new_mob)
		new_mob.set_leash(activator, 10)
		new_mob.faction |= faction
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(new_mob, pick(NORTH, SOUTH, EAST, WEST))

	if(prob(40))
		to_chat(activator, span_warning("[src] falls apart!"))
		qdel(src)

	sleep(600)
	for (var/mob/mob in mobs)
		mob.dust()

/obj/item/grenade/fauna_bomb/update_icon_state()
	return

/datum/crafting_recipe/fauna_bomb
	name = "Fauna bomb"
	result = /obj/item/grenade/fauna_bomb
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/relict_production/pet_spray = 1,
				/obj/item/assembly/signaler/anomaly/pyro = 1,
				/obj/item/grenade/chem_grenade/adv_release = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
