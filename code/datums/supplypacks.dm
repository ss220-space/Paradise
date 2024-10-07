//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// Supply Groups
#define SUPPLY_EMERGENCY 1
#define SUPPLY_SECURITY 2
#define SUPPLY_ENGINEER 3
#define SUPPLY_MEDICAL 4
#define SUPPLY_SCIENCE 5
#define SUPPLY_ORGANIC 6
#define SUPPLY_MATERIALS 7
#define SUPPLY_MISC 8
#define SUPPLY_VEND 9
#define SUPPLY_CONTRABAND 10

GLOBAL_LIST_INIT(all_supply_groups, list(SUPPLY_EMERGENCY,SUPPLY_SECURITY,SUPPLY_ENGINEER,SUPPLY_MEDICAL,SUPPLY_SCIENCE,SUPPLY_ORGANIC,SUPPLY_MATERIALS,SUPPLY_MISC,SUPPLY_VEND, SUPPLY_CONTRABAND))

/proc/get_supply_group_name(var/cat)
	switch(cat)
		if(SUPPLY_EMERGENCY)
			return "Emergency"
		if(SUPPLY_SECURITY)
			return "Security"
		if(SUPPLY_ENGINEER)
			return "Engineering"
		if(SUPPLY_MEDICAL)
			return "Medical"
		if(SUPPLY_SCIENCE)
			return "Science"
		if(SUPPLY_ORGANIC)
			return "Food and Livestock"
		if(SUPPLY_MATERIALS)
			return "Raw Materials"
		if(SUPPLY_MISC)
			return "Miscellaneous"
		if(SUPPLY_VEND)
			return "Vending"
		if(SUPPLY_CONTRABAND)
			return "Contraband"



/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/credits_cost = 0
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = SUPPLY_MISC
	var/list/announce_beacons = list() // Particular beacons that we'll notify the relevant department when we reach
	var/special = FALSE //Event/Station Goals/Admin enabled packs
	var/special_enabled = FALSE

	/// The number of times one can order a cargo crate, before it becomes restricted. -1 for infinite
//	var/order_limit = -1	// Unused for now (Crate limit #3056).
	/// Number of times a crate has been ordered in a shift
	var/times_ordered = 0

	/// List of names for being done in TGUI
	var/list/ui_manifest = list()

	var/list/required_tech


/datum/supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = path
		manifest += "<li>[initial(AM.name)]</li>"
		// Add the name to the UI manifest
		ui_manifest += "[initial(AM.name)]"
	manifest += "</ul>"

/datum/supply_packs/proc/can_approve(mob/user)
	if(SSshuttle.points < cost)
		user.balloon_alert(user, "недостаточно очков поставок!")
		return FALSE
	if(credits_cost && SSshuttle.cargo_money_account.money < credits_cost)
		user.balloon_alert(user, "недостаточно денег на счету!")
		return FALSE
	if(!length(required_tech))
		return TRUE
	for(var/tech_id in required_tech)
		if(!SSshuttle.techLevels[tech_id] || required_tech[tech_id] > SSshuttle.techLevels[tech_id])
			user.balloon_alert(user, "повысьте уровни технологий!")
			return FALSE
	return TRUE

////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Emergency ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/emergency	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = SUPPLY_EMERGENCY


/datum/supply_packs/emergency/evac
	name = "Emergency Equipment Crate"
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/gas/oxygen,
					/obj/item/grenade/gas/oxygen)
	cost = 40
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"

/datum/supply_packs/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher,
					/obj/item/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "firefighting crate"

/datum/supply_packs/emergency/atmostank
	name = "Firefighting Watertank Crate"
	contains = list(/obj/item/watertank/atmos)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "firefighting watertank crate"


/datum/supply_packs/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/emergency/voxsupport
	name = "Vox Life Support Supplies"
	contains = list(/obj/item/clothing/mask/breath/vox,
					/obj/item/clothing/mask/breath/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox)
	cost = 35
	containertype = /obj/structure/closet/crate/medical
	containername = "vox life support supplies crate"

/datum/supply_packs/emergency/plasmamansupport
	name = "Plasmaman Supply Kit"
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill,
					/obj/item/extinguisher_refill)
	cost = 35
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasmaman life support supplies crate"
	access = ACCESS_CARGO

/datum/supply_packs/emergency/pacmancrate
	name = "P.A.C.M.A.N Generator Crate"
	contains = list(/obj/machinery/power/port_gen,
					/obj/item/stack/sheet/mineral/plasma{amount = 20})
	cost = 220
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "P.A.C.M.A.N supplies crate"
	access = ACCESS_ATMOSPHERICS
	required_tech = list("engineering" = 2, "materials" = 2)

/datum/supply_packs/emergency/spacesuit
	name = "Space Suit Crate"
	contains = list(/obj/item/clothing/suit/space,
					/obj/item/clothing/suit/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/head/helmet/space,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 80
	containertype = /obj/structure/closet/crate/secure
	containername = "space suit crate"


/datum/supply_packs/emergency/scrubbercrate
	name = "Scrubber Crate"
	contains = list(/obj/machinery/portable_atmospherics/scrubber)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "scrubber crate"
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/pumpcrate
	name = "Pump Crate"
	contains = list(/obj/machinery/portable_atmospherics/pump)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "pump crate"
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/biosuitcrate
	name = "Anti-epidemic equipment crate"
	contains = list(/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/suit/bio_suit,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/head/bio_hood,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi)
	cost = 120
	containername = "anti-epidemic equipment crate"

/datum/supply_packs/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 60
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = 1

/datum/supply_packs/emergency/syndicate
	name = "ERROR_NULL_ENTRY"
	contains = list(/obj/item/storage/box/random_syndi)
	cost = 0
	credits_cost = 2500
	containertype = /obj/structure/closet/crate/syndicate
	containername = "crate"
	hidden = 1

/datum/supply_packs/emergency/highrisk
	name = "HEADER"
	cost = 450
	containertype = /obj/structure/closet/crate/secure
	containername = "high-risk crate"
	access = ACCESS_CAPTAIN

/datum/supply_packs/emergency/highrisk/rd_handtp
	name = "Hand Teleporter Crate"
	access = ACCESS_RD
	contains = list(/obj/item/hand_tele)
	required_tech = list("programming" = 7, "bluespace" = 8)

/datum/supply_packs/emergency/highrisk/rd_tp_armor
	name = "Reactive Armor Crate"
	access = ACCESS_RD
	contains = list(/obj/item/clothing/suit/armor/reactive/teleport)
	required_tech = list("combat" = 8, "bluespace" = 5)

/datum/supply_packs/emergency/highrisk/capt_jet
	name = "Deluxe Jetpack Crate"
	access = ACCESS_CAPTAIN
	contains = list(/obj/item/tank/jetpack/oxygen/captain)
	required_tech = list("toxins" = 8, "materials" = 7)

/datum/supply_packs/emergency/highrisk/ce_combatrcd
	name = "Combat R.C.D. Crate"
	access = ACCESS_CE
	contains = list(/obj/item/rcd/combat)
	required_tech = list("materials" = 6, "engineering" = 8)

/datum/supply_packs/emergency/highrisk/ce_advmagboots
	name = "Advanced Magboots Crate"
	access = ACCESS_CE
	contains = list(/obj/item/clothing/shoes/magboots/advance)
	required_tech = list("engineering" = 8, "magnets" = 6)

/datum/supply_packs/emergency/highrisk/cmo_defib
	name = "Advanced Defibrillator Crate"
	access = ACCESS_CMO
	contains = list(/obj/item/defibrillator/compact/advanced/loaded)
	required_tech = list("biotech" = 7, "powerstorage" = 8)

/datum/supply_packs/emergency/highrisk/cmo_hypospray
	name = "Advanced Hypospray Crate"
	access = ACCESS_CMO
	contains = list(/obj/item/reagent_containers/hypospray/CMO/empty)
	required_tech = list("materials" = 7, "biotech" = 8)

/datum/supply_packs/emergency/jetpack
	name = "Jetpack Crate"
	contains = list(
					/obj/item/tank/jetpack,
					/obj/item/tank/jetpack,
					/obj/item/tank/jetpack
					)
	cost = 30
	required_tech = list("toxins" = 3)
	containername = "Jetpack crate"

/datum/supply_packs/emergency/jetpack_upgrade
	name = "Jetpack Upgrade Crate"
	contains = list(
					/obj/item/tank/jetpack/suit,
					/obj/item/tank/jetpack/suit,
					/obj/item/tank/jetpack/suit
					)
	cost = 80
	required_tech = list("toxins" = 7)
	containername = "Jetpack upgrade crate"

/datum/supply_packs/emergency/jetpack_mini
	name = "Mouse Jetpack Crate"
	contains = list(
					/obj/item/mouse_jetpack,
					/obj/item/mouse_jetpack
					)
	cost = 30
	required_tech = list("toxins" = 2)
	containername = "mouse jetpack crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Security ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/security
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/gear
	access = ACCESS_SECURITY
	group = SUPPLY_SECURITY
	announce_beacons = list("Security" = list("Head of Security's Desk", "Warden", "Security"))

/datum/supply_packs/security/hardsuit
	name = "Security Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/security,
					/obj/item/clothing/suit/space/hardsuit/security,
					/obj/item/clothing/mask/gas/sechailer,
					/obj/item/clothing/mask/gas/sechailer)
	cost = 180
	containertype = /obj/structure/closet/crate/secure/gear
	required_tech = list("toxins" = 6, "combat" = 6)
	containername = "Security Hardsuit Crate"
	access = ACCESS_ARMORY

/datum/supply_packs/security/supplies
	name = "Security Supplies Crate"
	contains = list(/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/teargas,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/handcuffs)
	cost = 15
	containername = "security supply crate"

/datum/supply_packs/security/vending/security
	name = "SecTech Supply Crate"
	cost = 75
	contains = list(/obj/item/vending_refill/security)
	containername = "SecTech supply crate"

////// Armor: Basic

/datum/supply_packs/security/justiceinbound
	name = "Standard Justice Enforcer Crate"
	contains = list(/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/head/helmet/justice,
					/obj/item/clothing/mask/gas/sechailer,
					/obj/item/clothing/mask/gas/sechailer)
	cost = 45 //justice comes at a price. An expensive, noisy price.
	containername = "justice enforcer crate"

/datum/supply_packs/security/armor
	name = "Standard Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/suit/armor/vest,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet,
					/obj/item/clothing/head/helmet)
	cost = 20
	containername = "armor crate"

////// Weapons: Basic

/datum/supply_packs/security/baton
	name = "Stun Batons Crate"
	contains = list(/obj/item/melee/baton/security/loaded,
					/obj/item/melee/baton/security/loaded,
					/obj/item/melee/baton/security/loaded)
	cost = 20
	containername = "stun baton crate"

