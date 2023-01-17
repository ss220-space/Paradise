/obj/machinery/brs_server/proc/give_reward(var/turf/temp_loc)
	new /obj/item/paper/researchnotes_brs(temp_loc)
	new /obj/structure/toilet/bluespace/brs(temp_loc)
	spawn_effect(temp_loc)

/obj/machinery/brs_server/proc/give_random_reward(var/turf/temp_loc)
	new /obj/effect/spawner/lootdrop/brs(temp_loc)
	spawn_effect(temp_loc)

/obj/machinery/brs_server/proc/spawn_effect(var/turf/temp_loc)
	playsound(temp_loc, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, temp_loc)
	new /obj/effect/portal(temp_loc, null, null, 40)


//================ Objects ================
/obj/item/paper/researchnotes_brs
	name = "Исследования Блюспейс Разлома"
	info = "<b>Долгожданные научные исследования блюспейс разлома, продвигающие науку изучения Синего Космоса далеко вперед. \nВ записке написана тарабарщина на машинном языке. \nТребуется деструктивный анализ.</b>"
	origin_tech = "bluespace=9;magnets=8"

//Bluspace Tolkan
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

/obj/effect/spawner/lootdrop/brs/
	name = "brs loot"
	lootcount = 1
	loot = list(
		//Item type, weight
		/obj/item/stack/ore/bluespace_crystal = 100,
		/obj/item/stack/sheet/mineral/bananium/fifty = 60,
		/obj/item/stack/sheet/mineral/tranquillite/fifty = 60,
		/obj/item/stack/sheet/mineral/abductor/fifty = 30,
		/obj/item/clothing/under/psyjump = 10,
		/obj/item/storage/box/beakers/bluespace = 10,
		/obj/item/grown/bananapeel/bluespace = 10,
		/obj/item/seeds/random/labelled = 10,
		/obj/item/clothing/mask/cigarette/random = 5,
		/obj/item/soap/syndie = 20,
		/obj/item/toy/syndicateballoon = 5,
		/obj/item/stack/telecrystal = 1,

		//Toys
		/obj/item/gun/projectile/automatic/c20r/toy = 5,
		/obj/item/gun/projectile/automatic/l6_saw/toy = 5,
		/obj/item/gun/projectile/automatic/toy/pistol = 10,
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 5,
		/obj/item/gun/projectile/shotgun/toy = 5,
		/obj/item/gun/projectile/shotgun/toy/crossbow = 5,
		/obj/item/gun/projectile/shotgun/toy/tommygun = 5,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy = 5,
		/obj/item/twohanded/dualsaber/toy = 5,
		/obj/item/toy/katana = 5,
		/obj/item/fluff/rapid_wheelchair_kit = 50,
		/obj/vehicle/secway = 60,
		/obj/vehicle/atv = 30,
		/obj/vehicle/motorcycle = 20,
		/obj/vehicle/janicart = 15,
		/obj/vehicle/ambulance = 15,
		/obj/vehicle/snowmobile = 15,
		/obj/vehicle/space/speedbike/red = 10,
		/obj/vehicle/space/speedbike = 10,
		/obj/vehicle/car,
		/obj/random/figure = 30,
		/obj/random/mech = 25,
		/obj/random/plushie = 30,
		/obj/random/therapy = 25,
		/obj/random/carp_plushie = 25,

		//Toys that you most likely will never get and unnecessary small things
		/obj/item/toy/prizeball/mech,
		/obj/item/toy/prizeball/carp_plushie,
		/obj/item/toy/prizeball/plushie,
		/obj/item/toy/prizeball/figure,
		/obj/item/toy/prizeball/therapy,
		/obj/item/toy/balloon,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/blink,
		/obj/item/storage/box/dice,
		/obj/item/storage/box/snappops,
		/obj/item/deck/cards,
		/obj/item/storage/fancy/crayons,
		/obj/item/toy/eight_ball,
		/obj/item/storage/wallet/color,
		/obj/item/id_decal/prisoner,
		/obj/item/id_decal/silver,
		/obj/item/id_decal/gold,
		/obj/item/id_decal/centcom,
		/obj/item/id_decal/emag,
		/obj/item/toy/flash,
		/obj/item/toy/minimeteor,
		/obj/item/toy/minigibber,
		/obj/item/grenade/confetti,
		/obj/item/toy/AI,
		/obj/item/gun/projectile/revolver/capgun,
		/obj/item/toy/pet_rock,
		/obj/item/bikehorn/rubberducky,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/spellbook/oneuse/mime/fingergun/fake,
		/obj/item/grenade/clusterbuster/eng_tools,
		/obj/item/grenade/clusterbuster/tools,
		/obj/item/toy/eight_ball/conch,
		/obj/item/toy/foamblade,
		/obj/item/toy/redbutton,
		/obj/item/toy/nuke,
		/obj/item/clothing/head/blob,
		/obj/item/toy/codex_gigas,
		/obj/item/toy/sword,
		/obj/item/stack/tile/fakespace/loaded,
		/obj/item/stack/tile/arcade_carpet/loaded,
		/obj/item/twohanded/toy/chainsaw,
		/obj/item/toy/crayon/random,
		/obj/structure/toilet = 10,
		/obj/structure/toilet/secret = 5,
		/obj/structure/toilet/golden_toilet,
		/obj/structure/toilet/bluespace,


		//Not the most valuable items can still drop, albeit with a small chance of the sum of them all:
		/obj/item/reagent_containers/food/snacks/wingfangchu,
		/obj/item/reagent_containers/food/snacks/hotdog,
		/obj/item/reagent_containers/food/snacks/sliceable/turkey,
		/obj/item/reagent_containers/food/snacks/appletart,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake,
		/obj/item/reagent_containers/food/snacks/sliceable/bananacake,
		/obj/item/reagent_containers/food/snacks/sliceable/chocolatecake,
		/obj/item/reagent_containers/food/snacks/soup/meatballsoup,
		/obj/item/reagent_containers/food/snacks/soup/stew,
		/obj/item/reagent_containers/food/snacks/soup/hotchili,
		/obj/item/reagent_containers/food/snacks/burrito,
		/obj/item/reagent_containers/food/snacks/fishburger,
		/obj/item/reagent_containers/food/snacks/cubancarp,
		/obj/item/reagent_containers/food/snacks/fishandchips,
		/obj/item/reagent_containers/food/snacks/meatpie,
		/obj/item/reagent_containers/food/snacks/plumphelmetbiscuit,
		/obj/item/reagent_containers/food/snacks/soup/mysterysoup,
		/obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread,
		/obj/item/clothing/head/collectable/chef,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/captain,
		/obj/item/clothing/head/collectable/beret,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/collectable/kitty,
		/obj/item/clothing/head/crown/fancy,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/HoS,
		/obj/item/clothing/head/collectable/thunderdome,
		/obj/item/clothing/head/collectable/swat,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/police,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/xenom,
		/obj/item/clothing/head/collectable/petehat,

		//Bluespace magic items with the lowest chance to spawn
		/obj/item/spellbook/oneuse/fireball,
		/obj/item/spellbook/oneuse/smoke,
		/obj/item/spellbook/oneuse/blind,
		/obj/item/spellbook/oneuse/forcewall,
		/obj/item/spellbook/oneuse/knock,
		/obj/item/spellbook/oneuse/charge,
		/obj/item/spellbook/oneuse/summonitem,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/spellbook/oneuse/sacredflame,
		/obj/item/spellbook/oneuse/mime,
		/obj/item/spellbook/oneuse/mime/fingergun,
		/obj/item/spellbook/oneuse/mime/greaterwall,
		/obj/item/spellbook/oneuse/mime/fingergun/fake,
		/obj/structure/closet/crate/necropolis/tendril,

		//Babki, babki, suka, babki!
		/obj/item/stack/spacecash/c1000000 = 1,
		/obj/item/stack/spacecash/c1000 = 5,
		/obj/item/stack/spacecash/c500 = 10,
		/obj/item/stack/spacecash/c200 = 15,
		/obj/item/stack/spacecash/c100 = 20,
		/obj/item/stack/spacecash/c50 = 20,
		/obj/item/stack/spacecash/c20 = 20,
		/obj/item/stack/spacecash/c10 = 20,
		/obj/item/storage/bag/cash = 10,
		/obj/item/storage/secure/briefcase/syndie = 30,
	)
