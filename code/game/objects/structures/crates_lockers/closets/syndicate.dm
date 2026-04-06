/obj/structure/closet/syndicate
	name = "armoury closet"
	desc = "Зачем это здесь?"
	icon_state = "syndicate"

/obj/structure/closet/syndicate/get_ru_names()
    return list(
        NOMINATIVE = "оружейный шкафчик",
        GENITIVE = "оружейного шкафчика",
        DATIVE = "оружейному шкафчику",
        ACCUSATIVE = "оружейный шкафчик",
        INSTRUMENTAL = "оружейным шкафчиком",
        PREPOSITIONAL = "оружейном шкафчике",
    )

/obj/structure/closet/syndicate/personal
	desc = "Это устройство для хранения снаряжения оперативников."

/obj/structure/closet/syndicate/personal/populate_contents()
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/clothing/glasses/night(src)

/obj/structure/closet/syndicate/suits
	desc = "Это устройство для хранения снаряжения оперативников."

/obj/structure/closet/syndicate/suits/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)

/obj/structure/closet/syndicate/nuclear
	desc = "Это устройство для хранения вещей абордажнной группы Синдиката."

/obj/structure/closet/syndicate/nuclear/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/backpack/duffel/syndie/med(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/pda/syndicate(src)

/obj/structure/closet/syndicate/sst
	desc = "Это устройство для хранения снаряжения элитной ударной группы Синдиката."

/obj/structure/closet/syndicate/sst/populate_contents()
	new /obj/item/ammo_box/magazine/l6saw(src)
	new /obj/item/gun/projectile/automatic/l6_saw(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)
	new /obj/item/storage/belt/military/sst(src)
	new /obj/item/clothing/glasses/thermal(src)
	new /obj/item/clothing/shoes/magboots/syndie/advance(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite/sst(src)

/obj/structure/closet/syndicate/resources
	desc = "Старый, пыльный шкафчик."

/obj/structure/closet/syndicate/resources/populate_contents()
	var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK

	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/paper/P = new /obj/item/paper(src)
		P.name = "IOU"
		P.info = "Извини, дружище, нам нужны были деньги, поэтому мы продали твою партию. Ничего страшного, в этот раз мы точно удвоим свои деньги!"

	//Metal (common ore)
	if(pickednum >= 2)
		new /obj/item/stack/sheet/metal(src, rand(common_min, common_max))

	//Glass (common ore)
	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

	//Plasteel (common ore) Because it has a million more uses then plasma
	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//Plasma (rare ore)
	if(pickednum >= 15)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//Silver (rare ore)
	if(pickednum >= 20)
		new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//Gold (rare ore)
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//Uranium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//Titanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

	//Plastitanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

	//Diamond (rare HONK)
	if(pickednum >= 45)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "Это аварийный шкафчик для хранения материалов, нужных для проведения ремонтных работ."

/obj/structure/closet/syndicate/resources/everything/populate_contents()
	var/list/resources = list(
	/obj/item/stack/sheet/metal,
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/mineral/gold,
	/obj/item/stack/sheet/mineral/silver,
	/obj/item/stack/sheet/mineral/plasma,
	/obj/item/stack/sheet/mineral/uranium,
	/obj/item/stack/sheet/mineral/diamond,
	/obj/item/stack/sheet/mineral/bananium,
	/obj/item/stack/sheet/mineral/titanium,
	/obj/item/stack/sheet/mineral/plastitanium,
	/obj/item/stack/sheet/plasteel,
	/obj/item/stack/rods
	)

	for(var/i in 1 to 2)
		for(var/res in resources)
			var/obj/item/stack/R = new res(src)
			R.amount = R.max_amount

//Adding syndicate closets for "Taipan". Sprites by Элл Гууд
/obj/structure/closet/secure_closet/syndicate
	name = "Syndicate Locker"
	desc = "Это стационарное складское устройство с замком, открывающимся по ID-карте. Большая буква \"S\" на нем указывает на то, что он принадлежит Синдикату."
	req_access = list(150)
	layer = 2.9 // ensures the loot they drop always appears on top of them.
	max_integrity = 300
	icon_state = "syndicate_secure"
	custom_open_overlay = "syndicate_secure"

/obj/structure/closet/secure_closet/syndicate/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик Синдиката",
        GENITIVE = "шкафчика Синдиката",
        DATIVE = "шкафчику Синдиката",
        ACCUSATIVE = "шкафчик Синдиката",
        INSTRUMENTAL = "шкафчиком Синдиката",
        PREPOSITIONAL = "шкафчике Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/comms_officer
	req_access = list(ACCESS_SYNDICATE_COMMS_OFFICER)
	name = "Syndicate Comms Officer's Locker"

/obj/structure/closet/secure_closet/syndicate/comms_officer/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик офицера связи Синдиката",
        GENITIVE = "шкафчика офицера связи Синдиката",
        DATIVE = "шкафчику офицера связи Синдиката",
        ACCUSATIVE = "шкафчик офицера связи Синдиката",
        INSTRUMENTAL = "шкафчиком офицера связи Синдиката",
        PREPOSITIONAL = "шкафчике офицера связи Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/comms_officer/populate_contents()
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/pda/syndicate/no_cartridge/comms(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/clothing/accessory/stripedredscarf(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/storage/secure/briefcase/syndie(src)
	new /obj/item/megaphone(src)
	new /obj/item/card/emag(src)
	new /obj/item/dnainjector/xraymut(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/encryptionkey/syndicate/taipan/tcomms_agent(src)
	new /obj/item/storage/backpack/syndicate/command(src)
	new /obj/item/storage/backpack/fluff/syndiesatchel(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
	new /obj/item/storage/box/syndicate_permits(src)
	new /obj/item/door_remote/taipan(src)
	new /obj/item/clothing/neck/cloak/syndiecap/comms(src)

/obj/structure/closet/secure_closet/syndicate/research_director
	name = "Syndicate Research Director's Locker"
	req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
	icon_state = "syndicate_rd_secure"

/obj/structure/closet/secure_closet/syndicate/research_director/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик научного руководителя Синдиката",
        GENITIVE = "шкафчика научного руководителя Синдиката",
        DATIVE = "шкафчику научного руководителя Синдиката",
        ACCUSATIVE = "шкафчик научного руководителя Синдиката",
        INSTRUMENTAL = "шкафчиком научного руководителя Синдиката",
        PREPOSITIONAL = "шкафчике научного руководителя Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/research_director/populate_contents()
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/pda/syndicate/no_cartridge/rd(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/clothing/accessory/rbscarf(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/storage/secure/briefcase/syndie(src)
	new /obj/item/megaphone(src)
	new /obj/item/card/emag(src)
	new /obj/item/clothing/suit/cardborg(src)
	new /obj/item/clothing/head/cardborg(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/storage/belt/chameleon(src)
	new /obj/item/organ/internal/cyberimp/arm/gun/laser(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/batterer(src)
	new /obj/item/storage/backpack/syndicate/command(src)
	new /obj/item/storage/backpack/fluff/syndiesatchel(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
	new /obj/item/storage/box/syndicate_permits(src)

/obj/structure/closet/secure_closet/syndicate/cargo
	name = "Syndicate Cargo Technician's Locker"
	req_access = list(ACCESS_SYNDICATE_CARGO)
	icon_state = "syndicate_cargo_secure"

/obj/structure/closet/secure_closet/syndicate/cargo/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик грузчика Синдиката",
        GENITIVE = "шкафчика грузчика Синдиката",
        DATIVE = "шкафчику грузчика Синдиката",
        ACCUSATIVE = "шкафчик грузчика Синдиката",
        INSTRUMENTAL = "шкафчиком грузчика Синдиката",
        PREPOSITIONAL = "шкафчике грузчика Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/cargo/populate_contents()
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/stamp/denied(src)
	new /obj/item/stamp/granted(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/under/rank/cargotech/skirt(src)
	new /obj/item/clothing/shoes/color/black(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/storage/backpack/syndicate/cargo(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/medbay
	name = "Syndicate Medical Doctor's Locker"
	req_access = list(ACCESS_SYNDICATE_MEDICAL)
	icon_state = "syndicate_med_secure"

/obj/structure/closet/secure_closet/syndicate/medbay/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик врача Синдиката",
        GENITIVE = "шкафчика врача Синдиката",
        DATIVE = "шкафчику врача Синдиката",
        ACCUSATIVE = "шкафчик врача Синдиката",
        INSTRUMENTAL = "шкафчиком врача Синдиката",
        PREPOSITIONAL = "шкафчике врача Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/medbay/populate_contents()
	new /obj/item/storage/backpack/duffel/syndie/surgery(src)
	new /obj/item/storage/backpack/duffel/syndie/surgery(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/color/white(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/shoes/sandal/white(src)
	new /obj/item/storage/backpack/syndicate/med(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/hydro
	name = "Syndicate Botanist's Locker"
	req_access = list(ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndicate_hydro_secure"

/obj/structure/closet/secure_closet/syndicate/hydro/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик ботаника Синдиката",
        GENITIVE = "шкафчика ботаника Синдиката",
        DATIVE = "шкафчику ботаника Синдиката",
        ACCUSATIVE = "шкафчик ботаника Синдиката",
        INSTRUMENTAL = "шкафчиком ботаника Синдиката",
        PREPOSITIONAL = "шкафчике ботаника Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/hydro/populate_contents()
	new /obj/item/clothing/suit/apron(src)
	new /obj/item/clothing/suit/apron/overalls(src)
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/clothing/under/rank/hydroponics(src)
	new /obj/item/clothing/glasses/hud/hydroponic(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/mask/bandana/botany(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/storage/box/disks_plantgene(src)
	new /obj/item/storage/backpack/syndicate(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/chef
	name = "Syndicate Chef's Locker"
	req_access = list(ACCESS_SYNDICATE_KITCHEN)
	icon_state = "syndicate_fridge_secure"

/obj/structure/closet/secure_closet/syndicate/chef/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик повара Синдиката",
        GENITIVE = "шкафчика повара Синдиката",
        DATIVE = "шкафчику повара Синдиката",
        ACCUSATIVE = "шкафчик повара Синдиката",
        INSTRUMENTAL = "шкафчиком повара Синдиката",
        PREPOSITIONAL = "шкафчике повара Синдиката",
    )

/obj/structure/closet/secure_closet/syndicate/chef/populate_contents()
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/clothing/under/rank/chef(src)
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/reagent_containers/glass/rag(src)
	new /obj/item/storage/backpack/syndicate(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