/datum/supply_packs/security/laser
	name = "Lasers Crate"
	contains = list(/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser,
					/obj/item/gun/energy/laser)
	cost = 20
	containername = "laser crate"

/datum/supply_packs/security/taser
	name = "Non-lethal Energy Weapon Crate"
	contains = list(/obj/item/gun/energy/gun/advtaser,
					/obj/item/gun/energy/gun/advtaser,
					/obj/item/gun/energy/gun/advtaser,
					/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler,
					/obj/item/gun/energy/disabler)
	cost = 25
	containername = "non-lethal gun crate"

/datum/supply_packs/security/enforcer
	name = "Enforcer Crate"
	contains = list(/obj/item/storage/box/enforcer/security,
					/obj/item/storage/box/enforcer/security)
	cost = 12
	containername = "Enforcer crate"

/datum/supply_packs/security/forensics
	name = "Forensics Crate"
	contains = list(/obj/item/storage/box/evidence,
					/obj/item/camera,
					/obj/item/taperecorder,
					/obj/item/toy/crayon/white,
					/obj/item/clothing/head/det_hat,
					/obj/item/storage/box/swabs,
					/obj/item/storage/box/fingerprints,
					/obj/item/storage/briefcase/crimekit)
	cost = 20
	containername = "forensics crate"

/datum/supply_packs/security/telescopic
	name = "Telescopic Baton Crate"
	contains = list(/obj/item/melee/baton/telescopic,
					/obj/item/melee/baton/telescopic)
	cost = 20
	containername = "telescopic baton crate"

///// Armory stuff

/datum/supply_packs/security/armory
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/weapon
	access = ACCESS_ARMORY
	announce_beacons = list("Security" = list("Warden", "Head of Security's Desk"))

///// Armor: Specialist

/datum/supply_packs/security/armory/riothelmets
	name = "Riot Bundle Crate"
	contains = list(/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/clothing/head/helmet/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/shield/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot,
					/obj/item/clothing/suit/armor/riot)
	cost = 80
	containername = "riot bundle crate"

/datum/supply_packs/security/armory/bulletarmor
	name = "Bulletproof Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/suit/armor/bulletproof,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt,
					/obj/item/clothing/head/helmet/alt)
	cost = 40
	containername = "tactical armor crate"

/datum/supply_packs/security/armory/webbing
	name = "Webbing Crate"
	contains = list(/obj/item/storage/belt/security/webbing,
					/obj/item/storage/belt/security/webbing,
					/obj/item/storage/belt/security/webbing)
	cost = 15
	containername = "tactical webbing crate"

/datum/supply_packs/security/armory/combat_webbing
	name = "Combat Webbing Crate"
	contains = list(/obj/item/clothing/accessory/storage/webbing,
					/obj/item/clothing/accessory/storage/webbing,
					/obj/item/clothing/accessory/storage/webbing)
	cost = 25
	containername = "combat webbing crate"

/datum/supply_packs/security/armory/vest
	name = "Combat Vest Crate"
	contains = list(/obj/item/clothing/accessory/storage/black_vest,
					/obj/item/clothing/accessory/storage/black_vest,
					/obj/item/clothing/accessory/storage/brown_vest,
					/obj/item/clothing/accessory/storage/brown_vest)
	cost = 50
	containername = "combat vest crate"

/datum/supply_packs/security/armory/swat
	name = "SWAT gear crate"
	contains = list(/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/head/helmet/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/clothing/suit/space/swat,
					/obj/item/kitchen/knife/combat,
					/obj/item/kitchen/knife/combat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/clothing/mask/gas/sechailer/swat,
					/obj/item/storage/belt/military/assault,
					/obj/item/storage/belt/military/assault)
	cost = 80
	containername = "assault armor crate"

/datum/supply_packs/security/armory/laserarmor
	name = "Ablative Armor Crate"
	contains = list(/obj/item/clothing/suit/armor/laserproof,
					/obj/item/clothing/suit/armor/laserproof)		// Only two vests to keep costs down for balance
	cost = 20
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ablative armor crate"
	required_tech = list("bluespace" = 4, "combat" = 4)

/datum/supply_packs/security/armory/sibyl
	name = "Sibyl Attachments Crate"
	contains = list(/obj/item/sibyl_system_mod,
					/obj/item/sibyl_system_mod,
					/obj/item/sibyl_system_mod)
	cost = 25														//По 6 за один блокиратор
	containername = "sibyl attachments crate"

/////// Weapons: Specialist

