/obj/item/grenade/fauna_bomb
	name = "fauna bomb"
	ru_names = list(NOMINATIVE = "фаунная бомба", \
					GENITIVE = "фаунной бомбы", \
					DATIVE = "фаунную бомбу", \
					ACCUSATIVE = "фаунную бомбу", \
					INSTRUMENTAL = "фаунной бомбой", \
					PREPOSITIONAL = "фаунной бомбе")
	desc = "Эксперементальная, многоразовая граната, создающая фауну агрессивную ко всем, кроме активировавшего гранату."
	gender = FEMALE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/techrelic.dmi'
	icon_state = "bomb"
	item_state = "bomb"
	lefthand_file = 'icons/mob/inhands/relics_production/inhandl.dmi'
	righthand_file = 'icons/mob/inhands/relics_production/inhandr.dmi'
	origin_tech = "bluespace=4;biotech=5"
	COOLDOWN_DECLARE(fauna_bomb_cooldown)
	/// Amount of monsters that will be spawned.
	var/amount = 3
	/// Mob, who activated this bomb.
	var/mob/last_user

/obj/item/grenade/fauna_bomb/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, fauna_bomb_cooldown))
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] все еще перезаряжается!"))
		return

	COOLDOWN_START(src, fauna_bomb_cooldown, 60 SECONDS)
	last_user = user
	return ..(user, FALSE)

/obj/item/grenade/fauna_bomb/prime()
	active = FALSE
	playsound(get_turf(src), 'sound/items/rawr.ogg', 100, TRUE)
	var/faction = last_user.name + "_fauna_bomb"
	last_user.faction |= faction
	var/list/mob/living/simple_animal/mobs = list()

	var/mob/living/simple_animal/spawn_mob_type = pick(/mob/living/simple_animal/hostile/asteroid/hivelord/legion, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/marrowweaver)

	for(var/i in 1 to amount)
		var/mob/living/simple_animal/new_mob = new spawn_mob_type(get_turf(src))
		mobs.Add(new_mob)
		new_mob.set_leash(last_user, 10)
		new_mob.faction |= faction
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(new_mob, pick(NORTH, SOUTH, EAST, WEST))

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
				/obj/item/assembly/signaler/core/tier2/atmospheric = 1,
				/obj/item/grenade/chem_grenade/adv_release = 1,
				/obj/item/stack/cable_coil = 5)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
