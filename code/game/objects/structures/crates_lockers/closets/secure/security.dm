/obj/structure/closet/secure_closet/captains
	name = "captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "capsecure"

/obj/structure/closet/secure_closet/captains/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик капитана",
        GENITIVE = "шкафчика капитана",
        DATIVE = "шкафчику капитана",
        ACCUSATIVE = "шкафчик капитана",
        INSTRUMENTAL = "шкафчиком капитана",
        PREPOSITIONAL = "шкафчике капитана",
    )

/obj/structure/closet/secure_closet/captains/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/captain(src)
	else
		new /obj/item/storage/backpack/satchel_cap(src)
	new /obj/item/book/manual/faxes(src)
	new /obj/item/storage/backpack/duffel/captain(src)
	new /obj/item/cartridge/captain(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/storage/belt/rapier(src)
	new /obj/item/gun/energy/gun(src)
	new /obj/item/door_remote/captain(src)
	new /obj/item/reagent_containers/food/drinks/mug/cap(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/storage/garmentbag/captains(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/structure/closet/secure_closet/hop
	name = "head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик главы персонала",
        GENITIVE = "шкафчика главы персонала",
        DATIVE = "шкафчику главы персонала",
        ACCUSATIVE = "шкафчик главы персонала",
        INSTRUMENTAL = "шкафчиком главы персонала",
        PREPOSITIONAL = "шкафчике главы персонала",
    )

/obj/structure/closet/secure_closet/hop/populate_contents()
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/cartridge/hop(src)
	new /obj/item/radio/headset/heads/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/PDAs(src)
	new /obj/item/gun/energy/gun/mini(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/accessory/petcollar(src)
	new /obj/item/door_remote/civillian(src)
	new /obj/item/reagent_containers/food/drinks/mug/hop(src)
	new /obj/item/clothing/accessory/medal/service(src)
	new /obj/item/storage/garmentbag/hop(src)
	new /obj/item/clothing/accessory/holster(src)

/obj/structure/closet/secure_closet/hos
	name = "head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик главы службы безопасности",
        GENITIVE = "шкафчика главы службы безопасности",
        DATIVE = "шкафчику главы службы безопасности",
        ACCUSATIVE = "шкафчик главы службы безопасности",
        INSTRUMENTAL = "шкафчиком главы службы безопасности",
        PREPOSITIONAL = "шкафчике главы службы безопасности",
    )

/obj/structure/closet/secure_closet/hos/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/cartridge/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/gloves/combat/swat(src)
	new /obj/item/storage/lockbox/mindshield(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/clothing/mask/gas/sechailer/hos(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/sec(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/gun/energy/gun/hos(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/reagent_containers/food/drinks/mug/hos(src)
	new /obj/item/autoimplanter/oneuse/sec_hud(src)
	new /obj/item/clothing/accessory/medal/security(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/aviators(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/reagent_containers/food/drinks/flask(src)
	new /obj/item/storage/garmentbag/hos(src)
	new /obj/item/camera_bug/security(src)

/obj/structure/closet/secure_closet/warden
	name = "warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик смотрителя",
        GENITIVE = "шкафчика смотрителя",
        DATIVE = "шкафчику смотрителя",
        ACCUSATIVE = "шкафчик смотрителя",
        INSTRUMENTAL = "шкафчиком смотрителя",
        PREPOSITIONAL = "шкафчике смотрителя",
    )

/obj/structure/closet/secure_closet/warden/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer/warden(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/belt/security/sec(src)
	new /obj/item/storage/box/holobadge(src)
	new /obj/item/clothing/gloves/color/black/krav_maga/sec(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/storage/garmentbag/warden(src)
	new /obj/item/gun/projectile/automatic/pistol/sp8(src)
	new /obj/item/ammo_box/magazine/sp8(src)
	new /obj/item/ammo_box/magazine/sp8(src)
	new /obj/item/security_voucher(src)
	new /obj/item/security_voucher(src)
	new /obj/item/security_voucher(src)
	new /obj/item/storage/box/sec_cameras(src)
	new /obj/item/camera_bug/security(src)

/obj/structure/closet/secure_closet/pilot_sniper
	name = "sniper gun cabinet"
	desc = "Защищённый шкаф для хранения снайперской винтовки LSR-39 \"Queen blade\"."
	req_access = list(ACCESS_PILOT)
	icon_state = "sniper"

/obj/structure/closet/secure_closet/pilot_sniper/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик снайперской винтовки LSR-39 \"Queen blade\".",
        GENITIVE = "шкафчика снайперской винтовки LSR-39 \"Queen blade\".",
        DATIVE = "шкафчику снайперской винтовки LSR-39 \"Queen blade\".",
        ACCUSATIVE = "шкафчик снайперской винтовки LSR-39 \"Queen blade\".",
        INSTRUMENTAL = "шкафчиком снайперской винтовки LSR-39 \"Queen blade\".",
        PREPOSITIONAL = "шкафчике снайперской винтовки LSR-39 \"Queen blade\".",
    )

/obj/structure/closet/secure_closet/pilot_sniper/populate_contents()
	new /obj/item/gun/energy/sniperrifle/pod_pilot(src)

/obj/structure/closet/secure_closet/security_grenade_launcher
	name = "security grenade launcher cabinet"
	desc = "Защищённый шкаф для хранения гранатомета GL-06 и боеприпасов к нему. Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "guncabinet"

/obj/structure/closet/secure_closet/security_grenade_launcher/get_ru_names()
	return list(
		NOMINATIVE = "шкаф гранатомета GL-06",
		GENITIVE = "шкафа гранатомета GL-06",
		DATIVE = "шкафу гранатомета GL-06",
		ACCUSATIVE = "шкаф гранатомета GL-06",
		INSTRUMENTAL = "шкафом гранатомета GL-06",
		PREPOSITIONAL = "шкафе гранатомета GL-06",
	)

/obj/structure/closet/secure_closet/security_grenade_launcher/populate_contents()
	new /obj/item/gun/projectile/bombarda/secgl(src)
	new /obj/item/ammo_box/secgl/solid(src)
	new /obj/item/ammo_box/secgl/solid(src)
	new /obj/item/ammo_box/secgl/flash(src)
	new /obj/item/ammo_box/secgl/flash(src)
	new /obj/item/ammo_box/secgl/gas(src)
	new /obj/item/ammo_box/secgl/barricade(src)
	new /obj/item/ammo_box/secgl/paint(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик офицера безопасности",
        GENITIVE = "шкафчика офицера безопасности",
        DATIVE = "шкафчику офицера безопасности",
        ACCUSATIVE = "шкафчик офицера безопасности",
        INSTRUMENTAL = "шкафчиком офицера безопасности",
        PREPOSITIONAL = "шкафчике офицера безопасности",
    )

/obj/structure/closet/secure_closet/security/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/clothing/suit/armor/vest/security(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/storage/belt/security/sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/suit/armor/secjacket(src)

/obj/structure/closet/secure_closet/guncabinet/wt550
	name = "security WT-550 PDW gun cabinet"
	desc = "Защищённый шкаф для хранения пистолетов пулемётов WT-550. Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/guncabinet/wt550/get_ru_names()
	return list(
		NOMINATIVE = "шкаф пистолет-пулемётов WT-550",
		GENITIVE = "шкафа пистолет-пулемётов WT-550",
		DATIVE = "шкафу пистолет-пулемётов WT-550",
		ACCUSATIVE = "шкаф пистолет-пулемётов WT-550",
		INSTRUMENTAL = "шкафом пистолет-пулемётов WT-550",
		PREPOSITIONAL = "шкафе пистолет-пулемётов WT-550",
	)

/obj/structure/closet/secure_closet/guncabinet/wt550/populate_contents()
	new /obj/item/gun/projectile/automatic/wt550(src)
	new /obj/item/gun/projectile/automatic/wt550(src)
	new /obj/item/gun/projectile/automatic/wt550(src)
	new /obj/item/gun/projectile/automatic/wt550(src)
	new /obj/item/gun/projectile/automatic/wt550(src)

/obj/structure/closet/secure_closet/guncabinet/sp91
	name = "security SP-91-RC gun cabinet"
	desc = "Защищённый шкаф для хранения пистолетов пулемётов SP-91-RC. Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/guncabinet/sp91/get_ru_names()
	return list(
		NOMINATIVE = "шкаф пистолет-пулемётов SP-91-RC",
		GENITIVE = "шкафа пистолет-пулемётов SP-91-RC",
		DATIVE = "шкафу пистолет-пулемётов SP-91-RC",
		ACCUSATIVE = "шкаф пистолет-пулемётов SP-91-RC",
		INSTRUMENTAL = "шкафом пистолет-пулемётов SP-91-RC",
		PREPOSITIONAL = "шкафе пистолет-пулемётов SP-91-RC",
	)

/obj/structure/closet/secure_closet/guncabinet/sp91/populate_contents()
	new /obj/item/gun/projectile/automatic/sp91rc(src)
	new /obj/item/gun/projectile/automatic/sp91rc(src)
	new /obj/item/gun/projectile/automatic/sp91rc(src)
	new /obj/item/gun/projectile/automatic/sp91rc(src)
	new /obj/item/gun/projectile/automatic/sp91rc(src)

/obj/structure/closet/secure_closet/guncabinet/sparkle_a12
	name = "security Sparkle-A12 gun cabinet"
	desc = "Защищённый шкаф для хранения пистолетов пулемётов А9 \"Искра\". Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/guncabinet/sparkle_a12/get_ru_names()
	return list(
		NOMINATIVE = "шкаф пистолет пулемёта А9 \"Искра\"",
		GENITIVE = "шкафа пистолет пулемёта А9 \"Искра\"",
		DATIVE = "шкафу пистолет пулемёта А9 \"Искра\"",
		ACCUSATIVE = "шкаф пистолет пулемёта А9 \"Искра\"",
		INSTRUMENTAL = "шкафом пистолет пулемёта А9 \"Искра\"",
		PREPOSITIONAL = "шкафе пистолет пулемёта А9 \"Искра\""
	)

/obj/structure/closet/secure_closet/guncabinet/sparkle_a12/populate_contents()
	new /obj/item/gun/projectile/automatic/sparkle_a12(src)
	new /obj/item/gun/projectile/automatic/sparkle_a12(src)
	new /obj/item/gun/projectile/automatic/sparkle_a12(src)
	new /obj/item/gun/projectile/automatic/sparkle_a12(src)
	new /obj/item/gun/projectile/automatic/sparkle_a12(src)

/obj/structure/closet/secure_closet/guncabinet/lasergun
	name = "security laser gun cabinet"
	desc = "Защищённый шкаф для хранения лазерных винтовок. Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/guncabinet/lasergun/get_ru_names()
	return list(
		NOMINATIVE = "шкаф лазерных винтовок",
		GENITIVE = "шкафа лазерных винтовок",
		DATIVE = "шкафу лазерных винтовок",
		ACCUSATIVE = "шкаф лазерных винтовок",
		INSTRUMENTAL = "шкафом лазерных винтовок",
		PREPOSITIONAL = "шкафе лазерных винтовок",
	)

/obj/structure/closet/secure_closet/guncabinet/lasergun/populate_contents()
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)
	new /obj/item/gun/energy/laser(src)

/obj/structure/closet/secure_closet/guncabinet/lr30
	name = "security LR-30 gun cabinet"
	desc = "Защищённый шкаф для хранения лазерных винтовок LR-30. Шкаф прикручен к полу."
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/guncabinet/lr30/get_ru_names()
	return list(
		NOMINATIVE = "шкаф лазерных винтовок LR-30",
		GENITIVE = "шкафа лазерных винтовок LR-30",
		DATIVE = "шкафу лазерных винтовок LR-30",
		ACCUSATIVE = "шкаф лазерных винтовок LR-30",
		INSTRUMENTAL = "шкафом лазерных винтовок LR-30",
		PREPOSITIONAL = "шкафе лазерных винтовок LR-30",
	)

/obj/structure/closet/secure_closet/guncabinet/lr30/populate_contents()
	new /obj/item/gun/projectile/automatic/lr30(src)
	new /obj/item/gun/projectile/automatic/lr30(src)
	new /obj/item/gun/projectile/automatic/lr30(src)
	new /obj/item/gun/projectile/automatic/lr30(src)
	new /obj/item/gun/projectile/automatic/lr30(src)

/obj/structure/closet/secure_closet/brigdoc
	name = "brig physician's locker"
	req_access = list(ACCESS_BRIG)
	icon_state = "brigmed"

/obj/structure/closet/secure_closet/brigdoc/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик врача брига",
        GENITIVE = "шкафчика врача брига",
        DATIVE = "шкафчику врача брига",
        ACCUSATIVE = "шкафчик врача брига",
        INSTRUMENTAL = "шкафчиком врача брига",
        PREPOSITIONAL = "шкафчике врача брига",
    )

/obj/structure/closet/secure_closet/brigdoc/populate_contents()
	new /obj/item/storage/backpack/duffel/medical(src)
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical/surgery/loaded(src)
	new /obj/item/handheld_defibrillator/(src)
	new /obj/item/handheld_defibrillator/(src)
	new /obj/item/reagent_containers/hypospray/safety(src)
	new /obj/item/reagent_containers/hypospray/safety(src)
	new /obj/item/sensor_device/advanced/security(src)
	new /obj/item/radio/headset/headset_brigphys(src)
	new /obj/item/storage/garmentbag/brigdoc(src)
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/storage/firstaid/premium(src)
	new /obj/item/implantcase(src)

/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	req_access = list(ACCESS_BLUESHIELD)
	icon_state = "bssecure"

/obj/structure/closet/secure_closet/blueshield/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик офицера \"Синий щит\"",
        GENITIVE = "шкафчика офицера \"Синий щит\"",
        DATIVE = "шкафчику офицера \"Синий щит\"",
        ACCUSATIVE = "шкафчик офицера \"Синий щит\"",
        INSTRUMENTAL = "шкафчиком офицера \"Синий щит\"",
        PREPOSITIONAL = "шкафчике офицера \"Синий щит\"",
    )

/obj/structure/closet/secure_closet/blueshield/populate_contents()
	new /obj/item/storage/briefcase(src)
	new	/obj/item/storage/firstaid/adv(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/storage/belt/security/sec(src)
	new /obj/item/clothing/gloves/combat/swat(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/clothing/mask/gas/sechailer/blue(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/sensor_device/advanced/command(src)
	new /obj/item/storage/garmentbag/blueshield(src)
	new /obj/item/storage/belt/security/webbing(src)
	new /obj/item/reagent_containers/spray/cleaner/tactical(src)

/obj/structure/closet/secure_closet/ntrep
	name = "Nanotrasen Representative's locker"
	req_access = list(ACCESS_NTREP)
	icon_state = "nt"

/obj/structure/closet/secure_closet/ntrep/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик представителя Нанотрейзен",
        GENITIVE = "шкафчика представителя Нанотрейзен",
        DATIVE = "шкафчику представителя Нанотрейзен",
        ACCUSATIVE = "шкафчик представителя Нанотрейзен",
        INSTRUMENTAL = "шкафчиком представителя Нанотрейзен",
        PREPOSITIONAL = "шкафчике представителя Нанотрейзен",
    )

/obj/structure/closet/secure_closet/ntrep/populate_contents()
	new /obj/item/book/manual/faxes(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/paicard(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/storage/box/tapes(src)
	new /obj/item/taperecorder(src)
	new /obj/item/storage/garmentbag/ntrep(src)

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/populate_contents()
	new /obj/item/clothing/accessory/armband/cargo(src)
	new /obj/item/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/populate_contents()
	new /obj/item/clothing/accessory/armband/engine(src)
	new /obj/item/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/populate_contents()
	new /obj/item/clothing/accessory/armband/science(src)
	new /obj/item/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/populate_contents()
	new /obj/item/clothing/accessory/armband/medgreen(src)
	new /obj/item/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/cabinet/detective
	name = "detective's cabinet"
	icon_state = "cabinetdetective"
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/structure/closet/secure_closet/cabinet/detective/get_ru_names()
    return list(
        NOMINATIVE = "шкаф детектива",
        GENITIVE = "шкафа детектива",
        DATIVE = "шкафу детектива",
        ACCUSATIVE = "шкаф детектива",
        INSTRUMENTAL = "шкафом детектива",
        PREPOSITIONAL = "шкафе детектива",
    )

/obj/structure/closet/secure_closet/cabinet/detective/populate_contents()
	new /obj/item/storage/backpack/satchel_detective(src)
	new /obj/item/storage/backpack/detective(src)
	new /obj/item/storage/backpack/duffel/detective(src)
	new /obj/item/clothing/gloves/color/black/forensics(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/detective_scanner(src)
	new /obj/item/clothing/glasses/sunglasses/yeah(src)
	new /obj/item/storage/belt/security/detective(src)
	new /obj/item/clothing/accessory/holobadge/detective(src)
	new /obj/item/storage/garmentbag/detective(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(ACCESS_SECURITY)

/obj/structure/closet/secure_closet/injection/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик для смертельных инъекций",
        GENITIVE = "шкафчика для смертельных инъекций",
        DATIVE = "шкафчику для смертельных инъекций",
        ACCUSATIVE = "шкафчик для смертельных инъекций",
        INSTRUMENTAL = "шкафчиком для смертельных инъекций",
        PREPOSITIONAL = "шкафчике для смертельных инъекций",
    )

/obj/structure/closet/secure_closet/injection/populate_contents()
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/lethal(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	desc = "Защищённый шкаф для хранения вещей заключённого."
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/brig/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик заключённого",
        GENITIVE = "шкафчика заключённого",
        DATIVE = "шкафчику заключённого",
        ACCUSATIVE = "шкафчик заключённого",
        INSTRUMENTAL = "шкафчиком заключённого",
        PREPOSITIONAL = "шкафчике заключённого",
    )

/obj/structure/closet/secure_closet/brig/populate_contents()
	new /obj/item/clothing/under/prison(src)
	new /obj/item/clothing/head/prison(src)
	new /obj/item/clothing/shoes/prison(src)
	new /obj/item/card/id/prisoner/random(src)
	new /obj/item/radio/headset/prisoner(src)

/obj/structure/closet/secure_closet/brig/evidence
	name = "evidence locker"
	desc = "Защищённый шкаф для хранения улик."
	req_access = list(ACCESS_SECURITY)

/obj/structure/closet/secure_closet/brig/evidence/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик с уликами",
        GENITIVE = "шкафчика с уликами",
        DATIVE = "шкафчику с уликами",
        ACCUSATIVE = "шкафчик с уликами",
        INSTRUMENTAL = "шкафчиком с уликами",
        PREPOSITIONAL = "шкафчике с уликами",
    )

/obj/structure/closet/secure_closet/brig/evidence/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(ACCESS_COURT)

/obj/structure/closet/secure_closet/courtroom/populate_contents()
	new /obj/item/clothing/shoes/color/brown(src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/storage/briefcase(src)

/obj/structure/closet/secure_closet/magistrate
	name = "Magistrate's locker"
	req_access = list(ACCESS_MAGISTRATE)
	icon_state = "magistrate"

/obj/structure/closet/secure_closet/magistrate/get_ru_names()
    return list(
        NOMINATIVE = "шкафчик магистрата",
        GENITIVE = "шкафчика магистрата",
        DATIVE = "шкафчику магистрата",
        ACCUSATIVE = "шкафчик магистрата",
        INSTRUMENTAL = "шкафчиком магистрата",
        PREPOSITIONAL = "шкафчике магистрата",
    )

/obj/structure/closet/secure_closet/magistrate/populate_contents()
	new /obj/item/book/manual/faxes(src)
	new /obj/item/storage/secure/briefcase(src)
	new /obj/item/flash(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/gavelblock(src)
	new /obj/item/gavelhammer(src)
	new /obj/item/clothing/accessory/medal/legal(src)
	new /obj/item/clothing/accessory/head_strip/lawyers_badge(src)
	new /obj/item/radio/headset/heads/magistrate/alt(src)	//added here deleted on maps
	new /obj/item/megaphone(src)
	new /obj/item/storage/garmentbag/magistrate(src)
	new /obj/item/storage/box/tapes(src)