/datum/supply_packs/security/armory/ballistic
	name = "Riot Shotguns Crate"
	contains = list(/obj/item/gun/projectile/shotgun/riot,
					/obj/item/gun/projectile/shotgun/riot,
					/obj/item/gun/projectile/shotgun/riot,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	cost = 50
	containername = "riot shotgun crate"

/datum/supply_packs/security/armory/ballisticauto
	name = "Combat Shotguns Crate"
	contains = list(/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/gun/projectile/shotgun/automatic/combat,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier,
					/obj/item/storage/belt/bandolier)
	cost = 100
	containername = "combat shotgun crate"

/datum/supply_packs/security/armory/buckshotammo
	name = "Buckshot Ammo Crate"
	contains = list(/obj/item/ammo_box/speedloader/shotgun/buck,
					/obj/item/ammo_box/shotgun/buck,
					/obj/item/ammo_box/shotgun/buck,
					/obj/item/ammo_box/shotgun/buck,
					/obj/item/ammo_box/shotgun/buck,
					/obj/item/ammo_box/shotgun/buck)
	cost = 45
	containername = "buckshot ammo crate"

/datum/supply_packs/security/armory/slugammo
	name = "Slug Ammo Crate"
	contains = list(/obj/item/ammo_box/speedloader/shotgun/slug,
					/obj/item/ammo_box/shotgun,
					/obj/item/ammo_box/shotgun,
					/obj/item/ammo_box/shotgun,
					/obj/item/ammo_box/shotgun,
					/obj/item/ammo_box/shotgun)
	cost = 45
	containername = "slug ammo crate"

/datum/supply_packs/security/armory/expenergy
	name = "Energy Guns Crate"
	contains = list(/obj/item/gun/energy/gun,
					/obj/item/gun/energy/gun,
					/obj/item/gun/energy/gun)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"

/datum/supply_packs/security/armory/epistol	// costs 3/5ths of the normal e-guns for 3/4ths the total ammo, making it cheaper to arm more people, but less convient for any one person
	name = "Energy Pistol Crate"
	contains = list(/obj/item/gun/energy/gun/mini,
					/obj/item/gun/energy/gun/mini,
					/obj/item/gun/energy/gun/mini)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "energy gun crate"

/datum/supply_packs/security/armory/eweapons
	name = "Incendiary Weapons Crate"
	contains = list(/obj/item/flamethrower/full,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 30	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "incendiary weapons crate"
	access = ACCESS_HEADS

/datum/supply_packs/security/armory/wt550
	name = "WT-550 Auto Rifle Crate"
	contains = list(/obj/item/gun/projectile/automatic/wt550,
					/obj/item/gun/projectile/automatic/wt550)
	cost = 35
	containername = "auto rifle crate"

/datum/supply_packs/security/armory/ga12
	name = "Tkach Ya-Sui GA 12 Crate"
	contains = list(/obj/item/gun/projectile/revolver/ga12,
					/obj/item/gun/projectile/revolver/ga12)
	cost = 80
	containername = "Tkach supply crate"
	required_tech = list("combat" = 5, "materials" = 3)

/datum/supply_packs/security/armory/lr30
	name = "LR-30 Crate"
	contains = list(/obj/item/gun/projectile/automatic/lr30,
					/obj/item/gun/projectile/automatic/lr30,
					/obj/item/gun/projectile/automatic/lr30,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag,
					/obj/item/ammo_box/magazine/lr30mag)
	cost = 65
	containername = "laser rifle crate"

/datum/supply_packs/security/armory/wt550ammo
	name = "WT-550 Rifle Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/magazine/wt550m9,
					/obj/item/ammo_box/c46x30mm,
					/obj/item/ammo_box/c46x30mm,
					/obj/item/ammo_box/c46x30mm,
					/obj/item/ammo_box/c46x30mm)
	cost = 100
	containername = "auto rifle ammo crate"

/datum/supply_packs/security/armory/wt550apammo
	name = "WT-550 Rifle Armor-Piercing Ammo Crate"
	contains = list(/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/magazine/wt550m9/wtap,
					/obj/item/ammo_box/ap46x30mm,
					/obj/item/ammo_box/ap46x30mm,
					/obj/item/ammo_box/ap46x30mm,
					/obj/item/ammo_box/ap46x30mm)
	cost = 140
	containername = "auto rifle armor-piercing ammo crate"
	required_tech = list("combat" = 5, "materials" = 3)

/datum/supply_packs/security/armory/security_voucher
	name = "Security Voucher crate"
	contains = list(/obj/item/security_voucher,
					/obj/item/security_voucher,
					/obj/item/security_voucher,
					/obj/item/security_voucher,
					/obj/item/security_voucher,)
	cost = 100
	name = "Security Voucher crate"

/////// Implants & etc

/datum/supply_packs/security/armory/mindshield
	name = "Mindshield Implants Crate"
	contains = list (/obj/item/storage/lockbox/mindshield)
	cost = 60
	containername = "mindshield implant crate"
	required_tech = list("materials" = 2, "biotech" = 4, "programming" = 4)

/datum/supply_packs/security/armory/trackingimp
	name = "Tracking Implants Crate"
	contains = list (/obj/item/storage/box/trackimp)
	cost = 30
	containername = "tracking implant crate"
	required_tech = list("materials" = 2, "biotech" = 2, "programming" = 2, "magnets" = 2)

/datum/supply_packs/security/armory/chemimp
	name = "Chemical Implants Crate"
	contains = list (/obj/item/storage/box/chemimp)
	cost = 30
	containername = "chemical implant crate"
	required_tech = list("materials" = 3, "biotech" = 4)

/datum/supply_packs/security/armory/exileimp
	name = "Exile Implants Crate"
	contains = list (/obj/item/storage/box/exileimp)
	cost = 30
	containername = "exile implant crate"
	required_tech = list("materials" = 2, "biotech" = 4, "programming" = 6)

/datum/supply_packs/security/armory/ion_carbine
	name = "Ion Carbine Crate"
	containername = "ion carbine crate"
	cost = 120
	contains = list(
		/obj/item/gun/energy/ionrifle/carbine,
		/obj/item/gun/energy/ionrifle/carbine,
		/obj/item/gun/energy/ionrifle/carbine
	)
	required_tech = list("combat" = 5, "magnets" = 4)

/datum/supply_packs/security/armory/tele_shield
	name = "Telescopic Riot Shield Crate"
	containername = "telescopic riot shield crate"
	cost = 80
	contains = list(
		/obj/item/shield/riot/tele,
		/obj/item/shield/riot/tele,
		/obj/item/shield/riot/tele
	)
	required_tech = list("combat" = 4, "engineering" = 4, "materials" = 3)

/datum/supply_packs/security/armory/shotgun_shells
	name = "Various Shotgun Shells Crate"
	containername = "various shotgun shells crate"
	cost = 250
	contains = list(
		/obj/item/ammo_box/shotgun/stunslug,
		/obj/item/ammo_box/shotgun/pulseslug,
		/obj/item/ammo_box/shotgun/dragonsbreath,
		/obj/item/ammo_box/shotgun/frag12,
		/obj/item/ammo_box/shotgun/ion,
		/obj/item/ammo_box/shotgun/laserslug,
	)
	required_tech = list("powerstorage" = 4, "combat" = 4, "magnets" = 4, "materials" = 4)

/datum/supply_packs/security/securitybarriers
	name = "Security Barriers Crate"
	contains = list(/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier,
					/obj/item/grenade/barrier)
	cost = 10
	containername = "security barriers crate"

/datum/supply_packs/security/securityclothes
	name = "Security Clothing Crate"
	contains = list(/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/under/rank/security/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/head/soft/sec/corp,
					/obj/item/clothing/under/rank/warden/corp,
					/obj/item/clothing/head/beret/sec/warden,
					/obj/item/clothing/under/rank/head_of_security/corp,
					/obj/item/clothing/head/HoS/beret)
	cost = 30
	containername = "security clothing crate"

/datum/supply_packs/security/officerpack // Starter pack for an officer. Contains everything in a locker but backpack (officer already start with one). Convenient way to equip new officer on highpop.
	name = "Officer Starter Pack"
	contains = 	list(/obj/item/clothing/suit/armor/vest/security,
				/obj/item/radio/headset/headset_sec/alt,
				/obj/item/clothing/head/soft/sec,
				/obj/item/reagent_containers/spray/pepper,
				/obj/item/flash,
				/obj/item/grenade/flashbang,
				/obj/item/storage/belt/security/sec,
				/obj/item/holosign_creator/security,
				/obj/item/clothing/mask/gas/sechailer,
				/obj/item/clothing/glasses/hud/security/sunglasses,
				/obj/item/clothing/head/helmet,
				/obj/item/melee/baton/security/loaded,
				/obj/item/clothing/suit/armor/secjacket)
	cost = 40 // Convenience has a price and this pack is genuinely loaded
	containername = "officer starter crate"



//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Engineering /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/engineering
	name = "HEADER"
	group = SUPPLY_ENGINEER
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk"))
	containertype = /obj/structure/closet/crate/engineering

/datum/supply_packs/engineering/hardsuit
	name = "Engineering Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/engine,
					/obj/item/clothing/suit/space/hardsuit/engine,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 130
	containertype = /obj/structure/closet/crate/engineering
	required_tech = list("toxins" = 5, "engineering" = 4)
	containername = "Engineering Hardsuit Crate"
	access = ACCESS_ENGINE_EQUIP

/datum/supply_packs/engineering/hardsuit/atmospherics
	name = "Atmospherics Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/engine/atmos,
					/obj/item/clothing/suit/space/hardsuit/engine/atmos,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 130
	containertype = /obj/structure/closet/crate/engineering
	required_tech = list("toxins" = 6, "plasma" = 4)
	containername = "Engineering Hardsuit Crate"
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/engineering/fueltank
	name = "Fuel Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"

/datum/supply_packs/engineering/tools		//the most robust crate
	name = "Toolbox Crate"
	contains = list(/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/emergency,
					/obj/item/storage/toolbox/emergency,
					/obj/item/storage/toolbox/mechanical,
					/obj/item/storage/toolbox/mechanical)
	cost = 10
	containername = "electrical maintenance crate"

/datum/supply_packs/vending/engivend
	name = "Engineering Vendor Supply Crate"
	cost = 20
	contains = list(/obj/item/vending_refill/engivend,
					/obj/item/vending_refill/youtool)
	containername = "engineering supply crate"

/datum/supply_packs/engineering/powergamermitts
	name = "Insulated Gloves Crate"
	contains = list(/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow,
					/obj/item/clothing/gloves/color/yellow)
	cost = 30	//Made of pure-grade bullshittinium
	containername = "insulated gloves crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/power
	name = "Power Cell Crate"
	contains = list(/obj/item/stock_parts/cell/high,		//Changed to an extra high powercell because normal cells are useless
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 25
	containername = "electrical maintenance crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engiequipment
	name = "Engineering Gear Crate"
	contains = list(/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/storage/belt/utility,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat,
					/obj/item/clothing/head/hardhat)
	cost = 10
	containername = "engineering gear crate"

/datum/supply_packs/engineering/solar
	name = "Solar Pack Crate"
	contains  = list(/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly,
					/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
					/obj/item/circuitboard/solar_control,
					/obj/item/tracker_electronics,
					/obj/item/paper/solar)
	cost = 15
	containername = "solar pack crate"
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engine
	name = "Emitter Crate"
	contains = list(/obj/machinery/power/emitter,
					/obj/machinery/power/emitter)
	cost = 30
	containername = "emitter crate"
	access = ACCESS_CONSTRUCTION
	containertype = /obj/structure/closet/crate/secure/engineering

/datum/supply_packs/engineering/engine/field_gen
	name = "Field Generator Crate"
	contains = list(/obj/machinery/field/generator,
					/obj/machinery/field/generator)
	cost = 35
	containername = "field generator crate"

/datum/supply_packs/engineering/engine/sing_gen
	name = "Singularity Generator Crate"
	contains = list(/obj/machinery/the_singularitygen)
	cost = 150
	containername = "singularity generator crate"
	access = ACCESS_CE
	required_tech = list("powerstorage" = 6, "engineering" = 7)

/datum/supply_packs/engineering/engine/tesla
	name = "Energy Ball Generator Crate"
	contains = list(/obj/machinery/the_singularitygen/tesla)
	cost = 150
	containername = "energy ball generator crate"
	access = ACCESS_CE
	required_tech = list("powerstorage" = 7, "magnets" = 5)

/datum/supply_packs/engineering/engine/coil
	name = "Tesla Coil Crate"
	contains = list(/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil,
					/obj/machinery/power/tesla_coil)
	cost = 45
	containername = "tesla coil crate"

/datum/supply_packs/engineering/engine/grounding
	name = "Grounding Rod Crate"
	contains = list(/obj/machinery/power/grounding_rod,
					/obj/machinery/power/grounding_rod)
	cost = 10
	containername = "grounding rod crate"

/datum/supply_packs/engineering/engine/collector
	name = "Collector Crate"
	contains = list(/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector,
					/obj/machinery/power/rad_collector)
	cost = 45
	containername = "collector crate"

/datum/supply_packs/engineering/engine/PA
	name = "Particle Accelerator Crate"
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	cost = 50
	containername = "particle accelerator crate"
	access = ACCESS_CE
	required_tech = list("powerstorage" = 4, "magnets" = 4, "materials" = 3)

/datum/supply_packs/engineering/inflatable
	name = "Inflatable Barriers Crate"
	contains = list(/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable)
	cost = 10
	containername = "inflatable barrier crate"

/datum/supply_packs/engineering/engine/supermatter_shard
	name = "Supermatter Shard Crate"
	contains = list(/obj/machinery/power/supermatter_shard)
	cost = 150 //So cargo thinks twice before killing themselves with it
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "supermatter shard crate"
	access = ACCESS_CE
	required_tech = list("materials" = 7)

/datum/supply_packs/engineering/engine/teg
	name = "Thermo-Electric Generator Crate"
	contains = list(
		/obj/machinery/power/generator,
		/obj/item/pipe/circulator,
		/obj/item/pipe/circulator)
	cost = 225
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "thermo-electric generator crate"
	access = ACCESS_CE
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk", "Atmospherics"))
	required_tech = list("powerstorage" = 6, "engineering" = 5, "materials" = 2)

/datum/supply_packs/engineering/conveyor
	name = "Conveyor Assembly Crate"
	contains = list(/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_construct,
					/obj/item/conveyor_switch_construct,
					/obj/item/paper/conveyor)
	cost = 15
	containername = "conveyor assembly crate"

/datum/supply_packs/engineering/engine/magboots
	name = "Magboots Supply Crate"
	contains = list(/obj/item/clothing/shoes/magboots,
					/obj/item/clothing/shoes/magboots)
	cost = 50
	containername = "magboots crate"
	required_tech = list("magnets" = 4, "engineering" = 4)

/datum/supply_packs/engineering/permit
	name = "Construction Permit Crate"
	contains = list(/obj/item/areaeditor/permit)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "construction permit crate"
	access = ACCESS_CE

///////////// Station Goals

/datum/supply_packs/misc/station_goal
	name = "Empty Station Goal Crate"
	cost = 10
	special = TRUE
	containername = "empty station goal crate"
	containertype = /obj/structure/closet/crate/engineering

/datum/supply_packs/misc/station_goal/bsa
	name = "Bluespace Artillery Parts"
	cost = 300
	contains = list(/obj/item/circuitboard/machine/bsa/front,
					/obj/item/circuitboard/machine/bsa/middle,
					/obj/item/circuitboard/machine/bsa/back,
					/obj/item/circuitboard/computer/bsa_control
					)
	containername = "bluespace artillery parts crate"
	required_tech = list("powerstorage" = 6, "engineering" = 4, "combat" = 6, "bluespace" = 7)

/datum/supply_packs/misc/station_goal/bluespace_tap
	name = "Bluespace Harvester Parts"
	cost = 300
	contains = list(
					/obj/item/circuitboard/machine/bluespace_tap,
					/obj/item/paper/bluespace_tap
					)
	containername = "bluespace harvester parts crate"
	required_tech = list("powerstorage" = 7, "engineering" = 4, "magnets" = 6, "bluespace" = 5)

/datum/supply_packs/misc/station_goal/dna_vault
	name = "DNA Vault Parts"
	cost = 250
	contains = list(
					/obj/item/circuitboard/machine/dna_vault
					)
	containername = "dna vault parts crate"
	required_tech = list("engineering" = 4, "programming" = 7, "bluespace" = 3)

/datum/supply_packs/misc/station_goal/dna_probes
	name = "DNA Vault Samplers"
	cost = 30
	contains = list(/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	containername = "dna samplers crate"
	required_tech = list("biotech" = 6, "programming" = 5)

/datum/supply_packs/misc/station_goal/shield_sat
	name = "Shield Generator Satellite"
	cost = 200
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	containername = "shield sat crate"
	required_tech = list("combat" = 6, "programming" = 3)

/datum/supply_packs/misc/station_goal/shield_sat_control
	name = "Shield System Control Board"
	cost = 60
	contains = list(
					/obj/item/circuitboard/computer/sat_control
					)
	containername = "shield control board crate"
	required_tech = list("powerstorage" = 4, "programming" = 5, "magnets" = 4)

/datum/supply_packs/misc/station_goal/bfl
	name = "BFL assembly crate"
	cost = 50
	contains = list(
					/obj/item/circuitboard/machine/bfl_emitter,
					/obj/item/circuitboard/machine/bfl_receiver
					)
	containername = "BFL assembly crate"
	required_tech = list("engineering" = 5, "powerstorage" = 4, "bluespace" = 6, "plasmatech" = 6)

/datum/supply_packs/misc/station_goal/bfl_lens
	name = "BFL High-precision lens"
	cost = 100
	contains = list(
					/obj/machinery/bfl_lens
					)
	containername = "BFL High-precision lens"
	required_tech = list("materials" = 7, "bluespace" = 4)

/datum/supply_packs/misc/station_goal/bfl_goal
	name = "BFL Mission goal"
	cost = 3000
	contains = list(
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes,
					/obj/item/paper/researchnotes // 15 random research notes
					)
	containername = "Goal crate"

/datum/supply_packs/misc/station_goal/bluespace_rift
	name = "Bluespace Rift Research"
	cost = 150
	contains = list(
		/obj/item/disk/design_disk/station_goal_machinery/brs_server,
		/obj/item/disk/design_disk/station_goal_machinery/brs_portable_scanner,
		/obj/item/disk/design_disk/station_goal_machinery/brs_stationary_scanner,
	)
	containername = "bluespace rift research crate"
	containertype = /obj/structure/closet/crate/sci
	required_tech = list("engineering" = 3, "programming" = 6, "bluespace" = 7)



///////////// High-Tech Disks

/datum/supply_packs/misc/htdisk
	name = "HEADER"
	cost = 1
	special = TRUE
	containername = "htdisk crate"
	containertype = /obj/structure/closet/crate/secure/scisec
	access = ACCESS_RESEARCH

/datum/supply_packs/misc/htdisk/materials
	name = "Materials Research Disk Crate"
	contains = list(/obj/item/disk/tech_disk/loaded/materials)

/datum/supply_packs/misc/htdisk/engineering
	contains = list(/obj/item/disk/tech_disk/loaded/engineering)
	name = "Engineering Research Disk Crate"


/datum/supply_packs/misc/htdisk/plasmatech
	contains = list(/obj/item/disk/tech_disk/loaded/plasmatech)
	name = "Plasma Research Disk Crate"

/datum/supply_packs/misc/htdisk/powerstorage
	contains = list(/obj/item/disk/tech_disk/loaded/powerstorage)
	name = "Power Manipulation Technology Disk Crate"

/datum/supply_packs/misc/htdisk/bluespace
	contains = list(/obj/item/disk/tech_disk/loaded/bluespace)
	name = "'Blue-space' Research Disk Crate"

/datum/supply_packs/misc/htdisk/biotech
	contains = list(/obj/item/disk/tech_disk/loaded/biotech)
	name = "Biological Technology Disk Crate"

/datum/supply_packs/misc/htdisk/combat
	contains = list(/obj/item/disk/tech_disk/loaded/combat)
	name = "Combat Systems Research Disk Crate"

/datum/supply_packs/misc/htdisk/magnets
	contains = list(/obj/item/disk/tech_disk/loaded/magnets)
	name = "Electromagnetic Spectrum Research Disk Crate"

/datum/supply_packs/misc/htdisk/programming
	contains = list(/obj/item/disk/tech_disk/loaded/programming)
	name = "Data Theory Research Disk Crate"

/datum/supply_packs/misc/htdisk/toxins
	contains = list(/obj/item/disk/tech_disk/loaded/toxins)
	name = "Toxins Research Disk Crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Medical /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/medical
	name = "HEADER"
	containertype = /obj/structure/closet/crate/medical
	group = SUPPLY_MEDICAL
	announce_beacons = list("Medbay" = list("Medbay", "Chief Medical Officer's Desk"), "Security" = list("Brig Medbay"))

/datum/supply_packs/medical/hardsuit
	name = "Medical Hardsuit Crate"
	contains = list(/obj/item/clothing/suit/space/hardsuit/medical,
					/obj/item/clothing/suit/space/hardsuit/medical,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath)
	cost = 130
	containertype = /obj/structure/closet/crate/secure
	required_tech = list("toxins" = 4, "biotech" = 5)
	containername = "Medical Hardsuit Crate"
	access = ACCESS_MEDICAL


/datum/supply_packs/medical/supplies
	name = "Medical Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/reagent_containers/iv_bag/salglu,
					/obj/item/storage/box/beakers,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/box/iv_bags,
					/obj/item/vending_refill/medical)
	cost = 90
	containertype = /obj/structure/closet/crate/secure
	containername = "medical supplies crate"
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/firstaid
	name = "First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular)
	cost = 15
	containername = "first aid kits crate"

/datum/supply_packs/medical/firstaidadv
	name = "Advanced First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv)
	cost = 60
	containername = "advanced first aid kits crate"
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure
	required_tech = list("biotech" = 4, "materials" = 2)

/datum/supply_packs/medical/firstaibrute
	name = "Brute Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute)
	cost = 40
	containername = "brute first aid kits crate"
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure

/datum/supply_packs/medical/firstaidburns
	name = "Burns Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire)
	cost = 40
	containername = "fire first aid kits crate"
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure

/datum/supply_packs/medical/firstaidtoxins
	name = "Toxin Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin)
	cost = 20
	containername = "toxin first aid kits crate"

/datum/supply_packs/medical/firstaidoxygen
	name = "Oxygen Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2)
	cost = 15
	containername = "oxygen first aid kits crate"

/datum/supply_packs/medical/straightjacket
	name = "Straight Jacket Crate"
	contains = list(/obj/item/clothing/suit/straight_jacket)
	cost = 40
	containername = "straight jacket crate"

/datum/supply_packs/medical/virus
	name = "Virus Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/flu,
					/obj/item/reagent_containers/glass/bottle/cold,
					/obj/item/reagent_containers/glass/bottle/sneezing,
					/obj/item/reagent_containers/glass/bottle/cough,
					/obj/item/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/reagent_containers/glass/bottle/magnitis,
					/obj/item/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/reagent_containers/glass/bottle/brainrot,
					/obj/item/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/reagent_containers/glass/bottle/anxiety,
					/obj/item/reagent_containers/glass/bottle/beesease,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/beakers,
					/obj/item/reagent_containers/glass/bottle/mutagen)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "virus crate"
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Virology", "Chief Medical Officer's Desk"))
	required_tech = list("biotech" = 6, "combat" = 2)

/datum/supply_packs/medical/cloning
	name = "NanoTrasen Experimental Cloning Machine Crate"
	contains = list(/obj/item/circuitboard/clonepod,
					/obj/item/circuitboard/cloning)
	cost = 350
	containertype = /obj/structure/closet/crate/secure
	containername = "NanoTrasen experimental cloning machine crate"
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Chief Medical Officer's Desk"))

/datum/supply_packs/medical/vending
	name = "Medical Vending Crate"
	cost = 150
	contains = list(/obj/item/vending_refill/medical,
					/obj/item/vending_refill/wallmed)
	containername = "medical vending crate"
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_MEDICAL
	required_tech = list("biotech" = 4, "programming" = 2)

/datum/supply_packs/medical/bloodpacks_syn_oxygenis
	name = "Synthetic Blood Pack Oxygenis"
	contains = list(/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis)
	cost = 300
	containertype = /obj/structure/closet/crate/secure
	containername = "synthetic blood pack oxygenis crate"
	access = ACCESS_MEDICAL
	required_tech = list("biotech" = 6, "toxins" = 3)

/datum/supply_packs/medical/bloodpacks_syn_nitrogenis
	name = "Synthetic Blood Pack Nitrogenis"
	contains = list(/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
					/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis)
	cost = 300
	containertype = /obj/structure/closet/crate/secure
	containername = "synthetic blood pack nitrogenis crate"
	access = ACCESS_MEDICAL
	required_tech = list("biotech" = 6, "toxins" = 3)

/datum/supply_packs/medical/bloodpacks_human
	name = "Human Blood Pack"
	contains = list(/obj/item/reagent_containers/iv_bag/blood/ABPlus,
					/obj/item/reagent_containers/iv_bag/blood/ABMinus,
					/obj/item/reagent_containers/iv_bag/blood/APlus,
					/obj/item/reagent_containers/iv_bag/blood/AMinus,
					/obj/item/reagent_containers/iv_bag/blood/BPlus,
					/obj/item/reagent_containers/iv_bag/blood/BMinus,
					/obj/item/reagent_containers/iv_bag/blood/OPlus,
					/obj/item/reagent_containers/iv_bag/blood/OMinus)
	cost = 40
	containertype = /obj/structure/closet/crate/freezer
	containername = "human blood pack crate"
	required_tech = list("biotech" = 3)

/datum/supply_packs/medical/bloodpacks_xenos
	name = "Xenos Blood Pack"
	contains = list(/obj/item/reagent_containers/iv_bag/blood/skrell,
					/obj/item/reagent_containers/iv_bag/blood/tajaran,
					/obj/item/reagent_containers/iv_bag/blood/vulpkanin,
					/obj/item/reagent_containers/iv_bag/blood/unathi,
					/obj/item/reagent_containers/iv_bag/blood/kidan,
					/obj/item/reagent_containers/iv_bag/blood/grey,
					/obj/item/reagent_containers/iv_bag/blood/diona,
					/obj/item/reagent_containers/iv_bag/blood/wryn,
					/obj/item/reagent_containers/iv_bag/blood/nian)
	cost = 65
	containertype = /obj/structure/closet/crate/freezer
	containername = "xenos blood pack crate"
	required_tech = list("biotech" = 3)

/datum/supply_packs/medical/iv_drip
	name = "IV Drip Crate"
	contains = list(/obj/machinery/iv_drip)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "IV drip crate"
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/surgery
	name = "Surgery Crate"
	contains = list(/obj/item/cautery,
					/obj/item/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/internals/anesthetic,
					/obj/item/FixOVein,
					/obj/item/hemostat,
					/obj/item/scalpel,
					/obj/item/bonegel,
					/obj/item/retractor,
					/obj/item/bonesetter,
					/obj/item/circular_saw)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "surgery crate"
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/incision
	name = "Incision System Crate"
	containername = "incision system crate"
	cost = 180
	contains = list(
		/obj/item/scalpel/laser/manager,
		/obj/item/scalpel/laser/manager,
		/obj/item/scalpel/laser/manager,
	)
	required_tech = list("biotech" = 4, "materials" = 7, "magnets" = 5, "programming" = 4)


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Science /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/science
	name = "HEADER"
	group = SUPPLY_SCIENCE
	announce_beacons = list("Research Division" = list("Science", "Research Director's Desk"))
	containertype = /obj/structure/closet/crate/sci

/datum/supply_packs/science/robotics
	name = "Robotics Assembly Crate"
	contains = list(/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/box/flashes,
					/obj/item/stock_parts/cell/high,
					/obj/item/stock_parts/cell/high)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "robotics assembly crate"
	access = ACCESS_ROBOTICS
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))


