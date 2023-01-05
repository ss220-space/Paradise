/obj/machinery/brs_server/proc/give_reward()
	new /obj/item/paper/researchnotes_brs(src.loc)
	new /obj/structure/toilet/bluespace/brs(src.loc)

/obj/machinery/brs_server/proc/give_random_reward()



/obj/machinery/brs_server/proc/produce(key)
	if(key <= 0 || key > length(product_list))	//invalid key
		return
	var/datum/data/bluespace_tap_product/A = product_list[key]
	if(!A)
		return
	if(A.product_cost > points)
		return
	points -= A.product_cost
	A.product_cost = round(1.2 * A.product_cost, 1)
	playsound(src, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, src)
	new A.product_path(get_turf(src))


	var/static/product_list = list(
	new /datum/data/bluespace_tap_product("Unknown Exotic Hat", /obj/effect/spawner/lootdrop/bluespace_tap/hat, 5000),
	new /datum/data/bluespace_tap_product("Unknown Snack", /obj/effect/spawner/lootdrop/bluespace_tap/food, 6000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/cultural, 15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/organic, 20000)
	)



/obj/effect/spawner/lootdrop/bluespace_tap/food
	name = "fancy food"
	lootcount = 3
	loot = list(
		/obj/item/reagent_containers/food/snacks/wingfangchu,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/sliceable/turkey,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/appletart,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake,
		/obj/item/reagent_containers/food/snacks/sliceable/bananacake,
		/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake,
		/obj/item/reagent_containers/food/snacks/soup/meatballsoup,
		/obj/item/reagent_containers/food/snacks/soup/mysterysoup,
		/obj/item/reagent_containers/food/snacks/soup/stew,
		/obj/item/reagent_containers/food/snacks/soup/hotchili,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/fishburger,
		/obj/item/reagent_containers/food/snacks/cubancarp,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/meatpie,
		/obj/item/pizzabox/hawaiian, //it ONLY gives hawaiian. MUHAHAHA
		/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread //maybe add some dangerous/special food here, ie robobuger?
	)











//================ Объекты ================
/obj/item/paper/researchnotes_brs
	name = "Исследования Блюспейс Разлома"
	info = "<b>Долгожданные научные исследования блюспейс разлома, продвигающие науку изучения Синего Космоса далеко вперед. \nВ записке написана тарабарщина на машинном языке. \nТребуется деструктивный анализ.</b>"
	origin_tech = "bluespace=9;magnets=8"

//блюспейс толкан
/obj/structure/toilet/bluespace
	name = "Научный унитаз"
	desc = "Загадка современной науки о возникновении данного научного экземпляра."
	icon_state = "bluespace_toilet00"
	var/teleport_sound = 'sound/magic/lightning_chargeup.ogg'

/obj/structure/toilet/bluespace/brs
	name = "Воронка Бездны Синего Космоса"
	desc = "То, ради чего наука и была создана и первый гуманоид ударил палку о камень. Главное не смотреть в бездну."
	icon_state = "bluespace_toilet00-NT"

/obj/structure/toilet/bluespace/update_icon()
	. = ..()
	icon_state = "bluespace_toilet[open][cistern]"

/obj/structure/toilet/bluespace/brs/update_icon()
	. = ..()
	icon_state = "bluespace_toilet[open][cistern]-NT"

/obj/structure/toilet/bluespace/attack_hand(mob/living/user)
	. = ..()
	overlays.Cut()
	if(open)
		overlays += image(icon, "bluespace_toilet_singularity")

		if(do_after(user, 100, target = src))
			playsound(loc, teleport_sound, 100, 1)
			teleport(1)

/obj/structure/toilet/bluespace/proc/teleport(var/range_dist = 1)
	var/list/objects = range(range_dist, src)

	var/turf/simulated/floor/F = find_safe_turf(zlevels = src.z)
	for(var/mob/living/H in objects)
		do_teleport(H, F, range_dist * 3)
		investigate_log("teleported [key_name_log(H)] to [COORD(F)]", INVESTIGATE_TELEPORTATION)

	for(var/obj/O in objects)
		if (O.anchored)
			continue
		do_teleport(O, F, range_dist * 3)

	do_teleport(src, F)

/obj/structure/toilet/bluespace/Destroy()
	playsound(loc, teleport_sound, 100, 1)
	teleport(9)
	. = ..()

