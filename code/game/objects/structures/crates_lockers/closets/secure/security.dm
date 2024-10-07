/obj/structure/closet/secure_closet/captains
	name = "captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "capsecure"

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
/obj/structure/closet/secure_closet/hop
	name = "head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

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

/obj/structure/closet/secure_closet/hos
	name = "head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/cartridge/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/gloves/combat(src)
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
	new /obj/item/organ/internal/cyberimp/eyes/hud/security(src)
	new /obj/item/clothing/accessory/medal/security(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/aviators(src)
	new /obj/item/megaphone(src)	//added here deleted on maps
	new /obj/item/reagent_containers/food/drinks/flask(src)
	new /obj/item/storage/garmentbag/hos(src)

/obj/structure/closet/secure_closet/warden
	name = "warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

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

/obj/structure/closet/secure_closet/pilot_sniper
	name = "sniper gun cabinet"
	req_access = list(ACCESS_PILOT)
	icon_state = "sniper"

/obj/structure/closet/secure_closet/pilot_sniper/populate_contents()
	new /obj/item/gun/energy/sniperrifle/pod_pilot(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

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

/obj/structure/closet/secure_closet/brigdoc
	name = "brig physician's locker"
	req_access = list(ACCESS_BRIG)
	icon_state = "brigmed"

/obj/structure/closet/secure_closet/brigdoc/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/clothing/suit/storage/brigdoc(src)
	new /obj/item/clothing/under/rank/security/brigphys(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/sensor_device/advanced/security(src)
	new /obj/item/radio/headset/headset_brigphys(src)
	new /obj/item/clothing/shoes/sandal/white(src)

/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	req_access = list(ACCESS_BLUESHIELD)
	icon_state = "bssecure"

/obj/structure/closet/secure_closet/blueshield/populate_contents()
	new /obj/item/storage/briefcase(src)
	new	/obj/item/storage/firstaid/adv(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/storage/belt/security/sec(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/read_only(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/clothing/glasses/hud/skills/sunglasses(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/clothing/mask/gas/sechailer/blue(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/sensor_device/advanced/command(src)
	new /obj/item/storage/garmentbag/blueshield(src)
	new /obj/item/storage/belt/security/webbing(src)

/obj/structure/closet/secure_closet/ntrep
	name = "\improper Nanotrasen Representative's locker"
	req_access = list(ACCESS_NTREP)
	icon_state = "nt"

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
	overlay_locker = "cd_locker"
	req_access = list(ACCESS_FORENSICS_LOCKERS)


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
	new /obj/item/storage/box/revolver_kit(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(ACCESS_SECURITY)

/obj/structure/closet/secure_closet/injection/populate_contents()
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/lethal(src)


/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/brig/populate_contents()
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/card/id/prisoner/random(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/brig/evidence
	name = "evidence locker"
	req_access = list(ACCESS_SECURITY)

/obj/structure/closet/secure_closet/brig/evidence/populate_contents()
	new /obj/item/stack/sheet/cardboard(src)

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(ACCESS_COURT)

/obj/structure/closet/secure_closet/courtroom/populate_contents()
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/paper/Court (src)
	new /obj/item/pen (src)
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
	new /obj/item/storage/briefcase(src)


/obj/structure/closet/secure_closet/wall //TODO: Add here sprites. (They do not exist)
	name = "wall locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "wall-locker"
	density = TRUE

	//too small to put a man in
	large = FALSE

/obj/structure/closet/secure_closet/magistrate
	name = "\improper Magistrate's locker"
	req_access = list(ACCESS_MAGISTRATE)
	icon_state = "magistrate"

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