/datum/supply_packs/science/robotics/mecha_ripley
	name = "Circuit Crate (Ripley APLU)"
	contains = list(/obj/item/book/manual/ripley_build_and_repair,
					/obj/item/circuitboard/mecha/ripley/main, //TEMPORARY due to lack of circuitboard printer
					/obj/item/circuitboard/mecha/ripley/peripherals) //TEMPORARY due to lack of circuitboard printer
	cost = 25
	containername = "\improper APLU \"Ripley\" circuit crate"

/datum/supply_packs/science/robotics/mecha_odysseus
	name = "Circuit Crate (Odysseus)"
	contains = list(/obj/item/circuitboard/mecha/odysseus/peripherals, //TEMPORARY due to lack of circuitboard printer
					/obj/item/circuitboard/mecha/odysseus/main) //TEMPORARY due to lack of circuitboard printer
	cost = 55
	containername = "\improper \"Odysseus\" circuit crate"

/datum/supply_packs/science/firstaidmachine
	name = "Machine First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine)
	cost = 20
	containername = "machine first aid kits crate"

/datum/supply_packs/science/plasma
	name = "Plasma Assembly Crate"
	contains = list(/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/tank/internals/plasma,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/igniter,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/prox_sensor,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer,
					/obj/item/assembly/timer)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasma assembly crate"
	access = ACCESS_TOX_STORAGE

