//Автоматы, содержащие оружие

/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."

	icon_state = "liberationstation_off"
	panel_overlay = "liberationstation_panel"
	screen_overlay = "liberationstation"
	lightmask_overlay = "liberationstation_lightmask"
	broken_overlay = "liberationstation_broken"
	broken_lightmask_overlay = "liberationstation_broken_lightmask"

	req_access = list(ACCESS_SECURITY)
	slogan_list = list("Liberation Station: Your one-stop shop for all things second amendment!","Be a patriot today, pick up a gun!","Quality weapons for cheap prices!","Better dead than red!")
	ads_list = list("Float like an astronaut, sting like a bullet!","Express your second amendment today!","Guns don't kill people, but you can!","Who needs responsibilities when you have guns?")
	vend_reply = "Remember the name: Liberation Station!"
	products = list(/obj/item/gun/projectile/automatic/pistol/deagle/gold = 2,/obj/item/gun/projectile/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/projectile/automatic/pistol/m1911 = 2,/obj/item/gun/projectile/automatic/proto = 2,
					/obj/item/gun/projectile/shotgun/automatic/combat = 2,/obj/item/gun/projectile/automatic/gyropistol = 1,
					/obj/item/gun/projectile/shotgun = 2,/obj/item/gun/projectile/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2,/obj/item/ammo_box/magazine/m50 = 4,/obj/item/ammo_box/magazine/m45 = 2,/obj/item/ammo_box/magazine/m75 = 2)
	contraband = list(/obj/item/clothing/under/patriotsuit = 1,/obj/item/bedsheet/patriot = 3)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF


/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"

	icon_state = "syndi_off"
	panel_overlay = "syndi_panel"
	screen_overlay = "syndi"
	lightmask_overlay = "syndi_lightmask"
	broken_overlay = "syndi_broken"
	broken_lightmask_overlay = "syndi_broken_lightmask"

	slogan_list = list("Get your cool toys today!","Trigger a valid hunter today!","Quality toy weapons for cheap prices!","Give them to HoPs for all access!","Give them to HoS to get permabrigged!")
	ads_list = list("Feel robust with your toys!","Express your inner child today!","Toy weapons don't kill people, but valid hunters do!","Who needs responsibilities when you have toy weapons?","Make your next murder FUN!")
	vend_reply = "Come back for more!"
	products = list(/obj/item/gun/projectile/automatic/toy = 10,
					/obj/item/gun/projectile/automatic/toy/pistol= 10,
					/obj/item/gun/projectile/shotgun/toy = 10,
					/obj/item/toy/sword = 10,
					/obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just an assistant
	contraband = list(/obj/item/gun/projectile/shotgun/toy/crossbow= 10,   //Congrats, you unlocked the +18 setting!
					  /obj/item/gun/projectile/automatic/c20r/toy/riot = 10,
					  /obj/item/gun/projectile/automatic/l6_saw/toy/riot = 10,
  					  /obj/item/gun/projectile/automatic/sniper_rifle/toy = 10,
					  /obj/item/ammo_box/foambox/riot = 20,
					  /obj/item/toy/katana = 10,
					  /obj/item/twohanded/dualsaber/toy = 5,
					  /obj/item/deck/cards/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/vending/nta
	name = "NT Ammunition"
	desc = "A special equipment vendor."
	ads_list = list("Возьми патрон!","Не забывай, снаряжаться - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	panel_overlay = "nta_panel"
	screen_overlay = "nta"
	lightmask_overlay = "nta_lightmask"
	broken_overlay = "nta_broken"
	broken_lightmask_overlay = "nta_lightmask"
	vend_overlay = "nta_vend"
	deny_overlay = "nta_deny"
	vend_overlay_time = 3 SECONDS

	req_access = list(ACCESS_SECURITY)
	products = list(
		/obj/item/grenade/flashbang = 4,
		/obj/item/flash = 5,
		/obj/item/flashlight/seclite = 4,
		/obj/item/restraints/legcuffs/bola/energy = 8,

		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/rubbershot = 4,
		/obj/item/ammo_box/shotgun/stunslug = 5,
		/obj/item/ammo_box/shotgun/ion = 2,
		/obj/item/ammo_box/shotgun/laserslug = 5,
		/obj/item/ammo_box/speedloader/shotgun = 8,

		/obj/item/ammo_box/magazine/lr30mag = 12,
		/obj/item/ammo_box/magazine/enforcer = 8,
		/obj/item/ammo_box/magazine/enforcer/lethal = 8,
		/obj/item/ammo_box/magazine/sp8 = 8,

		/obj/item/ammo_box/magazine/laser = 12,
		/obj/item/ammo_box/magazine/wt550m9 = 20,
		/obj/item/ammo_box/magazine/m556 = 12,
		/obj/item/ammo_box/a40mm = 4,

		/obj/item/ammo_box/c46x30mm = 8,
		/obj/item/ammo_box/inc46x30mm = 4,
		/obj/item/ammo_box/tox46x30mm = 4,
		/obj/item/ammo_box/ap46x30mm = 4,
		/obj/item/ammo_box/laserammobox = 4
	)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/storage/fancy/donut_box = 2,/obj/item/grenade/clusterbuster/apocalypsefake = 1)
	refill_canister = /obj/item/vending_refill/nta
	tiltable = FALSE //no ert tilt

/obj/machinery/vending/nta/ertarmory
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/machinery/vending/nta/ertarmory/update_overlays()
	. = list()

	underlays.Cut()

	. += base_icon_state

	if(panel_open)
		. += "nta_panel"

	if((stat & NOPOWER) || force_no_power_icon_state)
		. += "nta_off"
		return

	if(stat & BROKEN)
		. += "nta_broken"
	else
		if(flick_sequence & FLICK_VEND)
			. += vend_overlay

		else if(flick_sequence & FLICK_DENY)
			. += deny_overlay

	underlays += emissive_appearance(icon, "nta_lightmask", src)


/obj/machinery/vending/nta/ertarmory/blue
	name = "NT ERT Medium Gear & Ammunition"
	desc = "A ERT Medium equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-blue"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-blue_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/energy/gun = 3,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/gun/projectile/automatic/lasercarbine = 3,
		/obj/item/ammo_box/magazine/laser = 6,
		/obj/item/suppressor = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/sfg = 3,
		/obj/item/ammo_box/magazine/sfg9mm = 6,
		/obj/item/gun/projectile/shotgun/automatic/combat = 3,
		/obj/item/ammo_box/shotgun = 4,
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun/dragonsbreath = 2
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/red
	name = "NT ERT Heavy Gear & Ammunition"
	desc = "A ERT Heavy equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-red"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-red_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/ar = 3,
		/obj/item/ammo_box/magazine/m556 = 6,
		/obj/item/gun/projectile/automatic/m52 = 3,
		/obj/item/ammo_box/magazine/m52mag = 6,
		/obj/item/gun/energy/sniperrifle = 1,
		/obj/item/gun/energy/lasercannon = 3,
		/obj/item/gun/energy/xray = 2,
		/obj/item/gun/energy/immolator/multi = 2,
		/obj/item/gun/energy/gun/nuclear = 3,
		/obj/item/storage/lockbox/t4 = 3,
		/obj/item/grenade/smokebomb = 3,
		/obj/item/grenade/frag = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/green
	name = "NT ERT Light Gear & Ammunition"
	desc = "A ERT Light equipment vendor."
	ads_list = list("Круши черепа синдиката!","Не забывай, спасать - полезно!","Бжж-Бзз-з!.","Обезопасить, Удержать, Сохранить!","Стоять, снярядись на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-green"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-green_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/restraints/handcuffs = 5,
		/obj/item/restraints/handcuffs/cable/zipties = 5,
		/obj/item/grenade/flashbang = 3,
		/obj/item/flash = 2,
		/obj/item/gun/energy/gun/advtaser = 4,
		/obj/item/gun/projectile/automatic/pistol/enforcer = 6,
		/obj/item/storage/box/barrier = 2,
		/obj/item/gun/projectile/shotgun/riot = 3,
		/obj/item/ammo_box/shotgun/rubbershot = 6,
		/obj/item/ammo_box/shotgun/beanbag = 4,
		/obj/item/ammo_box/shotgun/tranquilizer = 4,
		/obj/item/ammo_box/speedloader/shotgun = 4,
		/obj/item/gun/projectile/automatic/wt550 = 3,
		/obj/item/ammo_box/magazine/wt550m9 = 6,
		/obj/item/gun/energy/dominator/sibyl = 2,
		/obj/item/melee/baton/telescopic = 4
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/green/cc_jail
	name = "NT CentComm prison guards' Gear & Ammunition"
	desc = "An equipment vendor for CentComm corrections officers."
	products = list(/obj/item/restraints/handcuffs=5,
		/obj/item/restraints/handcuffs/cable/zipties=5,
		/obj/item/grenade/flashbang=3,
		/obj/item/flash=3,
		/obj/item/restraints/legcuffs/bola/energy=3,
		/obj/item/gun/energy/gun/advtaser=6,
		/obj/item/gun/projectile/automatic/pistol/enforcer=6,
		/obj/item/storage/box/barrier=2,
		/obj/item/gun/projectile/shotgun/riot=2,
		/obj/item/ammo_box/shotgun/rubbershot=4,
		/obj/item/ammo_box/shotgun=2,
		/obj/item/ammo_box/magazine/enforcer=6,
		/obj/item/gun/energy/dominator/sibyl=3)
	contraband = list(/obj/item/storage/fancy/donut_box=2,
		/obj/item/ammo_box/shotgun/buck=4,
		/obj/item/ammo_box/magazine/enforcer/lethal=4)

/obj/machinery/vending/nta/ertarmory/yellow
	name = "NT ERT Death Wish Gear & Ammunition"
	desc = "A ERT Death Wish equipment vendor."
	ads_list = list("Круши черепа ВСЕХ!","Не забывай, УБИВАТЬ - полезно!","УБИВАТЬ УБИВАТЬ УБИВАТЬ УБИВАТЬ!.","УБИВАТЬ, Удержать, УБИВАТЬ!","Стоять, снярядись на УБИВАТЬ!")

	icon_state = "nta_base"
	base_icon_state = "nta-yellow"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-yellow_deny"

	req_access = list(ACCESS_CENT_SECURITY)
	products = list(
		/obj/item/gun/projectile/automatic/gyropistol = 8,
		/obj/item/ammo_box/magazine/m75 = 12,
		/obj/item/gun/projectile/automatic/l6_saw = 6,
		/obj/item/ammo_box/magazine/mm556x45/ap = 12,
		/obj/item/gun/projectile/automatic/shotgun/bulldog = 6,
		/obj/item/gun/energy/immolator = 6,
		/obj/item/storage/backpack/duffel/syndie/ammo/shotgun = 12,
		/obj/item/gun/energy/xray = 8,
		/obj/item/gun/energy/pulse/destroyer/annihilator = 8,
		/obj/item/grenade/clusterbuster/inferno = 3,
		/obj/item/grenade/clusterbuster/emp = 3
	)
	contraband = list(/obj/item/storage/fancy/donut_box = 2)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/medical
	name = "NT ERT Medical Gear"
	desc = "A ERT medical equipment vendor."
	ads_list = list("Лечи раненых от рук синдиката!","Не забывай, лечить - полезно!","Бжж-Бзз-з!.","Перевязать, Оперировать, Выписать!","Стоять, снярядись медикаментами на задание!")

	icon_state = "nta_base"
	base_icon_state = "nta-medical"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-medical_deny"

	req_access = list(ACCESS_CENT_MEDICAL)
	products = list(
		/obj/item/storage/firstaid/tactical = 2,
		/obj/item/reagent_containers/applicator/dual = 2,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis = 4,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis = 2,
		/obj/item/storage/belt/medical/surgery/loaded = 2,
		/obj/item/storage/belt/medical/response_team = 3,
		/obj/item/storage/pill_bottle/ert = 4,
		/obj/item/reagent_containers/food/pill/mannitol = 10,
		/obj/item/reagent_containers/food/pill/salbutamol = 10,
		/obj/item/reagent_containers/food/pill/morphine = 8,
		/obj/item/reagent_containers/food/pill/charcoal = 10,
		/obj/item/reagent_containers/food/pill/mutadone = 8,
		/obj/item/storage/pill_bottle/patch_pack = 4,
		/obj/item/reagent_containers/food/pill/patch/silver_sulf = 10,
		/obj/item/reagent_containers/food/pill/patch/styptic = 10,
		/obj/item/storage/toolbox/surgery = 2,
		/obj/item/scalpel/laser/manager = 2,
		/obj/item/reagent_containers/applicator/brute = 4,
		/obj/item/reagent_containers/applicator/burn = 4,
		/obj/item/healthanalyzer/advanced = 4,
		/obj/item/roller/holo = 2
	)
	contraband = list()
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/engineer
	name = "NT ERT Engineer Gear"
	desc = "A ERT engineering equipment vendor."
	ads_list = list("Чини станцию от рук синдиката!","Не забывай, чинить - полезно!","Бжж-Бзз-з!.","Починить, Заварить, Трубить!","Стоять, снярядись на починку труб!")

	icon_state = "nta_base"
	base_icon_state = "nta-engi"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-engi_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/utility/chief/full = 2,
		/obj/item/clothing/mask/gas/welding = 4,
		/obj/item/weldingtool/experimental = 3,
		/obj/item/crowbar/power = 3,
		/obj/item/screwdriver/power  = 3,
		/obj/item/extinguisher/mini = 3,
		/obj/item/multitool = 3,
		/obj/item/rcd/preloaded = 2,
		/obj/item/rcd_ammo  = 8,
		/obj/item/stack/cable_coil = 4
	)
	contraband = list(/obj/item/clothing/head/welding/flamedecal = 1,
		/obj/item/storage/fancy/donut_box = 2,
		/obj/item/clothing/head/welding/flamedecal/white  = 1,
		/obj/item/clothing/head/welding/flamedecal/blue = 1
		)
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/nta/ertarmory/janitor
	name = "NT ERT Janitor Gear"
	desc = "A ERT ccleaning equipment vendor."
	ads_list = list("Чисть станцию от рук синдиката!","Не забывай, чистить - полезно!","Вилкой чисти!.","Помыть, Постирать, Оттереть!","Стоять, снярядись клинерами!")

	icon_state = "nta_base"
	base_icon_state = "nta-janitor"
	vend_overlay = "nta_vend"
	deny_overlay = "nta-janitor_deny"

	req_access = list(ACCESS_CENT_GENERAL)
	products = list(
		/obj/item/storage/belt/janitor/ert = 2,
		/obj/item/clothing/shoes/galoshes = 2,
		/obj/item/grenade/chem_grenade/antiweed = 2,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/bag/trash = 2,
		/obj/item/storage/box/lights/mixed = 4,
		/obj/item/melee/flyswatter= 1,
		/obj/item/soap/ert = 2,
		/obj/item/grenade/chem_grenade/cleaner = 4,
		/obj/item/clothing/mask/gas = 3,
		/obj/item/watertank/janitor  = 4,
		/obj/item/lightreplacer = 2
	)
	contraband = list(/obj/item/grenade/clusterbuster/cleaner = 1, /obj/item/storage/fancy/donut_box = 2, )
	refill_canister = /obj/item/vending_refill/nta

/obj/machinery/vending/security/ert
	name = "NT ERT Consumables Gear"
	desc = "A consumable equipment for different situations."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	refill_canister = /obj/item/vending_refill/nta

	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "sec_off"
	panel_overlay = "sec_panel"
	screen_overlay = "sec"
	lightmask_overlay = "sec_lightmask"
	broken_overlay = "sec_broken"
	broken_lightmask_overlay = "sec_broken_lightmask"
	deny_overlay = "sec_deny"

	density = FALSE
	products = list(
		/obj/item/restraints/handcuffs = 10,
		/obj/item/flashlight/seclite = 10,
		/obj/item/shield/riot/tele = 10,
		/obj/item/storage/box/flare = 5,
		/obj/item/storage/box/bodybags = 5,
		/obj/item/storage/box/bola = 5,
		/obj/item/grenade/smokebomb = 10,
		/obj/item/grenade/barrier = 15,
		/obj/item/grenade/flashbang = 10,
		/obj/item/grenade/plastic/c4_shaped/flash = 5,
		/obj/item/flash = 5,
		/obj/item/storage/box/evidence = 5,
		/obj/item/storage/box/swabs = 5,
		/obj/item/storage/box/fingerprints = 5)
	refill_canister = /obj/item/vending_refill/nta