/datum/supply_packs/science/shieldwalls
	name = "Shield Generators Crate"
	contains = list(/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen,
					/obj/machinery/shieldwallgen)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "shield generators crate"
	access = ACCESS_TELEPORTER
	required_tech = list("engineering" = 3, "powerstorage" = 3)

/datum/supply_packs/science/transfer_valves
	name = "Tank Transfer Valves Crate"
	contains = list(/obj/item/transfer_valve,
					/obj/item/transfer_valve)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "tank transfer valves crate"
	access = ACCESS_RD
	required_tech = list("engineering" = 2, "toxins" = 3)

/datum/supply_packs/science/prototype
	name = "Machine Prototype Crate"
	contains = list(/obj/item/machineprototype)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "machine prototype crate"
	access = ACCESS_RESEARCH
	required_tech = list("engineering" = 4, "magnets" = 2)

/datum/supply_packs/science/oil
	name = "Oil Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/oil,
					/obj/item/reagent_containers/food/drinks/oilcan)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "oil tank crate"

/datum/supply_packs/science/dis_borg
	name = "Disassembled Cyborg Crate"
	contains = list(/obj/item/robot_parts/robot_suit,
					/obj/item/robot_parts/chest,
					/obj/item/robot_parts/head,
					/obj/item/robot_parts/l_arm,
					/obj/item/robot_parts/r_arm,
					/obj/item/robot_parts/l_leg,
					/obj/item/robot_parts/r_leg)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "borg crate"
	access = ACCESS_ROBOTICS

/datum/supply_packs/science/rad_suit
	name = "Radiation Suit Crate"
	contains = list(/obj/item/clothing/head/radiation,
					/obj/item/clothing/head/radiation,
					/obj/item/clothing/suit/radiation,
					/obj/item/clothing/suit/radiation)
	cost = 35
	containername = "radiation suit crate"
	required_tech = list("biotech" = 3, "materials" = 2)

/datum/supply_packs/science/sohs
	name = "Satchel of Holding Crate"
	contains = list(
		/obj/item/storage/backpack/holding/satchel,
		/obj/item/storage/backpack/holding/satchel,
		/obj/item/storage/backpack/holding/satchel,
	)
	cost = 400
	containername = "satchel of holding crate"
	required_tech = list("plasmatech" = 6, "engineering" = 5, "bluespace" = 6, "materials" = 5)

/datum/supply_packs/science/belt_of_hold
	name = "Belt of Holding Crate"
	containername = "belt of holding crate"
	cost = 220
	contains = list(
		/obj/item/storage/belt/bluespace,
		/obj/item/storage/belt/bluespace,
		/obj/item/storage/belt/bluespace,
	)
	required_tech = list("plasmatech" = 6, "engineering" = 5, "bluespace" = 6, "materials" = 5)

/datum/supply_packs/science/mining_sohs
	name = "Mining Satchel of Holding Crate"
	containername = "mining satchel of holding of holding crate"
	cost = 200
	contains = list(
		/obj/item/storage/bag/ore/holding,
		/obj/item/storage/bag/ore/holding,
		/obj/item/storage/bag/ore/holding,
	)
	required_tech = list("engineering" = 4, "bluespace" = 4, "materials" = 3)

/datum/supply_packs/science/cutters
	name = "Advanced Plasma Cutter Crate"
	containername = "advanced plasma cutter crate"
	cost = 220
	contains = list(
		/obj/item/gun/energy/plasmacutter/adv,
		/obj/item/gun/energy/plasmacutter/adv,
		/obj/item/gun/energy/plasmacutter/adv
	)
	required_tech = list("engineering" = 6, "combat" = 3, "plasmatech" = 6, "materials" = 5, "magnets" = 3)

/datum/supply_packs/science/cutters_shotgun
	name = "Industrial Fan Cutter Crate"
	containername = "industrial fan cutter crate"
	cost = 320
	contains = list(
		/obj/item/gun/energy/plasmacutter/shotgun,
		/obj/item/gun/energy/plasmacutter/shotgun,
		/obj/item/gun/energy/plasmacutter/shotgun
	)
	required_tech = list("powerstorage" = 5, "engineering" = 6, "combat" = 7, "plasmatech" = 7, "materials" = 7, "magnets" = 6)

/datum/supply_packs/science/eka
	name = "E.K.A. Crate"
	containername = "E.K.A. crate"
	cost = 270
	contains = list(
		/obj/item/gun/energy/kinetic_accelerator/experimental,
		/obj/item/gun/energy/kinetic_accelerator/experimental,
		/obj/item/gun/energy/kinetic_accelerator/experimental
	)
	required_tech = list("powerstorage" = 4, "engineering" = 6, "combat" = 6, "materials" = 4)

/datum/supply_packs/science/fireproof_rods
	name = "Fireproof Rods Crate"
	containername = "fireproof rods crate"
	cost = 150
	contains = list(/obj/item/stack/fireproof_rods/twentyfive)
	required_tech = list("plasmatech" = 4, "engineering" = 3, "materials" = 6)

/datum/supply_packs/science/super_cell
	name = "Super Power Cell Crate"
	containername = "super power cell crate"
	cost = 100
	contains = list(
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/super
	)
	required_tech = list("powerstorage" = 3, "materials" = 3)

/datum/supply_packs/science/bluespace_cell
	name = "Bluespace Power Cell Crate"
	containername = "bluespace power cell crate"
	cost = 200
	contains = list(
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace,
		/obj/item/stock_parts/cell/bluespace,
		/obj/item/stock_parts/cell/bluespace
	)
	required_tech = list("powerstorage" = 6, "materials" = 6, "engineering" = 5, "bluespace" = 5,)

/datum/supply_packs/science/adv_tools
	name = "Advanced Tools Crate"
	containername = "advanced tools crate"
	cost = 200
	contains = list(
		/obj/item/weldingtool/experimental,
		/obj/item/weldingtool/experimental,
		/obj/item/screwdriver/power,
		/obj/item/screwdriver/power,
		/obj/item/crowbar/power,
		/obj/item/crowbar/power,
		/obj/item/clothing/mask/gas/welding,
		/obj/item/clothing/mask/gas/welding,
	)
	required_tech = list("powerstorage" = 7, "engineering" = 4, "magnets" = 6, "bluespace" = 5, "biotech" = 3, "materials" = 2)

/datum/supply_packs/science/rcd_crate
	name = "R.C.D. Crate"
	containername = "R.C.D. crate"
	cost = 200
	contains = list(
		/obj/item/rcd,
		/obj/item/rcd,
		/obj/item/rcd
	)
	required_tech = list("engineering" = 3, "programming" = 2)

/datum/supply_packs/science/bluespace_beakers
	name = "Bluespace Beakers Crate"
	containername = "bluespace beakers crate"
	cost = 150
	contains = list(
		/obj/item/storage/box/beakers/bluespace,
		/obj/item/storage/box/beakers/bluespace
	)
	required_tech = list("plasmatech" = 4, "bluespace" = 6, "materials" = 5)

/datum/supply_packs/science/deluxe_parts
	name = "Deluxe Parts Crate"
	containername = "deluxe parts crate"
	cost = 180
	contains = list(
		/obj/item/storage/box/stockparts/deluxe,
		/obj/item/storage/box/stockparts/deluxe
	)
	required_tech = list("powerstorage" = 7, "engineering" = 5, "magnets" = 6, "bluespace" = 6, "programming" = 6, "materials" = 7)

/datum/supply_packs/science/cyborg_upgrades
	name = "Cyborg Upgrades Crate"
	containername = "cyborg upgrades crate"
	cost = 250
	contains = list(
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/thrusters,
		/obj/item/borg/upgrade/thrusters,
		/obj/item/borg/upgrade/thrusters,
	)
	required_tech = list("powerstorage" = 5, "engineering" = 5, "magnets" = 6, "materials" = 6)

/datum/supply_packs/science/civ_implants
	name = "Civillian Implants Crate"
	containername = "civillian implants crate"
	cost = 160
	contains = list(
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/eyes/meson,
		/obj/item/organ/internal/cyberimp/eyes/meson,
	)
	required_tech = list("materials" = 4, "biotech" = 4, "engineering" = 5, "plasmatech" = 4)

//Nanotrasen tailblade
/datum/supply_packs/science/tailblade
	name = "Tail Laserblade Implant Design"
	cost = 50
	contains = list(/obj/item/disk/design_disk/tailblade/blade_nt)
	containername = "tail laserblade design crate"
	containertype = /obj/structure/closet/crate/secure/scisec
	access = ACCESS_RESEARCH
	required_tech = list("materials" = 6, "combat" = 6, "biotech" = 6, "powerstorage" = 5)


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Organic /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/organic
	name = "HEADER"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer


/datum/supply_packs/organic/food
	name = "Food Crate"
	contains = list(/obj/item/reagent_containers/food/condiment/flour,
					/obj/item/reagent_containers/food/condiment/rice,
					/obj/item/reagent_containers/food/condiment/milk,
					/obj/item/reagent_containers/food/condiment/soymilk,
					/obj/item/reagent_containers/food/condiment/saltshaker,
					/obj/item/reagent_containers/food/condiment/peppermill,
					/obj/item/kitchen/rollingpin,
					/obj/item/storage/fancy/egg_box,
					/obj/item/mixing_bowl,
					/obj/item/mixing_bowl,
					/obj/item/reagent_containers/food/condiment/enzyme,
					/obj/item/reagent_containers/food/condiment/sugar,
					/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/banana)
	cost = 10
	containername = "food crate"
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_packs/organic/pizza
	name = "Pizza Crate"
	contains = list(/obj/item/pizzabox/margherita,
					/obj/item/pizzabox/mushroom,
					/obj/item/pizzabox/meat,
					/obj/item/pizzabox/vegetable,
					/obj/item/pizzabox/hawaiian)
	cost = 80
	containername = "Pizza crate"

/datum/supply_packs/organic/monkey
	name = "Monkey Crate"
	contains = list (/obj/item/storage/box/monkeycubes)
	cost = 30
	containername = "monkey crate"

/datum/supply_packs/organic/farwa
	name = "Farwa Crate"
	contains = list (/obj/item/storage/box/monkeycubes/farwacubes)
	cost = 30
	containername = "farwa crate"


/datum/supply_packs/organic/wolpin
	name = "Wolpin Crate"
	contains = list (/obj/item/storage/box/monkeycubes/wolpincubes)
	cost = 30
	containername = "wolpin crate"


/datum/supply_packs/organic/skrell
	name = "Neaera Crate"
	contains = list (/obj/item/storage/box/monkeycubes/neaeracubes)
	cost = 30
	containername = "neaera crate"

/datum/supply_packs/organic/stok
	name = "Stok Crate"
	contains = list (/obj/item/storage/box/monkeycubes/stokcubes)
	cost = 30
	containername = "stok crate"

/datum/supply_packs/organic/party
	name = "Party Equipment Crate"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/reagent_containers/food/drinks/bottle/patron,
					/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/ale,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/reagent_containers/food/drinks/cans/beer,
					/obj/item/grenade/confetti,
					/obj/item/grenade/confetti)
	cost = 20
	containername = "party equipment"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/organic/bar
	name = "Bar Starter Kit"
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/circuitboard/chem_dispenser/soda,
					/obj/item/circuitboard/chem_dispenser/beer)
	cost = 25
	containername = "beer starter kit"
	announce_beacons = list("Bar" = list("Bar"))

//////// livestock
/datum/supply_packs/organic/cow
	name = "Cow Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/cow
	containername = "cow crate"

/datum/supply_packs/organic/pig
	name = "Pig Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/pig
	containername = "pig crate"

/datum/supply_packs/organic/goat
	name = "Goat Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/goat
	containername = "goat crate"

/datum/supply_packs/organic/chicken
	name = "Chicken Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/chick
	containername = "chicken crate"

/datum/supply_packs/organic/turkey
	name = "Turkey Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/turkey
	containername = "turkey crate"

/datum/supply_packs/organic/corgi
	name = "Corgi Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/corgi
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "corgi crate"

/datum/supply_packs/organic/dog_pug
	name = "Dog Pug Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/dog_pug
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog pug crate"

/datum/supply_packs/organic/dog_bullterrier
	name = "Dog Bullterrie Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/dog_bullterrier
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog bullterrie crate"

/datum/supply_packs/organic/dog_tamaskan
	name = "Dog Tamaskan Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/dog_tamaskan
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog tamaskan crate"

/datum/supply_packs/organic/dog_german
	name = "Dog German Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/dog_german
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog german crate"

/datum/supply_packs/organic/dog_brittany
	name = "Dog Brittany Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/dog_brittany
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "dog brittany crate"

/datum/supply_packs/organic/cat
	name = "Cat Crate"
	cost = 50 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/critter/cat
	contains = list(/obj/item/clothing/accessory/petcollar,
					/obj/item/toy/cattoy)
	containername = "cat crate"

/datum/supply_packs/organic/cat/white
	name = "White Cat Crate"
	containername = "white crate"
	containertype = /obj/structure/closet/critter/cat_white

/datum/supply_packs/organic/cat/birman
	name = "Birman Cat Crate"
	containername = "birman crate"
	containertype = /obj/structure/closet/critter/cat_birman

/datum/supply_packs/organic/fox
	name = "Fox Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/fox
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "fox crate"

/datum/supply_packs/organic/fennec
	name = "Fennec Crate"
	cost = 80
	containertype = /obj/structure/closet/critter/fennec
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "fennec crate"

/datum/supply_packs/organic/butterfly
	name = "Butterfly Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/butterfly
	containername = "butterfly crate"

/datum/supply_packs/organic/deer
	name = "Deer Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/deer
	containername = "deer crate"

/datum/supply_packs/organic/sloth
	name = "Sloth Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/sloth
	contains = list(/obj/item/clothing/accessory/petcollar)
	containername = "sloth crate"

/datum/supply_packs/organic/goose
	name = "Goose Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/goose
	containername = "goose crate"

/datum/supply_packs/organic/gosling
	name = "Gosling Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/gosling
	containername = "gosling crate"

/datum/supply_packs/organic/hamster
	name = "Hamster Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/hamster
	containername = "hamster crate"

/datum/supply_packs/organic/frog
	name = "Frog Crate"
	cost = 90
	containertype = /obj/structure/closet/critter/frog
	containername = "frog crate"

/datum/supply_packs/organic/frog/toxic
	name = "ERROR frog Crate"
	cost = 200
	containertype = /obj/structure/closet/critter/frog/toxic
	containername = "ERROR frog crate"
	hidden = 1

/datum/supply_packs/organic/turtle
	name = "Turtle Crate"
	cost = 80
	containertype = /obj/structure/closet/critter/turtle
	containername = "turtle crate"

/datum/supply_packs/organic/iguana
	name = "Iguana Crate"
	cost = 150
	containertype = /obj/structure/closet/critter/iguana
	containername = "iguana crate"

/datum/supply_packs/organic/gator
	name = "Gator Crate"
	cost = 300	//most dangerous
	containertype = /obj/structure/closet/critter/gator
	containername = "gator crate"

/datum/supply_packs/organic/croco
	name = "Croco Crate"
	cost = 250
	containertype = /obj/structure/closet/critter/croco
	containername = "croco crate"

/datum/supply_packs/organic/snake
	name = "Snake Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/snake
	containername = "snake crate"

/datum/supply_packs/organic/slime
	name = "Slime Crate"
	cost = 50
	containertype = /obj/structure/closet/critter/slime
	containername = "slime crate"

/datum/supply_packs/organic/barthender_rare
	name = "Bartender Rare Reagents Crate"
	containername = "bartender rare crate"
	cost = 60
	contains = list(
		/obj/item/storage/box/bartender_rare_ingredients_kit
	)

/datum/supply_packs/organic/chef_rare
	name = "Chef Rare Reagents Crate"
	containername = "chef rare crate"
	cost = 40
	contains = list(
		/obj/item/storage/box/chef_rare_ingredients_kit,
		/obj/item/storage/box/chef_rare_ingredients_kit
	)

/datum/supply_packs/science/strange_seeds
	name = "Strange Seeds Crate"
	containername = "strange seeds crate"
	cost = 300
	contains = list(
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random
	)
	required_tech = list("biotech" = 6)

/datum/supply_packs/organic/gorilla
	name = "Gorilla Crate"
	cost = 100
	containertype = /obj/structure/closet/critter/gorilla
	containername = "gorilla crate (DANGER!)"

/datum/supply_packs/organic/cargororilla
	name = "Cargorilla Crate"
	cost = 150
	containertype = /obj/structure/closet/critter/cargorilla
	containername = "cargorilla crate"

////// hippy gear

/datum/supply_packs/organic/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list(/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/spray/plantbgone,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/hatchet,
					/obj/item/cultivator,
					/obj/item/plant_analyzer,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/clothing/suit/apron) // Updated with new things
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "hydroponics crate"
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/hydroponics/hydrotank
	name = "Hydroponics Watertank Crate"
	contains = list(/obj/item/watertank)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "hydroponics watertank crate"
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/vending/hydro_refills
	name = "Hydroponics Vending Machines Refills"
	cost = 20
	containertype = /obj/structure/closet/crate
	contains = list(/obj/item/vending_refill/hydroseeds,
					/obj/item/vending_refill/hydronutrients)
	containername = "hydroponics supply crate"

/datum/supply_packs/organic/hydroponics/exoticseeds
	name = "Exotic Seeds Crate"
	contains = list(/obj/item/seeds/nettle,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/replicapod,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/nymph,
					/obj/item/seeds/plump,
					/obj/item/seeds/liberty,
					/obj/item/seeds/amanita,
					/obj/item/seeds/reishi,
					/obj/item/seeds/banana,
					/obj/item/seeds/bamboo,
					/obj/item/seeds/eggplant/eggy,
					/obj/item/seeds/random,
					/obj/item/seeds/random)
	cost = 15
	containername = "exotic seeds crate"

/datum/supply_packs/organic/hydroponics/beekeeping_fullkit
	name = "Beekeeping Starter Kit"
	contains = list(/obj/structure/beebox/unwrenched,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/honey_frame,
					/obj/item/queen_bee/bought,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/melee/flyswatter)
	cost = 15
	containername = "beekeeping starter kit"

/datum/supply_packs/organic/hydroponics/beekeeping_suits
	name = "2 Beekeeper suits"
	contains = list(/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit,
					/obj/item/clothing/head/beekeeper_head,
					/obj/item/clothing/suit/beekeeper_suit)
	cost = 10
	containername = "beekeeper suits"

//Bottler
/datum/supply_packs/organic/bottler
	name = "Brewing Buddy Bottler Unit"
	contains = list(/obj/machinery/bottler,
					/obj/item/wrench)
	cost = 20
	containername = "bottler crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/materials
	name = "HEADER"
	group = SUPPLY_MATERIALS
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk", "Atmospherics"))


/datum/supply_packs/materials/metal50
	name = "50 Metal Sheets Crate"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 20
	containername = "metal sheets crate"

/datum/supply_packs/materials/plasteel20
	name = "20 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/lowplasma)
	amount = 20
	cost = 90
	containername = "plasteel sheets crate"

/datum/supply_packs/materials/plasteel50
	name = "50 Plasteel Sheets Crate"
	contains = list(/obj/item/stack/sheet/plasteel/lowplasma)
	amount = 50
	cost = 210
	containername = "plasteel sheets crate"

/datum/supply_packs/materials/glass50
	name = "50 Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 15
	containername = "glass sheets crate"

/datum/supply_packs/materials/wood30
	name = "30 Wood Planks Crate"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 30
	cost = 15
	containername = "wood planks crate"

/datum/supply_packs/materials/cardboard50
	name = "50 Cardboard Sheets Crate"
	contains = list(/obj/item/stack/sheet/cardboard)
	amount = 50
	cost = 15
	containername = "cardboard sheets crate"

/datum/supply_packs/materials/sandstone30
	name = "30 Sandstone Blocks Crate"
	contains = list(/obj/item/stack/sheet/mineral/sandstone)
	amount = 30
	cost = 20
	containername = "sandstone blocks crate"


/datum/supply_packs/materials/plastic30
	name = "30 Plastic Sheets Crate"
	contains = list(/obj/item/stack/sheet/plastic)
	amount = 30
	cost = 20
	containername = "plastic sheets crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/misc
	name = "HEADER"
	group = SUPPLY_MISC

/datum/supply_packs/misc/mule
	name = "MULEbot Crate"
	contains = list(/mob/living/simple_animal/bot/mulebot)
	cost = 20
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot crate"

/datum/supply_packs/misc/cargo_mon
	name = "Order Monitors Crate"
	contains = list(/obj/item/qm_quest_tablet/cargotech, /obj/item/qm_quest_tablet/cargotech, /obj/item/qm_quest_tablet/cargotech)
	cost = 30
	containername = "\improper order monitors crate"

/datum/supply_packs/misc/watertank
	name = "Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 8
	containertype = /obj/structure/largecrate
	containername = "water tank crate"

/datum/supply_packs/misc/hightank
	name = "High-Capacity Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	cost = 12
	containertype = /obj/structure/largecrate
	containername = "high-capacity water tank crate"

/datum/supply_packs/misc/lasertag
	name = "Laser Tag Crate"
	contains = list(/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	cost = 15
	containername = "laser tag crate"

/datum/supply_packs/misc/religious_supplies
	name = "Religious Supplies Crate"
	contains = list(/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/reagent_containers/food/drinks/bottle/holywater,
					/obj/item/storage/bible/booze,
					/obj/item/storage/bible/booze,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/suit/hooded/chaplain_hoodie,
					/obj/item/clothing/under/burial,
					/obj/item/clothing/under/burial)
	cost = 40
	containername = "religious supplies crate"

/datum/supply_packs/misc/minerkit
	name = "Shaft Miner Starter Kit"
	cost = 30
	access = ACCESS_QM
	contains = list(/obj/item/storage/backpack/duffel/mining_conscript)
	containertype = /obj/structure/closet/crate/secure
	containername = "shaft miner starter kit"

/datum/supply_packs/misc/patriotic
	name = "Patriotic Crate"
	cost = 111
	containertype = /obj/structure/closet/crate/trashcart
	contains = list(/obj/item/flag/nt,
					/obj/item/flag/nt,
					/obj/item/flag/nt,
					/obj/item/flag/nt,
					/obj/item/flag/nt,
					/obj/item/flag/nt,
					/obj/item/book/manual/security_space_law,
					/obj/item/book/manual/security_space_law,
					/obj/item/book/manual/security_space_law,
					/obj/item/book/manual/security_space_law,
					/obj/item/book/manual/security_space_law,
					/obj/item/book/manual/security_space_law,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official
					)

	containername = "patriotic crate"

/datum/supply_packs/misc/golden_toilet
	name = "Golden Toilet"
	cost = 500
	contains = list(/obj/structure/toilet/golden_toilet)
	containername = "golden toilet"


///////////// Paper Work

/datum/supply_packs/misc/paper
	name = "Bureaucracy Crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/stack/tape_roll,
					/obj/item/paper_bin,
					/obj/item/pen,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/stamp/denied,
					/obj/item/stamp/granted,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard,
					/obj/item/clipboard)
	cost = 15
	containername = "bureaucracy crate"

/datum/supply_packs/misc/book_crate
	name = "Research Crate"
	contains = list(/obj/item/book/codex_gigas)
	cost = 15
	containername = "book crate"

/datum/supply_packs/misc/book_crate/New()
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	..()

/datum/supply_packs/misc/tape
	name = "Sticky Tape Crate"
	contains = list(/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll)
	cost = 10
	containername = "sticky tape crate"
	containertype = /obj/structure/closet/crate/tape

/datum/supply_packs/misc/toner
	name = "Toner Cartridges Crate"
	contains = list(/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner,
					/obj/item/toner)
	cost = 10
	containername = "toner cartridges crate"

/datum/supply_packs/misc/artscrafts
	name = "Arts and Crafts Supplies Crate"
	contains = list(/obj/item/storage/fancy/crayons,
	/obj/item/camera,
	/obj/item/camera_film,
	/obj/item/camera_film,
	/obj/item/storage/photo_album,
	/obj/item/stack/packageWrap,
	/obj/item/reagent_containers/glass/paint/red,
	/obj/item/reagent_containers/glass/paint/green,
	/obj/item/reagent_containers/glass/paint/blue,
	/obj/item/reagent_containers/glass/paint/yellow,
	/obj/item/reagent_containers/glass/paint/violet,
	/obj/item/reagent_containers/glass/paint/black,
	/obj/item/reagent_containers/glass/paint/white,
	/obj/item/reagent_containers/glass/paint/remover,
	/obj/item/poster/random_official,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper)
	cost = 10
	containername = "arts and crafts crate"

/datum/supply_packs/misc/posters
	name = "Corporate Posters Crate"
	contains = list(/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official)
	cost = 8
	containername = "corporate posters crate"

///////////// Janitor Supplies

/datum/supply_packs/misc/janitor
	name = "Janitorial Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner)
	cost = 10
	containername = "janitorial supplies crate"
	announce_beacons = list("Janitor" = list("Janitorial"))

/datum/supply_packs/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "janitorial cart crate"

/datum/supply_packs/misc/janitor/janitank
	name = "Janitor Watertank Backpack"
	contains = list(/obj/item/watertank/janitor)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "janitor watertank crate"
	access = ACCESS_JANITOR

/datum/supply_packs/misc/janitor/lightbulbs
	name = "Replacement Lights Crate"
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	cost = 10
	containername = "replacement lights crate"

/datum/supply_packs/misc/noslipfloor
	name = "High-traction Floor Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 20
	containername = "high-traction floor tiles"

///////////// Costumes

/datum/supply_packs/misc/costume
	name = "Standard Costume Crate"
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/clown,
					/obj/item/bikehorn,
					/obj/item/storage/backpack/mime,
					/obj/item/clothing/under/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
					/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana
					)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "standard costumes"
	access = ACCESS_THEATRE

/datum/supply_packs/misc/wizard
	name = "Wizard Costume Crate"
	contains = list(/obj/item/twohanded/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake)
	cost = 20
	containername = "wizard costume crate"

/datum/supply_packs/misc/mafia
	name = "Mafia Supply Crate"
	contains = list(/obj/item/clothing/suit/storage/browntrenchcoat,
					/obj/item/clothing/suit/storage/blacktrenchcoat,
					/obj/item/clothing/head/fedora/whitefedora,
					/obj/item/clothing/head/fedora/brownfedora,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/under/flappers,
					/obj/item/clothing/under/mafia,
					/obj/item/clothing/under/mafia/vest,
					/obj/item/clothing/under/mafia/white,
					/obj/item/clothing/under/mafia/sue,
					/obj/item/clothing/under/mafia/tan,
					/obj/item/gun/projectile/shotgun/toy/tommygun,
					/obj/item/gun/projectile/shotgun/toy/tommygun)
	cost = 15
	containername = "mafia supply crate"

/datum/supply_packs/misc/sunglasses
	name = "Sunglasses Crate"
	contains = list(/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses)
	cost = 30
	containername = "sunglasses crate"
/datum/supply_packs/misc/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
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
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectible Hats Crate"
	cost = 200
	containername = "collectable hats crate! Brought to you by Bass.inc!"

/datum/supply_packs/misc/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()


/datum/supply_packs/misc/foamforce
	name = "Foam Force Crate"
	contains = list(/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy)
	cost = 10
	containername = "foam force crate"

/datum/supply_packs/misc/bigband
	name = "Big band instrument collection"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/eguitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/item/instrument/xylophone,
					/obj/structure/piano/unanchored,
					/obj/structure/musician/drumkit)
	cost = 50
	containername = "Big band musical instruments collection"

/datum/supply_packs/misc/formalwear //This is a very classy crate.
	name = "Formal Wear Crate"
	contains = list(/obj/item/clothing/under/blacktango,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/assistantformal,
					/obj/item/clothing/under/lawyer/bluesuit,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/under/lawyer/purpsuit,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/under/lawyer/black,
					/obj/item/clothing/suit/storage/lawyer/blackjacket,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/accessory/blue,
					/obj/item/clothing/accessory/red,
					/obj/item/clothing/accessory/black,
					/obj/item/clothing/head/bowlerhat,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit_jacket/charcoal,
					/obj/item/clothing/under/suit_jacket/navy,
					/obj/item/clothing/under/suit_jacket/burgundy,
					/obj/item/clothing/under/suit_jacket/checkered,
					/obj/item/clothing/under/suit_jacket/tan,
					/obj/item/lipstick/random)
	cost = 30 //Lots of very expensive items. You gotta pay up to look good!
	containername = "formal-wear crate"

/datum/supply_packs/misc/teamcolors		//For team sports like space polo
	name = "Team Jerseys Crate"
	// 4 red jerseys, 4 blue jerseys, and 1 beach ball
	contains = list(/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/beach_ball)
	cost = 15
	containername = "team jerseys crate"

/datum/supply_packs/misc/polo			//For space polo! Or horsehead Quiditch
	name = "Polo Supply Crate"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/twohanded/staff/broom,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/beach_ball)
	cost = 20
	containername = "polo supply crate"

/datum/supply_packs/misc/boxing			//For non log spamming cargo brawls!
	name = "Boxing Supply Crate"
	// 4 boxing gloves
	contains = list(/obj/item/clothing/gloves/boxing/blue,
					/obj/item/clothing/gloves/boxing/green,
					/obj/item/clothing/gloves/boxing/yellow,
					/obj/item/clothing/gloves/boxing)
	cost = 15
	containername = "boxing supply crate"

///////////// Bathroom Fixtures

/datum/supply_packs/misc/toilet
	name = "Lavatory Crate"
	cost = 10
	contains = list(
					/obj/item/bathroom_parts,
					/obj/item/bathroom_parts/urinal
					)
	containername = "lavatory crate"

/datum/supply_packs/misc/hygiene
	name = "Hygiene Station Crate"
	cost = 10
	contains = list(
					/obj/item/bathroom_parts/sink,
					/obj/item/mounted/shower
					)
	containername = "hygiene station crate"

/datum/supply_packs/misc/snow_machine
	name = "Snow Machine Crate"
	cost = 20
	contains = list(
					/obj/machinery/snow_machine
					)
	special = TRUE


/datum/supply_packs/misc/crematorium
	name = "Crematorium Parts"
	cost = 15
	contains = list(
		/obj/item/circuitboard/machine/crematorium,
		/obj/item/toy/plushie/orange_fox,
	)
	containername = "crematorium parts crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Vending /////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/vending
	name = "HEADER"
	group = SUPPLY_VEND

/datum/supply_packs/vending/autodrobe
	name = "Autodrobe Supply Crate"
	contains = list(/obj/item/vending_refill/autodrobe)
	cost = 15
	containername = "autodrobe supply crate"

/datum/supply_packs/vending/clothes
	name = "ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing)
	cost = 15
	containername = "clothesmate supply crate"

/datum/supply_packs/vending/clothes/security
	name = "Security Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/security)
	cost = 80
	containername = "security departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/engineering
	name = "Engineering Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/engineering)
	cost = 50
	containername = "engineering departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/medical
	name = "Medical Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/medical)
	cost = 50
	containername = "medical departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/science
	name = "Science Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/science)
	cost = 30
	containername = "science departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/cargo
	name = "Cargo Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/cargo)
	cost = 30
	containername = "cargo departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/law
	name = "Law Departament ClothesMate Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/law)
	cost = 30
	containername = "law departament clothesmate supply crate"

/datum/supply_packs/vending/clothes/service/botanical
	name = "Service Departament ClothesMate Botanical Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/service/botanical)
	cost = 30
	containername = "Service Departament ClothesMate Botanical crate"

/datum/supply_packs/vending/clothes/service/chaplain
	name = "Service Departament ClothesMate Chaplain Supply Crate"
	contains = list(/obj/item/vending_refill/clothing/service/chaplain)
	cost = 30
	containername = "Service Departament ClothesMate Chaplain crate"

/datum/supply_packs/vending/suit
	name = "Suitlord Supply Crate"
	contains = list(/obj/item/vending_refill/suitdispenser)
	cost = 15
	containername = "suitlord supply crate"

/datum/supply_packs/vending/hat
	name = "Hatlord Supply Crate"
	contains = list(/obj/item/vending_refill/hatdispenser)
	cost = 15
	containername = "hatlord supply crate"

/datum/supply_packs/vending/shoes
	name = "Shoelord Supply Crate"
	contains = list(/obj/item/vending_refill/shoedispenser)
	cost = 15
	containername = "shoelord supply crate"

/datum/supply_packs/vending/pets
	name = "Pet Supply Crate"
	contains = list(/obj/item/vending_refill/crittercare)
	cost = 15
	containername = "pet supply crate"

/datum/supply_packs/vending/bartending
	name = "Booze-o-mat and Coffee Supply Crate"
	cost = 20
	contains = list(/obj/item/vending_refill/boozeomat,
					/obj/item/vending_refill/coffee)
	containername = "bartending supply crate"
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/vending/cigarette
	name = "Cigarette Supply Crate"
	contains = list(/obj/item/vending_refill/cigarette)
	cost = 15
	containername = "cigarette supply crate"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/vending/dinnerware
	name = "Dinnerware Supply Crate"
	cost = 10
	contains = list(/obj/item/vending_refill/dinnerware)
	containername = "dinnerware supply crate"

/datum/supply_packs/vending/imported
	name = "Imported Vending Machines"
	cost = 40
	contains = list(/obj/item/vending_refill/sustenance,
					/obj/item/vending_refill/robotics,
					/obj/item/vending_refill/sovietsoda,
					/obj/item/vending_refill/engineering)
	containername = "unlabeled supply crate"

/datum/supply_packs/vending/ptech
	name = "PTech Supply Crate"
	cost = 15
	contains = list(/obj/item/vending_refill/cart)
	containername = "ptech supply crate"

/datum/supply_packs/vending/snack
	name = "Snack Supply Crate"
	contains = list(/obj/item/vending_refill/snack)
	cost = 15
	containername = "snacks supply crate"

/datum/supply_packs/vending/cola
	name = "Softdrinks Supply Crate"
	contains = list(/obj/item/vending_refill/cola)
	cost = 15
	containername = "softdrinks supply crate"

/datum/supply_packs/vending/vendomat
	name = "Vendomat Supply Crate"
	cost = 10
	contains = list(/obj/item/vending_refill/assist)
	containername = "vendomat supply crate"

/datum/supply_packs/vending/chinese
	name = "Chinese Supply Crate"
	contains = list(/obj/item/vending_refill/chinese)
	cost = 15
	containername = "chinese supply crate"

/datum/supply_packs/vending/customat
	name = "Customat Resupply Canister Crate"
	contains = list(/obj/item/vending_refill/custom,
					/obj/item/vending_refill/custom)
	cost = 30
	containername = "customat canister supply crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// CONTRABAND SUPPLY ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/contraband
	name = "HEADER"
	group = SUPPLY_CONTRABAND
	contraband = TRUE
	cost = 0

/datum/supply_packs/contraband/mosin
	name = "Mosin Nagant crate"
	contains = list(/obj/item/gun/projectile/shotgun/boltaction,
					/obj/item/gun/projectile/shotgun/boltaction,
					/obj/item/ammo_box/speedloader/a762,
					/obj/item/ammo_box/speedloader/a762,
					/obj/item/ammo_box/speedloader/a762,
					/obj/item/ammo_box/speedloader/a762,
					/obj/item/ammo_box/speedloader/a762,
					/obj/item/ammo_box/speedloader/a762)
	cost = 80
	containername = "Mosin Nagant rifle crate"

/datum/supply_packs/contraband/ammobox_mosin
	name = "Mosin Nagant ammo box crate"
	contains = list(/obj/item/ammo_box/a762,
					/obj/item/ammo_box/a762)
	credits_cost = 2000
	containername = "7.62x54 mosin nagant ammo box crate"

/datum/supply_packs/contraband/ammobox556
	name = "5,56 ammo boxes crate"
	contains = list(/obj/item/ammo_box/a556,
					/obj/item/ammo_box/a556)
	credits_cost = 4500
	containername = "5,56 ammo boxes crate"

/datum/supply_packs/contraband/ammobox45
	name = ".45 ammo boxes crate"
	contains = list(/obj/item/ammo_box/c45/ext,
					/obj/item/ammo_box/c45/ext)
	credits_cost = 3000
	containername = ".45 ammo boxes crate"

/datum/supply_packs/contraband/ammobox45rubber
	name = ".45 rubber ammo boxes crate"
	contains = list(/obj/item/ammo_box/rubber45/ext,
					/obj/item/ammo_box/rubber45/ext)
	credits_cost = 3000
	containername = ".45 rubber ammo boxes crate"

/datum/supply_packs/contraband/ammoboxstechkinAP
	name = "10mm AP ammo boxes crate"
	contains = list(/obj/item/ammo_box/m10mm/ap,
					/obj/item/ammo_box/m10mm/ap)
	credits_cost = 2500
	containername = "10mm AP ammo boxes crate"

/datum/supply_packs/contraband/ammoboxstechkinHP
	name = "10mm HP ammo boxes crate"
	contains = list(/obj/item/ammo_box/m10mm/hp,
					/obj/item/ammo_box/m10mm/hp)
	credits_cost = 2200
	containername = "10mm HP ammo boxes crate"

/datum/supply_packs/contraband/ammoboxstechkinincendiary
	name = "10mm incendiary ammo boxes crate"
	contains = list(/obj/item/ammo_box/m10mm/fire,
					/obj/item/ammo_box/m10mm/fire)
	credits_cost = 2200
	containername = "10mm incendiary ammo boxes crate"

/datum/supply_packs/contraband/compact
	name = ".50L COMP ammo boxes crate"
	contains = list(/obj/item/ammo_box/sniper_rounds_compact,
					/obj/item/ammo_box/sniper_rounds_compact)
	credits_cost = 5000
	containername = ".50L COMP ammo boxes crate"

/datum/supply_packs/contraband/penetrator
	name = ".50 AP ammo boxes crate"
	contains = list(/obj/item/ammo_box/sniper_rounds_penetrator,
					/obj/item/ammo_box/sniper_rounds_penetrator)
	credits_cost = 9000
	containername = ".50 AP ammo boxes crate"

/datum/supply_packs/contraband/ammobox_nagant
	name = "7.62.38 nagant ammo boxes crate"
	contains = list(/obj/item/ammo_box/nagant,
					/obj/item/ammo_box/nagant)
	credits_cost = 4000
	containername = "7.62.38 nagant ammo boxes crate"

/datum/supply_packs/contraband/ammobox545
	name = "5.45x39 ammo boxes crate"
	contains = list(/obj/item/ammo_box/ak814,
					/obj/item/ammo_box/ak814)
	credits_cost = 4500
	containername = "5.45x39 ammo boxes crate"

/datum/supply_packs/contraband/rpg
	name = "Rockets crate"
	contains = list(/obj/item/ammo_casing/rocket,
					/obj/item/ammo_casing/rocket,
					/obj/item/ammo_casing/rocket)
	credits_cost = 25000
	containername = "rockets crate"

/datum/supply_packs/contraband/grenades
	name = "40mm grenade box crate"
	contains = list(/obj/item/ammo_box/a40mm)
	credits_cost = 16000
	containername = "40mm grenade boxe crate"

/datum/supply_packs/contraband/bombard_grenades
	name = "Bombarda grenades crate"
	contains = list(/obj/item/ammo_casing/grenade/improvised/exp_shell,
					/obj/item/ammo_casing/grenade/improvised/flame_shell,
					/obj/item/ammo_casing/grenade/improvised/smoke_shell)
	credits_cost = 7000
	containername = "bombarda grenades crate"

/datum/supply_packs/contraband/randomised/contraband
	var/num_contained = 5
	contains = list(/obj/item/storage/pill_bottle/random_drug_bottle,
					/obj/item/poster/random_contraband,
					/obj/item/storage/fancy/cigarettes/dromedaryco,
					/obj/item/storage/fancy/cigarettes/cigpack_shadyjims)
	name = "Contraband Crate"
	cost = 30
	containername = "crate"	//let's keep it subtle, eh?

/datum/supply_packs/contraband/randomised/contraband/New()
	manifest += "Contains any [num_contained] of:"
	..()

/datum/supply_packs/contraband/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 40
	containername = "foam force pistols crate"
